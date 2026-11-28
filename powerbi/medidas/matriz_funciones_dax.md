# Matriz de control de funciones DAX

> Jira: DWI-89 · Responsable: Marco Andrey López Quesada
> Requisito del enunciado: usar al menos 6 funciones DAX distintas. Fuente: las medidas de `Dashboard_Invacom.pbix`, leídas del modelo el 26/11/2026.

**Registro histórico del 26/11/2026:** el inventario original contabilizó **30 elementos de lenguaje** en **78 medidas**, incluyendo `VAR/RETURN`. Estas dos palabras son palabras clave, no funciones, y no deben contarse para demostrar el mínimo de seis funciones.

**Revisión actual del 27/11/2026:** `INFO.VIEW.MEASURES()` devuelve **92 medidas, todas en estado Valid**. Se verificaron directamente ocho funciones distintas: `CALCULATE` (19 medidas), `DISTINCTCOUNT` (1), `DIVIDE` (8), `EXCEPT` (1), `FORMAT` (23), `PREVIOUSMONTH` (8), `REMOVEFILTERS` (10) y `SUM` (6). Esta muestra demuestra el mínimo sin contar palabras clave; no es un recuento exhaustivo de todas las funciones actuales. Ver [QA y evidencias](../../docs/validaciones/proyecto2/qa_dashboard.md).

Las tablas siguientes conservan el desglose histórico por integrante del 26/11; sus cantidades no representan el inventario actual completo y no se reasignaron autorías durante el QA.

## Funciones por integrante

| Función | Tipo | Para qué se usa | Marco | Kristel | Krisley | Juan | Medidas |
|---|---|---|---|---|---|---|---:|
| `VAR/RETURN` | Variables | Variables para escribir y leer mejor la fórmula | ✓ | ✓ | ✓ | ✓ | 47 |
| `ISBLANK` | Información | ¿Está vacío? | ✓ | ✓ | ✓ | ✓ | 46 |
| `BLANK` | Información | Devuelve vacío | ✓ | ✓ | ✓ | ✓ | 34 |
| `IF` | Lógica | Condición sí/no | ✓ | ✓ | ✓ | ✓ | 34 |
| `CALCULATE` | Contexto de filtro | Cambia el filtro con que se evalúa una medida | ✓ | ✓ | ✓ | ✓ | 17 |
| `DIVIDE` | Matemática segura | División que no falla si el divisor es 0 | ✓ | ✓ | ✓ | ✓ | 8 |
| `REMOVEFILTERS` | Contexto de filtro | Quita filtros (por ejemplo, el del mes del visual) | ✓ | ✓ | ✓ | ✓ | 8 |
| `SWITCH` | Lógica | Varias condiciones (estado, color) | ✓ | ✓ |  | ✓ | 23 |
| `TRUE` | Lógica | Se usa con SWITCH para evaluar condiciones | ✓ | ✓ |  | ✓ | 23 |
| `FORMAT` | Texto | Convierte un número en texto con formato | ✓ | ✓ |  | ✓ | 19 |
| `HASONEVALUE` | Información | ¿Hay un solo valor seleccionado (un mes)? |  | ✓ | ✓ | ✓ | 15 |
| `SELECTEDVALUE` | Información | Valor seleccionado en el filtro |  | ✓ | ✓ | ✓ | 10 |
| `COUNTROWS` | Agregación | Cuenta filas de una tabla | ✓ |  | ✓ | ✓ | 4 |
| `ISEMPTY` | Información | ¿La tabla no tiene filas? | ✓ | ✓ |  |  | 24 |
| `PREVIOUSMONTH` | Inteligencia de tiempo | Fechas del mes anterior | ✓ | ✓ |  |  | 6 |
| `COALESCE` | Lógica | Primer valor no vacío |  |  | ✓ | ✓ | 3 |
| `VALUES` | Tablas | Lista de valores visibles |  |  | ✓ | ✓ | 3 |
| `FILTER` | Contexto de filtro | Filtra una tabla fila por fila |  |  | ✓ | ✓ | 2 |
| `SUM` | Agregación | Suma una columna (ingresos, alquileres, copias) | ✓ |  |  |  | 4 |
| `AVERAGE` | Agregación | Promedio (días de atraso) | ✓ |  |  |  | 1 |
| `CROSSFILTER` | Relaciones | Activa el filtro en ambos sentidos de una relación (tabla puente) | ✓ |  |  |  | 1 |
| `DATESBETWEEN` | Inteligencia de tiempo | Fechas entre dos límites |  |  | ✓ |  | 1 |
| `DISTINCTCOUNT` | Agregación | Cuenta valores distintos (clientes activos) | ✓ |  |  |  | 1 |
| `EOMONTH` | Fecha | Fin de mes |  |  | ✓ |  | 1 |
| `EXCEPT` | Tablas | Filas de una tabla que no están en otra |  |  |  | ✓ | 1 |
| `LOOKUPVALUE` | Búsqueda | Busca un valor en otra tabla |  |  | ✓ |  | 1 |
| `MAX` | Agregación | Máximo de una columna |  | ✓ |  |  | 1 |
| `MIN` | Agregación | Mínimo de una columna |  |  | ✓ |  | 1 |
| `TREATAS` | Relaciones | Aplica valores como filtro de otra tabla |  |  |  | ✓ | 1 |
| `YEAR` | Fecha | Año de una fecha |  | ✓ |  |  | 1 |
| **Total distintas** | | | **17** | **16** | **17** | **18** | |

## Medidas, responsable y funciones

### Base

Responsable: Marco López (DWI-84). Tablas: `fact_alquiler` y `fact_inventario` (`Copias`).

| Medida | Funciones DAX |
|---|---|
| Ingresos | `SUM` |
| Alquileres | `SUM` |
| Clientes activos | `DISTINCTCOUNT` |
| Ingresos mes anterior | `BLANK`, `CALCULATE`, `IF`, `ISEMPTY`, `PREVIOUSMONTH`, `REMOVEFILTERS` |
| Copias | `SUM` |

### K1 Crecimiento mensual de ingresos

Responsable: Kristel Ramírez (DWI-85). Tabla: `fact_alquiler`.

| Medida | Funciones DAX |
|---|---|
| K1 Crecimiento de ingresos % | `BLANK`, `DIVIDE`, `HASONEVALUE`, `IF`, `ISBLANK`, `VAR/RETURN` |
| K1 Meta | Constante (sin funciones) |
| K1 Mes anterior | `BLANK`, `CALCULATE`, `IF`, `ISEMPTY`, `PREVIOUSMONTH`, `REMOVEFILTERS` |
| K1 Variación (pp) | `BLANK`, `IF`, `ISBLANK`, `VAR/RETURN` |
| K1 Texto | `BLANK`, `FORMAT`, `HASONEVALUE`, `ISBLANK`, `ISEMPTY`, `SWITCH`, `TRUE`, `VAR/RETURN` |
| K1 Estado | `BLANK`, `HASONEVALUE`, `ISBLANK`, `ISEMPTY`, `SWITCH`, `TRUE`, `VAR/RETURN` |
| K1 Color | `BLANK`, `ISBLANK`, `ISEMPTY`, `SWITCH`, `TRUE`, `VAR/RETURN` |
| K1 Color variación | `BLANK`, `ISBLANK`, `ISEMPTY`, `SWITCH`, `TRUE`, `VAR/RETURN` |
| K1 Nota | `BLANK`, `CALCULATE`, `FORMAT`, `HASONEVALUE`, `IF`, `ISBLANK`, `ISEMPTY`, `MAX`, `PREVIOUSMONTH`, `REMOVEFILTERS`, `SELECTEDVALUE`, `SWITCH`, `TRUE`, `YEAR`, `VAR/RETURN` |
| K1 Título gráfico | `HASONEVALUE`, `IF`, `SELECTEDVALUE`, `VAR/RETURN` |
| K1 Variación de ingresos | `BLANK`, `FORMAT`, `HASONEVALUE`, `IF`, `ISBLANK`, `VAR/RETURN` |

### K2 Ticket promedio por alquiler

Responsable: Kristel Ramírez (DWI-85). Tabla: `fact_alquiler`.

| Medida | Funciones DAX |
|---|---|
| K2 Ticket promedio | `DIVIDE` |
| K2 Meta | Constante (sin funciones) |
| K2 Mes anterior | `BLANK`, `CALCULATE`, `IF`, `ISEMPTY`, `PREVIOUSMONTH`, `REMOVEFILTERS` |
| K2 Variación | `BLANK`, `IF`, `ISBLANK`, `VAR/RETURN` |
| K2 Texto | `BLANK`, `FORMAT`, `ISBLANK`, `ISEMPTY`, `SWITCH`, `TRUE`, `VAR/RETURN` |
| K2 Estado | `BLANK`, `ISBLANK`, `ISEMPTY`, `SWITCH`, `TRUE`, `VAR/RETURN` |
| K2 Color | `BLANK`, `ISBLANK`, `ISEMPTY`, `SWITCH`, `TRUE`, `VAR/RETURN` |
| K2 Color variación | `BLANK`, `ISBLANK`, `ISEMPTY`, `SWITCH`, `TRUE`, `VAR/RETURN` |
| K2 Título gráfico | `HASONEVALUE`, `IF`, `SELECTEDVALUE`, `VAR/RETURN` |
| K2 Medidor mínimo | Constante (sin funciones) |
| K2 Medidor máximo | Constante (sin funciones) |
| K2 Nota medidor | `FORMAT`, `IF`, `ISBLANK`, `VAR/RETURN` |

### Tarjetas de resumen

Responsable: Kristel Ramírez (DWI-90). Tabla: `fact_alquiler`.

| Medida | Funciones DAX |
|---|---|
| Ingresos Tienda 1 | `CALCULATE`, `FORMAT`, `IF`, `ISBLANK`, `VAR/RETURN` |
| Ingresos Tienda 2 | `CALCULATE`, `FORMAT`, `IF`, `ISBLANK`, `VAR/RETURN` |
| Alquileres Tienda 1 | `CALCULATE`, `FORMAT`, `IF`, `ISBLANK`, `VAR/RETURN` |
| Alquileres Tienda 2 | `CALCULATE`, `FORMAT`, `IF`, `ISBLANK`, `VAR/RETURN` |
| Ticket Tienda 1 | `CALCULATE` |
| Ticket Tienda 2 | `CALCULATE` |
| Ingresos Texto | `FORMAT`, `IF`, `ISBLANK` |
| Alquileres Texto | `FORMAT`, `IF`, `ISBLANK` |

### K3 Tasa de clientes recurrentes

Responsable: Krisley Castro (DWI-86). Tabla: `fact_alquiler`.

| Medida | Funciones DAX |
|---|---|
| K3 Clientes recurrentes | `BLANK`, `COALESCE`, `COUNTROWS`, `FILTER`, `HASONEVALUE`, `IF`, `ISBLANK`, `LOOKUPVALUE`, `SELECTEDVALUE`, `VALUES`, `VAR/RETURN` |

### K3 Clientes

Responsable: Krisley Castro (DWI-86). Tabla: `fact_alquiler`.

| Medida | Funciones DAX |
|---|---|
| K3 Clientes nuevos | `HASONEVALUE`, `IF` |
| K3 Tasa de clientes recurrentes | `DIVIDE`, `HASONEVALUE`, `IF`, `SELECTEDVALUE` |
| K3 Meta | `IF`, `ISBLANK` |

### K4 Clientes

Responsable: Krisley Castro (DWI-86). Tabla: `fact_alquiler`.

| Medida | Funciones DAX |
|---|---|
| K4 Ingreso promedio por cliente activo | `DIVIDE` |
| K4 Meta | `IF`, `ISBLANK`, `SELECTEDVALUE` |
| K4 Crecimiento mensual | `CALCULATE`, `DATESBETWEEN`, `DIVIDE`, `EOMONTH`, `HASONEVALUE`, `IF`, `ISBLANK`, `MIN`, `REMOVEFILTERS`, `VAR/RETURN` |

### K5 Rotación del inventario

Responsable: Juan Daniel Ulate (DWI-87). Tabla: `fact_alquiler`.

| Medida | Funciones DAX |
|---|---|
| K5 Rotación del inventario | `BLANK`, `COALESCE`, `DIVIDE`, `HASONEVALUE`, `IF`, `SELECTEDVALUE`, `VAR/RETURN` |
| K5 Meta | Constante (sin funciones) |
| K5 Estado | `HASONEVALUE`, `ISBLANK`, `SELECTEDVALUE`, `SWITCH`, `TRUE`, `VAR/RETURN` |
| K5 Texto | `FORMAT`, `IF`, `ISBLANK`, `VAR/RETURN` |
| K5 Color | `ISBLANK`, `SWITCH`, `TRUE`, `VAR/RETURN` |
| K5 Nota | `FORMAT`, `IF`, `ISBLANK`, `VAR/RETURN` |

### K6 Copias sin rotación

Responsable: Juan Daniel Ulate (DWI-87). Tabla: `fact_inventario`.

| Medida | Funciones DAX |
|---|---|
| K6 Copias sin rotación | `BLANK`, `COALESCE`, `COUNTROWS`, `EXCEPT`, `FILTER`, `IF`, `ISBLANK`, `VALUES`, `VAR/RETURN` |
| K6 Copias sin rotación % | `BLANK`, `DIVIDE`, `HASONEVALUE`, `IF`, `SELECTEDVALUE`, `VAR/RETURN` |
| K6 Meta | Constante (sin funciones) |
| K6 Estado | `HASONEVALUE`, `ISBLANK`, `SELECTEDVALUE`, `SWITCH`, `TRUE`, `VAR/RETURN` |
| K6 Texto | `FORMAT`, `IF`, `ISBLANK`, `VAR/RETURN` |
| K6 Color | `ISBLANK`, `SWITCH`, `TRUE`, `VAR/RETURN` |
| K6 Nota | `FORMAT`, `IF`, `ISBLANK`, `VAR/RETURN` |

### Apoyo inventario

Responsable: Juan Daniel Ulate (DWI-87). Tabla: `fact_alquiler`.

| Medida | Funciones DAX |
|---|---|
| Inventario Mes con datos | `CALCULATE`, `COUNTROWS`, `REMOVEFILTERS`, `TREATAS`, `VALUES`, `VAR/RETURN` |

### K7 Devoluciones fuera de plazo

Responsable: Marco López (DWI-88). Tabla: `fact_alquiler`.

| Medida | Funciones DAX |
|---|---|
| K7 Devoluciones tardías % | `CALCULATE`, `COUNTROWS`, `DIVIDE`, `ISBLANK`, `SUM`, `VAR/RETURN` |
| K7 Meta | Constante (sin funciones) |
| K7 Mes anterior | `BLANK`, `CALCULATE`, `IF`, `ISEMPTY`, `PREVIOUSMONTH`, `REMOVEFILTERS` |
| K7 Variación (pp) | `BLANK`, `IF`, `ISBLANK`, `VAR/RETURN` |
| K7 Texto | `BLANK`, `FORMAT`, `ISBLANK`, `ISEMPTY`, `SWITCH`, `TRUE`, `VAR/RETURN` |
| K7 Estado | `BLANK`, `ISBLANK`, `ISEMPTY`, `SWITCH`, `TRUE`, `VAR/RETURN` |
| K7 Color | `BLANK`, `ISBLANK`, `ISEMPTY`, `SWITCH`, `TRUE`, `VAR/RETURN` |
| K7 Color variación | `BLANK`, `ISBLANK`, `ISEMPTY`, `SWITCH`, `TRUE`, `VAR/RETURN` |
| K7 Variación Texto | `BLANK`, `FORMAT`, `ISBLANK`, `ISEMPTY`, `SWITCH`, `TRUE`, `VAR/RETURN` |
| K7 Medidor mínimo | Constante (sin funciones) |
| K7 Medidor máximo | Constante (sin funciones) |

### K8 Días promedio de atraso

Responsable: Marco López (DWI-88). Tabla: `fact_alquiler`.

| Medida | Funciones DAX |
|---|---|
| K8 Días promedio de atraso | `AVERAGE`, `CALCULATE` |
| K8 Meta | Constante (sin funciones) |
| K8 Mes anterior | `BLANK`, `CALCULATE`, `IF`, `ISEMPTY`, `PREVIOUSMONTH`, `REMOVEFILTERS` |
| K8 Variación (días) | `BLANK`, `IF`, `ISBLANK`, `VAR/RETURN` |
| K8 Texto | `BLANK`, `FORMAT`, `ISBLANK`, `ISEMPTY`, `SWITCH`, `TRUE`, `VAR/RETURN` |
| K8 Estado | `BLANK`, `ISBLANK`, `ISEMPTY`, `SWITCH`, `TRUE`, `VAR/RETURN` |
| K8 Color | `BLANK`, `ISBLANK`, `ISEMPTY`, `SWITCH`, `TRUE`, `VAR/RETURN` |
| K8 Color variación | `BLANK`, `ISBLANK`, `ISEMPTY`, `SWITCH`, `TRUE`, `VAR/RETURN` |
| K8 Variación Texto | `BLANK`, `FORMAT`, `ISBLANK`, `ISEMPTY`, `SWITCH`, `TRUE`, `VAR/RETURN` |

### Contexto

Responsable: Marco López (DWI-96). Tabla: `fact_alquiler`.

| Medida | Funciones DAX |
|---|---|
| Alquileres por actor | `CALCULATE`, `CROSSFILTER` |

## Medidas que no se cuentan

Medidas de prueba que quedaron en el modelo y no se usan en el dashboard: `Total alquileres`, `Copias registradas`, `Measure`, `Medida`. Conviene borrarlas antes de la entrega (DWI-98).

## Cómo se generó

Se leyeron las expresiones de todas las medidas del `.pbix` y se extrajeron los nombres de función (palabras en mayúsculas seguidas de paréntesis). `VAR/RETURN` se cuenta como una construcción del lenguaje. Si se agregan medidas, hay que volver a generar la tabla.
