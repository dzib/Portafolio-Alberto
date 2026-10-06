"""
=======================================================================================================================================
PROYECTO: P4_Real_World_Ingestion
FASE: 4.2.2 - Ingesta de Alta Velocidad (Kaggle a SQL)
AUTOR: Alberto Dzib
ESTÁNDAR: Dzib V13.0 (Resiliencia y Atomicidad)
DESCRIPCIÓN:
    - Carga masiva del dataset DataCo a SQL Server.
    - Cero Credenciales Quemadas: Uso estricto de variables de entorno (.env).
    - Patrón Idempotente y Fail-Fast.
    - Manejo atómico de transacciones con rollback automático ante fallos de red.
=======================================================================================================================================
"""

import os
import sys
import time
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy.exc import SQLAlchemyError

# Importamos tu conector (Asegúrate de que db_connect.py use os.getenv para las credenciales y fast_executemany=True)
from db_connect import get_engine

# =============================================================================
# CONFIGURACIÓN GLOBAL Y FAIL-FAST DE ENTORNO
# =============================================================================
PROJECT_ROOT = Path(__file__).resolve().parent.parent
CSV_FILE = PROJECT_ROOT / "data_sample" / "sample_data.csv" # Apuntamos a la muestra segura
TARGET_SCHEMA = "Staging"
TARGET_TABLE = "Kaggle_SupplyChain_Raw"

# 1. Carga Atómica de Credenciales
env_path = PROJECT_ROOT / ".env"
if not env_path.exists():
    print(f"❌ ERROR CRÍTICO: Archivo de configuración no encontrado en {env_path}")
    sys.exit(1)

load_dotenv(dotenv_path=env_path)

print("\nVALIDACIÓN DE RUTAS E INFRAESTRUCTURA")
print("=" * 80)
print(f"PROJECT_ROOT : {PROJECT_ROOT}")
print(f"CSV_FILE     : {CSV_FILE}")
print(f"TARGET       : {TARGET_SCHEMA}.{TARGET_TABLE}")
print("=" * 80)


# =============================================================================
# DATA CONTRACT (CSV -> SQL)
# =============================================================================
COLUMN_MAPPING = {
    "Type": "Type",
    "Days for shipping (real)": "Days_for_shipping_real",
    "Days for shipment (scheduled)": "Days_for_shipment_scheduled",
    "Benefit per order": "Benefit_per_order",
    "Sales per customer": "Sales_per_customer",
    "Delivery Status": "Delivery_Status",
    "Late_delivery_risk": "Late_delivery_risk",
    "Category Id": "Category_ID",
    "Category Name": "Category_Name",
    "Customer City": "Customer_City",
    "Customer Country": "Customer_Country",
    "order date (DateOrders)": "Order_Date_Raw",
    "Order Region": "Order_Region",
    "Order Item Total": "Order_Item_Total",
}

# =============================================================================
# VALIDACIONES
# =============================================================================
def validate_csv_file() -> None:
    """Verifica existencia del dataset."""
    if not CSV_FILE.exists():
        print(f"\n❌ Dataset no encontrado:\n{CSV_FILE}")
        sys.exit(1)

def validate_target_table(conn) -> None:
    """Valida existencia de tabla destino de forma atómica."""
    result = conn.exec_driver_sql(
        f"""
        SELECT COUNT(*)
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA = '{TARGET_SCHEMA}'
        AND TABLE_NAME = '{TARGET_TABLE}'
        """
    )
    exists = result.scalar()
    if not exists:
        raise ValueError(f"❌ La tabla destino {TARGET_SCHEMA}.{TARGET_TABLE} no existe. Ejecuta el DDL primero.")

def validate_schema_alignment(conn, dataframe) -> None:
    """Verifica que las columnas coincidan con SQL Server."""
    query = f"""
    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = '{TARGET_SCHEMA}'
      AND TABLE_NAME   = '{TARGET_TABLE}'
    """
    sql_columns = {row[0] for row in conn.exec_driver_sql(query)}
    dataframe_columns = set(dataframe.columns)
    missing_in_sql = dataframe_columns - sql_columns

    if missing_in_sql:
        raise ValueError(f"❌ Columnas no encontradas en SQL: {missing_in_sql}")
    print("✅ Contrato de esquema validado contra SQL Server.")


# =============================================================================
# INGESTA PRINCIPAL (TRANSACCIÓN ATÓMICA)
# =============================================================================
def bulk_load() -> None:
    print("\n" + "=" * 80)
    print("🚀 INICIO DE PROCESO DE INGESTA V13.0")
    print("=" * 80)

    validate_csv_file()
    print("\n📖 Leyendo dataset en memoria...")

    df = pd.read_csv(
        CSV_FILE,
        encoding="utf-8-sig",
        sep=",",
        engine="python",
        on_bad_lines="skip",
    )

    # Limpieza de cabeceras
    df.columns = df.columns.str.encode("ascii", "ignore").str.decode("ascii").str.strip()
    print(f"\n✅ Registros leídos en crudo : {len(df):,}")

    expected_columns = list(COLUMN_MAPPING.keys())
    missing_columns = [col for col in expected_columns if col not in df.columns]

    if missing_columns:
        print(f"\n❌ Columnas faltantes en el origen CSV: {missing_columns}")
        sys.exit(1)

    # DataFrame Staging
    df_staging = df[expected_columns].copy()
    df_staging.rename(columns=COLUMN_MAPPING, inplace=True)

    numeric_columns = [
      "Days_for_shipping_real", "Days_for_shipment_scheduled", "Benefit_per_order",
      "Sales_per_customer", "Late_delivery_risk", "Category_ID", "Order_Item_Total"
    ]

    for col in numeric_columns:
        df_staging[col] = pd.to_numeric(df_staging[col], errors="coerce")

    print(f"📊 Registros listos para ingesta : {len(df_staging):,}")

    engine = get_engine()
    if engine is None:
        print("❌ ERROR: No se pudo instanciar el motor de base de datos.")
        sys.exit(1)

    start_time = time.time()

    # 2. Bloque Transaccional Atómico
    try:
        # engine.begin() maneja el COMMIT automático al final o el ROLLBACK si hay excepción
        with engine.begin() as conn:
            validate_target_table(conn)
            validate_schema_alignment(conn, df_staging)

            print(f"\n🧹 Limpiando tabla destino ({TARGET_SCHEMA}.{TARGET_TABLE}) de forma idempotente...")
            conn.exec_driver_sql(f"TRUNCATE TABLE {TARGET_SCHEMA}.{TARGET_TABLE}")

            print("⬆️ Ejecutando carga masiva de alta velocidad (fast_executemany)...")

            df_staging.to_sql(
                name=TARGET_TABLE,
                schema=TARGET_SCHEMA,
                con=conn,
                if_exists="append",
                index=False,
                chunksize=1000,
            )

        elapsed_time = time.time() - start_time
        rows_per_second = len(df_staging) / elapsed_time if elapsed_time > 0 else 0

        print("\n" + "=" * 80)
        print("✅ INGESTA ATÓMICA COMPLETADA")
        print("=" * 80)
        print(f"📊 Registros persistidos : {len(df_staging):,}")
        print(f"⏱️ Tiempo de latencia    : {elapsed_time:.2f} s")
        print(f"🚀 Tasa de transferencia : {rows_per_second:,.2f} reg/s")
        print("=" * 80)

    except SQLAlchemyError as sql_err:
        print("\n" + "!" * 80)
        print("❌ FALLO DE RED O BASE DE DATOS (SE EJECUTÓ ROLLBACK)")
        print("!" * 80)
        print(f"Detalle Técnico: {sql_err}")
        sys.exit(1)
    except Exception as err:
        print("\n" + "!" * 80)
        print("❌ ERROR FATAL DE PROCESAMIENTO INESPERADO")
        print("!" * 80)
        print(f"Excepción: {err}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

# =============================================================================
# ENTRYPOINT
# =============================================================================
if __name__ == "__main__":
    bulk_load()
