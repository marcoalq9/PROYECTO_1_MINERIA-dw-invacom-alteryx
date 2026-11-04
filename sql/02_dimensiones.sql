/* ============================================================
   02_dimensiones.sql
   Crea las dimensiones y la tabla puente del DW.
   Jira: DWI-33 · Responsable: Marco Andrey López Quesada
   Campos: docs/modelo/03-dimensiones.md
   Llaves: docs/modelo/05-llaves-sustitutas.md
   Diagrama: docs/modelo/04-diagrama-dw.png

   Las llaves sustitutas (*_key) las genera Alteryx (Sort + Record ID),
   por eso no son IDENTITY. La llave de negocio de Pagila lleva UNIQUE
   para que una recarga no duplique registros.

   Ejecutar después de 01_crear_bd.sql. Si las tablas ya existen,
   se borran y se crean de nuevo (vacías).
   ============================================================ */

USE DW_Invacom;
GO

-- Primero se borran los hechos y la tabla puente, que dependen de las dimensiones
DROP TABLE IF EXISTS dbo.fact_alquiler;
DROP TABLE IF EXISTS dbo.fact_inventario;
DROP TABLE IF EXISTS dbo.bridge_pelicula_actor;
DROP TABLE IF EXISTS dbo.dim_fecha;
DROP TABLE IF EXISTS dbo.dim_cliente;
DROP TABLE IF EXISTS dbo.dim_pelicula;
DROP TABLE IF EXISTS dbo.dim_tienda;
DROP TABLE IF EXISTS dbo.dim_actor;
GO

/* ---------- dim_fecha: un registro por fecha del calendario ---------- */
CREATE TABLE dbo.dim_fecha (
    fecha_key   INT          NOT NULL,  -- AAAAMMDD, p. ej. 20050524
    fecha       DATE         NOT NULL,
    dia         TINYINT      NOT NULL,
    nombre_dia  NVARCHAR(10) NOT NULL,
    mes         TINYINT      NOT NULL,
    nombre_mes  NVARCHAR(10) NOT NULL,
    trimestre   TINYINT      NOT NULL,
    anio        SMALLINT     NOT NULL,
    CONSTRAINT PK_dim_fecha PRIMARY KEY (fecha_key),
    CONSTRAINT UQ_dim_fecha_fecha UNIQUE (fecha),
    CONSTRAINT CK_dim_fecha_key CHECK (fecha_key = YEAR(fecha) * 10000 + MONTH(fecha) * 100 + DAY(fecha)),
    CONSTRAINT CK_dim_fecha_dia CHECK (dia BETWEEN 1 AND 31),
    CONSTRAINT CK_dim_fecha_mes CHECK (mes BETWEEN 1 AND 12),
    CONSTRAINT CK_dim_fecha_trimestre CHECK (trimestre BETWEEN 1 AND 4)
);
GO

/* ---------- dim_cliente: un registro por cliente ---------- */
CREATE TABLE dbo.dim_cliente (
    cliente_key     INT           NOT NULL,
    customer_id     INT           NOT NULL,  -- llave de negocio (Pagila)
    nombre_completo NVARCHAR(100) NOT NULL,
    estado          BIT           NOT NULL,  -- customer.active: 1 activo, 0 inactivo (C08)
    ciudad          NVARCHAR(50)  NOT NULL,
    pais            NVARCHAR(50)  NOT NULL,
    ciudad_pais     NVARCHAR(110) NOT NULL,  -- distingue ciudades homónimas (C12)
    CONSTRAINT PK_dim_cliente PRIMARY KEY (cliente_key),
    CONSTRAINT UQ_dim_cliente_customer_id UNIQUE (customer_id)
);
GO

/* ---------- dim_pelicula: un registro por película ---------- */
CREATE TABLE dbo.dim_pelicula (
    pelicula_key             INT           NOT NULL,
    film_id                  INT           NOT NULL,  -- llave de negocio (Pagila)
    titulo                   NVARCHAR(255) NOT NULL,
    anio_estreno             SMALLINT      NULL,
    categoria                NVARCHAR(25)  NOT NULL,
    clasificacion            VARCHAR(5)    NULL,
    idioma                   NVARCHAR(20)  NOT NULL,  -- con Trim() (C11)
    duracion_min             SMALLINT      NULL,
    rango_duracion           NVARCHAR(20)  NULL,      -- intervalos por acordar antes del ETL
    tarifa_alquiler          DECIMAL(4,2)  NOT NULL,
    dias_alquiler_permitidos TINYINT       NOT NULL,
    costo_reemplazo          DECIMAL(5,2)  NOT NULL,
    CONSTRAINT PK_dim_pelicula PRIMARY KEY (pelicula_key),
    CONSTRAINT UQ_dim_pelicula_film_id UNIQUE (film_id),
    CONSTRAINT CK_dim_pelicula_clasificacion CHECK (clasificacion IN ('G', 'PG', 'PG-13', 'R', 'NC-17'))
);
GO

/* ---------- dim_tienda: un registro por tienda ---------- */
CREATE TABLE dbo.dim_tienda (
    tienda_key  INT           NOT NULL,
    store_id    INT           NOT NULL,  -- llave de negocio (Pagila)
    ciudad      NVARCHAR(50)  NOT NULL,
    pais        NVARCHAR(50)  NOT NULL,
    ciudad_pais NVARCHAR(110) NOT NULL,
    CONSTRAINT PK_dim_tienda PRIMARY KEY (tienda_key),
    CONSTRAINT UQ_dim_tienda_store_id UNIQUE (store_id)
);
GO

/* ---------- dim_actor: un registro por actor ---------- */
CREATE TABLE dbo.dim_actor (
    actor_key       INT           NOT NULL,
    actor_id        INT           NOT NULL,  -- llave de negocio; separa a los dos SUSAN DAVIS
    nombre_completo NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_dim_actor PRIMARY KEY (actor_key),
    CONSTRAINT UQ_dim_actor_actor_id UNIQUE (actor_id)
);
GO

/* ---------- bridge_pelicula_actor: relación muchos a muchos ---------- */
CREATE TABLE dbo.bridge_pelicula_actor (
    pelicula_key INT NOT NULL,
    actor_key    INT NOT NULL,
    CONSTRAINT PK_bridge_pelicula_actor PRIMARY KEY (pelicula_key, actor_key),
    CONSTRAINT FK_bridge_pelicula FOREIGN KEY (pelicula_key) REFERENCES dbo.dim_pelicula (pelicula_key),
    CONSTRAINT FK_bridge_actor    FOREIGN KEY (actor_key)    REFERENCES dbo.dim_actor (actor_key)
);
GO
