# ViveRioja Experience — Análisis de Datos en Enoturismo

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-316192?style=flat&logo=postgresql&logoColor=white)
![Python](https://img.shields.io/badge/Python-ETL_Pipeline-3776AB?style=flat&logo=python&logoColor=white)
![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=flat&logo=powerbi&logoColor=black)
![DAX](https://img.shields.io/badge/DAX-Medidas_avanzadas-F2C811?style=flat&logo=powerbi&logoColor=black)
![SQL](https://img.shields.io/badge/SQL-CTEs_%7C_Window_Functions_%7C_RFM-4479A1?style=flat&logo=postgresql&logoColor=white)
![Chart.js](https://img.shields.io/badge/Chart.js-Dashboard_interactivo-FF6384?style=flat&logo=chartdotjs&logoColor=white)
![Status](https://img.shields.io/badge/Estado-Portfolio_activo-9f4040?style=flat)

> Proyecto de análisis de datos completo para una empresa ficticia de enoturismo en La Rioja (España): desde el diseño relacional de la base de datos hasta el dashboard ejecutivo interactivo en Power BI, pasando por segmentación de clientes con modelo RFM.

**[Ver web del proyecto →](https://looperjajo.github.io/viverioja-experience)**

---

## Preguntas de negocio que responde este proyecto

Antes de escribir una sola línea de SQL, me hice las preguntas que haría cualquier analista en una reunión con dirección:

- **¿Qué tier de experiencia genera más revenue?** ¿Conviene seguir apostando por el estándar o escalar el premium?
- **¿Qué clientes tenemos en riesgo de perder?** ¿Cuántos llevan más de un año sin volver y cuánto valen?
- **¿De dónde vienen nuestros mejores clientes?** ¿Por canal de adquisición y por geografía?
- **¿Cuándo es temporada alta y cuándo baja?** ¿El enoturismo riojano es tan estacional como parece?
- **¿Qué bodegas partner generan más actividad?** ¿Qué nos dice eso sobre la negociación de contratos?
- **¿Cuál es la tasa de cancelación real?** No la teórica — la de reservas que cerramos sin completar.
- **¿Están creciendo los ingresos respecto al año pasado?** En el mismo mes, sin el ruido de la estacionalidad.

Cada análisis, cada medida DAX y cada segmento RFM existe para responder una de estas preguntas. No están porque "quedan bien en el portfolio".

---

## Arquitectura del proyecto

```
viverioja-experience/
│
├── database/
│   ├── 01_schema.sql          # Diseño relacional completo (8 tablas)
│   ├── 02_seed.sql            # Datos realistas: 7 bodegas, 12 experiencias, 50+ clientes
│   ├── 03_queries.sql         # 12 queries analíticas con explicación de cada decisión
│   ├── 04_powerbi_guide.md    # Guía paso a paso de conexión y construcción del dashboard
│   └── 05_dax_measures.dax    # 20+ medidas DAX organizadas por grupo funcional
│
├── analytics/
│   ├── rfm_analysis.sql         # Segmentación RFM completa con CTEs encadenadas
│   ├── rfm_insights.md          # Interpretación de negocio y acciones por segmento
│   ├── seasonality_analysis.sql # 8 queries de estacionalidad con decisión de negocio
│   └── seasonality_insights.md  # Análisis narrativo para dirección (sin código)
│
├── etl/
│   ├── pipeline.py              # Orquestador (extract → transform → load → dashboard)
│   ├── extract.py               # Extracción desde PostgreSQL a CSV
│   ├── transform.py             # KPIs mensuales + JSON de estacionalidad
│   ├── load.py                  # Generación de PDF y Excel
│   └── data/ output/            # Datos procesados y reportes generados
│
├── public/dashboard/            # Copiado a dist/ por Astro → servido en /dashboard/
│   ├── index.html               # Dashboard interactivo (Chart.js, sin servidor)
│   └── data/
│       ├── seasonality_data.js  # Datos para file:// (generado por ETL)
│       └── seasonality_data.json # Datos formato estándar (generado por ETL)
│
└── [web/]                       # Sitio desplegado en GitHub Pages
```

### Por qué esquema estrella

El esquema estrella no es una elección estética — es una decisión de rendimiento y claridad analítica.

En un esquema totalmente normalizado (3FN), una query de "ingresos por tier de experiencia" requiere cuatro o cinco JOINs. En un esquema estrella, la tabla de hechos ya tiene las claves foráneas necesarias y los JOINs son directos a las dimensiones. Power BI trabaja especialmente bien con este patrón porque su motor Vertipaq está optimizado para relaciones 1:N simples.

**Tabla de hechos central:** `reservas` — es el evento transaccional del negocio. Cada fila es un booking.

**Dimensiones:**

| Tabla | Rol | Por qué es dimensión |
|---|---|---|
| `clientes` | Dimensión de cliente | Describe quién reserva. Cambia raramente. |
| `experiencias` | Dimensión de producto | Describe qué se compra. Catálogo estable. |
| `bodegas` | Dimensión de partner | Describe dónde se realiza. Estable. |
| `empleados` | Dimensión de personal | Describe quién guía la experiencia. |
| `Dim_Fecha` | Dimensión temporal | Creada en Power BI. Explicación abajo. |

**Tablas de hechos secundarias:** `pagos` y `resenas` están vinculadas a `reservas`, no directamente a las dimensiones. Ambas tienen sus propias métricas (importe cobrado, puntuación) y su propio ciclo de vida.

**La tabla puente `experiencia_bodega`** resuelve la relación M:N entre experiencias y bodegas. Una experiencia puede involucrar varias bodegas (bodega anfitriona + restaurante colaborador), y una bodega puede participar en varias experiencias. Power BI no soporta relaciones M:N con buen rendimiento; mantener la tabla puente y navegar con `RELATEDTABLE` en DAX es la solución correcta.

### Por qué `Dim_Fecha` separada

Las funciones de inteligencia de tiempo de DAX (`DATESMTD`, `DATESYTD`, `DATEADD`, `SAMEPERIODLASTYEAR`) **requieren obligatoriamente una tabla de fechas continua y marcada como tal** en Power BI. Si usas directamente `reservas[fecha_experiencia]`, la inteligencia de tiempo no funciona cuando hay días sin reservas (los huecos rompen la continuidad del calendario).

`Dim_Fecha` cubre de 2022 a 2026, tiene columnas precalculadas (Año, Mes, Trimestre, Día de la semana, Es Fin de Semana) y permite filtrar y agrupar sin depender de las fechas reales de los datos.

---

## KPIs implementados en Power BI

Todos los KPIs están agrupados en una tabla `_Medidas` separada de los datos. Esto es una convención de organización que cualquier analista que abra el archivo agradecerá.

### Ingresos y rentabilidad

**Ingresos Totales**
```dax
Ingresos Totales =
CALCULATE(
    SUM(pagos[importe]),
    pagos[estado] = "completado",
    RELATEDTABLE(reservas),
    reservas[estado] = "completada"
)
```
*Por qué importa:* No sumamos `reservas[precio_total]` directamente. Una reserva completada puede tener un pago reembolsado. La tabla `pagos` es la fuente de verdad financiera. Si confundiéramos las dos, estaríamos reportando revenue que no está en la cuenta bancaria.

---

**Ingresos Mes Actual**
```dax
Ingresos Mes Actual =
CALCULATE(
    [Ingresos Totales],
    DATESMTD(Dim_Fecha[Date])
)
```
*Por qué importa:* Permite al equipo comercial ver en cualquier momento del mes cuánto llevan acumulado. Combinado con `[Objetivo Mensual]`, genera la tarjeta de seguimiento del presupuesto.

---

**Crecimiento YoY %**
```dax
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
*Por qué importa:* Es la comparación más honesta en un negocio estacional. Comparar octubre de este año con septiembre no tiene sentido en enoturismo — la vendimia infla octubre. Comparar octubre con el octubre anterior sí es accionable. El `BLANK()` es deliberado: si no hay datos del año anterior, mejor no mostrar nada que mostrar un número engañoso.

---

### Operaciones y conversión

**Tasa Cancelación %**
```dax
Tasa Cancelacion % =
VAR canceladas =
    CALCULATE(COUNTROWS(reservas), reservas[estado] = "cancelada")
VAR total_cerradas =
    CALCULATE(
        COUNTROWS(reservas),
        reservas[estado] IN {"completada","cancelada","no_show"}
    )
RETURN DIVIDE(canceladas, total_cerradas)
```
*Por qué importa:* El denominador excluye las reservas `pendiente` y `confirmada` porque aún pueden completarse. Si las incluyéramos, la tasa de cancelación parecería artificialmente baja al inicio del mes. Este KPI mide solo los ciclos de vida ya cerrados.

---

**Ticket Medio**
```dax
Ticket Medio = DIVIDE([Ingresos Totales], [Reservas Completadas])
```
*Por qué importa:* En enoturismo el ticket medio varía mucho por tier (estándar vs. premium pueden tener un factor 5x). Este KPI segmentado por tier es más útil que el global, pero el global sirve para el headline del dashboard ejecutivo.

---

### Clientes y fidelización

**Clientes Activos**
```dax
Clientes Activos =
CALCULATE(
    DISTINCTCOUNT(reservas[cliente_id]),
    reservas[estado] = "completada"
)
```
*Por qué importa:* Cuenta clientes únicos con al menos una compra real completada. No cuenta leads, no cuenta cancelados, no duplica clientes con varias reservas.

---

**LTV Cliente** *(Lifetime Value)*
```dax
LTV Cliente =
CALCULATE(
    SUM(reservas[precio_total]),
    reservas[estado] = "completada"
)
```
*Por qué importa:* En el visual Top 5 del dashboard, este KPI identifica los clientes que más revenue han generado históricamente. Son los candidatos prioritarios para programas de fidelización y acceso anticipado a experiencias premium.

---

**Tasa de Retención %**
```dax
Tasa Retencion % = DIVIDE([Clientes Recurrentes], [Clientes Activos])
```
*Por qué importa:* Adquirir un nuevo cliente en enoturismo (marketing, agencias, ferias) cuesta entre 5 y 7 veces más que retener uno existente. Esta tasa mide qué porcentaje de la base repite. Si cae, es una señal de alerta antes de que lo veamos en los ingresos.

---

**NPS Proxy**
```dax
NPS Proxy =
VAR promotores  = CALCULATE(COUNTROWS(resenas), resenas[puntuacion] >= 4, resenas[publicada] = TRUE)
VAR detractores = CALCULATE(COUNTROWS(resenas), resenas[puntuacion] <= 2, resenas[publicada] = TRUE)
VAR total       = CALCULATE(COUNTROWS(resenas), resenas[publicada] = TRUE)
RETURN DIVIDE(promotores - detractores, total) * 100
```
*Por qué importa:* No tenemos escala 0-10 (NPS estándar), pero tenemos reseñas de 1 a 5. La adaptación — promotores (4-5) menos detractores (1-2) dividido entre total — da una señal direccional válida de satisfacción. Cuenta solo reseñas publicadas (moderadas por el equipo).

---

## Análisis de Estacionalidad — Dashboard Interactivo

### Qué pregunta de negocio responde

¿Cuándo es el momento del año más rentable y por qué? ¿Qué días de la semana concentran más reservas? ¿Cómo se comporta cada tier de producto según la temporada? ¿Está creciendo el negocio año a año descontando el efecto estacional?

El enoturismo riojano es radicalmente estacional. Septiembre y octubre (vendimia) pueden generar el 42% de los ingresos anuales. Sin visualizar ese patrón con claridad, cualquier decisión de pricing, staffing o marketing está a ciegas.

### Cómo funciona el flujo de datos

```
PostgreSQL → ETL (extract) → CSV raw → ETL (transform)
                                              │
                              ┌───────────────┼──────────────────┐
                              │               │                  │
                         kpis_mes.csv  reporte PDF/Excel  seasonality_data.js
                                                                  │
                                                         dashboard/index.html
                                                         (se abre directo en el navegador)
```

El ETL genera automáticamente dos archivos en `/dashboard/data/`:
- **`seasonality_data.json`** — datos en formato estándar (para APIs, documentación o herramientas externas)
- **`seasonality_data.js`** — mismos datos envueltos como `window.VIVERIOJA_DATA = {...}` para que el dashboard funcione con protocolo `file://` sin servidor

**Por qué `.js` además de `.json`:** Los navegadores bloquean `fetch()` sobre `file://` por política CORS. Inyectar los datos como variable global con `<script src="...">` es el patrón estándar en dashboards de análisis estáticos (Observable, D3.js, Vega-Lite). Así el dashboard funciona tanto abierto desde el explorador de archivos como publicado en GitHub Pages.

**Ventaja para un Data Analyst:** la separación datos / visualización es clave en flujos de trabajo reales. El analista actualiza los datos ejecutando `python pipeline.py`. El dashboard siempre muestra los datos más recientes sin tocar una línea de HTML o JS. Este patrón se usa en empresas con dashboards de reporting estático (reportes de dirección, informes regulatorios, PDFs interactivos) donde el backend genera los datos y el frontend los consume sin acoplamiento.

### El dashboard incluye

| Visual | Qué muestra | Interactividad |
|---|---|---|
| **KPI Cards** | Mes pico, mes valle, trimestre top, día top, variación % | Animación de entrada al cargar |
| **Barras + línea media** | Ingresos por mes con media superpuesta | Filtro por tier + selector de año + tooltip con ticket medio |
| **Heatmap mes × día** | Concentración de reservas por combinación mes/día | Tooltip al hover con número exacto |
| **Líneas YoY** | Comparativa año a año (2023/2024/2025) | Toggle para mostrar/ocultar cada año |
| **Insights automáticos** | 3 conclusiones calculadas desde los datos | Se recalculan automáticamente con cada actualización del JSON |

### Cómo ejecutar

```bash
# 1. Regenerar datos (desde /etl)
cd etl
python pipeline.py

# 2. Abrir el dashboard (desde la raíz del proyecto)
# Windows: doble clic en dashboard/index.html
# O desde terminal:
start dashboard/index.html
```

### Screenshot del dashboard

> *[Captura del dashboard — añadir tras primera ejecución en local]*

### Link al dashboard online

**[looperjajo.github.io/viverioja-experience/dashboard](https://looperjajo.github.io/viverioja-experience/dashboard)**

El dashboard vive en `public/dashboard/` — Astro lo copia a `dist/dashboard/` durante el build y el workflow de GitHub Actions lo despliega automáticamente. No requiere ningún cambio en la configuración de Pages.

---

## Análisis RFM — Segmentación de clientes

El análisis RFM está implementado en [`analytics/rfm_analysis.sql`](analytics/rfm_analysis.sql) y la interpretación completa en [`analytics/rfm_insights.md`](analytics/rfm_insights.md).

### Qué decisión de negocio permite tomar

RFM responde la pregunta que ningún KPI agregado puede responder: **¿a quién le hablo mañana y qué le digo?**

Un dashboard de ingresos te dice que el revenue bajó un 15%. RFM te dice que tienes 8 clientes en el segmento "At Risk" que juntos representan €12.000 de LTV histórico y llevan más de 14 meses sin volver. Esa es la diferencia entre un informe descriptivo y un análisis accionable.

### Cómo funciona técnicamente

El análisis usa tres CTEs encadenadas en PostgreSQL:

```sql
rfm_base     → métricas brutas (días desde última visita, nº reservas, total gastado)
rfm_scores   → NTILE(4) por cuartil en cada dimensión (4 = mejor cliente)
rfm_segments → clasificación de texto según combinación R/F/M
```

**Decisión de diseño:** usamos `MAX(fecha_experiencia)` de reservas completadas para la Recencia, no `fecha_reserva`. En enoturismo la señal relevante es cuándo el cliente *vivió* la experiencia, no cuándo hizo el click de reserva.

### Los 6 segmentos y su lectura para ViveRioja

| Segmento | Perfil | Prioridad | Acción |
|---|---|---|---|
| **Champions** | Recientes y frecuentes. El núcleo de la marca. | Máxima | Programa de embajadores y referidos |
| **Loyal Customers** | Alta frecuencia, posible ciclo largo entre visitas. | Alta | Upsell a tier premium |
| **At Risk** | Compraron varias veces pero llevan tiempo sin volver. | Urgente | Campaña de reactivación con incentivo (90 días) |
| **New Customers** | Primera compra reciente. Ventana de conversión abierta. | Alta | Onboarding post-visita automatizado |
| **Potential Loyalists** | Potencial no desarrollado. Perfil de ocasiones especiales. | Media | Contenido estacional y recordatorio |
| **Lost** | Una compra antigua. Coste de recuperación alto. | Baja | Solo actuar si M_score es alto |

---

## Stack tecnológico y por qué cada herramienta

**PostgreSQL 15**
Base de datos relacional open source. La elección para este proyecto fue deliberada: quería trabajar con un motor SQL completo que soportara CTEs, funciones de ventana (`NTILE`, `LAG`, `DENSE_RANK`), tipos de datos avanzados y constraints de integridad referencial. SQLite habría sido más fácil de configurar pero no refleja un entorno de trabajo real.

**SQL (CTEs y Window Functions)**
Las 12 queries analíticas de `03_queries.sql` no son queries básicas. Usan `LAG` para crecimiento MoM, `DENSE_RANK` para rankings de experiencias, `FILTER` para agregaciones condicionales y CTEs encadenadas para el modelo RFM. La legibilidad del código es una decisión de equipo: un analista que llegue en 6 meses tiene que entender qué calcula cada query y por qué.

**Power BI Desktop**
El estándar de facto en análisis de negocio en España y Europa. La curva de aprendizaje de DAX es real, pero una vez que entiendes el contexto de evaluación de filtros (`CALCULATE` modifica el filter context, no ejecuta una condición WHERE), el resto fluye. Elegí Power BI sobre Tableau porque es el que más aparece en ofertas de Data Analyst junior en el mercado español.

**DAX**
El lenguaje de medidas de Power BI. La diferencia entre un dashboard superficial y uno útil está en las medidas: `DATEADD` para comparaciones YoY, `DATESMTD` para acumulados de mes, `DIVIDE` para evitar errores de división por cero, `VAR`/`RETURN` para código legible. Las 20+ medidas están organizadas en 6 grupos funcionales con comentarios.

**HTML + CSS + JavaScript (web)**
La web desplegada en GitHub Pages no es el núcleo del proyecto de datos, pero refleja el contexto de negocio: si alguien quiere entender qué es ViveRioja antes de mirar el dashboard, puede hacerlo. También me obligó a pensar en el producto desde el punto de vista del usuario, lo cual mejora el análisis.

---

## Lo que aprendí construyendo este proyecto

**Diseñar para el negocio antes que para los datos.** Mi primer instinto fue normalizar al máximo. Luego me di cuenta de que `precio_unitario` en `reservas` tiene que ser una *snapshot* del precio en el momento de la reserva, aunque duplique datos con `experiencias[precio_base]`. Si el precio de una experiencia cambia, las reservas antiguas tienen que conservar el precio que el cliente aceptó. Ese tipo de decisión no sale de ningún tutorial — sale de pensar en qué pasa cuando el negocio evoluciona.

**DAX no es Excel con esteroides.** Pensaba que sabiendo fórmulas de Excel, DAX sería intuitivo. No lo es. El concepto de *filter context* — que una medida se evalúa siempre dentro de un contexto de filtro que puede ser modificado por `CALCULATE` — me costó varios días y varios dashboards rotos. Ahora es el primer concepto que explicaría a alguien que empieza.

**La documentación es parte del análisis, no un extra.** Las queries de `03_queries.sql` tienen comentarios que explican el *por qué* de cada decisión, no el *qué*. El código dice qué hace; el comentario dice por qué elegí ese enfoque sobre otros. Si en seis meses tengo que modificar la query de tasa de cancelación, quiero saber por qué excluí las reservas `pendiente` del denominador.

**Los datos limpios no existen — tienes que diseñarlos.** El seed de datos de `02_seed.sql` tiene 50+ clientes, 12 experiencias de tres tiers, bodegas reales de La Rioja y reservas con distintos estados y descuentos. Diseñar datos realistas me obligó a pensar en casos borde: ¿qué pasa con un cliente que tiene una reserva completada pero su pago fue reembolsado? ¿Cómo tratamos los no-shows en la tasa de cancelación? Responder esas preguntas mejoró tanto la base de datos como el análisis.

---

## Cómo ejecutar el proyecto

### Requisitos previos

- PostgreSQL 15+ instalado y corriendo en `localhost:5432`
- Power BI Desktop (descarga gratuita en microsoft.com/es-es/power-platform/products/power-bi/desktop)
- Driver ODBC de PostgreSQL (descarga en postgresql.org/ftp/odbc/versions/)

### Paso 1 — Crear la base de datos

```bash
# Crear la base de datos
createdb viverioja

# Ejecutar schema
psql -d viverioja -f database/01_schema.sql

# Cargar datos de prueba
psql -d viverioja -f database/02_seed.sql

# Verificar con las queries analíticas (opcional)
psql -d viverioja -f database/03_queries.sql
```

### Paso 2 — Ejecutar los análisis SQL

```bash
# Segmentación RFM de clientes
psql -d viverioja -f analytics/rfm_analysis.sql

# Análisis de estacionalidad (8 queries de negocio)
psql -d viverioja -f analytics/seasonality_analysis.sql
```

El output del RFM muestra cada cliente con su segmento y puntuaciones. El de estacionalidad muestra rankings de meses, comportamiento por día y comparativas de tier.

### Paso 3 — Ejecutar el pipeline ETL

```bash
cd etl
pip install -r requirements.txt   # primera vez
python pipeline.py
```

El pipeline extrae los datos de PostgreSQL, calcula KPIs, genera el PDF y Excel de reporte, y actualiza automáticamente el JSON del dashboard interactivo.

### Paso 4 — Abrir el dashboard de estacionalidad

```bash
# Abrir directamente en el navegador (no necesita servidor)
# Windows:
start dashboard\index.html
# Mac/Linux:
open dashboard/index.html
```

El dashboard lee el archivo `dashboard/data/seasonality_data.js` generado por el ETL y renderiza todos los gráficos dinámicamente con Chart.js.

### Paso 5 — Conectar Power BI

1. Abre Power BI Desktop → **Obtener datos** → **Base de datos PostgreSQL**
2. Servidor: `localhost` | Base de datos: `viverioja`
3. Importa todas las tablas: `clientes`, `reservas`, `experiencias`, `bodegas`, `pagos`, `resenas`, `experiencia_bodega`, `empleados`
4. Sigue los pasos del archivo [`database/04_powerbi_guide.md`](database/04_powerbi_guide.md) para:
   - Crear las relaciones del modelo estrella
   - Añadir la tabla `Dim_Fecha`
   - Importar las medidas DAX desde [`database/05_dax_measures.dax`](database/05_dax_measures.dax)
   - Construir los visuales del dashboard

### Variables de entorno recomendadas

Crea un archivo `.env` en la raíz (no commitear — ya está en `.gitignore`):

```env
PGHOST=localhost
PGPORT=5432
PGDATABASE=viverioja
PGUSER=tu_usuario
PGPASSWORD=tu_password
```

---

## Estructura de la base de datos

```
clientes ──────────────────────────┐
                                   │
experiencias ─── experiencia_bodega─┤
             │                     │
             └── reservas ──────────┤
                     │             │
                     ├── pagos     │
                     ├── resenas   │
                     └── empleados─┘
                           │
                       bodegas
```

8 tablas | ~50 clientes | 7 bodegas partner | 12 experiencias | 3 tiers (estándar, personalizada, premium)

---

*Proyecto de portfolio — Joan · Data Analyst Junior*
*Base de datos PostgreSQL 15 · Power BI · DAX · SQL*
