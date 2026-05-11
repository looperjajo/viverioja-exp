# =============================================================
# ViveRioja ETL — Fase 1: Extract
# =============================================================
# DECISIÓN: Extract está separado de Transform por una razón
# fundamental de ingeniería de datos: si la extracción falla
# (PostgreSQL no responde, credenciales caducadas), no quieres
# que eso afecte al Transform. Cada fase puede fallar, reiniciarse
# y testearse de forma independiente.
#
# Además, guardar los CSV en /data/raw es el "checkpoint" del
# pipeline: si Transform falla, no necesitas volver a extraer
# desde la base de datos. Solo relanzas desde el paso 2.
# Eso ahorra tiempo y conexiones de red en pipelines grandes.
#
# DECISIÓN: SQLAlchemy + pandas.read_sql en lugar de psycopg2 puro.
# Con psycopg2 puro tendrías que manejar cursores, fetchall y
# convertir manualmente a DataFrame. SQLAlchemy hace eso en una línea
# y sigue siendo psycopg2 por debajo (lo usa como driver).
# =============================================================

import logging
import pandas as pd
from sqlalchemy import create_engine, text

from config import DB_URL, TABLES_TO_EXTRACT, DATA_RAW_DIR

logger = logging.getLogger(__name__)


def create_connection():
    """Crea y devuelve el engine de SQLAlchemy."""
    engine = create_engine(DB_URL)
    # Test de conexión: si falla aquí, el error es claro y temprano.
    with engine.connect() as conn:
        conn.execute(text("SELECT 1"))
    return engine


def extract_table(engine, table_name: str) -> pd.DataFrame:
    """Extrae una tabla completa de PostgreSQL como DataFrame."""
    df = pd.read_sql(f"SELECT * FROM {table_name}", engine)
    logger.info(f"     {table_name:<25} {len(df):>5} filas")
    return df


def extract_rfm_view(engine):
    """
    Intenta extraer la vista vw_rfm_clientes si existe.
    Si no existe, devuelve None sin romper el pipeline.
    DECISIÓN: try/except aquí porque la vista es opcional —
    el pipeline funciona sin ella.
    """
    try:
        df = pd.read_sql("SELECT * FROM vw_rfm_clientes", engine)
        logger.info(f"     vw_rfm_clientes          {len(df):>5} filas")
        return df
    except Exception:
        logger.warning("     vw_rfm_clientes no existe — se omite")
        return None


def run_extract() -> dict:
    """
    Función principal de la fase Extract.
    Devuelve un dict con {nombre_tabla: nº_filas} para el resumen final.
    """
    DATA_RAW_DIR.mkdir(parents=True, exist_ok=True)

    engine = create_connection()
    extracted = {}

    for table in TABLES_TO_EXTRACT:
        df = extract_table(engine, table)
        df.to_csv(DATA_RAW_DIR / f"{table}.csv", index=False)
        extracted[table] = len(df)

    rfm_df = extract_rfm_view(engine)
    if rfm_df is not None:
        rfm_df.to_csv(DATA_RAW_DIR / "vw_rfm_clientes.csv", index=False)
        extracted["vw_rfm_clientes"] = len(rfm_df)

    # Cerramos el pool de conexiones explícitamente.
    # Buena práctica: no dejar conexiones abiertas al terminar la fase.
    engine.dispose()

    return extracted
