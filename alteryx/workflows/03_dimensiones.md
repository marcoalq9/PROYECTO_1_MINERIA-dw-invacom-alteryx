# 03_dimensiones

> Jira: DWI-37 · Responsable: Marco Andrey López Quesada

Carga `dim_cliente`, `dim_pelicula`, `dim_tienda` y `dim_actor` en `DW_Invacom` a partir de los archivos limpios de `02_limpieza` (`docs/etl/01-contrato-archivos-limpios.md`).

## Antes de ejecutar

1. Haber corrido `01_extraccion` y `02_limpieza`, que dejan los archivos en `alteryx/datos/limpio/`.
2. Tener creadas las tablas con `sql/01_crear_bd.sql`, `02_dimensiones.sql` y `03_hechos.sql`.
3. Tener un DSN de Windows llamado `DW_Invacom` (ODBC Driver 18 for SQL Server, servidor `localhost`, base `DW_Invacom`, autenticación de Windows y **Trust server certificate** marcado). El flujo usa ese DSN directamente, así que funciona en cualquier máquina que lo tenga con ese nombre.

## Qué hace

Cuatro carriles iguales, uno por dimensión:

| Paso | Herramienta | Detalle |
|---|---|---|
| Leer | Input Data | `cliente`, `pelicula`, `tienda` o `actor`.yxdb |
| Rango de duración | Formula | Solo películas: Corta (<90 min), Media (90-120 min), Larga (>120 min) |
| Ordenar | Sort | Por la llave de negocio (`customer_id`, `film_id`, `store_id`, `actor_id`) |
| Llave sustituta | Record ID | `*_key` desde 1, Int32 |
| Columnas | Select | Solo las columnas de la tabla, en su orden |
| Cargar | Output Data | Append Existing con *Pre Create SQL Statement* |

La instrucción SQL previa de cada carga vacía primero `fact_alquiler`, `fact_inventario` y `bridge_pelicula_actor` (que referencian las dimensiones) y después la propia dimensión. No se usa *Delete Data & Append* porque Alteryx lo ejecuta como `TRUNCATE`, y SQL Server no permite `TRUNCATE` en tablas referenciadas por llaves foráneas.

La tabla puente se carga en `04_hechos`, porque necesita las llaves de películas y actores ya cargadas.

## Resultado

Ejecutado el 11/11/2026 con el motor AMP, dos veces seguidas, sin errores ni advertencias:

| Tabla | Filas |
|---|---:|
| `dim_cliente` | 599 |
| `dim_pelicula` | 1 000 |
| `dim_tienda` | 2 |
| `dim_actor` | 200 |

Al ejecutarlo se vacían los hechos; después hay que volver a correr `04_hechos`.
