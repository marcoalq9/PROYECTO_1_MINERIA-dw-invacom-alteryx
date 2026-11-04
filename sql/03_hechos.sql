/* ============================================================
   03_hechos.sql
   Crea las tablas de hechos y sus llaves foráneas.
   Jira: DWI-33 · Responsable: Marco Andrey López Quesada
   Campos: docs/modelo/02-tablas-de-hechos.md
   Diagrama: docs/modelo/04-diagrama-dw.png

   Los indicadores (devuelto, devolucion_tardia, pago_cero) son TINYINT
   con valores 0/1, no BIT, para que se puedan sumar en SQL y en las
   tablas dinámicas de Excel: SUM(devolucion_tardia) / SUM(devuelto).

   Ejecutar después de 02_dimensiones.sql.
   ============================================================ */

USE DW_Invacom;
GO

DROP TABLE IF EXISTS dbo.fact_alquiler;
DROP TABLE IF EXISTS dbo.fact_inventario;
GO

/* ---------- fact_inventario: una fila por copia física (4 581) ---------- */
CREATE TABLE dbo.fact_inventario (
    inventario_id   INT     NOT NULL,  -- inventory_id
    pelicula_key    INT     NOT NULL,
    tienda_key      INT     NOT NULL,  -- tienda dueña de la copia
    cantidad_copias TINYINT NOT NULL CONSTRAINT DF_fact_inventario_cantidad DEFAULT (1),
    CONSTRAINT PK_fact_inventario PRIMARY KEY (inventario_id),
    CONSTRAINT FK_fact_inventario_pelicula FOREIGN KEY (pelicula_key) REFERENCES dbo.dim_pelicula (pelicula_key),
    CONSTRAINT FK_fact_inventario_tienda   FOREIGN KEY (tienda_key)   REFERENCES dbo.dim_tienda (tienda_key),
    CONSTRAINT CK_fact_inventario_cantidad CHECK (cantidad_copias = 1)
);
GO

/* ---------- fact_alquiler: una fila por alquiler válido (16 044, sin C01) ---------- */
CREATE TABLE dbo.fact_alquiler (
    alquiler_id       INT           NOT NULL,  -- rental_id
    inventario_id     INT           NOT NULL,  -- inventory_id, para las copias sin rotación
    fecha_key         INT           NOT NULL,  -- fecha del alquiler (rental_date)
    cliente_key       INT           NOT NULL,
    pelicula_key      INT           NOT NULL,
    tienda_key        INT           NOT NULL,  -- inventory.store_id
    cantidad          TINYINT       NOT NULL CONSTRAINT DF_fact_alquiler_cantidad DEFAULT (1),
    monto             DECIMAL(10,2) NOT NULL CONSTRAINT DF_fact_alquiler_monto DEFAULT (0),  -- pagos válidos (sin C02 ni C03)
    cantidad_pagos    INT           NOT NULL CONSTRAINT DF_fact_alquiler_pagos DEFAULT (0),
    dias_alquilado    DECIMAL(9,4)  NULL,      -- NULL si no se devolvió (C06)
    dias_atraso       DECIMAL(9,4)  NULL,      -- 0 si se devolvió a tiempo; NULL si no se devolvió
    devuelto          TINYINT       NOT NULL,
    devolucion_tardia TINYINT       NULL,      -- NULL si no se devolvió o plazo inválido (C23)
    pago_cero         TINYINT       NOT NULL,  -- 1 si el monto total es 0 (C04)
    CONSTRAINT PK_fact_alquiler PRIMARY KEY (alquiler_id),
    CONSTRAINT FK_fact_alquiler_fecha    FOREIGN KEY (fecha_key)    REFERENCES dbo.dim_fecha (fecha_key),
    CONSTRAINT FK_fact_alquiler_cliente  FOREIGN KEY (cliente_key)  REFERENCES dbo.dim_cliente (cliente_key),
    CONSTRAINT FK_fact_alquiler_pelicula FOREIGN KEY (pelicula_key) REFERENCES dbo.dim_pelicula (pelicula_key),
    CONSTRAINT FK_fact_alquiler_tienda   FOREIGN KEY (tienda_key)   REFERENCES dbo.dim_tienda (tienda_key),
    CONSTRAINT CK_fact_alquiler_cantidad CHECK (cantidad = 1),
    CONSTRAINT CK_fact_alquiler_monto    CHECK (monto >= 0),
    CONSTRAINT CK_fact_alquiler_pagos    CHECK (cantidad_pagos >= 0),
    CONSTRAINT CK_fact_alquiler_atraso   CHECK (dias_atraso >= 0),
    CONSTRAINT CK_fact_alquiler_devuelto CHECK (devuelto IN (0, 1)),
    CONSTRAINT CK_fact_alquiler_tardia   CHECK (devolucion_tardia IN (0, 1)),
    CONSTRAINT CK_fact_alquiler_cero     CHECK (pago_cero IN (0, 1)),
    -- Un alquiler sin devolver no puede tener días ni marcarse como tardío
    CONSTRAINT CK_fact_alquiler_sin_dev  CHECK (devuelto = 1 OR (dias_alquilado IS NULL AND dias_atraso IS NULL AND devolucion_tardia IS NULL))
);
GO

-- Índices para las uniones con las dimensiones y para la rotación del inventario
CREATE INDEX IX_fact_alquiler_fecha      ON dbo.fact_alquiler (fecha_key);
CREATE INDEX IX_fact_alquiler_cliente    ON dbo.fact_alquiler (cliente_key);
CREATE INDEX IX_fact_alquiler_pelicula   ON dbo.fact_alquiler (pelicula_key);
CREATE INDEX IX_fact_alquiler_tienda     ON dbo.fact_alquiler (tienda_key);
CREATE INDEX IX_fact_alquiler_inventario ON dbo.fact_alquiler (inventario_id);
CREATE INDEX IX_fact_inventario_pelicula ON dbo.fact_inventario (pelicula_key);
CREATE INDEX IX_fact_inventario_tienda   ON dbo.fact_inventario (tienda_key);
GO

-- Comprobación: deben aparecer las 8 tablas
SELECT name AS tabla FROM sys.tables ORDER BY name;
GO
