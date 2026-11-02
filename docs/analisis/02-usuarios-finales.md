
# Usuarios finales y necesidades de información

> **DWI-21**
> **Responsable:** Krisley Castro Barrantes

## 1. Identificación de usuarios finales

El Data Warehouse de Invacom Inc S.A. tiene como propósito facilitar el análisis de la información relacionada con los alquileres de películas, los ingresos, los clientes y el inventario.

Para identificar los usuarios finales, se tomaron como referencia las diez preguntas de negocio definidas previamente por el equipo. A partir de ellas, se identificaron seis áreas que utilizarían los reportes para consultar información y apoyar la toma de decisiones.

Los usuarios finales propuestos son Gerencia, Operaciones, Catálogo, Gerencia Comercial, Mercadeo e Inventario.

## 2. Necesidades de información por área

| Usuario o área | Información que necesita | Para qué utilizará la información |
|---|---|---|
| Gerencia | Ingresos totales y monto promedio cobrado por mes y por tienda. | Comparar los resultados económicos e identificar cuáles tiendas generan mayores ingresos. |
| Operaciones | Cantidad de alquileres por período y porcentaje de devoluciones tardías. | Evaluar el comportamiento de los alquileres y detectar problemas con los tiempos de devolución. |
| Encargado del catálogo | Las diez películas y los diez actores con mayor cantidad de alquileres. | Identificar los títulos y actores con mayor demanda. |
| Gerencia comercial | Ingresos por categoría y cantidad de alquileres e ingresos según la clasificación de las películas. | Comparar el rendimiento de las distintas categorías y clasificaciones para orientar decisiones comerciales. |
| Mercadeo | Clientes que más dinero han pagado y países o ciudades donde se concentran los alquileres. | Conocer el comportamiento de los clientes e identificar oportunidades para desarrollar estrategias comerciales. |
| Inventario | Cantidad de copias físicas registradas de cada película por tienda. | Conocer cómo está distribuido el inventario y apoyar las decisiones sobre existencias. |

## 3. Forma en que los usuarios consultarán la información

Los usuarios accederán a los resultados mediante tablas dinámicas de Excel conectadas al Data Warehouse.

Los reportes permitirán consultar y comparar la información utilizando diferentes criterios, según las necesidades de cada área:

- **Períodos:** consultar resultados por mes, trimestre o año.
- **Tiendas:** comparar la cantidad de alquileres, ingresos e inventario.
- **Películas:** analizar títulos, categorías y clasificaciones.
- **Clientes:** identificar patrones de consumo y distribución geográfica.

La intención es que los usuarios puedan obtener información útil sin tener que consultar directamente las tablas originales de PostgreSQL.

## 4. Relación con las preguntas de negocio

Las necesidades identificadas se relacionan con las diez preguntas establecidas para el proyecto:

| Área | Preguntas relacionadas |
|---|---|
| Gerencia | Pregunta 1 |
| Operaciones | Preguntas 2 y 9 |
| Catálogo | Preguntas 3 y 7 |
| Gerencia comercial | Preguntas 4 y 8 |
| Mercadeo | Preguntas 5 y 6 |
| Inventario | Pregunta 10 |

Esta relación permite identificar qué información debe contemplar el diseño del Data Warehouse para responder a las necesidades de cada área.

## 5. Validación de las necesidades

Las necesidades de información fueron identificadas a partir de las preguntas de negocio definidas por el equipo, por lo que representan una propuesta inicial de usuarios y requerimientos.

Debido a que el proyecto se desarrolla como un caso académico, estas necesidades deberán ser validadas con el profesor, quien cumple el rol de Product Owner.

Adicionalmente, se plantearon tres posibles análisis relacionados con el ticket promedio por alquiler, la frecuencia de alquiler de los clientes y el inventario sin rotación. Su incorporación dependerá de la aprobación del equipo y del Product Owner.
