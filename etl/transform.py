# =============================================================
# ViveRioja ETL — Fase 2: Transform
# =============================================================
# DECISIÓN: Transform lee los CSV de /data/raw, no la base de datos.
# Esto desacopla completamente el Transform del Extract. Podrías
# cambiar la fuente de datos (de PostgreSQL a Snowflake, por ejemplo)
# y el Transform no cambia nada siempre que el CSV tenga las mismas columnas.
#
# DECISIÓN: Los KPIs del "mes actual" usan datetime.now().
# Si el seed de datos no tiene reservas del mes en curso, los valores
# del mes serán 0 — es correcto y esperado. Los KPIs históricos
# (clientes activos, LTV) sí tendrán datos completos.
# =============================================================

import json
import logging
from datetime import datetime

import numpy as np
import pandas as pd

from config import DASHBOARD_DATA_DIR, DATA_PROCESSED_DIR, DATA_RAW_DIR

logger = logging.getLogger(__name__)


# ─── 1. CARGA ────────────────────────────────────────────────

def load_raw_data() -> dict:
    """Lee los CSV de /data/raw en un diccionario de DataFrames."""
    data = {}
    for name in ["clientes", "reservas", "pagos", "experiencias"]:
        path = DATA_RAW_DIR / f"{name}.csv"
        data[name] = pd.read_csv(path)
        logger.info(f"     Cargado {name}.csv — {len(data[name])} filas")
    return data


# ─── 2. LIMPIEZA ─────────────────────────────────────────────

def clean_data(data: dict) -> dict:
    """
    Normaliza tipos de datos y gestiona nulos.
    DECISIÓN: Los errores de conversión se convierten en NaN con
    errors='coerce' y luego se rellenan con 0 o '—'.
    Preferimos un 0 explícito a un NaN que rompa los cálculos posteriores.
    """
    # ── Reservas ──────────────────────────────────────────────
    r = data["reservas"].copy()
    r["fecha_experiencia"] = pd.to_datetime(r["fecha_experiencia"], errors="coerce", utc=True).dt.tz_localize(None)
    r["fecha_reserva"]     = pd.to_datetime(r["fecha_reserva"],     errors="coerce", utc=True).dt.tz_localize(None)
    r["precio_total"]      = pd.to_numeric(r["precio_total"],  errors="coerce").fillna(0)
    r["descuento_pct"]     = pd.to_numeric(r["descuento_pct"], errors="coerce").fillna(0)
    r["estado"]            = r["estado"].fillna("desconocido")
    data["reservas"] = r

    # ── Pagos ─────────────────────────────────────────────────
    p = data["pagos"].copy()
    p["importe"]    = pd.to_numeric(p["importe"], errors="coerce").fillna(0)
    p["fecha_pago"] = pd.to_datetime(p["fecha_pago"], errors="coerce", utc=True).dt.tz_localize(None)
    p["estado"]     = p["estado"].fillna("desconocido")
    data["pagos"] = p

    # ── Clientes ──────────────────────────────────────────────
    c = data["clientes"].copy()
    # Columna derivada: nombre completo para los reportes.
    c["nombre_completo"] = (
        c["nombre"].fillna("") + " " + c["apellidos"].fillna("")
    ).str.strip()
    c["ciudad"]      = c["ciudad"].fillna("—")
    c["nacionalidad"] = c["nacionalidad"].fillna("—")
    data["clientes"] = c

    return data


# ─── 3. CÁLCULO DE KPIs ──────────────────────────────────────

def calculate_kpis(data: dict) -> dict:
    """
    Calcula los KPIs del mes actual y los rankings históricos.
    Devuelve un dict con tres claves: kpis, top_experiencias, top_clientes.
    """
    now        = datetime.now()
    mes_actual = now.month
    anio_actual = now.year

    reservas    = data["reservas"]
    pagos       = data["pagos"]
    clientes    = data["clientes"]
    experiencias = data["experiencias"]

    # ── Filtros base ──────────────────────────────────────────
    reservas_completadas = reservas[reservas["estado"] == "completada"]
    pagos_completados    = pagos[pagos["estado"] == "completado"]

    # Reservas completadas del mes actual
    completadas_mes = reservas_completadas[
        (reservas_completadas["fecha_experiencia"].dt.month == mes_actual) &
        (reservas_completadas["fecha_experiencia"].dt.year  == anio_actual)
    ]

    # ── Pagos vinculados a reservas completadas ───────────────
    # JOIN pagos → reservas para heredar cliente_id y experiencia_id.
    # DECISIÓN: usamos merge (SQL JOIN en pandas) en lugar de isin()
    # porque necesitamos las columnas de ambas tablas.
    pagos_validos = pagos_completados.merge(
        reservas_completadas[["id", "cliente_id", "experiencia_id"]],
        left_on="reserva_id",
        right_on="id",
        how="inner",
        suffixes=("_pago", "_reserva")
    )

    # Pagos del mes actual
    pagos_mes = pagos_validos[
        (pd.to_datetime(pagos_validos["fecha_pago"]).dt.month == mes_actual) &
        (pd.to_datetime(pagos_validos["fecha_pago"]).dt.year  == anio_actual)
    ]

    # ── KPIs del mes ─────────────────────────────────────────
    ingresos_mes    = pagos_mes["importe"].sum()
    num_reservas_mes = len(completadas_mes)
    ticket_medio    = ingresos_mes / num_reservas_mes if num_reservas_mes > 0 else 0

    # Tasa de cancelación del mes
    # Denominador: solo reservas ya cerradas (excluimos pendiente/confirmada
    # porque aún pueden completarse y distorsionarían la tasa).
    cerradas_mes  = reservas[
        (reservas["fecha_experiencia"].dt.month == mes_actual) &
        (reservas["fecha_experiencia"].dt.year  == anio_actual) &
        (reservas["estado"].isin(["completada", "cancelada", "no_show"]))
    ]
    canceladas_mes = cerradas_mes[cerradas_mes["estado"] == "cancelada"]
    tasa_cancelacion = (
        len(canceladas_mes) / len(cerradas_mes) * 100
        if len(cerradas_mes) > 0 else 0
    )

    # Clientes activos históricos (al menos 1 reserva completada)
    clientes_activos = reservas_completadas["cliente_id"].nunique()

    # ── Top 3 experiencias por ingresos (histórico) ───────────
    pagos_con_exp = pagos_validos.merge(
        experiencias[["id", "nombre", "tier"]],
        left_on="experiencia_id",
        right_on="id",
        how="left"
    )
    top_experiencias = (
        pagos_con_exp
        .groupby(["nombre", "tier"])["importe"]
        .sum()
        .reset_index()
        .sort_values("importe", ascending=False)
        .head(3)
        .rename(columns={"nombre": "experiencia", "importe": "ingresos_total"})
    )
    top_experiencias["ingresos_total"] = top_experiencias["ingresos_total"].round(2)

    # ── Top 3 clientes por LTV (histórico) ───────────────────
    ltv = (
        pagos_validos
        .groupby("cliente_id")["importe"]
        .sum()
        .reset_index()
        .sort_values("importe", ascending=False)
        .head(3)
        .merge(
            clientes[["id", "nombre_completo", "ciudad"]],
            left_on="cliente_id",
            right_on="id",
            how="left"
        )
        .rename(columns={"importe": "ltv_total"})
    )
    ltv["ltv_total"] = ltv["ltv_total"].round(2)

    return {
        "kpis": {
            "mes":                  now.strftime("%B %Y"),
            "ingresos_mes":         round(float(ingresos_mes), 2),
            "num_reservas_mes":     int(num_reservas_mes),
            "ticket_medio":         round(float(ticket_medio), 2),
            "tasa_cancelacion_pct": round(float(tasa_cancelacion), 1),
            "clientes_activos":     int(clientes_activos),
        },
        "top_experiencias": top_experiencias,
        "top_clientes":     ltv[["nombre_completo", "ciudad", "ltv_total"]],
    }


# ─── 4. JSON DE ESTACIONALIDAD PARA EL DASHBOARD ─────────────

def generate_seasonality_json(data: dict) -> str:
    """
    Calcula métricas de estacionalidad y genera dos archivos en /dashboard/data/:
      - seasonality_data.json  → formato estándar para APIs o documentación
      - seasonality_data.js   → mismos datos envueltos en window.VIVERIOJA_DATA = {...}
                                 para que el dashboard funcione con protocolo file://
                                 sin necesidad de un servidor HTTP.

    DECISIÓN: ¿Por qué generar .js además de .json?
    Los navegadores bloquean fetch() sobre file:// por política CORS.
    El truco de asignar los datos a una variable global con <script src="...">
    es el patrón estándar en dashboards de análisis estáticos (D3.js, Observable).
    Así el dashboard funciona tanto abierto localmente como en GitHub Pages.
    """
    reservas = data["reservas"]
    pagos    = data["pagos"]

    # ── Filtros base ──────────────────────────────────────────
    reservas_ok = reservas[reservas["estado"] == "completada"]
    pagos_ok    = pagos[pagos["estado"] == "completado"]

    pagos_con_reserva = pagos_ok.merge(
        reservas_ok[["id", "cliente_id", "experiencia_id",
                     "fecha_experiencia", "descuento_pct"]],
        left_on="reserva_id", right_on="id",
        how="inner", suffixes=("_pago", "_res")
    )

    # ── Ingresos por mes (promedio histórico) ─────────────────
    pagos_con_reserva["mes"] = pd.to_datetime(
        pagos_con_reserva["fecha_experiencia"]
    ).dt.month
    pagos_con_reserva["anio"] = pd.to_datetime(
        pagos_con_reserva["fecha_experiencia"]
    ).dt.year

    nombres_meses = [
        "Enero","Febrero","Marzo","Abril","Mayo","Junio",
        "Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"
    ]
    nombres_cortos = ["Ene","Feb","Mar","Abr","May","Jun",
                      "Jul","Ago","Sep","Oct","Nov","Dic"]

    agg_mes = (
        pagos_con_reserva
        .groupby("mes")
        .agg(
            ingresos   =("importe", "sum"),
            reservas   =("reserva_id", "nunique"),
            ticket_med =("importe", "mean")
        )
        .reindex(range(1, 13), fill_value=0)
        .reset_index()
    )

    ingresos_por_mes = []
    for _, row in agg_mes.iterrows():
        m = int(row["mes"])
        ingresos_por_mes.append({
            "mes":             m,
            "nombre_mes":      nombres_cortos[m - 1],
            "nombre_completo": nombres_meses[m - 1],
            "ingresos":        round(float(row["ingresos"]),   2),
            "reservas":        int(row["reservas"]),
            "ticket_medio":    round(float(row["ticket_med"]), 2),
        })

    # ── Comparativa anual (por año y mes) ─────────────────────
    comparativa = {}
    for anio, grp in pagos_con_reserva.groupby("anio"):
        agg_a = (
            grp.groupby("mes")["importe"].sum()
            .reindex(range(1, 13), fill_value=0)
            .tolist()
        )
        comparativa[str(int(anio))] = [round(v, 2) for v in agg_a]

    totales_anuales = {
        str(int(a)): round(float(grp["importe"].sum()), 2)
        for a, grp in pagos_con_reserva.groupby("anio")
    }

    # ── Reservas por día de la semana ─────────────────────────
    reservas_ok_copy = reservas_ok.copy()
    reservas_ok_copy["dia_iso"] = pd.to_datetime(
        reservas_ok_copy["fecha_reserva"]
    ).dt.dayofweek + 1   # 1=Lun … 7=Dom

    nombres_dias = ["Lunes","Martes","Miércoles","Jueves","Viernes","Sábado","Domingo"]

    agg_dia = (
        reservas_ok_copy
        .groupby("dia_iso")
        .agg(num_reservas=("id", "count"), cancelaciones=("estado", lambda x: 0))
        .reindex(range(1, 8), fill_value=0)
        .reset_index()
    )

    reservas_por_dia = []
    for _, row in agg_dia.iterrows():
        d = int(row["dia_iso"])
        nr = int(row["num_reservas"])
        reservas_por_dia.append({
            "dia_num":              d,
            "dia":                  nombres_dias[d - 1],
            "num_reservas":         nr,
            "cancelaciones":        0,
            "tasa_cancelacion_pct": 0.0,
        })

    # ── Heatmap mes × día de semana ───────────────────────────
    reservas_ok_copy["mes"] = pd.to_datetime(
        reservas_ok_copy["fecha_experiencia"]
    ).dt.month

    heatmap = []
    for m in range(1, 13):
        fila = []
        for d in range(1, 8):
            cnt = int(len(
                reservas_ok_copy[
                    (reservas_ok_copy["mes"] == m) &
                    (reservas_ok_copy["dia_iso"] == d)
                ]
            ))
            fila.append(cnt)
        heatmap.append(fila)

    # ── KPIs de estacionalidad ────────────────────────────────
    ing_lista = [m["ingresos"] for m in ingresos_por_mes]
    media_men = sum(ing_lista) / 12 if any(ing_lista) else 0
    idx_pico  = ing_lista.index(max(ing_lista))
    idx_valle = ing_lista.index(min(v for v in ing_lista if v > 0)) if any(v > 0 for v in ing_lista) else 0

    trimestres = {
        "Q1 (Ene–Mar)": sum(ing_lista[0:3]),
        "Q2 (Abr–Jun)": sum(ing_lista[3:6]),
        "Q3 (Jul–Sep)": sum(ing_lista[6:9]),
        "Q4 (Oct–Dic)": sum(ing_lista[9:12]),
    }
    trimestre_top = max(trimestres, key=trimestres.get)

    agg_dia_all = (
        reservas_ok_copy.groupby("dia_iso")["id"].count()
        .reindex(range(1, 8), fill_value=0)
    )
    dia_top_idx = int(agg_dia_all.idxmax())
    dia_top     = nombres_dias[dia_top_idx - 1]

    pico_val  = max(ing_lista) if ing_lista else 0
    valle_val = min(v for v in ing_lista if v > 0) if any(v > 0 for v in ing_lista) else 0
    var_pct   = round((pico_val - valle_val) / valle_val * 100, 1) if valle_val > 0 else 0

    pct_sobre_media = [
        round((v - media_men) / media_men * 100, 1) if media_men > 0 else 0.0
        for v in ing_lista
    ]

    kpis = {
        "mes_pico":          nombres_meses[idx_pico],
        "mes_pico_num":      idx_pico + 1,
        "mes_valle":         nombres_meses[idx_valle],
        "mes_valle_num":     idx_valle + 1,
        "trimestre_top":     trimestre_top,
        "dia_top":           dia_top,
        "ingresos_pico":     round(pico_val,  2),
        "ingresos_valle":    round(valle_val, 2),
        "variacion_pct":     var_pct,
        "media_mensual":     round(media_men, 2),
        "ingresos_total":    round(sum(ing_lista), 2),
        "meses_sobre_media": sum(1 for v in ing_lista if v > media_men),
    }

    # ── Construir payload ─────────────────────────────────────
    payload = {
        "generado_en":            datetime.now().strftime("%Y-%m-%dT%H:%M:%S"),
        "fuente":                 "ViveRioja ETL Pipeline v1.0",
        "anios_disponibles":      [int(a) for a in sorted(comparativa.keys())],
        "kpis_estacionalidad":    kpis,
        "ingresos_por_mes":       ingresos_por_mes,
        "comparativa_anual":      comparativa,
        "totales_anuales":        totales_anuales,
        "reservas_por_dia_semana": reservas_por_dia,
        "heatmap_mes_dia":        heatmap,
        "pct_sobre_media":        pct_sobre_media,
    }

    _guardar_json_y_js(payload, "seasonality_data", "VIVERIOJA_DATA")
    return str(DASHBOARD_DATA_DIR / "seasonality_data.json")


# ─── 5. JSON DE COHORTES PARA EL DASHBOARD ───────────────────

def generate_cohort_json(data: dict) -> str:
    """
    Calcula la matriz de retención por cohorte y el LTV acumulado.
    Genera cohort_data.json y cohort_data.js en /dashboard/data/.

    Lógica:
      cohorte  = mes de la primera reserva completada del cliente
      periodo  = meses entre la cohorte y un mes de actividad posterior
      retención = % de clientes del grupo que estuvo activo en ese periodo
    """
    reservas = data["reservas"].copy()
    pagos    = data["pagos"].copy()

    reservas_ok = reservas[reservas["estado"] == "completada"].copy()
    pagos_ok    = pagos[pagos["estado"] == "completado"].copy()

    if reservas_ok.empty:
        logger.warning("     Sin reservas completadas — JSON de cohortes vacío")
        payload = {"generado_en": datetime.now().strftime("%Y-%m-%dT%H:%M:%S"),
                   "cohortes": [], "kpis": {}, "nuevos_vs_recurrentes": []}
        _guardar_json_y_js(payload, "cohort_data", "COHORT_DATA")
        return str(DASHBOARD_DATA_DIR / "cohort_data.json")

    # ── Fecha como período mensual ────────────────────────────
    reservas_ok["mes_exp"] = pd.to_datetime(
        reservas_ok["fecha_experiencia"]
    ).dt.to_period("M")

    # ── Primera reserva por cliente (cohorte) ─────────────────
    primera = (
        reservas_ok.groupby("cliente_id")["mes_exp"]
        .min()
        .reset_index()
        .rename(columns={"mes_exp": "cohorte_mes"})
    )

    # ── Actividad mensual única por cliente ───────────────────
    actividad = (
        reservas_ok[["cliente_id", "mes_exp"]]
        .drop_duplicates()
    )

    # ── Join: actividad con cohorte ───────────────────────────
    act_coh = actividad.merge(primera, on="cliente_id")
    act_coh["periodo"] = (
        (act_coh["mes_exp"].dt.year  - act_coh["cohorte_mes"].dt.year)  * 12 +
        (act_coh["mes_exp"].dt.month - act_coh["cohorte_mes"].dt.month)
    )
    act_coh = act_coh[act_coh["periodo"] >= 0]

    # ── Tamaño de cada cohorte ────────────────────────────────
    tamanos = primera.groupby("cohorte_mes").size().reset_index(name="n_clientes")

    # ── Clientes retenidos por (cohorte, periodo) ─────────────
    retenidos = (
        act_coh.groupby(["cohorte_mes", "periodo"])["cliente_id"]
        .nunique()
        .reset_index(name="clientes_retenidos")
        .merge(tamanos, on="cohorte_mes")
    )
    retenidos["tasa_pct"] = (
        retenidos["clientes_retenidos"] / retenidos["n_clientes"] * 100
    ).round(1)

    # ── Ingresos por (cohorte, periodo) ──────────────────────
    pagos_con_res = pagos_ok.merge(
        reservas_ok[["id", "cliente_id", "fecha_experiencia"]],
        left_on="reserva_id", right_on="id", how="inner"
    )
    pagos_con_res["mes_pago"] = pd.to_datetime(
        pagos_con_res["fecha_experiencia"]
    ).dt.to_period("M")
    pagos_con_res = pagos_con_res.merge(primera, on="cliente_id")
    pagos_con_res["periodo"] = (
        (pagos_con_res["mes_pago"].dt.year  - pagos_con_res["cohorte_mes"].dt.year)  * 12 +
        (pagos_con_res["mes_pago"].dt.month - pagos_con_res["cohorte_mes"].dt.month)
    )
    pagos_con_res = pagos_con_res[pagos_con_res["periodo"] >= 0]
    ingresos_grp = (
        pagos_con_res.groupby(["cohorte_mes", "periodo"])["importe"]
        .sum()
        .reset_index(name="ingresos_periodo")
    )

    # ── Construir lista de cohortes ───────────────────────────
    max_per  = 18
    nombres_meses = ["Enero","Febrero","Marzo","Abril","Mayo","Junio",
                     "Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"]
    cohortes_out = []

    for _, row_t in tamanos.sort_values("cohorte_mes").iterrows():
        coh_mes  = row_t["cohorte_mes"]
        n_cli    = int(row_t["n_clientes"])
        coh_id   = str(coh_mes)                         # "2023-09"
        coh_nom  = f"{nombres_meses[coh_mes.month-1]} {coh_mes.year}"

        ret_sub  = retenidos[retenidos["cohorte_mes"] == coh_mes].set_index("periodo")
        ing_sub  = ingresos_grp[ingresos_grp["cohorte_mes"] == coh_mes].set_index("periodo")
        max_obs  = int(ret_sub.index.max()) if not ret_sub.empty else 0

        retencion  = []
        ltv_acum   = []
        ltv_pcap   = []
        ltv_corriente = 0.0

        for p in range(max_per):
            if p > max_obs:
                retencion.append(None)
                ltv_acum.append(None)
                ltv_pcap.append(None)
            else:
                tasa = float(ret_sub.loc[p, "tasa_pct"]) if p in ret_sub.index else 0.0
                ing  = float(ing_sub.loc[p, "ingresos_periodo"]) if p in ing_sub.index else 0.0
                ltv_corriente += ing
                retencion.append(round(tasa, 1))
                ltv_acum.append(round(ltv_corriente, 2))
                ltv_pcap.append(round(ltv_corriente / n_cli, 2) if n_cli > 0 else 0.0)

        cohortes_out.append({
            "cohorte_id":     coh_id,
            "cohorte_nombre": coh_nom,
            "num_clientes":   n_cli,
            "retencion_pct":  retencion,
            "ltv_acumulado":  ltv_acum,
            "ltv_per_capita": ltv_pcap,
        })

    # ── KPIs globales ─────────────────────────────────────────
    m1_vals  = [c["retencion_pct"][1] for c in cohortes_out
                if len(c["retencion_pct"]) > 1 and c["retencion_pct"][1] is not None]
    m12_vals = [c["retencion_pct"][12] for c in cohortes_out
                if len(c["retencion_pct"]) > 12 and c["retencion_pct"][12] is not None]
    ltv_finals = [next((v for v in reversed(c["ltv_per_capita"]) if v is not None), 0.0)
                  for c in cohortes_out]
    mejor_ltv = max(cohortes_out, key=lambda c: (
        next((v for v in reversed(c["ltv_per_capita"]) if v is not None), 0.0)
    ))
    mejor_ret = max(cohortes_out, key=lambda c: (
        c["retencion_pct"][1] if len(c["retencion_pct"]) > 1 and c["retencion_pct"][1] else 0
    ))

    # Tiempo hasta segunda reserva
    # cumcount() es más robusto que nth() en pandas 3.x
    res_ranked = (
        reservas_ok[["cliente_id", "mes_exp"]]
        .drop_duplicates()
        .sort_values(["cliente_id", "mes_exp"])
        .copy()
    )
    res_ranked["rank_n"] = res_ranked.groupby("cliente_id").cumcount()
    segunda = (
        res_ranked[res_ranked["rank_n"] == 1][["cliente_id", "mes_exp"]]
        .rename(columns={"mes_exp": "segunda_mes"})
    )
    if not segunda.empty:
        intervalos = primera.merge(segunda, on="cliente_id")
        intervalos["meses"] = (
            (intervalos["segunda_mes"].dt.year  - intervalos["cohorte_mes"].dt.year) * 12 +
            (intervalos["segunda_mes"].dt.month - intervalos["cohorte_mes"].dt.month)
        )
        meses_retorno = round(float(intervalos["meses"].mean()), 1)
    else:
        meses_retorno = 0.0

    # Nuevos vs recurrentes
    act_coh2 = actividad.merge(primera, on="cliente_id")
    act_coh2["es_nuevo"] = act_coh2["mes_exp"] == act_coh2["cohorte_mes"]
    nr = (
        act_coh2.groupby("mes_exp")
        .agg(nuevos=("es_nuevo", "sum"), total=("cliente_id", "nunique"))
        .reset_index()
    )
    nr["recurrentes"]     = nr["total"] - nr["nuevos"]
    nr["pct_recurrentes"] = (nr["recurrentes"] / nr["total"] * 100).round(1)
    nr_out = [
        {
            "mes":             str(r["mes_exp"]),
            "nuevos":          int(r["nuevos"]),
            "recurrentes":     int(r["recurrentes"]),
            "pct_recurrentes": float(r["pct_recurrentes"]),
        }
        for _, r in nr.sort_values("mes_exp").iterrows()
    ]

    kpis = {
        "total_cohortes":           len(cohortes_out),
        "retencion_m1_promedio":    round(sum(m1_vals)  / len(m1_vals),  1) if m1_vals  else 0.0,
        "retencion_m12_promedio":   round(sum(m12_vals) / len(m12_vals), 1) if m12_vals else 0.0,
        "mejor_cohorte_retencion":  mejor_ret["cohorte_nombre"],
        "ltv_per_capita_promedio":  round(sum(ltv_finals) / len(ltv_finals), 2) if ltv_finals else 0.0,
        "mejor_cohorte_ltv":        mejor_ltv["cohorte_nombre"],
        "meses_medio_retorno":      meses_retorno,
        "pct_clientes_recurrentes": round(float(nr["recurrentes"].sum()) /
                                          float(nr["total"].sum()) * 100, 1) if not nr.empty else 0.0,
    }

    payload = {
        "generado_en":           datetime.now().strftime("%Y-%m-%dT%H:%M:%S"),
        "fuente":                "ViveRioja ETL Pipeline v1.0",
        "max_periodos":          max_per,
        "kpis":                  kpis,
        "cohortes":              cohortes_out,
        "nuevos_vs_recurrentes": nr_out,
    }

    _guardar_json_y_js(payload, "cohort_data", "COHORT_DATA")
    logger.info(f"     Cohortes calculadas: {len(cohortes_out)}")
    return str(DASHBOARD_DATA_DIR / "cohort_data.json")


def _guardar_json_y_js(payload: dict, nombre: str, var_js: str) -> None:
    """Helper: guarda el payload como .json y como .js con variable global."""
    DASHBOARD_DATA_DIR.mkdir(parents=True, exist_ok=True)
    json_str = json.dumps(payload, ensure_ascii=False, indent=2)

    with open(DASHBOARD_DATA_DIR / f"{nombre}.json", "w", encoding="utf-8") as f:
        f.write(json_str)

    js_content = (
        f"// Generado por ETL ViveRioja — etl/transform.py\n"
        f"// Actualizacion: {payload['generado_en']}\n"
        f"// NO editar manualmente — regenerar con: python pipeline.py\n\n"
        f"window.{var_js} = {json_str};\n"
    )
    with open(DASHBOARD_DATA_DIR / f"{nombre}.js", "w", encoding="utf-8") as f:
        f.write(js_content)

    logger.info(f"     JSON → {DASHBOARD_DATA_DIR / nombre}.json")
    logger.info(f"     JS   → {DASHBOARD_DATA_DIR / nombre}.js")


# ─── 6. GUARDAR ──────────────────────────────────────────────

def run_transform() -> dict:
    """Función principal de la fase Transform."""
    DATA_PROCESSED_DIR.mkdir(parents=True, exist_ok=True)

    data    = load_raw_data()
    data    = clean_data(data)
    results = calculate_kpis(data)

    # KPIs del mes → CSV plano (una fila)
    pd.DataFrame([results["kpis"]]).to_csv(
        DATA_PROCESSED_DIR / "kpis_mes.csv", index=False
    )

    # Clientes con columnas limpias → CSV para Power BI u otros consumidores
    clientes_proc = data["clientes"][[
        "id", "nombre_completo", "ciudad", "pais", "nacionalidad", "canal_adquisicion"
    ]]
    clientes_proc.to_csv(DATA_PROCESSED_DIR / "clientes_procesados.csv", index=False)

    kpis = results["kpis"]
    logger.info(f"     Periodo:              {kpis['mes'].title()}")
    logger.info(f"     Ingresos del mes:     €{kpis['ingresos_mes']:,.2f}")
    logger.info(f"     Reservas completadas: {kpis['num_reservas_mes']}")
    logger.info(f"     Ticket medio:         €{kpis['ticket_medio']:,.2f}")
    logger.info(f"     Tasa cancelación:     {kpis['tasa_cancelacion_pct']}%")
    logger.info(f"     Clientes activos:     {kpis['clientes_activos']}")

    # JSON para los dashboards interactivos
    results["dashboard_json"]        = generate_seasonality_json(data)
    results["dashboard_cohort_json"] = generate_cohort_json(data)

    return results
