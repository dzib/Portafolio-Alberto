# src/generate_data.py
from datetime import datetime, timedelta
import os
from importlib import import_module

try:
    pd = import_module("pandas")
    np = import_module("numpy")
except ModuleNotFoundError as exc:
    raise ModuleNotFoundError(
        "Faltan dependencias para generar datos: instala pandas y numpy con 'pip install pandas numpy'."
    ) from exc

from src.config import DATA_DIR, DATA_FILE

def generar_datos_ecommerce(num_registros: int = 1500):
    """Genera un dataset sintético de e-commerce con complejidad realista (PyME)."""
    np.random.seed(42)

    fechas = [datetime(2025, 1, 1) + timedelta(days=int(np.random.randint(0, 365))) for _ in range(num_registros)]
    clientes = [f"Cliente_{np.random.randint(100, 250)}" for _ in range(num_registros)]
    productos = np.random.choice(["Software ERP", "Licencia CRM", "Consultoría Cloud", "Soporte SLA", "Migración Database"], size=num_registros)
    canales = np.random.choice(["Web Directo", "Partner", "Marketplace", "Venta Telefónica"], size=num_registros, p=[0.5, 0.2, 0.2, 0.1])

    # Simular montos de venta con distribución sesgada (realista para negocios)
    ventas = np.round(np.random.exponential(scale=1500, size=num_registros) + 200, 2)

    df = pd.DataFrame({
        "fecha": fechas,
        "cliente": clientes,
        "producto": productos,
        "canal": canales,
        "ventas": ventas
    })

    # Inyectar intencionalmente algunos nulos y anomalías para probar el pipeline de IA
    df.loc[np.random.choice(df.index, 10), "ventas"] = np.nan

    os.makedirs(DATA_DIR, exist_ok=True)
    df.to_csv(DATA_FILE, index=False)
    print(f"✅ Dataset corporativo generado exitosamente en: {DATA_FILE} ({num_registros} registros)")

if __name__ == "__main__":
    generar_datos_ecommerce()
