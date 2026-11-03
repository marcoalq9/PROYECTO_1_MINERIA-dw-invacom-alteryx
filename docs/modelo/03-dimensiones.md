
# Definición de dimensiones y atributos

> **Jira:** DWI-29  
> **Responsable:** Krisley Endrina Castro Barrantes

## 1. Descripción general

Para el Data Warehouse de Invacom Inc S.A. se propone utilizar cinco dimensiones: `dim_fecha`, `dim_cliente`, `dim_pelicula`, `dim_tienda` y `dim_actor`.

Estas dimensiones permitirán organizar y consultar la información de los alquileres e inventario desde diferentes perspectivas, como fechas, clientes, películas y tiendas.

La propuesta se basa en las preguntas de negocio establecidas por el equipo y en el esquema dimensional definido para el proyecto.

Cada dimensión tendrá una llave sustituta propia del Data Warehouse, que permitirá relacionarla con las tablas de hechos sin depender directamente de los identificadores de la base de datos fuente.

## 2. Dimensión Fecha: dim_fecha

Esta dimensión permitirá analizar los alquileres e ingresos según el período en que fueron realizados.

**Granularidad:** un registro por cada fecha del calendario.

**Origen:** se generará utilizando las fechas necesarias para analizar los alquileres de `rental.rental_date`.

### 2.1. Atributos propuestos

| Campo | Descripción |
|---|---|
| fecha_key | Llave primaria de la dimensión, con formato AAAAMMDD. |
| fecha | Fecha completa del calendario. |
| dia | Día del mes. |
| nombre_dia | Nombre del día de la semana. |
| mes | Número del mes. |
| nombre_mes | Nombre del mes. |
| trimestre | Trimestre al que pertenece la fecha. |
| anio | Año correspondiente. |

### 2.2. Uso de la dimensión

Permitirá consultar los alquileres e ingresos por mes, trimestre o año y comparar los resultados entre diferentes períodos.

La llave `fecha_key` se generará a partir de la fecha del alquiler. Por ejemplo, para el 24 de mayo de 2005, la llave será `20050524`.

Durante el ETL se deberá utilizar un mismo criterio de zona horaria para evitar que una fecha cambie de día al transformarse.

## 3. Dimensión Cliente: dim_cliente

Esta dimensión almacenará la información necesaria para identificar y analizar a los clientes que realizan alquileres.

**Granularidad:** un registro por cada cliente.

**Tablas de origen:** `customer`, `address`, `city` y `country`.

### 3.1. Atributos propuestos

| Campo | Origen | Descripción |
|---|---|---|
| cliente_key | Generado en el DW | Llave primaria sustituta del cliente. |
| customer_id | customer | Identificador original del cliente. |
| nombre_completo | customer | Nombre y apellido del cliente. |
| estado | customer.active | Indica si el cliente está activo (1) o inactivo (0). |
| ciudad | city | Ciudad donde reside el cliente. |
| pais | country | País donde reside el cliente. |
| ciudad_pais | Derivado de city y country | Identifica la combinación de ciudad y país para evitar confundir ciudades homónimas. |

### 3.2. Uso de la dimensión

Permitirá identificar a los clientes que realizan más alquileres, conocer cuáles generan mayores ingresos y analizar la distribución geográfica de los clientes.

También se utilizará para estudiar la frecuencia de alquiler y diferenciar clientes nuevos de recurrentes, en conjunto con las fechas registradas en `fact_alquiler`.

Para el estado del cliente se utilizará **`customer.active`**, conforme a la regla C08. El perfilado encontró 15 clientes inactivos con `active = 0`; `activebool` muestra los 599 clientes como activos y no permite distinguirlos. Para la ubicación se generará `ciudad_pais` (C12) y no se cargará `address.district` (C17), ya que no es necesario para las preguntas de negocio y presenta valores vacíos.

No se incluirán contraseñas, teléfonos ni correos electrónicos, ya que no son necesarios para responder las preguntas de negocio y el equipo estableció que no se cargarán datos personales sin valor analítico.

## 4. Dimensión Película: dim_pelicula

Esta dimensión almacenará las características de las películas disponibles en el catálogo.

**Granularidad:** un registro por cada película.

**Tablas de origen:** `film`, `film_category`, `category` y `language`.

### 4.1. Atributos propuestos

| Campo | Origen | Descripción |
|---|---|---|
| pelicula_key | Generado en el DW | Llave primaria sustituta de la película. |
| film_id | film | Identificador original de la película. |
| titulo | film | Nombre de la película. |
| anio_estreno | film | Año de estreno registrado. |
| categoria | category | Categoría de la película. |
| clasificacion | film | Clasificación G, PG, PG-13, R o NC-17. |
| idioma | language | Idioma de la película. |
| duracion_min | film | Duración de la película en minutos. |
| rango_duracion | Derivado de film.length | Agrupación de películas según su duración. |
| tarifa_alquiler | film | Tarifa registrada para alquilar la película. |
| dias_alquiler_permitidos | film | Cantidad de días permitidos para la devolución. |
| costo_reemplazo | film | Costo de reemplazar la película. |

### 4.2. Uso de la dimensión

Permitirá identificar las películas más alquiladas, comparar los ingresos por categoría y analizar el comportamiento de las distintas clasificaciones.

También permitirá relacionar las películas con las copias disponibles en el inventario de cada tienda.

La categoría se obtendrá relacionando `film` con `film_category` y `category`, mientras que el idioma se obtendrá mediante `language`. El campo `idioma` se conserva como atributo descriptivo, aunque las 1.000 películas tienen inglés como idioma; por ahora no permite comparar películas entre distintos idiomas. En la extracción se aplicará `Trim()` para quitar los espacios de relleno (C11).

El atributo `rango_duracion` será calculado durante la transformación. Los intervalos utilizados para clasificar las películas deberán acordarse antes de implementar el ETL.

La dimensión deberá mantener una sola fila por película. En caso de encontrar varias categorías asociadas a una misma película, será necesario revisar los datos para evitar duplicaciones.

## 5. Dimensión Tienda: dim_tienda

Esta dimensión almacenará la información necesaria para identificar las tiendas y analizar sus resultados.

**Granularidad:** un registro por cada tienda.

**Tablas de origen:** `store`, `address`, `city` y `country`.

### 5.1. Atributos propuestos

| Campo | Origen | Descripción |
|---|---|---|
| tienda_key | Generado en el DW | Llave primaria sustituta de la tienda. |
| store_id | store | Identificador original de la tienda. |
| ciudad | city | Ciudad donde está ubicada. |
| pais | country | País donde está ubicada. |
| ciudad_pais | Derivado de city y country | Ubicación de la tienda, diferenciando ciudades con el mismo nombre. |

### 5.2. Uso de la dimensión

Permitirá comparar los ingresos, la cantidad de alquileres, las devoluciones tardías y las copias de películas registradas en cada tienda.

Para relacionar un alquiler con su tienda se utilizará `inventory.store_id`, correspondiente a la tienda propietaria de la copia física alquilada.

Este criterio mantiene la misma definición de tienda en las tablas `fact_alquiler` y `fact_inventario`.

No se utilizará `customer.store_id` ni `staff.store_id` para asignar la tienda del alquiler, de acuerdo con las decisiones de diseño documentadas por el equipo. No se cargará `address.district` (C17); se conservarán ciudad y país, además de `ciudad_pais` para su identificación.

## 6. Dimensión Actor: dim_actor

Esta dimensión almacenará la información de los actores que participan en las películas del catálogo.

**Granularidad:** un registro por cada actor.

**Tabla de origen:** `actor`.

### 6.1. Atributos propuestos

| Campo | Origen | Descripción |
|---|---|---|
| actor_key | Generado en el DW | Llave primaria sustituta del actor. |
| actor_id | actor | Identificador original del actor. |
| nombre_completo | actor | Nombre y apellido del actor. |

### 6.2. Uso de la dimensión

Permitirá identificar a los actores cuyas películas registran mayor cantidad de alquileres.

Como una película puede tener varios actores y un actor puede participar en diferentes películas, esta dimensión se relacionará con `dim_pelicula` mediante una tabla puente.

Los actores se identificarán por `actor_id`, ya que pueden existir personas con el mismo nombre y apellido.

## 7. Tabla puente: bridge_pelicula_actor

La tabla `bridge_pelicula_actor` permitirá establecer la relación de muchos a muchos entre las películas y sus actores.

**Tabla de origen:** `film_actor`.

### 7.1. Campos propuestos

| Campo | Descripción |
|---|---|
| pelicula_key | Llave foránea que identifica la película. |
| actor_key | Llave foránea que identifica al actor. |

La combinación de ambas llaves deberá ser única para evitar relaciones duplicadas.

Esta tabla se utilizará para responder la pregunta sobre los actores cuyas películas se alquilan más.

Al realizar consultas por actor, se deberá contar correctamente cada alquiler y evitar sumar los resultados de varios actores como si fueran alquileres diferentes.

## 8. Relación de las dimensiones con las tablas de hechos

Las dimensiones se conectarán a las tablas de hechos mediante las llaves sustitutas definidas para el Data Warehouse.

| Dimensión | fact_alquiler | fact_inventario |
|---|---|---|
| dim_fecha | Sí | No |
| dim_cliente | Sí | No |
| dim_pelicula | Sí | Sí |
| dim_tienda | Sí | Sí |
| dim_actor | Mediante tabla puente | No |

Las dimensiones Película y Tienda serán compartidas por las dos tablas de hechos, siguiendo el modelo dimensional seleccionado por el equipo.

La dimensión Actor se relacionará con Película mediante `bridge_pelicula_actor`, sin incorporarse directamente a las tablas de hechos.

## 9. Consideraciones para la implementación

Para mantener la calidad de la información se deberán considerar las siguientes reglas:

1. Generar una llave sustituta única para cada registro de las dimensiones.
2. Conservar los identificadores originales para reconocer los registros de Pagila.
3. Evitar duplicados al combinar las tablas de origen.
4. Estandarizar los nombres y formatos necesarios durante el ETL.
5. Utilizar `customer.active` (C08), excluir `address.district` (C17) y generar `ciudad_pais` (C12).
6. Eliminar espacios adicionales en valores como el idioma de las películas (C11) y utilizar las mismas dimensiones Película y Tienda para ambas tablas de hechos.
7. Validar que las llaves utilizadas por las tablas de hechos existan en las dimensiones.
8. Evitar cargar información personal o campos que no sean necesarios para los reportes.

Estas reglas se aplicarán durante los procesos ETL desarrollados en Alteryx Designer.

## 10. Validación de las dimensiones

Para comprobar la carga de las dimensiones, se tomarán como referencia los datos de Pagila.

Según el inventario de la base fuente documentado por el equipo, se tienen los siguientes registros:

| Dimensión | Cantidad de registros de referencia |
|---|---:|
| dim_cliente | 599 clientes |
| dim_pelicula | 1.000 películas |
| dim_tienda | 2 tiendas |
| dim_actor | 200 actores |
| bridge_pelicula_actor | 5.462 relaciones |

La dimensión Fecha se generará según el rango de fechas requerido para el análisis, por lo que su cantidad de registros dependerá del calendario definido.

Después de ejecutar el ETL se deberán validar estos conteos, comprobar que no existan llaves duplicadas y verificar que los registros de las tablas de hechos tengan correspondencia con sus dimensiones. En `dim_cliente` también se deberán identificar los 15 clientes inactivos a partir de `customer.active`, y comprobar que `ciudad_pais` distinga las ciudades homónimas.

Los valores deberán confirmarse utilizando la base de datos oficial definida para el proyecto.

## 11. Conclusión

Las cinco dimensiones propuestas permitirán organizar la información descriptiva necesaria para analizar los alquileres, ingresos, clientes, películas e inventario de Invacom Inc S.A.

Su relación con `fact_alquiler` y `fact_inventario` facilitará la elaboración de reportes mediante tablas dinámicas de Excel.

Esta definición servirá como referencia para construir las dimensiones en SQL Server y desarrollar sus procesos de carga en Alteryx Designer, manteniendo la estructura acordada por el equipo.
