
# Usuarios finales y necesidades de información

> **DWI-21**
> **Responsable:** Krisley Castro Barrantes

## 1. Identificación de usuarios finales

El Data Warehouse de Invacom Inc S.A. tiene como propósito facilitar el análisis de la información relacionada con los alquileres de películas, los ingresos, los clientes y el inventario.

Para identificar los usuarios finales, se tomaron como referencia las doce preguntas de negocio que aparecen actualmente en `docs/analisis/04-preguntas-de-negocio.md`. A partir de ellas, se identificaron seis áreas que utilizarían los reportes para consultar información y apoyar la toma de decisiones.

Los usuarios finales propuestos son Gerencia, Operaciones, Catálogo, Gerencia Comercial, Mercadeo e Inventario.

## 2. Necesidades de información por área

| Usuario o área | Información que necesita | Para qué utilizará la información |
|---|---|---|
| Gerencia | Ingresos totales y monto promedio por pago, por mes y por tienda. | Comparar los resultados económicos e identificar cuáles tiendas generan mayores ingresos. |
| Operaciones | Cantidad de alquileres por período y porcentaje de devoluciones tardías. | Evaluar el comportamiento de los alquileres y detectar problemas con los tiempos de devolución. |
| Encargado del catálogo | Las diez películas y los diez actores con mayor cantidad de alquileres. | Identificar los títulos y actores con mayor demanda. |
| Gerencia comercial | Ingresos por categoría, alquileres e ingresos por clasificación, y ticket promedio por alquiler según cliente y categoría. | Comparar el rendimiento comercial del catálogo y conocer el monto promedio cobrado por alquiler. |
| Mercadeo | Clientes que más dinero han pagado, ciudad y país de residencia, días entre alquileres y cantidad de clientes nuevos y recurrentes por mes. | Conocer el comportamiento y la frecuencia de alquiler de los clientes para orientar estrategias comerciales. |
| Inventario | Copias físicas de cada película por tienda y porcentaje de copias sin alquileres durante el trimestre seleccionado. | Conocer la distribución del inventario e identificar copias con poca o ninguna rotación. |

## 3. Forma en que los usuarios consultarán la información

Los usuarios accederán a los resultados mediante tablas dinámicas de Excel conectadas al Data Warehouse.

Los reportes permitirán consultar y comparar la información utilizando diferentes criterios, según las necesidades de cada área:

- **Períodos:** consultar resultados por mes, trimestre o año, incluyendo la rotación del inventario por trimestre y los clientes nuevos o recurrentes por mes.
- **Tiendas:** comparar la cantidad de alquileres, ingresos e inventario.
- **Películas:** analizar títulos, categorías y clasificaciones.
- **Clientes:** identificar patrones de consumo, distribución geográfica, frecuencia de alquiler y clientes nuevos o recurrentes.

La intención es que los usuarios puedan obtener información útil sin tener que consultar directamente las tablas originales de PostgreSQL.

## 4. Relación con las preguntas de negocio

Las necesidades identificadas se relacionan con las doce preguntas que aparecen actualmente en el documento de preguntas de negocio del equipo:

| Área | Preguntas relacionadas |
|---|---|
| Gerencia | Pregunta 1 |
| Operaciones | Preguntas 2 y 9 |
| Catálogo | Preguntas 3 y 7 |
| Gerencia comercial | Preguntas 4, 8 y 11 |
| Mercadeo | Preguntas 5, 6 y 12 |
| Inventario | Pregunta 10 |

Esta relación permite identificar qué información debe contemplar el diseño del Data Warehouse para responder a las necesidades de cada área.

## 5. Validación de las necesidades

Las necesidades de información fueron identificadas a partir de las preguntas de negocio definidas por el equipo, por lo que representan una propuesta inicial de usuarios y requerimientos.

Debido a que el proyecto se desarrolla como un caso académico, estas necesidades deberán ser validadas con el profesor, quien cumple el rol de Product Owner.

Los análisis de ticket promedio por alquiler, frecuencia de alquiler de los clientes e inventario sin rotación ya están contemplados en las preguntas actuales: 11, 12 y 10, respectivamente. Por esa razón, no se presentan aquí como propuestas adicionales pendientes de incorporar.

La validación formal de estas necesidades con el profesor, quien cumple el rol de Product Owner, continúa siendo una actividad del proyecto. Este documento no supone que las áreas hayan sido entrevistadas ni que exista una aprobación formal ya registrada.
