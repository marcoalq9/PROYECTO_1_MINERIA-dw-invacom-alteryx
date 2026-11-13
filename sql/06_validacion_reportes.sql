USE DW_Invacom;
GO

SELECT
    f.anio,
    f.mes,
    t.store_id AS tienda,
    SUM(a.cantidad) AS alquileres,
    SUM(a.monto) AS ingresos
FROM dbo.fact_alquiler AS a
INNER JOIN dbo.dim_fecha AS f
    ON a.fecha_key = f.fecha_key
INNER JOIN dbo.dim_tienda AS t
    ON a.tienda_key = t.tienda_key
GROUP BY
    f.anio,
    f.mes,
    t.store_id
ORDER BY
    f.anio,
    f.mes,
    t.store_id;



-- Promedio por pago por año, mes y tienda
SELECT
    f.anio,
    f.mes,
    t.store_id AS tienda,
    SUM(a.cantidad_pagos) AS pagos,
    CAST(
        SUM(a.monto) / NULLIF(SUM(a.cantidad_pagos), 0)
        AS DECIMAL(10,2)
    ) AS promedio_por_pago
FROM dbo.fact_alquiler AS a
INNER JOIN dbo.dim_fecha AS f
    ON a.fecha_key = f.fecha_key
INNER JOIN dbo.dim_tienda AS t
    ON a.tienda_key = t.tienda_key
GROUP BY f.anio, f.mes, t.store_id
ORDER BY f.anio, f.mes, t.store_id;






-- Películas más alquiladas: diez primeras incluyendo empates
;WITH conteos AS (
    SELECT
        p.film_id,
        p.titulo,
        SUM(a.cantidad) AS alquileres
    FROM dbo.fact_alquiler AS a
    INNER JOIN dbo.dim_pelicula AS p
        ON a.pelicula_key = p.pelicula_key
    GROUP BY p.film_id, p.titulo
),
ranking AS (
    SELECT
        film_id,
        titulo,
        alquileres,
        RANK() OVER (ORDER BY alquileres DESC) AS posicion
    FROM conteos
)
SELECT
    posicion,
    film_id,
    titulo,
    alquileres
FROM ranking
WHERE posicion <= 10
ORDER BY alquileres DESC, titulo, film_id;





-- Ingresos por categoría, año y mes
SELECT
    p.categoria,
    f.anio,
    f.mes,
    SUM(a.monto) AS ingresos
FROM dbo.fact_alquiler AS a
INNER JOIN dbo.dim_fecha AS f
    ON a.fecha_key = f.fecha_key
INNER JOIN dbo.dim_pelicula AS p
    ON a.pelicula_key = p.pelicula_key
GROUP BY
    p.categoria,
    f.anio,
    f.mes
ORDER BY
    p.categoria,
    f.anio,
    f.mes;









-- Diez clientes con mayores pagos, incluyendo empates
;WITH totales AS (
    SELECT
        c.customer_id,
        c.nombre_completo AS cliente,
        SUM(a.monto) AS pagos_acumulados
    FROM dbo.fact_alquiler AS a
    INNER JOIN dbo.dim_cliente AS c
        ON a.cliente_key = c.cliente_key
    GROUP BY
        c.customer_id,
        c.nombre_completo
),
ranking AS (
    SELECT
        customer_id,
        cliente,
        pagos_acumulados,
        RANK() OVER (
            ORDER BY pagos_acumulados DESC
        ) AS posicion
    FROM totales
)
SELECT
    posicion,
    customer_id,
    cliente,
    pagos_acumulados
FROM ranking
WHERE posicion <= 10
ORDER BY pagos_acumulados DESC, customer_id;










-- Alquileres por país y ciudad del cliente
SELECT
    c.pais,
    c.ciudad,
    SUM(a.cantidad) AS alquileres
FROM dbo.fact_alquiler AS a
INNER JOIN dbo.dim_cliente AS c
    ON a.cliente_key = c.cliente_key
GROUP BY c.pais, c.ciudad
ORDER BY c.pais, c.ciudad;

-- Resumen de control geográfico
;WITH grupos AS (
    SELECT
        c.pais,
        c.ciudad,
        SUM(a.cantidad) AS alquileres
    FROM dbo.fact_alquiler AS a
    INNER JOIN dbo.dim_cliente AS c
        ON a.cliente_key = c.cliente_key
    GROUP BY c.pais, c.ciudad
)
SELECT
    COUNT(*) AS grupos_pais_ciudad,
    COUNT(DISTINCT pais) AS paises,
    SUM(alquileres) AS total_alquileres
FROM grupos;






-- Diez actores con más alquileres, incluyendo empates
;WITH conteos AS (
    SELECT
        ac.actor_id,
        ac.nombre_completo AS actor,
        COUNT(DISTINCT a.alquiler_id) AS alquileres
    FROM dbo.fact_alquiler AS a
    INNER JOIN dbo.bridge_pelicula_actor AS b
        ON a.pelicula_key = b.pelicula_key
    INNER JOIN dbo.dim_actor AS ac
        ON b.actor_key = ac.actor_key
    GROUP BY ac.actor_id, ac.nombre_completo
),
ranking AS (
    SELECT
        actor_id,
        actor,
        alquileres,
        RANK() OVER (ORDER BY alquileres DESC) AS posicion
    FROM conteos
)
SELECT
    posicion,
    actor_id,
    actor,
    alquileres
FROM ranking
WHERE posicion <= 10
ORDER BY alquileres DESC, actor_id;







-- Alquileres e ingresos por clasificación y tienda
SELECT
    p.clasificacion,
    t.store_id AS tienda,
    SUM(a.cantidad) AS alquileres,
    SUM(a.monto) AS ingresos
FROM dbo.fact_alquiler AS a
INNER JOIN dbo.dim_pelicula AS p
    ON a.pelicula_key = p.pelicula_key
INNER JOIN dbo.dim_tienda AS t
    ON a.tienda_key = t.tienda_key
GROUP BY
    p.clasificacion,
    t.store_id
ORDER BY
    p.clasificacion,
    t.store_id;







        -- Devoluciones tardías por año, mes y tienda
    SELECT
        f.anio,
        f.mes,
        t.store_id AS tienda,
        SUM(a.devuelto) AS devueltos,
        COALESCE(SUM(a.devolucion_tardia), 0) AS tardias,
        CAST(
            100.0 * COALESCE(SUM(a.devolucion_tardia), 0)
            / NULLIF(SUM(a.devuelto), 0)
            AS DECIMAL(10,2)
        ) AS porcentaje_tardio
    FROM dbo.fact_alquiler AS a
    INNER JOIN dbo.dim_fecha AS f
        ON a.fecha_key = f.fecha_key
    INNER JOIN dbo.dim_tienda AS t
        ON a.tienda_key = t.tienda_key
    GROUP BY f.anio, f.mes, t.store_id
    ORDER BY f.anio, f.mes, t.store_id;

    -- Porcentaje general: cociente de los totales
    SELECT
        SUM(devuelto) AS devueltos,
        COALESCE(SUM(devolucion_tardia), 0) AS tardias,
        CAST(
            100.0 * COALESCE(SUM(devolucion_tardia), 0)
            / NULLIF(SUM(devuelto), 0)
            AS DECIMAL(10,2)
        ) AS porcentaje_tardio
    FROM dbo.fact_alquiler;





-- Inventario sin rotación: tercer trimestre de 2005
;WITH movimientos AS (
    SELECT DISTINCT a.inventario_id
    FROM dbo.fact_alquiler AS a
    INNER JOIN dbo.dim_fecha AS f
        ON a.fecha_key = f.fecha_key
    WHERE f.anio = 2005
      AND f.trimestre = 3
),
detalle AS (
    SELECT
        p.film_id,
        p.titulo AS pelicula,
        t.store_id AS tienda,
        COUNT(i.inventario_id) AS copias,
        SUM(CASE
            WHEN i.inventario_id IS NOT NULL
             AND m.inventario_id IS NULL THEN 1
            ELSE 0
        END) AS copias_sin_rotacion
    FROM dbo.dim_pelicula AS p
    CROSS JOIN dbo.dim_tienda AS t
    LEFT JOIN dbo.fact_inventario AS i
        ON p.pelicula_key = i.pelicula_key
        AND t.tienda_key = i.tienda_key
    LEFT JOIN movimientos AS m
        ON i.inventario_id = m.inventario_id
    GROUP BY p.film_id, p.titulo, t.store_id
)
SELECT *
INTO #validacion_inventario
FROM detalle;

-- Detalle por película y tienda
SELECT
    film_id,
    pelicula,
    tienda,
    copias,
    copias_sin_rotacion,
    CAST(
        100.0 * copias_sin_rotacion / NULLIF(copias, 0)
        AS DECIMAL(10,2)
    ) AS porcentaje_sin_rotacion
FROM #validacion_inventario
ORDER BY film_id, tienda;

-- Resumen general
SELECT
    COUNT(*) AS grupos_pelicula_tienda,
    SUM(copias) AS copias,
    SUM(copias_sin_rotacion) AS copias_sin_rotacion,
    SUM(CASE WHEN copias = 0 THEN 1 ELSE 0 END) AS grupos_sin_copias,
    CAST(
        100.0 * SUM(copias_sin_rotacion)
        / NULLIF(SUM(copias), 0)
        AS DECIMAL(10,2)
    ) AS porcentaje_sin_rotacion
FROM #validacion_inventario;

DROP TABLE #validacion_inventario;






-- Ticket promedio por cliente y categoría
SELECT
    p.categoria,
    c.customer_id,
    c.nombre_completo AS cliente,
    SUM(a.cantidad) AS alquileres,
    SUM(a.monto) AS ingresos,
    CAST(
        SUM(a.monto) / NULLIF(SUM(a.cantidad), 0)
        AS DECIMAL(10,2)
    ) AS ticket_promedio
FROM dbo.fact_alquiler AS a
INNER JOIN dbo.dim_cliente AS c
    ON a.cliente_key = c.cliente_key
INNER JOIN dbo.dim_pelicula AS p
    ON a.pelicula_key = p.pelicula_key
GROUP BY
    p.categoria,
    c.customer_id,
    c.nombre_completo
ORDER BY
    p.categoria,
    c.customer_id;





-- Historial para validar frecuencia y clientes por mes
;WITH base AS (
    SELECT
        a.alquiler_id,
        c.customer_id,
        c.nombre_completo AS cliente,
        f.fecha,
        f.anio,
        f.mes
    FROM dbo.fact_alquiler AS a
    INNER JOIN dbo.dim_cliente AS c
        ON a.cliente_key = c.cliente_key
    INNER JOIN dbo.dim_fecha AS f
        ON a.fecha_key = f.fecha_key
),
historial AS (
    SELECT
        *,
        MIN(fecha) OVER (
            PARTITION BY customer_id
        ) AS primer_alquiler,
        LAG(fecha) OVER (
            PARTITION BY customer_id
            ORDER BY fecha, alquiler_id
        ) AS alquiler_anterior,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id, anio, mes
            ORDER BY fecha, alquiler_id
        ) AS orden_cliente_mes
    FROM base
)
SELECT *
INTO #historial_clientes
FROM historial;

-- 1. Intervalos y promedio de días por cliente
SELECT
    customer_id,
    cliente,
    COUNT(alquiler_anterior) AS intervalos,
    CAST(
        AVG(CAST(
            DATEDIFF(DAY, alquiler_anterior, fecha)
            AS DECIMAL(18,6)
        ))
        AS DECIMAL(10,2)
    ) AS dias_promedio
FROM #historial_clientes
GROUP BY customer_id, cliente
ORDER BY customer_id;

-- 2. Clientes nuevos y recurrentes por mes
SELECT
    anio,
    mes,
    SUM(CASE
        WHEN YEAR(primer_alquiler) = anio
         AND MONTH(primer_alquiler) = mes
        THEN 1 ELSE 0
    END) AS nuevos,
    SUM(CASE
        WHEN DATEFROMPARTS(
            YEAR(primer_alquiler),
            MONTH(primer_alquiler), 1
        ) < DATEFROMPARTS(anio, mes, 1)
        THEN 1 ELSE 0
    END) AS recurrentes
FROM #historial_clientes
WHERE orden_cliente_mes = 1
GROUP BY anio, mes
ORDER BY anio, mes;

DROP TABLE #historial_clientes;