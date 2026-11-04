# Establecimiento de la granularidad del Data Warehouse

## 1. Definición general

La granularidad define exactamente qué representa una fila de cada tabla del Data Warehouse de Invacom Inc S.A.

Se almacenarán los alquileres a nivel de evento individual y el inventario a nivel de copia física. Este detalle permitirá analizar los datos por cliente, película, tienda y período, conservando la información necesaria para calcular los indicadores de negocio.

El modelo estará compuesto por dos tablas de hechos, cinco dimensiones y una tabla puente.

## 2. Granularidad de las tablas de hechos

### 2.1. Tabla fact_alquiler

**Granularidad: cada fila representa un alquiler válido de una copia física de una película, realizado por un cliente, después de aplicar las reglas de limpieza y excluir los alquileres duplicados.**

Cada alquiler se identificará mediante `alquiler_id`, proveniente de `rental.rental_id`. Este identificador deberá ser único en la tabla.

La fila se relacionará con las siguientes dimensiones:

| Dimensión | Relación con el alquiler |
|---|---|
| Fecha | Día de inicio del alquiler, obtenido de `rental.rental_date`. |
| Cliente | Cliente que realizó el alquiler. |
| Película | Película correspondiente a la copia alquilada. |
| Tienda | Tienda propietaria de la copia, obtenida de `inventory.store_id`. |

Las medidas corresponderán al alquiler individual: cantidad de alquileres, monto pagado, cantidad de pagos, días alquilados, días de atraso e indicadores de devolución.

#### Tratamiento de los pagos

Los pagos válidos se agruparán por `rental_id` antes de incorporarlos a la tabla de hechos.

- `cantidad` tendrá el valor 1 por cada alquiler.
- `monto` contendrá la suma de los pagos válidos asociados al alquiler.
- `cantidad_pagos` contendrá el número de pagos válidos asociados.
- Los alquileres sin pagos válidos se conservarán con `monto = 0` y `cantidad_pagos = 0`.
- Una devolución actualizará las medidas del alquiler correspondiente, sin generar una fila adicional.

Por lo tanto, un alquiler con varios pagos ocupará una sola fila en `fact_alquiler`.

#### Ejemplo ilustrativo

Los siguientes datos son ficticios y muestran únicamente algunos campos para explicar la granularidad.

| alquiler_id | inventario_id | cantidad | monto | cantidad_pagos |
|---|---|---:|---:|---:|
| 501 | 80 | 1 | 5,99 | 2 |
| 502 | 80 | 1 | 2,99 | 1 |
| 503 | 81 | 1 | 0,00 | 0 |

El alquiler 501 tiene dos pagos válidos que suman 5,99, pero ocupa una sola fila. Los alquileres 501 y 502 corresponden a la misma copia física en momentos distintos, por lo que se almacenan como dos alquileres diferentes.

#### Nivel temporal

Los registros se conservarán por alquiler individual y se relacionarán con el día de inicio del alquiler.

Los análisis por mes, trimestre y año se obtendrán mediante la dimensión Fecha. Los ingresos agrupados por período corresponderán a los pagos válidos asociados a los alquileres iniciados en ese período, conforme a la decisión de diseño del modelo.

### 2.2. Tabla fact_inventario

**Granularidad: cada fila representa una copia física de una película registrada en una tienda.**

Cada copia se identificará mediante `inventario_id`, proveniente de `inventory.inventory_id`. Este identificador deberá ser único en la tabla.

Cada registro se relacionará con las dimensiones Película y Tienda. La medida `cantidad_copias` tendrá el valor 1 por cada copia física.

#### Ejemplo ilustrativo

Los siguientes datos son ficticios.

| inventario_id | pelicula_key | tienda_key | cantidad_copias |
|---|---|---|---:|
| 80 | 20 | 1 | 1 |
| 81 | 20 | 1 | 1 |
| 82 | 20 | 2 | 1 |

La película 20 tiene dos copias registradas en la tienda 1 y una en la tienda 2, para un total de tres copias.

Aunque la copia 80 se alquile varias veces, aparecerá una sola vez en `fact_inventario`. Sus alquileres se registrarán individualmente en `fact_alquiler`.

#### Alcance temporal del inventario

La tabla representará las copias registradas en la base fuente. No almacenará una fila por copia y día ni un historial de entradas, salidas o traslados.

Para analizar la rotación durante un trimestre, se comprobará si cada copia tiene alquileres registrados en `fact_alquiler` dentro del período seleccionado.

Las combinaciones película–tienda sin copias se mostrarán con valor cero mediante una vista de reportes, sin agregar registros ficticios a `fact_inventario`.

## 3. Granularidad de las dimensiones

| Dimensión | Qué representa una fila | Llave sustituta | Identificador de origen |
|---|---|---|---|
| `dim_fecha` | Un día del calendario dentro del rango definido para el análisis. | `fecha_key`, en formato AAAAMMDD. | Fecha del calendario. |
| `dim_cliente` | Un cliente, con sus atributos descriptivos y geográficos. | `cliente_key`. | `customer_id`. |
| `dim_pelicula` | Una película del catálogo, con sus características. | `pelicula_key`. | `film_id`. |
| `dim_tienda` | Una tienda, con su información de ubicación. | `tienda_key`. | `store_id`. |
| `dim_actor` | Un actor identificado en la fuente. | `actor_key`. | `actor_id`. |

El modelo definido conservará una sola fila por cliente, película, tienda y actor.

La categoría y el idioma se almacenarán como atributos de `dim_pelicula`. La ciudad y el país se incorporarán como atributos de `dim_cliente` y `dim_tienda`, sin modificar la granularidad de estas dimensiones.

Los actores con nombres iguales se mantendrán separados mediante su identificador de origen y su llave sustituta.

## 4. Granularidad de la tabla puente

### 4.1. Tabla bridge_pelicula_actor

**Granularidad: cada fila representa una asociación única entre una película y un actor que participa en ella.**

La combinación de `pelicula_key` y `actor_key` deberá ser única.

Esta estructura permitirá representar que una película tiene varios actores y que un actor participa en varias películas, conservando una sola fila por película en `dim_pelicula`.

Al consultar los alquileres por actor, un mismo alquiler podrá asociarse con varios actores de la película. Por esta razón, los resultados por actor no deberán sumarse directamente para obtener el total general de alquileres o ingresos.

## 5. Reglas de validación de la granularidad

| Tabla | Validación requerida |
|---|---|
| `fact_alquiler` | Una sola fila por `alquiler_id`, sin identificadores nulos. |
| `fact_inventario` | Una sola fila por `inventario_id`, sin identificadores nulos. |
| `dim_fecha` | Una sola fila por fecha del calendario. |
| `dim_cliente` | Una sola fila por `customer_id`. |
| `dim_pelicula` | Una sola fila por `film_id`. |
| `dim_tienda` | Una sola fila por `store_id`. |
| `dim_actor` | Una sola fila por `actor_id`. |
| `bridge_pelicula_actor` | Una sola fila por combinación de `pelicula_key` y `actor_key`. |

Durante el proceso ETL se comprobará que:

1. Los pagos válidos se agrupen por alquiler antes de incorporarse a `fact_alquiler`.
2. Las uniones con las dimensiones no multipliquen los registros de las tablas de hechos.
3. Los alquileres válidos sin pagos o sin devolución se conserven según las reglas de limpieza.
4. Las copias físicas no se dupliquen al relacionarlas con sus alquileres.
5. Los reportes mensuales, trimestrales y anuales se calculen a partir del detalle almacenado.

De esta manera, una copia alquilada cinco veces aparecerá una vez en `fact_inventario` y cinco veces en `fact_alquiler`, manteniendo el nivel de detalle establecido para cada tabla.