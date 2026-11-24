-- DWI-85: Validación de K1 (crecimiento mensual de ingresos) y K2 (ticket promedio por alquiler)
-- Responsable: Kristel Daniela Ramírez Duarte
-- Calcula los mismos valores que las medidas DAX de powerbi/medidas/k1_k2.md,
-- por tienda y mes de inicio del alquiler, más los totales por mes (ambas tiendas).
-- El mes anterior es el mes calendario anterior: si no tiene alquileres
-- (abril de 2005, enero de 2017), K1 queda en NULL («Sin dato» en Power BI).

USE DW_Invacom;
GO

WITH por_mes AS (
    SELECT
        CASE WHEN GROUPING(t.store_id) = 1 THEN 'Todas'
             ELSE CAST(t.store_id AS VARCHAR(10)) END AS tienda,
        DATEFROMPARTS(f.anio, f.mes, 1)               AS inicio_mes,
        SUM(a.monto)                                  AS ingresos,
        SUM(CAST(a.cantidad AS INT))                  AS alquileres
    FROM dbo.fact_alquiler AS a
    JOIN dbo.dim_fecha     AS f ON f.fecha_key  = a.fecha_key
    JOIN dbo.dim_tienda    AS t ON t.tienda_key = a.tienda_key
    GROUP BY GROUPING SETS (
        (t.store_id, f.anio, f.mes),   -- tienda y mes
        (f.anio, f.mes)                -- mes, ambas tiendas
    )
)
SELECT
    m.tienda,
    FORMAT(m.inicio_mes, 'yyyy-MM')                              AS mes,
    m.ingresos,
    ant.ingresos                                                 AS ingresos_mes_anterior,
    CAST(100.0 * (m.ingresos - ant.ingresos)
         / NULLIF(ant.ingresos, 0) AS DECIMAL(7, 1))             AS k1_pct,
    m.alquileres,
    CAST(m.ingresos / NULLIF(m.alquileres, 0) AS DECIMAL(6, 2))  AS k2_ticket
FROM por_mes AS m
LEFT JOIN por_mes AS ant
       ON ant.tienda     = m.tienda
      AND ant.inicio_mes = DATEADD(MONTH, -1, m.inicio_mes)
ORDER BY CASE WHEN m.tienda = 'Todas' THEN 1 ELSE 0 END, m.tienda, m.inicio_mes;

-- K2 por tienda y total general (el promedio de todo el período no es el promedio de los meses).
SELECT
    CASE WHEN GROUPING(t.store_id) = 1 THEN 'Todas'
         ELSE CAST(t.store_id AS VARCHAR(10)) END                AS tienda,
    SUM(a.monto)                                                 AS ingresos,
    SUM(CAST(a.cantidad AS INT))                                 AS alquileres,
    CAST(SUM(a.monto) / NULLIF(SUM(CAST(a.cantidad AS INT)), 0)
         AS DECIMAL(6, 2))                                       AS k2_ticket
FROM dbo.fact_alquiler AS a
JOIN dbo.dim_tienda    AS t ON t.tienda_key = a.tienda_key
GROUP BY GROUPING SETS ((t.store_id), ())
ORDER BY GROUPING(t.store_id), t.store_id;

-- Esperado en el total general (Proyecto 1): ingresos 67 406.56, alquileres 16 044, k2_ticket 4.20.
-- K1 de mayo de 2005 y de febrero de 2017 queda en NULL: no hay alquileres en el mes anterior.
