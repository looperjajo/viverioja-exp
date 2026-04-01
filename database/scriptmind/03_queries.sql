-- =============================================================
-- ScriptMind — Queries de Métricas SaaS
-- Las 6 métricas que mira un inversor en Series A
-- =============================================================
-- CONTEXTO FINANCIERO:
-- Un inversor en SaaS mira MRR, Churn y LTV antes que cualquier
-- otra métrica. La razón es simple: predicen el futuro del negocio.
-- Si MRR crece >15% MoM, churn es <5% y LTV/CAC > 3x, el negocio
-- es financieramente saludable y escalable.
-- =============================================================


-- =============================================================
-- QUERY 1: MRR (Monthly Recurring Revenue) por mes
-- =============================================================
-- QUÉ ES: El total de ingresos recurrentes que la empresa genera
-- en un mes, solo de suscripciones activas (no one-time payments).
-- POR QUÉ IMPORTA: Es la métrica de salud #1 de un SaaS.
-- Un inversor mira la curva del MRR — si crece de forma consistente
-- y predecible, el negocio es escalable. Una curva plana o con
-- caídas señala problemas de retención o adquisición.
-- DIFERENCIA con revenue: el revenue puede incluir cobros únicos,
-- reembolsos, etc. El MRR es solo la parte recurrente, normalizada
-- a mensual. Permite proyectar el ARR (MRR × 12).
-- =============================================================
WITH mrr_mensual AS (
    SELECT
        p.periodo_facturado,
        pl.nombre                                   AS tier,
        COUNT(DISTINCT p.usuario_id)                AS usuarios_pagando,
        SUM(p.importe)                              AS mrr,
        ROUND(AVG(p.importe), 2)                    AS arpu  -- Average Revenue Per User
    FROM pagos p
    JOIN suscripciones s ON s.id = p.suscripcion_id
    JOIN planes pl        ON pl.id = s.plan_id
    WHERE p.estado = 'completado'
      AND pl.nombre != 'free'   -- Free no genera MRR
    GROUP BY p.periodo_facturado, pl.nombre
),
mrr_total AS (
    SELECT
        periodo_facturado,
        SUM(mrr)                                    AS mrr_total,
        SUM(usuarios_pagando)                       AS total_usuarios_pagando
    FROM mrr_mensual
    GROUP BY periodo_facturado
)
SELECT
    t.periodo_facturado                             AS mes,
    t.mrr_total,
    -- ARR proyectado: MRR × 12 (lo que ingresaría en 12 meses al ritmo actual)
    t.mrr_total * 12                                AS arr_proyectado,
    t.total_usuarios_pagando,
    ROUND(t.mrr_total / t.total_usuarios_pagando, 2) AS arpu_global,
    -- Desglose por tier
    MAX(CASE WHEN m.tier = 'pro' THEN m.mrr ELSE 0 END)  AS mrr_pro,
    MAX(CASE WHEN m.tier = 'max' THEN m.mrr ELSE 0 END)  AS mrr_max,
    -- Crecimiento MoM
    ROUND(
        (t.mrr_total - LAG(t.mrr_total) OVER (ORDER BY t.periodo_facturado))
        / NULLIF(LAG(t.mrr_total) OVER (ORDER BY t.periodo_facturado), 0)
        * 100, 1
    )                                               AS crecimiento_mom_pct
FROM mrr_total t
JOIN mrr_mensual m ON m.periodo_facturado = t.periodo_facturado
GROUP BY t.periodo_facturado, t.mrr_total, t.total_usuarios_pagando
ORDER BY t.periodo_facturado;


-- =============================================================
-- QUERY 2: CHURN RATE mensual (tasa de abandono)
-- =============================================================
-- QUÉ ES: El porcentaje de clientes de pago que cancela en un mes.
-- Fórmula: (cancelaciones en el mes) / (clientes al inicio del mes) × 100
-- POR QUÉ IMPORTA: Es la métrica de retención fundamental.
-- Un churn del 5% mensual significa que en 20 meses has perdido
-- toda tu base de clientes. El 2% mensual = 22% anual (tolerable).
-- El <1% mensual es excelente (mundo enterprise).
-- DISTINCIÓN importante: Churn de clientes (cuántos se van)
-- vs Revenue Churn (cuánto MRR se pierde). Son distintos si
-- tienes tiers: perder un cliente Max duele más que perder uno Pro.
-- =============================================================
WITH clientes_inicio_mes AS (
    -- Clientes de pago activos al inicio de cada mes
    SELECT
        TO_CHAR(DATE_TRUNC('month', fecha_inicio), 'YYYY-MM') AS mes,
        COUNT(*)                                               AS clientes_inicio
    FROM suscripciones
    WHERE plan_id IN (SELECT id FROM planes WHERE nombre != 'free')
      AND estado IN ('activa', 'upgradeada', 'cancelada')
      AND fecha_inicio < DATE_TRUNC('month', fecha_inicio) + INTERVAL '1 month'
    GROUP BY DATE_TRUNC('month', fecha_inicio)
),
churns_mes AS (
    -- Cancelaciones ocurridas en cada mes
    SELECT
        TO_CHAR(DATE_TRUNC('month', fecha_cancelacion), 'YYYY-MM') AS mes,
        COUNT(*)                                                    AS num_churns,
        COUNT(*) FILTER (WHERE nps_salida < 5)                     AS churns_insatisfechos,
        COUNT(*) FILTER (WHERE fue_retenible = TRUE)               AS churns_retenibles
    FROM cancelaciones
    GROUP BY DATE_TRUNC('month', fecha_cancelacion)
),
revenue_churn AS (
    -- Revenue perdido por churn en cada mes
    SELECT
        TO_CHAR(DATE_TRUNC('month', c.fecha_cancelacion), 'YYYY-MM') AS mes,
        SUM(s.precio_efectivo)                                         AS mrr_perdido
    FROM cancelaciones c
    JOIN suscripciones s ON s.id = c.suscripcion_id
    GROUP BY DATE_TRUNC('month', c.fecha_cancelacion)
)
SELECT
    ch.mes,
    COALESCE(ci.clientes_inicio, 0)             AS clientes_inicio_mes,
    COALESCE(ch.num_churns, 0)                  AS churns,
    ROUND(
        COALESCE(ch.num_churns, 0) * 100.0
        / NULLIF(ci.clientes_inicio, 0), 1
    )                                           AS churn_rate_pct,
    COALESCE(ch.churns_insatisfechos, 0)        AS churns_insatisfechos,
    COALESCE(ch.churns_retenibles, 0)           AS churns_retenibles,
    COALESCE(rc.mrr_perdido, 0)                 AS mrr_perdido,
    -- Revenue Churn Rate: % del MRR perdido
    ROUND(
        COALESCE(rc.mrr_perdido, 0) * 100.0
        / NULLIF((
            SELECT SUM(importe)
            FROM pagos
            WHERE periodo_facturado = ch.mes
              AND estado = 'completado'
        ), 0), 1
    )                                           AS revenue_churn_rate_pct
FROM churns_mes ch
LEFT JOIN clientes_inicio_mes ci ON ci.mes = ch.mes
LEFT JOIN revenue_churn rc       ON rc.mes = ch.mes
ORDER BY ch.mes;


-- =============================================================
-- QUERY 3: CONVERSIÓN Free → Pro y Pro → Max
-- =============================================================
-- QUÉ ES: El porcentaje de usuarios que sube de tier.
-- POR QUÉ IMPORTA: En un modelo PLG (Product-Led Growth) como
-- ScriptMind, la conversión Free→Pro es el KPI de monetización
-- más importante. Si es baja (<5%), el producto no está creando
-- suficiente urgencia de pago. Si es alta (>15%), señala que el
-- pricing y el freemium están bien calibrados.
-- Pro→Max es la tasa de expansión — indica si los usuarios
-- encuentran suficiente valor adicional para pagar 2.5x más.
-- Un Net Revenue Retention >100% significa que los upgrades
-- compensan el churn — señal de un SaaS muy saludable.
-- =============================================================
WITH cohortes_mes AS (
    SELECT
        TO_CHAR(DATE_TRUNC('month', u.fecha_registro), 'YYYY-MM') AS cohorte,
        COUNT(DISTINCT u.id)                                       AS usuarios_registrados
    FROM usuarios u
    GROUP BY DATE_TRUNC('month', u.fecha_registro)
),
conversiones_free_pro AS (
    SELECT
        TO_CHAR(DATE_TRUNC('month', u.fecha_registro), 'YYYY-MM') AS cohorte,
        COUNT(DISTINCT u.id)                                       AS convertidos_a_pro
    FROM usuarios u
    WHERE EXISTS (
        SELECT 1 FROM suscripciones s
        JOIN planes pl ON pl.id = s.plan_id
        WHERE s.usuario_id = u.id
          AND pl.nombre = 'pro'
          AND s.origen_cambio IN ('upgrade_voluntario','upgrade_oferta','trial_conversion')
    )
    GROUP BY DATE_TRUNC('month', u.fecha_registro)
),
conversiones_pro_max AS (
    SELECT
        TO_CHAR(DATE_TRUNC('month', u.fecha_registro), 'YYYY-MM') AS cohorte,
        COUNT(DISTINCT u.id)                                       AS upgrades_a_max
    FROM usuarios u
    WHERE EXISTS (
        SELECT 1 FROM suscripciones s
        JOIN planes pl ON pl.id = s.plan_id
        WHERE s.usuario_id = u.id
          AND pl.nombre = 'max'
          AND s.origen_cambio = 'upgrade_voluntario'
    )
    AND EXISTS (
        SELECT 1 FROM suscripciones s
        JOIN planes pl ON pl.id = s.plan_id
        WHERE s.usuario_id = u.id AND pl.nombre = 'pro'
    )
    GROUP BY DATE_TRUNC('month', u.fecha_registro)
),
max_directo AS (
    -- Usuarios que llegaron directamente a Max (saltando Pro)
    SELECT
        TO_CHAR(DATE_TRUNC('month', u.fecha_registro), 'YYYY-MM') AS cohorte,
        COUNT(DISTINCT u.id)                                       AS max_directo
    FROM usuarios u
    WHERE EXISTS (
        SELECT 1 FROM suscripciones s
        JOIN planes pl ON pl.id = s.plan_id
        WHERE s.usuario_id = u.id AND pl.nombre = 'max'
          AND s.origen_cambio = 'registro'
    )
    GROUP BY DATE_TRUNC('month', u.fecha_registro)
)
SELECT
    c.cohorte,
    c.usuarios_registrados,
    COALESCE(fp.convertidos_a_pro, 0)              AS free_to_pro,
    COALESCE(md.max_directo, 0)                     AS max_directo,
    ROUND(
        COALESCE(fp.convertidos_a_pro, 0) * 100.0
        / NULLIF(c.usuarios_registrados, 0), 1
    )                                               AS tasa_conv_free_pro_pct,
    COALESCE(pm.upgrades_a_max, 0)                  AS upgrades_pro_max,
    ROUND(
        COALESCE(pm.upgrades_a_max, 0) * 100.0
        / NULLIF(COALESCE(fp.convertidos_a_pro, 0), 0), 1
    )                                               AS tasa_upgrade_pro_max_pct,
    -- Total monetizados (pro + max)
    COALESCE(fp.convertidos_a_pro, 0)
    + COALESCE(md.max_directo, 0)                   AS total_monetizados,
    ROUND(
        (COALESCE(fp.convertidos_a_pro, 0) + COALESCE(md.max_directo, 0)) * 100.0
        / NULLIF(c.usuarios_registrados, 0), 1
    )                                               AS tasa_monetizacion_total_pct
FROM cohortes_mes c
LEFT JOIN conversiones_free_pro fp ON fp.cohorte = c.cohorte
LEFT JOIN conversiones_pro_max  pm ON pm.cohorte = c.cohorte
LEFT JOIN max_directo            md ON md.cohorte = c.cohorte
ORDER BY c.cohorte;


-- =============================================================
-- QUERY 4: LTV medio por tier (Lifetime Value)
-- =============================================================
-- QUÉ ES: El revenue total esperado de un cliente durante toda
-- su relación con el producto.
-- Fórmula simplificada: ARPU mensual / Churn Rate mensual
-- O bien: suma real del revenue histórico por usuario.
-- POR QUÉ IMPORTA: El LTV determina cuánto puedes gastar en
-- adquirir un cliente (CAC). La regla de oro es LTV/CAC > 3.
-- Si adquirir un cliente Pro cuesta €50 (Google Ads) y su LTV
-- es €180, el ratio es 3.6x — aceptable. Si el LTV es €60,
-- estás perdiendo dinero en cada cliente.
-- IMPORTANTE: un LTV/CAC alto + churn bajo = flywheel activado.
-- =============================================================
WITH revenue_por_usuario AS (
    SELECT
        p.usuario_id,
        pl.nombre                                   AS tier_final,
        SUM(p.importe)                              AS revenue_total,
        COUNT(DISTINCT p.periodo_facturado)         AS meses_pagando,
        MIN(p.fecha_pago::DATE)                     AS primer_pago,
        MAX(p.fecha_pago::DATE)                     AS ultimo_pago,
        u.plan_actual                               AS estado_actual
    FROM pagos p
    JOIN usuarios u       ON u.id = p.usuario_id
    JOIN suscripciones s  ON s.id = p.suscripcion_id
    JOIN planes pl        ON pl.id = s.plan_id
    WHERE p.estado = 'completado'
    GROUP BY p.usuario_id, pl.nombre, u.plan_actual
),
resumen_por_tier AS (
    SELECT
        tier_final,
        COUNT(*)                                    AS num_usuarios,
        ROUND(AVG(revenue_total), 2)                AS ltv_medio,
        ROUND(MIN(revenue_total), 2)                AS ltv_minimo,
        ROUND(MAX(revenue_total), 2)                AS ltv_maximo,
        ROUND(PERCENTILE_CONT(0.5)
            WITHIN GROUP (ORDER BY revenue_total), 2) AS ltv_mediana,
        ROUND(AVG(meses_pagando), 1)                AS meses_medio_activo,
        -- LTV proyectado anual (extrapola si llevan < 12 meses)
        ROUND(AVG(revenue_total / meses_pagando) * 12, 2) AS ltv_anual_proyectado,
        COUNT(*) FILTER (WHERE estado_actual = 'churned') AS churneados
    FROM revenue_por_usuario
    GROUP BY tier_final
)
SELECT
    r.*,
    -- CAC asumido por canal (valores de referencia de mercado SaaS)
    CASE tier_final
        WHEN 'pro' THEN 45.00
        WHEN 'max' THEN 80.00
        ELSE 0
    END                                             AS cac_estimado,
    ROUND(
        r.ltv_medio / NULLIF(
            CASE tier_final WHEN 'pro' THEN 45.00 WHEN 'max' THEN 80.00 ELSE 1 END,
        0), 2)                                      AS ratio_ltv_cac
FROM resumen_por_tier r
ORDER BY ltv_medio DESC;


-- =============================================================
-- QUERY 5: USUARIOS ACTIVOS vs INACTIVOS
-- =============================================================
-- QUÉ ES: Distingue entre usuarios que realmente usan el producto
-- y los que están registrados pero "muertos".
-- DEFINICIÓN usada:
--   Activo = login en los últimos 30 días
--   En riesgo = login entre 31 y 90 días
--   Inactivo = sin login en >90 días o nunca logueado
-- POR QUÉ IMPORTA: Los usuarios inactivos en tier Free nunca
-- van a convertir. Los de pago en riesgo son churns en potencia.
-- El equipo de Customer Success debe priorizar la reactivación
-- de usuarios Pro/Max en riesgo antes de que cancelen.
-- DAU/MAU ratio (usuarios activos diarios / mensuales) es
-- otra métrica clave de engagement que se puede derivar de aquí.
-- =============================================================
WITH actividad AS (
    SELECT
        u.id,
        u.email,
        u.nombre,
        u.plan_actual,
        u.canal_adquisicion,
        u.pais,
        u.fecha_registro,
        u.ultimo_login,
        -- Días desde último login
        EXTRACT(DAY FROM NOW() - u.ultimo_login)::INT AS dias_sin_login,
        -- Clasificación de actividad
        CASE
            WHEN u.ultimo_login IS NULL
                THEN 'nunca_activo'
            WHEN u.ultimo_login >= NOW() - INTERVAL '30 days'
                THEN 'activo'
            WHEN u.ultimo_login >= NOW() - INTERVAL '90 days'
                THEN 'en_riesgo'
            ELSE 'inactivo'
        END AS segmento_actividad,
        -- ¿Genera revenue?
        CASE WHEN u.plan_actual IN ('pro','max') THEN TRUE ELSE FALSE END AS es_pagador
    FROM usuarios u
    WHERE u.activo = TRUE
)
SELECT
    segmento_actividad,
    plan_actual,
    COUNT(*)                                        AS num_usuarios,
    COUNT(*) FILTER (WHERE es_pagador)              AS pagadores_en_segmento,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY plan_actual), 1) AS pct_del_tier,
    ROUND(AVG(dias_sin_login), 0)                   AS dias_sin_login_promedio,
    -- Revenue en riesgo (usuarios pagadores inactivos)
    SUM(CASE
        WHEN es_pagador AND segmento_actividad IN ('en_riesgo','inactivo')
        THEN CASE plan_actual WHEN 'pro' THEN 19 WHEN 'max' THEN 49 ELSE 0 END
        ELSE 0
    END)                                            AS mrr_en_riesgo
FROM actividad
GROUP BY segmento_actividad, plan_actual
ORDER BY plan_actual, segmento_actividad;


-- =============================================================
-- QUERY 6: REVENUE POR COHORTE DE ADQUISICIÓN
-- =============================================================
-- QUÉ ES: Un análisis de cohortes muestra cómo evoluciona el
-- revenue de un grupo de usuarios adquiridos en el mismo mes
-- a lo largo del tiempo (mes 1, mes 2, mes 3...).
-- POR QUÉ IMPORTA: Es el análisis más sofisticado que pide
-- un inversor. Revela si el producto tiene retención estructural.
-- Una cohorte saludable no debería caer más del 20% en mes 3.
-- Si la cohorte de enero sigue generando revenue en mes 6,
-- el producto tiene "stickiness" real.
-- Además, permite comparar cohortes: ¿los usuarios de Product Hunt
-- retienen mejor que los de Google Ads? ¿Valen más los de enero
-- o los de mayo? Responde si el CAC está mejorando con el tiempo.
-- =============================================================
WITH cohorte_usuarios AS (
    SELECT
        u.id                                        AS usuario_id,
        TO_CHAR(DATE_TRUNC('month', u.fecha_registro), 'YYYY-MM') AS cohorte_mes,
        u.canal_adquisicion
    FROM usuarios u
),
pagos_mensuales AS (
    SELECT
        p.usuario_id,
        p.periodo_facturado,
        SUM(p.importe)                              AS revenue_mes
    FROM pagos p
    WHERE p.estado = 'completado'
    GROUP BY p.usuario_id, p.periodo_facturado
),
cohorte_revenue AS (
    SELECT
        cu.cohorte_mes,
        pm.periodo_facturado,
        -- Mes de vida de la cohorte (0 = mes de registro, 1 = mes siguiente, etc.)
        (EXTRACT(YEAR FROM pm.periodo_facturado::DATE)
            - EXTRACT(YEAR FROM (cu.cohorte_mes || '-01')::DATE)) * 12
        + (EXTRACT(MONTH FROM pm.periodo_facturado::DATE)
            - EXTRACT(MONTH FROM (cu.cohorte_mes || '-01')::DATE))
        AS mes_vida_cohorte,
        COUNT(DISTINCT cu.usuario_id)               AS usuarios_activos,
        SUM(pm.revenue_mes)                         AS revenue_cohorte
    FROM cohorte_usuarios cu
    JOIN pagos_mensuales pm ON pm.usuario_id = cu.usuario_id
    GROUP BY cu.cohorte_mes, pm.periodo_facturado,
             EXTRACT(YEAR FROM pm.periodo_facturado::DATE),
             EXTRACT(YEAR FROM (cu.cohorte_mes || '-01')::DATE),
             EXTRACT(MONTH FROM pm.periodo_facturado::DATE),
             EXTRACT(MONTH FROM (cu.cohorte_mes || '-01')::DATE)
)
SELECT
    cohorte_mes,
    mes_vida_cohorte,
    periodo_facturado,
    usuarios_activos,
    revenue_cohorte,
    -- Revenue acumulado de la cohorte hasta ese mes
    SUM(revenue_cohorte) OVER (
        PARTITION BY cohorte_mes
        ORDER BY mes_vida_cohorte
        ROWS UNBOUNDED PRECEDING
    )                                               AS revenue_acumulado_cohorte,
    -- Revenue en mes 0 (primer mes) de esta cohorte — para calcular retención %
    FIRST_VALUE(revenue_cohorte) OVER (
        PARTITION BY cohorte_mes
        ORDER BY mes_vida_cohorte
    )                                               AS revenue_mes_0,
    -- Retención de revenue vs mes inicial
    ROUND(
        revenue_cohorte * 100.0
        / NULLIF(FIRST_VALUE(revenue_cohorte) OVER (
            PARTITION BY cohorte_mes ORDER BY mes_vida_cohorte
        ), 0), 1
    )                                               AS retencion_revenue_pct
FROM cohorte_revenue
ORDER BY cohorte_mes, mes_vida_cohorte;


-- =============================================================
-- QUERY BONUS 1: NORTH STAR METRIC — Resumen ejecutivo para inversor
-- =============================================================
-- Este es el resumen de una página que presentarías en un pitch.
-- Agrupa todas las métricas clave en una sola query.
-- =============================================================
WITH metricas AS (
    SELECT
        -- MRR actual (último mes completo = junio 2024)
        (SELECT SUM(importe) FROM pagos
         WHERE periodo_facturado = '2024-06' AND estado = 'completado') AS mrr_actual,
        -- MRR primer mes (enero 2024)
        (SELECT SUM(importe) FROM pagos
         WHERE periodo_facturado = '2024-01' AND estado = 'completado') AS mrr_inicial,
        -- Total usuarios registrados
        (SELECT COUNT(*) FROM usuarios WHERE activo = TRUE) AS total_usuarios,
        -- Usuarios pagando hoy
        (SELECT COUNT(*) FROM usuarios WHERE plan_actual IN ('pro','max')) AS usuarios_pagando,
        -- Total churns
        (SELECT COUNT(*) FROM cancelaciones) AS total_churns,
        -- LTV medio global
        (SELECT ROUND(AVG(revenue_total),2)
         FROM (SELECT usuario_id, SUM(importe) AS revenue_total
               FROM pagos WHERE estado='completado'
               GROUP BY usuario_id) t) AS ltv_medio_global
)
SELECT
    mrr_actual                                      AS "MRR Junio 2024 (€)",
    mrr_actual * 12                                 AS "ARR Proyectado (€)",
    ROUND((mrr_actual - mrr_inicial) * 100.0 / NULLIF(mrr_inicial,0), 1)
                                                    AS "Crecimiento MRR 6 meses (%)",
    total_usuarios                                  AS "Total Usuarios",
    usuarios_pagando                                AS "Usuarios de Pago",
    ROUND(usuarios_pagando * 100.0 / NULLIF(total_usuarios, 0), 1)
                                                    AS "Tasa Monetización (%)",
    ltv_medio_global                                AS "LTV Medio Global (€)",
    total_churns                                    AS "Total Churns (6 meses)"
FROM metricas;


-- =============================================================
-- QUERY BONUS 2: CANAL DE ADQUISICIÓN — ¿Qué canal trae mejor LTV?
-- =============================================================
-- POR QUÉ IMPORTA: No todos los canales son iguales.
-- Un usuario de Product Hunt puede tener LTV 3x mayor que uno
-- de Google Ads pero costar 5x menos. Esto determina dónde
-- invertir el presupuesto de marketing.
-- =============================================================
SELECT
    u.canal_adquisicion,
    COUNT(DISTINCT u.id)                            AS usuarios_registrados,
    COUNT(DISTINCT u.id) FILTER (WHERE u.plan_actual IN ('pro','max','churned'))
                                                    AS alguna_vez_pagaron,
    ROUND(
        COUNT(DISTINCT u.id) FILTER (WHERE u.plan_actual IN ('pro','max','churned'))
        * 100.0 / NULLIF(COUNT(DISTINCT u.id), 0), 1
    )                                               AS tasa_conversion_pago_pct,
    COALESCE(ROUND(SUM(p.importe) / NULLIF(COUNT(DISTINCT u.id),0), 2), 0)
                                                    AS revenue_por_usuario_adquirido,
    COALESCE(SUM(p.importe), 0)                     AS revenue_total_canal
FROM usuarios u
LEFT JOIN pagos p ON p.usuario_id = u.id AND p.estado = 'completado'
GROUP BY u.canal_adquisicion
ORDER BY revenue_total_canal DESC;
