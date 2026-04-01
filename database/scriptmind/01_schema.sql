-- =============================================================
-- ScriptMind — Schema Relacional SaaS
-- Base de datos: PostgreSQL 15+
-- Producto: Plataforma de transcripción e IA
-- Tiers: Free (€0) | Pro (€19/mes) | Max (€49/mes)
-- =============================================================
-- ARQUITECTURA:
-- En un SaaS, el modelo de datos gira en torno al CICLO DE VIDA
-- del usuario: adquisición → activación → retención → expansión → churn.
-- Cada tabla captura una fase distinta de ese ciclo.
-- El objetivo analítico es entender MRR, Churn y LTV — los tres
-- números que un inversor mira primero.
-- =============================================================

DROP TABLE IF EXISTS eventos_uso       CASCADE;
DROP TABLE IF EXISTS cancelaciones     CASCADE;
DROP TABLE IF EXISTS pagos             CASCADE;
DROP TABLE IF EXISTS suscripciones     CASCADE;
DROP TABLE IF EXISTS usuarios          CASCADE;
DROP TABLE IF EXISTS planes            CASCADE;


-- =============================================================
-- TABLA 1: PLANES
-- Catálogo de productos — los tiers del SaaS.
-- DECISIÓN: tabla separada aunque sean 3 filas fijas.
-- Ventaja: si cambia el precio, cambiamos 1 fila y todas las
-- queries que referencian planes[precio_mensual] se actualizan
-- automáticamente. Sin tabla, habría precios hardcodeados en DAX.
-- precio_mensual = 0 para Free es válido: facilita queries de
-- revenue sin necesidad de excluir manualmente el tier free.
-- =============================================================
CREATE TABLE planes (
    id                  SERIAL PRIMARY KEY,
    nombre              VARCHAR(20)   NOT NULL UNIQUE
                        CHECK (nombre IN ('free','pro','max')),
    precio_mensual      NUMERIC(8,2)  NOT NULL DEFAULT 0
                        CHECK (precio_mensual >= 0),
    limite_minutos_mes  INT,          -- NULL = ilimitado
    limite_ia_queries   INT,          -- NULL = ilimitado
    limite_proyectos    INT,          -- NULL = ilimitado
    soporte             VARCHAR(50)   CHECK (soporte IN (
                            'comunidad','email','prioritario','dedicado')),
    descripcion         TEXT
);

COMMENT ON TABLE  planes IS 'Catálogo de tiers de ScriptMind';
COMMENT ON COLUMN planes.limite_minutos_mes IS 'NULL = sin límite (Max). Free = 60 min/mes';


-- =============================================================
-- TABLA 2: USUARIOS
-- Todos los registros, independientemente del plan.
-- DECISIÓN: plan_actual es una desnormalización controlada.
-- El estado "real" del plan está en suscripciones, pero tener
-- plan_actual en usuarios permite queries rápidas de segmentación
-- sin siempre hacer JOIN. Hay que mantenerla sincronizada (trigger
-- o lógica de aplicación al cambiar plan).
-- DECISIÓN: canal_adquisicion es clave para análisis de cohortes
-- y ROI de marketing. ¿Qué canal trae usuarios que pagan más?
-- =============================================================
CREATE TABLE usuarios (
    id                  SERIAL PRIMARY KEY,
    email               VARCHAR(255)  NOT NULL UNIQUE,
    nombre              VARCHAR(100)  NOT NULL,
    apellidos           VARCHAR(150),
    plan_actual         VARCHAR(20)   NOT NULL DEFAULT 'free'
                        CHECK (plan_actual IN ('free','pro','max','churned')),
    canal_adquisicion   VARCHAR(50)   CHECK (canal_adquisicion IN (
                            'organico','seo','google_ads','linkedin_ads',
                            'referido','product_hunt','twitter','directo','otro')),
    pais                CHAR(2)       DEFAULT 'ES',  -- ISO 3166-1
    empresa             VARCHAR(150),                -- B2B indicator
    fecha_registro      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    ultimo_login        TIMESTAMPTZ,
    activo              BOOLEAN       NOT NULL DEFAULT TRUE,
    -- onboarding: ¿completó la configuración inicial?
    onboarding_completo BOOLEAN       NOT NULL DEFAULT FALSE
);

COMMENT ON TABLE  usuarios IS 'Todos los usuarios registrados en ScriptMind';
COMMENT ON COLUMN usuarios.plan_actual IS '"churned" = se fue. Desnormalización para queries rápidas';
COMMENT ON COLUMN usuarios.canal_adquisicion IS 'Canal de marketing que originó el registro';


-- =============================================================
-- TABLA 3: SUSCRIPCIONES
-- Historial completo del plan de cada usuario.
-- DECISIÓN: esta es la tabla más importante del modelo.
-- Cada cambio de plan (upgrade, downgrade, cancel) genera una
-- NUEVA fila con fecha_fin en la anterior y fecha_inicio en la nueva.
-- Esto permite reconstruir el estado del portfolio en CUALQUIER
-- fecha pasada — fundamental para cálculos de MRR histórico.
-- Si solo guardáramos el plan actual, perderíamos la historia.
-- =============================================================
CREATE TABLE suscripciones (
    id                  SERIAL PRIMARY KEY,
    usuario_id          INT           NOT NULL REFERENCES usuarios(id),
    plan_id             INT           NOT NULL REFERENCES planes(id),
    fecha_inicio        DATE          NOT NULL,
    fecha_fin           DATE,         -- NULL = suscripción activa actualmente
    estado              VARCHAR(30)   NOT NULL DEFAULT 'activa'
                        CHECK (estado IN (
                            'activa','cancelada','expirada',
                            'upgradeada','downgradeada','trial')),
    periodo_facturacion VARCHAR(20)   DEFAULT 'mensual'
                        CHECK (periodo_facturacion IN ('mensual','anual','trial')),
    -- Precio real cobrado (puede diferir del precio_mensual por descuentos/promociones)
    precio_efectivo     NUMERIC(8,2)  NOT NULL DEFAULT 0,
    -- Origen del cambio para análisis de conversión
    origen_cambio       VARCHAR(50)   CHECK (origen_cambio IN (
                            'registro','upgrade_voluntario','upgrade_oferta',
                            'downgrade','cancelacion','reactivacion','trial_conversion')),
    CONSTRAINT chk_fechas_suscripcion CHECK (
        fecha_fin IS NULL OR fecha_fin > fecha_inicio
    )
);

COMMENT ON TABLE  suscripciones IS 'Historial completo de planes — permite reconstruir MRR en cualquier fecha';
COMMENT ON COLUMN suscripciones.fecha_fin IS 'NULL = suscripción vigente. Fecha = cuando terminó';
COMMENT ON COLUMN suscripciones.precio_efectivo IS 'Precio real cobrado (puede incluir descuentos)';


-- =============================================================
-- TABLA 4: PAGOS
-- Transacciones financieras reales.
-- DECISIÓN: separamos suscripción (contrato) de pago (cobro).
-- Un pago fallido no cancela la suscripción automáticamente;
-- hay un periodo de gracia. Tener tablas separadas modela esto.
-- DECISIÓN: periodo_facturado como 'YYYY-MM' permite queries
-- de MRR directas sin parsear fechas: WHERE periodo_facturado = '2024-03'
-- =============================================================
CREATE TABLE pagos (
    id                  SERIAL PRIMARY KEY,
    usuario_id          INT           NOT NULL REFERENCES usuarios(id),
    suscripcion_id      INT           NOT NULL REFERENCES suscripciones(id),
    fecha_pago          TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    importe             NUMERIC(8,2)  NOT NULL CHECK (importe >= 0),
    periodo_facturado   CHAR(7)       NOT NULL,  -- 'YYYY-MM'
    metodo_pago         VARCHAR(30)   CHECK (metodo_pago IN (
                            'tarjeta','paypal','stripe','sepa','otro')),
    estado              VARCHAR(20)   NOT NULL DEFAULT 'completado'
                        CHECK (estado IN (
                            'completado','fallido','reembolsado','pendiente')),
    referencia_stripe   VARCHAR(100), -- ID de Stripe/pasarela
    es_reembolso        BOOLEAN       NOT NULL DEFAULT FALSE
);

COMMENT ON TABLE  pagos IS 'Transacciones de cobro — fuente de verdad del revenue real';
COMMENT ON COLUMN pagos.periodo_facturado IS 'Mes al que corresponde el pago (YYYY-MM). Clave para MRR';


-- =============================================================
-- TABLA 5: EVENTOS_USO
-- Telemetría del producto — qué hace el usuario y cuánto.
-- DECISIÓN: esta tabla es el fundamento del análisis de
-- "product-led growth". Correlacionar uso con conversión/churn
-- revela los "aha moments" del producto.
-- DECISIÓN: duración en minutos para transcripciones,
-- NULL para eventos sin duración (login, export, etc.).
-- En producción real, esta tabla crece enormemente y se
-- particiona por fecha o se mueve a columnar (BigQuery/Redshift).
-- =============================================================
CREATE TABLE eventos_uso (
    id                  BIGSERIAL PRIMARY KEY,  -- BIGSERIAL: prevé millones de filas
    usuario_id          INT           NOT NULL REFERENCES usuarios(id),
    tipo_evento         VARCHAR(50)   NOT NULL CHECK (tipo_evento IN (
                            'transcripcion','ia_query','exportacion',
                            'login','integracion','compartir',
                            'limite_alcanzado','onboarding_paso')),
    fecha_evento        TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    duracion_minutos    NUMERIC(8,2), -- para transcripciones
    plan_en_momento     VARCHAR(20),  -- snapshot del plan cuando ocurrió el evento
    metadatos           JSONB         -- datos adicionales del evento (formato archivo, idioma, etc.)
);

COMMENT ON TABLE  eventos_uso IS 'Telemetría de uso del producto — base del análisis de activación y retención';
COMMENT ON COLUMN eventos_uso.metadatos IS 'JSONB flexible: idioma, formato, tamaño_archivo, modelo_ia...';


-- =============================================================
-- TABLA 6: CANCELACIONES
-- Registro detallado del churn con motivo.
-- DECISIÓN: tabla separada (no solo un campo en suscripciones)
-- porque el análisis del churn merece su propia dimensión.
-- El motivo de cancelación es información cualitativa de oro
-- para el equipo de producto y retención.
-- DECISIÓN: nps_salida (0-10) captura el NPS en el momento del
-- churn — correlacionarlo con el motivo es muy revelador.
-- =============================================================
CREATE TABLE cancelaciones (
    id                  SERIAL PRIMARY KEY,
    usuario_id          INT           NOT NULL REFERENCES usuarios(id),
    suscripcion_id      INT           NOT NULL REFERENCES suscripciones(id),
    fecha_cancelacion   TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    plan_cancelado      VARCHAR(20)   NOT NULL,
    motivo_categoria    VARCHAR(50)   CHECK (motivo_categoria IN (
                            'precio_alto','alternativa_competencia',
                            'funcionalidad_faltante','poco_uso',
                            'proyecto_terminado','problemas_tecnicos',
                            'no_especificado')),
    motivo_detalle      TEXT,         -- respuesta libre de la encuesta de salida
    nps_salida          SMALLINT      CHECK (nps_salida BETWEEN 0 AND 10),
    -- ¿Podría haberse retenido? (lo marca el equipo de Customer Success)
    fue_retenible       BOOLEAN,
    -- ¿Volvió después? (se actualiza si se reactiva)
    reactivo            BOOLEAN       NOT NULL DEFAULT FALSE,
    fecha_reactivacion  DATE
);

COMMENT ON TABLE  cancelaciones IS 'Análisis cualitativo del churn — por qué se van los usuarios';
COMMENT ON COLUMN cancelaciones.nps_salida IS 'NPS en el momento de cancelar: detecta churn evitable';


-- =============================================================
-- ÍNDICES CRÍTICOS PARA PERFORMANCE ANALÍTICA
-- =============================================================

-- Suscripciones: las queries de MRR siempre filtran por rango de fechas
CREATE INDEX idx_suscripciones_usuario   ON suscripciones(usuario_id);
CREATE INDEX idx_suscripciones_fechas    ON suscripciones(fecha_inicio, fecha_fin);
CREATE INDEX idx_suscripciones_estado    ON suscripciones(estado);

-- Pagos: MRR siempre agrupa por periodo_facturado
CREATE INDEX idx_pagos_periodo           ON pagos(periodo_facturado);
CREATE INDEX idx_pagos_usuario           ON pagos(usuario_id);
CREATE INDEX idx_pagos_estado            ON pagos(estado);

-- Usuarios: filtros habituales en análisis de cohortes
CREATE INDEX idx_usuarios_plan           ON usuarios(plan_actual);
CREATE INDEX idx_usuarios_canal          ON usuarios(canal_adquisicion);
CREATE INDEX idx_usuarios_registro       ON usuarios(fecha_registro);

-- Eventos: siempre se filtra por usuario y por fecha
CREATE INDEX idx_eventos_usuario_fecha   ON eventos_uso(usuario_id, fecha_evento);
CREATE INDEX idx_eventos_tipo            ON eventos_uso(tipo_evento);
-- Índice parcial: transcripciones específicamente (el evento más frecuente)
CREATE INDEX idx_eventos_transcripciones ON eventos_uso(usuario_id, fecha_evento)
    WHERE tipo_evento = 'transcripcion';
