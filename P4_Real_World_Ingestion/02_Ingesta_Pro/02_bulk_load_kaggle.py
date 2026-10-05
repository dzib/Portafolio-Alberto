"""
=======================================================================================================================================
PROYECTO: P4_Real_World_Ingestion
FASE: 4.2.2 - Ingesta de Alta Velocidad (Kaggle a SQL)

AUTOR:
    Alberto Dzib

DESCRIPCIÓN:
    - Carga masiva del dataset DataCo a SQL Server.
    - Uso de SQLAlchemy + fast_executemany.
    - Validación de rutas.
    - Validación de estructura.
    - Validación de tabla destino.
    - Métricas de rendimiento.
    - Patrón idempotente.
=======================================================================================================================================
"""

from pathlib import Path
import time

import pandas as pd
from db_connect import get_engine


# =============================================================================
# CONFIGURACIÓN GLOBAL
# =============================================================================

PROJECT_ROOT = Path(__file__).resolve().parents[2]

CSV_FILE = (
    PROJECT_ROOT
    / "data"
    / "DataCoSupplyChainDataset.csv"
)

TARGET_SCHEMA = "Staging"
TARGET_TABLE = "Kaggle_SupplyChain_Raw"


print("\nCONFIGURACIÓN DETECTADA")
print(f"PROJECT_ROOT = {PROJECT_ROOT}")
print(f"CSV_FILE = {CSV_FILE}")
print(f"SCHEMA = {TARGET_SCHEMA}")
print(f"TABLE = {TARGET_TABLE}")


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
    "order date (DateOrders)": "Order_Date",
    "Order Region": "Order_Region",
    "Order Item Total": "Order_Item_Total"
}


# =============================================================================
# VALIDACIONES
# =============================================================================


def validate_csv_file() -> None:
    """Verifica existencia del dataset."""

    if not CSV_FILE.exists():
        raise FileNotFoundError(
            f"\n❌ Dataset no encontrado:\n{CSV_FILE}"
        )


def validate_target_table(conn) -> None:
    """Valida existencia de tabla destino."""

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
        raise ValueError(
            f"""
            ❌ La tabla destino no existe.

            Schema : {TARGET_SCHEMA}
            Tabla  : {TARGET_TABLE}

            Ejecuta primero:

            P4_Real_World_Ingestion/
            └── 01_Setup_DDL/
                └── 01_db_creation.sql
            """
        )

def validate_schema_alignment(
    conn,
    dataframe
):
    """
    Verifica que las columnas
    coincidan con SQL Server.
    """

    query = f"""
    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = '{TARGET_SCHEMA}'
      AND TABLE_NAME   = '{TARGET_TABLE}'
    """

    sql_columns = {
        row[0]
        for row in conn.exec_driver_sql(query)
    }

    dataframe_columns = set(
        dataframe.columns
    )

    missing_in_sql = (
        dataframe_columns - sql_columns
    )

    if missing_in_sql:

        raise ValueError(
            f"""
❌ Columnas no encontradas en SQL:

{missing_in_sql}
"""
        )

    print(
        "✅ Contrato de esquema validado."
    )

# =============================================================================
# INGESTA PRINCIPAL
# =============================================================================


def bulk_load() -> None:

    print("\n" + "=" * 80)
    print("🚀 INICIO DE PROCESO DE INGESTA")
    print("=" * 80)

    print(f"\n📂 Proyecto : {PROJECT_ROOT}")
    print(f"📄 Dataset  : {CSV_FILE}")

    validate_csv_file()

    print("\n📖 Leyendo dataset...")

    df = pd.read_csv(
        CSV_FILE,
        encoding="utf-8-sig",
        sep=",",
        engine="python",
        on_bad_lines="skip",
    )

    # -------------------------------------------------------------------------
    # Limpieza de cabeceras
    # -------------------------------------------------------------------------

    df.columns = (
        df.columns
        .str.encode("ascii", "ignore")
        .str.decode("ascii")
        .str.strip()
    )

    print(f"\n✅ Registros leídos : {len(df):,}")

    expected_columns = [
        "Type",
        "Days for shipping (real)",
        "Days for shipment (scheduled)",
        "Benefit per order",
        "Sales per customer",
        "Delivery Status",
        "Late_delivery_risk",
        "Category Id",
        "Category Name",
        "Customer City",
        "Customer Country",
        "order date (DateOrders)",
        "Order Region",
        "Order Item Total",
    ]

    missing_columns = [
        col
        for col in expected_columns
        if col not in df.columns
    ]

    if missing_columns:
        raise ValueError(
            f"""
❌ Columnas faltantes en CSV:

{missing_columns}
"""
        )

    # -------------------------------------------------------------------------
    # DataFrame Staging
    # -------------------------------------------------------------------------

    df_staging = df[expected_columns].copy()

    df_staging.rename(
    columns=COLUMN_MAPPING,
    inplace=True
    )

    print(f"📊 Registros para carga : {len(df_staging):,}")

    engine = get_engine()

    if engine is None:
        raise RuntimeError(
            "No se pudo obtener la conexión a la base de datos."
        )

    start_time = time.time()

    try:

        with engine.begin() as conn:

            validate_target_table(conn)

            validate_schema_alignment(
            conn,
            df_staging
            )

            print(
                f"\n🧹 Limpiando tabla {TARGET_SCHEMA}.{TARGET_TABLE}"
            )

            conn.exec_driver_sql(
                f"TRUNCATE TABLE {TARGET_SCHEMA}.{TARGET_TABLE}"
            )

            print("⬆️ Ejecutando carga masiva...")

            df_staging.to_sql(
                name=TARGET_TABLE,
                schema=TARGET_SCHEMA,
                con=conn,
                if_exists="append",
                index=False,
                chunksize=10000,
                method="multi",
            )

        elapsed_time = time.time() - start_time

        rows_per_second = (
            len(df_staging) / elapsed_time
            if elapsed_time > 0
            else 0
        )

        print("\n" + "=" * 80)
        print("✅ INGESTA COMPLETADA")
        print("=" * 80)

        print(f"📊 Registros cargados : {len(df_staging):,}")
        print(f"⏱️ Tiempo total      : {elapsed_time:.2f} s")
        print(f"🚀 Velocidad         : {rows_per_second:,.2f} reg/s")

        print("=" * 80)

    except Exception as exc:

        print("\n" + "!" * 80)
        print("❌ ERROR DE INGESTA")
        print("!" * 80)

        print(exc)

        print("!" * 80)

        raise


# =============================================================================
# ENTRYPOINT
# =============================================================================

if __name__ == "__main__":
    bulk_load()
