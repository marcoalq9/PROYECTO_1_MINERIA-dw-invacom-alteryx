# Scripts SQL del Data Warehouse y Power BI

Orden sugerido de ejecución:

1. `01_crear_bd.sql` — crea la base de datos del DW
2. `02_dimensiones.sql` — tablas de dimensiones
3. `03_hechos.sql` — tabla(s) de hechos y llaves foráneas
4. `05_validacion_dw.sql` — conteos y totales del DW, después de correr el ETL (DWI-39)
5. `06_validacion_reportes.sql` — consultas para comparar con las tablas dinámicas de Excel
6. `07_validacion_k7_k8.sql` — valores de K7 y K8 por tienda y mes, para comparar con las medidas DAX de Power BI (DWI-88)
7. `08_validacion_k1_k2.sql` — valores de K1 y K2 por tienda y mes, para comparar con las medidas DAX de Power BI (DWI-85)

`05_validacion_conteos_totales.sql` se ejecuta en **PostgreSQL** sobre la base fuente
(`pagila_dvd_rental`), no en el DW: da los conteos antes de la limpieza.

No se crearon vistas: el libro de Excel consulta las tablas del DW con Power Query.
No ejecutar `02_dimensiones.sql` sobre un DW con datos: borra y recrea las tablas.
