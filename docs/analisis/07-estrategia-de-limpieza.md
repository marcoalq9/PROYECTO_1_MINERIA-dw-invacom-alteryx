# Estrategia de limpieza de datos

> Jira: DWI-26 · Responsable: Kristel Ramírez
> Fuente: base `pagila_dvd_rental` restaurada del respaldo entregado. El detalle de tablas y campos está en `05-inventario-bd-fuente.md`.


## 1. Reglas generales

1. **La base fuente no se modifica.** Toda la limpieza se hace en los flujos de Alteryx.
2. **Nada se borra en silencio.** Lo que se excluye va a un archivo de rechazos con el código del problema (por ejemplo, `C01`).
3. **Si el dato es real pero especial, se marca.** No se elimina: se le agrega una bandera, como `devuelto = 0` en un alquiler sin devolver.
4. **Lo que no llega al DW no se limpia.** Esos campos simplemente no se cargan.
5. **Cada regla se aplica en un solo flujo.** La columna *Flujo* de la matriz dice dónde. Si una regla se aplica después de `02_limpieza`, este flujo solo debe entregar el dato intacto para que el siguiente la pueda aplicar.

## 2. Matriz de problemas

**Flujos:** `01` = `01_extraccion` (DWI-34) · `02` = `02_limpieza` (DWI-35) · `03` = `03_dimensiones` (DWI-37) · `04` = `04_hechos` (DWI-38) · `Vista` = vista SQL de reportes.

| Código | Tabla.campo | Problema | Afectados | Tratamiento | Flujo |
|---|---|---|---:|---|---|
| C01 | `rental` | Alquileres duplicados (misma copia y cliente, ±30 min) | 16.044 | **Excluir** → rechazos | 02 |
| C02 | `payment` | Pagos de los alquileres duplicados | 16.044 | **Excluir** → rechazos | 02 |
| C03 | `payment.customer_id` | Pagos de otros clientes en el alquiler 4591 | 5 | **Excluir** → rechazos | 02 |
| C04 | `payment.amount` | Pagos en 0 | 24 | Conservar; bandera `pago_cero` en el hecho | 02 conserva · 04 marca |
| C05 | `payment.payment_date` | Pagos fechados en 2017 para alquileres de 2005 | 32.093 | No se usa; se toma `rental_date` | 02 (no va en `pago.yxdb`) |
| C06 | `rental.return_date` | Alquileres sin devolver | 183 (tras C01) | Conservar; `devuelto = 0` en el hecho | 02 conserva · 04 marca |
| C07 | `rental.rental_date` | Alquileres el 14/02/2017, 11 años después del resto | 182 (tras C01) | Conservar como día atípico | 02 |
| C08 | `customer.activebool` / `active` | Dos campos de estado que se contradicen | 15 | Usar solo `active`, como Bool | 02 |
| C09 | `customer.create_date` | Todos los clientes con alta el 14/02/2017 | 599 | No se carga | 01 |
| C10 | `film.release_year` | Estreno posterior al alquiler | 472 películas | Se carga tal cual, solo descriptivo | 02 |
| C11 | `language.name` | Espacios de relleno (`char(20)`) | 6 | `Trim()` por precaución | 01 y 02 |
| C12 | `city.city` | Dos ciudades London (Canadá y Reino Unido) | 2 | Unir por `city_id` y crear `ciudad_pais` | 02 |
| C13 | `actor` | Dos actores SUSAN DAVIS (101 y 110) | 2 | Separados por llave; el ID se agrega al nombre repetido | 02 |
| C14 | `actor`, `customer`, `film.title` | Texto en MAYÚSCULAS | 1.799 | `TitleCase()` | 02 |
| C15 | `staff` | Empleados 3, 4 y 5 solo aparecen en el bloque duplicado | 3 | Sin efecto; `staff` no se extrae | 01 |
| C16 | `film.original_language_id` | Nulo en todas las películas | 1.000 | No se carga | 01 |
| C17 | `address` | `address2`, `postal_code`, `district` y `phone` con nulos o vacíos | 603 | No se cargan | 01 |
| C18 | `staff`, `customer`, `address` | Datos sensibles (contraseña, usuario, correo, teléfono, foto) | — | No se cargan | 01 |
| C19 | `inventory` | Películas sin copias en una tienda o en ninguna | 42 películas · 479 combinaciones | Mostrar con 0 en la vista de reportes, sin filas ficticias en `fact_inventario` | Vista |
| C20 | `rental.inventory_id` | Alquiler con una copia que no existe | 0 (control) | **Excluir** → rechazos | 02 |
| C21 | `film_category` | Película sin categoría o con varias | 0 (control) | `"Sin categoría"` o quedarse con la de menor `category_id` | 02 |
| C22 | `film.rating` | Clasificación nula | 0 (control) | `"Sin clasificación"` | 02 |
| C23 | `film.rental_duration` | Plazo en 0 o negativo | 0 (control) | `devolucion_tardia = Null` | 02 conserva · 04 marca |
| C24 | `customer` → `country` | Cliente sin ciudad o país | 0 (control) | `"Desconocido"` | 02 |
| C25 | `film_actor` | Películas sin actores (257, 323 y 803) | 3 | Conservar; no salen en el ranking de actores | Ninguno (informativo) |
| C26 | `payment.amount` | `numeric(5,2)` no soporta la suma total | Toda la columna | Convertir a `Double` | 02 |

Los casos marcados como "control" no aparecen hoy, pero la regla queda en el flujo por si los datos cambian.

## 3. Detalle de cada problema

### C01 · Alquileres duplicados

`rental` tiene 32.088 filas en dos bloques de 16.044: el original (`rental_id` 1 a 16049) y un segundo bloque (16251 a 32294) en el que cada alquiler repite la copia y el cliente de uno del primero, con una diferencia de máximo 30 minutos.

Se tratan como duplicados porque:

- Los dos bloques tienen la misma distribución por mes y los mismos 183 alquileres sin devolver.
- Las fechas del segundo bloque tienen milisegundos, como si se hubieran generado a partir de las originales.
- Solo los atienden los empleados 3, 4 y 5, creados un día antes del respaldo.
- Sus montos (5 a 15) no siguen la tarifa de las películas.
- Al quitarlos, las consultas de referencia de Sports y Gina Degeneres coinciden (sección 4). Con ellos, no.

**Regla:** dos alquileres son duplicados si tienen la misma copia, el mismo cliente y sus fechas difieren en 30 minutos o menos. Se conserva el de `rental_id` menor. No se filtra por rango de ID para no depender de esta base en particular.

**En Alteryx (02):** *Join* de `rental` consigo misma por `inventory_id` y `customer_id` → *Filter* `[Right_rental_id] > [rental_id] AND Abs(DateTimeDiff([Right_rental_date],[rental_date],"seconds")) <= 1800` → *Unique* sobre `Right_rental_id` → *Join* contra `rental` para separar válidos (salida **L**) y rechazos (salida **J**).

### C02 · Pagos de alquileres duplicados

Los 16.044 pagos de los duplicados suman 160.352,36, más del doble de los ingresos reales (67.406,56). Se excluyen al cruzar `payment` con los alquileres válidos: lo que no cruza va a rechazos.

### C03 · Pagos de otro cliente

El alquiler 4591 es del cliente 182, pero tiene 6 pagos de clientes distintos. Se deja solo el del cliente 182 (3,99) y los otros 5 van a rechazos. Así cada alquiler queda con un solo pago y no se le suman ingresos a clientes que no alquilaron.

### C04 · Pagos en 0

Son alquileres reales que aún no se cobran. **En 02** se conservan en `pago.yxdb` sin filtrarlos. **En 04**, después de agrupar los pagos por alquiler, se marca `pago_cero = IIF([monto] = 0, 1, 0)`, que permite sacarlos del monto promedio si hace falta.

### C05 · Fecha de pago desfasada

Todos los pagos están en 2017 y casi todos los alquileres en 2005. Por eso todas las preguntas, incluidas las de ingresos, usan la fecha del alquiler, y `payment_date` no se incluye en `pago.yxdb`.

### C06 · Alquileres sin devolver

**En 02** se conservan con `return_date` nula, sin convertirla a otro valor. **En 04** se calculan estas banderas:

- `devuelto = IIF(IsNull([return_date]), 0, 1)`
- `devolucion_tardia = IIF(IsNull([return_date]), Null(), IIF([return_date] > DateTimeAdd([rental_date],[rental_duration],"days"), 1, 0))`

El atraso se mide contra la fecha y hora límite, no contra días enteros; si no, el porcentaje bajaría de 51,2 % a 40,4 %. Los no devueltos no cuentan como a tiempo ni como tarde, y se reportan aparte.

### C07 · Día atípico: 14/02/2017

Quedan 182 alquileres en esa fecha, todos sin devolver. Es la misma fecha de alta de todos los clientes, o sea, la fecha de carga de la base. Se conservan porque son alquileres válidos, y en los informes se pueden aislar con el filtro de fechas.

### C08 · Estado del cliente

`activebool` está en verdadero para los 599 clientes, así que no distingue a nadie. Se usa `active`, como booleano: `estado = [active] = 1`. Así coincide con `dim_cliente.estado` (`BIT`) y con el contrato de archivos limpios.

La etiqueta "Activo" / "Inactivo" no se guarda en el DW: se aplica en la capa de informes (vista de reportes o etiquetas de la tabla dinámica en Excel).

### C09 · Fecha de alta del cliente

Todos los clientes tienen la fecha de carga de la base, no la real. Ninguna pregunta la necesita, así que no se extrae.

### C10 · Año de estreno

Hay 472 películas con estreno después de 2005, y suman 7.625 alquileres. No hay cómo corregirlo y excluirlas quitaría casi la mitad de los datos, así que se carga como dato descriptivo y se deja documentado.

### C11 a C14 · Textos y nombres

- **Idioma (C11):** la extracción ya aplica `TRIM(name)` en la consulta, y por ODBC los espacios llegan limpios. En 02 se repite `Trim([name])` por precaución, por si cambia el conector.
- **London (C12):** cliente y tienda se unen con su ciudad por `city_id`, no por nombre, para no mezclar las dos London. En el archivo final no va `city_id`: basta con `ciudad_pais = [ciudad] + ", " + [pais]`, que distingue las ciudades homónimas en los informes.
- **SUSAN DAVIS (C13):** cada uno conserva su `actor_id`. Como Excel agrupa por el texto que se ve, a los nombres completos repetidos se les agrega el ID, por ejemplo "Susan Davis (101)" y "Susan Davis (110)"; los demás actores quedan sin cambio. En Alteryx: *Summarize* con `Count` por `nombre_completo` → *Join* de vuelta por `nombre_completo` → *Formula* `IIF([Count] > 1, [nombre_completo] + " (" + ToString([actor_id]) + ")", [nombre_completo])`. No cambia ninguna columna del contrato.
- **Mayúsculas (C14):** `TitleCase()` en nombres y títulos. Es solo presentación y no cambia ningún conteo. Se aplica antes de C13, para que la comparación de nombres repetidos use el texto final.

### C15 a C18 · Campos y tablas que no se usan

No hay dimensión de empleado, y después de C01 los empleados 3, 4 y 5 quedan sin alquileres; por eso `staff` no se extrae. Los campos de C16 a C18 no se incluyen en las consultas de `01_extraccion`, así que no necesitan limpieza.

### C19 · Películas sin copias

`inventario.yxdb` y `fact_inventario` conservan una fila por copia física (4.581). Las 42 películas sin ninguna copia y las 479 combinaciones película–tienda sin copias se muestran con 0 desde una vista SQL de reportes que cruza todas las películas con todas las tiendas (ver `docs/modelo/02-tablas-de-hechos.md`). No se agregan filas ficticias a la tabla de hechos, y 02 no arma la combinación película × tienda.

### C20 a C26 · Controles por pregunta de negocio

Salieron de revisar qué datos necesita cada pregunta.

| Código | Por qué importa | Cómo se aplica |
|---|---|---|
| C20 | Un alquiler sin copia no tiene película ni tienda | 02: *Join* `rental` × `inventory`; la salida **L** va a rechazos |
| C21 | Una película con dos categorías se contaría dos veces | 02: *Summarize* por `film_id` + *Filter* `Count > 1` |
| C22 | Una película sin clasificación desaparecería del informe | 02: `IIF(IsNull([rating]), "Sin clasificación", [rating])` |
| C23 | Con plazo 0, todo alquiler saldría tarde | 02 entrega `rental_duration` sin filtrar; 04 deja `devolucion_tardia = Null` si `rental_duration <= 0` |
| C24 | Un cliente sin ciudad o país quedaría fuera del informe geográfico | 02: *Join* encadenado; lo que no cruza recibe `"Desconocido"` |
| C25 | Explica por qué el ranking de actores no suma el total de alquileres | Ninguna acción; se documenta en el informe |
| C26 | Sin el cambio de tipo, la suma de ingresos falla | 02: *Select* `amount` → `Double` |

## 4. Validación después de limpiar

| Control | Valor esperado | Dónde se valida |
|---|---:|---|
| Alquileres válidos | 16.044 | `alquiler.yxdb` y `fact_alquiler` |
| Pagos válidos | 16.044 (uno por alquiler) | `pago.yxdb` |
| Ingresos totales | 67.406,56 | `pago.yxdb` y `fact_alquiler` |
| Alquileres sin devolver | 183 | `alquiler.yxdb` (`return_date` nula) |
| Pagos en 0 | 24 | `pago.yxdb` |
| Clientes inactivos | 15 | `cliente.yxdb` (`estado` = False) |
| Actores con ID en el nombre | 2 (Susan Davis 101 y 110) | `actor.yxdb` |
| Registros en rechazos | 32.093 (C01 + C02 + C03) | Archivo de rechazos de 02 |
| Películas con categoría y clasificación | 100 % | `pelicula.yxdb` |
| Clientes con ciudad y país | 100 % | `cliente.yxdb` |
| Copias de inventario | 4.581 (tienda 1: 2.270; tienda 2: 2.311) | `inventario.yxdb` y `fact_inventario` |
| % de devoluciones tardías | 51,2 % | `fact_alquiler` (04) |
| Ingresos de Sports (query_3) | **5.314,21** ✔ | DW / Excel |
| Alquileres de Gina Degeneres (query_2) | **753** ✔ | DW / Excel |
