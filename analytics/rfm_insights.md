# RFM Analysis — ViveRioja Experience S.L.
## Guía de Interpretación para Dirección

---

## 1. Qué es RFM y por qué lo usamos en enoturismo

RFM es un modelo de segmentación de clientes basado en tres métricas de comportamiento transaccional:

| Dimensión | Pregunta que responde | Cómo se mide en ViveRioja |
|---|---|---|
| **R — Recencia** | ¿Cuándo fue la última vez que vino? | Días desde su última experiencia completada |
| **F — Frecuencia** | ¿Cuántas veces ha venido? | Número de reservas completadas |
| **M — Valor Monetario** | ¿Cuánto dinero nos ha dejado? | Suma de pagos cobrados y completados |

**Por qué RFM y no otro modelo:**

El enoturismo tiene un patrón de compra muy específico: baja frecuencia (2-4 visitas por año en el mejor caso), alta estacionalidad (primavera y otoño concentran el 60-70% de las visitas) y alta dispersión geográfica del cliente (turismo nacional e internacional). Estos factores hacen que modelos como el CLV predictivo necesiten más datos longitudinales de los que normalmente disponemos.

RFM funciona aquí porque:

1. **Es descriptivo, no predictivo** — con un dataset de tamaño medio o pequeño, predecir comportamiento futuro introduce mucho error. RFM solo describe lo que ya pasó y es siempre correcto con los datos disponibles.
2. **Accionable de inmediato** — cada segmento tiene una acción de negocio clara asociada. No necesitas un modelo de ML para actuar.
3. **Transparente para dirección** — puedes explicar por qué un cliente es "At Risk" en 30 segundos: "compró dos veces pero lleva más de un año sin volver".
4. **Compatible con el CRM** — el código RFM (ej. `442`) se puede añadir como campo en cualquier herramienta de email marketing o CRM sin infraestructura adicional.

**Nota metodológica:** Usamos cuartiles (NTILE 4) en lugar de quintiles (NTILE 5) porque con una base de clientes pequeña o mediana los quintiles generan grupos de 2-3 personas que no son estadísticamente significativos. Los cuartiles ofrecen mejor resolución con menos ruido.

---

## 2. Qué significa cada segmento para ViveRioja

### Champions (R=4, F=4)
**Perfil:** Vienen frecuentemente y lo hicieron hace poco. Son el núcleo fiel de ViveRioja.

En el contexto de enoturismo, estos clientes probablemente ya exploraron varios tiers de experiencia, conocen el territorio y traen a amigos o familia. Tienen la mayor probabilidad de convertirse en prescriptores (word-of-mouth) y de consumir el tier premium si se les presenta bien.

**Señal de alerta:** este segmento tiende a ser pequeño (5-15% de la base) pero concentra el 25-40% del revenue. Si empieza a encogerse, es un indicador de deterioro del producto antes de que lo veamos en los ingresos.

---

### Loyal Customers (F≥3)
**Perfil:** Alta frecuencia aunque no necesariamente recientes. Conocen el producto, repiten, pero pueden estar en un ciclo largo entre visitas.

Son el candidato ideal para upselling de tier (de estándar a premium) y para productos de suscripción o membresía si ViveRioja desarrolla ese modelo. También son buenos candidatos para encuestas de satisfacción profunda porque ya tienen criterio comparativo.

**Matiz importante:** un Loyal Customer con R_score=1 está en riesgo real aunque la frecuencia sea alta. En una versión avanzada del modelo se puede cruzar R y F para identificar "Loyal at Risk" como micro-segmento prioritario.

---

### At Risk (R≤2, F≥2)
**Perfil:** Compraron al menos dos veces pero llevan tiempo sin aparecer. El negocio los está perdiendo de forma silenciosa.

Este segmento es crítico porque el coste de recuperar un cliente perdido es 5-7x mayor que retenerlo. En enoturismo, la razón más común del abandono no es insatisfacción con el producto (si volvieron una segunda vez, les gustó), sino falta de estímulo para volver: no recibieron comunicación relevante, se fue el momento (cambio de estación, fin de un viaje) o encontraron una alternativa.

**Ventana de acción:** si un cliente de este segmento no responde a una campaña de reactivación en los próximos 90 días, lo clasificaríamos como Lost en el siguiente ciclo de análisis.

---

### New Customers (F=1, R≥3)
**Perfil:** Primera compra reciente. El producto les interesó lo suficiente para probar. Aún no sabemos si volverán.

Son el segmento más incierto: la primera experiencia es la que define si un cliente se convierte en Loyal o desaparece. La ventana crítica es las 8-12 semanas post-visita. Si en ese período no reciben ninguna comunicación personalizada de ViveRioja, la probabilidad de segunda visita cae significativamente.

**Dato de contexto:** en enoturismo, la tasa de conversión de primera a segunda visita ronda el 30-40% sin acciones específicas de retención. Con campañas dirigidas puede subir al 55-65%.

---

### Potential Loyalists (resto)
**Perfil:** Compraron más de una vez pero no con la frecuencia ni recencia suficiente para entrar en otro segmento. Perfil intermedio con potencial no desarrollado.

Son candidatos a empujar hacia Loyal Customers con el estímulo adecuado. Generalmente son clientes que disfrutaron la experiencia pero no tienen un hábito establecido de consumo de enoturismo, o que reservan solo en ocasiones especiales (cumpleaños, aniversarios).

---

### Lost (R=1, F=1)
**Perfil:** Una sola compra, hace mucho tiempo. El coste de reactivación es alto y la probabilidad de respuesta es baja.

En la mayoría de los casos, invertir en recuperar clientes Lost no es rentable. La excepción son clientes con M_score=4 (gastaron mucho en su única visita): vale la pena intentar reactivarlos porque el ticket potencial justifica el coste de la campaña.

**Recomendación de tratamiento:** separar Lost de alto valor (M=3 o M=4) de Lost de bajo valor. Los primeros merecen una acción personalizada; los segundos, una campaña de bajo coste o ninguna acción.

---

## 3. Acciones de marketing/negocio recomendadas por segmento

| Segmento | Acción principal | Canal | Mensaje clave | KPI de éxito |
|---|---|---|---|---|
| **Champions** | Programa de embajadores / referidos | Email personalizado + teléfono | "Eres parte de ViveRioja — trae a alguien especial" | Nº de referidos generados |
| **Loyal Customers** | Upsell a tier premium o experiencia exclusiva | Email + WhatsApp (si consintieron) | "Te reservamos algo nuevo que creemos que te encantará" | Tasa de conversión a premium |
| **At Risk** | Campaña de reactivación con incentivo | Email con oferta por tiempo limitado | "Te echamos de menos — vuelve con un 10% de descuento" | Tasa de reactivación (90 días) |
| **New Customers** | Onboarding post-visita (nurturing) | Email automatizado 2 semanas post-visita | "Esperamos que hayas disfrutado — aquí tienes tu próxima aventura" | Segunda reserva en 90 días |
| **Potential Loyalists** | Contenido de valor + recordatorio estacional | Newsletter + redes sociales | "La vendimia llega — ven a vivirla" | Frecuencia de compra |
| **Lost (alto valor)** | Contacto personal con oferta exclusiva | Email personalizado o llamada | "Han pasado X meses — te lo ponemos fácil para volver" | Reapertura de reserva |
| **Lost (bajo valor)** | Sin acción activa o campaña masiva de bajo coste | Newsletter general | — | Desuscripción / conversión residual |

---

## 4. Cómo presentaría estos resultados a dirección

### Estructura de la presentación (20 minutos)

**Slide 1 — El problema que resuelve este análisis (2 min)**

> "Hoy ViveRioja trata a todos los clientes igual en sus comunicaciones. Este análisis nos permite saber, para cada cliente, cuánto vale, cuánto tiempo lleva sin volver y si está en riesgo de perderse. Eso nos permite actuar antes de que se vaya."

**Slide 2 — Distribución de la base de clientes (3 min)**

Mostrar la tabla resumen por segmento: cuántos clientes hay en cada uno y qué % del revenue representan. El mensaje esperado es el clásico del análisis de Pareto aplicado a clientes: un porcentaje pequeño (Champions + Loyal) genera la mayoría del ingreso.

**Slide 3 — Los tres segmentos prioritarios para dirección (5 min)**

No todos los segmentos son igual de urgentes. En esta presentación, destacaría:
1. **Champions** — hay que protegerlos activamente (riesgo de que se vayan a la competencia)
2. **At Risk** — tenemos una ventana de 90 días antes de perderlos definitivamente
3. **New Customers** — el crecimiento futuro viene de aquí; hay que convertirlos ahora

**Slide 4 — Plan de acción con ROI estimado (5 min)**

Traducir cada acción a coste estimado y revenue potencial. Por ejemplo:
- Campaña de reactivación para "At Risk": coste de email marketing bajo, si recuperamos el 20% de ese segmento a su ticket medio histórico, el revenue adicional es X.
- Onboarding de "New Customers": si mejoramos la tasa de segunda visita del 35% al 50%, el impacto en LTV anual es Y.

**Slide 5 — Cómo mantener este análisis vivo (2 min)**

RFM no es un análisis puntual. Proponer ejecutarlo mensual o trimestral y vincular el resultado al CRM para que el equipo comercial vea el segmento de cada cliente en su ficha. El objetivo es que en 6 meses la distribución de segmentos muestre más Champions y menos Lost: esa sería la medida de éxito del programa de retención.

---

### Mensajes clave para dirección (para responder preguntas difíciles)

**"¿Por qué NTILE 4 y no otro método?"**
> Los cuartiles son el estándar de la industria para RFM porque equilibran granularidad con robustez estadística. Con quintiles (5 grupos) necesitaríamos el doble de clientes para que los grupos sean significativos.

**"¿Podemos confiar en estos segmentos con nuestro volumen de datos?"**
> Los segmentos son descriptivos, no predictivos. Reflejan el comportamiento pasado exactamente como está en nuestra base de datos. Lo que no podemos garantizar es que el comportamiento futuro sea igual — por eso el análisis se debe repetir periódicamente.

**"¿Cuándo veremos resultados de las acciones?"**
> Los primeros resultados visibles (cambios en tasas de apertura de email, primeras reactivaciones) serán en 4-6 semanas. El impacto en el KPI de retención (segunda reserva en 90 días para New Customers, reactivación para At Risk) será medible a los 90-120 días.

---

*Análisis generado para ViveRioja Experience S.L. — Base de datos PostgreSQL 15+*
*Actualizar mensualmente para mantener la segmentación vigente.*
