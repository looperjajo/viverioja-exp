-- ================================================================
-- ViveRioja Experience — Análisis de Cohortes
-- ================================================================
-- Un análisis de cohortes agrupa clientes por el mes en que
-- hicieron su PRIMERA reserva y luego rastrea qué porcentaje
-- de ese grupo vuelve a reservar en los meses siguientes.
--
-- Responde preguntas que los KPIs agregados no pueden:
--   ¿Los clientes captados en vendimia vuelven al año siguiente?
--   ¿Qué cohorte tiene mayor valor de vida (LTV)?
--   ¿Cuánto tiempo tarda un cliente nuevo en convertirse en recurrente?
--
-- CÓMO EJECUTAR:
--   psql -d viverioja -f analytics/cohort_analysis.sql
-- ================================================================


-- ──────────────────────────────────────────────────────────────
-- BLOQUE BASE: CTEs reutilizadas en todas las queries
-- ──────────────────────────────────────────────────────────────

-- primera_reserva: mes de primera reserva completada = cohorte
-- DECISIÓN: usamos fecha_experiencia, no fecha_reserva.
-- La cohorte debe reflejar cuándo el cliente VIVIÓ la experiencia,
-- no cuándo hizo click. Así la cohorte tiene sentido estacional.
WITH primera_reserva AS (
    SELECT
        cliente_id,
        DATE_TRUNC('month', MIN(fecha_experiencia))::DATE  AS cohorte_mes,
        TO_CHAR(MIN(fecha_experiencia), 'YYYY-MM')         AS cohorte_id,
        TO_CHAR(MIN(fecha_experiencia), 'TMMonth YYYY')    AS cohorte_nombre
    FROM reservas
    WHERE estado = 'completada'
    GROUP BY cliente_id
),

-- tamanos_cohorte: cuántos clientes entran en cada cohorte
tamanos_cohorte AS (
    SELECT
        cohorte_mes,
        cohorte_id,
        cohorte_nombre,
        COUNT(*) AS n_clientes
    FROM primera_reserva
    GROUP BY cohorte_mes, cohorte_id, cohorte_nombre
),

-- actividad_mensual: todos los meses en que cada cliente tuvo
-- al menos una reserva completada (DISTINCT: no contar 2 reservas
-- del mismo mes como dos eventos de retención)
actividad_mensual AS (
    SELECT DISTINCT
        cliente_id,
        DATE_TRUNC('month', fecha_experiencia)::DATE AS mes_actividad
    FROM reservas
    WHERE estado = 'completada'
),

-- cohort_actividad: para cada cohorte, cuántos clientes estuvieron
-- activos en cada periodo N (meses desde la adquisición)
cohort_actividad AS (
    SELECT
        pr.cohorte_mes,
        pr.cohorte_id,
        -- Diferencia exacta en meses entre el mes de actividad y el de adquisición
        (EXTRACT(YEAR  FROM am.mes_actividad) - EXTRACT(YEAR  FROM pr.cohorte_mes))::INT * 12 +
        (EXTRACT(MONTH FROM am.mes_actividad) - EXTRACT(MONTH FROM pr.cohorte_mes))::INT
                                                                   AS periodo,
        COUNT(DISTINCT am.cliente_id)                              AS clientes_retenidos
    FROM primera_reserva pr
    JOIN actividad_mensual am
      ON am.cliente_id   = pr.cliente_id
     AND am.mes_actividad >= pr.cohorte_mes   -- solo periodos posteriores o iguales
    GROUP BY pr.cohorte_mes, pr.cohorte_id, periodo
),

-- ingresos_por_periodo: ingresos reales (pagos completados)
-- asociados a cada cohorte en cada periodo
ingresos_por_periodo AS (
    SELECT
        pr.cohorte_mes,
        (EXTRACT(YEAR  FROM DATE_TRUNC('month', r.fecha_experiencia)) -
         EXTRACT(YEAR  FROM pr.cohorte_mes))::INT * 12 +
        (EXTRACT(MONTH FROM DATE_TRUNC('month', r.fecha_experiencia)) -
         EXTRACT(MONTH FROM pr.cohorte_mes))::INT                  AS periodo,
        ROUND(SUM(p.importe)::NUMERIC, 2)                          AS ingresos_periodo
    FROM primera_reserva pr
    JOIN reservas r
      ON r.cliente_id         = pr.cliente_id
     AND DATE_TRUNC('month', r.fecha_experiencia) >= pr.cohorte_mes
     AND r.estado             = 'completada'
    JOIN pagos p
      ON p.reserva_id = r.id
     AND p.estado     = 'completado'
    GROUP BY pr.cohorte_mes, periodo
)


-- ──────────────────────────────────────────────────────────────
-- QUERY 1 — MATRIZ DE RETENCIÓN POR COHORTE (formato largo)
-- ──────────────────────────────────────────────────────────────
-- DECISIÓN DE NEGOCIO: Identifica qué cohortes retienen mejor.
-- Si los clientes captados en septiembre tienen una tasa de
-- retención al mes 12 del 40% frente al 10% de los captados en
-- enero, el esfuerzo de marketing en vendimia tiene el triple de
-- valor a largo plazo. Eso justifica invertir más en captación
-- justo antes de septiembre aunque el CAC sea más alto.
-- ──────────────────────────────────────────────────────────────
SELECT
    ca.cohorte_id,
    tc.cohorte_nombre,
    tc.n_clientes,
    ca.periodo                                                  AS mes_numero,
    ca.clientes_retenidos,
    ROUND(
        ca.clientes_retenidos::NUMERIC / NULLIF(tc.n_clientes, 0) * 100
    , 1)                                                        AS tasa_retencion_pct
FROM cohort_actividad ca
JOIN tamanos_cohorte tc
  ON tc.cohorte_mes = ca.cohorte_mes
ORDER BY ca.cohorte_mes, ca.periodo;


-- ──────────────────────────────────────────────────────────────
-- QUERY 2 — LTV ACUMULADO POR COHORTE Y PERIODO
-- ──────────────────────────────────────────────────────────────
-- DECISIÓN DE NEGOCIO: El LTV acumulado a 12 meses por cohorte
-- permite calcular cuánto vale realmente cada cliente captado en
-- cada temporada. Si el LTV a 12 meses de un cliente captado en
-- vendimia es 2.5x el de un cliente de enero, el presupuesto de
-- marketing debería reflejarlo. Permite también calcular el
-- payback period: cuántos meses tarda en recuperarse el CAC.
-- ──────────────────────────────────────────────────────────────
SELECT
    ip.cohorte_mes,
    TO_CHAR(ip.cohorte_mes, 'YYYY-MM')                         AS cohorte_id,
    TO_CHAR(ip.cohorte_mes, 'TMMonth YYYY')                    AS cohorte_nombre,
    tc.n_clientes,
    ip.periodo                                                  AS mes_numero,
    ip.ingresos_periodo,
    ROUND(
        SUM(ip.ingresos_periodo) OVER (
            PARTITION BY ip.cohorte_mes
            ORDER BY ip.periodo
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )::NUMERIC
    , 2)                                                        AS ltv_acumulado_cohorte,
    -- LTV per cápita: más útil para comparar cohortes de distinto tamaño
    ROUND(
        SUM(ip.ingresos_periodo) OVER (
            PARTITION BY ip.cohorte_mes
            ORDER BY ip.periodo
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )::NUMERIC / NULLIF(tc.n_clientes, 0)
    , 2)                                                        AS ltv_per_capita
FROM ingresos_por_periodo ip
JOIN tamanos_cohorte tc
  ON tc.cohorte_mes = ip.cohorte_mes
ORDER BY ip.cohorte_mes, ip.periodo;


-- ──────────────────────────────────────────────────────────────
-- QUERY 3 — RESUMEN: RETENCIÓN M1 Y M12 POR COHORTE
-- ──────────────────────────────────────────────────────────────
-- DECISIÓN DE NEGOCIO: El mes 1 mide la "pegajosidad" inmediata
-- (¿cuántos volvieron al mes siguiente?). El mes 12 mide la
-- lealtad anual (¿cuántos repiten al cabo de un año?). Son los
-- dos KPIs de retención más accionables para dirección: no
-- necesitas la matriz completa para tomar decisiones, solo
-- estos dos puntos de referencia por cohorte.
-- ──────────────────────────────────────────────────────────────
SELECT
    tc.cohorte_id,
    tc.cohorte_nombre,
    tc.n_clientes,
    -- Retención en mes 1
    ROUND(
        MAX(ca.clientes_retenidos) FILTER (WHERE ca.periodo = 1)::NUMERIC
        / NULLIF(tc.n_clientes, 0) * 100
    , 1)                                                        AS retencion_m1_pct,
    -- Retención en mes 6
    ROUND(
        MAX(ca.clientes_retenidos) FILTER (WHERE ca.periodo = 6)::NUMERIC
        / NULLIF(tc.n_clientes, 0) * 100
    , 1)                                                        AS retencion_m6_pct,
    -- Retención en mes 12
    ROUND(
        MAX(ca.clientes_retenidos) FILTER (WHERE ca.periodo = 12)::NUMERIC
        / NULLIF(tc.n_clientes, 0) * 100
    , 1)                                                        AS retencion_m12_pct
FROM tamanos_cohorte tc
LEFT JOIN cohort_actividad ca
       ON ca.cohorte_mes = tc.cohorte_mes
      AND ca.periodo IN (1, 6, 12)
GROUP BY tc.cohorte_id, tc.cohorte_nombre, tc.n_clientes, tc.cohorte_mes
ORDER BY tc.cohorte_mes;


-- ──────────────────────────────────────────────────────────────
-- QUERY 4 — TIEMPO MEDIO HASTA LA SEGUNDA RESERVA
-- ──────────────────────────────────────────────────────────────
-- DECISIÓN DE NEGOCIO: Saber que de media un cliente tarda
-- 4.2 meses en volver permite diseñar el timing exacto de una
-- campaña de re-engagement: si envías el email a los 5 meses
-- (cuando la "ventana de retorno" está cerrándose), el impacto
-- es mayor que enviarlo al mes siguiente.
-- ──────────────────────────────────────────────────────────────
WITH primera_y_segunda AS (
    SELECT
        cliente_id,
        fecha_experiencia,
        ROW_NUMBER() OVER (
            PARTITION BY cliente_id
            ORDER BY fecha_experiencia
        ) AS num_reserva
    FROM reservas
    WHERE estado = 'completada'
),
intervalo AS (
    SELECT
        p1.cliente_id,
        ROUND(
            EXTRACT(EPOCH FROM (p2.fecha_experiencia - p1.fecha_experiencia))
            / (30.44 * 24 * 3600)
        , 1) AS meses_entre_1a_y_2a
    FROM primera_y_segunda p1
    JOIN primera_y_segunda p2
      ON p2.cliente_id  = p1.cliente_id
     AND p2.num_reserva = 2
    WHERE p1.num_reserva = 1
)
SELECT
    COUNT(*)                            AS clientes_con_segunda_reserva,
    ROUND(AVG(meses_entre_1a_y_2a), 1) AS meses_medio_retorno,
    ROUND(MIN(meses_entre_1a_y_2a), 1) AS retorno_mas_rapido,
    ROUND(MAX(meses_entre_1a_y_2a), 1) AS retorno_mas_lento,
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY meses_entre_1a_y_2a)::NUMERIC
    , 1)                                AS mediana_meses_retorno
FROM intervalo;


-- ──────────────────────────────────────────────────────────────
-- QUERY 5 — CLIENTES NUEVOS VS RECURRENTES POR MES
-- ──────────────────────────────────────────────────────────────
-- DECISIÓN DE NEGOCIO: Si en septiembre el 70% de las reservas
-- son de clientes recurrentes, la vendimia fideliza tanto como
-- adquiere. Si el 90% son nuevos, tienes un problema de retención:
-- captas mucho pero no fidelizas. Esta query da el split mensual.
-- ──────────────────────────────────────────────────────────────
WITH primera_reserva_fecha AS (
    SELECT
        cliente_id,
        MIN(fecha_experiencia) AS primera_fecha
    FROM reservas
    WHERE estado = 'completada'
    GROUP BY cliente_id
)
SELECT
    DATE_TRUNC('month', r.fecha_experiencia)::DATE   AS mes,
    TO_CHAR(r.fecha_experiencia, 'YYYY-MM')          AS mes_id,
    COUNT(DISTINCT r.cliente_id)                      AS total_clientes,
    COUNT(DISTINCT r.cliente_id) FILTER (
        WHERE DATE_TRUNC('month', r.fecha_experiencia) =
              DATE_TRUNC('month', prf.primera_fecha)
    )                                                 AS clientes_nuevos,
    COUNT(DISTINCT r.cliente_id) FILTER (
        WHERE DATE_TRUNC('month', r.fecha_experiencia) >
              DATE_TRUNC('month', prf.primera_fecha)
    )                                                 AS clientes_recurrentes,
    ROUND(
        COUNT(DISTINCT r.cliente_id) FILTER (
            WHERE DATE_TRUNC('month', r.fecha_experiencia) >
                  DATE_TRUNC('month', prf.primera_fecha)
        )::NUMERIC
        / NULLIF(COUNT(DISTINCT r.cliente_id), 0) * 100
    , 1)                                              AS pct_recurrentes
FROM reservas r
JOIN primera_reserva_fecha prf ON prf.cliente_id = r.cliente_id
WHERE r.estado = 'completada'
GROUP BY mes, mes_id
ORDER BY mes;


-- ──────────────────────────────────────────────────────────────
-- VISTA: vw_cohort_retention
-- ──────────────────────────────────────────────────────────────
-- Vista persistente que combina retención y LTV por cohorte.
-- Úsala en Power BI o como fuente del ETL Python sin repetir
-- la lógica de CTEs en cada consulta.
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_cohort_retention AS
WITH primera_reserva AS (
    SELECT
        cliente_id,
        DATE_TRUNC('month', MIN(fecha_experiencia))::DATE AS cohorte_mes,
        TO_CHAR(MIN(fecha_experiencia), 'YYYY-MM')        AS cohorte_id,
        TO_CHAR(MIN(fecha_experiencia), 'TMMonth YYYY')   AS cohorte_nombre
    FROM reservas
    WHERE estado = 'completada'
    GROUP BY cliente_id
),
tamanos_cohorte AS (
    SELECT cohorte_mes, cohorte_id, cohorte_nombre, COUNT(*) AS n_clientes
    FROM primera_reserva
    GROUP BY cohorte_mes, cohorte_id, cohorte_nombre
),
actividad_mensual AS (
    SELECT DISTINCT
        cliente_id,
        DATE_TRUNC('month', fecha_experiencia)::DATE AS mes_actividad
    FROM reservas
    WHERE estado = 'completada'
),
cohort_actividad AS (
    SELECT
        pr.cohorte_mes,
        (EXTRACT(YEAR  FROM am.mes_actividad) - EXTRACT(YEAR  FROM pr.cohorte_mes))::INT * 12 +
        (EXTRACT(MONTH FROM am.mes_actividad) - EXTRACT(MONTH FROM pr.cohorte_mes))::INT AS periodo,
        COUNT(DISTINCT am.cliente_id) AS clientes_retenidos
    FROM primera_reserva pr
    JOIN actividad_mensual am
      ON am.cliente_id    = pr.cliente_id
     AND am.mes_actividad >= pr.cohorte_mes
    GROUP BY pr.cohorte_mes, periodo
),
ingresos_por_periodo AS (
    SELECT
        pr.cohorte_mes,
        (EXTRACT(YEAR  FROM DATE_TRUNC('month', r.fecha_experiencia)) -
         EXTRACT(YEAR  FROM pr.cohorte_mes))::INT * 12 +
        (EXTRACT(MONTH FROM DATE_TRUNC('month', r.fecha_experiencia)) -
         EXTRACT(MONTH FROM pr.cohorte_mes))::INT AS periodo,
        SUM(p.importe) AS ingresos_periodo
    FROM primera_reserva pr
    JOIN reservas r
      ON r.cliente_id = pr.cliente_id
     AND DATE_TRUNC('month', r.fecha_experiencia) >= pr.cohorte_mes
     AND r.estado     = 'completada'
    JOIN pagos p
      ON p.reserva_id = r.id
     AND p.estado     = 'completado'
    GROUP BY pr.cohorte_mes, periodo
)
SELECT
    tc.cohorte_id,
    tc.cohorte_nombre,
    tc.n_clientes,
    ca.periodo                                                                        AS mes_numero,
    ca.clientes_retenidos,
    ROUND(ca.clientes_retenidos::NUMERIC / NULLIF(tc.n_clientes, 0) * 100, 1)        AS tasa_retencion_pct,
    COALESCE(ROUND(ip.ingresos_periodo::NUMERIC, 2), 0)                              AS ingresos_periodo,
    ROUND(
        SUM(COALESCE(ip.ingresos_periodo, 0)) OVER (
            PARTITION BY tc.cohorte_mes ORDER BY ca.periodo
        )::NUMERIC, 2
    )                                                                                 AS ltv_acumulado,
    ROUND(
        SUM(COALESCE(ip.ingresos_periodo, 0)) OVER (
            PARTITION BY tc.cohorte_mes ORDER BY ca.periodo
        )::NUMERIC / NULLIF(tc.n_clientes, 0), 2
    )                                                                                 AS ltv_per_capita
FROM cohort_actividad ca
JOIN tamanos_cohorte tc  ON tc.cohorte_mes = ca.cohorte_mes
LEFT JOIN ingresos_por_periodo ip
       ON ip.cohorte_mes = ca.cohorte_mes
      AND ip.periodo     = ca.periodo
ORDER BY tc.cohorte_mes, ca.periodo;
