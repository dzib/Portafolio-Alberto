# src/generate_multi_source.py
import os
import json
import logging
import random
from datetime import datetime, timedelta
import pandas as pd # pyright: ignore[reportMissingModuleSource]

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] [%(filename)s:%(lineno)d] - %(message)s"
)
logger = logging.getLogger(__name__)

def generar_fuentes_heterogeneas(num_ecom: int = 1000, num_pos: int = 500):
    try:
        logger.info("Iniciando proceso de generación de fuentes de datos heterogéneas...")

        # Rutas absolutas basadas en la ubicación del archivo actual
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        raw_dir = os.path.join(base_dir, "data", "raw")
        os.makedirs(raw_dir, exist_ok=True)

        random.seed(42)

        # 1. Generación E-commerce (CSV)
        logger.info(f"Generando dataset E-commerce ({num_ecom} registros)...")
        fechas_ecom = [datetime(2025, 1, 1) + timedelta(days=random.randrange(365)) for _ in range(num_ecom)]
        df_ecom = pd.DataFrame({
            "fecha": fechas_ecom,
            "canal_origen": "E-commerce Web",
            "cliente": [f"Cliente_Web_{random.randrange(100, 300)}" for _ in range(num_ecom)],
            "producto": random.choices(["Software ERP", "Licencia CRM", "Consultoría Cloud"], k=num_ecom),
            "monto": [round(random.expovariate(1 / 1200) + 150, 2) for _ in range(num_ecom)]
        })
        if num_ecom:
            indices_nan = random.sample(list(df_ecom.index), min(10, num_ecom))
            df_ecom.loc[indices_nan, "monto"] = None

        path_csv = os.path.join(raw_dir, "ventas_ecommerce.csv")
        df_ecom.to_csv(path_csv, index=False)
        logger.info(f"✅ Archivo CSV generado exitosamente en: {path_csv} (Filas: {len(df_ecom)})")

        # 2. Generación Tienda Física POS (JSON)
        logger.info(f"Generando transacciones POS ({num_pos} registros)...")
        datos_pos = []
        for _ in range(num_pos):
            datos_pos.append({
                "fecha_transaccion": (datetime(2025, 1, 1) + timedelta(days=random.randrange(365))).strftime("%Y-%m-%d"),
                "canal_origen": "Tienda Física POS",
                "id_cliente": f"Cliente_POS_{random.randrange(400, 600)}",
                "articulo": random.choice(["Soporte SLA", "Migración Database", "Hardware Setup"]),
                "total_venta": round(random.expovariate(1 / 2000) + 300, 2)
            })

        path_json = os.path.join(raw_dir, "transacciones_pos.json")
        with open(path_json, "w", encoding="utf-8") as f:
            json.dump(datos_pos, f, indent=4, ensure_ascii=False)
        logger.info(f"✅ Archivo JSON generado exitosamente en: {path_json} (Registros: {len(datos_pos)})")

    except Exception as e:
        logger.error(f"❌ Error crítico durante la generación de fuentes: {str(e)}", exc_info=True)
        raise

if __name__ == "__main__":
    generar_fuentes_heterogeneas()
