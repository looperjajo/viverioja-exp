-- =============================================================
-- ViveRioja Experience S.L. — Schema Relacional
-- Base de datos: PostgreSQL 15+
-- Autor: TFG Portfolio — Database Design
-- Fecha: 2025
-- =============================================================
-- DECISIÓN: Usamos SERIAL (autoincremento) para PKs en lugar de UUID.
-- Para un sistema interno y académico, INTEGER es más legible en queries
-- y más eficiente en JOINs. UUID sería mejor si expusiéramos una API pública
-- y quisiéramos evitar enumeration attacks.
-- =============================================================

-- Limpia si ya existe (útil en desarrollo)
DROP TABLE IF EXISTS resenas          CASCADE;
DROP TABLE IF EXISTS pagos            CASCADE;
DROP TABLE IF EXISTS reservas         CASCADE;
DROP TABLE IF EXISTS empleados        CASCADE;
DROP TABLE IF EXISTS experiencia_bodega CASCADE;
DROP TABLE IF EXISTS experiencias     CASCADE;
DROP TABLE IF EXISTS bodegas          CASCADE;
DROP TABLE IF EXISTS clientes         CASCADE;


-- =============================================================
-- TABLA 1: CLIENTES
-- Entidad central. Representa a cada persona que interactúa
-- con ViveRioja como comprador o potencial comprador.
-- DECISIÓN: email UNIQUE — un cliente = un email. Así evitamos
-- duplicados y usamos email como identificador de negocio.
-- DECISIÓN: canal_adquisicion con CHECK permite análisis de
-- marketing (¿de dónde vienen los clientes?) sin tabla auxiliar.
-- Para un sistema en producción con muchos canales, sí haría
-- una tabla lookup_canales normalizada.
-- =============================================================
CREATE TABLE clientes (
    id                  SERIAL PRIMARY KEY,
    nombre              VARCHAR(100)  NOT NULL,
    apellidos           VARCHAR(150)  NOT NULL,
    email               VARCHAR(255)  NOT NULL UNIQUE,
    telefono            VARCHAR(20),
    fecha_nacimiento    DATE,
    nacionalidad        CHAR(2)       DEFAULT 'ES',  -- ISO 3166-1 alpha-2
    ciudad              VARCHAR(100),
    pais                VARCHAR(100)  DEFAULT 'España',
    canal_adquisicion   VARCHAR(50)   CHECK (canal_adquisicion IN (
                            'web','redes_sociales','agencia',
                            'referido','qr_promo','feria','otro')),
    fecha_registro      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    activo              BOOLEAN       NOT NULL DEFAULT TRUE,
    -- DECISIÓN: audit trail mínimo. En producción añadiría
    -- created_by, updated_at con trigger.
    CONSTRAINT chk_email_formato CHECK (email LIKE '%@%.%')
);

COMMENT ON TABLE  clientes IS 'Clientes registrados de ViveRioja Experience S.L.';
COMMENT ON COLUMN clientes.canal_adquisicion IS 'Canal por el que llegó el cliente por primera vez';
COMMENT ON COLUMN clientes.nacionalidad IS 'Código ISO 3166-1 alpha-2 (ES, FR, DE, GB...)';


-- =============================================================
-- TABLA 2: BODEGAS
-- Partners comerciales de ViveRioja. Pueden ser bodegas,
-- restaurantes, hoteles o una combinación.
-- DECISIÓN: El tipo distingue la naturaleza del partner porque
-- afecta a qué tipo de experiencias pueden hospedar.
-- DECISIÓN: denominacion_origen como VARCHAR y no FK a tabla
-- DO porque en La Rioja las DOs son pocas y estables. Si
-- gestionáramos múltiples regiones vitivinícolas, haría tabla.
-- =============================================================
CREATE TABLE bodegas (
    id                  SERIAL PRIMARY KEY,
    nombre              VARCHAR(200)  NOT NULL,
    tipo                VARCHAR(50)   NOT NULL CHECK (tipo IN (
                            'bodega','restaurante','hotel',
                            'bodega_hotel','bodega_restaurante')),
    localidad           VARCHAR(100)  NOT NULL,
    provincia           VARCHAR(50)   DEFAULT 'La Rioja',
    denominacion_origen VARCHAR(100),
    año_fundacion       SMALLINT,
    descripcion         TEXT,
    web                 VARCHAR(255),
    capacidad_max       SMALLINT,     -- personas máx en visita
    activa              BOOLEAN       NOT NULL DEFAULT TRUE
);

COMMENT ON TABLE  bodegas IS 'Partners y bodegas colaboradoras en las experiencias';
COMMENT ON COLUMN bodegas.tipo IS 'Clasifica qué servicios puede prestar el partner';


-- =============================================================
-- TABLA 3: EXPERIENCIAS
-- El catálogo de productos de ViveRioja.
-- DECISIÓN: tier como VARCHAR con CHECK en lugar de tabla
-- lookup porque son exactamente 3 valores fijos del modelo
-- de negocio. Si añadieran tiers, cambio el CHECK.
-- DECISIÓN: precio_base + precio_max permite modelar el rango
-- de "personalizada". Para estándar precio_base = precio_max.
-- DECISIÓN: slug UNIQUE para URLs limpias en la web.
-- DECISIÓN: aforo_min/max en la experiencia, NO en la reserva,
-- porque son restricciones del producto, no de cada booking.
-- =============================================================
CREATE TABLE experiencias (
    id                  SERIAL PRIMARY KEY,
    nombre              VARCHAR(200)  NOT NULL,
    slug                VARCHAR(200)  UNIQUE,
    tier                VARCHAR(20)   NOT NULL CHECK (tier IN (
                            'estandar','personalizada','premium')),
    categoria           VARCHAR(50)   CHECK (categoria IN (
                            'enoturismo','gastronomia','cultural',
                            'aventura','spa','maridaje','combinada')),
    descripcion         TEXT,
    precio_base         NUMERIC(10,2) NOT NULL CHECK (precio_base > 0),
    precio_max          NUMERIC(10,2),
    duracion_horas      NUMERIC(4,1),
    aforo_min           SMALLINT      DEFAULT 1 CHECK (aforo_min >= 1),
    aforo_max           SMALLINT,
    incluye_transporte  BOOLEAN       DEFAULT FALSE,
    incluye_manutension BOOLEAN       DEFAULT FALSE,
    activa              BOOLEAN       NOT NULL DEFAULT TRUE,
    fecha_alta          DATE          NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT chk_precio_rango CHECK (
        precio_max IS NULL OR precio_max >= precio_base
    ),
    CONSTRAINT chk_aforo CHECK (
        aforo_max IS NULL OR aforo_max >= aforo_min
    )
);

COMMENT ON TABLE  experiencias IS 'Catálogo de experiencias enoturísticas ofertadas';
COMMENT ON COLUMN experiencias.precio_base IS 'Precio por persona (mínimo para personalizada)';
COMMENT ON COLUMN experiencias.precio_max  IS 'Precio máximo por persona (para personalizada/premium)';


-- =============================================================
-- TABLA 4: EXPERIENCIA_BODEGA (tabla de unión M:N)
-- Una experiencia puede involucrar varias bodegas y una bodega
-- puede participar en varias experiencias.
-- DECISIÓN: PK compuesta (experiencia_id, bodega_id) —
-- no necesito un id surrogate porque la combinación ya es única
-- y representa exactamente la relación.
-- DECISIÓN: rol permite saber si la bodega es la anfitriona
-- principal o sólo colabora (p.ej. transporte, maridaje).
-- =============================================================
CREATE TABLE experiencia_bodega (
    experiencia_id  INT  NOT NULL REFERENCES experiencias(id) ON DELETE CASCADE,
    bodega_id       INT  NOT NULL REFERENCES bodegas(id)      ON DELETE CASCADE,
    rol             VARCHAR(50) NOT NULL DEFAULT 'principal'
                    CHECK (rol IN ('principal','colaboradora','proveedor')),
    PRIMARY KEY (experiencia_id, bodega_id)
);

COMMENT ON TABLE experiencia_bodega IS 'Relación M:N entre experiencias y bodegas partner';


-- =============================================================
-- TABLA 5: EMPLEADOS
-- Personal interno de ViveRioja que gestiona y guía reservas.
-- DECISIÓN: idiomas como VARCHAR('es,en,fr') denormalizado.
-- Podría normalizarse en empleado_idioma, pero para este scope
-- es sobreingenieería. Un analista simplemente hace LIKE '%en%'.
-- DECISIÓN: lo mantengo separado de clientes aunque comparten
-- nombre/email porque su ciclo de vida es completamente distinto.
-- =============================================================
CREATE TABLE empleados (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    apellidos   VARCHAR(150) NOT NULL,
    email       VARCHAR(255) UNIQUE,
    rol         VARCHAR(50)  CHECK (rol IN (
                    'guia','sommelier','recepcionista',
                    'gestor','director')),
    idiomas     VARCHAR(100),    -- 'es,en,fr'
    fecha_alta  DATE         NOT NULL DEFAULT CURRENT_DATE,
    activo      BOOLEAN      NOT NULL DEFAULT TRUE
);

COMMENT ON TABLE empleados IS 'Personal de ViveRioja Experience S.L.';


-- =============================================================
-- TABLA 6: RESERVAS
-- Núcleo transaccional del sistema. Registra cada booking.
-- DECISIÓN: precio_unitario desnormalizado (copiado desde
-- experiencias en el momento de la reserva). Esto es CRÍTICO:
-- si el precio de la experiencia cambia después, la reserva
-- debe conservar el precio que el cliente vio. Es una snapshot.
-- DECISIÓN: descuento_pct permite aplicar el promo QR (15%)
-- y otros descuentos futuros sin alterar precio_unitario.
-- precio_total = precio_unitario * num_personas * (1 - descuento_pct/100)
-- DECISIÓN: estado con CHECK enumera el ciclo de vida del booking.
-- =============================================================
CREATE TABLE reservas (
    id                  SERIAL PRIMARY KEY,
    cliente_id          INT           NOT NULL REFERENCES clientes(id),
    experiencia_id      INT           NOT NULL REFERENCES experiencias(id),
    empleado_id         INT           REFERENCES empleados(id),
    fecha_reserva       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    fecha_experiencia   DATE          NOT NULL,
    hora_inicio         TIME,
    num_personas        SMALLINT      NOT NULL CHECK (num_personas >= 1),
    precio_unitario     NUMERIC(10,2) NOT NULL,
    descuento_pct       NUMERIC(5,2)  NOT NULL DEFAULT 0
                        CHECK (descuento_pct BETWEEN 0 AND 100),
    precio_total        NUMERIC(10,2) NOT NULL,
    canal_reserva       VARCHAR(50)   CHECK (canal_reserva IN (
                            'web','telefono','agencia',
                            'qr_promo','presencial')),
    codigo_promo        VARCHAR(50),
    estado              VARCHAR(30)   NOT NULL DEFAULT 'pendiente'
                        CHECK (estado IN (
                            'pendiente','confirmada',
                            'completada','cancelada','no_show')),
    notas               TEXT,
    fecha_actualizacion TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_fecha_experiencia CHECK (
        fecha_experiencia >= fecha_reserva::DATE
    )
);

COMMENT ON TABLE  reservas IS 'Reservas de experiencias — tabla transaccional central';
COMMENT ON COLUMN reservas.precio_unitario IS 'Precio por persona en el momento de la reserva (snapshot)';
COMMENT ON COLUMN reservas.descuento_pct   IS 'Porcentaje de descuento aplicado (0 = sin descuento)';
COMMENT ON COLUMN reservas.precio_total    IS 'precio_unitario × num_personas × (1 - descuento_pct/100)';


-- =============================================================
-- TABLA 7: PAGOS
-- Registros financieros asociados a cada reserva.
-- DECISIÓN: una reserva puede tener MÚLTIPLES pagos. Esto es
-- realista: pago parcial (señal 30%) + pago del resto, o un
-- pago completado + reembolso parcial son dos filas en pagos.
-- DECISIÓN: referencia_externa guarda el ID de Stripe/PayPal
-- para trazabilidad con la pasarela de pago externa.
-- DECISIÓN: estado en pagos es independiente del estado en
-- reservas. Una reserva 'confirmada' puede tener pago
-- 'reembolsado' si hubo devolución parcial.
-- =============================================================
CREATE TABLE pagos (
    id                  SERIAL PRIMARY KEY,
    reserva_id          INT           NOT NULL REFERENCES reservas(id),
    fecha_pago          TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    importe             NUMERIC(10,2) NOT NULL,
    metodo_pago         VARCHAR(50)   CHECK (metodo_pago IN (
                            'tarjeta','transferencia','efectivo',
                            'paypal','bizum','voucher')),
    estado              VARCHAR(30)   NOT NULL DEFAULT 'pendiente'
                        CHECK (estado IN (
                            'pendiente','completado','fallido','reembolsado')),
    referencia_externa  VARCHAR(100),
    notas               TEXT
);

COMMENT ON TABLE  pagos IS 'Registros de pago — una reserva puede tener múltiples pagos';
COMMENT ON COLUMN pagos.referencia_externa IS 'ID de la transacción en pasarela (Stripe, PayPal...)';


-- =============================================================
-- TABLA 8: RESEÑAS
-- Valoraciones post-experiencia de los clientes.
-- DECISIÓN: reserva_id UNIQUE — máximo 1 reseña por reserva.
-- Así evitamos spam y garantizamos que solo clientes reales
-- que hicieron la experiencia pueden valorar.
-- DECISIÓN: publicada = FALSE por defecto — moderación manual
-- antes de mostrar en la web (evita contenido inapropiado).
-- DECISIÓN: respuesta_empresa TEXT permite al equipo responder
-- públicamente, como en TripAdvisor/Google Reviews.
-- =============================================================
CREATE TABLE resenas (
    id                  SERIAL PRIMARY KEY,
    reserva_id          INT       NOT NULL UNIQUE REFERENCES reservas(id),
    cliente_id          INT       NOT NULL REFERENCES clientes(id),
    puntuacion          SMALLINT  NOT NULL CHECK (puntuacion BETWEEN 1 AND 5),
    comentario          TEXT,
    fecha_resena        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    publicada           BOOLEAN   NOT NULL DEFAULT FALSE,
    respuesta_empresa   TEXT
);

COMMENT ON TABLE  resenas IS 'Valoraciones de clientes post-experiencia — máximo 1 por reserva';
COMMENT ON COLUMN resenas.publicada IS 'FALSE = pendiente de moderación. Solo se muestran las TRUE';


-- =============================================================
-- ÍNDICES DE RENDIMIENTO
-- DECISIÓN: crear índices sobre las columnas más usadas en
-- WHERE, JOIN y ORDER BY. Sin índices, queries sobre reservas
-- (tabla más grande) harían full table scan.
-- =============================================================
CREATE INDEX idx_reservas_cliente      ON reservas(cliente_id);
CREATE INDEX idx_reservas_experiencia  ON reservas(experiencia_id);
CREATE INDEX idx_reservas_fecha_exp    ON reservas(fecha_experiencia);
CREATE INDEX idx_reservas_estado       ON reservas(estado);
CREATE INDEX idx_pagos_reserva         ON pagos(reserva_id);
CREATE INDEX idx_pagos_estado          ON pagos(estado);
CREATE INDEX idx_resenas_cliente       ON resenas(cliente_id);
CREATE INDEX idx_clientes_email        ON clientes(email);  -- ya tiene UNIQUE pero explicitamos

-- Índice compuesto para queries de ingresos por periodo
CREATE INDEX idx_reservas_fecha_estado ON reservas(fecha_experiencia, estado);
