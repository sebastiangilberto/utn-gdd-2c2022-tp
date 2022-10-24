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

CREATE PROCEDURE GAME_OF_JOINS.Erase_All_Foreign_Keys
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

CREATE PROCEDURE GAME_OF_JOINS.Drop_All_Tables
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
     cliente_dni     DECIMAL(18,0), 
     id_canal_venta       INT, 
     venta_total     DECIMAL(18,2), 
     id_venta_medio_pago   INT, 
	 id_venta_medio_envio		   INT,
  )  

CREATE TABLE GAME_OF_JOINS.ventas_medio_pago 
  ( 
     id       INT PRIMARY KEY, 
     venta_medio_pago_costo     DECIMAL(18,2), 
     id_venta_medio_pago    nvarchar(255), 
  ) 

CREATE TABLE GAME_OF_JOINS.medios_pago 
  ( 
     id     INT PRIMARY KEY, 
     medio_pago_descuento DECIMAL(18,2), 
     medio_pago  nvarchar(255), 
  ) 


CREATE TABLE GAME_OF_JOINS.ventas_descuento 
  ( 
     id     INT PRIMARY KEY, 
     venta_codigo  DECIMAL(19,0), 
     venta_descuento_importe   DECIMAL(18,2),
	 id_descuento   INT,
  ) 

CREATE TABLE GAME_OF_JOINS.ventas_canales 
  ( 
     id     INT PRIMARY KEY, 
     venta_codigo  DECIMAL(19,0), 
     id_canal  INT, 
     venta_canal_costo DECIMAL(18,2), 

  ) 

CREATE TABLE GAME_OF_JOINS.ventas_cupones 
  ( 
     venta_codigo DECIMAL(19,0) PRIMARY KEY,
     venta_cupon_codigo     nvarchar(255), 
     venta_cupon_importe   DECIMAL(18,2), 
  ) 

CREATE TABLE GAME_OF_JOINS.clientes 
  ( 
     cliente_dni DECIMAL(18,0) PRIMARY KEY, 
     cliente_apellido nvarchar(255), 
     cliente_nombre         nvarchar(255), 
     cliente_direccion    nvarchar(255), 
     cliente_telefono       DECIMAL(18,0), 
     cliente_mail       nvarchar(255), 
     cliente_fecha_nac       DATETIME2, 
     cliente_codigo_postal       DECIMAL(18,0), 
  ) 

CREATE TABLE GAME_OF_JOINS.cupones 
  ( 
     venta_cupon_codigo      INT PRIMARY KEY, 
     venta_cupon_fecha_desde         DATETIME2, 
     venta_cupon_fecha_hasta         DATETIME2, 
     venta_cupon_valor        DECIMAL(18,2), 
     id_venta_cupon_tipo INT, 
  ) 

CREATE TABLE GAME_OF_JOINS.canales
  ( 
     id      INT PRIMARY KEY, 
     canal nvarchar(255), 
  ) 

CREATE TABLE GAME_OF_JOINS.descuentos
  ( 
     id      INT PRIMARY KEY, 
     venta_descuento_concepto DECIMAL(18,0), 
     venta_descuento_valor    DECIMAL(18,2), 
  ) 
  
  CREATE TABLE GAME_OF_JOINS.tipos_cupones
  ( 
     id      INT PRIMARY KEY, 
     venta_cupon_tipo nvarchar(50), 
  ) 

CREATE TABLE GAME_OF_JOINS.tipos_variantes_productos
  ( 
     id      INT PRIMARY KEY, 
     producto_variante nvarchar(50), 
     producto_tipo_variante    nvarchar(50), 
  ) 

CREATE TABLE GAME_OF_JOINS.ventas_envios
  ( 
     id      INT PRIMARY KEY, 
     venta_codigo DECIMAL(19,0), 
     venta_envio_precio    DECIMAL(18,2), 
     id_medio_habilitado      nvarchar(255), 
  ) 

CREATE TABLE GAME_OF_JOINS.medios_envios_habilitados
  ( 
     id      INT PRIMARY KEY, 
     venta_medio_envio DECIMAL(18,0), 
     codigo_postal    DECIMAL(18,2), 
     venta_envio_precio_actual      DECIMAL(18,2), 
	 tiempo_estimado_envio		   DECIMAL(19,0)
  ) 

CREATE TABLE GAME_OF_JOINS.codigos_postales
  ( 
     codigo_postal      DECIMAL(18,0) PRIMARY KEY, 
     id_localidad INT, 
  ) 

CREATE TABLE GAME_OF_JOINS.localidades
  ( 
     id      INT PRIMARY KEY, 
     localidad nvarchar(255), 
     id_provincia    INT, 
  ) 

CREATE TABLE GAME_OF_JOINS.provincias
  ( 
     id      INT PRIMARY KEY, 
     provincia nvarchar(255), 
  ) 

CREATE TABLE GAME_OF_JOINS.ventas_medios_envios 
  ( 
	 venta_medio_envio DECIMAL(18,0) PRIMARY KEY,
  ) 

CREATE TABLE GAME_OF_JOINS.productos_material 
  ( 
	 id INT PRIMARY KEY,
     producto_categoria    nvarchar(50),  
  ) 

CREATE TABLE GAME_OF_JOINS.productos_marcas 
  ( 
	 id INT PRIMARY KEY,
     producto_marca    nvarchar(255), 
  ) 

CREATE TABLE GAME_OF_JOINS.categorias_productos
  ( 
     id      INT PRIMARY KEY, 
     producto_categoria nvarchar(255), 
  ) 

CREATE TABLE GAME_OF_JOINS.productos_ventas 
  ( 
	 id INT PRIMARY KEY,
     producto_codigo    nvarchar(50), 
	 venta_codigo   DECIMAL(19,0),
     producto_variante_codigo    nvarchar(50), 
     venta_producto_cantidad    DECIMAL(18,0), 
     venta_producto_precio    DECIMAL(18,2), 
     venta_producto_total    DECIMAL(18,2), 
  ) 

CREATE TABLE GAME_OF_JOINS.variantes_productos 
  ( 
	 producto_variante_codigo nvarchar(50) PRIMARY KEY,
     producto_codigo    nvarchar(50), 
	 id_tipo_variante_producto   INT,
     variante_producto_precio    DECIMAL(18,2), 
  ) 

CREATE TABLE GAME_OF_JOINS.productos_compras
  ( 
	 id INT PRIMARY KEY,
     producto_codigo    nvarchar(50), 
	 compra_numero   DECIMAL(19,0),
     producto_variante_codigo    nvarchar(50), 
     compra_producto_cantidad    DECIMAL(18,2), 
     compra_producto_precio    DECIMAL(18,2), 
     compra_total    DECIMAL(18,2), 
  ) 

CREATE TABLE GAME_OF_JOINS.compras_descuentos 
  ( 
	 id INT PRIMARY KEY,
     compra_numero    DECIMAL(19,0), 
	 descuento_compra_valor   DECIMAL(18,2),
     descuento_compra_codigo    DECIMAL(19,0), 
  ) 

CREATE TABLE GAME_OF_JOINS.compras 
  ( 
	 compra_numero DECIMAL(19,0) PRIMARY KEY,
     compra_fecha    DATETIME2, 
	 proveedor_cuit   DECIMAL(19,0),
     id_compra_medio_pago   INT,
     compra_total    DECIMAL(18,2), 
  ) 

CREATE TABLE GAME_OF_JOINS.compras_medio_pago 
  ( 
	 id INT PRIMARY KEY,
     compra_medio_pago    nvarchar(255), 
  ) 

CREATE TABLE GAME_OF_JOINS.productos 
  ( 
	 producto_codigo nvarchar(50) PRIMARY KEY,
     producto_nombre    nvarchar(50), 
	 producto_descripcion   nvarchar(50),
     id_producto_categoria    INT, 
     id_producto_marca    INT, 
     id_producto_material    INT, 
  ) 

CREATE TABLE GAME_OF_JOINS.proveedores 
  ( 
	 proveedor_cuit nvarchar(50) PRIMARY KEY,
     proveedor_razon_social   nvarchar(50), 
	 proveedor_domicilio   nvarchar(50),
     proveedor_mail    nvarchar(50), 
     proveedor_codigo_postal    DECIMAL(18,0), 
  ) 
