# src/config.py
import os
from dotenv import load_dotenv

# Cargar variables desde el archivo .env
load_dotenv()

OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "llama3.2")
OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://localhost:11434")

DATA_DIR = "data"
REPORTS_DIR = os.getenv("REPORTS_PATH", "reports")
DATA_FILE = os.path.join(DATA_DIR, "ventas.csv")
