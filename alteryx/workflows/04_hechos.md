# 04_hechos

> Jira: DWI-38 · Responsable: Marco Andrey López Quesada

Carga `fact_alquiler`, `fact_inventario` y `bridge_pelicula_actor` en `DW_Invacom`. Lee los archivos limpios de `02_limpieza` y toma las llaves sustitutas de las dimensiones que ya están cargadas en el DW.

## Antes de ejecutar

1. Haber corrido `01_extraccion`, `02_limpieza`, `dim_fecha` y `03_dimensiones`, en ese orden.
2. Tener el DSN de Windows `DW_Invacom` descrito en `03_dimensiones.md`.

## Qué hace

### fact_alquiler (una fila por alquiler válido)

| Paso | Herramienta | Detalle |
|---|---|---|
| Pagos por alquiler | Summarize | Suma `amount` → `monto` y cuenta los pagos → `cantidad_pagos` |
| Unir pagos | Join + Union | Conserva también los alquileres sin pago (L), que quedan con monto 0 |
| Medidas | Formula | `fecha_key` (AAAAMMDD de `rental_date`), `devuelto`, `dias_alquilado`, `dias_atraso`, `devolucion_tardia`, `pago_cero`, `cantidad` = 1 |
| Llaves | Join ×3 | `customer_id` → `cliente_key`, `film_id` → `pelicula_key`, `store_id` → `tienda_key`, contra las dimensiones del DW |
| Columnas | Select | `rental_id` → `alquiler_id`, `inventory_id` → `inventario_id` |
| Cargar | Output Data | Append con `DELETE FROM dbo.fact_alquiler;` previo |

Reglas de las medidas:

- `dias_alquilado` y `dias_atraso` quedan en NULL si el alquiler no se devolvió (C06).
- `dias_atraso` = días alquilado − días permitidos, mínimo 0.
- `devolucion_tardia` = 1 si se devolvió después del plazo; NULL si no se devolvió o el plazo no es válido (C23).
- `pago_cero` = 1 si el monto total es 0 (C04).

### fact_inventario (una fila por copia física)

Lee `inventario.yxdb`, agrega `cantidad_copias` = 1, busca `pelicula_key` y `tienda_key` y carga con `DELETE FROM dbo.fact_inventario;` previo.

### bridge_pelicula_actor

Lee `pelicula_actor.yxdb`, busca `pelicula_key` y `actor_key` y carga con `DELETE FROM dbo.bridge_pelicula_actor;` previo.

Se usa Append con un `DELETE` previo porque *Delete Data & Append* se ejecuta como `TRUNCATE`, que SQL Server no permite en tablas con llaves foráneas.

## Resultado

Ejecutado el 12/11/2026 con el motor AMP, sin errores ni advertencias. Validado con consultas directas en SQL Server:

| Dato | DW | Esperado |
|---|---:|---:|
| Filas de `fact_alquiler` | 16 044 | 16 044 |
| Ingresos (`SUM(monto)`) | 67 406,56 | 67 406,56 |
| Pagos (`SUM(cantidad_pagos)`) | 16 044 | 16 044 |
| Sin devolver | 183 | 183 |
| Devoluciones tardías | 51,2 % | 51,2 % |
| Alquileres con pago en cero | 24 | 24 |
| Filas de `fact_inventario` | 4 581 | 4 581 |
| Filas de `bridge_pelicula_actor` | 5 462 | 5 462 |
| Alquileres por tienda | 7 923 · 8 121 | 7 923 · 8 121 |
| Actriz más alquilada | Gina Degeneres, 753 | Gina Degeneres, 753 |
