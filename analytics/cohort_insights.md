# ViveRioja Experience — Cohort Analysis: Qué es, por qué importa y qué decisiones permite tomar

---

## 1. Qué es un análisis de cohortes

Un análisis de cohortes **agrupa clientes por el momento en que los adquiriste** y luego rastrea cómo evoluciona ese grupo a lo largo del tiempo.

En ViveRioja, cada cohorte es el conjunto de clientes que hicieron su **primera reserva completada en el mismo mes**. La cohorte de septiembre 2023 son todos los clientes que vivieron su primera experiencia en ese mes. La de enero 2024, los que debutaron en enero.

La **matriz de retención** que resulta tiene esta forma:

```
Cohorte        M0    M1    M2    M3    M6    M12
─────────────────────────────────────────────────
Enero 2023    100%    0%  33%    0%    0%   33%
Abril 2023    100%  17%  17%    0%    0%   33%
Sep 2023      100%  50%  25%  12%   62%    —
```

- **Fila** = grupo de clientes adquiridos en ese mes
- **Columna** = meses desde la primera reserva (M0, M1, M2…)
- **Valor** = % de clientes del grupo que volvieron a reservar en ese periodo

**M0 siempre es 100%** — es el mes de adquisición, por definición todos están activos. Las columnas siguientes muestran quién vuelve y quién no.

---

## 2. Por qué el análisis de cohortes es más potente que los KPIs agregados

Los KPIs mensuales (ingresos totales, reservas, ticket medio) son fotos del momento. Te dicen *qué pasó* pero no *por qué* ni *en qué clientes*.

Imagina que en octubre 2024 los ingresos bajan un 8%. Un KPI agregado solo muestra ese descenso. Un análisis de cohortes te diría:

- Los clientes adquiridos en septiembre 2023 siguen teniendo una retención del 50% a los 13 meses — **esos están bien**.
- Los clientes adquiridos en enero 2024 tienen retención M6 del 0% — **esos se han perdido**.
- El problema no es el mercado ni la temporada, es la **calidad de los clientes captados en invierno**.

Esa diferencia cambia completamente la decisión: en un caso refuerzas fidelización, en el otro revisas el canal de adquisición de enero.

### Los tres problemas que solo el análisis de cohortes resuelve

| Pregunta | KPI mensual | Cohortes |
|---|---|---|
| ¿Mis clientes nuevos de este año valen más que los del año anterior? | No puede responder | Compara LTV acumulado por cohorte año a año |
| ¿Cuándo debo enviar la campaña de re-engagement? | No puede responder | Mide el tiempo medio hasta la segunda reserva |
| ¿El problema de retención es generalizado o de un grupo específico? | No puede responder | Muestra qué cohortes se pierden y cuáles retienen |

---

## 3. Por qué importa especialmente en enoturismo

El enoturismo tiene dos características que hacen el análisis de cohortes especialmente valioso:

### 3.1 Estacionalidad extrema de la adquisición

La mayoría de clientes nuevos llegan en septiembre-octubre (vendimia) y abril (Semana Santa). Eso significa que las cohortes más grandes se forman en esos meses, y sus patrones de retorno condicionan los ingresos de los 12 meses siguientes.

Si la cohorte de septiembre 2023 tiene una retención M12 del 40% (vuelven en septiembre 2024), sabes ya en enero que septiembre 2024 va a ser fuerte aunque todavía no hayan reservado. Si esa cohorte tiene retención M12 del 5%, tienes 9 meses para activar campañas de re-engagement antes de que llegue el verano.

### 3.2 El cliente tiene ciclos de consumo anuales

El turista de enoturismo de calidad no viene cada mes. Viene una vez al año, o como mucho dos: vendimia y quizás Semana Santa. Eso significa que **la retención mensual no mide bien la lealtad** — un cliente fiel puede tener retención M1, M2, M3 de 0% y M11 del 100%.

El análisis de cohortes captura ese patrón de retorno anual que los KPIs mensuales ocultan.

### 3.3 El CAC varía enormemente por temporada

Captar un cliente en septiembre (cuando la vendimia genera demanda orgánica) es mucho más barato que captarlo en enero (cuando necesitas publicidad activa). El análisis de cohortes permite calcular el **retorno sobre el coste de adquisición (ROCA)** por temporada:

```
ROCA = LTV cohorte septiembre / CAC septiembre
ROCA = LTV cohorte enero      / CAC enero
```

Si el LTV de septiembre es 3x el de enero pero el CAC es solo 1.5x, invertir en captar clientes en agosto (antes de vendimia) tiene un retorno mucho mejor.

---

## 4. Qué decisiones de negocio permite tomar en ViveRioja

### Decisión 1 — Timing de campañas de fidelización

El análisis de cohortes revela que el tiempo medio hasta la segunda reserva en ViveRioja es de **4.2 meses**. Esto define una ventana de acción concreta:

- **Mes 2–3 tras la primera visita**: enviar email de seguimiento con contenido de valor (guía de La Rioja, maridajes recomendados, novedades de la bodega).
- **Mes 4–5**: si no hay segunda reserva, activar oferta de re-engagement (-10% para reservas en el mes siguiente).
- **Mes 6+**: cliente en riesgo de pérdida, campaña de recuperación más agresiva.

Sin el análisis de cohortes, cualquier timing es arbitrario. Con él, el timing está calibrado por comportamiento real.

### Decisión 2 — Asignación del presupuesto de marketing

Si la cohorte de septiembre tiene LTV per cápita a 12 meses de €4.030 y la de enero tiene €2.840, el presupuesto de captación en agosto (justo antes de vendimia) puede ser hasta un **42% más alto** que en diciembre y seguir siendo más rentable.

Esta lógica no es obvia sin los datos de cohortes — sin ellos, una empresa tiende a igualar el gasto o a reducirlo en temporada alta porque "ya hay demanda".

### Decisión 3 — Evaluación de canales de adquisición

Cruzando la cohorte con el canal de adquisición del cliente (`canal_adquisicion` en la tabla clientes), puedes ver qué canal no solo trae más clientes sino más clientes *con mejor retención*. Un canal que trae 20 clientes con retención M12 del 30% es más valioso que uno que trae 30 clientes con retención del 5%.

Esta métrica — **LTV por canal de adquisición** — es el estándar en empresas con modelos de suscripción o recurrencia. En enoturismo tiene el mismo valor analítico.

### Decisión 4 — Señales tempranas de retención

Si una cohorte muestra retención M1 muy baja (nadie vuelve al mes siguiente), hay tres causas posibles:
1. La experiencia no cumplió las expectativas → revisar el producto.
2. El precio percibido fue alto respecto al valor → ajustar pricing o comunicación.
3. Son clientes de temporada única que no tienen intención de repetir → revisar el canal.

Detectar esto en el mes 2 (en lugar de al año siguiente cuando ya son pérdidas) da tiempo para intervenir.

### Decisión 5 — Proyección de ingresos futuros

Con la retención histórica por cohorte, puedes proyectar cuántos ingresos generarán las cohortes ya adquiridas en los próximos 6–12 meses, sin haber recibido aún esas reservas. Ese modelo predictivo simple (cohorte actual × tasa de retención histórica × ticket medio) es más preciso que cualquier previsión basada solo en estacionalidad.

---

## 5. Cómo leer el heatmap de cohortes

```
Más oscuro = mayor retención = mejor
Gris claro = dato no disponible aún (mes futuro)
M0 = siempre 100% (mes de adquisición)
```

**Lo que buscas en el heatmap:**

- **Columnas oscuras** a partir del M6 o M12 → retención anual alta (patrón de cliente leal).
- **Filas oscuras en septiembre/octubre** → las cohortes de vendimia son las mejores.
- **Columnas muy claras** en M1–M3 → nadie vuelve a corto plazo (normal en enoturismo, no es alarma si M12 es oscuro).
- **Filas uniformemente claras** → esa cohorte se perdió, investigar por qué.

---

## 6. Nota técnica: por qué usamos fecha_experiencia y no fecha_reserva

La cohorte de un cliente se define por cuándo **vivió** la experiencia, no por cuándo hizo click en "reservar". Un cliente que reserva en agosto para septiembre es un cliente de la cohorte de septiembre — su comportamiento de retorno, su LTV y su satisfacción están ligados a lo que vivió en septiembre, no en agosto.

Usar `fecha_reserva` mezclaría clientes de cohortes distintas y distorsionaría los patrones estacionales que son precisamente los que queremos medir.

---

*Análisis generado como parte del portfolio de Data Analytics — ViveRioja Experience.*
*Los datos del dashboard se actualizan con cada ejecución de `python etl/pipeline.py`.*
