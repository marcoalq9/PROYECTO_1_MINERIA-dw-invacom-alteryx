-- DWI-39: Validación de conteos y totales del DW
-- Responsable: Juan Daniel Ulate Aguilar

USE DW_Invacom;
GO

-- 1. Validar la dimensión de fechas
SELECT
    COUNT(*) AS total_fechas,
    COUNT(DISTINCT fecha_key) AS fechas_unicas,
    MIN(fecha) AS primera_fecha,
    MAX(fecha) AS ultima_fecha
FROM dbo.dim_fecha;

-- 2. Validar los conteos de las demás dimensiones
SELECT 'dim_cliente' AS tabla, COUNT(*) AS registros
FROM dbo.dim_cliente
UNION ALL
SELECT 'dim_pelicula', COUNT(*) FROM dbo.dim_pelicula
UNION ALL
SELECT 'dim_tienda', COUNT(*) FROM dbo.dim_tienda
UNION ALL
SELECT 'dim_actor', COUNT(*) FROM dbo.dim_actor;

-- 3. Validar alquileres, ingresos y pagos
SELECT
    COUNT(*) AS alquileres,
    SUM(monto) AS ingresos,
    SUM(cantidad_pagos) AS pagos_validos,
    SUM(CASE WHEN devuelto = 0 THEN 1 ELSE 0 END) AS sin_devolver
FROM dbo.fact_alquiler;

-- 4. Validar las copias de inventario
SELECT COUNT(*) AS copias
FROM dbo.fact_inventario;

-- 5. Validar las relaciones película–actor
SELECT COUNT(*) AS relaciones_pelicula_actor
FROM dbo.bridge_pelicula_actor;