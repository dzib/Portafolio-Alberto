# src/config.py
import os


def load_dotenv():
    """Carga variables desde .env si la dependencia está disponible."""
    try:
        dotenv = __import__("dotenv")
        loader = getattr(dotenv, "load_dotenv", None)
        if callable(loader):
            return loader()
    except ModuleNotFoundError:
        return False
    return False


# Cargar variables desde el archivo .env
load_dotenv()

OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "llama3.2")
OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://localhost:11434")

DATA_DIR = "data"
REPORTS_DIR = os.getenv("REPORTS_PATH", "reports")
DATA_FILE = os.path.join(DATA_DIR, "ventas.csv")
