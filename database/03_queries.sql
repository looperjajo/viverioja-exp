-- =============================================================
-- ViveRioja Experience S.L. — 10 Queries Analíticas Esenciales
-- =============================================================
-- Ejecutar DESPUÉS de 01_schema.sql y 02_seed.sql
-- Compatible con PostgreSQL 15+
-- =============================================================


-- =============================================================
-- QUERY 1: INGRESOS TOTALES POR MES (últimos 12 meses)
-- =============================================================
-- PROPÓSITO: KPI financiero principal — revenue mensual.
-- CONCEPTO: Solo contamos reservas 'completadas' y pagos 'completado'.
-- Un analista NUNCA suma precio_total de reservas directamente porque
-- pueden incluir canceladas. Usamos la tabla pagos como fuente de verdad.
-- DATE_TRUNC trunca a inicio de mes → agrupa por mes limpiamente.
-- LAG() es una ventana analítica: compara el mes actual con el anterior
-- para calcular el % de crecimiento MoM (Month-over-Month).
-- =============================================================
SELECT
    TO_CHAR(DATE_TRUNC('month', p.fecha_pago), 'YYYY-MM') AS mes,
    COUNT(DISTINCT r.id)                                   AS num_reservas,
    SUM(p.importe)                                         AS ingresos_brutos,
    ROUND(AVG(r.precio_total), 2)                          AS ticket_medio,
    -- Crecimiento MoM: ((actual - anterior) / anterior) * 100
    ROUND(
        (SUM(p.importe) - LAG(SUM(p.importe))
            OVER (ORDER BY DATE_TRUNC('month', p.fecha_pago)))
        / NULLIF(LAG(SUM(p.importe))
            OVER (ORDER BY DATE_TRUNC('month', p.fecha_pago)), 0)
        * 100, 1
    ) AS crecimiento_mom_pct
FROM pagos p
JOIN reservas r ON r.id = p.reserva_id
WHERE p.estado = 'completado'
  AND r.estado  = 'completada'
  AND p.fecha_pago >= NOW() - INTERVAL '12 months'
GROUP BY DATE_TRUNC('month', p.fecha_pago)
ORDER BY mes;


-- =============================================================
-- QUERY 2: EXPERIENCIAS MÁS VENDIDAS (por reservas y por revenue)
-- =============================================================
-- PROPÓSITO: Saber qué producto vende más en volumen Y en dinero.
-- A veces son distintos: la experiencia estándar tiene más reservas
-- pero el premium genera más revenue. Ambas métricas son útiles.
-- DENSE_RANK() es una ventana que asigna posición según valor
-- sin saltar números (si hay empate, siguiente = posición + 1).
-- =============================================================
SELECT
    e.nombre                                AS experiencia,
    e.tier,
    COUNT(r.id)                             AS total_reservas,
    DENSE_RANK() OVER (ORDER BY COUNT(r.id) DESC) AS ranking_volumen,
    SUM(r.precio_total)                     AS revenue_total,
    DENSE_RANK() OVER (ORDER BY SUM(r.precio_total) DESC) AS ranking_revenue,
    ROUND(AVG(r.num_personas), 1)           AS personas_media,
    ROUND(AVG(r.precio_total), 2)           AS ticket_medio
FROM experiencias e
JOIN reservas r ON r.experiencia_id = e.id
WHERE r.estado = 'completada'
GROUP BY e.id, e.nombre, e.tier
ORDER BY revenue_total DESC;


-- =============================================================
-- QUERY 3: CLIENTES CON MAYOR LIFETIME VALUE (LTV)
-- =============================================================
-- PROPÓSITO: Identificar los clientes más valiosos para programas
-- de fidelización, upgrades y atención prioritaria.
-- LTV aquí = suma de pagos completados histórica.
-- NOTA: días_como_cliente permite normalizar por antigüedad si
-- quisiéramos calcular LTV anualizado.
-- =============================================================
SELECT
    c.id,
    c.nombre || ' ' || c.apellidos          AS cliente,
    c.nacionalidad,
    c.canal_adquisicion,
    COUNT(DISTINCT r.id)                    AS total_reservas,
    SUM(r.precio_total)                     AS ltv_total,
    ROUND(AVG(r.precio_total), 2)           AS ticket_medio,
    MAX(r.fecha_experiencia)                AS ultima_experiencia,
    EXTRACT(DAY FROM NOW() - c.fecha_registro)::INT AS dias_como_cliente,
    -- LTV diario: útil para comparar clientes nuevos vs antiguos
    ROUND(SUM(r.precio_total)
        / NULLIF(EXTRACT(DAY FROM NOW() - c.fecha_registro), 0), 4
    ) AS ltv_por_dia
FROM clientes c
JOIN reservas r ON r.cliente_id = c.id
WHERE r.estado = 'completada'
GROUP BY c.id, c.nombre, c.apellidos, c.nacionalidad, c.canal_adquisicion, c.fecha_registro
ORDER BY ltv_total DESC
LIMIT 10;


-- =============================================================
-- QUERY 4: TASA DE CONVERSIÓN Y CANCELACIÓN POR TIER
-- =============================================================
-- PROPÓSITO: ¿Qué tier tiene más abandono? ¿Los clientes de
-- premium se comprometen más o menos que los de estándar?
-- Conversión = completadas / (completadas + canceladas + no_show)
-- NO incluimos pendientes/confirmadas porque aún pueden completarse.
-- =============================================================
SELECT
    e.tier,
    COUNT(r.id)                             AS total_reservas,
    COUNT(r.id) FILTER (WHERE r.estado = 'completada')  AS completadas,
    COUNT(r.id) FILTER (WHERE r.estado = 'cancelada')   AS canceladas,
    COUNT(r.id) FILTER (WHERE r.estado = 'no_show')     AS no_shows,
    COUNT(r.id) FILTER (WHERE r.estado IN ('pendiente','confirmada')) AS en_proceso,
    -- Tasa de conversión: completadas / total cerradas (excluye en proceso)
    ROUND(
        COUNT(r.id) FILTER (WHERE r.estado = 'completada') * 100.0
        / NULLIF(COUNT(r.id) FILTER (WHERE r.estado IN
            ('completada','cancelada','no_show')), 0),
        1
    ) AS tasa_conversion_pct,
    ROUND(AVG(r.precio_total) FILTER (WHERE r.estado = 'completada'), 2) AS ticket_medio
FROM experiencias e
JOIN reservas r ON r.experiencia_id = e.id
GROUP BY e.tier
ORDER BY
    CASE e.tier
        WHEN 'estandar'     THEN 1
        WHEN 'personalizada' THEN 2
        WHEN 'premium'      THEN 3
    END;


-- =============================================================
-- QUERY 5: REVENUE Y TICKET MEDIO POR CANAL DE RESERVA
-- =============================================================
-- PROPÓSITO: ¿Vale la pena mantener el canal telefónico?
-- ¿Las agencias traen tickets más altos que la web?
-- Esta query justifica (o cuestiona) inversiones en cada canal.
-- =============================================================
SELECT
    r.canal_reserva,
    COUNT(r.id)                         AS num_reservas,
    SUM(p.importe)                      AS revenue_total,
    ROUND(AVG(r.precio_total), 2)       AS ticket_medio,
    ROUND(AVG(r.num_personas), 1)       AS personas_media,
    -- % del revenue total
    ROUND(
        SUM(p.importe) * 100.0
        / SUM(SUM(p.importe)) OVER (),
        1
    ) AS pct_revenue_total
FROM reservas r
JOIN pagos p ON p.reserva_id = r.id
WHERE r.estado   = 'completada'
  AND p.estado   = 'completado'
GROUP BY r.canal_reserva
ORDER BY revenue_total DESC;


-- =============================================================
-- QUERY 6: PARTICIPACIÓN DE BODEGAS EN RESERVAS COMPLETADAS
-- =============================================================
-- PROPÓSITO: ¿Qué partners generan más actividad?
-- Útil para negociar comisiones, renovar contratos y planificar
-- capacidad conjunta con cada bodega.
-- =============================================================
SELECT
    b.nombre                            AS bodega,
    b.tipo,
    b.localidad,
    COUNT(DISTINCT r.id)                AS reservas_participadas,
    SUM(r.precio_total)                 AS revenue_generado,
    ROUND(AVG(r.precio_total), 2)       AS ticket_medio_reservas,
    COUNT(DISTINCT eb.experiencia_id)   AS num_experiencias,
    -- % del revenue total del sistema
    ROUND(
        SUM(r.precio_total) * 100.0
        / SUM(SUM(r.precio_total)) OVER (),
        1
    ) AS pct_revenue_total
FROM bodegas b
JOIN experiencia_bodega eb ON eb.bodega_id = b.id
JOIN reservas r ON r.experiencia_id = eb.experiencia_id
WHERE r.estado = 'completada'
GROUP BY b.id, b.nombre, b.tipo, b.localidad
ORDER BY revenue_generado DESC;


-- =============================================================
-- QUERY 7: ANÁLISIS DE ESTACIONALIDAD (reservas por mes del año)
-- =============================================================
-- PROPÓSITO: El enoturismo es estacional. ¿Cuándo hay picos?
-- Permite optimizar precios (revenue management), personal y stock.
-- EXTRACT(MONTH) agrupa todos los años juntos → patrón anual.
-- =============================================================
SELECT
    EXTRACT(MONTH FROM r.fecha_experiencia)::INT   AS mes_numero,
    TO_CHAR(
        DATE '2000-01-01' + (EXTRACT(MONTH FROM r.fecha_experiencia)::INT - 1) * INTERVAL '1 month',
        'TMMonth'
    )                                              AS mes_nombre,
    COUNT(r.id)                                    AS total_reservas,
    SUM(r.precio_total)                            AS revenue_total,
    ROUND(AVG(r.precio_total), 2)                  AS ticket_medio,
    ROUND(AVG(r.num_personas), 1)                  AS personas_media,
    -- Índice de estacionalidad: 100 = media mensual, >100 = temporada alta
    ROUND(
        COUNT(r.id) * 100.0 / AVG(COUNT(r.id)) OVER (),
        0
    ) AS indice_estacionalidad
FROM reservas r
WHERE r.estado = 'completada'
GROUP BY EXTRACT(MONTH FROM r.fecha_experiencia)
ORDER BY mes_numero;


-- =============================================================
-- QUERY 8: TASA DE RETENCIÓN — CLIENTES RECURRENTES
-- =============================================================
-- PROPÓSITO: ¿Cuántos clientes vuelven? La retención es más
-- barata que la adquisición. Un LTV alto con recurrencia alta
-- indica un producto fidelizador.
-- CTE (WITH) es una subconsulta nombrada — más legible que
-- un subquery anidado y permite reutilizar el resultado.
-- =============================================================
WITH historico_cliente AS (
    SELECT
        c.id,
        c.nombre || ' ' || c.apellidos     AS cliente,
        c.canal_adquisicion,
        COUNT(r.id)                        AS num_reservas,
        MIN(r.fecha_experiencia)           AS primera_experiencia,
        MAX(r.fecha_experiencia)           AS ultima_experiencia,
        SUM(r.precio_total)                AS ltv
    FROM clientes c
    JOIN reservas r ON r.cliente_id = c.id
    WHERE r.estado = 'completada'
    GROUP BY c.id, c.nombre, c.apellidos, c.canal_adquisicion
)
SELECT
    CASE
        WHEN num_reservas = 1 THEN '1 reserva (único)'
        WHEN num_reservas = 2 THEN '2 reservas'
        WHEN num_reservas BETWEEN 3 AND 4 THEN '3-4 reservas'
        ELSE '5+ reservas (fan)'
    END                                    AS segmento,
    COUNT(*)                               AS num_clientes,
    ROUND(AVG(ltv), 2)                     AS ltv_medio,
    -- % clientes en cada segmento
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct_clientes
FROM historico_cliente
GROUP BY segmento
ORDER BY num_clientes DESC;


-- =============================================================
-- QUERY 9: NPS PROXY — PUNTUACIÓN MEDIA POR EXPERIENCIA
-- =============================================================
-- PROPÓSITO: Detectar experiencias con problemas de calidad.
-- El NPS real requiere escala 0-10 y clasificación Promotores/
-- Detractores. Como tenemos escala 1-5, calculamos un proxy:
-- ≥4.5 = zona Promotora | 3.5-4.4 = zona Pasiva | <3.5 = zona Detractora
-- =============================================================
SELECT
    e.nombre                            AS experiencia,
    e.tier,
    COUNT(res.id)                       AS total_resenas,
    ROUND(AVG(res.puntuacion), 2)       AS puntuacion_media,
    COUNT(res.id) FILTER (WHERE res.puntuacion = 5) AS cincos,
    COUNT(res.id) FILTER (WHERE res.puntuacion = 4) AS cuatros,
    COUNT(res.id) FILTER (WHERE res.puntuacion <= 3) AS bajo_3,
    CASE
        WHEN AVG(res.puntuacion) >= 4.5 THEN 'Promotora'
        WHEN AVG(res.puntuacion) >= 3.5 THEN 'Pasiva'
        ELSE 'Detractora'
    END                                 AS zona_satisfaccion,
    COUNT(res.id) FILTER (WHERE res.respuesta_empresa IS NOT NULL) AS con_respuesta
FROM experiencias e
JOIN reservas r   ON r.experiencia_id = e.id
JOIN resenas  res ON res.reserva_id   = r.id
WHERE res.publicada = TRUE
GROUP BY e.id, e.nombre, e.tier
ORDER BY puntuacion_media DESC;


-- =============================================================
-- QUERY 10: REVENUE BREAKDOWN POR TIER CON % DEL TOTAL
-- =============================================================
-- PROPÓSITO: Vista ejecutiva — ¿qué segmento sostiene el negocio?
-- Incluye métricas de rentabilidad relativa y permite decisiones
-- sobre qué tier escalar o dónde invertir en marketing.
-- SUM(...) OVER () sin PARTITION ni ORDER → total global (todos los grupos).
-- =============================================================
SELECT
    e.tier,
    COUNT(DISTINCT r.id)                             AS total_reservas,
    COUNT(DISTINCT r.cliente_id)                     AS clientes_unicos,
    SUM(r.precio_total)                              AS revenue_total,
    ROUND(AVG(r.precio_total), 2)                    AS ticket_medio,
    ROUND(AVG(r.num_personas), 1)                    AS personas_media,
    -- % del revenue global
    ROUND(
        SUM(r.precio_total) * 100.0
        / SUM(SUM(r.precio_total)) OVER (),
        1
    )                                                AS pct_revenue,
    -- % de reservas (volumen)
    ROUND(
        COUNT(r.id) * 100.0
        / SUM(COUNT(r.id)) OVER (),
        1
    )                                                AS pct_reservas,
    -- Revenue por cliente único (proxy de valor del segmento)
    ROUND(SUM(r.precio_total) / COUNT(DISTINCT r.cliente_id), 2) AS revenue_por_cliente
FROM experiencias e
JOIN reservas r ON r.experiencia_id = e.id
WHERE r.estado = 'completada'
GROUP BY e.tier
ORDER BY
    CASE e.tier
        WHEN 'estandar'      THEN 1
        WHEN 'personalizada' THEN 2
        WHEN 'premium'       THEN 3
    END;


-- =============================================================
-- BONUS: QUERY 11 — MÉTODOS DE PAGO PREFERIDOS POR TIER
-- =============================================================
-- PROPÓSITO: ¿Los clientes premium pagan de forma distinta?
-- Útil para optimizar la pasarela de pago y reducir fricciones.
-- =============================================================
SELECT
    e.tier,
    p.metodo_pago,
    COUNT(p.id)                             AS num_pagos,
    SUM(p.importe)                          AS importe_total,
    ROUND(
        COUNT(p.id) * 100.0
        / SUM(COUNT(p.id)) OVER (PARTITION BY e.tier),
        1
    )                                       AS pct_dentro_tier
FROM pagos p
JOIN reservas r    ON r.id = p.reserva_id
JOIN experiencias e ON e.id = r.experiencia_id
WHERE p.estado = 'completado'
  AND r.estado = 'completada'
GROUP BY e.tier, p.metodo_pago
ORDER BY e.tier, num_pagos DESC;


-- =============================================================
-- BONUS: QUERY 12 — FUNNEL DE CONVERSIÓN COMPLETO
-- =============================================================
-- PROPÓSITO: Vista de todo el pipeline de ventas en una sola query.
-- Identifica en qué estado se pierden más reservas.
-- =============================================================
SELECT
    estado,
    COUNT(*)                                AS num_reservas,
    SUM(precio_total)                       AS valor_pipeline,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        1
    )                                       AS pct_total,
    ROUND(AVG(precio_total), 2)             AS ticket_medio
FROM reservas
GROUP BY estado
ORDER BY
    CASE estado
        WHEN 'pendiente'  THEN 1
        WHEN 'confirmada' THEN 2
        WHEN 'completada' THEN 3
        WHEN 'cancelada'  THEN 4
        WHEN 'no_show'    THEN 5
    END;
