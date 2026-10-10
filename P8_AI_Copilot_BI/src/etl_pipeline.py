# src/etl_pipeline.py
import os
import time
import logging
import json
import pandas as pd  # pyright: ignore[reportMissingModuleSource]

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] [%(filename)s:%(lineno)d] - %(message)s"
)
logger = logging.getLogger(__name__)

def procesar_etl_multifuente():
    inicio_tiempo = time.time()
    logger.info("Iniciando pipeline ETL multi-fuente y optimización Parquet...")

    try:
        # Asegurar rutas absolutas seguras basadas en la ubicación del archivo o raíz
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        processed_dir = os.path.join(base_dir, "data", "processed")
        raw_dir = os.path.join(base_dir, "data", "raw")

        os.makedirs(processed_dir, exist_ok=True)

        path_csv = os.path.join(raw_dir, "ventas_ecommerce.csv")
        path_json = os.path.join(raw_dir, "transacciones_pos.json")

        if not os.path.exists(path_csv) or not os.path.exists(path_json):
            raise FileNotFoundError(f"No se encontraron los archivos en {raw_dir}. Ejecute primero generate_multi_source.py")

        # 1. Ingesta CSV
        logger.info(f"Leyendo origen CSV: {path_csv}")
        df_ecom = pd.read_csv(path_csv)
        df_ecom = df_ecom.rename(columns={"monto": "ventas"})
        df_ecom["fecha"] = pd.to_datetime(df_ecom["fecha"])

        # 2. Ingesta JSON
        logger.info(f"Leyendo origen JSON: {path_json}")
        with open(path_json, "r", encoding="utf-8") as f:
            data_pos = json.load(f)
        df_pos = pd.DataFrame(data_pos)
        df_pos = df_pos.rename(columns={
            "fecha_transaccion": "fecha",
            "id_cliente": "cliente",
            "articulo": "producto",
            "total_venta": "ventas"
        })
        df_pos["fecha"] = pd.to_datetime(df_pos["fecha"])

        # 3. Consolidación
        logger.info("Homologando esquemas y consolidando datasets...")
        df_unificado = pd.concat([df_ecom, df_pos], ignore_index=True)
        filas_iniciales = len(df_unificado)

        # 4. Limpieza
        nulos_detectados = int(df_unificado["ventas"].isnull().sum())
        if nulos_detectados > 0:
            media_ventas = df_unificado["ventas"].mean()
            df_unificado["ventas"] = df_unificado["ventas"].fillna(media_ventas)
            logger.info(f"Saneados {nulos_detectados} nulos con la media ({media_ventas:.2f}).")

        df_unificado["producto"] = df_unificado["producto"].str.strip().str.title()
        df_unificado["canal_origen"] = df_unificado["canal_origen"].str.strip()

        # 5. Exportación a Parquet con ruta absoluta
        output_parquet = os.path.join(processed_dir, "ventas_unificadas.parquet")
        logger.info(f"Escribiendo archivo Parquet en: {output_parquet}")
        df_unificado.to_parquet(output_parquet, index=False, engine="pyarrow")

        # Verificación inmediata de tamaño del archivo
        file_size = os.path.getsize(output_parquet)
        logger.info(f"Tamaño físico del Parquet generado: {file_size} bytes")

        duracion = time.time() - inicio_tiempo
        logger.info("==================================================")
        logger.info("📊 REPORTE DE EJECUCIÓN ETL (ESTÁNDAR DZIB V13.0)")
        logger.info(f"   - Total registros: {filas_iniciales}")
        logger.info(f"   - Tamaño Parquet: {file_size} bytes")
        logger.info(f"   - Tiempo: {duracion:.4f}s - Estado: ÉXITO 100%")
        logger.info("==================================================")

        return df_unificado

    except Exception as e:
        logger.error(f"❌ Error crítico en el pipeline ETL: {str(e)}", exc_info=True)
        raise

if __name__ == "__main__":
    procesar_etl_multifuente()
