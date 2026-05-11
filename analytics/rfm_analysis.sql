-- =============================================================
-- ViveRioja Experience S.L. — Análisis RFM de Clientes
-- Recencia · Frecuencia · Valor Monetario
-- Compatible con PostgreSQL 15+
-- Ejecutar después de 01_schema.sql y 02_seed.sql
-- =============================================================


-- =============================================================
-- DECISIONES DE DISEÑO GLOBALES
-- =============================================================
-- 1. RECENCIA: usamos MAX(fecha_experiencia) de reservas completadas,
--    NO fecha_reserva. En enoturismo la señal relevante es cuándo el
--    cliente vivió la experiencia por última vez, no cuándo hizo el click.
--    Alguien que reservó en enero para marzo tiene recencia = marzo.
--
-- 2. FRECUENCIA: COUNT de reservas con estado = 'completada'. Las
--    canceladas y no_shows no cuentan como comportamiento fidelizador.
--
-- 3. VALOR MONETARIO: SUM de pagos.importe con estado = 'completado'.
--    NO usamos reservas.precio_total directamente porque una reserva
--    puede estar completada pero el pago reembolsado. La tabla pagos
--    es la fuente de verdad financiera (ver criterio en 03_queries.sql).
--
-- 4. NTILE(4): cuartiles estándar en RFM. Con ORDER BY DESC para R
--    (pocos días = mejor = score 4) y ASC para F y M
--    (más reservas / más gasto = mejor = score 4).
--    Con datasets pequeños (académico/seed) NTILE puede generar grupos
--    desiguales si hay empates — es esperado y no afecta la lógica.
-- =============================================================


-- =============================================================
-- CTE 1: rfm_base — métricas brutas por cliente
-- =============================================================
WITH rfm_base AS (
    SELECT
        c.id                                            AS cliente_id,
        c.nombre || ' ' || c.apellidos                 AS nombre_completo,
        c.ciudad,
        c.nacionalidad,
        c.canal_adquisicion,

        -- Recencia: días desde la última experiencia completada hasta hoy.
        -- CAST a INT para limpiar el output (CURRENT_DATE - DATE devuelve INTEGER en PG).
        (CURRENT_DATE - MAX(r.fecha_experiencia))::INT AS recencia_dias,

        -- Frecuencia: número de reservas completadas distintas.
        -- COUNT DISTINCT es defensivo: no debería haber duplicados, pero previene
        -- que un posible doble-join con pagos infle el conteo.
        COUNT(DISTINCT r.id)                            AS num_reservas,

        -- Valor Monetario: suma de importes pagados y cobrados.
        -- COALESCE(..., 0) cubre el caso borde de un cliente con reservas
        -- completadas pero sin ningún pago en estado 'completado' aún
        -- (señal de anomalía contable, pero no queremos que el query falle).
        COALESCE(SUM(p.importe), 0)                    AS total_gastado

    FROM clientes c

    -- JOIN a reservas: solo las completadas aportan señal RFM real.
    JOIN reservas r  ON r.cliente_id = c.id
                    AND r.estado     = 'completada'

    -- LEFT JOIN a pagos: puede haber reservas completadas con pago
    -- pendiente o reembolsado; el LEFT evita perder esos clientes del análisis.
    LEFT JOIN pagos p ON p.reserva_id = r.id
                     AND p.estado     = 'completado'

    -- Clientes sin ninguna reserva completada no tienen historia RFM útil,
    -- así que el INNER JOIN sobre reservas los excluye correctamente.
    GROUP BY
        c.id, c.nombre, c.apellidos,
        c.ciudad, c.nacionalidad, c.canal_adquisicion
),


-- =============================================================
-- CTE 2: rfm_scores — puntuaciones 1-4 por cuartil
-- =============================================================
-- Regla: 4 = mejor cliente, 1 = peor cliente en cada dimensión.
--
-- Para R (Recencia): ORDER BY recencia_dias DESC
--   → muchos días (cliente inactivo) = primeras filas → NTILE = 1 (peor)
--   → pocos días (cliente reciente)  = últimas filas  → NTILE = 4 (mejor)
--
-- Para F y M: ORDER BY ... ASC
--   → valor bajo = primeras filas → NTILE = 1 (peor)
--   → valor alto = últimas filas  → NTILE = 4 (mejor)
-- =============================================================
rfm_scores AS (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY recencia_dias DESC) AS r_score,
        NTILE(4) OVER (ORDER BY num_reservas   ASC) AS f_score,
        NTILE(4) OVER (ORDER BY total_gastado  ASC) AS m_score
    FROM rfm_base
),


-- =============================================================
-- CTE 3: rfm_segments — segmentación por texto de negocio
-- =============================================================
-- ORDEN DE CASES: de más restrictivo a más general.
-- Si invertimos el orden, un Champions (R=4, F=4) caería en
-- 'Loyal Customers' (F>=3) antes de ser evaluado como Champions.
-- El CASE se evalúa de arriba abajo y devuelve en el primer match.
--
-- Nota de negocio: un cliente con F>=3 y R<=2 (muchas compras
-- pero tiempo sin aparecer) cae en 'Loyal Customers', no 'At Risk'.
-- Esa es la especificación dada. En una versión avanzada podríamos
-- añadir un segmento 'Champions at Risk' para ese perfil.
-- =============================================================
rfm_segments AS (
    SELECT
        *,
        CASE
            -- Mejor segmento: recientes Y frecuentes
            WHEN r_score = 4 AND f_score = 4           THEN 'Champions'

            -- Alta frecuencia independientemente de recencia
            WHEN f_score >= 3                           THEN 'Loyal Customers'

            -- Compraron varias veces pero llevan tiempo sin volver
            WHEN r_score <= 2 AND f_score >= 2         THEN 'At Risk'

            -- Una sola compra, muy inactivos: probablemente perdidos
            WHEN r_score = 1 AND f_score = 1           THEN 'Lost'

            -- Primera compra reciente: hay que convertirlos antes de perderlos
            WHEN f_score = 1 AND r_score >= 3          THEN 'New Customers'

            -- Todo lo demás: compraron poco o moderado, con recencia media
            ELSE                                            'Potential Loyalists'
        END AS segmento
    FROM rfm_scores
)


-- =============================================================
-- QUERY FINAL: vista ejecutiva completa
-- =============================================================
-- Incluye métricas brutas + scores + segmento + código RFM.
-- rfm_code (ej. '442') es útil para exportar al CRM y filtrar
-- micro-segmentos sin recalcular todo el análisis.
-- =============================================================
SELECT
    cliente_id,
    nombre_completo,
    ciudad,
    nacionalidad,
    canal_adquisicion,

    -- Segmento de negocio
    segmento,

    -- Puntuaciones individuales (1 = peor, 4 = mejor)
    r_score,
    f_score,
    m_score,

    -- Código RFM concatenado — útil para filtrar en CRM / exportar a Excel
    CONCAT(r_score, f_score, m_score)   AS rfm_code,

    -- Métricas brutas para contexto
    recencia_dias,
    num_reservas,
    ROUND(total_gastado, 2)             AS total_gastado

FROM rfm_segments
ORDER BY
    -- Ordenar por segmento (de mejor a peor) y dentro de cada uno por gasto
    CASE segmento
        WHEN 'Champions'           THEN 1
        WHEN 'Loyal Customers'     THEN 2
        WHEN 'At Risk'             THEN 3
        WHEN 'New Customers'       THEN 4
        WHEN 'Potential Loyalists' THEN 5
        WHEN 'Lost'                THEN 6
    END,
    total_gastado DESC;


-- =============================================================
-- QUERIES DE APOYO: resumen por segmento para presentación
-- =============================================================
-- Descomenta para ejecutar el resumen agregado.
-- Útil para un dashboard ejecutivo o slide de dirección.
-- =============================================================

/*
-- Distribución de clientes y revenue por segmento
WITH rfm_base AS ( ... ),  -- copiar las CTEs de arriba
     rfm_scores AS ( ... ),
     rfm_segments AS ( ... )
SELECT
    segmento,
    COUNT(*)                                    AS num_clientes,
    ROUND(AVG(recencia_dias), 0)                AS recencia_media_dias,
    ROUND(AVG(num_reservas), 1)                 AS reservas_media,
    ROUND(AVG(total_gastado), 2)                AS gasto_medio,
    ROUND(SUM(total_gastado), 2)                AS gasto_total_segmento,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        1
    )                                           AS pct_clientes,
    ROUND(
        SUM(total_gastado) * 100.0
        / SUM(SUM(total_gastado)) OVER (),
        1
    )                                           AS pct_revenue
FROM rfm_segments
GROUP BY segmento
ORDER BY gasto_total_segmento DESC;
*/


-- =============================================================
-- CÓMO CONECTAR Y EJECUTAR
-- =============================================================
-- Opción A — psql en terminal:
--   psql -h localhost -U viverioja_user -d viverioja_db -f analytics/rfm_analysis.sql
--
-- Opción B — DBeaver / TablePlus / DataGrip:
--   Abrir este archivo y ejecutar con F5 o Ctrl+Enter.
--
-- Opción C — pgAdmin 4:
--   Query Tool → Open File → rfm_analysis.sql → Execute (F5)
--
-- Variables de entorno recomendadas (archivo .env, NO commitear):
--   PGHOST=localhost
--   PGPORT=5432
--   PGDATABASE=viverioja_db
--   PGUSER=viverioja_user
--   PGPASSWORD=tu_password
-- =============================================================
