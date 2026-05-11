# =============================================================
# ViveRioja ETL — Configuración centralizada
# =============================================================
# DECISIÓN: Todo lo configurable vive aquí.
# Si cambias de servidor, de base de datos o de rutas,
# solo tocas este archivo. El resto del código ni se entera.
# Esto sigue el principio de "un único punto de verdad" (SSOT).
#
# En producción real, la contraseña no estaría aquí sino en
# una variable de entorno o un secret manager (AWS Secrets,
# Azure Key Vault). Para portfolio local, así es suficiente.
# =============================================================

from pathlib import Path

# ─── Rutas del proyecto ───────────────────────────────────────
# Path(__file__).parent apunta a la carpeta /etl donde vive este archivo.
# Así las rutas funcionan independientemente de desde dónde ejecutes el script.
BASE_DIR           = Path(__file__).parent
DATA_RAW_DIR       = BASE_DIR / "data" / "raw"
DATA_PROCESSED_DIR = BASE_DIR / "data" / "processed"
OUTPUT_DIR         = BASE_DIR / "output"
DASHBOARD_DATA_DIR = BASE_DIR.parent / "public" / "dashboard" / "data"

# ─── Conexión PostgreSQL ──────────────────────────────────────
# Cambia estos valores si tu configuración de PostgreSQL es distinta.
DB_CONFIG = {
    "host":     "localhost",
    "port":     5432,
    "database": "viverioja",   # nombre de tu base de datos
    "user":     "postgres",
    "password": "1208207",       # ← cambia esto por tu contraseña real
}

# URL de conexión para SQLAlchemy.
# Formato: postgresql+psycopg2://usuario:password@host:puerto/basededatos
DB_URL = (
    f"postgresql+psycopg2://{DB_CONFIG['user']}:{DB_CONFIG['password']}"
    f"@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}"
)

# ─── Tablas a extraer ─────────────────────────────────────────
# Lista explícita: si añades una tabla nueva, solo la añades aquí.
TABLES_TO_EXTRACT = ["clientes", "reservas", "pagos", "experiencias"]
