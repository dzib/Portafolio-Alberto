import os
from pathlib import Path
from dotenv import load_dotenv

# Cargar variables de entorno desde la raíz del módulo P4
load_dotenv()

# Rutas base del proyecto
BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"
LOGS_DIR = BASE_DIR / "logs"

# Configuración de Base de Datos para SQLAlchemy / PyGWalker
DB_SERVER = os.getenv("DB_SERVER", "Dzi bPC")
DB_NAME = os.getenv("DB_NAME", "P4_Global_SupplyChain")
DB_DRIVER = os.getenv("DB_DRIVER", "ODBC Driver 18 for SQL Server")

# String de Conexión Unificado
DATABASE_URL = f"mssql+pyodbc://@{DB_SERVER}/{DB_NAME}?driver={DB_DRIVER.replace(' ', '+')}&trusted_connection=yes&TrustServerCertificate=yes"
