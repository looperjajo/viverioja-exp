# =============================================================
# ViveRioja ETL — Fase 3: Load
# =============================================================
# DECISIÓN: "Load" no significa cargar a una base de datos —
# significa entregar el dato procesado al consumidor final.
# En este pipeline el consumidor es un humano (dirección),
# así que el output son un PDF y un Excel, no otra tabla SQL.
# En un pipeline empresarial real, el Load podría insertar en
# un Data Warehouse (BigQuery, Redshift) o actualizar un dashboard.
#
# DECISIÓN: reportlab para el PDF porque da control total sobre
# el layout: colores corporativos, tipografía, márgenes, tablas
# con estilos propios. Alternativas como fpdf2 son más simples
# pero menos flexibles para reportes con marca corporativa.
#
# DECISIÓN: openpyxl vía pandas.ExcelWriter para el Excel.
# Permite múltiples hojas con una sola instrucción y es el
# estándar de facto en Python para generar Excel sin Office.
# =============================================================

import logging
from datetime import datetime

import pandas as pd
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.platypus import (Paragraph, SimpleDocTemplate, Spacer, Table,
                                TableStyle)

from config import OUTPUT_DIR

logger = logging.getLogger(__name__)

# ─── Paleta corporativa ViveRioja ────────────────────────────
ROJO_VINO  = colors.HexColor("#9f4040")
DORADO     = colors.HexColor("#C8A96E")
CREMA      = colors.HexColor("#FAF8F5")
GRIS_TEXTO = colors.HexColor("#6B7280")
GRIS_BORDE = colors.HexColor("#E5E7EB")


# ─── Helpers de estilo ───────────────────────────────────────

def _tabla_style() -> TableStyle:
    """Estilo reutilizable para todas las tablas del PDF."""
    return TableStyle([
        # Cabecera
        ("BACKGROUND",   (0, 0), (-1, 0),  ROJO_VINO),
        ("TEXTCOLOR",    (0, 0), (-1, 0),  colors.white),
        ("FONTNAME",     (0, 0), (-1, 0),  "Helvetica-Bold"),
        ("FONTSIZE",     (0, 0), (-1, 0),  10),
        # Cuerpo
        ("FONTNAME",     (0, 1), (-1, -1), "Helvetica"),
        ("FONTSIZE",     (0, 1), (-1, -1), 9),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, CREMA]),
        # Bordes y padding
        ("GRID",         (0, 0), (-1, -1), 0.4, GRIS_BORDE),
        ("TOPPADDING",   (0, 0), (-1, -1), 7),
        ("BOTTOMPADDING",(0, 0), (-1, -1), 7),
        ("LEFTPADDING",  (0, 0), (-1, -1), 10),
        ("RIGHTPADDING", (0, 0), (-1, -1), 10),
    ])


# ─── Generador de PDF ────────────────────────────────────────

def build_pdf(results: dict) -> str:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    pdf_path = OUTPUT_DIR / "reporte_mensual_viverioja.pdf"

    doc = SimpleDocTemplate(
        str(pdf_path),
        pagesize=A4,
        rightMargin=2 * cm,
        leftMargin=2 * cm,
        topMargin=2.5 * cm,
        bottomMargin=2 * cm,
    )

    styles = getSampleStyleSheet()

    titulo   = ParagraphStyle("Titulo",   parent=styles["Title"],
                              textColor=ROJO_VINO,  fontSize=20,
                              spaceAfter=4,  alignment=TA_CENTER)
    subtitulo = ParagraphStyle("Sub",     parent=styles["Normal"],
                              textColor=GRIS_TEXTO, fontSize=11,
                              spaceAfter=20, alignment=TA_CENTER)
    seccion  = ParagraphStyle("Seccion", parent=styles["Heading2"],
                              textColor=ROJO_VINO,  fontSize=12,
                              spaceBefore=14, spaceAfter=6)
    pie      = ParagraphStyle("Pie",     parent=styles["Normal"],
                              textColor=GRIS_TEXTO, fontSize=7,
                              spaceBefore=30, alignment=TA_CENTER)

    kpis    = results["kpis"]
    top_exp = results["top_experiencias"]
    top_cli = results["top_clientes"]
    story   = []

    # ── Encabezado ──────────────────────────────────────────
    story.append(Paragraph("ViveRioja Experience S.L.", titulo))
    story.append(Paragraph(f"Reporte Mensual — {kpis['mes'].title()}", subtitulo))
    story.append(Spacer(1, 0.4 * cm))

    # ── Tabla de KPIs ───────────────────────────────────────
    story.append(Paragraph("KPIs del Mes", seccion))
    kpi_data = [
        ["Indicador", "Valor"],
        ["Ingresos totales del mes",    f"€{kpis['ingresos_mes']:,.2f}"],
        ["Reservas completadas",        str(kpis['num_reservas_mes'])],
        ["Ticket medio por reserva",    f"€{kpis['ticket_medio']:,.2f}"],
        ["Tasa de cancelación",         f"{kpis['tasa_cancelacion_pct']}%"],
        ["Clientes activos (histórico)",str(kpis['clientes_activos'])],
    ]
    kpi_table = Table(kpi_data, colWidths=[10 * cm, 6 * cm])
    kpi_table.setStyle(_tabla_style())
    # Columna de valores alineada a la derecha
    kpi_table.setStyle(TableStyle([("ALIGN", (1, 0), (1, -1), "RIGHT")]))
    story.append(kpi_table)

    # ── Top 3 Experiencias ──────────────────────────────────
    story.append(Paragraph("Top 3 Experiencias por Ingresos (histórico)", seccion))
    exp_data = [["Experiencia", "Tier", "Ingresos"]]
    for _, row in top_exp.iterrows():
        exp_data.append([
            str(row["experiencia"]),
            str(row["tier"]),
            f"€{row['ingresos_total']:,.2f}",
        ])
    exp_table = Table(exp_data, colWidths=[8 * cm, 4 * cm, 4 * cm])
    exp_table.setStyle(_tabla_style())
    exp_table.setStyle(TableStyle([("ALIGN", (2, 0), (2, -1), "RIGHT")]))
    story.append(exp_table)

    # ── Top 3 Clientes ──────────────────────────────────────
    story.append(Paragraph("Top 3 Clientes por LTV (histórico)", seccion))
    cli_data = [["Cliente", "Ciudad", "LTV Total"]]
    for _, row in top_cli.iterrows():
        cli_data.append([
            str(row["nombre_completo"]),
            str(row.get("ciudad") or "—"),
            f"€{row['ltv_total']:,.2f}",
        ])
    cli_table = Table(cli_data, colWidths=[8 * cm, 4 * cm, 4 * cm])
    cli_table.setStyle(_tabla_style())
    cli_table.setStyle(TableStyle([("ALIGN", (2, 0), (2, -1), "RIGHT")]))
    story.append(cli_table)

    # ── Pie de página ───────────────────────────────────────
    story.append(Paragraph(
        f"Generado automáticamente el {datetime.now().strftime('%d/%m/%Y a las %H:%M')} "
        f"· ViveRioja Experience S.L. · Pipeline ETL v1.0",
        pie,
    ))

    doc.build(story)
    logger.info(f"     PDF → {pdf_path}")
    return str(pdf_path)


# ─── Generador de Excel ──────────────────────────────────────

def build_excel(results: dict) -> str:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    excel_path = OUTPUT_DIR / "reporte_mensual_viverioja.xlsx"

    kpis = results["kpis"]

    # Una hoja por sección — el analista que lo reciba puede filtrar
    # cada hoja de forma independiente en Excel.
    with pd.ExcelWriter(str(excel_path), engine="openpyxl") as writer:
        pd.DataFrame([{
            "Indicador": "Ingresos totales del mes",
            "Valor": f"€{kpis['ingresos_mes']:,.2f}",
        }, {
            "Indicador": "Reservas completadas",
            "Valor": kpis['num_reservas_mes'],
        }, {
            "Indicador": "Ticket medio",
            "Valor": f"€{kpis['ticket_medio']:,.2f}",
        }, {
            "Indicador": "Tasa de cancelación",
            "Valor": f"{kpis['tasa_cancelacion_pct']}%",
        }, {
            "Indicador": "Clientes activos",
            "Valor": kpis['clientes_activos'],
        }]).to_excel(writer, sheet_name="KPIs Mes", index=False)

        results["top_experiencias"].to_excel(
            writer, sheet_name="Top Experiencias", index=False
        )
        results["top_clientes"].to_excel(
            writer, sheet_name="Top Clientes LTV", index=False
        )

    logger.info(f"     Excel → {excel_path}")
    return str(excel_path)


# ─── Función principal ───────────────────────────────────────

def run_load(results: dict) -> dict:
    pdf_path   = build_pdf(results)
    excel_path = build_excel(results)
    return {"pdf": pdf_path, "excel": excel_path}
