-- DWI-88: Validación de K7 (devoluciones fuera de plazo) y K8 (días promedio de atraso)
-- Responsable: Marco Andrey López Quesada
-- Calcula los mismos valores que las medidas DAX de powerbi/medidas/k7_k8.md,
-- por tienda y mes de inicio del alquiler, con subtotales por mes, por tienda y total.

USE DW_Invacom;
GO

SET ANSI_WARNINGS OFF;  -- evita el aviso por los nulos de devolucion_tardia en COUNT y AVG

SELECT
    CASE WHEN GROUPING(t.store_id) = 1 THEN 'Todas'
         ELSE CAST(t.store_id AS VARCHAR(10)) END                  AS tienda,
    CASE WHEN GROUPING(f.anio) = 1 THEN 'Total'
         ELSE CONCAT(f.anio, '-', RIGHT('0' + CAST(f.mes AS VARCHAR(2)), 2)) END AS mes,
    COUNT(*)                                                       AS alquileres,
    SUM(CAST(a.devolucion_tardia AS INT))                          AS tardias,
    COUNT(a.devolucion_tardia)                                     AS devueltos_evaluables,
    CAST(100.0 * SUM(CAST(a.devolucion_tardia AS INT))
         / NULLIF(COUNT(a.devolucion_tardia), 0) AS DECIMAL(5, 1)) AS k7_pct,
    CAST(AVG(CASE WHEN a.devolucion_tardia = 1 THEN a.dias_atraso END)
         AS DECIMAL(6, 1))                                         AS k8_dias
FROM dbo.fact_alquiler AS a
JOIN dbo.dim_fecha     AS f ON f.fecha_key  = a.fecha_key
JOIN dbo.dim_tienda    AS t ON t.tienda_key = a.tienda_key
GROUP BY GROUPING SETS (
    (t.store_id, f.anio, f.mes),   -- tienda y mes
    (f.anio, f.mes),               -- mes, ambas tiendas
    (t.store_id),                  -- tienda, todo el período
    ()                             -- total general
)
ORDER BY GROUPING(t.store_id), t.store_id, GROUPING(f.anio), f.anio, f.mes;

SET ANSI_WARNINGS ON;

-- Esperado en el total general (Proyecto 1): tardias 8 121, devueltos_evaluables 15 861, k7_pct 51.2
-- Los meses sin devoluciones (febrero de 2017) muestran k7_pct y k8_dias en NULL: en Power BI, «Sin dato».
