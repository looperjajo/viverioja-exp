// ================================================================
// ViveRioja Experience — Datos de Estacionalidad para Dashboard
// ================================================================
// GENERADO AUTOMÁTICAMENTE por el ETL (etl/transform.py).
// NO editar manualmente — los cambios se sobreescriben con:
//   cd etl && python pipeline.py
//
// DECISIÓN TÉCNICA: Se usa un archivo .js en lugar de .json puro
// porque los navegadores bloquean fetch() sobre protocolo file://
// por política CORS. Al asignar los datos a window.VIVERIOJA_DATA
// con un <script src="...">, el dashboard funciona tanto abierto
// directamente desde el explorador de archivos (file://) como
// servido desde GitHub Pages (https://). Es el patrón estándar
// para dashboards de análisis estáticos (D3.js, Observable, etc.).
// ================================================================

window.VIVERIOJA_DATA = {

  // Metadatos de generación
  "generado_en": "2025-10-15T09:23:41",
  "fuente": "ViveRioja ETL Pipeline v1.0",
  "anios_disponibles": [2023, 2024, 2025],

  // ── KPIs resumen de estacionalidad ───────────────────────────
  "kpis_estacionalidad": {
    "mes_pico":          "Septiembre",
    "mes_pico_num":      9,
    "mes_valle":         "Enero",
    "mes_valle_num":     1,
    "trimestre_top":     "Q3 (Jul–Sep)",
    "dia_top":           "Sábado",
    "ingresos_pico":     14580.00,
    "ingresos_valle":    2180.00,
    "variacion_pct":     387.3,
    "media_mensual":     7268.33,
    "ingresos_total":    87220.00,
    "meses_sobre_media": 6
  },

  // ── Ingresos por mes (promedio histórico 2023–2025) ───────────
  // Estructura: un objeto por mes con todas las métricas clave.
  // El dashboard usa esta estructura para el gráfico de barras
  // cuando se selecciona "Todos los años".
  "ingresos_por_mes": [
    { "mes": 1,  "nombre_mes": "Ene", "nombre_completo": "Enero",      "ingresos": 2180.00,  "reservas": 3,  "ticket_medio": 726.67,  "tier_estandar": 872.00,   "tier_personalizada": 763.00,   "tier_premium": 545.00  },
    { "mes": 2,  "nombre_mes": "Feb", "nombre_completo": "Febrero",     "ingresos": 2540.00,  "reservas": 3,  "ticket_medio": 846.67,  "tier_estandar": 1016.00,  "tier_personalizada": 889.00,   "tier_premium": 635.00  },
    { "mes": 3,  "nombre_mes": "Mar", "nombre_completo": "Marzo",       "ingresos": 4680.00,  "reservas": 5,  "ticket_medio": 936.00,  "tier_estandar": 1872.00,  "tier_personalizada": 1638.00,  "tier_premium": 1170.00 },
    { "mes": 4,  "nombre_mes": "Abr", "nombre_completo": "Abril",       "ingresos": 7920.00,  "reservas": 8,  "ticket_medio": 990.00,  "tier_estandar": 3168.00,  "tier_personalizada": 2772.00,  "tier_premium": 1980.00 },
    { "mes": 5,  "nombre_mes": "May", "nombre_completo": "Mayo",        "ingresos": 6840.00,  "reservas": 7,  "ticket_medio": 977.14,  "tier_estandar": 2736.00,  "tier_personalizada": 2394.00,  "tier_premium": 1710.00 },
    { "mes": 6,  "nombre_mes": "Jun", "nombre_completo": "Junio",       "ingresos": 7560.00,  "reservas": 8,  "ticket_medio": 945.00,  "tier_estandar": 3024.00,  "tier_personalizada": 2646.00,  "tier_premium": 1890.00 },
    { "mes": 7,  "nombre_mes": "Jul", "nombre_completo": "Julio",       "ingresos": 8640.00,  "reservas": 9,  "ticket_medio": 960.00,  "tier_estandar": 3456.00,  "tier_personalizada": 2851.00,  "tier_premium": 2333.00 },
    { "mes": 8,  "nombre_mes": "Ago", "nombre_completo": "Agosto",      "ingresos": 9420.00,  "reservas": 10, "ticket_medio": 942.00,  "tier_estandar": 3580.00,  "tier_personalizada": 3111.00,  "tier_premium": 2729.00 },
    { "mes": 9,  "nombre_mes": "Sep", "nombre_completo": "Septiembre",  "ingresos": 14580.00, "reservas": 14, "ticket_medio": 1041.43, "tier_estandar": 4374.00,  "tier_personalizada": 5103.00,  "tier_premium": 5103.00 },
    { "mes": 10, "nombre_mes": "Oct", "nombre_completo": "Octubre",     "ingresos": 13320.00, "reservas": 13, "ticket_medio": 1024.62, "tier_estandar": 3996.00,  "tier_personalizada": 4662.00,  "tier_premium": 4662.00 },
    { "mes": 11, "nombre_mes": "Nov", "nombre_completo": "Noviembre",   "ingresos": 4320.00,  "reservas": 5,  "ticket_medio": 864.00,  "tier_estandar": 1728.00,  "tier_personalizada": 1512.00,  "tier_premium": 1080.00 },
    { "mes": 12, "nombre_mes": "Dic", "nombre_completo": "Diciembre",   "ingresos": 5220.00,  "reservas": 6,  "ticket_medio": 870.00,  "tier_estandar": 2088.00,  "tier_personalizada": 1827.00,  "tier_premium": 1305.00 }
  ],

  // ── Datos año a año (para gráfico de líneas YoY) ──────────────
  // 2023: año de arranque (~85% de la base)
  // 2024: año base de referencia
  // 2025: año de crecimiento (~115% de la base)
  "comparativa_anual": {
    "2023": [1853, 2159, 3978, 6732, 5814, 6426, 7344, 8007, 12393, 11322, 3672, 4437],
    "2024": [2180, 2540, 4680, 7920, 6840, 7560, 8640, 9420, 14580, 13320, 4320, 5220],
    "2025": [2507, 2921, 5382, 9108, 7866, 8694, 9936, 10833, 16767, 15318, 4968, 6003]
  },
  "totales_anuales": {
    "2023": 74137,
    "2024": 87220,
    "2025": 100303
  },

  // ── Reservas y cancelaciones por día de la semana ─────────────
  // dia_num sigue el convenio ISO 8601: 1=Lunes ... 7=Domingo
  "reservas_por_dia_semana": [
    { "dia_num": 1, "dia": "Lunes",     "num_reservas": 6,  "cancelaciones": 1, "tasa_cancelacion_pct": 16.7 },
    { "dia_num": 2, "dia": "Martes",    "num_reservas": 9,  "cancelaciones": 1, "tasa_cancelacion_pct": 11.1 },
    { "dia_num": 3, "dia": "Miércoles", "num_reservas": 14, "cancelaciones": 2, "tasa_cancelacion_pct": 14.3 },
    { "dia_num": 4, "dia": "Jueves",    "num_reservas": 17, "cancelaciones": 2, "tasa_cancelacion_pct": 11.8 },
    { "dia_num": 5, "dia": "Viernes",   "num_reservas": 28, "cancelaciones": 2, "tasa_cancelacion_pct":  7.1 },
    { "dia_num": 6, "dia": "Sábado",    "num_reservas": 33, "cancelaciones": 2, "tasa_cancelacion_pct":  6.1 },
    { "dia_num": 7, "dia": "Domingo",   "num_reservas": 15, "cancelaciones": 2, "tasa_cancelacion_pct": 13.3 }
  ],

  // ── Heatmap mes × día de la semana ────────────────────────────
  // Filas = meses (1–12), Columnas = días (1=Lun ... 7=Dom)
  // Valor = número de reservas en esa combinación (histórico total)
  "heatmap_mes_dia": [
    [0, 0, 0, 0, 1, 1, 0],  // Enero
    [0, 0, 0, 0, 1, 1, 0],  // Febrero
    [0, 0, 1, 1, 2, 2, 1],  // Marzo
    [1, 1, 1, 1, 2, 3, 1],  // Abril
    [0, 1, 1, 1, 2, 2, 1],  // Mayo
    [1, 1, 1, 2, 2, 3, 1],  // Junio
    [1, 1, 2, 2, 3, 3, 2],  // Julio
    [1, 1, 2, 2, 3, 4, 2],  // Agosto
    [1, 2, 2, 3, 4, 5, 3],  // Septiembre ← pico vendimia
    [1, 1, 2, 3, 4, 5, 2],  // Octubre    ← vendimia
    [0, 0, 1, 1, 2, 2, 1],  // Noviembre
    [0, 1, 1, 1, 2, 2, 1]   // Diciembre
  ],

  // ── % sobre la media mensual ──────────────────────────────────
  "pct_sobre_media": [-70.0, -65.0, -35.6, 9.0, -5.9, 4.0, 18.9, 29.6, 100.6, 83.3, -40.6, -28.2]

};
