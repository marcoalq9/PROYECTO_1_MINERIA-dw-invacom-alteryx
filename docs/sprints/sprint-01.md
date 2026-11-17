# Sprint 1

| | |
|---|---|
| **Fechas en Jira** | Inicio: 21/10/2026 · fin planificado: 28/10/2026 · cierre real: 04/11/2026 |
| **Scrum Master** | Kristel Daniela Ramírez Duarte |
| **Coordinadores** | Juan Daniel Ulate Aguilar y Marco Andrey López Quesada |
| **Product Owner** | El profesor |
| **Objetivo del sprint (Jira)** | Definir los propósitos iniciales del proyecto y la lista de preguntas de negocio, para luego, en el siguiente sprint, procesar los datos. |
| **Épicas** | DWI-1 Arranque y organización · DWI-2 Requisitos del negocio · DWI-3 Fuentes y calidad de datos · DWI-4 Modelado dimensional · DWI-5 (creación del DW) |
| **Tareas del enunciado** | 1 a 8 y la infraestructura del DW (10) |

El sprint se planificó a una semana y se cerró en Jira el 04/11. La segunda semana se usó para terminar el análisis de la fuente y el modelo dimensional, que dependían del perfilado de datos.

## Sprint Planning (21/10/2026)

Antes del sprint se completaron, el 20/10:

- [x] DWI-10 Formar el grupo y presentarlo al profesor (Kristel)
- [x] DWI-11 Designar Scrum Master (Marco)
- [x] DWI-12 Crear el repositorio Git con la estructura inicial (Marco)
- [x] DWI-13 Configurar el tablero de Jira con el Product Backlog (Kristel)

Sprint Backlog, según Jira:

| Tarea | Descripción | Responsable |
|---|---|---|
| DWI-14 | Acordar día de Sprint Planning y chat del Daily asíncrono | Kristel |
| DWI-15 | Instalar Alteryx Designer y obtener la licencia educativa | Krisley |
| DWI-16 | Instalar el motor del DW (SQL Server Developer + SSMS) | Marco |
| DWI-17 | Recibir la base de datos fuente y restaurarla localmente | Juan Daniel |
| DWI-18 | Invitar a los compañeros y al profesor como colaboradores del repo | Marco |
| DWI-19 | Completar el README con los usuarios de GitHub del equipo | Juan Daniel |
| DWI-20 | Definir el propósito general del proyecto | Marco |
| DWI-21 | Identificar usuarios finales y la información que necesitan | Krisley |
| DWI-22 | Redactar los objetivos del DW de forma clara y medible | Kristel |
| DWI-23 | Listar las preguntas de negocio que responderán las tablas dinámicas | Juan Daniel |
| DWI-24 | Inventariar tablas, campos y relaciones de la BD fuente | Kristel |
| DWI-25 | Perfilar los datos: nulos, duplicados y formatos inconsistentes | Juan Daniel (con Kristel) |
| DWI-26 | Documentar la estrategia de limpieza para cada problema encontrado | Kristel |
| DWI-27 | Elegir esquema estrella o copo de nieve y justificar | Marco |
| DWI-28 | Definir las tablas de hechos y sus medidas | Krisley |
| DWI-29 | Definir las dimensiones y sus atributos | Krisley |
| DWI-30 | Establecer la granularidad | Juan Daniel |
| DWI-31 | Definir llaves sustitutas para las dimensiones | Marco |
| DWI-32 | Dibujar el diagrama del modelo dimensional | Marco |
| DWI-33 | Crear la base de datos del DW y sus tablas | Marco |


## Daily

El daily es asíncrono, por el chat del grupo. Cada integrante responde qué hizo, qué hará y qué lo bloquea.

### DWI-15: instalación de Alteryx Designer

**Responsable:** Krisley Castro Barrantes  
**Fecha:** 21/10/2026

Se instaló Alteryx Designer x64, versión **2025.2.1.213 (Patch 6)**, en la modalidad Non-Admin Designer, para desarrollar los procesos ETL del proyecto. Se verificó que la herramienta abre su interfaz correctamente.

**Estado:** completado.

### Avances registrados en el repositorio

| Fecha | Integrante | Avance | Commit |
|---|---|---|---|
| 20/10 | Marco | DWI-12 Estructura inicial del repositorio e integrantes | [85e5540](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/85e5540), [98895d4](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/98895d4) |
| 20/10 | Marco | Planificación del sprint 1 | [ccb6d0e](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/ccb6d0e) |
| 21/10 | Marco | DWI-20 Propósito general del proyecto | [fb623d3](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/fb623d3) |
| 21/10 | Kristel, Marco, Juan Daniel | DWI-19 Usuarios de GitHub en el README | [f03283c](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/f03283c), [56c4140](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/56c4140), [5620520](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/5620520) |
| 21/10 | Kristel | DWI-14 Día de Sprint Planning y daily asíncrono | [9c3371f](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/9c3371f) |
| 21/10 | Krisley | DWI-15 Instalación y licencia de Alteryx | [916c02c](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/916c02c) |
| 28/10 | Marco | DWI-27 Esquema dimensional, DWI-67 decisiones de diseño y DWI-31 llaves sustitutas | [0ba6f04](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/0ba6f04), [a4317c0](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/a4317c0), [1f68cff](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/1f68cff) |
| 28/10 | Juan Daniel | DWI-23 Preguntas de negocio (primeras 10) | [e13e987](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/e13e987) |
| 28/10 | Kristel | DWI-22 Objetivos del DW (el commit quedó etiquetado como DWI-17) | [7340951](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/7340951) |
| 30/10 | Kristel | DWI-24 Inventario de la BD fuente | [863a7f6](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/863a7f6) |
| 01/11 | Juan Daniel | DWI-23 Preguntas de negocio ampliadas a 12 | [ad5beea](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/ad5beea) |
| 01/11 | Krisley | DWI-21 Usuarios finales (PR #1) | [64b10a6](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/64b10a6) |
| 02/11 | Krisley | DWI-28 Tablas de hechos (PR #2) y DWI-29 dimensiones (PR #3) | [d207e05](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/d207e05), [860991a](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/860991a) |
| 02/11 | Juan Daniel | DWI-25 Perfilado, flujos 1 a 4, y documento del perfilado | [eed48dd](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/eed48dd), [1e8ec59](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/1e8ec59) |
| 02/11 | Kristel | DWI-25 Perfilado, flujos 5 a 8, y DWI-26 estrategia de limpieza | [2594f5e](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/2594f5e), [c09662b](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/c09662b) |
| 02/11 | Krisley | Ajusta DWI-28 y DWI-29 según el perfilado (PR #4) y DWI-21 según las 12 preguntas (PR #5) | [de98b91](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/de98b91), [22b8385](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/22b8385), [b7123ee](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/b7123ee) |
| 04/11 | Marco | DWI-67 Corrige cifras; DWI-32 diagrama del modelo; DWI-33 scripts del DW | [3b25328](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/3b25328), [da284cd](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/da284cd), [d6eae2e](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/d6eae2e) |
| 04/11 | Juan Daniel | DWI-30 Granularidad; DWI-17 guía para restaurar Pagila y conectarla con Alteryx | [92a2b96](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/92a2b96), [1e55356](https://github.com/marcoalq9/PROYECTO_1_MINERIA-dw-invacom-alteryx/commit/1e55356) |

## Sprint Review (04/11/2026)

Las 24 tareas del sprint quedaron finalizadas en Jira.

| Tareas | Entregable | Evidencia |
|---|---|---|
| DWI-10 a DWI-19 | Equipo, repositorio, tablero y herramientas listos | `README.md`, `datos/README.md` |
| DWI-20 | Propósito general | `docs/analisis/01-proposito-general.md` |
| DWI-21 | Usuarios finales | `docs/analisis/02-usuarios-finales.md` |
| DWI-22 | Objetivos del DW | `docs/analisis/03-objetivos-dw.md` |
| DWI-23 | 12 preguntas de negocio, revisadas con el profesor por Juan Daniel (coordinador) | `docs/analisis/04-preguntas-de-negocio.md` |
| DWI-24 | Inventario de la BD fuente | `docs/analisis/05-inventario-bd-fuente.md` |
| DWI-25 | Perfilado de datos | `docs/analisis/06-perfilado-de-datos.md` y `alteryx/workflows/perfilado/` (8 flujos) |
| DWI-26 | Estrategia de limpieza: 26 problemas con su código y su regla | `docs/analisis/07-estrategia-de-limpieza.md` |
| DWI-27, DWI-31, DWI-67, DWI-70 | Esquema estrella, llaves sustitutas y decisiones de diseño | `docs/modelo/01`, `05` y `06` |
| DWI-28, DWI-29 | Hechos, medidas y dimensiones | `docs/modelo/02-tablas-de-hechos.md`, `03-dimensiones.md` |
| DWI-30 | Granularidad | `docs/modelo/08-granularidad.md` |
| DWI-32 | Diagrama del modelo dimensional | `docs/modelo/04-diagrama-dw.png` |
| DWI-33 | Base `DW_Invacom` con 8 tablas, llaves y restricciones | `sql/01_crear_bd.sql` a `03_hechos.sql` |

**Incremento entregado:** requisitos del negocio definidos, fuente analizada y perfilada, estrategia de limpieza documentada, modelo dimensional diseñado y base del DW creada en SQL Server.

**Hallazgo principal:** el perfilado encontró 16 044 alquileres duplicados (regla C01). Por eso se ajustaron las cifras esperadas de los objetivos, los hechos y las dimensiones dentro del mismo sprint.

**Trabajo con ramas:** se integraron 5 pull requests (#1 a #5) a `main`.


