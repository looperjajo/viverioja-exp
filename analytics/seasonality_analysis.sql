-- ================================================================
-- ViveRioja Experience — Análisis de Estacionalidad
-- ================================================================
-- Responde 8 preguntas de negocio sobre comportamiento estacional:
-- cuándo reservan los clientes, cuándo cancela más, qué tier rinde
-- mejor por temporada y dónde están las palancas de revenue.
--
-- CÓMO EJECUTAR:
--   psql -d viverioja -f analytics/seasonality_analysis.sql
-- ================================================================


-- ──────────────────────────────────────────────────────────────
-- QUERY 1 — TOP 3 Y BOTTOM 3 DE MESES POR INGRESOS
-- ──────────────────────────────────────────────────────────────
-- DECISIÓN DE NEGOCIO: Saber qué 3 meses generan el 60-70% de
-- los ingresos permite concentrar recursos (marketing, personal
-- extra, stock de actividades) exactamente cuando hay demanda.
-- Los 3 meses peores son la ventana ideal para mantenimiento,
-- formación de guías y negociación de contratos con bodegas sin
-- interferir en la operativa productiva.
-- ──────────────────────────────────────────────────────────────
WITH ingresos_por_mes AS (
    SELECT
        EXTRACT(MONTH FROM r.fecha_experiencia)::INT            AS mes,
        TO_CHAR(r.fecha_experiencia, 'TMMonth')                 AS nombre_mes,
        ROUND(SUM(p.importe)::NUMERIC, 2)                       AS ingresos_totales,
        COUNT(DISTINCT r.id)                                    AS num_reservas,
        ROUND(AVG(p.importe)::NUMERIC, 2)                       AS ticket_medio,
        RANK() OVER (ORDER BY SUM(p.importe) DESC)              AS rank_ingresos_desc,
        RANK() OVER (ORDER BY SUM(p.importe) ASC)               AS rank_ingresos_asc
    FROM reservas r
    JOIN pagos p ON p.reserva_id = r.id
    WHERE r.estado   = 'completada'
      AND p.estado   = 'completado'
      AND r.fecha_experiencia IS NOT NULL
    GROUP BY
        EXTRACT(MONTH FROM r.fecha_experiencia),
        TO_CHAR(r.fecha_experiencia, 'TMMonth')
)
SELECT
    mes,
    nombre_mes,
    ingresos_totales,
    num_reservas,
    ticket_medio,
    CASE
        WHEN rank_ingresos_desc <= 3 THEN '🔴 TOP 3 — Temporada Alta'
        WHEN rank_ingresos_asc  <= 3 THEN '🔵 BOTTOM 3 — Temporada Baja'
        ELSE '⬜ Temporada Media'
    END AS clasificacion
FROM ingresos_por_mes
ORDER BY ingresos_totales DESC;


-- ──────────────────────────────────────────────────────────────
-- QUERY 2 — TASA DE CANCELACIÓN POR TRIMESTRE
-- ──────────────────────────────────────────────────────────────
-- DECISIÓN DE NEGOCIO: Un trimestre con tasa de cancelación
-- elevada puede señalar: pricing inadecuado respecto a la
-- competencia, expectativas no gestionadas, eventos externos
-- (clima, fiestas), o reservas con demasiada antelación que el
-- cliente luego no honra. Con este dato se puede ajustar la
-- política de cancelación: más estricta en Q3 (verano, alta
-- demanda) y más flexible en Q1 (baja demanda, necesitas volumen).
-- ──────────────────────────────────────────────────────────────
SELECT
    EXTRACT(YEAR    FROM fecha_experiencia)::INT              AS anio,
    'Q' || EXTRACT(QUARTER FROM fecha_experiencia)::INT       AS trimestre,
    COUNT(*)                                                  AS total_reservas,
    COUNT(*) FILTER (WHERE estado = 'completada')             AS completadas,
    COUNT(*) FILTER (WHERE estado = 'cancelada')              AS canceladas,
    COUNT(*) FILTER (WHERE estado = 'no_show')                AS no_shows,
    COUNT(*) FILTER (WHERE estado IN ('pendiente','confirmada')) AS abiertas,
    ROUND(
        COUNT(*) FILTER (WHERE estado = 'cancelada')::NUMERIC
        / NULLIF(COUNT(*) FILTER (
            WHERE estado IN ('completada','cancelada','no_show')
          ), 0) * 100
    , 1)                                                      AS tasa_cancelacion_pct,
    ROUND(
        COUNT(*) FILTER (WHERE estado = 'completada')::NUMERIC
        / NULLIF(COUNT(*) FILTER (
            WHERE estado IN ('completada','cancelada','no_show')
          ), 0) * 100
    , 1)                                                      AS tasa_completacion_pct
FROM reservas
WHERE fecha_experiencia IS NOT NULL
GROUP BY anio, EXTRACT(QUARTER FROM fecha_experiencia)
ORDER BY anio, EXTRACT(QUARTER FROM fecha_experiencia);


-- ──────────────────────────────────────────────────────────────
-- QUERY 3 — RESERVAS Y CANCELACIONES POR DÍA DE LA SEMANA
-- ──────────────────────────────────────────────────────────────
-- DECISIÓN DE NEGOCIO: Si el sábado concentra el 30% de reservas
-- pero también el 25% de cancelaciones, hay un problema de
-- sobredemanda que se resuelve con lista de espera o precios
-- dinámicos. Si el lunes tiene tasa de cancelación alta con poco
-- volumen, puede ser que los clientes reserven el fin de semana
-- y cancelen el lunes al ver la previsión meteorológica.
-- Con este dato se optimiza el calendario de disponibilidad y
-- el staffing por día de la semana.
-- ──────────────────────────────────────────────────────────────
SELECT
    CASE EXTRACT(DOW FROM fecha_reserva)::INT
        WHEN 0 THEN 'Domingo'
        WHEN 1 THEN 'Lunes'
        WHEN 2 THEN 'Martes'
        WHEN 3 THEN 'Miércoles'
        WHEN 4 THEN 'Jueves'
        WHEN 5 THEN 'Viernes'
        WHEN 6 THEN 'Sábado'
    END                                                           AS dia_semana,
    EXTRACT(DOW FROM fecha_reserva)::INT                         AS dia_num,
    COUNT(*)                                                      AS total_reservas,
    COUNT(*) FILTER (WHERE estado = 'completada')                 AS completadas,
    COUNT(*) FILTER (WHERE estado = 'cancelada')                  AS cancelaciones,
    ROUND(
        COUNT(*) FILTER (WHERE estado = 'cancelada')::NUMERIC
        / NULLIF(COUNT(*), 0) * 100
    , 1)                                                          AS tasa_cancelacion_pct,
    ROUND(
        COUNT(*)::NUMERIC
        / SUM(COUNT(*)) OVER () * 100
    , 1)                                                          AS pct_del_total_reservas
FROM reservas
WHERE fecha_reserva IS NOT NULL
GROUP BY EXTRACT(DOW FROM fecha_reserva)
ORDER BY pct_del_total_reservas DESC;


-- ──────────────────────────────────────────────────────────────
-- QUERY 4 — COMPORTAMIENTO POR TIER Y MES
-- ──────────────────────────────────────────────────────────────
-- DECISIÓN DE NEGOCIO: Si el tier Premium tiene ingresos estables
-- todo el año (baja correlación con estacionalidad), se puede
-- vender como "exclusividad garantizada" en temporada baja con
-- un precio ligeramente superior. Si el Premium sube mucho en
-- temporada alta, hay una oportunidad de upselling sistemático
-- en los meses de mayor demanda cuando el cliente ya está en
-- modo "experiencia especial" y es más receptivo a pagar más.
-- ──────────────────────────────────────────────────────────────
SELECT
    EXTRACT(MONTH FROM r.fecha_experiencia)::INT                  AS mes,
    TO_CHAR(r.fecha_experiencia, 'TMMonth')                       AS nombre_mes,
    e.tier,
    COUNT(DISTINCT r.id)                                          AS num_reservas,
    ROUND(SUM(p.importe)::NUMERIC, 2)                             AS ingresos,
    ROUND(AVG(p.importe)::NUMERIC, 2)                             AS ticket_medio,
    -- Cuánto peso tiene este tier en el mes
    ROUND(
        SUM(p.importe)::NUMERIC
        / NULLIF(SUM(SUM(p.importe)) OVER (
            PARTITION BY EXTRACT(MONTH FROM r.fecha_experiencia)
          ), 0) * 100
    , 1)                                                          AS pct_del_mes
FROM reservas r
JOIN experiencias e ON e.id = r.experiencia_id
JOIN pagos p        ON p.reserva_id = r.id
WHERE r.estado = 'completada'
  AND p.estado = 'completado'
GROUP BY
    EXTRACT(MONTH FROM r.fecha_experiencia),
    TO_CHAR(r.fecha_experiencia, 'TMMonth'),
    e.tier
ORDER BY mes, e.tier;


-- ──────────────────────────────────────────────────────────────
-- QUERY 5 — BODEGAS CON MÁS RESERVAS EN TEMPORADA VENDIMIA
-- ──────────────────────────────────────────────────────────────
-- DECISIÓN DE NEGOCIO: Septiembre y octubre son el momento más
-- aspiracional del enoturismo riojano. Saber qué bodega partner
-- lidera en esos meses permite:
--   a) Negociar exclusividades o ampliaciones de aforo para el año siguiente
--   b) Crear paquetes premium "Vendimia Exclusiva" con las bodegas top
--   c) Identificar bodegas infrautilizadas que podrían captar demanda con
--      una oferta de vendimia atractiva
-- ──────────────────────────────────────────────────────────────
SELECT
    b.nombre                                                      AS bodega,
    b.denominacion_origen                                         AS do,
    COUNT(DISTINCT r.id)                                          AS reservas_vendimia,
    ROUND(SUM(p.importe)::NUMERIC, 2)                             AS ingresos_vendimia,
    ROUND(AVG(r.num_personas)::NUMERIC, 1)                        AS personas_por_reserva,
    COUNT(DISTINCT r.cliente_id)                                  AS clientes_unicos,
    -- Ingreso medio por cliente (LTV del periodo vendimia)
    ROUND(SUM(p.importe)::NUMERIC / NULLIF(COUNT(DISTINCT r.cliente_id), 0), 2)
                                                                  AS ingreso_por_cliente
FROM reservas r
JOIN experiencias e        ON e.id  = r.experiencia_id
JOIN experiencia_bodega eb ON eb.experiencia_id = e.id
JOIN bodegas b             ON b.id  = eb.bodega_id
JOIN pagos p               ON p.reserva_id = r.id
WHERE r.estado   = 'completada'
  AND p.estado   = 'completado'
  AND EXTRACT(MONTH FROM r.fecha_experiencia) IN (9, 10)
GROUP BY b.id, b.nombre, b.denominacion_origen
ORDER BY reservas_vendimia DESC, ingresos_vendimia DESC;


-- ──────────────────────────────────────────────────────────────
-- QUERY 6 — COMPARATIVA MES VS MEDIA ANUAL
-- ──────────────────────────────────────────────────────────────
-- DECISIÓN DE NEGOCIO: Cuantificar el % sobre/bajo la media es
-- la base del revenue management. En los meses -40% la pregunta
-- es: ¿puedo ofrecer descuentos estratégicos que recuperen
-- volumen sin destruir margen? ¿O mejor usar ese tiempo libre
-- para inversión interna (formación, nuevos productos)?
-- En los meses +80% la pregunta es: ¿estoy dejando dinero sobre
-- la mesa por falta de capacidad o personal?
-- ──────────────────────────────────────────────────────────────
WITH ingresos_mensuales AS (
    SELECT
        EXTRACT(MONTH FROM r.fecha_experiencia)::INT          AS mes,
        TO_CHAR(r.fecha_experiencia, 'TMMonth')               AS nombre_mes,
        SUM(p.importe)                                         AS ingresos_mes,
        COUNT(DISTINCT r.id)                                   AS reservas_mes
    FROM reservas r
    JOIN pagos p ON p.reserva_id = r.id
    WHERE r.estado = 'completada'
      AND p.estado = 'completado'
    GROUP BY mes, nombre_mes
),
media_global AS (
    SELECT AVG(ingresos_mes) AS media_mensual
    FROM ingresos_mensuales
)
SELECT
    i.mes,
    i.nombre_mes,
    ROUND(i.ingresos_mes::NUMERIC, 2)                            AS ingresos_mes,
    ROUND(m.media_mensual::NUMERIC, 2)                           AS media_mensual,
    ROUND((i.ingresos_mes - m.media_mensual)::NUMERIC, 2)        AS diferencia_euros,
    ROUND(
        (i.ingresos_mes - m.media_mensual) / m.media_mensual * 100
    , 1)                                                          AS pct_sobre_media,
    CASE
        WHEN i.ingresos_mes >= m.media_mensual * 1.5  THEN 'Muy por encima (+50%)'
        WHEN i.ingresos_mes >= m.media_mensual * 1.1  THEN 'Por encima (+10%)'
        WHEN i.ingresos_mes <= m.media_mensual * 0.5  THEN 'Muy por debajo (-50%)'
        WHEN i.ingresos_mes <= m.media_mensual * 0.9  THEN 'Por debajo (-10%)'
        ELSE 'En línea con la media'
    END                                                           AS clasificacion
FROM ingresos_mensuales i, media_global m
ORDER BY i.mes;


-- ──────────────────────────────────────────────────────────────
-- QUERY 7 — CLIENTES NUEVOS POR MES (primera reserva completada)
-- ──────────────────────────────────────────────────────────────
-- DECISIÓN DE NEGOCIO: La estacionalidad en captación dice cuándo
-- funcionan los canales de marketing. Si captas el 40% de tus
-- clientes nuevos en septiembre-octubre (vendimia), tu CAC en
-- esos meses es probablemente bajo (demanda orgánica alta).
-- En los meses de baja captación, el CAC de cualquier campaña
-- pagada será más alto — decisión de cuánto invertir y cuándo.
-- ──────────────────────────────────────────────────────────────
WITH primera_reserva_completada AS (
    SELECT
        cliente_id,
        MIN(fecha_experiencia) AS primera_fecha
    FROM reservas
    WHERE estado = 'completada'
    GROUP BY cliente_id
)
SELECT
    EXTRACT(MONTH FROM prc.primera_fecha)::INT                    AS mes,
    TO_CHAR(prc.primera_fecha, 'TMMonth')                         AS nombre_mes,
    COUNT(prc.cliente_id)                                          AS clientes_nuevos,
    ROUND(
        COUNT(prc.cliente_id)::NUMERIC
        / SUM(COUNT(prc.cliente_id)) OVER () * 100
    , 1)                                                          AS pct_del_total,
    ROUND(
        SUM(COUNT(prc.cliente_id)) OVER (
            ORDER BY EXTRACT(MONTH FROM prc.primera_fecha)
        )::NUMERIC / SUM(COUNT(prc.cliente_id)) OVER () * 100
    , 1)                                                          AS pct_acumulado,
    -- Canal de adquisición más frecuente en ese mes
    (
        SELECT c.canal_adquisicion
        FROM clientes c
        WHERE c.id IN (
            SELECT pr2.cliente_id
            FROM primera_reserva_completada pr2
            WHERE EXTRACT(MONTH FROM pr2.primera_fecha) =
                  EXTRACT(MONTH FROM prc.primera_fecha)
        )
        GROUP BY c.canal_adquisicion
        ORDER BY COUNT(*) DESC
        LIMIT 1
    )                                                             AS canal_adquisicion_top
FROM primera_reserva_completada prc
GROUP BY mes, nombre_mes
ORDER BY mes;


-- ──────────────────────────────────────────────────────────────
-- QUERY 8 — TICKET MEDIO POR MES (con distribución estadística)
-- ──────────────────────────────────────────────────────────────
-- DECISIÓN DE NEGOCIO: Si el ticket medio sube en temporada alta,
-- valida la estrategia de pricing dinámico (subir precio cuando
-- hay demanda). Si baja aunque el volumen sube, estás haciendo
-- demasiados descuentos precisamente cuando no los necesitas —
-- dejas margen sobre la mesa.
-- La diferencia entre ticket medio y mediano también es
-- informativa: si la media es mucho mayor que la mediana, hay
-- pocas reservas de ticket muy alto que distorsionan el promedio.
-- ──────────────────────────────────────────────────────────────
SELECT
    EXTRACT(MONTH FROM r.fecha_experiencia)::INT                  AS mes,
    TO_CHAR(r.fecha_experiencia, 'TMMonth')                       AS nombre_mes,
    COUNT(DISTINCT r.id)                                          AS num_reservas,
    ROUND(SUM(p.importe)::NUMERIC, 2)                             AS ingresos_totales,
    ROUND(AVG(p.importe)::NUMERIC, 2)                             AS ticket_medio,
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY p.importe)::NUMERIC
    , 2)                                                          AS ticket_mediano,
    ROUND(MAX(p.importe)::NUMERIC, 2)                             AS ticket_maximo,
    ROUND(MIN(p.importe)::NUMERIC, 2)                             AS ticket_minimo,
    ROUND(AVG(r.descuento_pct)::NUMERIC, 1)                       AS descuento_medio_pct,
    -- Índice de ticket respecto al año completo (100 = media)
    ROUND(
        AVG(p.importe) / AVG(AVG(p.importe)) OVER () * 100
    , 1)                                                          AS indice_ticket
FROM reservas r
JOIN pagos p ON p.reserva_id = r.id
WHERE r.estado = 'completada'
  AND p.estado = 'completado'
GROUP BY mes, nombre_mes
ORDER BY mes;
