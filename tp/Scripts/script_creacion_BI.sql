USE GD2C2022

------------------------------------------------
------- Creamos Schema GAME_OF_JOINS -----------
------------------------------------------------

SET ANSI_WARNINGS OFF
GO

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

IF Object_id('GAME_OF_JOINS.BI_Erase_All_Foreign_Keys') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Erase_All_Foreign_Keys 

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Erase_All_Foreign_Keys
AS 
    DECLARE @query nvarchar(255) 
    DECLARE query_cursor CURSOR FOR 
      SELECT 'ALTER TABLE ' 
             + object_schema_name(k.parent_object_id) 
             + '.[' + Object_name(k.parent_object_id) 
             + '] DROP CONSTRAINT ' + k.NAME query 
      FROM   sys.foreign_keys k 
	  WHERE  Object_name(k.parent_object_id) LIKE 'BI_%' 
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

IF Object_id('GAME_OF_JOINS.BI_Drop_All_Tables') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Drop_All_Tables 

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Drop_All_Tables
AS 
    DECLARE @query nvarchar(255) 
    DECLARE query_cursor CURSOR FOR  
    SELECT 'DROP TABLE GAME_OF_JOINS.' + name
               FROM  sys.tables 
               WHERE schema_id = (SELECT schema_id FROM sys.schemas WHERE name = 'GAME_OF_JOINS')
			   AND NAME LIKE 'BI_%' 
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

IF Object_id('GAME_OF_JOINS.BI_Drop_All_Procedures') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Drop_All_Procedures

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Drop_All_Procedures
AS 
    DECLARE @query nvarchar(255) 
    DECLARE query_cursor CURSOR FOR  
    SELECT 'DROP PROCEDURE GAME_OF_JOINS.' + name
               FROM  sys.procedures 
               WHERE schema_id = (SELECT schema_id FROM sys.schemas WHERE name = 'GAME_OF_JOINS') AND name LIKE 'BI_Migrar_%'
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

EXEC GAME_OF_JOINS.BI_Erase_All_Foreign_Keys
EXEC GAME_OF_JOINS.BI_Drop_All_Tables
EXEC GAME_OF_JOINS.BI_Drop_All_Procedures

GO

------------------------------------------------
----------- Tablas de dimensiones --------------
------------------------------------------------

/*
 * Se deberán considerar como mínimo, las siguientes dimensiones además de las
 * que el alumno considere convenientes:
 * - Tiempo (año, mes)
 * - Provincia
 * - Rango etario cliente
 * 	- <25
 * 	- 25 - 35
 * 	- 35 – 55
 * 	- >55
 * - Canal de venta
 * - Medio de pago
 * - Categoría de producto
 * - Producto
 * - Tipo de descuento
 * - Tipo de envío 
 */

--canal
CREATE TABLE GAME_OF_JOINS.BI_canal
  (
	 id_canal INT PRIMARY KEY IDENTITY(1, 1), 
     descripcion NVARCHAR(255) NOT NULL,
  )

--categoria_producto  
CREATE TABLE GAME_OF_JOINS.BI_categoria_producto
  (
	 id_categoria INT PRIMARY KEY IDENTITY(1, 1), 
     descripcion NVARCHAR(255) NOT NULL,
  )

--cliente  
CREATE TABLE GAME_OF_JOINS.BI_cliente 
  ( 
     id_cliente INT PRIMARY KEY IDENTITY(1, 1), 
     rango_etario NVARCHAR(255) NOT NULL,
  ) 

--producto
CREATE TABLE GAME_OF_JOINS.BI_producto
  (
	 id_producto INT PRIMARY KEY IDENTITY(1, 1),
	 codigo NVARCHAR(50) NOT NULL,
     descripcion NVARCHAR(50) NOT NULL,
  )

--proveedor
CREATE TABLE GAME_OF_JOINS.BI_proveedor 
  ( 
  	 id_proveedor INT PRIMARY KEY IDENTITY(1, 1),
  	 cuit NVARCHAR(50) NOT NULL,
  ) 

--provincia
CREATE TABLE GAME_OF_JOINS.BI_provincia
  (
	 id_provincia INT PRIMARY KEY IDENTITY(1, 1), 
     descripcion NVARCHAR(255) NOT NULL,
  )

--tiempo
CREATE TABLE GAME_OF_JOINS.BI_tiempo 
  ( 
	 id_tiempo INT PRIMARY KEY IDENTITY(1, 1), 
     anio INT NOT NULL,
	 mes  INT NOT NULL,
  )

--tipo_descuento
CREATE TABLE GAME_OF_JOINS.BI_tipo_descuento
  (
	 id_tipo_descuento INT PRIMARY KEY IDENTITY(1, 1), 
     descripcion NVARCHAR(255) NOT NULL,
  )

--tipo_envio
CREATE TABLE GAME_OF_JOINS.BI_tipo_envio
  (
	 id_tipo_envio INT PRIMARY KEY IDENTITY(1, 1), 
     descripcion NVARCHAR(255) NOT NULL,
  )

--tipo_medio_pago
CREATE TABLE GAME_OF_JOINS.BI_tipo_medio_pago
  (
	 id_tipo_medio_pago INT PRIMARY KEY IDENTITY(1, 1), 
     descripcion NVARCHAR(255) NOT NULL,
  )

------------------------------------------------
------------- Tablas de Hechos -----------------
------------------------------------------------

--hechos_compra
CREATE TABLE GAME_OF_JOINS.BI_hechos_compra
  (
	id_hechos_compra INT PRIMARY KEY IDENTITY(1, 1),
	id_producto INT NOT NULL, --fk
	id_proveedor INT NOT NULL, --fk
	id_tiempo INT NOT NULL, --fk
	cantidad DECIMAL(18,0) NOT NULL,
	precio_unitario DECIMAL(18,2) NOT NULL,
  ) 

--hechos_descuento
CREATE TABLE GAME_OF_JOINS.BI_hechos_descuento
  (
	id_hechos_descuento INT PRIMARY KEY IDENTITY(1, 1),
	id_canal INT NOT NULL, --fk
	id_tiempo INT NOT NULL, --fk
	id_tipo_descuento INT NOT NULL, --fk
	valor_total DECIMAL(18,2) NOT NULL,
  ) 

--hechos_envio
CREATE TABLE GAME_OF_JOINS.BI_hechos_envio
  (
	id_hechos_envio INT PRIMARY KEY IDENTITY(1, 1),
	id_provincia INT NOT NULL, --fk
	id_tiempo INT NOT NULL, --fk
	id_tipo_envio INT NOT NULL, --fk
	cantidad_envios INT NOT NULL,
	costo_envio DECIMAL(18,2) NOT NULL,
  ) 

--hechos_medio_pago
CREATE TABLE GAME_OF_JOINS.BI_hechos_medio_pago
  (
	id_hechos_medio_pago INT PRIMARY KEY IDENTITY(1, 1),
	id_tipo_medio_pago INT NOT NULL, --fk
	id_canal INT NOT NULL, --fk
	id_tiempo INT NOT NULL, --fk
	costo_transaccion DECIMAL(18,2) NOT NULL,
  ) 

--hechos_venta
CREATE TABLE GAME_OF_JOINS.BI_hechos_venta
  (
	id_hechos_venta INT PRIMARY KEY IDENTITY(1, 1),
	id_tiempo INT NOT NULL, --fk
	id_cliente INT NOT NULL, --fk
	id_canal INT NOT NULL, --fk
	id_categoria INT NOT NULL, --fk
	id_producto INT NOT NULL, --fk
	cantidad DECIMAL(18,0) NOT NULL,
	precio_unitario DECIMAL(18,2) NOT NULL,
  )
  
------------------------------------------------
------------- Definicion de FKs ----------------
------------------------------------------------

-- Regla para nombrar FKs: FK_BI_tabla_origen_nombre_campo 

  
--hechos_compra
ALTER TABLE GAME_OF_JOINS.BI_hechos_compra 
  ADD CONSTRAINT fk_BI_hechos_compra_id_producto FOREIGN KEY (id_producto) REFERENCES GAME_OF_JOINS.BI_producto(id_producto) 

ALTER TABLE GAME_OF_JOINS.BI_hechos_compra 
  ADD CONSTRAINT fk_BI_hechos_compra_id_proveedor FOREIGN KEY (id_proveedor) REFERENCES GAME_OF_JOINS.BI_proveedor(id_proveedor) 

ALTER TABLE GAME_OF_JOINS.BI_hechos_compra 
  ADD CONSTRAINT fk_BI_hechos_compra_id_tiempo FOREIGN KEY (id_tiempo) REFERENCES GAME_OF_JOINS.BI_tiempo(id_tiempo) 

GO
  
--hechos_descuento
ALTER TABLE GAME_OF_JOINS.BI_hechos_descuento
  ADD CONSTRAINT fk_BI_hechos_descuento_id_canal FOREIGN KEY (id_canal) REFERENCES GAME_OF_JOINS.BI_canal(id_canal) 

ALTER TABLE GAME_OF_JOINS.BI_hechos_descuento
  ADD CONSTRAINT fk_BI_hechos_descuento_id_tiempo FOREIGN KEY (id_tiempo) REFERENCES GAME_OF_JOINS.BI_tiempo(id_tiempo) 

ALTER TABLE GAME_OF_JOINS.BI_hechos_descuento
  ADD CONSTRAINT fk_BI_hechos_descuento_id_tipo_descuento FOREIGN KEY (id_tipo_descuento) REFERENCES GAME_OF_JOINS.BI_tipo_descuento(id_tipo_descuento) 

GO

--hechos_envio
ALTER TABLE GAME_OF_JOINS.BI_hechos_envio
  ADD CONSTRAINT fk_BI_hechos_envio_id_provincia FOREIGN KEY (id_provincia) REFERENCES GAME_OF_JOINS.BI_provincia(id_provincia) 

ALTER TABLE GAME_OF_JOINS.BI_hechos_envio
  ADD CONSTRAINT fk_BI_hechos_envio_id_tiempo FOREIGN KEY (id_tiempo) REFERENCES GAME_OF_JOINS.BI_tiempo(id_tiempo) 

ALTER TABLE GAME_OF_JOINS.BI_hechos_envio
  ADD CONSTRAINT fk_BI_hechos_envio_id_tipo_envio FOREIGN KEY (id_tipo_envio) REFERENCES GAME_OF_JOINS.BI_tipo_envio(id_tipo_envio) 

GO

--hechos_medio_pago
ALTER TABLE GAME_OF_JOINS.BI_hechos_medio_pago
  ADD CONSTRAINT fk_BI_hechos_medio_pago_id_tipo_medio_pago FOREIGN KEY (id_tipo_medio_pago) REFERENCES GAME_OF_JOINS.BI_tipo_medio_pago(id_tipo_medio_pago) 

ALTER TABLE GAME_OF_JOINS.BI_hechos_medio_pago
  ADD CONSTRAINT fk_BI_hechos_medio_pago_id_tiempo FOREIGN KEY (id_tiempo) REFERENCES GAME_OF_JOINS.BI_tiempo(id_tiempo) 

ALTER TABLE GAME_OF_JOINS.BI_hechos_medio_pago
  ADD CONSTRAINT fk_BI_hechos_medio_pago_id_canal FOREIGN KEY (id_canal) REFERENCES GAME_OF_JOINS.BI_canal(id_canal) 

GO

--hechos_venta
ALTER TABLE GAME_OF_JOINS.BI_hechos_venta
  ADD CONSTRAINT fk_BI_hechos_venta_id_tiempo FOREIGN KEY (id_tiempo) REFERENCES GAME_OF_JOINS.BI_tiempo(id_tiempo) 

ALTER TABLE GAME_OF_JOINS.BI_hechos_venta
  ADD CONSTRAINT fk_BI_hechos_venta_id_cliente FOREIGN KEY (id_cliente) REFERENCES GAME_OF_JOINS.BI_cliente(id_cliente) 

ALTER TABLE GAME_OF_JOINS.BI_hechos_venta
  ADD CONSTRAINT fk_BI_hechos_venta_id_canal FOREIGN KEY (id_canal) REFERENCES GAME_OF_JOINS.BI_canal(id_canal)

ALTER TABLE GAME_OF_JOINS.BI_hechos_venta
  ADD CONSTRAINT fk_BI_hechos_venta_id_categoria FOREIGN KEY (id_categoria) REFERENCES GAME_OF_JOINS.BI_categoria_producto(id_categoria) 

ALTER TABLE GAME_OF_JOINS.BI_hechos_venta
  ADD CONSTRAINT fk_BI_hechos_venta_id_producto FOREIGN KEY (id_producto) REFERENCES GAME_OF_JOINS.BI_producto(id_producto) 

GO

------------------------------------------------
----------- Funciones auxiliares ---------------
------------------------------------------------

-- devuelve el rango etario en base a una fecha
IF Object_id('GAME_OF_JOINS.BI_Obtener_Rango_Etario') IS NOT NULL 
  DROP FUNCTION GAME_OF_JOINS.BI_Obtener_Rango_Etario 

GO 

CREATE FUNCTION GAME_OF_JOINS.BI_Obtener_Rango_Etario(@fecha_nacimiento DATE) 
RETURNS NVARCHAR(255) 
AS 
  BEGIN 
      DECLARE @edad AS INT = 0 

      SET @edad = Datediff(year, @fecha_nacimiento, GETDATE()) 

      IF @edad < 25
      	RETURN '< 25 años'
      	
      IF @edad BETWEEN 25 AND 35 
        RETURN '25-35 años' 

      IF @edad BETWEEN 35 AND 55 
        RETURN '35-55 años' 

      IF @edad > 55
        RETURN '> 55 años' 

      RETURN '' 
  END 

GO 

-- devuelve el id_cliente de bi en base al id de modelo  
IF Object_id('GAME_OF_JOINS.BI_Obtener_Id_Cliente') IS NOT NULL 
  DROP FUNCTION GAME_OF_JOINS.BI_Obtener_Id_Cliente 

GO 

CREATE FUNCTION GAME_OF_JOINS.BI_Obtener_Id_Cliente(@id_cliente_modelo INT) 
RETURNS INT 
AS 
  BEGIN 
      DECLARE @id_cliente AS INT 
      DECLARE @fecha_nac AS DATE 

		SELECT
			@fecha_nac = clie_fecha_nac
		FROM
			GAME_OF_JOINS.cliente
		WHERE
			clie_id = @id_cliente_modelo 

		SELECT
			@id_cliente = id_cliente
		FROM
			GAME_OF_JOINS.BI_cliente
		WHERE
			rango_etario = GAME_OF_JOINS.BI_Obtener_Rango_Etario(@fecha_nac)

      RETURN @id_cliente 
  END; 

GO 

-- devuelve el id_proveedor de bi en base al cuit del mismo en el modelo  
IF Object_id('GAME_OF_JOINS.BI_Obtener_Id_Proveedor') IS NOT NULL 
  DROP FUNCTION GAME_OF_JOINS.BI_Obtener_Id_Proveedor 

GO 

CREATE FUNCTION GAME_OF_JOINS.BI_Obtener_Id_Proveedor(@cuit_proveedor_modelo NVARCHAR(50)) 
RETURNS INT 
AS 
  BEGIN 
      DECLARE @id_proveedor AS INT 

		SELECT 
				@id_proveedor = id_proveedor
		FROM	GAME_OF_JOINS.BI_proveedor	
		WHERE
				cuit = @cuit_proveedor_modelo

      RETURN @id_proveedor 
  END

GO

-- devuelve el id_producto de bi en base al código de producto del mismo en el modelo  
IF Object_id('GAME_OF_JOINS.BI_Obtener_Id_Producto') IS NOT NULL 
  DROP FUNCTION GAME_OF_JOINS.BI_Obtener_Id_Producto 

GO 

CREATE FUNCTION GAME_OF_JOINS.BI_Obtener_Id_Producto(@codigo_producto_modelo NVARCHAR(50)) 
RETURNS INT 
AS 
  BEGIN 
      DECLARE @id_producto AS INT 

		SELECT 
				@id_producto = id_producto
		FROM	GAME_OF_JOINS.BI_producto	
		WHERE
				codigo = @codigo_producto_modelo

      RETURN @id_producto 
  END

GO 

-- devuelve el id_tiempo de bi en base a una fecha del modelo  
IF Object_id('GAME_OF_JOINS.BI_Obtener_Id_Tiempo') IS NOT NULL 
  DROP FUNCTION GAME_OF_JOINS.BI_Obtener_Id_Tiempo 

GO 

CREATE FUNCTION GAME_OF_JOINS.BI_Obtener_Id_Tiempo(@fecha_modelo DATE) 
RETURNS INT 
AS 
  BEGIN 
      DECLARE @id_fecha AS INT 

		SELECT 
				@id_fecha = id_tiempo
		FROM	GAME_OF_JOINS.BI_tiempo	
		WHERE
				anio = YEAR(@fecha_modelo) AND mes = MONTH(@fecha_modelo)

      RETURN @id_fecha 
  END

GO 

-- devuelve el id_categoria de bi en base a una categoria del modelo  
IF Object_id('GAME_OF_JOINS.BI_Obtener_Id_Categoria') IS NOT NULL 
  DROP FUNCTION GAME_OF_JOINS.BI_Obtener_Id_Categoria 

GO 

CREATE FUNCTION GAME_OF_JOINS.BI_Obtener_Id_Categoria(@categoria_modelo NVARCHAR(255)) 
RETURNS INT 
AS 
  BEGIN 
      DECLARE @id_categoria AS INT 

		SELECT 
				@id_categoria = id_categoria
		FROM	GAME_OF_JOINS.BI_categoria_producto
		WHERE
				descripcion = @categoria_modelo

      RETURN @id_categoria 
  END

GO 

-- devuelve el id_provincia de bi en base al cliente del modelo  
IF Object_id('GAME_OF_JOINS.BI_Obtener_Id_Provincia') IS NOT NULL 
  DROP FUNCTION GAME_OF_JOINS.BI_Obtener_Id_Provincia 

GO 

CREATE FUNCTION GAME_OF_JOINS.BI_Obtener_Id_Provincia(@id_cliente_modelo INT) 
RETURNS INT 
AS 
  BEGIN 
      DECLARE @id_provincia AS INT 
      DECLARE @prov AS NVARCHAR(255) 

		SELECT
			@prov = p.prov_provincia
		FROM
			GAME_OF_JOINS.cliente c
		INNER JOIN GAME_OF_JOINS.codigo_postal cp ON
			c.clie_codigo_postal = cp.copo_id
		INNER JOIN GAME_OF_JOINS.localidad l ON
			cp.copo_localidad = l.loca_id
		INNER JOIN GAME_OF_JOINS.provincia p ON
			l.loca_provincia = p.prov_id
		WHERE
			clie_id = @id_cliente_modelo
		
		SELECT
			@id_provincia = id_provincia
		FROM
			GAME_OF_JOINS.BI_provincia
		WHERE
			descripcion = @prov

      RETURN @id_provincia 
  END; 

GO 

-- devuelve el id_canal de bi en base al codigo de venta del modelo  
IF Object_id('GAME_OF_JOINS.BI_Obtener_Id_Canal') IS NOT NULL 
  DROP FUNCTION GAME_OF_JOINS.BI_Obtener_Id_Canal 

GO 

CREATE FUNCTION GAME_OF_JOINS.BI_Obtener_Id_Canal(@codigo_venta_modelo INT) 
RETURNS INT 
AS 
  BEGIN 
      DECLARE @id_canal AS INT 
      DECLARE @canal AS NVARCHAR(255) 

		SELECT
			@canal = c.cana_canal
		FROM
			GAME_OF_JOINS.venta_canal vc
		INNER JOIN GAME_OF_JOINS.canal c ON
			vc.veca_canal = c.cana_id
		WHERE
			vc.veca_venta_codigo = @codigo_venta_modelo
      
		SELECT
			@id_canal = id_canal
		FROM
			GAME_OF_JOINS.BI_canal
		WHERE
			descripcion = @canal

      RETURN @id_canal
  END; 

GO 

-- devuelve el id_tipo_envio de bi en base al codigo de venta del modelo  
IF Object_id('GAME_OF_JOINS.BI_Obtener_Id_Tipo_Envio') IS NOT NULL 
  DROP FUNCTION GAME_OF_JOINS.BI_Obtener_Id_Tipo_Envio 

GO 

CREATE FUNCTION GAME_OF_JOINS.BI_Obtener_Id_Tipo_Envio(@codigo_venta_modelo INT) 
RETURNS INT 
AS 
  BEGIN 
      DECLARE @id_tipo_envio AS INT 
      DECLARE @tipo_envio AS NVARCHAR(255) 

		SELECT
			@tipo_envio = me.menv_medio_envio
		FROM
			GAME_OF_JOINS.venta_envio ve
		INNER JOIN GAME_OF_JOINS.medio_envio_habilitado hab ON
			ve.veen_medio_habilitado = hab.menh_id
		INNER JOIN GAME_OF_JOINS.medio_envio me ON
			hab.menh_medio_envio = me.menv_id
		WHERE
			ve.veen_venta_codigo = @codigo_venta_modelo
      
		SELECT
			@id_tipo_envio = id_tipo_envio
		FROM
			GAME_OF_JOINS.BI_tipo_envio
		WHERE
			descripcion = @tipo_envio

      RETURN @id_tipo_envio
  END; 

GO 

-- devuelve el id_tipo_medio_pago de bi en base al id de venta medio de pago del modelo 
IF Object_id('GAME_OF_JOINS.BI_Obtener_Id_Tipo_Medio_Pago') IS NOT NULL 
  DROP FUNCTION GAME_OF_JOINS.BI_Obtener_Id_Tipo_Medio_Pago 

GO 

CREATE FUNCTION GAME_OF_JOINS.BI_Obtener_Id_Tipo_Medio_Pago(@venta_medio_pago_modelo INT) 
RETURNS INT 
AS 
  BEGIN 
      DECLARE @id_medio_pago AS INT 
      DECLARE @medio_pago AS NVARCHAR(255) 

		SELECT
			@medio_pago = mp.mepa_medio_pago
		FROM
			GAME_OF_JOINS.venta_medio_pago vmp
		INNER JOIN GAME_OF_JOINS.medio_pago mp ON
			vmp.vmep_medio_pago = mp.mepa_id
		WHERE
			vmp.vmep_id = @venta_medio_pago_modelo
      
		SELECT
			@id_medio_pago = id_tipo_medio_pago
		FROM
			GAME_OF_JOINS.BI_tipo_medio_pago
		WHERE
			descripcion = @medio_pago

      RETURN @id_medio_pago
  END; 

GO 

-- devuelve el id_tipo_descuento de bi en base al id de tipo descuento del modelo 
IF Object_id('GAME_OF_JOINS.BI_Obtener_Id_Tipo_Descuento') IS NOT NULL 
  DROP FUNCTION GAME_OF_JOINS.BI_Obtener_Id_Tipo_Descuento 

GO 

CREATE FUNCTION GAME_OF_JOINS.BI_Obtener_Id_Tipo_Descuento(@tipo_descuento_modelo NVARCHAR(255)) 
RETURNS INT 
AS 
  BEGIN 
      DECLARE @id_tipo_descuento AS INT 

		SELECT
			@id_tipo_descuento = id_tipo_descuento
		FROM
			GAME_OF_JOINS.BI_tipo_descuento
		WHERE
			descripcion = @tipo_descuento_modelo

      RETURN @id_tipo_descuento
  END; 

GO 

USE GD2C2022


------------------------------------------------
--------- Migración de dimensiones -------------
------------------------------------------------

--canal 
IF Object_id('GAME_OF_JOINS.BI_Migrar_Canal') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Migrar_Canal 

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Migrar_Canal 
AS 
    INSERT INTO GAME_OF_JOINS.BI_canal 
                (descripcion) 
	SELECT
		DISTINCT cana_canal
	FROM
		GAME_OF_JOINS.canal

GO 

--categoria_producto 
IF Object_id('GAME_OF_JOINS.BI_Migrar_Categoria_Producto') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Migrar_Categoria_Producto 

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Migrar_Categoria_Producto
AS 
    INSERT INTO GAME_OF_JOINS.BI_categoria_producto
                (descripcion) 
	SELECT
		DISTINCT pcat_categoria
	FROM
		GAME_OF_JOINS.producto_categoria

GO 

--cliente 
IF Object_id('GAME_OF_JOINS.BI_Migrar_Cliente') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Migrar_Cliente 

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Migrar_Cliente 
AS 
    INSERT INTO GAME_OF_JOINS.BI_cliente 
                (rango_etario) 
	SELECT
		DISTINCT GAME_OF_JOINS.BI_Obtener_Rango_Etario(clie_fecha_nac)
	FROM
		GAME_OF_JOINS.cliente

GO 

--producto 
IF Object_id('GAME_OF_JOINS.BI_Migrar_Producto') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Migrar_Producto 

GO 
CREATE PROCEDURE GAME_OF_JOINS.BI_Migrar_Producto
AS 
    INSERT INTO GAME_OF_JOINS.BI_producto
                (codigo, descripcion) 
	SELECT
		DISTINCT	prod_codigo,
					prod_descripcion
	FROM
		GAME_OF_JOINS.producto

GO

--proveedor 
IF Object_id('GAME_OF_JOINS.BI_Migrar_Proveedor') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Migrar_Proveedor 

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Migrar_Proveedor 
AS 
    INSERT INTO GAME_OF_JOINS.BI_proveedor 
                (cuit) 
	SELECT
		DISTINCT prove_cuit
	FROM
		GAME_OF_JOINS.proveedor

GO 

--provincia 
IF Object_id('GAME_OF_JOINS.BI_Migrar_Provincia') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Migrar_Provincia 

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Migrar_Provincia
AS 
    INSERT INTO GAME_OF_JOINS.BI_provincia
                (descripcion) 
	SELECT
		DISTINCT prov_provincia
	FROM
		GAME_OF_JOINS.provincia

GO

--tiempo   
IF Object_id('GAME_OF_JOINS.BI_Migrar_Tiempo') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Migrar_Tiempo 

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Migrar_Tiempo
AS 
    INSERT INTO GAME_OF_JOINS.BI_tiempo 
                (anio, 
                 mes) 
	SELECT
		DISTINCT YEAR(comp_fecha),
		MONTH(comp_fecha)
	FROM
		GAME_OF_JOINS.compra
	UNION
	SELECT
		DISTINCT YEAR(vent_fecha),
		MONTH(vent_fecha)
	FROM
		GAME_OF_JOINS.venta

GO 

--tipo_descuento
IF Object_id('GAME_OF_JOINS.BI_Migrar_Tipo_Descuento') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Migrar_Tipo_Descuento 

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Migrar_Tipo_Descuento 
AS 
    INSERT INTO GAME_OF_JOINS.BI_tipo_descuento
                (descripcion) 
	SELECT
		DISTINCT descu_tipo
	FROM
		GAME_OF_JOINS.descuento
	UNION
	SELECT
		'Cupon'
GO

--tipo_envio 
IF Object_id('GAME_OF_JOINS.BI_Migrar_Tipo_Envio') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Migrar_Tipo_Envio 

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Migrar_Tipo_Envio 
AS 
    INSERT INTO GAME_OF_JOINS.BI_tipo_envio
                (descripcion) 
	SELECT
		DISTINCT menv_medio_envio
	FROM
		GAME_OF_JOINS.medio_envio

GO 

--tipo_medio_pago 
IF Object_id('GAME_OF_JOINS.BI_Migrar_Tipo_Medio_Pago') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Migrar_Tipo_Medio_Pago 

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Migrar_Tipo_Medio_Pago 
AS 
    INSERT INTO GAME_OF_JOINS.BI_tipo_medio_pago 
                (descripcion) 
	SELECT
		DISTINCT mepa_medio_pago
	FROM
		GAME_OF_JOINS.medio_pago

GO 

------------------------------------------------
----------- Migración de hechos ----------------
------------------------------------------------

--hechos_compra
IF Object_id('GAME_OF_JOINS.BI_Migrar_Hechos_Compra') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Migrar_Hechos_Compra

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Migrar_Hechos_Compra
AS 
	INSERT INTO GD2C2022.GAME_OF_JOINS.BI_hechos_compra
	(id_producto, id_proveedor, id_tiempo, cantidad, precio_unitario)

	SELECT
		GAME_OF_JOINS.BI_Obtener_Id_Producto(cp.cpro_producto_codigo) AS id_producto,
		GAME_OF_JOINS.BI_Obtener_Id_Proveedor(co.comp_proveedor_cuit) AS id_proveedor,
		GAME_OF_JOINS.BI_Obtener_Id_Tiempo(co.comp_fecha) AS id_tiempo,
		SUM(cp.cpro_cantidad) AS cantidad,
		MAX(cp.cpro_precio) AS precio_unitario
	FROM
		GAME_OF_JOINS.compra_producto cp
	INNER JOIN GAME_OF_JOINS.compra co ON
		cp.cpro_compra_numero = co.comp_numero
	GROUP BY
		GAME_OF_JOINS.BI_Obtener_Id_Producto(cp.cpro_producto_codigo),
		GAME_OF_JOINS.BI_Obtener_Id_Proveedor(co.comp_proveedor_cuit),
		GAME_OF_JOINS.BI_Obtener_Id_Tiempo(co.comp_fecha)
GO

--hechos_descuento

IF Object_id('GAME_OF_JOINS.BI_Migrar_Hechos_Descuento') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Migrar_Hechos_Descuento

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Migrar_Hechos_Descuento
AS 
	INSERT INTO GD2C2022.GAME_OF_JOINS.BI_hechos_descuento
	(id_canal, id_tiempo, id_tipo_descuento, valor_total)
	
	SELECT
		GAME_OF_JOINS.BI_Obtener_Id_Canal(vd.vede_venta_codigo) AS id_canal,
		GAME_OF_JOINS.BI_OBtener_Id_Tiempo(v.vent_fecha) AS id_tiempo,
		GAME_OF_JOINS.BI_OBtener_Id_Tipo_Descuento(d.descu_tipo) AS id_tipo_descuento,
		SUM(vd.vede_importe) AS valor_total
	FROM
		GAME_OF_JOINS.venta_descuento vd
	INNER JOIN GAME_OF_JOINS.venta v ON
		vd.vede_venta_codigo = v.vent_codigo
	INNER JOIN GAME_OF_JOINS.descuento d ON
		vd.vede_descuento = d.descu_id
	GROUP BY
		GAME_OF_JOINS.BI_Obtener_Id_Canal(vd.vede_venta_codigo),
		GAME_OF_JOINS.BI_OBtener_Id_Tiempo(v.vent_fecha),
		GAME_OF_JOINS.BI_OBtener_Id_Tipo_Descuento(d.descu_tipo)
	UNION
	SELECT
		GAME_OF_JOINS.BI_Obtener_Id_Canal(vc.vecu_venta_codigo) AS id_canal,
		GAME_OF_JOINS.BI_OBtener_Id_Tiempo(v.vent_fecha) AS id_tiempo,
		GAME_OF_JOINS.BI_OBtener_Id_Tipo_Descuento('Cupon') AS id_tipo_descuento,
		SUM(vc.vecu_importe) AS valor_total
	FROM
		GAME_OF_JOINS.venta_cupon vc
	INNER JOIN GAME_OF_JOINS.venta v ON
		vc.vecu_venta_codigo = v.vent_codigo
	GROUP BY
		GAME_OF_JOINS.BI_Obtener_Id_Canal(vc.vecu_venta_codigo),
		GAME_OF_JOINS.BI_OBtener_Id_Tiempo(v.vent_fecha)
GO


--hechos_medio_pago
IF Object_id('GAME_OF_JOINS.BI_Migrar_Hechos_Medio_Pago') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Migrar_Hechos_Medio_Pago

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Migrar_Hechos_Medio_Pago
AS 
	INSERT INTO GD2C2022.GAME_OF_JOINS.BI_hechos_medio_pago
	(id_tipo_medio_pago, id_canal, id_tiempo, costo_transaccion)
	
	SELECT
		GAME_OF_JOINS.BI_Obtener_Id_Tipo_Medio_Pago(vmp.vmep_id) AS id_tipo_medio_pago,
		GAME_OF_JOINS.BI_Obtener_Id_Canal(v.vent_codigo) AS id_canal,
		GAME_OF_JOINS.BI_Obtener_Id_Tiempo(v.vent_fecha) AS id_tiempo,
		SUM(vmp.vmep_costo) AS costo_transaccion
	FROM
		GAME_OF_JOINS.venta_medio_pago vmp
	INNER JOIN GAME_OF_JOINS.venta v ON
		vmp.vmep_id = v.vent_venta_medio_pago
	GROUP BY
		GAME_OF_JOINS.BI_Obtener_Id_Tipo_Medio_Pago(vmp.vmep_id),
		GAME_OF_JOINS.BI_Obtener_Id_Canal(v.vent_codigo) ,
		GAME_OF_JOINS.BI_Obtener_Id_Tiempo(v.vent_fecha)
GO

--hechos_venta
IF Object_id('GAME_OF_JOINS.BI_Migrar_Hechos_Venta') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Migrar_Hechos_Venta

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Migrar_Hechos_Venta
AS 
	INSERT INTO GD2C2022.GAME_OF_JOINS.BI_hechos_venta
	(id_tiempo, id_cliente, id_canal, id_categoria, id_producto, cantidad, precio_unitario)

	SELECT
		GAME_OF_JOINS.BI_Obtener_Id_Tiempo(ve.vent_fecha) AS id_tiempo,
		GAME_OF_JOINS.BI_Obtener_Id_Cliente(ve.vent_cliente) AS id_cliente,
		GAME_OF_JOINS.BI_Obtener_Id_Canal(vp.vpro_venta_codigo) AS id_canal,
		GAME_OF_JOINS.BI_Obtener_Id_Categoria(pc.pcat_categoria) AS id_categoria,
		GAME_OF_JOINS.BI_Obtener_Id_Producto(vp.vpro_producto_codigo) AS id_producto,
		SUM(vp.vpro_cantidad) AS cantidad,
		MAX(vp.vpro_precio) AS precio_unitario
	FROM
		GAME_OF_JOINS.venta_producto vp
	INNER JOIN GAME_OF_JOINS.venta ve ON
		vp.vpro_venta_codigo = ve.vent_codigo
	INNER JOIN GAME_OF_JOINS.producto pr ON
		vp.vpro_producto_codigo = pr.prod_codigo
	INNER JOIN GAME_OF_JOINS.producto_categoria pc ON
		pr.prod_categoria = pc.pcat_id
	GROUP BY
		GAME_OF_JOINS.BI_Obtener_Id_Tiempo(ve.vent_fecha),
		GAME_OF_JOINS.BI_Obtener_Id_Cliente(ve.vent_cliente),
		GAME_OF_JOINS.BI_Obtener_Id_Canal(vp.vpro_venta_codigo),
		GAME_OF_JOINS.BI_Obtener_Id_Categoria(pc.pcat_categoria),
		GAME_OF_JOINS.BI_Obtener_Id_Producto(vp.vpro_producto_codigo)
GO

--hechos_Envio
IF Object_id('GAME_OF_JOINS.BI_Migrar_Hechos_Envio') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Migrar_Hechos_Envio

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Migrar_Hechos_Envio
AS 
	INSERT INTO GD2C2022.GAME_OF_JOINS.BI_hechos_envio
	(id_provincia, id_tiempo, id_tipo_envio, cantidad_envios, costo_envio)
	
	SELECT
		GAME_OF_JOINS.BI_Obtener_Id_Provincia(venta.vent_cliente) id_provincia,
		GAME_OF_JOINS.BI_Obtener_Id_Tiempo(venta.vent_fecha) AS id_tiempo,
		GAME_OF_JOINS.BI_Obtener_Id_Tipo_Envio(venta.vent_codigo) AS id_tipo_envio,
		COUNT(*) AS cantidad,
		SUM(envio.veen_precio) AS costo
	FROM
		GAME_OF_JOINS.venta_envio envio
	INNER JOIN GAME_OF_JOINS.venta venta ON
		envio.veen_venta_codigo = venta.vent_codigo
	GROUP BY
		GAME_OF_JOINS.BI_Obtener_Id_Tiempo(venta.vent_fecha),
		GAME_OF_JOINS.BI_Obtener_Id_Provincia(venta.vent_cliente),
		GAME_OF_JOINS.BI_Obtener_Id_Tipo_Envio(venta.vent_codigo)
GO

------------------------------------------------
---------- Vistas para modelo BI ---------------
------------------------------------------------


/*
 * Las ganancias mensuales de cada canal de venta.
 * Se entiende por ganancias al total de las ventas, menos el total de las
 * compras, menos los costos de transacción totales aplicados asociados los
 * medios de pagos utilizados en las mismas.
 */

IF Object_id('GAME_OF_JOINS.BI_VW_Ganancias_Mensuales') IS NOT NULL 
  DROP VIEW GAME_OF_JOINS.BI_VW_Ganancias_Mensuales

GO 

CREATE VIEW GAME_OF_JOINS.BI_VW_Ganancias_Mensuales
AS	
	SELECT		ti.anio anio,
				ti.mes mes,
				ca.descripcion canal_de_venta,
				ISNULL(SUM(hve.cantidad * hve.precio_unitario), 0) - ISNULL((SELECT SUM(hmp.costo_transaccion) FROM GAME_OF_JOINS.BI_hechos_medio_pago hmp WHERE hmp.id_tiempo = hve.id_tiempo), 0) - ISNULL((SELECT SUM(hco.cantidad * hco.precio_unitario) FROM GAME_OF_JOINS.BI_hechos_compra hco WHERE hco.id_tiempo = hve.id_tiempo), 0) ganancia_mensual
	FROM		GAME_OF_JOINS.BI_hechos_venta hve
	INNER JOIN	GAME_OF_JOINS.BI_tiempo ti
	ON			hve.id_tiempo = ti.id_tiempo
	INNER JOIN	GAME_OF_JOINS.BI_canal ca
	ON			hve.id_canal = ca.id_canal
	GROUP BY	hve.id_tiempo,
				ti.anio,
				ti.mes, 
				hve.id_canal, 
				ca.descripcion
GO


/*
 * Los 5 productos con mayor rentabilidad anual, con sus respectivos %
 * Se entiende por rentabilidad a los ingresos generados por el producto
 * (ventas) durante el periodo menos la inversión realizada en el producto
 * (compras) durante el periodo, todo esto sobre dichos ingresos.
 * Valor expresado en porcentaje.
 * Para simplificar, no es necesario tener en cuenta los descuentos aplicados.
 */

IF Object_id('GAME_OF_JOINS.BI_VW_Productos_Con_Mayor_Rentabilidad_Anual') IS NOT NULL 
  DROP VIEW GAME_OF_JOINS.BI_VW_Productos_Con_Mayor_Rentabilidad_Anual

GO 

CREATE VIEW GAME_OF_JOINS.BI_VW_Productos_Con_Mayor_Rentabilidad_Anual
AS

	WITH ranking_productos_rentabilidad AS (
	SELECT		pr.codigo codigo,
				ti.anio anio,
				100 *(
					ISNULL(SUM(hv.precio_unitario * hv.cantidad), 0)
					-
					ISNULL((
						SELECT			SUM(hc.precio_unitario * hc.cantidad)
						FROM			GAME_OF_JOINS.BI_hechos_compra hc
						INNER JOIN		GAME_OF_JOINS.BI_tiempo ti2
						ON				hc.id_tiempo = ti2.id_tiempo
						WHERE			hc.id_producto = hv.id_producto AND ti2.anio = ti.anio
						GROUP BY		hc.id_producto
					), 0)
				)
				/
				(SUM(hv.precio_unitario * hv.cantidad)) rentabilidad,
				ROW_NUMBER()
				OVER (
					PARTITION BY ti.anio
					ORDER BY	100 * (
									ISNULL(SUM(hv.precio_unitario * hv.cantidad), 0)
									-
									ISNULL((
										SELECT			SUM(hc.precio_unitario * hc.cantidad)
										FROM			GAME_OF_JOINS.BI_hechos_compra hc
										INNER JOIN		GAME_OF_JOINS.BI_tiempo ti2
										ON				hc.id_tiempo = ti2.id_tiempo
										WHERE			hc.id_producto = hv.id_producto AND ti2.anio = ti.anio
										GROUP BY		hc.id_producto
									), 0)
								)
								/
								(SUM(hv.precio_unitario * hv.cantidad))
					DESC) AS ranking
	FROM		GAME_OF_JOINS.BI_hechos_venta hv
	INNER JOIN	GAME_OF_JOINS.BI_producto pr
	ON			hv.id_producto = pr.id_producto
	INNER JOIN	GAME_OF_JOINS.BI_tiempo ti
	ON			hv.id_tiempo = ti.id_tiempo
	GROUP BY	hv.id_producto, pr.codigo, ti.anio
	)
	SELECT
		codigo codigo,
		anio anio,
		rentabilidad rentabilidad
	FROM
		ranking_productos_rentabilidad
	WHERE
		ranking <= 5

GO

/*
 * Las 5 categorías de productos más vendidos por rango etario de clientes
 * por mes.
 */

IF Object_id('GAME_OF_JOINS.BI_VW_categorias_mas_vendidas_por_rango_etario') IS NOT NULL 
  DROP VIEW GAME_OF_JOINS.BI_VW_categorias_mas_vendidas_por_rango_etario 

GO 

CREATE VIEW GAME_OF_JOINS.BI_VW_categorias_mas_vendidas_por_rango_etario 
AS

	WITH ranking_categorias_por_edad AS (
	SELECT
		tie.anio AS anio,
		tie.mes AS mes,
		cli.rango_etario AS rango_etario,
		cp.descripcion AS categoria,
		SUM(hv.cantidad) AS cantidad_vendida,
		ROW_NUMBER() OVER (PARTITION BY tie.mes, cli.rango_etario
	ORDER BY
		SUM(hv.cantidad) DESC) AS ranking
	FROM
		GAME_OF_JOINS.BI_hechos_venta hv
	INNER JOIN GAME_OF_JOINS.BI_categoria_producto cp ON
		hv.id_categoria = cp.id_categoria
	INNER JOIN GAME_OF_JOINS.BI_tiempo tie ON
		hv.id_tiempo = tie.id_tiempo
	INNER JOIN GAME_OF_JOINS.BI_cliente cli ON
		hv.id_cliente = cli.id_cliente
	GROUP BY
		tie.anio,
		tie.mes,
		cli.rango_etario,
		cp.descripcion )
	SELECT
		anio,
		mes,
		rango_etario,
		categoria,
		cantidad_vendida
	FROM
		ranking_categorias_por_edad
	WHERE
		ranking <= 5

GO

/*
 * Total de Ingresos por cada medio de pago por mes, descontando los costos
 * por medio de pago (en caso que aplique) y descuentos por medio de pago
 * (en caso que aplique)
 */

IF Object_id('GAME_OF_JOINS.BI_VW_Ingresos_Mensuales_Medio_Pago') IS NOT NULL 
  DROP VIEW GAME_OF_JOINS.BI_VW_Ingresos_Mensuales_Medio_Pago

GO 

CREATE VIEW GAME_OF_JOINS.BI_VW_Ingresos_Mensuales_Medio_Pago
AS

	SELECT
		ti.anio AS anio,
		ti.mes AS mes,
		--medio_pago AS medio_pago,
		SUM(hv.cantidad * hv.precio_unitario) AS total_ventas,
		(
		SELECT
			SUM(hd.valor_total)
		FROM
			GAME_OF_JOINS.BI_hechos_descuento hd
		INNER JOIN GAME_OF_JOINS.BI_tipo_descuento td ON
			hd.id_tipo_descuento = td.id_tipo_descuento
		WHERE
			td.descripcion = 'Medio Pago'
			AND hd.id_tiempo = ti.id_tiempo) AS descuentos,
		(
		SELECT
			SUM(hmp.costo_transaccion)
		FROM
			GAME_OF_JOINS.BI_hechos_medio_pago hmp
		WHERE
			hmp.id_tiempo = ti.id_tiempo) AS costos,
		COUNT(*) AS la_resta_que_falta
		--faltaría borrar las 3 de arriba después de probar y hacer acá la resta
	
		FROM GAME_OF_JOINS.BI_hechos_venta hv
	INNER JOIN GAME_OF_JOINS.BI_tiempo ti ON
		hv.id_tiempo = ti.id_tiempo
		--faltaría agregar la dimensión tipo medio pago a hechos_ventas, sino no podes saber como distribuir los ingresos 
		--INNER JOIN GAME_OF_JOINS.BI_tipo_medio_pago mp
		--ON hv.
	
		GROUP BY ti.id_tiempo,
		ti.anio,
		ti.mes
		--mp.descripcion

GO


/* 
 * Importe total en descuentos aplicados según su tipo de descuento, por
 * canal de venta, por mes. Se entiende por tipo de descuento como los
 * correspondientes a envío, medio de pago, cupones, etc)
 */

IF Object_id('GAME_OF_JOINS.BI_VW_Descuentos_Mensuales_Por_Canal_Por_Tipo') IS NOT NULL 
  DROP VIEW GAME_OF_JOINS.BI_VW_Descuentos_Mensuales_Por_Canal_Por_Tipo

GO 

CREATE VIEW GAME_OF_JOINS.BI_VW_Descuentos_Mensuales_Por_Canal_Por_Tipo
AS
	SELECT
		ti.anio AS anio,
		ti.mes AS mes,
		ca.descripcion AS canal,
		td.descripcion AS tipo_de_descuento,
		SUM(hd.valor_total) AS total_descuento
	FROM
		GAME_OF_JOINS.BI_hechos_descuento hd
	INNER JOIN GAME_OF_JOINS.BI_tiempo ti ON
		hd.id_tiempo = ti.id_tiempo
	INNER JOIN GAME_OF_JOINS.BI_tipo_descuento td ON
		hd.id_tipo_descuento = td.id_tipo_descuento
	INNER JOIN GAME_OF_JOINS.BI_canal ca ON
		hd.id_canal = ca.id_canal
	GROUP BY
		ti.anio,
		ti.mes,
		ca.descripcion,
		td.descripcion
GO

/*
 * Porcentaje de envíos realizados a cada Provincia por mes. El porcentaje
 * debe representar la cantidad de envíos realizados a cada provincia sobre
 * total de envío mensuales.
 */

IF Object_id('GAME_OF_JOINS.BI_VW_porcentaje_envios_provincia_mensual') IS NOT 
   NULL 
  DROP VIEW GAME_OF_JOINS.BI_VW_porcentaje_envios_provincia_mensual 

GO 

CREATE VIEW GAME_OF_JOINS.BI_VW_porcentaje_envios_provincia_mensual 
AS 
	SELECT
		ti.anio AS anio,
		ti.mes AS mes,
		pr.descripcion AS provincia,
		ROUND(100 * 1.0 * COUNT(*) / ( SELECT COUNT(*) FROM GAME_OF_JOINS.BI_hechos_envio he1 INNER JOIN GAME_OF_JOINS.BI_tiempo ti1 ON he1.id_tiempo = ti1.id_tiempo WHERE ti1.anio = ti.anio AND ti1.mes = ti.mes), 2) AS porcentaje_envios
	FROM
		GAME_OF_JOINS.BI_hechos_envio he
	INNER JOIN GAME_OF_JOINS.BI_tiempo ti ON
		he.id_tiempo = ti.id_tiempo
	INNER JOIN GAME_OF_JOINS.BI_provincia pr ON
		he.id_provincia = pr.id_provincia
	GROUP BY
		ti.anio,
		ti.mes,
		pr.descripcion

GO

/* 
 * Valor promedio de envío por Provincia por Medio De Envío anual.
 */

IF Object_id('GAME_OF_JOINS.BI_VW_valor_promedio_envio_provincia') IS NOT 
   NULL 
  DROP VIEW GAME_OF_JOINS.BI_VW_valor_promedio_envio_provincia 

GO 

CREATE VIEW GAME_OF_JOINS.BI_VW_valor_promedio_envio_provincia 
AS 
	SELECT
		ti.anio AS anio,
		pr.descripcion AS provincia,
		te.descripcion AS medio_envio,
		AVG(he.costo_envio) AS envio_promedio
	FROM
		GAME_OF_JOINS.BI_hechos_envio he
	INNER JOIN GAME_OF_JOINS.BI_tiempo ti ON
		he.id_tiempo = ti.id_tiempo
	INNER JOIN GAME_OF_JOINS.BI_provincia pr ON
		he.id_provincia = pr.id_provincia
	INNER JOIN GAME_OF_JOINS.BI_tipo_envio te ON
		he.id_tipo_envio = te.id_tipo_envio
	GROUP BY
		ti.anio,
		pr.descripcion,
		te.descripcion
GO

/*
 * Aumento promedio de precios de cada proveedor anual. Para calcular este
 * indicador se debe tomar como referencia el máximo precio por año menos
 * el mínimo todo esto divido el mínimo precio del año. Teniendo en cuenta
 * que los precios siempre van en aumento.
 */

IF Object_id('GAME_OF_JOINS.BI_VW_aumento_promedio_proveedor') IS NOT 
   NULL 
  DROP VIEW GAME_OF_JOINS.BI_VW_aumento_promedio_proveedor 

GO 

CREATE VIEW GAME_OF_JOINS.BI_VW_aumento_promedio_proveedor 
AS 

	WITH aumentos_proveedores AS (
	SELECT
		tie.anio AS anio,
		p.cuit AS proveedor,
		(MAX(hc.precio_unitario) - MIN(hc.precio_unitario)) / MIN(hc.precio_unitario) * 100 AS porcentaje_aumento
	FROM
		GAME_OF_JOINS.BI_hechos_compra hc
	INNER JOIN GAME_OF_JOINS.BI_Proveedor p ON
		hc.id_proveedor = p.id_proveedor
	INNER JOIN GAME_OF_JOINS.BI_tiempo tie ON
		hc.id_tiempo = tie.id_tiempo
	GROUP BY
		tie.anio,
		p.cuit,
		hc.id_producto )
	SELECT
		anio,
		proveedor,
		ROUND(AVG(porcentaje_aumento), 2) AS aumento_promedio
	FROM
		aumentos_proveedores
	GROUP BY
		anio,
		proveedor

GO

/*
 * Los 3 productos con mayor cantidad de reposición por mes. 
 */

IF Object_id('GAME_OF_JOINS.BI_VW_productos_mayor_reposicion') IS NOT 
   NULL 
  DROP VIEW GAME_OF_JOINS.BI_VW_productos_mayor_reposicion 

GO 

CREATE VIEW GAME_OF_JOINS.BI_VW_productos_mayor_reposicion 
AS 
	WITH ranking_productos_reposicion AS (
	SELECT
		p.codigo AS producto_codigo,
		p.descripcion AS producto_descripcion,
		tie.anio AS anio,
		tie.mes AS mes,
		SUM(hc.cantidad) AS cantidad,
		ROW_NUMBER() OVER ( PARTITION BY tie.mes
	ORDER BY
		SUM(hc.cantidad) DESC ) AS ranking
	FROM
		GAME_OF_JOINS.BI_hechos_compra hc
	INNER JOIN GAME_OF_JOINS.BI_tiempo tie ON
		hc.id_tiempo = tie.id_tiempo
	INNER JOIN GAME_OF_JOINS.BI_producto p ON
		hc.id_producto = p.id_producto
	GROUP BY
		p.codigo,
		p.descripcion,
		tie.anio,
		tie.mes )
	SELECT
		anio,
		mes,
		producto_codigo,
		producto_descripcion,
		cantidad
	FROM
		ranking_productos_reposicion
	WHERE
		ranking <= 3
GO 

------------------------------------------------
------------ Migracion de datos ----------------
------------------------------------------------

EXEC GAME_OF_JOINS.BI_Migrar_Canal
EXEC GAME_OF_JOINS.BI_Migrar_Categoria_Producto
EXEC GAME_OF_JOINS.BI_Migrar_Cliente
EXEC GAME_OF_JOINS.BI_Migrar_Producto
EXEC GAME_OF_JOINS.BI_Migrar_Proveedor
EXEC GAME_OF_JOINS.BI_Migrar_Provincia
EXEC GAME_OF_JOINS.BI_Migrar_Tiempo
EXEC GAME_OF_JOINS.BI_Migrar_Tipo_Descuento
EXEC GAME_OF_JOINS.BI_Migrar_Tipo_Envio
EXEC GAME_OF_JOINS.BI_Migrar_Tipo_Medio_Pago
EXEC GAME_OF_JOINS.BI_Migrar_Hechos_Compra
EXEC GAME_OF_JOINS.BI_Migrar_Hechos_Descuento
EXEC GAME_OF_JOINS.BI_Migrar_Hechos_Envio
EXEC GAME_OF_JOINS.BI_Migrar_Hechos_Medio_Pago
EXEC GAME_OF_JOINS.BI_Migrar_Hechos_Venta

GO

------------------------------------------------
----------- Drop de Procedures -----------------
------------------------------------------------

EXEC GAME_OF_JOINS.BI_Drop_All_Procedures

GO

------------------------------------------------
--------------- Test Views ---------------------
------------------------------------------------

--SELECT * FROM GAME_OF_JOINS.BI_VW_Ganancias_Mensuales ORDER BY anio ASC, mes ASC, canal_de_venta ASC
--SELECT * FROM GAME_OF_JOINS.BI_VW_Productos_Con_Mayor_Rentabilidad_Anual ORDER BY anio ASC, rentabilidad DESC
--SELECT * FROM GAME_OF_JOINS.BI_VW_Ingresos_Mensuales_Medio_Pago ORDER BY anio ASC, mes ASC, medio_de_pago ASC
--SELECT * FROM GAME_OF_JOINS.BI_VW_Descuentos_Mensuales_Por_Canal_Por_Tipo ORDER BY anio ASC, mes ASC, tipo_de_descuento ASC
--SELECT * FROM GAME_OF_JOINS.BI_VW_Productos_Mayor_Reposicion ORDER BY mes, anio, cantidad DESC
--SELECT * FROM GAME_OF_JOINS.BI_VW_Aumento_Promedio_Proveedor ORDER BY anio ASC, proveedor ASC
--SELECT * FROM GAME_OF_JOINS.BI_VW_Valor_Promedio_Envio_Provincia ORDER BY anio, provincia, medio_envio
--SELECT * FROM GAME_OF_JOINS.BI_VW_Porcentaje_Envios_Provincia_Mensual ORDER BY anio, mes, provincia
--SELECT * FROM GAME_OF_JOINS.BI_VW_Categorias_Mas_Vendidas_Por_Rango_Etario ORDER BY anio, mes, rango_etario, categoria, cantidad_vendida DESC


SELECT * FROM GAME_OF_JOINS.table_row_count ORDER BY table_name ASC