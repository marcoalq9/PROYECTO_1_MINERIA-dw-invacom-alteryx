# Preparación de Pagila y conexión con Alteryx

Este documento describe la restauración de la base de datos fuente del proyecto, la configuración de la conexión ODBC y su utilización desde Alteryx.

**Estado actual:** resuelto. La conexión funciona desde Alteryx: `01_extraccion` lee las 14 tablas (32.088 alquileres, 32.093 pagos, 4.581 copias) y el ETL completo se ejecutó el 12/11/2026 (`docs/validaciones/ejecucion_ETL.md`). Las secciones 10 y 12 se conservan como registro de las incidencias.

## 1. Arquitectura del proyecto

El flujo de datos definido para el proyecto es:

PostgreSQL (Pagila) → Alteryx (ETL) → SQL Server (DW) → Excel

| Componente | Función |
|---|---|
| PostgreSQL | Almacenar la base de datos fuente Pagila. |
| Alteryx | Extraer, transformar y cargar los datos. |
| SQL Server | Almacenar el Data Warehouse. |
| Excel | Consultar el DW y presentar los reportes mediante tablas dinámicas. |

La preparación documentada corresponde a la base fuente y a su conexión con Alteryx. El diseño y la carga del DW son etapas posteriores.

## 2. Software utilizado

| Componente | Configuración |
|---|---|
| Sistema operativo | Windows de 64 bits. |
| Base de datos fuente | PostgreSQL 15. |
| Instalador de PostgreSQL | EDB con pgAdmin 4. |
| Administración de la base | pgAdmin 4. |
| Controlador de conexión | psqlODBC de 64 bits, variante PostgreSQL Unicode. |
| Herramienta ETL | Alteryx Designer. |
| Destino del DW | SQL Server. |
| Reportes | Excel. |

## 3. Configuración local

Los valores identificados en la configuración ODBC son:

| Parámetro | Valor |
|---|---|
| Base de datos | `pagila_dvd_rental` |
| DSN de Windows | `pagila_local` |
| Servidor | `localhost` |
| Puerto | `5432` |
| Usuario de PostgreSQL | `postgres` |
| SSL Mode | `disable`, según la configuración local utilizada. |
| Contraseña | Configurada localmente; no se incluye en el repositorio. |

### Diferencia entre base de datos y DSN

- `pagila_dvd_rental` es el nombre de la base de datos en PostgreSQL.
- `pagila_local` es el nombre de la conexión ODBC guardada en Windows.
- El DSN contiene la configuración necesaria para localizar el servidor, la base y el controlador.

En el campo **ODBC DSN** de Alteryx debe utilizarse `pagila_local`.

Aunque inicialmente se propuso crear la base con el nombre `pagila`, la configuración local mostrada utiliza `pagila_dvd_rental`. Cada integrante debe utilizar el nombre real de su base y documentar cualquier diferencia.

## 4. Archivos de la fuente

El profesor entregó el archivo:

`pagila_dvd_rental.zip`

El ZIP contiene scripts SQL para crear y completar la base, además de archivos CSV.

La fuente del proyecto será la base completa restaurada en PostgreSQL.

### Tratamiento de los CSV

Los CSV corresponden a una versión anterior a los cambios de los scripts 3 y 5:

- No incluyen los tres empleados adicionales.
- Les faltan aproximadamente 16000 alquileres.
- Les faltan aproximadamente 16000 pagos.
- Los años de estreno difieren de la versión completa.

**Los CSV no se utilizarán como fuente del ETL. Alteryx debe leer directamente la base completa de PostgreSQL.**

## 5. Restauración de la base

### 5.1. Preparar los archivos

1. Obtener el ZIP entregado por el profesor.
2. Descomprimirlo en una carpeta local fuera del repositorio.
3. Identificar los seis scripts numerados.

### 5.2. Crear la base

Para reproducir la instalación en otro equipo:

1. Abrir pgAdmin.
2. Conectarse al servidor PostgreSQL 15.
3. Hacer clic derecho en **Databases → Create → Database**.
4. Escribir `pagila_dvd_rental` como nombre.
5. Seleccionar `postgres` como propietario.
6. Guardar.
7. Abrir **Query Tool** sobre esa base.

El procedimiento de restauración parte de una base vacía.

### 5.3. Ajustar el primer script

Antes de ejecutar `1. pagila-schema.sql` en PostgreSQL 15, eliminar o comentar esta instrucción antigua:

```sql
SET default_with_oids = false;
```

### 5.4. Ejecutar los scripts

Desde Query Tool:

1. Abrir el archivo con **Ctrl + O**.
2. Ejecutar el script completo con **F5**.
3. Esperar a que termine.
4. Revisar la pestaña **Messages**.
5. Continuar con el siguiente archivo cuando el anterior termine sin errores.

El orden requerido es:

| Orden | Archivo | Función |
|---|---|---|
| 1 | `1. pagila-schema.sql` | Crea las tablas, tipos, funciones, índices y relaciones. |
| 2 | `2. pagila-insert-data.sql` | Inserta los datos iniciales y ajusta las secuencias. |
| 3 | `3. release_year_update.sql` | Modifica los años de estreno de las películas. |
| 4 | `4. before_additional_sakila_data.sql` | Limpia ampliaciones previas y prepara las secuencias. |
| 5 | `5. additional_sakila_data.sql` | Agrega empleados, alquileres y pagos. |
| 6 | `6. get_customer_balance.sql` | Reemplaza la función de cálculo del saldo del cliente. |

La fuente requerida por el proyecto incluye los seis scripts.

Los archivos 1 y 2 crean únicamente la versión inicial. El script 4 contiene eliminaciones y el script 5 agrega datos; por ello, la secuencia debe ejecutarse una sola vez sobre la base preparada.

Después de finalizar, actualizar:

**Schemas → public → Tables → Refresh**

## 6. Verificación de la restauración

Ejecutar las siguientes consultas por separado en Query Tool, sobre la base restaurada.

### 6.1. Confirmar base, versión y puerto

```sql
SELECT
    current_database() AS base_de_datos,
    current_setting('server_version') AS version_postgresql,
    inet_server_addr() AS direccion_servidor,
    inet_server_port() AS puerto;
```

Comprobar:

- Que la base sea la destinada a Pagila.
- Que la versión del servidor sea PostgreSQL 15.
- Que el puerto coincida con el configurado en ODBC.

### 6.2. Verificar los conteos

```sql
SELECT
    tabla,
    cantidad,
    esperado,
    CASE
        WHEN cantidad = esperado THEN 'OK'
        ELSE 'REVISAR'
    END AS resultado
FROM (
    SELECT
        'rental' AS tabla,
        COUNT(*) AS cantidad,
        32088 AS esperado
    FROM public.rental

    UNION ALL

    SELECT 'payment', COUNT(*), 32093
    FROM public.payment

    UNION ALL

    SELECT 'customer', COUNT(*), 599
    FROM public.customer

    UNION ALL

    SELECT 'film', COUNT(*), 1000
    FROM public.film

    UNION ALL

    SELECT 'inventory', COUNT(*), 4581
    FROM public.inventory

    UNION ALL

    SELECT 'staff', COUNT(*), 5
    FROM public.staff

    UNION ALL

    SELECT 'store', COUNT(*), 2
    FROM public.store
) AS control
ORDER BY tabla;
```

Los conteos esperados después de ejecutar los seis scripts son:

| Tabla | Registros esperados |
|---|---:|
| rental | 32088 |
| payment | 32093 |
| customer | 599 |
| film | 1000 |
| inventory | 4581 |
| staff | 5 |
| store | 2 |

### 6.3. Verificar las fechas de los alquileres

```sql
SELECT
    MIN(rental_date)::date AS primer_alquiler,
    MAX(rental_date)::date AS ultimo_alquiler
FROM public.rental;
```

Resultado esperado:

| Primer alquiler | Último alquiler |
|---|---|
| 2005-05-24 | 2017-02-14 |

Los conteos y las fechas anteriores son valores de referencia. Queda pendiente registrar los resultados reales de estas consultas y su fecha de ejecución.

## 7. Instalación del controlador ODBC

### 7.1. Instalar psqlODBC de 64 bits

1. Abrir **Stack Builder**.
2. Seleccionar la instalación de **PostgreSQL 15 (x64)**.
3. Abrir **Database Drivers**.
4. Seleccionar **psqlODBC (64 bit)**.
5. Completar la descarga.
6. Finalizar el asistente de instalación.

Según la versión, el controlador puede aparecer con alguno de estos nombres:

- PostgreSQL Unicode(x64).
- PostgreSQL Unicode.
- PostgreSQL ODBC Driver(UNICODE).

### 7.2. Abrir el administrador ODBC de 64 bits

Presionar **Windows + R** y ejecutar:

```text
C:\Windows\System32\odbcad32.exe
```

En Windows de 64 bits, esta ruta abre el administrador ODBC de 64 bits.

En la pestaña **Controladores / Drivers**, comprobar que aparece el controlador PostgreSQL Unicode.

## 8. Creación del DSN

1. Abrir **DSN de usuario → Agregar**.
2. Seleccionar el controlador PostgreSQL Unicode de 64 bits.
3. Completar la configuración:

| Campo | Valor utilizado |
|---|---|
| Data Source | `pagila_local` |
| Database | `pagila_dvd_rental` |
| Server | `localhost` |
| Port | `5432` |
| User Name | `postgres` |
| Password | Contraseña local del usuario PostgreSQL. |
| SSL Mode | `disable`, según la configuración local mostrada. |

4. Presionar **Test**.
5. Cuando el resultado sea exitoso, presionar **Save**.
6. Confirmar que `pagila_local` aparece en la lista de DSN.

**Resultado confirmado:** el test de conexión desde el controlador ODBC fue exitoso.

Un DSN de usuario corresponde a la cuenta de Windows que lo creó. Alteryx debe ejecutarse con acceso a ese mismo DSN.

## 9. Configuración en Alteryx

### 9.1. Crear la conexión

1. Abrir Alteryx Designer.
2. Crear un flujo nuevo.
3. Agregar una herramienta **Input Data / Datos de entrada**.
4. Abrir la configuración de conexión.
5. Seleccionar **PostgreSQL ODBC**.
6. Completar la pantalla **New Connection**.

| Campo | Valor |
|---|---|
| Connection Name | `Conexion_Pagila`, como etiqueta descriptiva. |
| Technology | `PostgreSQL ODBC` |
| Data Source | `Create new data source` |
| Data Source Name | `Fuente_Pagila`, como etiqueta descriptiva. |
| ODBC DSN | `pagila_local`, nombre exacto del DSN de Windows. |

En **ODBC DSN**, escribir únicamente:

```text
pagila_local
```

El valor debe introducirse sin comillas, espacios adicionales ni el prefijo `DSN=`.

### 9.2. Registrar las credenciales

| Campo | Configuración |
|---|---|
| Authentication Method | `Username and password` |
| Credential | `Create New Credential` |
| Credential Name | `Credencial_Pagila`, como etiqueta descriptiva. |
| Vault | `DCM` |
| Username | `postgres` |
| Password | La misma contraseña utilizada en el test exitoso de ODBC. |

El usuario y la contraseña corresponden a PostgreSQL.

La contraseña se introduce localmente en Alteryx y no se copia al repositorio.

Para esta conexión nativa de Input Data, la opción **Allow connection for SDK** puede permanecer desmarcada.

Guardar con **Save** y seleccionar **Connect**.

### 9.3. Probar la lectura

Cuando la conexión permita seleccionar tablas:

1. Elegir `public.customer`.
2. Agregar una herramienta **Browse / Examinar**.
3. Conectar la salida de Input Data con la entrada de Browse.
4. Ejecutar el flujo con **Run**.
5. Comprobar que se leen **599 registros**.

También puede utilizarse esta consulta desde Input Data:

```sql
SELECT *
FROM public.customer;
```

**Esta prueba sigue pendiente de confirmación.**

El test exitoso del controlador ODBC confirma esa conexión local; la lectura desde Alteryx debe verificarse por separado.

## 10. Incidencias registradas

### 10.1. El controlador Unicode no aparecía

Se indicó comprobar:

- Que se estuviera utilizando el administrador ODBC de 64 bits.
- Que estuviera instalado psqlODBC de 64 bits.

Posteriormente se confirmó que el controlador ya aparecía.

### 10.2. La base indicada no existía

Durante la configuración se reportó un error al buscar la base `pagia`.

Se aclaró que el campo **Database** debe coincidir exactamente con el nombre real de la base en pgAdmin.

La configuración posterior mostró `pagila_dvd_rental` como base. Después se informó un test ODBC exitoso.

### 10.3. Confusión entre base de datos y DSN

En una captura de Alteryx, el campo **ODBC DSN** contenía:

```text
pagila_dvd_rental
```

La captura del controlador mostró que los valores eran:

| Elemento | Nombre |
|---|---|
| Base de datos | `pagila_dvd_rental` |
| DSN de Windows | `pagila_local` |

Se indicó cambiar **ODBC DSN** de Alteryx a `pagila_local` y guardar los cambios.

### 10.4. Último error de Alteryx

El último intento reportó:

```text
Internal Error SQLDriverConnect:
[Microsoft][Administrador de controladores ODBC]
No se encuentra el nombre del origen de datos y no se especificó
ningún controlador predeterminado.

[Microsoft][Administrador de controladores ODBC]
Atributo de cadena de conexión no válido.
```

Este error requiere comprobar que Alteryx pueda localizar el DSN y cargar su controlador.

La causa exacta todavía no está confirmada.

Comprobaciones pendientes:

1. Abrir el administrador ODBC de 64 bits.
2. Verificar que el controlador PostgreSQL Unicode esté instalado allí.
3. Confirmar que `pagila_local` aparece guardado como DSN.
4. Probar la conexión desde su configuración.
5. Guardar con **Save**.
6. Confirmar que Alteryx contiene exactamente `pagila_local` en **ODBC DSN**.
7. Guardar los cambios en Alteryx.
8. Volver a seleccionar la conexión desde Input Data.
9. Intentar la lectura de `public.customer`.

Si el error continúa, comparar las capturas del DSN registrado en Windows y del campo ODBC DSN en Alteryx.

**Estado de la incidencia:** resuelta; Alteryx lee la fuente mediante la conexión DCM a `pagila_local`.

## 11. Reglas para el repositorio

La documentación debe permitir que cada integrante reproduzca la preparación local.

- Guardar esta documentación en `datos/README.md`.
- Documentar las versiones utilizadas.
- Conservar el orden de ejecución de los seis scripts.
- Registrar los resultados reales de las consultas de verificación.
- Documentar cualquier configuración diferente.
- Mantener fuera del repositorio los scripts originales de la fuente.
- Mantener fuera del repositorio el ZIP y los respaldos de PostgreSQL.
- No utilizar los CSV originales como entrada del ETL.
- No incluir contraseñas en archivos versionados.
- No incluir cadenas de conexión con contraseñas.
- Configurar la base y el DSN en el equipo de cada integrante.

## 12. Estado de avance

| Actividad | Estado |
|---|---|
| Definir el flujo PostgreSQL → Alteryx → SQL Server → Excel | Definido. |
| Identificar los scripts y el orden de ejecución | Documentado. |
| Identificar la configuración local de base y DSN | Confirmado mediante capturas. |
| Probar la conexión desde el controlador ODBC | Exitoso, confirmado por el usuario. |
| Registrar conteos y fechas reales de la base restaurada | Hecho (`docs/validaciones/conteos_totales.md`). |
| Configurar y probar la conexión en Alteryx | Hecho. |
| Leer 599 clientes desde Input Data | Hecho. |
| Diseñar y cargar el DW en SQL Server | Hecho (`sql/` y `alteryx/workflows/`). |
| Construir los reportes de Excel | Hecho (`reportes/reportes_invacom.xlsx`). |
