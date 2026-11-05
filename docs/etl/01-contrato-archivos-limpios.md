# Acuerdo de archivos entre los flujos del ETL

> Jira: DWI-35 (entrega) → DWI-37 y DWI-38 (uso) · Redactado por: Marco Andrey López Quesada
> Define qué archivos entrega `02_limpieza.yxmd` (8 para los flujos 03 y 04, más el de rechazos) y qué columnas trae cada uno, para que `03_dimensiones.yxmd` y `04_hechos.yxmd` los lean sin cambios.

## Cadena del ETL

```
Pagila → 01_extraccion → 02_limpieza → alteryx/datos/limpio/*.yxdb → 03_dimensiones → DW (dim_*)
                                                                   → 04_hechos      → DW (fact_*)
```

## Reglas para todos los archivos

1. **Ubicación:** `alteryx/datos/limpio/`, con la ruta relativa al flujo. En Alteryx: *Options → Advanced Options → Workflow Dependencies → All Relative*.
2. **Formato:** Alteryx Database (`.yxdb`). El `.gitignore` excluye los `.yxdb`, así que estos archivos no se suben al repo: cada integrante los genera en su máquina corriendo `01_extraccion` y `02_limpieza`.
3. **Nombres exactos:** los archivos y las columnas se escriben como aparecen aquí, en minúsculas y sin tildes.
4. **Columnas extra:** se pueden agregar, pero ninguna de las de aquí se quita ni se renombra.
5. **Una fila por llave:** la llave de cada archivo (en **negrita**) no se repite ni viene nula.
6. **Fechas:** `rental_date` y `return_date` se dejan como `DateTime`, tal como salen de Pagila, sin convertir zona horaria.
7. **Cambios:** si hace falta cambiar algo de este acuerdo, se avisa antes a Marco, para ajustar los flujos 03 y 04.

## Archivos para las dimensiones (`03_dimensiones.yxmd`)

### `cliente.yxdb` · 599 filas

| Columna | Tipo | Regla |
|---|---|---|
| **customer_id** | Int32 | |
| nombre_completo | V_WString | `first_name` + espacio + `last_name`, con `TitleCase()` (C14) |
| estado | Bool | `customer.active = 1` (C08) |
| ciudad | V_WString | `"Desconocido"` si falta (C24) |
| pais | V_WString | `"Desconocido"` si falta (C24) |
| ciudad_pais | V_WString | `ciudad + ", " + pais` (C12) |

### `pelicula.yxdb` · 1 000 filas

| Columna | Tipo | Regla |
|---|---|---|
| **film_id** | Int32 | |
| titulo | V_WString | `TitleCase()` (C14) |
| anio_estreno | Int16 | `release_year` tal cual (C10) |
| categoria | V_WString | `"Sin categoría"` si no tiene; si tiene varias, la de menor `category_id` (C21) |
| clasificacion | V_WString | `rating` como texto; `"Sin clasificación"` si viene nulo (C22) |
| idioma | V_WString | `Trim()` (C11) |
| duracion_min | Int16 | `length` |
| tarifa_alquiler | Double | `rental_rate` |
| dias_alquiler_permitidos | Int16 | `rental_duration` |
| costo_reemplazo | Double | `replacement_cost` |

### `tienda.yxdb` · 2 filas

| Columna | Tipo | Regla |
|---|---|---|
| **store_id** | Int32 | |
| ciudad | V_WString | |
| pais | V_WString | |
| ciudad_pais | V_WString | `ciudad + ", " + pais` (C12) |

### `actor.yxdb` · 200 filas

| Columna | Tipo | Regla |
|---|---|---|
| **actor_id** | Int32 | Los dos SUSAN DAVIS quedan separados (C13) |
| nombre_completo | V_WString | `first_name` + espacio + `last_name`, con `TitleCase()` (C14). Si el nombre se repite, todos los repetidos llevan su ID: `Susan Davis (101)` y `Susan Davis (110)` (C13) |

Los nombres repetidos se detectan con una regla general (por ejemplo, *Summarize* que cuente por nombre y marque los que tengan más de 1), sin escribir los IDs a mano. El sufijo es necesario porque Excel agrupa las tablas dinámicas por el texto del nombre: sin él, las dos actrices saldrían en una sola fila.

### `pelicula_actor.yxdb` · 5 462 filas

| Columna | Tipo | Regla |
|---|---|---|
| **film_id** | Int32 | La pareja `film_id` + `actor_id` no se repite |
| **actor_id** | Int32 | |

## Archivos para los hechos (`04_hechos.yxmd`)

### `inventario.yxdb` · 4 581 filas

| Columna | Tipo | Regla |
|---|---|---|
| **inventory_id** | Int32 | |
| film_id | Int32 | |
| store_id | Int32 | Tienda dueña de la copia |

### `alquiler.yxdb` · 16 044 filas

Alquileres válidos, después de C01 (duplicados) y C20 (copias inexistentes).

| Columna | Tipo | Regla |
|---|---|---|
| **rental_id** | Int32 | |
| rental_date | DateTime | |
| return_date | DateTime | Nula si no se devolvió (C06, 183 filas) |
| inventory_id | Int32 | |
| customer_id | Int32 | |
| film_id | Int32 | Desde `inventory` |
| store_id | Int32 | Desde `inventory.store_id` |
| rental_duration | Int16 | Desde `film` |

### `pago.yxdb` · 16 044 filas

Pagos válidos, después de C02 (pagos de duplicados) y C03 (pagos de otro cliente). Sin agrupar: una fila por pago.

| Columna | Tipo | Regla |
|---|---|---|
| **payment_id** | Int32 | |
| rental_id | Int32 | |
| amount | Double | Conserva los 24 pagos en 0 (C04, C26) |

## Archivo de rechazos

### `rechazos.yxdb` · 32 093 filas

Registros excluidos por la limpieza (regla general 2 de `07-estrategia-de-limpieza.md`). Los flujos 03 y 04 no lo leen; sirve para validar y mostrar qué se excluyó.

| Columna | Tipo | Regla |
|---|---|---|
| tabla | V_WString | Tabla de origen: `rental` o `payment` |
| llave | Int32 | `rental_id` o `payment_id` del registro excluido |
| codigo | V_WString | Código del problema: `C01`, `C02`, `C03` o `C20` |
| detalle | V_WString | Descripción breve del motivo |

Si se necesita mostrarlo en la entrega, se agrega después una salida extra a `.csv`.

## Lo que calcula cada flujo

- **02_limpieza (Kristel):** aplica C01–C26, escribe los archivos de arriba y los rechazos.
- **03_dimensiones (Marco):** agrega `rango_duracion`, genera las llaves sustitutas (*Sort* + *Record ID*) y carga `dim_cliente`, `dim_pelicula`, `dim_tienda`, `dim_actor` y `bridge_pelicula_actor`.
- **04_hechos (Marco):** agrupa los pagos por alquiler, calcula `fecha_key`, `dias_alquilado`, `dias_atraso`, `devuelto`, `devolucion_tardia` y `pago_cero`, busca las llaves y carga `fact_alquiler` y `fact_inventario`.
- **Dimensión tiempo (Krisley, DWI-36):** carga `dim_fecha` con todos los días entre el primer y el último `rental_date` (24/05/2005 al 14/02/2017).

## Validación al entregar

| Archivo | Filas | Control |
|---|---:|---|
| `alquiler.yxdb` | 16 044 | 183 con `return_date` nula |
| `pago.yxdb` | 16 044 | Suma de `amount` = 67 406,56 |
| `inventario.yxdb` | 4 581 | Tienda 1: 2 270 · Tienda 2: 2 311 |
| `cliente.yxdb` | 599 | 15 con `estado` = False |
| `actor.yxdb` | 200 | 2 nombres con sufijo de ID |
| `rechazos.yxdb` | 32 093 | C01 = 16 044 · C02 = 16 044 · C03 = 5 |
