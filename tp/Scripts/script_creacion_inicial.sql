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
     cliente_dni     DECIMAL(18,0), --fk
     id_canal_venta       INT,  --fk    
     venta_total     DECIMAL(18,2), 
     id_venta_medio_pago   INT,  --fk
	 id_venta_medio_envio		   INT, --fk
  )  

CREATE TABLE GAME_OF_JOINS.ventas_medio_pago 
  ( 
     id       INT PRIMARY KEY, 
     venta_medio_pago_costo     DECIMAL(18,2),
     id_medio_pago    INT, --fk
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
     venta_codigo  DECIMAL(19,0), --fk
     venta_descuento_importe   DECIMAL(18,2),
	 id_descuento   INT, --fk
  ) 

CREATE TABLE GAME_OF_JOINS.ventas_canales 
  ( 
     id     INT PRIMARY KEY, 
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
     cliente_dni DECIMAL(18,0) PRIMARY KEY, 
     cliente_apellido nvarchar(255), 
     cliente_nombre         nvarchar(255), 
     cliente_direccion    nvarchar(255), 
     cliente_telefono       DECIMAL(18,0), 
     cliente_mail       nvarchar(255), 
     cliente_fecha_nac       DATETIME2, 
     cliente_codigo_postal       DECIMAL(18,0),  --fk
  ) 

CREATE TABLE GAME_OF_JOINS.cupones 
  ( 
     venta_cupon_codigo      nvarchar(255) PRIMARY KEY, 
     venta_cupon_fecha_desde         DATETIME2, 
     venta_cupon_fecha_hasta         DATETIME2, 
     venta_cupon_valor        DECIMAL(18,2), 
     id_venta_cupon_tipo INT,  --fk
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
     venta_codigo DECIMAL(19,0),  --fk
     venta_envio_precio    DECIMAL(18,2), 
     id_medio_habilitado      INT,  --fk
  ) 

CREATE TABLE GAME_OF_JOINS.medios_envios_habilitados
  ( 
     id      INT PRIMARY KEY, 
     venta_medio_envio DECIMAL(18,0),  --fk
     codigo_postal    DECIMAL(18,0),  --fk
     venta_envio_precio_actual      DECIMAL(18,2), 
	 tiempo_estimado_envio		   DECIMAL(19,0)
  ) 

CREATE TABLE GAME_OF_JOINS.codigos_postales
  ( 
     codigo_postal      DECIMAL(18,0) PRIMARY KEY, 
     id_localidad INT,  --fk
  ) 

CREATE TABLE GAME_OF_JOINS.localidades
  ( 
     id      INT PRIMARY KEY, 
     localidad nvarchar(255), 
     id_provincia    INT,  --fk
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
	 id_tipo_variante_producto   INT, --fk
     variante_producto_precio    DECIMAL(18,2), 
  ) 

CREATE TABLE GAME_OF_JOINS.productos_compras
  ( 
	 id INT PRIMARY KEY,
     producto_codigo    nvarchar(50),  --fk
	 compra_numero   DECIMAL(19,0), --fk
     producto_variante_codigo    nvarchar(50),  --fk
     compra_producto_cantidad    DECIMAL(18,2), 
     compra_producto_precio    DECIMAL(18,2), 
     compra_total    DECIMAL(18,2), 
  ) 

CREATE TABLE GAME_OF_JOINS.compras_descuentos 
  ( 
	 id INT PRIMARY KEY,
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
	 id INT PRIMARY KEY,
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
     proveedor_codigo_postal    DECIMAL(18,0),  --fk
  ) 

-- Regla para nombrar FKs: FK_tabla_origen_nombre_campo 

--ventas 
ALTER TABLE GAME_OF_JOINS.ventas 
  ADD CONSTRAINT fk_ventas_cliente_dni FOREIGN KEY (cliente_dni) REFERENCES GAME_OF_JOINS.clientes(cliente_dni) 

ALTER TABLE GAME_OF_JOINS.ventas 
  ADD CONSTRAINT fk_ventas_id_canal_venta FOREIGN KEY (id_canal_venta) REFERENCES GAME_OF_JOINS.ventas_canales(id) 

ALTER TABLE GAME_OF_JOINS.ventas 
  ADD CONSTRAINT fk_ventas_id_venta_medio_pago FOREIGN KEY (id_venta_medio_pago) REFERENCES GAME_OF_JOINS.ventas_medio_pago(id) 

ALTER TABLE GAME_OF_JOINS.ventas 
  ADD CONSTRAINT fk_ventas_id_venta_medio_envio FOREIGN KEY (id_venta_medio_envio) REFERENCES GAME_OF_JOINS.ventas_envios(id) 

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
  ADD CONSTRAINT fk_clientes_cliente_codigo_postal FOREIGN KEY (cliente_codigo_postal) REFERENCES GAME_OF_JOINS.codigos_postales(codigo_postal) 

GO

--cupones
ALTER TABLE GAME_OF_JOINS.cupones 
  ADD CONSTRAINT fk_cupones_id_venta_cupon_tipo FOREIGN KEY (id_venta_cupon_tipo) REFERENCES GAME_OF_JOINS.tipos_cupones(id)

GO

--ventas_envios
ALTER TABLE GAME_OF_JOINS.ventas_envios 
  ADD CONSTRAINT fk_ventas_envios_venta_codigo FOREIGN KEY (venta_codigo) REFERENCES GAME_OF_JOINS.ventas(venta_codigo) 

ALTER TABLE GAME_OF_JOINS.ventas_envios
  ADD CONSTRAINT fk_ventas_envios_id_medio_habilitado FOREIGN KEY (id_medio_habilitado) REFERENCES GAME_OF_JOINS.medios_envios_habilitados(id)

GO

--medios_envios_habilitados
ALTER TABLE GAME_OF_JOINS.medios_envios_habilitados 
  ADD CONSTRAINT fk_medios_envios_habilitados_venta_medio_envio FOREIGN KEY (venta_medio_envio) REFERENCES GAME_OF_JOINS.ventas_medios_envios(venta_medio_envio)

ALTER TABLE GAME_OF_JOINS.medios_envios_habilitados
  ADD CONSTRAINT fk_medios_envios_habilitados_codigo_postal FOREIGN KEY (codigo_postal) REFERENCES GAME_OF_JOINS.codigos_postales(codigo_postal)

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

ALTER TABLE GAME_OF_JOINS.productos_ventas 
  ADD CONSTRAINT fk_productos_ventas_producto_variante_codigo FOREIGN KEY (producto_variante_codigo) REFERENCES GAME_OF_JOINS.variantes_productos(producto_variante_codigo) 

GO

--variantes_productos
ALTER TABLE GAME_OF_JOINS.variantes_productos 
  ADD CONSTRAINT fk_variantes_productos_producto_codigo FOREIGN KEY (producto_codigo) REFERENCES GAME_OF_JOINS.productos(producto_codigo) 

ALTER TABLE GAME_OF_JOINS.variantes_productos 
  ADD CONSTRAINT fk_variantes_productos_id_tipo_variante_producto FOREIGN KEY (id_tipo_variante_producto) REFERENCES GAME_OF_JOINS.tipos_variantes_productos(id) 

GO

--productos_compras
ALTER TABLE GAME_OF_JOINS.productos_compras 
  ADD CONSTRAINT fk_productos_compras_producto_codigo FOREIGN KEY (producto_codigo) REFERENCES GAME_OF_JOINS.productos(producto_codigo) 

ALTER TABLE GAME_OF_JOINS.productos_compras 
  ADD CONSTRAINT fk_productos_compras_compra_numero FOREIGN KEY (compra_numero) REFERENCES GAME_OF_JOINS.compras(compra_numero) 

ALTER TABLE GAME_OF_JOINS.productos_compras 
  ADD CONSTRAINT fk_productos_compras_producto_variante_codigo FOREIGN KEY (producto_variante_codigo) REFERENCES GAME_OF_JOINS.variantes_productos(producto_variante_codigo) 

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
  ADD CONSTRAINT fk_proveedores_proveedor_codigo_postal FOREIGN KEY (proveedor_codigo_postal) REFERENCES GAME_OF_JOINS.codigos_postales(codigo_postal) 

GO
