USE GD2C2022

------------------------------------------------
------- Creamos Schema GAME_OF_JOINS -----------
------------------------------------------------

IF NOT EXISTS (SELECT * 
               FROM   sys.schemas 
               WHERE  name = 'GAME_OF_JOINS') 
  BEGIN 
      EXEC ('CREATE SCHEMA [GAME_OF_JOINS] AUTHORIZATION dbo') 
  END 

GO

------------------------------------------------
-- SPs Auxiliares para la definicion de datos --
------------------------------------------------

IF Object_id('GAME_OF_JOINS.Erase_All_Foreign_Keys') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Erase_All_Foreign_Keys 

GO 

CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Erase_All_Foreign_Keys
AS 
    DECLARE @query nvarchar(255) 
    DECLARE query_cursor CURSOR FOR 
      SELECT 'ALTER TABLE ' 
             + object_schema_name(k.parent_object_id) 
             + '.[' + Object_name(k.parent_object_id) 
             + '] DROP CONSTRAINT ' + k.NAME query 
      FROM   sys.foreign_keys k 
    OPEN query_cursor 
    FETCH NEXT FROM query_cursor INTO @query 
    WHILE @@FETCH_STATUS = 0 
      BEGIN 
          EXEC sp_executesql 
            @query 
          FETCH NEXT FROM query_cursor INTO @query 
      END 
    CLOSE query_cursor 
    DEALLOCATE query_cursor 

GO 

IF Object_id('GAME_OF_JOINS.Drop_All_Tables') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Drop_All_Tables 

GO 

CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Drop_All_Tables
AS 
    DECLARE @query nvarchar(255) 
    DECLARE query_cursor CURSOR FOR  
    SELECT 'DROP TABLE GAME_OF_JOINS.' + name
               FROM   sys.tables 
               WHERE schema_id = (SELECT schema_id FROM sys.schemas WHERE name = 'GAME_OF_JOINS')
      OPEN query_cursor 
    FETCH NEXT FROM query_cursor INTO @query 
    WHILE @@FETCH_STATUS = 0 
      BEGIN 
          EXEC sp_executesql 
            @query 
          FETCH NEXT FROM query_cursor INTO @query 
      END 
    CLOSE query_cursor 
    DEALLOCATE query_cursor 

GO 

------------------------------------------------
------------ Drop de FKs y Tablas --------------
------------------------------------------------

EXEC GAME_OF_JOINS.Erase_All_Foreign_Keys
EXEC GAME_OF_JOINS.Drop_All_Tables

GO

------------------------------------------------
------------ Definicion de datos ---------------
------------------------------------------------

CREATE TABLE GAME_OF_JOINS.ventas 
  ( 
     venta_codigo DECIMAL(19,0) PRIMARY KEY, 
     venta_fecha    DATETIME2, 
     id_cliente INT, --fk
     venta_total     DECIMAL(18,2), 
     id_venta_medio_pago   INT,  --fk
  )  

CREATE TABLE GAME_OF_JOINS.ventas_medio_pago 
  ( 
     id       INT IDENTITY(1,1) PRIMARY KEY, 
     venta_medio_pago_costo     DECIMAL(18,2),
     id_medio_pago    INT, --fk
  ) 

CREATE TABLE GAME_OF_JOINS.medios_pago 
  ( 
     id     INT IDENTITY(1,1) PRIMARY KEY, 
     medio_pago_descuento DECIMAL(18,2), 
     medio_pago  nvarchar(255), 
  ) 


CREATE TABLE GAME_OF_JOINS.ventas_descuento 
  ( 
     id     INT IDENTITY(1,1) PRIMARY KEY, 
     venta_codigo  DECIMAL(19,0), --fk
     venta_descuento_importe   DECIMAL(18,2),
	 id_descuento   INT, --fk
  ) 

CREATE TABLE GAME_OF_JOINS.ventas_canales 
  ( 
     id     INT IDENTITY(1,1) PRIMARY KEY, 
     venta_codigo  DECIMAL(19,0), --fk
     id_canal  INT,  --fk
     venta_canal_costo DECIMAL(18,2), 

  ) 

CREATE TABLE GAME_OF_JOINS.ventas_cupones 
  ( 
     venta_codigo DECIMAL(19,0) NOT NULL, --fk
     venta_cupon_codigo     nvarchar(255) NOT NULL,   --fk
     venta_cupon_importe   DECIMAL(18,2),
  ) 

CREATE TABLE GAME_OF_JOINS.clientes 
  ( 
  	id INT IDENTITY(1,1) PRIMARY KEY,
     cliente_dni DECIMAL(18,0), 
     cliente_apellido nvarchar(255), 
     cliente_nombre         nvarchar(255), 
     cliente_direccion    nvarchar(255), 
     cliente_telefono       DECIMAL(18,0), 
     cliente_mail       nvarchar(255), 
     cliente_fecha_nac       DATETIME2, 
     cliente_codigo_postal       INT,  --fk
  ) 

CREATE TABLE GAME_OF_JOINS.cupones 
  ( 
     venta_cupon_codigo      nvarchar(255) PRIMARY KEY, 
     venta_cupon_fecha_desde         DATETIME2, 
     venta_cupon_fecha_hasta         DATETIME2, 
     venta_cupon_valor        DECIMAL(18,2), 
     id_tipo_cupon INT,  --fk
  ) 

CREATE TABLE GAME_OF_JOINS.canales
  ( 
     id      INT IDENTITY(1, 1) PRIMARY KEY, 
     canal nvarchar(255), 
  ) 

CREATE TABLE GAME_OF_JOINS.descuentos
  ( 
     id      INT IDENTITY(1,1) PRIMARY KEY, 
     venta_descuento_concepto nvarchar(255), 
     venta_descuento_valor    DECIMAL(18,2), 
  ) 
  
  CREATE TABLE GAME_OF_JOINS.tipos_cupones
  ( 
     id      INT IDENTITY(1,1) PRIMARY KEY, 
     tipo_cupon nvarchar(50), 
  ) 

CREATE TABLE GAME_OF_JOINS.variantes
  ( 
     id      INT IDENTITY(1,1) PRIMARY KEY, 
     variante nvarchar(50), 
     id_tipo_variante    INT, --fk
  ) 

CREATE TABLE GAME_OF_JOINS.tipos_variantes
  ( 
     id      INT IDENTITY(1,1) PRIMARY KEY, 
     tipo_variante    nvarchar(50), 
  ) 

CREATE TABLE GAME_OF_JOINS.ventas_envios
  ( 
     id      INT IDENTITY(1,1) PRIMARY KEY, 
     venta_codigo DECIMAL(19,0),  --fk
     venta_envio_precio    DECIMAL(18,2), 
     id_medio_habilitado      INT,  --fk
  ) 

CREATE TABLE GAME_OF_JOINS.medios_envios_habilitados
  ( 
     id      INT IDENTITY(1,1) PRIMARY KEY, 
     id_venta_medio_envio INT,  --fk
     codigo_postal    INT,  --fk
     venta_envio_precio_actual      DECIMAL(18,2), 
	 tiempo_estimado_envio		   DECIMAL(19,0)
  ) 

CREATE TABLE GAME_OF_JOINS.codigos_postales
  ( 
     id INT IDENTITY(1,1) PRIMARY KEY,
     codigo_postal      DECIMAL(18,0), 
     id_localidad INT,  --fk
  ) 

CREATE TABLE GAME_OF_JOINS.localidades
  ( 
     id      INT IDENTITY(1,1) PRIMARY KEY, 
     localidad nvarchar(255), 
     id_provincia    INT,  --fk
  ) 

CREATE TABLE GAME_OF_JOINS.provincias
  ( 
     id      INT IDENTITY(1,1) PRIMARY KEY, 
     provincia nvarchar(255), 
  ) 

CREATE TABLE GAME_OF_JOINS.ventas_medios_envios 
  ( 
   id INT IDENTITY(1,1) PRIMARY KEY,
	 venta_medio_envio nvarchar(255),
  ) 

CREATE TABLE GAME_OF_JOINS.productos_material 
  ( 
	 id INT IDENTITY(1,1) PRIMARY KEY,
     producto_material    nvarchar(50),  
  ) 

CREATE TABLE GAME_OF_JOINS.productos_marcas 
  ( 
	 id INT IDENTITY(1,1) PRIMARY KEY,
     producto_marca    nvarchar(255), 
  ) 

CREATE TABLE GAME_OF_JOINS.categorias_productos
  ( 
     id      INT IDENTITY(1,1) PRIMARY KEY, 
     producto_categoria nvarchar(255), 
  ) 

CREATE TABLE GAME_OF_JOINS.productos_ventas 
  ( 
	 id INT IDENTITY(1,1) PRIMARY KEY,
     producto_codigo    nvarchar(50),  --fk
	 venta_codigo   DECIMAL(19,0), --fk
     producto_variante_codigo    nvarchar(50),  --fk
     venta_producto_cantidad    DECIMAL(18,0), 
     venta_producto_precio    DECIMAL(18,2), 
     venta_producto_total    DECIMAL(18,2), 
  ) 

CREATE TABLE GAME_OF_JOINS.variantes_productos 
  ( 
	 producto_variante_codigo nvarchar(50) PRIMARY KEY,
     producto_codigo    nvarchar(50),  --fk
	 id_variante   INT, --fk
     precio_actual    DECIMAL(18,2),
     stock INT NOT NULL, 
  ) 

CREATE TABLE GAME_OF_JOINS.productos_compras
  ( 
	 id INT IDENTITY(1,1) PRIMARY KEY,
     producto_codigo    nvarchar(50),  --fk
	 compra_numero   DECIMAL(19,0), --fk
     producto_variante_codigo    nvarchar(50),  --fk
     compra_producto_cantidad    DECIMAL(18,2), 
     compra_producto_precio    DECIMAL(18,2), 
     compra_total    DECIMAL(18,2), 
  ) 

CREATE TABLE GAME_OF_JOINS.compras_descuentos 
  ( 
	 id INT IDENTITY(1,1) PRIMARY KEY,
     compra_numero    DECIMAL(19,0),  --fk
	 descuento_compra_valor   DECIMAL(18,2),
     descuento_compra_codigo    DECIMAL(19,0), 
  ) 

CREATE TABLE GAME_OF_JOINS.compras 
  ( 
	 compra_numero DECIMAL(19,0) PRIMARY KEY,
     compra_fecha    DATETIME2, 
	 proveedor_cuit   nvarchar(50), --fk
     id_compra_medio_pago   INT, --fk
     compra_total    DECIMAL(18,2), 
  ) 

CREATE TABLE GAME_OF_JOINS.compras_medio_pago 
  ( 
	 id INT IDENTITY(1,1) PRIMARY KEY,
     compra_medio_pago    nvarchar(255), 
  ) 

CREATE TABLE GAME_OF_JOINS.productos 
  ( 
	 producto_codigo nvarchar(50) PRIMARY KEY,
     producto_nombre    nvarchar(50), 
	 producto_descripcion   nvarchar(50),
     id_producto_categoria    INT,  --fk
     id_producto_marca    INT,  --fk
     id_producto_material    INT,  --fk
  ) 

CREATE TABLE GAME_OF_JOINS.proveedores 
  ( 
	 proveedor_cuit nvarchar(50) PRIMARY KEY,
     proveedor_razon_social   nvarchar(50), 
	 proveedor_domicilio   nvarchar(50),
     proveedor_mail    nvarchar(50), 
     proveedor_codigo_postal    INT,  --fk
  ) 

------------------------------------------------
------------- Definicion de FKs ----------------
------------------------------------------------

-- Regla para nombrar FKs: FK_tabla_origen_nombre_campo 

--ventas 
ALTER TABLE GAME_OF_JOINS.ventas 
  ADD CONSTRAINT fk_ventas_id_cliente FOREIGN KEY (id_cliente) REFERENCES GAME_OF_JOINS.clientes(id) 

ALTER TABLE GAME_OF_JOINS.ventas 
  ADD CONSTRAINT fk_ventas_id_venta_medio_pago FOREIGN KEY (id_venta_medio_pago) REFERENCES GAME_OF_JOINS.ventas_medio_pago(id) 

GO

--ventas_medio_pago 
ALTER TABLE GAME_OF_JOINS.ventas_medio_pago 
  ADD CONSTRAINT fk_ventas_medio_pago_id_medio_pago FOREIGN KEY (id_medio_pago) REFERENCES GAME_OF_JOINS.medios_pago(id)

GO

--ventas_descuento 
ALTER TABLE GAME_OF_JOINS.ventas_descuento 
  ADD CONSTRAINT fk_ventas_descuento_venta_codigo FOREIGN KEY (venta_codigo) REFERENCES GAME_OF_JOINS.ventas(venta_codigo)

ALTER TABLE GAME_OF_JOINS.ventas_descuento 
  ADD CONSTRAINT fk_ventas_descuento_id_descuento FOREIGN KEY (id_descuento) REFERENCES GAME_OF_JOINS.descuentos(id)

GO

--ventas_canales 
ALTER TABLE GAME_OF_JOINS.ventas_canales 
  ADD CONSTRAINT fk_venta_canales_venta_codigo FOREIGN KEY (venta_codigo) REFERENCES GAME_OF_JOINS.ventas(venta_codigo)

ALTER TABLE GAME_OF_JOINS.ventas_canales 
  ADD CONSTRAINT fk_venta_canales_id_canal FOREIGN KEY (id_canal) REFERENCES GAME_OF_JOINS.canales(id)

GO

--ventas_cupones 
ALTER TABLE GAME_OF_JOINS.ventas_cupones 
  ADD CONSTRAINT pk_ventas_cupones  PRIMARY KEY (venta_codigo, venta_cupon_codigo)

ALTER TABLE GAME_OF_JOINS.ventas_cupones 
  ADD CONSTRAINT fk_ventas_cupones_venta_codigo FOREIGN KEY (venta_codigo) REFERENCES GAME_OF_JOINS.ventas(venta_codigo)

ALTER TABLE GAME_OF_JOINS.ventas_cupones 
  ADD CONSTRAINT fk_ventas_cupones_venta_cupon_codigo FOREIGN KEY (venta_cupon_codigo) REFERENCES GAME_OF_JOINS.cupones(venta_cupon_codigo)

GO

--clientes 
ALTER TABLE GAME_OF_JOINS.clientes 
  ADD CONSTRAINT fk_clientes_cliente_codigo_postal FOREIGN KEY (cliente_codigo_postal) REFERENCES GAME_OF_JOINS.codigos_postales(id) 

GO

--cupones
ALTER TABLE GAME_OF_JOINS.cupones 
  ADD CONSTRAINT fk_cupones_id_tipo_cupon FOREIGN KEY (id_tipo_cupon) REFERENCES GAME_OF_JOINS.tipos_cupones(id)

GO

--ventas_envios
ALTER TABLE GAME_OF_JOINS.ventas_envios 
  ADD CONSTRAINT fk_ventas_envios_venta_codigo FOREIGN KEY (venta_codigo) REFERENCES GAME_OF_JOINS.ventas(venta_codigo) 

ALTER TABLE GAME_OF_JOINS.ventas_envios
  ADD CONSTRAINT fk_ventas_envios_id_medio_habilitado FOREIGN KEY (id_medio_habilitado) REFERENCES GAME_OF_JOINS.medios_envios_habilitados(id)

GO

--medios_envios_habilitados
ALTER TABLE GAME_OF_JOINS.medios_envios_habilitados 
  ADD CONSTRAINT fk_medios_envios_habilitados_id_venta_medio_envio FOREIGN KEY (id_venta_medio_envio) REFERENCES GAME_OF_JOINS.ventas_medios_envios(id)

ALTER TABLE GAME_OF_JOINS.medios_envios_habilitados
  ADD CONSTRAINT fk_medios_envios_habilitados_codigo_postal FOREIGN KEY (codigo_postal) REFERENCES GAME_OF_JOINS.codigos_postales(id)

GO

--codigos_postales
ALTER TABLE GAME_OF_JOINS.codigos_postales 
  ADD CONSTRAINT fk_codigos_postales_id_localidad FOREIGN KEY (id_localidad) REFERENCES GAME_OF_JOINS.localidades(id) 

GO

--localidades
ALTER TABLE GAME_OF_JOINS.localidades 
  ADD CONSTRAINT fk_localidades_id_provincia FOREIGN KEY (id_provincia) REFERENCES GAME_OF_JOINS.provincias(id) 

GO

--productos_ventas
ALTER TABLE GAME_OF_JOINS.productos_ventas 
  ADD CONSTRAINT fk_productos_ventas_producto_codigo FOREIGN KEY (producto_codigo) REFERENCES GAME_OF_JOINS.productos(producto_codigo) 

ALTER TABLE GAME_OF_JOINS.productos_ventas 
  ADD CONSTRAINT fk_productos_ventas_venta_codigo FOREIGN KEY (venta_codigo) REFERENCES GAME_OF_JOINS.ventas(venta_codigo) 

--ALTER TABLE GAME_OF_JOINS.productos_ventas 
--  ADD CONSTRAINT fk_productos_ventas_producto_variante_codigo FOREIGN KEY (producto_variante_codigo) REFERENCES GAME_OF_JOINS.variantes_productos(producto_variante_codigo) 

GO

--variantes_productos
ALTER TABLE GAME_OF_JOINS.variantes_productos 
  ADD CONSTRAINT fk_variantes_productos_producto_codigo FOREIGN KEY (producto_codigo) REFERENCES GAME_OF_JOINS.productos(producto_codigo) 

ALTER TABLE GAME_OF_JOINS.variantes_productos 
  ADD CONSTRAINT fk_variantes_productos_id_variante FOREIGN KEY (id_variante) REFERENCES GAME_OF_JOINS.variantes(id) 

GO

--variantes
ALTER TABLE GAME_OF_JOINS.variantes 
  ADD CONSTRAINT fk_variantes_id_tipo_variante FOREIGN KEY (id_tipo_variante) REFERENCES GAME_OF_JOINS.tipos_variantes(id) 

GO

--productos_compras
ALTER TABLE GAME_OF_JOINS.productos_compras 
  ADD CONSTRAINT fk_productos_compras_producto_codigo FOREIGN KEY (producto_codigo) REFERENCES GAME_OF_JOINS.productos(producto_codigo) 

ALTER TABLE GAME_OF_JOINS.productos_compras 
  ADD CONSTRAINT fk_productos_compras_compra_numero FOREIGN KEY (compra_numero) REFERENCES GAME_OF_JOINS.compras(compra_numero) 

--ALTER TABLE GAME_OF_JOINS.productos_compras 
--  ADD CONSTRAINT fk_productos_compras_producto_variante_codigo FOREIGN KEY (producto_variante_codigo) REFERENCES GAME_OF_JOINS.variantes_productos(producto_variante_codigo) 

GO

--compras_descuentos
ALTER TABLE GAME_OF_JOINS.compras_descuentos 
  ADD CONSTRAINT fk_compras_descuentos_compra_numero FOREIGN KEY (compra_numero) REFERENCES GAME_OF_JOINS.compras(compra_numero) 

GO

--compras
ALTER TABLE GAME_OF_JOINS.compras 
  ADD CONSTRAINT fk_compras_proveedor_cuit FOREIGN KEY (proveedor_cuit) REFERENCES GAME_OF_JOINS.proveedores(proveedor_cuit) 

ALTER TABLE GAME_OF_JOINS.compras 
  ADD CONSTRAINT fk_compras_id_compra_medio_pago FOREIGN KEY (id_compra_medio_pago) REFERENCES GAME_OF_JOINS.compras_medio_pago(id) 

GO

--productos
ALTER TABLE GAME_OF_JOINS.productos 
  ADD CONSTRAINT fk_productos_id_producto_categoria FOREIGN KEY (id_producto_categoria) REFERENCES GAME_OF_JOINS.categorias_productos(id) 

ALTER TABLE GAME_OF_JOINS.productos 
  ADD CONSTRAINT fk_productos_id_producto_marca FOREIGN KEY (id_producto_marca) REFERENCES GAME_OF_JOINS.productos_marcas(id) 

ALTER TABLE GAME_OF_JOINS.productos 
  ADD CONSTRAINT fk_productos_id_producto_material FOREIGN KEY (id_producto_material) REFERENCES GAME_OF_JOINS.productos_material(id) 

GO

--proveedores
ALTER TABLE GAME_OF_JOINS.proveedores 
  ADD CONSTRAINT fk_proveedores_proveedor_codigo_postal FOREIGN KEY (proveedor_codigo_postal) REFERENCES GAME_OF_JOINS.codigos_postales(id) 

GO

------------------------------------------------
-------- Procedures para migracion -------------
------------------------------------------------

--canales 
IF Object_id('GAME_OF_JOINS.Migrar_Canales') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Canales 

GO 

CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Canales 
AS 
    INSERT INTO GAME_OF_JOINS.canales 
                (canal) 
	SELECT
		DISTINCT VENTA_CANAL
	FROM
		gd_esquema.Maestra
	WHERE
		VENTA_CANAL IS NOT NULL

GO

--categorias_productos
IF Object_id('GAME_OF_JOINS.Migrar_Categorias_Productos') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Categorias_Productos 

GO 

CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Categorias_Productos 
AS 
    INSERT INTO GAME_OF_JOINS.categorias_productos 
                (producto_categoria)
	SELECT
		DISTINCT PRODUCTO_CATEGORIA
	FROM
		gd_esquema.maestra
	WHERE
		PRODUCTO_CATEGORIA IS NOT NULL

GO
--clientes
IF Object_id('GAME_OF_JOINS.Migrar_Clientes') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Clientes 

GO 

CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Clientes 
AS 
    INSERT INTO GAME_OF_JOINS.clientes 
                (cliente_dni,
                cliente_apellido,
                cliente_nombre,
                cliente_direccion,
                cliente_telefono,
                cliente_mail,
                cliente_fecha_nac,
                cliente_codigo_postal
                ) 
	SELECT
		DISTINCT m.CLIENTE_DNI,
		m.CLIENTE_APELLIDO,
		m.CLIENTE_NOMBRE,
		m.CLIENTE_DIRECCION,
		m.CLIENTE_TELEFONO,
		m.CLIENTE_MAIL,
		m.CLIENTE_FECHA_NAC,
		cp.id
	FROM
		gd_esquema.maestra m
	INNER JOIN GAME_OF_JOINS.provincias p ON
		p.provincia = m.CLIENTE_PROVINCIA
	INNER JOIN GAME_OF_JOINS.localidades l ON
		l.localidad = m.CLIENTE_LOCALIDAD
		AND l.id_provincia = p.id
	INNER JOIN GAME_OF_JOINS.codigos_postales cp ON
		cp.id_localidad = l.id
		AND cp.codigo_postal = m.CLIENTE_CODIGO_POSTAL
	WHERE
		m.CLIENTE_DNI IS NOT NULL

GO

--codigos_postales
IF Object_id('GAME_OF_JOINS.Migrar_Codigos_Postales') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Codigos_Postales 

GO 

CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Codigos_Postales 
AS 
    INSERT INTO GAME_OF_JOINS.codigos_postales 
                (codigo_postal,
                id_localidad
                )
    (
	SELECT
		DISTINCT m.CLIENTE_CODIGO_POSTAL,
		l.id
	FROM
		gd_esquema.maestra m
	INNER JOIN GAME_OF_JOINS.localidades l ON
		m.CLIENTE_LOCALIDAD = l.localidad
	WHERE
		m.CLIENTE_CODIGO_POSTAL IS NOT NULL
	UNION
	SELECT
		DISTINCT m.PROVEEDOR_CODIGO_POSTAL,
		l.id
	FROM
		gd_esquema.maestra m
	INNER JOIN GAME_OF_JOINS.localidades l ON
		m.PROVEEDOR_LOCALIDAD = l.localidad
	WHERE
		m.PROVEEDOR_CODIGO_POSTAL IS NOT NULL
	)

GO
--compras
IF Object_id('GAME_OF_JOINS.Migrar_Compras') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Compras 

GO 

CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Compras 
AS 
    INSERT INTO GAME_OF_JOINS.compras 
                (compra_numero, compra_fecha, proveedor_cuit, id_compra_medio_pago, compra_total) 
	SELECT
		DISTINCT m.COMPRA_NUMERO,
		m.COMPRA_FECHA,
		m.PROVEEDOR_CUIT,
		cmp.id,
		m.COMPRA_TOTAL
	FROM
		gd_esquema.maestra m
	INNER JOIN GAME_OF_JOINS.compras_medio_pago cmp ON
		cmp.compra_medio_pago = m.COMPRA_MEDIO_PAGO
	WHERE
		m.COMPRA_NUMERO IS NOT NULL

GO

--compras_descuentos
--compras_medio_pago
IF Object_id('GAME_OF_JOINS.Migrar_Compras_Medio_Pago') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Compras_Medio_Pago 

GO 

CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Compras_Medio_Pago 
AS 
    INSERT INTO GAME_OF_JOINS.compras_medio_pago 
                (compra_medio_pago) 
	SELECT
		DISTINCT COMPRA_MEDIO_PAGO
	FROM
		gd_esquema.Maestra
	WHERE
		COMPRA_MEDIO_PAGO IS NOT NULL

GO

--cupones
IF Object_id('GAME_OF_JOINS.Migrar_Cupones') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Cupones 
GO 

CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Cupones
AS 
    INSERT INTO GAME_OF_JOINS.cupones
                (venta_cupon_codigo, venta_cupon_fecha_desde, venta_cupon_fecha_hasta, venta_cupon_valor, id_tipo_cupon) 
	(	
		SELECT		DISTINCT 
					M.VENTA_CUPON_CODIGO,
					M.VENTA_CUPON_FECHA_DESDE,
					M.VENTA_CUPON_FECHA_HASTA,
					M.VENTA_CUPON_VALOR,
					TP.id
		FROM		gd_esquema.Maestra M
		INNER JOIN	GAME_OF_JOINS.tipos_cupones TP
		ON			M.VENTA_CUPON_TIPO = TP.tipo_cupon
	)

GO
--descuentos
IF Object_id('GAME_OF_JOINS.Migrar_Descuentos') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Descuentos 

GO 
CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Descuentos
AS 
    INSERT INTO GAME_OF_JOINS.descuentos
                (venta_descuento_concepto, venta_descuento_valor) 
	(
		SELECT
			DISTINCT VENTA_DESCUENTO_CONCEPTO,
			VENTA_DESCUENTO_IMPORTE
		FROM
			gd_esquema.Maestra
		WHERE
			VENTA_DESCUENTO_CONCEPTO IS NOT NULL
	)
GO
--localidades
IF Object_id('GAME_OF_JOINS.Migrar_Localidades') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Localidades 

GO 

CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Localidades 
AS 
    INSERT INTO GAME_OF_JOINS.localidades 
                (localidad,
                id_provincia
                )
	SELECT
		DISTINCT m.PROVEEDOR_LOCALIDAD,
		p.id
	FROM
		gd_esquema.maestra m
	INNER JOIN GAME_OF_JOINS.provincias p ON
		m.PROVEEDOR_PROVINCIA = p.provincia
	WHERE
		PROVEEDOR_LOCALIDAD IS NOT NULL
	UNION
	SELECT
		DISTINCT CLIENTE_LOCALIDAD,
		p.id
	FROM
		gd_esquema.maestra m
	INNER JOIN GAME_OF_JOINS.provincias p ON
		m.CLIENTE_PROVINCIA = p.provincia
	WHERE
		CLIENTE_LOCALIDAD IS NOT NULL

GO
--medios_envios_habilitados
--medios_pago
IF Object_id('GAME_OF_JOINS.Migrar_Medio_Pago') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Medio_Pago 

GO 
CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Medio_Pago
AS 
    INSERT INTO GAME_OF_JOINS.medios_pago
                (medio_pago_descuento, medio_pago) 
	SELECT
		DISTINCT 0,
		VENTA_MEDIO_PAGO
	FROM
		gd_esquema.Maestra
	WHERE
		VENTA_MEDIO_PAGO IS NOT NULL
GO

--productos
IF Object_id('GAME_OF_JOINS.Migrar_Productos') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Productos 

GO 
CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Productos
AS 
    INSERT INTO GAME_OF_JOINS.productos
                (producto_codigo, producto_nombre, producto_descripcion, id_producto_categoria, id_producto_marca, id_producto_material) 
	(
		SELECT
			DISTINCT M.PRODUCTO_CODIGO,
			M.PRODUCTO_NOMBRE,
			M.PRODUCTO_DESCRIPCION,
			CP.id,
			PMAR.id,
			PMAT.id
		FROM
			gd_esquema.Maestra M
		INNER JOIN GAME_OF_JOINS.categorias_productos CP ON
			M.PRODUCTO_CATEGORIA = CP.producto_categoria
		INNER JOIN GAME_OF_JOINS.productos_marcas PMAR ON
			M.PRODUCTO_MARCA = PMAR.producto_marca
		INNER JOIN GAME_OF_JOINS.productos_material PMAT ON
			M.PRODUCTO_MATERIAL = PMAT.producto_material
	)
GO

--productos_compras
IF Object_id('GAME_OF_JOINS.Migrar_Productos_Compras') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Productos_Compras 

GO 

CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Productos_Compras
AS 
    INSERT INTO GAME_OF_JOINS.productos_compras 
                (producto_codigo, compra_numero, producto_variante_codigo, compra_producto_cantidad, compra_producto_precio, compra_total)
	SELECT
		PRODUCTO_CODIGO,
		COMPRA_NUMERO,
		PRODUCTO_VARIANTE_CODIGO,
		COMPRA_PRODUCTO_CANTIDAD,
		COMPRA_PRODUCTO_PRECIO,
		COMPRA_PRODUCTO_CANTIDAD * COMPRA_PRODUCTO_PRECIO
	FROM
		gd_esquema.maestra
	WHERE
		COMPRA_NUMERO IS NOT NULL
		AND PRODUCTO_CODIGO IS NOT NULL

GO
--productos_marcas
IF Object_id('GAME_OF_JOINS.Migrar_Productos_Marcas') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Productos_Marcas 

GO 

CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Productos_Marcas 
AS 
    INSERT INTO GAME_OF_JOINS.productos_marcas 
                (producto_marca)
	SELECT
		DISTINCT PRODUCTO_MARCA
	FROM
		gd_esquema.maestra
	WHERE
		PRODUCTO_MARCA IS NOT NULL
	ORDER BY
		1 ASC

GO
--productos_material
IF Object_id('GAME_OF_JOINS.Migrar_Productos_Material') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Productos_Material 

GO 

CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Productos_Material 
AS 
    INSERT INTO GAME_OF_JOINS.productos_material 
                (producto_material)
	SELECT
		DISTINCT PRODUCTO_MATERIAL
	FROM
		gd_esquema.maestra
	WHERE
		PRODUCTO_MATERIAL IS NOT NULL

GO
--productos_ventas
IF Object_id('GAME_OF_JOINS.Migrar_Productos_Ventas') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Productos_Ventas 

GO 

CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Productos_Ventas 
AS 
    INSERT INTO GAME_OF_JOINS.productos_ventas 
                (venta_codigo,
                producto_codigo,
                producto_variante_codigo,
                venta_producto_cantidad,
                venta_producto_precio,
                venta_producto_total
                ) 
	SELECT
		VENTA_CODIGO,
		PRODUCTO_CODIGO,
		PRODUCTO_VARIANTE_CODIGO,
		VENTA_PRODUCTO_CANTIDAD,
		VENTA_PRODUCTO_PRECIO,
		VENTA_PRODUCTO_CANTIDAD * VENTA_PRODUCTO_PRECIO as vendido
	FROM
		gd_esquema.maestra
	WHERE
		VENTA_CODIGO IS NOT NULL
		AND PRODUCTO_CODIGO IS NOT NULL

GO

--proveedores
IF Object_id('GAME_OF_JOINS.Migrar_Proveedores') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Proveedores 

GO 

CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Proveedores 
AS 
    INSERT INTO GAME_OF_JOINS.proveedores 
                (proveedor_cuit,
                proveedor_razon_social,
                proveedor_domicilio,
                proveedor_mail,
                proveedor_codigo_postal
                ) 
	SELECT
		DISTINCT m.PROVEEDOR_CUIT,
		m.PROVEEDOR_RAZON_SOCIAL,
		m.PROVEEDOR_DOMICILIO,
		m.PROVEEDOR_MAIL,
		cp.id
	FROM
		gd_esquema.maestra m		
	INNER JOIN GAME_OF_JOINS.provincias p ON
		p.provincia = m.PROVEEDOR_PROVINCIA
	INNER JOIN GAME_OF_JOINS.localidades l ON
		l.localidad = m.PROVEEDOR_LOCALIDAD
		AND l.id_provincia = p.id
	INNER JOIN GAME_OF_JOINS.codigos_postales cp ON
		cp.id_localidad = l.id
		AND cp.codigo_postal = m.PROVEEDOR_CODIGO_POSTAL		
	WHERE
		m.PROVEEDOR_CUIT IS NOT NULL

GO
--provincias
IF Object_id('GAME_OF_JOINS.Migrar_Provincias') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Provincias 

GO 
CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Provincias
AS 
    INSERT INTO GAME_OF_JOINS.provincias
                (provincia) 
	SELECT
		DISTINCT PROVEEDOR_PROVINCIA
	FROM
		gd_esquema.Maestra
	WHERE
		PROVEEDOR_PROVINCIA IS NOT NULL
	UNION
	SELECT
		DISTINCT CLIENTE_PROVINCIA
	FROM
		gd_esquema.Maestra
	WHERE
		CLIENTE_PROVINCIA IS NOT NULL

GO

--tipos_cupones
IF Object_id('GAME_OF_JOINS.Migrar_Tipos_Cupones') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Tipos_Cupones 

GO 
CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Tipos_Cupones
AS 
    INSERT INTO GAME_OF_JOINS.tipos_cupones
                (tipo_cupon) 
	SELECT
		DISTINCT VENTA_CUPON_TIPO
	FROM
		gd_esquema.Maestra
	WHERE
		VENTA_CUPON_TIPO IS NOT NULL
GO
--tipos_variantes
IF Object_id('GAME_OF_JOINS.Migrar_Tipos_Variantes') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Tipos_Variantes 

GO 
CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Tipos_Variantes
AS 
    INSERT INTO GAME_OF_JOINS.tipos_variantes
                (tipo_variante) 
	SELECT
		DISTINCT PRODUCTO_TIPO_VARIANTE
	FROM
		gd_esquema.Maestra
	WHERE
		PRODUCTO_TIPO_VARIANTE IS NOT NULL
GO

EXEC GAME_OF_JOINS.Migrar_Tipos_Variantes

GO
--variantes
IF Object_id('GAME_OF_JOINS.Migrar_Variantes') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Variantes 

GO 
CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Variantes
AS 
    INSERT INTO GAME_OF_JOINS.variantes
                (variante, id_tipo_variante) 
	(
		SELECT
			DISTINCT M.PRODUCTO_VARIANTE,
			TV.id
		FROM
			gd_esquema.Maestra M
		INNER JOIN GAME_OF_JOINS.tipos_variantes TV ON
			M.PRODUCTO_TIPO_VARIANTE = TV.tipo_variante
	)
GO

--variantes_productos
IF Object_id('GAME_OF_JOINS.Migrar_Variantes_Productos') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Variantes_Productos 

GO 
CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Variantes_Productos
AS 
    INSERT INTO GAME_OF_JOINS.variantes_productos
                (producto_variante_codigo,
				producto_codigo, 
				id_variante,
				precio_actual,
				stock) 
	SELECT
		DISTINCT m.PRODUCTO_VARIANTE_CODIGO,
		m.PRODUCTO_CODIGO,
		v.id as id_variante,
		(
		SELECT
			CASE
				WHEN MAX(m1.VENTA_PRODUCTO_PRECIO) > MAX(m1.COMPRA_PRODUCTO_PRECIO) THEN MAX(m1.VENTA_PRODUCTO_PRECIO)
				ELSE MAX(m1.COMPRA_PRODUCTO_PRECIO)
			END AS precio_actual
		FROM
			gd_esquema.maestra m1
		WHERE
			m1.PRODUCTO_CODIGO = m.PRODUCTO_CODIGO
			AND m1.PRODUCTO_VARIANTE_CODIGO = m.PRODUCTO_VARIANTE_CODIGO ) precio_actual,
		( (
		select
			sum(COMPRA_PRODUCTO_CANTIDAD)
		FROM
			gd_esquema.maestra m2
		where
			PRODUCTO_CODIGO = m.PRODUCTO_CODIGO
			AND PRODUCTO_VARIANTE_CODIGO = m.PRODUCTO_VARIANTE_CODIGO
			AND COMPRA_NUMERO IS NOT NULL ) - (
		select
			sum(VENTA_PRODUCTO_CANTIDAD)
		FROM
			gd_esquema.maestra m3
		WHERE
			PRODUCTO_CODIGO = m.PRODUCTO_CODIGO
			AND PRODUCTO_VARIANTE_CODIGO = m.PRODUCTO_VARIANTE_CODIGO
			AND VENTA_CODIGO IS NOT NULL ) ) as stock
	FROM
		gd_esquema.maestra m
	INNER JOIN GAME_OF_JOINS.tipos_variantes tv ON
		tv.tipo_variante = m.PRODUCTO_TIPO_VARIANTE
	INNER JOIN GAME_OF_JOINS.variantes v ON
		v.id_tipo_variante = tv.id
		AND v.variante = m.PRODUCTO_VARIANTE
	WHERE
		m.PRODUCTO_CODIGO IS NOT NULL
		AND m.PRODUCTO_VARIANTE_CODIGO IS NOT NULL
GO

--ventas
IF Object_id('GAME_OF_JOINS.Migrar_Ventas') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Ventas

GO 
CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Ventas
AS 
    INSERT INTO GAME_OF_JOINS.ventas
                (venta_codigo, venta_fecha, id_cliente, id_venta_medio_pago, venta_total) 
	SELECT
		DISTINCT m.VENTA_CODIGO,
		m.VENTA_FECHA,
		cliente.id as id_cliente,
		vmp.id as id_venta_medio_pago,
		m.VENTA_TOTAL
	FROM
		gd_esquema.maestra m
	INNER JOIN GAME_OF_JOINS.clientes cliente ON
		cliente.cliente_dni = m.CLIENTE_DNI
		AND cliente.cliente_nombre = m.CLIENTE_NOMBRE
		AND cliente.cliente_apellido = m.CLIENTE_APELLIDO
	INNER JOIN GAME_OF_JOINS.medios_pago mp ON
		mp.medio_pago = m.VENTA_MEDIO_PAGO
	INNER JOIN GAME_OF_JOINS.ventas_medio_pago vmp ON
		vmp.id_medio_pago = mp.id

GO
	
--ventas_canales
IF Object_id('GAME_OF_JOINS.Migrar_Ventas_Canales') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Ventas_Canales 

GO 
CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Ventas_Canales
AS 
    INSERT INTO GAME_OF_JOINS.ventas_canales
                (venta_codigo, id_canal, venta_canal_costo) 
	SELECT
		DISTINCT m.VENTA_CODIGO,
		c.id,
		m.VENTA_CANAL_COSTO
	FROM
		gd_esquema.maestra m
	INNER JOIN GAME_OF_JOINS.canales c ON
		m.VENTA_CANAL = c.canal
	WHERE
		m.VENTA_CODIGO IS NOT NULL

GO

--ventas_cupones
IF Object_id('GAME_OF_JOINS.Migrar_Ventas_Cupones') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Ventas_Cupones 

GO 
CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Ventas_Cupones
AS 
    INSERT INTO GAME_OF_JOINS.ventas_cupones
                (venta_codigo, venta_cupon_codigo, venta_cupon_importe) 
	(
		SELECT
			DISTINCT M.VENTA_CODIGO,
			M.VENTA_CUPON_CODIGO,
			M.VENTA_CUPON_IMPORTE
		FROM
			gd_esquema.Maestra M
		INNER JOIN GAME_OF_JOINS.cupones C ON
			M.VENTA_CUPON_CODIGO = C.venta_cupon_codigo
		WHERE
			m.VENTA_CODIGO IS NOT NULL
	)

GO

--ventas_descuento
--ventas_envios
--ventas_medio_pago
IF Object_id('GAME_OF_JOINS.Migrar_Ventas_Medio_Pago') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Ventas_Medio_Pago 

GO 
CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Ventas_Medio_Pago
AS 
    INSERT INTO GAME_OF_JOINS.ventas_medio_pago
                (venta_medio_pago_costo, id_medio_pago) 
	(
		SELECT
			DISTINCT VENTA_MEDIO_PAGO_COSTO,
			MP.id
		FROM
			gd_esquema.Maestra M
		INNER JOIN GAME_OF_JOINS.medios_pago MP ON
			M.VENTA_MEDIO_PAGO = MP.medio_pago
	)

GO

--ventas_medios_envios
IF Object_id('GAME_OF_JOINS.Migrar_Ventas_Medios_Envios') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Ventas_Medios_Envios

GO 
CREATE OR ALTER PROCEDURE GAME_OF_JOINS.Migrar_Ventas_Medios_Envios
AS 
    INSERT INTO GAME_OF_JOINS.ventas_medios_envios
                (venta_medio_envio) 
	SELECT
		DISTINCT VENTA_MEDIO_ENVIO
	FROM
		gd_esquema.maestra
	WHERE
		VENTA_MEDIO_ENVIO IS NOT NULL
GO


------------------------------------------------
------------ Migracion de datos ----------------
------------------------------------------------

EXEC GAME_OF_JOINS.Migrar_Canales
EXEC GAME_OF_JOINS.Migrar_Medio_Pago
EXEC GAME_OF_JOINS.Migrar_Productos_Marcas
EXEC GAME_OF_JOINS.Migrar_Productos_Material
EXEC GAME_OF_JOINS.Migrar_Categorias_Productos
EXEC GAME_OF_JOINS.Migrar_Provincias
EXEC GAME_OF_JOINS.Migrar_Ventas_Medio_Pago
EXEC GAME_OF_JOINS.Migrar_Ventas_Medios_Envios
EXEC GAME_OF_JOINS.Migrar_Tipos_Cupones
EXEC GAME_OF_JOINS.Migrar_Cupones
EXEC GAME_OF_JOINS.Migrar_Localidades
EXEC GAME_OF_JOINS.Migrar_Codigos_Postales
EXEC GAME_OF_JOINS.Migrar_Descuentos
EXEC GAME_OF_JOINS.Migrar_Productos
EXEC GAME_OF_JOINS.Migrar_Clientes
EXEC GAME_OF_JOINS.Migrar_Ventas
EXEC GAME_OF_JOINS.Migrar_Ventas_Canales
EXEC GAME_OF_JOINS.Migrar_Ventas_Cupones 
EXEC GAME_OF_JOINS.Migrar_Variantes
EXEC GAME_OF_JOINS.Migrar_Proveedores
EXEC GAME_OF_JOINS.Migrar_Compras_Medio_Pago
EXEC GAME_OF_JOINS.Migrar_Compras
EXEC GAME_OF_JOINS.Migrar_Productos_Compras
EXEC GAME_OF_JOINS.Migrar_Productos_Ventas
EXEC GAME_OF_JOINS.Migrar_Variantes_Productos

GO

------------------------------------------------
----------- Drop de Procedures -----------------
------------------------------------------------

DROP PROCEDURE GAME_OF_JOINS.Migrar_Medio_Pago
DROP PROCEDURE GAME_OF_JOINS.Migrar_Productos_Marcas
DROP PROCEDURE GAME_OF_JOINS.Migrar_Productos_Material
DROP PROCEDURE GAME_OF_JOINS.Migrar_Categorias_Productos
DROP PROCEDURE GAME_OF_JOINS.Migrar_Provincias
DROP PROCEDURE GAME_OF_JOINS.Migrar_Ventas_Medio_Pago
DROP PROCEDURE GAME_OF_JOINS.Migrar_Ventas_Medios_Envios
DROP PROCEDURE GAME_OF_JOINS.Migrar_Tipos_Cupones
DROP PROCEDURE GAME_OF_JOINS.Migrar_Cupones
DROP PROCEDURE GAME_OF_JOINS.Migrar_Localidades
DROP PROCEDURE GAME_OF_JOINS.Migrar_Codigos_Postales
DROP PROCEDURE GAME_OF_JOINS.Migrar_Descuentos
DROP PROCEDURE GAME_OF_JOINS.Migrar_Productos
DROP PROCEDURE GAME_OF_JOINS.Migrar_Clientes
DROP PROCEDURE GAME_OF_JOINS.Migrar_Ventas
DROP PROCEDURE GAME_OF_JOINS.Migrar_Ventas_Canales
DROP PROCEDURE GAME_OF_JOINS.Migrar_Ventas_Cupones 
DROP PROCEDURE GAME_OF_JOINS.Migrar_Variantes
DROP PROCEDURE GAME_OF_JOINS.Migrar_Variantes_Productos
DROP PROCEDURE GAME_OF_JOINS.Migrar_Proveedores
DROP PROCEDURE GAME_OF_JOINS.Migrar_Compras_Medio_Pago
DROP PROCEDURE GAME_OF_JOINS.Migrar_Compras
DROP PROCEDURE GAME_OF_JOINS.Migrar_Productos_Compras
DROP PROCEDURE GAME_OF_JOINS.Migrar_Productos_Ventas
DROP PROCEDURE GAME_OF_JOINS.Erase_All_Foreign_Keys
DROP PROCEDURE GAME_OF_JOINS.Drop_All_Tables

GO