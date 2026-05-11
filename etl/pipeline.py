# =============================================================
# ViveRioja ETL — Orquestador principal
# =============================================================
# DECISIÓN: ¿Qué significa "orquestar" en Data Engineering?
#
# En un pipeline ETL tienes tres piezas que deben ejecutarse en
# orden y comunicarse entre ellas (Extract pasa datos a Transform,
# Transform pasa resultados a Load). El orquestador es el director:
# sabe en qué orden llamar a cada función, captura los errores de
# cada fase, registra qué pasó y presenta el resumen al final.
#
# En producción, este script sería invocado por un scheduler
# (Apache Airflow, Prefect, cron) de forma automática cada mes.
# Para portfolio, lo ejecutas tú manualmente con `python pipeline.py`.
#
# DECISIÓN: sys.exit(1) en cada except.
# Si una fase falla, no tiene sentido continuar con la siguiente
# (no puedes transformar datos que no extrajiste). El exit code 1
# le indica al sistema operativo (y a cualquier scheduler) que
# el proceso terminó en error.
# =============================================================

import logging
import sys
from datetime import datetime

from extract import run_extract
from load import run_load
from transform import run_transform

# ─── Configuración de logs ───────────────────────────────────
# Formato: hora · nivel · mensaje. Limpio y legible en consola.
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(message)s",
    datefmt="%H:%M:%S",
)
logger = logging.getLogger(__name__)

SEPARADOR = "─" * 55


def run_pipeline():
    start = datetime.now()

    logger.info(SEPARADOR)
    logger.info("  ViveRioja ETL Pipeline — Iniciando")
    logger.info(f"  {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}")
    logger.info(SEPARADOR)

    # ── FASE 1: EXTRACT ──────────────────────────────────────
    logger.info("[1/3] EXTRACT — Conectando a PostgreSQL...")
    try:
        extracted = run_extract()
        total_filas = sum(extracted.values())
        logger.info(f"  ✓ Extracción completada — {total_filas} filas en total")
    except Exception as e:
        logger.error(f"  ✗ EXTRACT falló: {e}")
        logger.error("  Pipeline detenido. Comprueba la conexión a PostgreSQL.")
        sys.exit(1)

    # ── FASE 2: TRANSFORM ────────────────────────────────────
    logger.info(SEPARADOR)
    logger.info("[2/3] TRANSFORM — Calculando KPIs...")
    try:
        results = run_transform()
        logger.info(f"  ✓ Transform completado")
    except Exception as e:
        logger.error(f"  ✗ TRANSFORM falló: {e}")
        logger.error("  Los CSV de /data/raw están intactos. Puedes reintentar desde aquí.")
        sys.exit(1)

    # ── FASE 3: LOAD ─────────────────────────────────────────
    logger.info(SEPARADOR)
    logger.info("[3/3] LOAD — Generando reportes...")
    try:
        output_paths = run_load(results)
        logger.info(f"  ✓ Reportes generados correctamente")
    except Exception as e:
        logger.error(f"  ✗ LOAD falló: {e}")
        logger.error("  Los datos procesados están en /data/processed. Puedes reintentar solo el Load.")
        sys.exit(1)

    # ── FASE 4: DASHBOARDS JSON ──────────────────────────────
    logger.info(SEPARADOR)
    logger.info("[4/4] DASHBOARD — Actualizando datos de los dashboards web...")
    logger.info(f"  ✓ Estacionalidad → {results.get('dashboard_json', 'no generado')}")
    logger.info(f"  ✓ Cohortes       → {results.get('dashboard_cohort_json', 'no generado')}")

    # ── RESUMEN FINAL ────────────────────────────────────────
    elapsed = round((datetime.now() - start).total_seconds(), 1)
    kpis    = results["kpis"]

    logger.info(SEPARADOR)
    logger.info("  RESUMEN FINAL")
    logger.info(SEPARADOR)
    logger.info(f"  Periodo analizado:      {kpis['mes'].title()}")
    logger.info(f"  Registros procesados:   {total_filas}")
    logger.info(f"  ─────────────────────────────────────────")
    logger.info(f"  Ingresos del mes:       €{kpis['ingresos_mes']:>10,.2f}")
    logger.info(f"  Reservas completadas:   {kpis['num_reservas_mes']:>10}")
    logger.info(f"  Ticket medio:           €{kpis['ticket_medio']:>10,.2f}")
    logger.info(f"  Tasa cancelación:       {kpis['tasa_cancelacion_pct']:>9}%")
    logger.info(f"  Clientes activos:       {kpis['clientes_activos']:>10}")
    logger.info(f"  ─────────────────────────────────────────")
    logger.info(f"  PDF:      {output_paths['pdf']}")
    logger.info(f"  Excel:    {output_paths['excel']}")
    logger.info(f"  JSON estacionalidad: {results.get('dashboard_json', 'n/a')}")
    logger.info(f"  JSON cohortes:       {results.get('dashboard_cohort_json', 'n/a')}")
    logger.info(f"  Tiempo total:           {elapsed}s")
    logger.info(SEPARADOR)


if __name__ == "__main__":
    run_pipeline()
