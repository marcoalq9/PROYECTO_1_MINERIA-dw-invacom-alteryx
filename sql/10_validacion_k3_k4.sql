/* Proyecto 2 - Validación de K3 y K4
   Responsable: Krisley Endrina Castro Barrantes.
   Resultados mensuales por tienda y total del negocio. */

USE DW_Invacom;
GO

DECLARE @desde date = '20050501', @hasta date = '20050901';

WITH alquiler AS (
    SELECT a.cliente_key, t.store_id, f.fecha, a.monto,
           DATEFROMPARTS(f.anio, f.mes, 1) AS mes
    FROM dbo.fact_alquiler a
    JOIN dbo.dim_fecha f ON f.fecha_key = a.fecha_key
    JOIN dbo.dim_tienda t ON t.tienda_key = a.tienda_key
),
primer_alquiler AS (
    SELECT cliente_key, MIN(fecha) AS primera_fecha
    FROM alquiler
    GROUP BY cliente_key
),
mensual AS (
    SELECT a.mes, a.store_id,
           COUNT(DISTINCT a.cliente_key) AS activos,
           COUNT(DISTINCT CASE WHEN p.primera_fecha >= a.mes
                THEN a.cliente_key END) AS nuevos,
           SUM(a.monto) AS ingresos,
           SUM(CASE WHEN p.primera_fecha >= a.mes
                THEN a.monto ELSE 0 END) AS ingresos_nuevos,
           SUM(CASE WHEN p.primera_fecha < a.mes
                THEN a.monto ELSE 0 END) AS ingresos_recurrentes
    FROM alquiler a
    JOIN primer_alquiler p ON p.cliente_key = a.cliente_key
    GROUP BY GROUPING SETS ((a.mes, a.store_id), (a.mes))
),
kpis AS (
    SELECT *,
           activos - nuevos AS recurrentes,
           CASE WHEN mes <> '20050501'
                THEN (activos - nuevos) * 1.0 / NULLIF(activos, 0)
           END AS k3,
           ingresos * 1.0 / NULLIF(activos, 0) AS k4
    FROM mensual
)
SELECT a.mes,
       COALESCE(CAST(a.store_id AS varchar(10)), 'Todas') AS tienda,
       a.activos, a.nuevos, a.recurrentes,
       ROUND(a.k3, 6) AS k3_tasa,
       0.85 AS k3_meta,
       ROUND(p.k3, 6) AS k3_anterior,
       ROUND((a.k3 - p.k3) * 100, 2) AS k3_variacion_pp,
       CASE WHEN a.k3 IS NULL THEN N'Sin historial previo'
            WHEN a.k3 >= 0.85 THEN N'Cumple la meta'
            ELSE N'No cumple la meta' END AS k3_estado,
       a.ingresos,
       ROUND(a.k4, 2) AS k4_promedio,
       ROUND(p.k4, 2) AS k4_anterior,
       ROUND(a.k4 - p.k4, 2) AS k4_variacion,
       ROUND((a.k4 - p.k4) / NULLIF(p.k4, 0), 6) AS k4_crecimiento,
       0.05 AS k4_meta,
       CASE WHEN p.k4 IS NULL OR p.k4 = 0 THEN N'Sin dato'
            WHEN a.mes = '20050601' THEN N'Comparación con mes parcial'
            WHEN (a.k4 - p.k4) / NULLIF(p.k4, 0) >= 0.05
                THEN N'Cumple la meta'
            ELSE N'No cumple la meta' END AS k4_estado,
       ROUND(a.ingresos_nuevos / NULLIF(a.nuevos, 0), 2)
           AS promedio_nuevos,
       ROUND(a.ingresos_recurrentes / NULLIF(a.recurrentes, 0), 2)
           AS promedio_recurrentes
FROM kpis a
LEFT JOIN kpis p ON p.mes = DATEADD(month, -1, a.mes)
    AND (p.store_id = a.store_id
         OR (p.store_id IS NULL AND a.store_id IS NULL))
WHERE a.mes >= @desde AND a.mes < @hasta
ORDER BY a.mes, a.store_id;
GO