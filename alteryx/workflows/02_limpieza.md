# Limpieza y transformación — DWI-35

Workflow: `alteryx/workflows/02_limpieza.yxmd`.

Lee las 14 extracciones de `01_extraccion` (`datos/extraccion/<tabla>.yxdb`), aplica las reglas marcadas con flujo 02 en `docs/analisis/07-estrategia-de-limpieza.md` y escribe en `alteryx/datos/limpio/` los 9 archivos que define `docs/etl/01-contrato-archivos-limpios.md`: 8 para los flujos 03 y 04 y `rechazos.yxdb`. Todas las rutas son relativas al workflow.

## Contenedores

| # | Contenedor | Reglas | Salida |
|---|---|---|---|
| 1 | Entradas | — | 14 *Input Data* de `datos/extraccion/` |
| 2 | Alquileres y pagos | C01, C20, C02, C03, C26 | `alquiler.yxdb`, `pago.yxdb` |
| 3 | Inventario | — | `inventario.yxdb` |
| 4 | Clientes y tiendas | C08, C12, C14, C24 | `cliente.yxdb`, `tienda.yxdb` |
| 5 | Películas | C10, C11, C14, C21, C22 | `pelicula.yxdb` |
| 6 | Actores | C13, C14 | `actor.yxdb`, `pelicula_actor.yxdb` |
| 7 | Rechazos | C01, C20, C02, C03 | `rechazos.yxdb` |
| 8 | Validación | — | 7 *Browse* con el valor esperado en la anotación |

## Lógica principal

- **C01:** *Join* de `rental` consigo misma por `inventory_id` y `customer_id` → *Filter* `[Right_rental_id] > [rental_id]` y diferencia de 30 minutos o menos → *Unique* por `Right_rental_id`. Un segundo *Join* separa los válidos (salida **L**) de los duplicados (salida **J**), que van a rechazos con el ID del alquiler original en `detalle`.
- **C20:** *Join* de los válidos con `inventory`; trae `film_id` y `store_id`. Lo que no cruza (**L**) va a rechazos. Después se agrega `rental_duration` desde `film`.
- **C02 y C03:** *Join* de `payment` con los alquileres válidos por `rental_id`. Lo que no cruza (**L**) es C02. En lo que cruza, *Filter* `[customer_id] = [rental_customer_id]`: la salida **F** es C03.
- **C26:** *Select* convierte `amount` a `Double` antes de cualquier suma.
- **C24:** las ubicaciones se unen con un *Join* + *Union* de **J** y **L**, que conserva los registros sin pareja. Así, un cliente o tienda sin ciudad o país no se pierde y recibe `"Desconocido"`.
- **C21:** *Summarize* por `film_id` con el `Min` de `category_id`. La película que no cruza recibe `"Sin categoría"`.
- **C13:** *Summarize* cuenta cuántas veces aparece cada `nombre_completo` (ya en `TitleCase`). Si se repite, se agrega ` (actor_id)`.
- Cada salida pasa por un *Select* final con las columnas, nombres, orden y tipos del contrato, y descarta cualquier otro campo.

Las banderas `pago_cero`, `devuelto` y `devolucion_tardia` (C04, C06 y C23) **no** se calculan aquí: el flujo 04 las calcula a partir de `amount`, `return_date` y `rental_duration`, que se entregan sin modificar.

## Ejecución

1. Ejecutar antes `01_extraccion.yxmd` completo, para que existan los 14 archivos de `datos/extraccion/`.
2. Abrir `02_limpieza.yxmd` desde su ubicación en el repositorio y ejecutar con Ctrl+R. No usa conexiones DCM.
3. Revisar el contenedor 8: cada *Browse* tiene en su anotación el valor esperado.

El workflow está configurado con *Cancel running workflow on error*: si una herramienta falla, no se escriben archivos a medias.

## Validación esperada

| Control | Esperado |
|---|---:|
| Rechazos por código | C01: 16.044 · C02: 16.044 · C03: 5 (total 32.093) |
| Alquileres · sin devolver | 16.044 · 183 |
| Pagos · suma · pagos en 0 | 16.044 · 67.406,56 · 24 |
| Copias por tienda | Tienda 1: 2.270 · Tienda 2: 2.311 |
| Clientes por estado | True: 584 · False: 15 |
| Actores con ID en el nombre | Susan Davis (101) y Susan Davis (110) |
| Películas · categorías | 1.000 · 16 |

C20 no aparece en los rechazos porque hoy no tiene casos: el *Summarize* solo muestra los códigos con registros.

## Mantenimiento

- **Ruta de entrada:** si la extracción se mueve a `alteryx/datos/extraccion/`, cambiar las 14 rutas de entrada de `..\..\datos\extraccion\` a `..\datos\extraccion\`.

## Resultado
Se ejecutaron `01_extraccion` y `02_limpieza` en Alteryx Designer 2025.2 con AMP. Se generaron los 9 archivos de `alteryx/datos/limpio/` con las columnas, el orden y los tipos del contrato.

| Control | Esperado | Obtenido |
|---|---:|---:|
| `alquiler.yxdb` · sin devolver | 16.044 · 183 | 16.044 · 183 |
| `pago.yxdb` · suma · pagos en 0 | 16.044 · 67.406,56 · 24 | 16.044 · 67.406,56 · 24 |
| `inventario.yxdb` por tienda | 2.270 · 2.311 | 2.270 · 2.311 |
| `cliente.yxdb` por estado | True 584 · False 15 | True 584 · False 15 |
| `actor.yxdb` con ID en el nombre | Susan Davis (101) y (110) | Susan Davis (101) y (110) |
| `pelicula.yxdb` | 1.000 | 1.000 |
| `pelicula_actor.yxdb` | 5.462 | 5.462 |
| `tienda.yxdb` | 2 | 2 |
| `rechazos.yxdb` por código | C01 16.044 · C02 16.044 · C03 5 | C01 16.044 · C02 16.044 · C03 5 |

Ningún cliente ni tienda recibió `"Desconocido"` y ninguna película recibió `"Sin categoría"` ni `"Sin clasificación"`: esas reglas de control (C21, C22 y C24) no tuvieron casos. `rating` se leyó como texto sin errores.

Los archivos quedan en el formato del motor AMP (e2), igual que las extracciones de `01_extraccion`. Conviene ejecutar los flujos 03 y 04 también con AMP.
