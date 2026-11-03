# Invacom Inc S.A. — Objetivos del data warehouse

>  DWI-17 · Responsable: Kristel Ramírez



## Objetivos del data warehouse por necesidad de negocio

### 1. Gerencia: control de ingresos 
- **Objetivo:** Proveer el monto total y el monto promedio cobrado por mes y por tienda.
- **Meta medible:** Ingresos disponibles para el 100 % de los meses del período y para las 2 tiendas. La suma de ingresos del data warehouse coincide con la suma de pagos válidos de la fuente.

### 2. Operaciones: volumen de alquileres
- **Objetivo:** Medir la cantidad de alquileres realizados por mes en cada tienda.
- **Meta medible:** El 100 % de los alquileres de la fuente está cargado, con exactamente una fila por alquiler.

### 3. Operaciones: cumplimiento de plazos de devolución 
- **Objetivo:** Medir el porcentaje de devoluciones fuera del plazo permitido por tienda y mes, para identificar problemas de cumplimiento.
- **Meta medible:** El porcentaje se calcula sobre los alquileres devueltos (Σ devoluciones tardías / Σ devueltos), y el 100 % de los alquileres no devueltos queda identificado y se reporta aparte.

### 4. Catálogo: desempeño de títulos y actores (preguntas 3 y 7)
- **Objetivo:** Identificar las 10 películas y los 10 actores con más alquileres en cualquier período que el usuario seleccione.
- **Meta medible:** Rankings filtrables por cualquier rango de fechas. El conteo por actor coincide con la consulta de referencia entregada (query_2).

### 5. Gerencia comercial: rentabilidad del catálogo 
- **Objetivo:** Determinar qué categorías generan más ingresos cada mes y qué clasificación de películas (G, PG, PG-13, R, NC-17) genera más alquileres e ingresos en cada tienda.
- **Meta medible:** El 100 % de las películas alquiladas tiene categoría y clasificación asignadas. Los ingresos por categoría coinciden con la consulta de referencia entregada (query_3).

### 6. Mercadeo: conocimiento de clientes 
- **Objetivo:** Identificar a los 10 clientes de mayor gasto en el período seleccionado y la ubicación (país y ciudad) de los clientes con más alquileres.
- **Meta medible:** El 100 % de los clientes tiene ciudad y país asignados. Las ciudades con el mismo nombre en países distintos se distinguen correctamente.

### 7. Inventario: existencias por tienda 
- **Objetivo:** Conocer la cantidad de copias físicas de cada película registradas en cada tienda.
- **Meta medible:** El total de copias del data warehouse coincide con el inventario de la fuente, y las películas sin copias se muestran con 0.

## Objetivos de calidad y operación

| Área | Objetivo | Meta medible |
|---|---|---|
| Autoservicio | Que los usuarios respondan sus preguntas sin depender del equipo técnico | preguntas respondidas en Excel con tablas dinámicas y filtros de fecha y tienda |
| Confiabilidad | Que ningún informe muestre montos o conteos inflados | 0 alquileres duplicados y 0 llaves sin correspondencia en las tablas de hechos |
| Calidad de datos | Tratar todos los problemas detectados en la fuente y dejar evidencia | 100 % de los hallazgos de la matriz de calidad con una regla aplicada; registros excluidos guardados en un archivo de rechazos |
| Actualización | Que el data warehouse se pueda recargar y los informes se actualicen sin rehacer trabajo | Los flujos de Alteryx corren de principio a fin sin pasos manuales, y Excel se actualiza con "Actualizar todo" |
| Seguridad | No almacenar datos sensibles sin valor analítico | 0 campos de contraseña, usuario, imagen, correo o teléfono cargados |

## Estado de verificación (perfilado, DWI-25)

La fuente oficial del ETL es la base PostgreSQL `pagila_dvd_rental` restaurada del respaldo entregado. El perfilado en Alteryx (`06-perfilado-de-datos.md`) confirmó que los datos permiten cumplir estas metas:

| Objetivo | Meta | Qué mostró el perfilado |
|---|---|---|
| 1. Control de ingresos | Ingresos del DW = pagos válidos de la fuente | Ingreso válido: **67.406,56** (227.768,87 − 160.352,36 de pagos de duplicados − 9,95 de pagos de otro cliente) |
| 2. Volumen de alquileres | Una fila por alquiler | **16.044** alquileres válidos después de excluir 16.044 duplicados |
| 3. Plazos de devolución | No devueltos identificados aparte | 183 alquileres sin devolver tras quitar duplicados; plazo válido (3 a 7 días) en todas las películas |
| 5. Rentabilidad del catálogo | 100 % de películas con categoría y clasificación | ✔ Cada película tiene exactamente una categoría y una clasificación |
| 6. Conocimiento de clientes | 100 % de clientes con ciudad y país | ✔ Los 599 clientes llegan a ciudad y país; London se distingue por país |
| 7. Existencias por tienda | Películas sin copias con 0 | 4.581 copias; 42 películas sin ninguna copia y 479 combinaciones película–tienda sin copias que deben mostrarse con 0 |
| Confiabilidad | 0 alquileres duplicados | Los 16.044 duplicados quedan identificados con la regla C01 |

Las cifras exactas de validación del DW están en la sección 4 de `07-estrategia-de-limpieza.md`.
