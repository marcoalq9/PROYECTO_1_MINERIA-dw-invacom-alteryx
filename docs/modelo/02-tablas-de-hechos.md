
# Definición de tablas de hechos y medidas

> **DWI-28**
> **Responsable:** Krisley Endrina Castro Barrantes

## 1. Descripción general

Para el Data Warehouse de Invacom Inc S.A. se propone utilizar dos tablas de hechos: `fact_alquiler` y `fact_inventario`.

Estas tablas permitirán analizar la información relacionada con los alquileres de películas, los ingresos generados, las devoluciones y las copias físicas registradas en las tiendas.

La definición se basa en las preguntas de negocio establecidas por el equipo y en el esquema dimensional seleccionado para el proyecto.

## 2. Tabla de hechos: fact_alquiler

Esta tabla almacenará la información de los alquileres realizados por los clientes, permitiendo analizar la cantidad de alquileres, los montos pagados y los tiempos de devolución.

**Granularidad:** cada registro representa un alquiler válido, identificado por `rental_id`, después de excluir los duplicados mediante la regla de limpieza C01. De acuerdo con el perfilado de la fuente oficial, se esperan **16.044 alquileres válidos**.

**Tablas de origen:** `rental`, `payment`, `inventory` y `film`.

### 2.1. Campos propuestos

| Campo | Tipo de campo | Descripción |
|---|---|---|
| alquiler_id | Identificador del negocio | Identifica cada alquiler realizado. |
| inventario_id | Identificador de origen | Identifica la copia física que fue alquilada. |
| fecha_key | Llave foránea | Relaciona el alquiler con la dimensión Fecha. |
| cliente_key | Llave foránea | Identifica al cliente que realizó el alquiler. |
| pelicula_key | Llave foránea | Identifica la película alquilada. |
| tienda_key | Llave foránea | Identifica la tienda propietaria de la copia. |
| cantidad | Medida | Valor 1 para contabilizar cada alquiler. |
| monto | Medida | Total de pagos asociados al alquiler. |
| cantidad_pagos | Medida | Número de pagos registrados para el alquiler. |
| dias_alquilado | Medida | Tiempo transcurrido entre el alquiler y la devolución, expresado en días. |
| dias_atraso | Medida | Tiempo que supera el plazo permitido de devolución, expresado en días. |
| devuelto | Indicador | Valor 1 si la película fue devuelta y 0 si no. |
| devolucion_tardia | Indicador | Valor 1 si la devolución ocurrió fuera del plazo, 0 si se devolvió a tiempo y NULL cuando no se ha devuelto o el plazo de alquiler es inválido. |
| pago_cero | Indicador | Valor 1 cuando el monto total asociado al alquiler es cero. |

Los campos `inventario_id` y `cantidad_pagos` se proponen para responder las preguntas relacionadas con la rotación del inventario y el promedio por pago.

### 2.2. Obtención de las medidas

Las medidas se calcularán utilizando la información disponible en las tablas de Pagila:

- **Cantidad:** se asignará el valor 1 a cada alquiler para facilitar su conteo.
- **Monto:** se sumarán los pagos válidos de `payment` asociados a cada `rental_id`, excluyendo los pagos de alquileres duplicados (C02) y aquellos cuyo `payment.customer_id` no coincida con el cliente del alquiler (C03). Los alquileres sin pagos válidos tendrán un monto de cero.
- **Cantidad de pagos:** se contará el número de pagos asociados a cada alquiler. Cuando no existan pagos, el valor será cero.
- **Días alquilados:** se calculará el tiempo transcurrido entre `rental_date` y `return_date`.
- **Días de atraso:** se comparará la duración real del alquiler con el plazo permitido en `film.rental_duration`.
- **Devuelto:** permitirá distinguir los alquileres que tienen una fecha de devolución registrada.
- **Devolución tardía:** identificará los alquileres devueltos después del plazo permitido.
- **Pago cero:** permitirá identificar los alquileres cuyo monto total pagado sea cero.

Los pagos válidos deberán agruparse por `rental_id` antes de incorporarlos a la tabla de hechos, evitando que un alquiler aparezca duplicado cuando tenga varios pagos. Los alquileres y pagos excluidos se registrarán en archivos de rechazos, según la estrategia de limpieza.

### 2.3. Cálculo de los días de atraso

Para identificar las devoluciones tardías se comparará la fecha de devolución con la fecha límite permitida para cada película.

La fecha límite se obtendrá sumando los días establecidos en `film.rental_duration` a la fecha del alquiler.

Se proponen las siguientes reglas:

1. Si la película fue devuelta dentro del plazo permitido, `dias_atraso` será 0.
2. Si fue devuelta después de la fecha límite, se calculará el tiempo excedido.
3. Si no existe fecha de devolución, `dias_alquilado` y `dias_atraso` quedarán sin valor, `devuelto` será 0 y `devolucion_tardia` será NULL (C06).
4. Si la película se devolvió a tiempo, `devolucion_tardia` será 0; si se devolvió fuera del plazo, será 1.
5. Si `film.rental_duration` es cero o negativo, `devolucion_tardia` será NULL, según el control C23.

Para conservar la precisión, se propone calcular las duraciones como días transcurridos, incluyendo fracciones de día. Si se requieren días enteros, el criterio de redondeo deberá acordarse antes de implementar el ETL.

Los alquileres sin devolución no se contabilizarán como devoluciones realizadas a tiempo.

### 2.4. Indicadores que permitirá calcular

| Indicador | Cálculo |
|---|---|
| Total de alquileres | SUM(cantidad) |
| Ingresos totales | SUM(monto) |
| Monto promedio por pago | SUM(monto) / SUM(cantidad_pagos) |
| Ticket promedio por alquiler | SUM(monto) / SUM(cantidad) |
| Porcentaje de devoluciones tardías | SUM(devolucion_tardia) / SUM(devuelto) * 100 |

En los indicadores que incluyen divisiones, se deberá comprobar que el denominador sea mayor que cero.

Para los análisis mensuales se utilizará la fecha del alquiler, de acuerdo con la decisión de diseño establecida por el equipo. Por lo tanto, los ingresos agrupados por mes representarán los pagos asociados a los alquileres realizados en ese mes, no necesariamente los cobros efectuados durante ese período.

## 3. Tabla de hechos: fact_inventario

Esta tabla permitirá analizar las copias físicas de películas registradas en cada tienda, facilitando el control de existencias y la identificación de películas con poca rotación.

**Granularidad:** cada registro representa una copia física del inventario, identificada por `inventory_id` (4.581 registros en la fuente oficial). Se conserva este detalle para determinar si cada copia tuvo alquileres durante un trimestre.

**Tabla de origen:** `inventory`.

### 3.1. Campos propuestos

| Campo | Tipo de campo | Descripción |
|---|---|---|
| inventario_id | Identificador del negocio | Identifica cada copia física registrada. |
| pelicula_key | Llave foránea | Identifica la película correspondiente. |
| tienda_key | Llave foránea | Identifica la tienda donde está registrada la copia. |
| cantidad_copias | Medida | Valor 1 por cada copia física registrada. |

### 3.2. Obtención de las medidas

La medida `cantidad_copias` tendrá un valor de 1 para cada registro del inventario.

Al sumar esta medida, se podrá conocer cuántas copias físicas tiene registrada cada tienda de una película determinada.

Esta información permitirá comparar las existencias entre tiendas y conocer cuáles películas cuentan con mayor o menor cantidad de copias registradas.

### 3.3. Inventario sin rotación

Para identificar las películas o copias físicas con poca rotación, se analizarán los registros del inventario y los alquileres realizados durante el trimestre seleccionado.

Se considerará una copia sin rotación cuando su `inventory_id` no tenga ningún alquiler registrado dentro del período analizado.

El porcentaje se calculará de la siguiente manera:

**Porcentaje sin rotación = (Copias sin alquileres durante el trimestre / Total de copias registradas) × 100**

Para realizar este cálculo se relacionarán los identificadores de las copias de `fact_inventario` con los alquileres de `fact_alquiler`.

El cálculo deberá realizarse sin duplicar las copias que tengan varios alquileres.

Este análisis se basará en el inventario registrado en la fuente. No representa necesariamente la disponibilidad actual de las películas ni un historial completo de existencias, ya que la base no proporciona todos los movimientos de entrada y salida del inventario.

**Películas sin copias:** se mantendrá el grano por copia física en `fact_inventario`. Para que los reportes muestren también las películas con cero copias, se propone una vista en SQL Server (`04_vistas.sql`) que cruce todas las películas con todas las tiendas y complete con 0 las combinaciones sin inventario. De acuerdo con el perfilado, hay 42 películas sin ninguna copia y 479 combinaciones película–tienda sin copias. La vista debe acordarse con el responsable de la carga y de los reportes (DWI-33/DWI-30), sin agregar filas ficticias a la tabla de hechos.

## 4. Relación con las dimensiones

Las tablas de hechos utilizarán llaves foráneas para relacionarse con las dimensiones del Data Warehouse.

| Tabla de hechos | Dimensiones relacionadas |
|---|---|
| fact_alquiler | Fecha, Cliente, Película y Tienda |
| fact_inventario | Película y Tienda |

Las dimensiones permitirán analizar los resultados desde diferentes perspectivas, como períodos, clientes, películas, categorías y tiendas.

La dimensión Actor se relacionará con Película mediante una tabla puente denominada `bridge_pelicula_actor`, debido a que una película puede tener varios actores y un actor puede participar en diferentes películas.

Esta relación permitirá identificar los actores cuyas películas registran más alquileres, evitando duplicar los totales generales de alquileres e ingresos.

Las tablas de hechos utilizarán las llaves sustitutas definidas para las dimensiones en el modelo del Data Warehouse.

## 5. Consideraciones para la implementación

Para mantener la integridad de la información y evitar inconsistencias, se deberán considerar las siguientes reglas:

1. Mantener un único registro por alquiler válido en `fact_alquiler`, después de aplicar la regla C01 y documentar los duplicados rechazados.
2. Excluir los pagos inválidos según C02 y C03, y agrupar los pagos válidos por `rental_id` antes de incorporarlos a la tabla de hechos.
3. Utilizar la tienda registrada en `inventory.store_id`, correspondiente a la propietaria de la copia física.
4. Utilizar `rental_date` para relacionar los alquileres con `dim_fecha`.
5. Evitar duplicaciones al relacionar películas con actores.
6. Identificar por separado los alquileres que no tienen fecha de devolución.
7. Mantener la relación mediante `inventario_id` para el análisis de las copias sin rotación.
8. Validar los conteos, las relaciones y los montos contra la base de datos fuente.

Estas reglas deberán aplicarse durante los procesos de extracción, transformación y carga desarrollados en Alteryx Designer.

## 6. Análisis adicionales

Las preguntas de negocio también contemplan el ticket promedio, la frecuencia de alquiler de los clientes y la identificación de clientes nuevos y recurrentes.

Estos indicadores podrán calcularse a partir de `fact_alquiler` y las dimensiones relacionadas.

### Ticket promedio

Permitirá conocer el monto promedio cobrado por alquiler, utilizando los montos registrados y la cantidad de alquileres.

Se podrá analizar por cliente, categoría de película y período.

### Frecuencia de alquiler

Se calculará a partir de las fechas de alquiler de cada cliente, comparando los días transcurridos entre alquileres consecutivos.

Para realizar este análisis será necesario conservar el historial de alquileres y ordenarlos cronológicamente por cliente.

### Clientes nuevos y recurrentes

Se propone clasificar como cliente nuevo a quien registra su primer alquiler durante el mes analizado.

Se considerará recurrente a quien realiza alquileres en ese mes y ya cuenta con alquileres registrados anteriormente.

Esta clasificación se basará en el historial disponible en Pagila, por lo que un cliente identificado como nuevo será nuevo dentro de los registros analizados, no necesariamente desde el inicio real de operaciones de la empresa.

Las reglas definitivas deberán validarse con el equipo y el Product Owner antes de desarrollar los reportes.

## 7. Validación de las tablas de hechos

Para comprobar que las tablas de hechos se carguen correctamente, se utilizarán los registros de la base de datos Pagila como referencia.

Antes de la limpieza, la base local revisada en pgAdmin 4 mostró los siguientes conteos de origen:

| Tabla de origen | Cantidad de registros |
|---|---:|
| rental | 32.088 |
| payment | 32.093 |
| inventory | 4.581 |

A partir de estos datos, se proponen las siguientes validaciones:

| Validación | Resultado esperado |
|---|---|
| Registros en fact_alquiler | **16.044 alquileres válidos**, tras excluir 16.044 duplicados (C01) |
| Registros en fact_inventario | **4.581 copias físicas**, sin inventar registros para películas sin copias |
| Pagos válidos | 16.044, después de aplicar C02 y C03 |
| Ingresos totales | 67.406,56, según la estrategia de limpieza de la fuente oficial |
| Alquileres sin devolución | 183 registros válidos identificados aparte |
| Pagos por monto cero | 24 pagos conservados e identificados |
| Identificadores de alquiler | Sin duplicados de rental_id |
| Identificadores de inventario | Sin duplicados de inventory_id |
| Relaciones con dimensiones | Sin llaves foráneas sin correspondencia |
| Conteo de pagos | Coincidir con los pagos válidos asociados a cada alquiler |
| Inventario sin copias | Las combinaciones sin copias se muestran con 0 en la vista de reporte, no como copias ficticias |

Los conteos originales corresponden a la base local revisada. Los valores esperados después de limpiar se tomaron del documento `docs/analisis/07-estrategia-de-limpieza.md`, elaborado a partir de la fuente oficial `pagila_dvd_rental`. Deben verificarse nuevamente cuando se ejecute el ETL.

Después de cargar el Data Warehouse, será necesario comparar los resultados obtenidos contra la información original para comprobar que no existan registros duplicados, faltantes o montos incorrectos.

## 8. Conclusión

La definición de `fact_alquiler` y `fact_inventario` establece la información que se utilizará para analizar las principales operaciones de Invacom Inc S.A.

Estas tablas permitirán organizar los datos de alquileres, pagos, devoluciones e inventario, relacionándolos con las dimensiones del Data Warehouse.

Con esta estructura se busca facilitar la elaboración de tablas dinámicas en Excel y responder las preguntas de negocio definidas por el equipo.

La estructura propuesta servirá como base para la creación de las tablas en SQL Server y el desarrollo de los procesos ETL en Alteryx Designer.
