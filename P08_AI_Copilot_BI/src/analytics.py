# src/analytics.py
import pandas as pd

def calcular_kpis(df: pd.DataFrame):
    """Calcula los indicadores clave de rendimiento (KPIs)."""
    ventas_totales = df["ventas"].sum()
    ticket_promedio = df["ventas"].mean()
    clientes_unicos = df["cliente"].nunique()

    kpis = {
        "ventas_totales": ventas_totales,
        "ticket_promedio": ticket_promedio,
        "clientes_unicos": clientes_unicos,
        "resumen_estadistico": df.describe().to_string()
    }
    return kpis
