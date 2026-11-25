USE DW_Invacom;
GO

;WITH alquileres_mes AS (
    SELECT a.tienda_key, a.inventario_id, a.cantidad
    FROM dbo.fact_alquiler AS a
    INNER JOIN dbo.dim_fecha AS f
        ON a.fecha_key = f.fecha_key
    WHERE f.anio = 2005 AND f.mes = 6
),
alquileres_tienda AS (
    SELECT tienda_key, SUM(cantidad) AS alquileres
    FROM alquileres_mes
    GROUP BY tienda_key
),
copias_alquiladas AS (
    SELECT DISTINCT tienda_key, inventario_id
    FROM alquileres_mes
),
inventario_tienda AS (
    SELECT
        i.tienda_key,
        SUM(i.cantidad_copias) AS copias,
        SUM(CASE
            WHEN c.inventario_id IS NULL
            THEN i.cantidad_copias ELSE 0
        END) AS sin_rotacion
    FROM dbo.fact_inventario AS i
    LEFT JOIN copias_alquiladas AS c
        ON i.inventario_id = c.inventario_id
        AND i.tienda_key = c.tienda_key
    GROUP BY i.tienda_key
)
SELECT
    CASE
        WHEN GROUPING(t.store_id) = 1 THEN 'Total'
        ELSE CAST(t.store_id AS VARCHAR(10))
    END AS tienda,
    SUM(COALESCE(a.alquileres, 0)) AS alquileres,
    SUM(i.copias) AS copias,
    CAST(
        1.0 * SUM(COALESCE(a.alquileres, 0))
        / NULLIF(SUM(i.copias), 0)
        AS DECIMAL(10,2)
    ) AS k5_rotacion,
    SUM(i.sin_rotacion) AS copias_sin_rotacion,
    CAST(
        100.0 * SUM(i.sin_rotacion)
        / NULLIF(SUM(i.copias), 0)
        AS DECIMAL(10,2)
    ) AS k6_porcentaje
FROM dbo.dim_tienda AS t
INNER JOIN inventario_tienda AS i
    ON t.tienda_key = i.tienda_key
LEFT JOIN alquileres_tienda AS a
    ON t.tienda_key = a.tienda_key
GROUP BY GROUPING SETS ((t.store_id), ())
ORDER BY GROUPING(t.store_id), t.store_id;