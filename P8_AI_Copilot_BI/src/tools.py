# src/tools.py
import pandas as pd
import logging

# Configuración de logs profesionales
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)

def validar_estructura_df(df: pd.DataFrame) -> bool:
    """Valida que el DataFrame contenga las columnas esenciales para el análisis."""
    columnas_requeridas = ["fecha", "cliente", "ventas", "producto"]
    for col in columnas_requeridas:
        if col not in df.columns:
            logging.error(f"Falta la columna obligatoria: {col}")
            return False
    logging.info("Estructura del DataFrame validada correctamente con éxito.")
    return True

def limpiar_valores_nulos(df: pd.DataFrame) -> pd.DataFrame:
    """Limpia o reemplaza valores nulos críticos en métricas numéricas."""
    if "ventas" in df.columns:
        df["ventas"] = df["ventas"].fillna(0.0)
    return df
