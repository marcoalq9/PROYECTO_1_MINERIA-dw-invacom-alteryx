# Medidas DAX base del equipo

> Jira: DWI-84 · Responsable: Marco Andrey López Quesada (a pedido de Kristel Ramírez)

Medidas comunes que usan los KPIs K1 a K6. Están en `Dashboard_Invacom.pbix`, en la carpeta **Base** de cada tabla. Cada responsable construye sus KPIs sobre ellas en lugar de repetir la suma, así todos los cálculos parten del mismo número.

## Medidas

| Medida | Tabla | Formato | DAX | La usan |
|---|---|---|---|---|
| `Ingresos` | `fact_alquiler` | `#,0.00` | `SUM ( fact_alquiler[monto] )` | K1, K2, K4 |
| `Alquileres` | `fact_alquiler` | `#,0` | `SUM ( fact_alquiler[cantidad] )` | K2, K5 |
| `Clientes activos` | `fact_alquiler` | `#,0` | `DISTINCTCOUNT ( fact_alquiler[cliente_key] )` | K3, K4 |
| `Ingresos mes anterior` | `fact_alquiler` | `#,0.00` | ver abajo | K1 |
| `Copias` | `fact_inventario` | `#,0` | `SUM ( fact_inventario[cantidad_copias] )` | K5, K6 |

```dax
Ingresos mes anterior =
IF (
    ISEMPTY ( fact_alquiler ),
    BLANK (),
    CALCULATE (
        [Ingresos],
        PREVIOUSMONTH ( dim_fecha[fecha] ),
        REMOVEFILTERS ( dim_fecha )
    )
)
```

- **`PREVIOUSMONTH` y no `SAMEPERIODLASTYEAR`.** Los alquileres van de mayo a agosto de 2005 (más un día de 2017), así que no hay un año anterior con qué comparar.
- **`REMOVEFILTERS ( dim_fecha )`** quita el filtro de año y mes del visual para que el mes anterior no quede vacío. Así funciona aunque `dim_fecha` no esté marcada como tabla de fechas.
- **`ISEMPTY ( fact_alquiler )`** deja vacíos los meses del calendario sin alquileres (2006 a 2016), para que no aparezcan en los visuales.

## Cuidado con `Copias`

`fact_inventario` no tiene fecha, así que `Copias` **no cambia por mes**: cada tienda tiene siempre las mismas copias. En un visual por mes, `Copias` sola hace aparecer todos los meses del calendario; hay que usarla junto con una medida de alquileres (por ejemplo, dentro de `DIVIDE ( [Alquileres], [Copias] )`, que da vacío en los meses sin alquileres). No se le puso `ISEMPTY ( fact_alquiler )` porque K6 necesita contar las copias que nunca se alquilaron.

## Valores comprobados

Consulta DAX sobre el modelo de DWI-81 (fechas en UTC). Los totales coinciden con los validados en el Proyecto 1:

| Tienda | Mes | Ingresos | Ingresos mes anterior | Alquileres | Clientes activos | Copias |
|---|---|---:|---:|---:|---:|---:|
| Todas | 2005-05 | 4 823,44 | — | 1 156 | 520 | 4 581 |
| Todas | 2005-06 | 9 629,89 | 4 823,44 | 2 311 | 590 | 4 581 |
| Todas | 2005-07 | 29 346,58 | 9 629,89 | 6 942 | 599 | 4 581 |
| Todas | 2005-08 | 23 092,47 | 29 346,58 | 5 453 | 599 | 4 581 |
| Todas | 2017-02 | 514,18 | — | 182 | 158 | 4 581 |
| 1 | Total | 33 679,79 | — | 7 923 | 599 | 2 270 |
| 2 | Total | 33 726,77 | — | 8 121 | 599 | 2 311 |
| Todas | **Total** | **67 406,56** | — | **16 044** | **599** | **4 581** |

El mes anterior de febrero de 2017 es enero de 2017, que no tiene alquileres: queda vacío. Mayo de 2005 es un mes parcial (los datos empiezan el 24/05/2005).

## Medidas de prueba de DWI-81

El modelo también trae `Total alquileres`, `Copias registradas` y una medida vacía llamada `Measure`, en `bridge_pelicula_actor`. Las creó DWI-81 para validar el modelo. No se borraron porque las usa la tabla de prueba de la página 1; cuando esa página se rehaga, conviene quitarlas para que no se confundan con las medidas base.
