-- Identificacion de la base de datos y sus tablas
SELECT
    current_database() AS base_de_datos,
    table_schema AS esquema,
    table_name AS tabla
FROM information_schema.tables
WHERE table_type = 'BASE TABLE'
  AND table_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY table_schema, table_name;

-- Conteo de la fuente antes de limpiar

SELECT 'rental' AS tabla, COUNT(*) AS registros
FROM public.rental

UNION ALL

SELECT 'payment', COUNT(*)
FROM public.payment

UNION ALL

SELECT 'inventory', COUNT(*)
FROM public.inventory

UNION ALL

SELECT 'film_actor', COUNT(*)
FROM public.film_actor;