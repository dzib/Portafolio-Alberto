# src/config.py
import os

# Configuración del modelo local con Ollama
OLLAMA_MODEL = "llama3.2"

# Rutas de directorios
DATA_DIR = "data"
REPORTS_DIR = "reports"
DATA_FILE = os.path.join(DATA_DIR, "ventas.csv")
