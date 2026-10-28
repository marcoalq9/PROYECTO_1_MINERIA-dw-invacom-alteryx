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

Nota: Las cifras de validación (cantidad de filas, totales de ingresos) se fijarán una vez que el equipo confirme la fuente oficial del ETL, ya que los CSV y la base de datos construida con los scripts SQL contienen datos distintos.
