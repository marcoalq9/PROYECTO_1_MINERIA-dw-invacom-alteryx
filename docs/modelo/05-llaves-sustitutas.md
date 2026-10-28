# Llaves sustitutas

> Jira: DWI-31 · Responsable: Marco Andrey López Quesada
> Dimensiones según la propuesta del modelo, sin `dim_empleado` (DWI-70). Si DWI-29 agrega o quita una dimensión, se agrega o quita su fila aquí.

Cada dimensión tiene una llave sustituta propia del DW (`*_key`) y conserva la llave de la base fuente como llave de negocio. Las tablas de hechos y la tabla puente se unen a las dimensiones solo por la llave sustituta.

| Dimensión | Llave sustituta | Llave de negocio (fuente) | Tipo | Cómo se genera en Alteryx |
|---|---|---|---|---|
| `dim_fecha` | `fecha_key` | la fecha (`rental_date`) | INT, formato AAAAMMDD | *Formula*: `ToNumber(DateTimeFormat([fecha], '%Y%m%d'))` → 24/05/2005 = `20050524` |
| `dim_cliente` | `cliente_key` | `customer_id` | INT | *Sort* por `customer_id` + *Record ID* desde 1 |
| `dim_pelicula` | `pelicula_key` | `film_id` | INT | *Sort* por `film_id` + *Record ID* desde 1 |
| `dim_tienda` | `tienda_key` | `store_id` | INT | *Sort* por `store_id` + *Record ID* desde 1 |
| `dim_actor` | `actor_key` | `actor_id` | INT | *Sort* por `actor_id` + *Record ID* desde 1 |

## Reglas

- **Ordenar antes de numerar.** El *Sort* por la llave de negocio hace que cada ejecución del ETL asigne la misma llave a cada registro.
- **Llave de negocio única.** En SQL Server, la llave sustituta es `PRIMARY KEY` y la llave de negocio lleva `UNIQUE`, para que una recarga no duplique registros.
- **Búsqueda de llaves en los hechos.** Al cargar `fact_alquiler`, `fact_inventario` y `bridge_pelicula_actor`, cada llave de negocio se reemplaza por su llave sustituta con un *Join* contra la dimensión ya cargada.
- **Fecha con formato AAAAMMDD.** Es la única llave que no es un consecutivo: se calcula a partir de la fecha, así que se puede leer directamente y no necesita buscarse en la dimensión.

## Por qué llaves sustitutas

- **El DW no depende de la fuente.** Si la base de Invacom renumera o reutiliza un `customer_id`, las llaves del DW no cambian.
- **Distingue registros con el mismo nombre.** Los dos actores SUSAN DAVIS (`actor_id` 101 y 110) quedan con llaves distintas, y la pregunta de los actores más alquilados los cuenta por separado.
