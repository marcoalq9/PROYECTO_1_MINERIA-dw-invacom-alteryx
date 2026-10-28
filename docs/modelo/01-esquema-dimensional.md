# Esquema del data warehouse

> Tarea 6 del enunciado: *Diseñar el esquema del data warehouse (modelado dimensional) usando el modelo estrella o copo de nieve.*
> Jira: DWI-27 · Responsable: Marco Andrey López Quesada

## Decisión

Se usa un **esquema estrella**. Las dimensiones se guardan desnormalizadas, en una sola tabla cada una. La única excepción es la relación entre películas y actores, que se resuelve con una **tabla puente**.

El modelo tiene dos tablas de hechos (alquileres e inventario) que comparten las dimensiones Película y Tienda. Es decir, son dos estrellas unidas por dimensiones comunes, lo que también se conoce como constelación de hechos.

## Justificación

| Criterio | Estrella | Copo de nieve |
|---|---|---|
| Consultas desde Excel | Cada pregunta se resuelve uniendo el hecho con cada dimensión una sola vez | Hay que unir varias tablas por dimensión (por ejemplo cliente → dirección → ciudad → país) |
| Uso en tablas dinámicas | Cada dimensión aparece como una sola tabla con todos sus atributos | El usuario ve más tablas y debe entender cómo se relacionan |
| Espacio en disco | Repite algunos valores (ciudad, país, categoría) | Evita esas repeticiones |
| Carga en Alteryx | Un flujo por dimensión | Un flujo por cada tabla normalizada |

La única ventaja del copo de nieve es el ahorro de espacio, y en esta base es despreciable porque las dimensiones son pequeñas:

- **Cliente:** 599 clientes. Guardar su ciudad (600 en total) y su país (109) en la misma tabla repite pocos valores.
- **Película:** 1 000 películas. Cada película tiene **exactamente una categoría** (1 000 filas en `film_category`) y un solo idioma (6 en total), así que ambos se guardan como columnas de la dimensión sin duplicar filas.

## Excepción: actores

Una película tiene varios actores y un actor aparece en varias películas (5 462 filas en `film_actor`). Si los actores se guardaran dentro de la dimensión Película, cada película se repetiría una vez por actor y los conteos de alquileres se multiplicarían.

Por eso los actores van en su propia dimensión, unida a Película mediante una **tabla puente** (`bridge_pelicula_actor`). La tabla puente solo se usa para la pregunta de los actores más alquilados; las demás preguntas no la tocan.
