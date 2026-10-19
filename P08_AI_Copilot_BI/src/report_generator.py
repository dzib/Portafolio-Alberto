# src/report_generator.py
import os
from src.config import REPORTS_DIR

def guardar_reporte_ejecutivo(contenido_ia: str, nombre_archivo: str = "reporte_ejecutivo.txt"):
    """Guarda el análisis generado por el agente en la carpeta de reportes."""
    os.makedirs(REPORTS_DIR, exist_ok=True)
    ruta_archivo = os.path.join(REPORTS_DIR, nombre_archivo)

    with open(ruta_archivo, "w", encoding="utf-8") as f:
        f.write("=" * 60 + "\n")
        f.write(" REPORTE EJECUTIVO DE ANALÍTICA - P8 AI COPOLIT BI\n")
        f.write("=" * 60 + "\n\n")
        f.write(contenido_ia)

    return ruta_archivo
