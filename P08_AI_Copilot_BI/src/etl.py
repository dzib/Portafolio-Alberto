# src/etl.py
import pandas as pd
import os
from src.config import DATA_FILE, DATA_DIR

def cargar_datos():
    """Carga y valida el dataset de transacciones."""
    if not os.path.exists(DATA_FILE):
        # Crear un dataset sintético de respaldo si no existe
        os.makedirs(DATA_DIR, exist_ok=True)
        data = {
            "fecha": ["2026-01-01", "2026-01-02", "2026-01-03", "2026-01-04"],
            "cliente": ["Empresa A", "Empresa B", "Empresa A", "Empresa C"],
            "ventas": [1500.50, 3200.00, 1200.00, 4500.00],
            "producto": ["Software", "Consultoría", "Software", "Cloud"]
        }
        df = pd.DataFrame(data)
        df.to_csv(DATA_FILE, index=False)

    df = pd.read_csv(DATA_FILE)
    df["fecha"] = pd.to_datetime(df["fecha"])
    return df
