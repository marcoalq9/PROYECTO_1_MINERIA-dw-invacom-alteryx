
# Dimensión Tiempo — DWI-36

**Responsable:** Krisley Castro Barrantes  
**Workflow:** `alteryx/workflows/dim_fecha.yxmd`

## Objetivo

Generar y cargar la dimensión tiempo del Data Warehouse de Invacom Inc S.A., con todas las fechas desde el 24/05/2005 hasta el 14/02/2017.

Esta dimensión permitirá analizar los alquileres según el día, mes, trimestre y año.

## Herramientas utilizadas

| Herramienta | Función |
|---|---|
| Generate Rows | Genera una fila por cada día del rango establecido. |
| Formula | Calcula los atributos de la fecha. |
| Select | Organiza las columnas y sus tipos de datos. |
| Browse | Permite revisar los registros generados. |
| Output Data | Carga los registros en SQL Server. |

## Estructura de la dimensión

La tabla `dim_fecha` contiene ocho columnas:

| Campo | Tipo SQL Server | Descripción |
|---|---|---|
| fecha_key | INT | Llave primaria con formato AAAAMMDD. |
| fecha | DATE | Fecha completa. |
| dia | TINYINT | Número del día. |
| nombre_dia | NVARCHAR(10) | Nombre del día en español. |
| mes | TINYINT | Número del mes. |
| nombre_mes | NVARCHAR(10) | Nombre del mes en español. |
| trimestre | TINYINT | Trimestre del año. |
| anio | SMALLINT | Año correspondiente. |

## Configuración del flujo

### 1. Generación de fechas

Se utilizó Generate Rows para crear las fechas automáticamente.

- **Fecha inicial:** 2005-05-24
- **Fecha final:** 2017-02-14
- **Incremento:** 1 día
- **Total esperado:** 4.285 registros

### 2. Transformación

Mediante Formula se calcularon los siguientes campos:

- `fecha_key`: identificador numérico en formato AAAAMMDD.
- `dia`: día del mes.
- `nombre_dia`: nombre del día en español.
- `mes`: número del mes.
- `nombre_mes`: nombre del mes en español.
- `trimestre`: trimestre correspondiente.
- `anio`: año de la fecha.

### 3. Carga de datos

Los registros se cargaron mediante Output Data en:

- **Motor:** SQL Server
- **Base de datos:** `DW_Invacom`
- **Tabla:** `dbo.dim_fecha`
- **Método:** Append Existing
- **Mapeo:** By Field Name

La conexión se configuró mediante ODBC en Alteryx. Como utiliza una conexión local, cada integrante debe configurar la suya antes de ejecutar el flujo en otro equipo.

Antes de realizar una nueva carga, se debe comprobar que la tabla esté vacía para evitar registros duplicados.

## Validación

Después de ejecutar el flujo, se utilizó la siguiente consulta en SQL Server:

```sql
USE DW_Invacom;
GO

SELECT
    COUNT(*) AS total_registros,
    MIN(fecha) AS primera_fecha,
    MAX(fecha) AS ultima_fecha,
    COUNT(DISTINCT fecha_key) AS fechas_unicas
FROM dbo.dim_fecha;
```

## Integración con los demás flujos ETL

La dimensión `dim_fecha` se genera de forma independiente de los archivos de extracción y limpieza, ya que utiliza un calendario creado directamente en Alteryx.

Por esta razón, no necesita leer los archivos `.yxdb` generados por los flujos `01_extraccion` y `02_limpieza`.

### Relación con la tabla de hechos

La tabla `fact_alquiler` utilizará el campo `fecha_key` para relacionar cada alquiler con su fecha correspondiente en `dim_fecha`.

La llave debe calcularse utilizando `rental_date`, con el formato AAAAMMDD.

Por ejemplo:

- Fecha del alquiler: `2005-05-24`
- Llave correspondiente: `20050524`

Este formato debe mantenerse igual en ambos flujos para que la relación funcione correctamente.

### Orden de carga

La tabla `dim_fecha` debe estar cargada antes de insertar los registros de `fact_alquiler`, ya que esta última utiliza `fecha_key` como llave foránea.

El flujo está preparado para cargar las fechas en `dbo.dim_fecha`, pero cada integrante deberá configurar su propia conexión a SQL Server.

### Consideraciones importantes

- La carga realizada corresponde únicamente a la base de datos local donde se ejecutó el flujo.
- Los registros no se transfieren automáticamente al SQL Server de los demás integrantes.
- Antes de ejecutar el flujo se debe verificar que `dbo.dim_fecha` esté vacía.
- No se debe ejecutar nuevamente sobre una tabla que ya contenga las 4.285 fechas, porque se producirán errores por llaves duplicadas.
- No se debe volver a ejecutar `sql/02_dimensiones.sql` sobre una base con datos cargados, porque ese script elimina y vuelve a crear las tablas.

### Resultados obtenidos

| Validación | Resultado |
|---|---|
| Total de registros | 4.285 |
| Primera fecha | 2005-05-24 |
| Última fecha | 2017-02-14 |
| Fechas únicas | 4.285 |

Los resultados coinciden con el rango establecido y confirman que no existen fechas duplicadas.

## Resultado final

Se completó la generación y carga local de la dimensión `dim_fecha` con los 4.285 registros esperados y sus ocho atributos.

La dimensión queda preparada para relacionarse con `fact_alquiler` mediante `fecha_key`, permitiendo realizar análisis de alquileres por diferentes períodos de tiempo.

