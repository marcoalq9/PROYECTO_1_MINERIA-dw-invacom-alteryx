# Extracción de Pagila — DWI-34

Workflow: `alteryx/workflows/01_extraccion.yxmd`.

Contiene 14 Input Data, 14 Output Data y 14 Browse. Lee el esquema public de pagila_dvd_rental mediante la conexión DCM local `Fuente_Pagila — Credencial_Pagila` (DSN `pagila_local`). Las credenciales permanecen en DCM; el archivo solo guarda la referencia a la conexión.

Tablas: rental, payment, inventory, film, film_category, category, language, actor, film_actor, customer, address, city, country y store. staff se excluye porque el modelo vigente no tiene dimensión de empleado ni atributo de gerente.

Las consultas seleccionan los campos analíticos y las llaves necesarias, sin filtros de filas, uniones ni deduplicación. payment se consulta desde la tabla madre para incluir todas las particiones. Se conservan nulos y duplicados para 02_limpieza; se aplica TRIM al nombre del idioma (C11). Se excluyen campos personales sin uso analítico, distrito y campos de auditoría. Los timestamps mantienen el comportamiento ODBC de los flujos de perfilado; la zona horaria de negocio debe acordarse para la etapa de transformación.

## Ejecución

1. Abrir el workflow desde su ubicación dentro del repositorio.
2. En otro equipo, crear o seleccionar la conexión DCM a la BD fuente en cada Input Data: los identificadores DCM son locales.
3. Asegurar que exista `datos/extraccion/` y ejecutar con Ctrl+R.
4. Revisar Results y Browse. Cada ejecución reemplaza las extracciones anteriores de su tabla.

Los archivos `datos/extraccion/<tabla>.yxdb` usan rutas relativas al workflow y alimentarán 02_limpieza. Están excluidos de Git por la regla existente `*.yxdb`. No consumir una extracción parcial si la ejecución falla: corregir y volver a ejecutar el flujo completo. Las lecturas son independientes, sin una transacción común; ejecutar con la fuente estable para obtener un corte consistente.

## Validación realizada

El 4 de noviembre de 2026 se ejecutó en Alteryx Designer 2025.2 con AMP: finalizó en 2,9 segundos y generó los 14 archivos YXDB. Results confirmó 32.088 registros de rental, 32.093 de payment y 4.581 de inventory, coincidentes con el inventario del proyecto. No se aplicaron las reglas de limpieza ni se cargó el DW.
