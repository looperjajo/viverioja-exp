# ViveRioja Experience — Dashboard Power BI
## Guía completa paso a paso

---

## PASO 0 — Conectar PostgreSQL a Power BI Desktop

**Prerequisito:** Tener instalado el driver ODBC de PostgreSQL
(descarga: postgresql.org/ftp/odbc/versions/)

1. Abre Power BI Desktop → **Obtener datos** → **Base de datos PostgreSQL**
2. Servidor: `localhost` | Base de datos: `viverioja` (o el nombre que uses)
3. Selecciona todas las tablas: `clientes`, `reservas`, `experiencias`,
   `bodegas`, `pagos`, `resenas`, `experiencia_bodega`, `empleados`
4. Clic en **Transformar datos** → se abre Power Query Editor

**En Power Query, verifica:**
- `reservas.fecha_experiencia` → tipo Fecha
- `pagos.fecha_pago` → tipo Fecha/Hora
- `reservas.precio_total`, `pagos.importe` → tipo Número decimal
- `reservas.descuento_pct` → tipo Número decimal

---

## PASO 1 — Modelo de datos (relaciones)

Antes de crear ningún visual, define las relaciones.
Ve a la vista **Modelo** (icono del diagrama, barra izquierda).

### Relaciones a crear (arrastra campos):

| Tabla origen    | Campo          | → | Tabla destino   | Campo          | Cardinalidad |
|-----------------|----------------|---|-----------------|----------------|-------------|
| reservas        | cliente_id     | → | clientes        | id             | N:1         |
| reservas        | experiencia_id | → | experiencias    | id             | N:1         |
| reservas        | id             | → | pagos           | reserva_id     | 1:N         |
| reservas        | id             | → | resenas         | reserva_id     | 1:N         |
| experiencia_bodega | experiencia_id | → | experiencias | id          | N:1         |
| experiencia_bodega | bodega_id   | → | bodegas         | id             | N:1         |

**Por qué este modelo:**
Las reservas son el centro del esquema (tabla de hechos en términos BI).
Clientes, experiencias y bodegas son dimensiones. Pagos y reseñas
son tablas de hechos secundarias relacionadas vía reservas.
Este patrón se llama **Esquema estrella** — es el estándar en Data Warehousing.

---

## PASO 2 — Tabla de fechas (OBLIGATORIA en Power BI)

Power BI necesita una tabla de fechas independiente para que la
inteligencia de tiempo DAX (YTD, MTD, mismo periodo año anterior)
funcione correctamente.

En **Modelado** → **Nueva tabla:**

```dax
Dim_Fecha =
ADDCOLUMNS(
    CALENDAR(DATE(2022,1,1), DATE(2026,12,31)),
    "Año",          YEAR([Date]),
    "Mes Num",      MONTH([Date]),
    "Mes Nombre",   FORMAT([Date], "MMMM", "es-ES"),
    "Mes Corto",    FORMAT([Date], "MMM", "es-ES"),
    "Trimestre",    "T" & QUARTER([Date]),
    "Año-Mes",      FORMAT([Date], "YYYY-MM"),
    "Semana",       WEEKNUM([Date]),
    "Día Semana",   FORMAT([Date], "dddd", "es-ES"),
    "Es Fin Semana", IF(WEEKDAY([Date],2) >= 6, TRUE, FALSE)
)
```

Después crea la relación:
`Dim_Fecha[Date]` → `reservas[fecha_experiencia]` (N:1, dirección única)

Marca la tabla como **Tabla de fechas** (clic derecho → Marcar como tabla de fechas → campo Date).

---

## PASO 3 — Medidas DAX esenciales

Crea una tabla vacía llamada `_Medidas` (Modelado → Nueva tabla → `_Medidas = {""}`).
Agrupa ahí todas tus medidas. Es una buena práctica de organización.

### 3.1 — Medidas de ingresos

```dax
-- Ingresos totales (solo pagos completados de reservas completadas)
Ingresos Totales =
CALCULATE(
    SUM(pagos[importe]),
    pagos[estado] = "completado",
    RELATEDTABLE(reservas),
    reservas[estado] = "completada"
)
```
> CALCULATE modifica el contexto de filtro. Aquí fuerza dos condiciones
> simultáneas. RELATEDTABLE navega la relación reservas→pagos.

```dax
-- Ingresos del mes en curso
Ingresos Mes Actual =
CALCULATE(
    [Ingresos Totales],
    DATESMTD(Dim_Fecha[Date])
)
```
> DATESMTD = Dates Month To Date. Devuelve todas las fechas desde
> el inicio del mes hasta hoy. Requiere tabla de fechas marcada.

```dax
-- Ingresos mismo mes año anterior (para comparación YoY)
Ingresos Mismo Mes Año Ant =
CALCULATE(
    [Ingresos Totales],
    DATEADD(Dim_Fecha[Date], -1, YEAR)
)
```

```dax
-- Crecimiento interanual (%)
Crecimiento YoY % =
VAR ingresos_actual   = [Ingresos Totales]
VAR ingresos_anterior = [Ingresos Mismo Mes Año Ant]
RETURN
    IF(
        ingresos_anterior = 0 || ISBLANK(ingresos_anterior),
        BLANK(),
        DIVIDE(ingresos_actual - ingresos_anterior, ingresos_anterior)
    )
```
> VAR declara variables locales — hace el código más legible y eficiente
> (cada expresión se evalúa una sola vez). DIVIDE evita división por cero.

---

### 3.2 — Medidas de reservas

```dax
-- Número de reservas completadas
Reservas Completadas =
CALCULATE(
    COUNTROWS(reservas),
    reservas[estado] = "completada"
)
```

```dax
-- Reservas mes actual
Reservas Mes Actual =
CALCULATE(
    [Reservas Completadas],
    DATESMTD(Dim_Fecha[Date])
)
```

```dax
-- Ticket medio por reserva
Ticket Medio =
DIVIDE(
    [Ingresos Totales],
    [Reservas Completadas]
)
```

```dax
-- Tasa de cancelación (%)
Tasa Cancelacion % =
VAR canceladas = CALCULATE(COUNTROWS(reservas), reservas[estado] = "cancelada")
VAR total_cerradas =
    CALCULATE(
        COUNTROWS(reservas),
        reservas[estado] IN {"completada","cancelada","no_show"}
    )
RETURN DIVIDE(canceladas, total_cerradas)
```

---

### 3.3 — Medidas de clientes y LTV

```dax
-- Clientes únicos con al menos 1 reserva completada
Clientes Activos =
CALCULATE(
    DISTINCTCOUNT(reservas[cliente_id]),
    reservas[estado] = "completada"
)
```

```dax
-- LTV por cliente (para visual Top 5)
LTV Cliente =
CALCULATE(
    SUM(reservas[precio_total]),
    reservas[estado] = "completada"
)
```

```dax
-- Número de reservas por cliente (para segmentación)
Reservas por Cliente =
DIVIDE([Reservas Completadas], [Clientes Activos])
```

---

### 3.4 — Medidas para KPI cards

```dax
-- Experiencia más vendida (nombre del top 1)
Exp Mas Vendida =
CALCULATE(
    FIRSTNONBLANK(experiencias[nombre], 1),
    TOPN(
        1,
        SUMMARIZE(reservas, experiencias[nombre], "total", [Reservas Completadas]),
        [total], DESC
    )
)
```

```dax
-- Bodega con más participación
Bodega Top =
CALCULATE(
    FIRSTNONBLANK(bodegas[nombre], 1),
    TOPN(
        1,
        SUMMARIZE(
            experiencia_bodega,
            bodegas[nombre],
            "total", CALCULATE([Reservas Completadas])
        ),
        [total], DESC
    )
)
```

---

## PASO 4 — Construir los visuales

### 4.1 — KPI Cards (banda superior)

Crea 5 tarjetas en fila usando **Objeto visual: Tarjeta** (Card).

| Tarjeta | Medida | Formato |
|---------|--------|---------|
| Ingresos Totales | `[Ingresos Totales]` | € #,##0.00 |
| Reservas del Mes | `[Reservas Mes Actual]` | Número entero |
| Ticket Medio | `[Ticket Medio]` | € #,##0.00 |
| Exp. Más Vendida | `[Exp Mas Vendida]` | Texto |
| Bodega Top | `[Bodega Top]` | Texto |

**Tip de diseño:** Añade un subtítulo a cada tarjeta con el delta respecto
al mes anterior. Usa **KPI visual** en lugar de Card simple si quieres
mostrar el objetivo vs actual con flecha de tendencia.

---

### 4.2 — Gráfico de ingresos mensuales (línea temporal)

**Visual:** Gráfico de líneas (Line chart)

**¿Por qué línea?** Porque mostramos una evolución continua en el tiempo.
El gráfico de barras es mejor para comparar categorías discretas;
la línea es mejor para tendencias temporales.

**Configuración:**
- **Eje X:** `Dim_Fecha[Año-Mes]` (o `Dim_Fecha[Date]` con jerarquía)
- **Eje Y:** `[Ingresos Totales]`
- **Leyenda:** `experiencias[tier]` (para ver las 3 líneas por tier)
- **Información sobre herramientas:** añade `[Reservas Completadas]` y `[Ticket Medio]`

**Medida de línea de referencia (objetivo mensual):**
```dax
Objetivo Mensual = 3000  -- ajusta según tu objetivo
```
Añádela como línea de referencia constante en el gráfico (Analytics → Línea constante).

---

### 4.3 — Distribución por tier (donut)

**Visual:** Gráfico de anillos (Donut chart)

**¿Por qué donut y no pastel?** El donut permite mostrar un KPI
en el centro (el total). Es más moderno y el agujero central
reduce el efecto de distorsión visual del ángulo en los sectores.

**Configuración:**
- **Leyenda:** `experiencias[tier]`
- **Valores:** `[Reservas Completadas]`
- **Centro del anillo:** añade `[Ingresos Totales]` como etiqueta de detalle

**Colores por tier (para coherencia con la web):**
- Estándar → `#C8A96E` (dorado suave)
- Personalizada → `#9f4040` (rojo vino — brand color)
- Premium → `#2C1810` (marrón oscuro)

**Medida para etiquetas %:**
```dax
% Reservas Tier =
DIVIDE(
    [Reservas Completadas],
    CALCULATE([Reservas Completadas], ALL(experiencias[tier]))
)
```
Formato: `0.0%`

---

### 4.4 — Top 5 clientes por LTV

**Visual:** Gráfico de barras horizontales (Bar chart — Clustered bar)

**¿Por qué horizontal?** Los nombres de clientes son textos largos.
Las barras horizontales permiten leerlos sin rotar el eje.
Además, el ranking de mayor a menor es más natural de arriba a abajo.

**Configuración:**
- **Eje Y (categorías):** `clientes[nombre] & " " & clientes[apellidos]`
  (crea una columna calculada: `Nombre Completo = clientes[nombre] & " " & clientes[apellidos]`)
- **Eje X (valores):** `[LTV Cliente]`
- **Pequeños múltiplos:** opcional — divide por `clientes[nacionalidad]`
- **Filtro del visual:** Primeros N = 5 por `[LTV Cliente]`
  (Filtros → Este objeto visual → Top N → 5 → por [LTV Cliente])

**Columna calculada adicional (para tooltip):**
```dax
Num Reservas Cliente =
CALCULATE(
    COUNTROWS(reservas),
    reservas[estado] = "completada"
)
```

---

### 4.5 — Mapa de origen de clientes

**Visual:** Mapa de formas (Shape map) o Mapa de burbujas (Map visual)

**Opción A — Por país (internacional):** Usa **Map visual**
- **Ubicación:** `clientes[pais]`
- **Tamaño de burbuja:** `[Clientes Activos]`
- **Información sobre herramientas:** `[LTV Cliente]`, `[Ticket Medio]`

**Opción B — Por provincia España (doméstico):** Usa **Shape map**
- Necesitas el JSON de provincias españolas
  (descarga: github.com/codeforgermany/click_that_hood/blob/main/public/data/spain-provinces.geojson)
- **Ubicación:** `clientes[ciudad]`
- **Valores de color:** `[Clientes Activos]` (escala de calor)

**Columna calculada para estandarizar países:**
```dax
Pais Agrupado =
SWITCH(
    clientes[pais],
    "España",      "España",
    "Francia",     "Francia",
    "Alemania",    "Alemania",
    "Reino Unido", "Reino Unido",
    "Italia",      "Italia",
    "Japón",       "Asia",
    "Brasil",      "América",
    "EEUU",        "América",
    "Otro"
)
```

---

### 4.6 — Filtros interactivos (Segmentadores)

Añade 3 segmentadores (Slicer) en el panel lateral:

**Slicer 1 — Rango de fechas:**
- Campo: `Dim_Fecha[Date]`
- Estilo: Entre (Between) — muestra selector de fecha de inicio/fin
- Ubicación: parte superior del panel de filtros

**Slicer 2 — Tier:**
- Campo: `experiencias[tier]`
- Estilo: Lista vertical con checkboxes
- Selección múltiple activada

**Slicer 3 — Bodega:**
- Campo: `bodegas[nombre]`
- Estilo: Lista desplegable (Dropdown) — ahorra espacio
- Incluye opción "Todas"

**Para que los slicers afecten a todos los visuales:**
Ve a **Ver → Interacciones de objeto visual** y asegúrate de que
cada slicer tiene flecha de filtro activada sobre cada visual.

---

## PASO 5 — Layout y diseño del dashboard

### Estructura recomendada (1920×1080 o 1366×768)

```
┌─────────────────────────────────────────────────────────────┐
│  LOGO ViveRioja    │  TÍTULO: Dashboard Ejecutivo           │
│  color #9f4040     │  Subtítulo: Temporada 2023-2025        │
├──────────┬──────────┬──────────┬──────────┬────────────────┤
│ KPI:     │ KPI:     │ KPI:     │ KPI:     │ KPI:           │
│ Ingresos │Reservas  │  Ticket  │Exp. top  │Bodega top      │
│ Totales  │  Mes     │  Medio   │          │                │
├──────────────────────────────┬──────────────────────────────┤
│                              │                              │
│   LÍNEA: Ingresos mensuales  │   DONUT: Reservas por tier   │
│   (con leyenda por tier)     │   (con total en centro)      │
│                              │                              │
├──────────────────────────────┼──────────────────────────────┤
│                              │                              │
│   BARRAS H: Top 5 LTV        │   MAPA: Origen clientes      │
│   Clientes                   │                              │
│                              │                              │
└──────────────────────────────┴──────────────────────────────┘
│  SLICERS: [Fecha: desde-hasta]  [Tier: ▼]  [Bodega: ▼]     │
└─────────────────────────────────────────────────────────────┘
```

### Paleta de colores corporativa:
- Fondo: `#FAF8F5` (blanco cálido)
- Tarjetas: `#FFFFFF` con sombra suave
- Acento principal: `#9f4040` (rojo vino)
- Acento secundario: `#C8A96E` (dorado)
- Texto: `#1A1A1A`
- Texto secundario: `#6B7280`

### Fuentes:
- Títulos: Playfair Display (o Georgia como fallback en Power BI)
- Cuerpo: Segoe UI (nativa de Power BI)

---

## PASO 6 — Exportar para portfolio

### Opción A — PDF estático (presentación)
**Archivo → Exportar → Exportar a PDF**
- Exporta cada página del informe como una página PDF
- Ideal para adjuntar en CV o LinkedIn
- **Límite:** No es interactivo

### Opción B — Publicar en Power BI Service (RECOMENDADO)
1. Crea cuenta gratuita en app.powerbi.com (requiere email corporativo o educativo)
2. En Power BI Desktop: **Inicio → Publicar → Mi área de trabajo**
3. El dashboard queda accesible con URL pública
4. Comparte el link en tu CV, LinkedIn y portfolio web

**Para portfolio como Data Analyst junior, el link en Power BI Service
es lo más impactante** — el reclutador puede interactuar con el dashboard en vivo.

### Opción C — Imagen estática para web/portfolio
**Archivo → Exportar → Exportar a PowerPoint**
Cada visual queda como imagen de alta resolución en una diapositiva.
Luego screenshot y a tu portfolio web.

### Opción D — Embed en portfolio web
Si tienes cuenta Power BI Service:
1. Dashboard publicado → **Archivo → Insertar informe → Sitio web o portal**
2. Copia el código iframe
3. Pégalo en tu portfolio HTML

```html
<!-- Ejemplo de embed en tu portfolio -->
<iframe
  title="ViveRioja Dashboard"
  width="100%"
  height="600"
  src="TU_URL_EMBED_POWERBI"
  frameborder="0"
  allowFullScreen="true">
</iframe>
```

---

## PASO 7 — Lo que explicas en entrevista

### "¿Por qué elegiste ese modelo de datos?"
> "Usé un esquema estrella con reservas como tabla de hechos y clientes,
> experiencias y bodegas como dimensiones. Añadí una Dim_Fecha independiente
> para habilitar la inteligencia de tiempo de DAX, que es requisito para
> funciones como DATESMTD o DATEADD."

### "¿Cuál fue el mayor reto técnico?"
> "La relación entre bodegas y experiencias es M:N a través de experiencia_bodega.
> Power BI no permite relaciones M:N directas con buena performance, así que
> mantuve la tabla puente y navego las relaciones con RELATEDTABLE en DAX."

### "¿Qué medida DAX te parece más útil?"
> "La de Crecimiento YoY con DATEADD. Permite al negocio saber en cada punto
> si están creciendo respecto al mismo periodo del año anterior, que es
> la comparación más accionable para una empresa estacional como el enoturismo."

### "¿Cómo está estructurado el dashboard?"
> "Sigue el patrón de pirámide de información: KPIs ejecutivos en la parte
> superior (responden '¿cómo estamos?'), análisis de tendencia en el medio
> (responden '¿hacia dónde vamos?') y detalle de cliente/geografía abajo
> (responden '¿quiénes son nuestros mejores clientes?')."
