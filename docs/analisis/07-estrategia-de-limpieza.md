# Estrategia de limpieza de datos

> Jira: DWI-26 · Responsable: Kristel Ramírez
> Fuente: base `pagila_dvd_rental` restaurada del respaldo entregado. El detalle de tablas y campos está en `05-inventario-bd-fuente.md`.

## 1. Reglas generales

1. **La base fuente no se modifica.** Toda la limpieza se hace en los flujos de Alteryx.
2. **Nada se borra en silencio.** Lo que se excluye va a un archivo de rechazos con el código del problema (por ejemplo, `C01`).
3. **Si el dato es real pero especial, se marca.** No se elimina: se le agrega una bandera, como `devuelto = 0` en un alquiler sin devolver.
4. **Lo que no llega al DW no se limpia.** Esos campos simplemente no se cargan.


## 2. Matriz de problemas

| Código | Tabla.campo | Problema | Afectados | Tratamiento |
|---|---|---|---:|---|
| C01 | `rental` | Alquileres duplicados (misma copia y cliente, ±30 min) | 16.044 | **Excluir** → rechazos |
| C02 | `payment` | Pagos de los alquileres duplicados | 16.044 | **Excluir** → rechazos |
| C03 | `payment.customer_id` | Pagos de otros clientes en el alquiler 4591 | 5 | **Excluir** → rechazos |
| C04 | `payment.amount` | Pagos en 0 | 24 | Conservar con bandera `pago_cero` |
| C05 | `payment.payment_date` | Pagos fechados en 2017 para alquileres de 2005 | 32.093 | No se usa; se toma `rental_date` |
| C06 | `rental.return_date` | Alquileres sin devolver | 183 (tras C01) | Conservar con `devuelto = 0` |
| C07 | `rental.rental_date` | Alquileres el 14/02/2017, 11 años después del resto | 182 (tras C01) | Conservar como día atípico |
| C08 | `customer.activebool` / `active` | Dos campos de estado que se contradicen | 15 | Usar solo `active` |
| C09 | `customer.create_date` | Todos los clientes con alta el 14/02/2017 | 599 | No se carga |
| C10 | `film.release_year` | Estreno posterior al alquiler | 472 películas | Se carga tal cual, solo descriptivo |
| C11 | `language.name` | Espacios de relleno (`char(20)`) | 6 | `Trim()` por precaución |
| C12 | `city.city` | Dos ciudades London (Canadá y Reino Unido) | 2 | Usar `city_id` y crear `ciudad_pais` |
| C13 | `actor` | Dos actores SUSAN DAVIS (101 y 110) | 2 | Se mantienen separados |
| C14 | `actor`, `customer`, `film.title` | Texto en MAYÚSCULAS | 1.799 | `TitleCase()` |
| C15 | `staff` | Empleados 3, 4 y 5 solo aparecen en el bloque duplicado | 3 | Sin efecto |
| C16 | `film.original_language_id` | Nulo en todas las películas | 1.000 | No se carga |
| C17 | `address` | `address2`, `postal_code`, `district` y `phone` con nulos o vacíos | 603 | No se cargan |
| C18 | `staff`, `customer`, `address` | Datos sensibles (contraseña, usuario, correo, teléfono, foto) | — | No se cargan |
| C19 | `inventory` | Películas sin copias en una tienda o en ninguna | 42 películas · 479 combinaciones | Mostrar con 0 en `fact_inventario` |
| C20 | `rental.inventory_id` | Alquiler con una copia que no existe | 0 (control) | **Excluir** → rechazos |
| C21 | `film_category` | Película sin categoría o con varias | 0 (control) | `"Sin categoría"` o quedarse con la de menor `category_id` |
| C22 | `film.rating` | Clasificación nula | 0 (control) | `"Sin clasificación"` |
| C23 | `film.rental_duration` | Plazo en 0 o negativo | 0 (control) | `devolucion_tardia = Null` |
| C24 | `customer` → `country` | Cliente sin ciudad o país | 0 (control) | `"Desconocido"` |
| C25 | `film_actor` | Películas sin actores (257, 323 y 803) | 3 | Conservar; no salen en el ranking de actores |
| C26 | `payment.amount` | `numeric(5,2)` no soporta la suma total | Toda la columna | Convertir a `Double` |

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

**En Alteryx:** *Join* de `rental` consigo misma por `inventory_id` y `customer_id` → *Filter* `[Right_rental_id] > [rental_id] AND Abs(DateTimeDiff([Right_rental_date],[rental_date],"seconds")) <= 1800` → *Unique* sobre `Right_rental_id` → *Join* contra `rental` para separar válidos (salida **L**) y rechazos (salida **J**).

### C02 · Pagos de alquileres duplicados

Los 16.044 pagos de los duplicados suman 160.352,36, más del doble de los ingresos reales (67.406,56). Se excluyen al cruzar `payment` con los alquileres válidos: lo que no cruza va a rechazos.

### C03 · Pagos de otro cliente

El alquiler 4591 es del cliente 182, pero tiene 6 pagos de clientes distintos. Se deja solo el del cliente 182 (3,99) y los otros 5 van a rechazos. Así cada alquiler queda con un solo pago y no se le suman ingresos a clientes que no alquilaron.

### C04 · Pagos en 0

Son alquileres reales que aún no se cobran. Se conservan con `pago_cero = IIF([amount] = 0, 1, 0)`, que permite sacarlos del monto promedio si hace falta.

### C05 · Fecha de pago desfasada

Todos los pagos están en 2017 y casi todos los alquileres en 2005. Por eso todas las preguntas, incluidas las de ingresos, usan la fecha del alquiler.

### C06 · Alquileres sin devolver

Se conservan con estas fórmulas:

- `devuelto = IIF(IsNull([return_date]), 0, 1)`
- `devolucion_tardia = IIF(IsNull([return_date]), Null(), IIF([return_date] > DateTimeAdd([rental_date],[rental_duration],"days"), 1, 0))`

El atraso se mide contra la fecha y hora límite, no contra días enteros; si no, el porcentaje bajaría de 51,2 % a 40,4 %. Los no devueltos no cuentan como a tiempo ni como tarde, y se reportan aparte.

### C07 · Día atípico: 14/02/2017

Quedan 182 alquileres en esa fecha, todos sin devolver. Es la misma fecha de alta de todos los clientes, o sea, la fecha de carga de la base. Se conservan porque son alquileres válidos, y en los informes se pueden aislar con el filtro de fechas.

### C08 · Estado del cliente

`activebool` está en verdadero para los 599 clientes, así que no distingue a nadie. Se usa `active`: `estado = IIF([active] = 1, "Activo", "Inactivo")`.

### C09 · Fecha de alta del cliente

Todos los clientes tienen la fecha de carga de la base, no la real. Ninguna pregunta la necesita, así que no se carga.

### C10 · Año de estreno

Hay 472 películas con estreno después de 2005, y suman 7.625 alquileres. No hay cómo corregirlo y excluirlas quitaría casi la mitad de los datos, así que se carga como dato descriptivo y se deja documentado.

### C11 a C14 · Textos y nombres

- **Idioma:** `Trim([name])` quita los espacios de relleno. Por ODBC ya llegan limpios, pero se deja por precaución.
- **London:** `ciudad_pais = [city] + ", " + [country]` evita mezclar ciudades con el mismo nombre.
- **SUSAN DAVIS:** cada uno tiene su propia llave y, cuando el nombre se repite, se le agrega el ID para distinguirlos en Excel.
- **Mayúsculas:** `TitleCase()` en nombres y títulos. Es solo presentación y no cambia ningún conteo.

### C15 a C18 · Campos y tablas que no se usan

No hay dimensión de empleado, y después de C01 los empleados 3, 4 y 5 quedan sin alquileres. Los campos de C16 a C18 se quitan con *Select* en la extracción, así que no necesitan limpieza.

### C19 a C26 · Controles por pregunta de negocio

Salieron de revisar qué datos necesita cada pregunta.

| Código | Por qué importa | En Alteryx |
|---|---|---|
| C19 | El inventario debe mostrar 0 en las películas sin copias | *Append Fields* película × tienda + *Join* con el conteo de copias |
| C20 | Un alquiler sin copia no tiene película ni tienda | *Join* `rental` × `inventory`; la salida **L** va a rechazos |
| C21 | Una película con dos categorías se contaría dos veces | *Summarize* por `film_id` + *Filter* `Count > 1` |
| C22 | Una película sin clasificación desaparecería del informe | `IIF(IsNull([rating]), "Sin clasificación", [rating])` |
| C23 | Con plazo 0, todo alquiler saldría tarde | `devolucion_tardia = Null` si `rental_duration <= 0` |
| C24 | Un cliente sin ciudad o país quedaría fuera del informe geográfico | *Join* encadenado; lo que no cruza recibe `"Desconocido"` |
| C25 | Explica por qué el ranking de actores no suma el total de alquileres | *Join* `film` × `film_actor` |
| C26 | Sin el cambio de tipo, la suma de ingresos falla | *Select*: `amount` → `Double` |

## 4. Validación después de limpiar

| Control | Valor esperado |
|---|---:|
| Alquileres en `fact_alquiler` | 16.044 |
| Pagos válidos | 16.044 (uno por alquiler) |
| Ingresos totales | 67.406,56 |
| Alquileres sin devolver | 183 |
| Pagos en 0 | 24 |
| % de devoluciones tardías | 51,2 % |
| Ingresos de Sports (query_3) | **5.314,21** ✔ |
| Alquileres de Gina Degeneres (query_2) | **753** ✔ |
| Registros en rechazos | 32.093 (C01 + C02 + C03) |
| Películas con categoría y clasificación | 100 % |
| Clientes con ciudad y país | 100 % |
| Copias en `fact_inventario` | 4.581 (tienda 1: 2.270; tienda 2: 2.311) |

