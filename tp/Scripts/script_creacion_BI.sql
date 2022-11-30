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

CREATE OR ALTER PROCEDURE GAME_OF_JOINS.BI_Erase_All_Foreign_Keys
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

CREATE OR ALTER PROCEDURE GAME_OF_JOINS.BI_Drop_All_Tables
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

CREATE OR ALTER PROCEDURE GAME_OF_JOINS.BI_Drop_All_Procedures
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
------------ Definicion de datos ---------------
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
     descripcion NVARCHAR(255),
  )

--cliente  
CREATE TABLE GAME_OF_JOINS.BI_cliente 
  ( 
     id_cliente INT PRIMARY KEY IDENTITY(1, 1), 
     rango_etario NVARCHAR(255) NOT NULL,
  ) 

--compra
CREATE TABLE GAME_OF_JOINS.BI_compra
  (
	id_compra INT PRIMARY KEY IDENTITY(1, 1),
	total DECIMAL(18,2) NOT NULL,
	id_proveedor INT NOT NULL, --fk
	id_tiempo INT NOT NULL, --fk
  ) 

--compra_producto
CREATE TABLE GAME_OF_JOINS.BI_compra_producto
  (
	id_compra_producto INT PRIMARY KEY IDENTITY(1, 1),
	precio_unitario DECIMAL(18,2) NOT NULL,
	cantidad DECIMAL(18,0) NOT NULL,
	id_producto INT NOT NULL, --fk
	id_proveedor INT NOT NULL, --fk
	id_tiempo INT NOT NULL, --fk
  ) 

--medio_pago
CREATE TABLE GAME_OF_JOINS.BI_medio_pago
  (
	 id_medio_pago INT PRIMARY KEY IDENTITY(1, 1), 
     descripcion NVARCHAR(255) NOT NULL,
  )

--producto
CREATE TABLE GAME_OF_JOINS.BI_producto
  (
	 id_producto INT PRIMARY KEY IDENTITY(1, 1),
	 codigo NVARCHAR(50) NOT NULL,
     descripcion NVARCHAR(50) NOT NULL,
  )

--producto_categoria  
CREATE TABLE GAME_OF_JOINS.BI_producto_categoria
  (
	 id_categoria INT PRIMARY KEY IDENTITY(1, 1), 
     descripcion NVARCHAR(255),
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
     descripcion NVARCHAR(255),
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

-- venta
CREATE TABLE GAME_OF_JOINS.BI_venta
  (
	id_venta INT PRIMARY KEY IDENTITY(1, 1),
	venta_codigo DECIMAL(19,0) NOT NULL,
	total DECIMAL(18,2) NOT NULL,
	valor_envio DECIMAL(18,2),
	mepa_costo DECIMAL(18,2) NOT NULL,
	mepa_descuento DECIMAL(18,2),
	id_tiempo INT NOT NULL, --fk
	id_cliente INT NOT NULL, --fk
	id_provincia INT NOT NULL, --fk
	id_canal INT NOT NULL, --fk
	id_tipo_envio INT NOT NULL, --fk
	id_medio_pago INT NOT NULL, --fk
  ) 

--venta_descuento
CREATE TABLE GAME_OF_JOINS.BI_venta_descuento
  (
	id_venta_descuento INT PRIMARY KEY IDENTITY(1, 1),
	venta_codigo DECIMAL(19,0) NOT NULL,
	id_tipo_descuento INT NOT NULL, --fk
	importe DECIMAL(18,2) NOT NULL, --fk
  )  

--venta_producto
CREATE TABLE GAME_OF_JOINS.BI_venta_producto
  (
	id_venta_producto INT PRIMARY KEY IDENTITY(1, 1),
	id_producto INT NOT NULL,
	id_categoria INT NOT NULL, --fk
	id_tiempo INT NOT NULL, --fk
	id_cliente INT NOT NULL, --fk
	precio DECIMAL(18,2) NOT NULL, --fk
	cantidad DECIMAL(18,2) NOT NULL, --fk
  )  

  
------------------------------------------------
------------- Definicion de FKs ----------------
------------------------------------------------

-- Regla para nombrar FKs: FK_BI_tabla_origen_nombre_campo 

  
--compra
ALTER TABLE GAME_OF_JOINS.BI_compra 
  ADD CONSTRAINT fk_BI_compra_id_proveedor FOREIGN KEY (id_proveedor) REFERENCES GAME_OF_JOINS.BI_proveedor(id_proveedor) 

ALTER TABLE GAME_OF_JOINS.BI_compra 
  ADD CONSTRAINT fk_BI_compra_id_tiempo FOREIGN KEY (id_tiempo) REFERENCES GAME_OF_JOINS.BI_tiempo(id_tiempo) 

GO
  
--compra_producto
ALTER TABLE GAME_OF_JOINS.BI_compra_producto
  ADD CONSTRAINT fk_BI_compra_producto_id_producto FOREIGN KEY (id_producto) REFERENCES GAME_OF_JOINS.BI_producto(id_producto) 

ALTER TABLE GAME_OF_JOINS.BI_compra_producto 
  ADD CONSTRAINT fk_BI_compra_producto_id_proveedor FOREIGN KEY (id_proveedor) REFERENCES GAME_OF_JOINS.BI_proveedor(id_proveedor) 

ALTER TABLE GAME_OF_JOINS.BI_compra_producto 
  ADD CONSTRAINT fk_BI_compra_producto_id_tiempo FOREIGN KEY (id_tiempo) REFERENCES GAME_OF_JOINS.BI_tiempo(id_tiempo) 

GO

--venta
ALTER TABLE GAME_OF_JOINS.BI_venta
  ADD CONSTRAINT fk_BI_venta_id_provincia FOREIGN KEY (id_provincia) REFERENCES GAME_OF_JOINS.BI_provincia(id_provincia) 

ALTER TABLE GAME_OF_JOINS.BI_venta
  ADD CONSTRAINT fk_BI_venta_id_cliente FOREIGN KEY (id_cliente) REFERENCES GAME_OF_JOINS.BI_cliente(id_cliente) 

ALTER TABLE GAME_OF_JOINS.BI_venta
  ADD CONSTRAINT fk_BI_venta_id_tiempo FOREIGN KEY (id_tiempo) REFERENCES GAME_OF_JOINS.BI_tiempo(id_tiempo) 
  
ALTER TABLE GAME_OF_JOINS.BI_venta
  ADD CONSTRAINT fk_BI_venta_id_canal FOREIGN KEY (id_canal) REFERENCES GAME_OF_JOINS.BI_canal(id_canal) 
  
ALTER TABLE GAME_OF_JOINS.BI_venta
  ADD CONSTRAINT fk_BI_venta_id_tipo_envio FOREIGN KEY (id_tipo_envio) REFERENCES GAME_OF_JOINS.BI_tipo_envio(id_tipo_envio) 

ALTER TABLE GAME_OF_JOINS.BI_venta
  ADD CONSTRAINT fk_BI_venta_id_medio_pago FOREIGN KEY (id_medio_pago) REFERENCES GAME_OF_JOINS.BI_medio_pago(id_medio_pago) 

GO

--venta_descuento
ALTER TABLE GAME_OF_JOINS.BI_venta_descuento
  ADD CONSTRAINT fk_BI_venta_descuento_id_tipo_descuento FOREIGN KEY (id_tipo_descuento) REFERENCES GAME_OF_JOINS.BI_tipo_descuento(id_tipo_descuento) 

GO

--venta_producto
ALTER TABLE GAME_OF_JOINS.BI_venta_producto
  ADD CONSTRAINT fk_BI_venta_producto_id_producto FOREIGN KEY (id_producto) REFERENCES GAME_OF_JOINS.BI_producto(id_producto) 

ALTER TABLE GAME_OF_JOINS.BI_venta_producto
  ADD CONSTRAINT fk_BI_venta_producto_id_categoria FOREIGN KEY (id_categoria) REFERENCES GAME_OF_JOINS.BI_producto_categoria(id_categoria) 
  
ALTER TABLE GAME_OF_JOINS.BI_venta_producto
  ADD CONSTRAINT fk_BI_venta_producto_id_tiempo FOREIGN KEY (id_tiempo) REFERENCES GAME_OF_JOINS.BI_tiempo(id_tiempo) 
  
ALTER TABLE GAME_OF_JOINS.BI_venta_producto
  ADD CONSTRAINT fk_BI_venta_producto_id_cliente FOREIGN KEY (id_cliente) REFERENCES GAME_OF_JOINS.BI_cliente(id_cliente) 

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
		FROM	GAME_OF_JOINS.BI_producto_categoria
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

-- devuelve el id_medio_pago de bi en base al id de venta medio de pago del modelo 
IF Object_id('GAME_OF_JOINS.BI_Obtener_Id_Medio_Pago') IS NOT NULL 
  DROP FUNCTION GAME_OF_JOINS.BI_Obtener_Id_Medio_Pago 

GO 

CREATE FUNCTION GAME_OF_JOINS.BI_Obtener_Id_Medio_Pago(@venta_medio_pago_modelo INT) 
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
			vmp.id = @venta_medio_pago_modelo
      
		SELECT
			@id_medio_pago = id_medio_pago
		FROM
			GAME_OF_JOINS.BI_medio_pago
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

------------------------------------------------
-------- Procedures para migracion -------------
------------------------------------------------

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

--medio_pago 
IF Object_id('GAME_OF_JOINS.BI_Migrar_Medio_Pago') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Migrar_Medio_Pago 

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Migrar_Medio_Pago 
AS 
    INSERT INTO GAME_OF_JOINS.BI_medio_pago 
                (descripcion) 
	SELECT
		DISTINCT mepa_medio_pago
	FROM
		GAME_OF_JOINS.medio_pago

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

GO


--venta
IF Object_id('GAME_OF_JOINS.BI_Migrar_Venta') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Migrar_Venta 

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Migrar_Venta
AS 
	INSERT INTO GAME_OF_JOINS.BI_venta
	(venta_codigo, total, valor_envio, mepa_costo, mepa_descuento, id_tiempo, id_cliente, id_provincia, id_canal, id_tipo_envio, id_medio_pago)

	SELECT
		v.vent_codigo,
		v.vent_total,
		ve.veen_precio,
		mp.vmep_costo,
		ISNULL((
		SELECT
			vd.vede_importe
		FROM
			GAME_OF_JOINS.venta v1
		INNER JOIN GAME_OF_JOINS.venta_descuento vd ON
			v1.vent_codigo = vd.vede_venta_codigo
		INNER JOIN GAME_OF_JOINS.descuento d ON
			vd.vede_descuento = d.descu_id
		WHERE
			v1.vent_codigo = v.vent_codigo
			AND d.descu_tipo = 'Medio Pago'),
		0) AS mepa_descuento,
		GAME_OF_JOINS.BI_Obtener_Id_Tiempo(v.vent_fecha) AS id_tiempo,
		GAME_OF_JOINS.BI_Obtener_Id_Cliente(v.vent_cliente) AS id_cliente,
		GAME_OF_JOINS.BI_Obtener_Id_Provincia(v.vent_cliente) AS id_provincia,
		GAME_OF_JOINS.BI_Obtener_Id_Canal(v.vent_codigo) AS id_canal,
		GAME_OF_JOINS.BI_Obtener_Id_Tipo_Envio(v.vent_codigo) AS id_tipo_envio,
		GAME_OF_JOINS.BI_Obtener_Id_Medio_Pago(v.vent_venta_medio_pago) AS id_medio_pago
	FROM
		GAME_OF_JOINS.venta v
	INNER JOIN GAME_OF_JOINS.venta_envio ve ON
		v.vent_codigo = ve.veen_venta_codigo
	INNER JOIN GAME_OF_JOINS.venta_medio_pago mp ON
		v.vent_venta_medio_pago = mp.vmep_id
GO 

--venta_descuento

IF Object_id('GAME_OF_JOINS.BI_Migrar_Venta_Descuento') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Migrar_Venta_Descuento 

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Migrar_Venta_Descuento 
AS 

	INSERT INTO GD2C2022.GAME_OF_JOINS.BI_venta_descuento
	(venta_codigo, id_tipo_descuento, importe)

	SELECT
		vd.vede_venta_codigo,
		GAME_OF_JOINS.BI_Obtener_Id_Tipo_Descuento(d.descu_tipo) AS id_tipo_descuento,
		vd.vede_importe
	FROM
		GAME_OF_JOINS.venta_descuento vd
	INNER JOIN GAME_OF_JOINS.descuento d ON
		vd.vede_descuento = d.descu_id
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

--producto_categoria 
IF Object_id('GAME_OF_JOINS.BI_Migrar_Producto_Categoria') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Migrar_Producto_Categoria 

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Migrar_Producto_Categoria
AS 
    INSERT INTO GAME_OF_JOINS.BI_producto_categoria
                (descripcion) 
	SELECT
		DISTINCT pcat_categoria
	FROM
		GAME_OF_JOINS.producto_categoria

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

--compra_producto 
IF Object_id('GAME_OF_JOINS.BI_Migrar_Compra_Producto') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Migrar_Compra_Producto 

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Migrar_Compra_Producto
AS 
    INSERT INTO GAME_OF_JOINS.BI_compra_producto
                (id_producto, precio_unitario, id_proveedor, cantidad, id_tiempo) 
	SELECT
		GAME_OF_JOINS.BI_Obtener_Id_Producto(cp.cpro_producto_codigo),
		cp.cpro_precio,
		GAME_OF_JOINS.BI_Obtener_Id_Proveedor(co.comp_proveedor_cuit),
		cp.cpro_cantidad,
		GAME_OF_JOINS.BI_Obtener_Id_Tiempo(co.comp_fecha)		
	FROM
		GAME_OF_JOINS.compra_producto cp
	INNER JOIN
		GAME_OF_JOINS.compra co
	ON	cp.cpro_compra_numero = co.comp_numero
GO

--compra
IF Object_id('GAME_OF_JOINS.BI_Migrar_Compra') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Migrar_Compra

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Migrar_Compra
AS 
    INSERT INTO GAME_OF_JOINS.BI_compra
                (total, id_proveedor, id_tiempo) 
	SELECT
		comp_total,
		GAME_OF_JOINS.BI_Obtener_Id_Proveedor(comp_proveedor_cuit),
		GAME_OF_JOINS.BI_Obtener_Id_Tiempo(comp_fecha)		
	FROM
		GAME_OF_JOINS.compra
GO

--venta producto
IF Object_id('GAME_OF_JOINS.BI_Migrar_Venta_Producto') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Migrar_Venta_Producto

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Migrar_Venta_Producto
AS 
    INSERT INTO GAME_OF_JOINS.BI_venta_producto
                (id_producto, id_categoria, precio, cantidad, id_tiempo, id_cliente) 
	SELECT
		GAME_OF_JOINS.BI_Obtener_Id_Producto(vp.vpro_producto_codigo),
		GAME_OF_JOINS.BI_Obtener_Id_Categoria(pc.pcat_categoria),
		vp.vpro_precio,
		vp.vpro_cantidad,
		GAME_OF_JOINS.BI_Obtener_Id_Tiempo(ve.vent_fecha),
		GAME_OF_JOINS.BI_Obtener_Id_Cliente(ve.vent_cliente)
	FROM
		GAME_OF_JOINS.venta_producto vp
	INNER JOIN
		GAME_OF_JOINS.venta ve
	ON	vp.vpro_venta_codigo = ve.vent_codigo
	INNER JOIN
		GAME_OF_JOINS.producto pr
	ON	vp.vpro_producto_codigo = pr.prod_codigo
	INNER JOIN
		GAME_OF_JOINS.producto_categoria pc
	ON
		pr.prod_categoria = pc.pcat_id
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


/*
 * 
 * Los 5 productos con mayor rentabilidad anual, con sus respectivos %
 * Se entiende por rentabilidad a los ingresos generados por el producto
 * (ventas) durante el periodo menos la inversión realizada en el producto
 * (compras) durante el periodo, todo esto sobre dichos ingresos.
 * Valor expresado en porcentaje.
 * Para simplificar, no es necesario tener en cuenta los descuentos aplicados.
 */ 

/*
 * Las 5 categorías de productos más vendidos por rango etario de clientes
 * por mes.
 */

/*
 * Total de Ingresos por cada medio de pago por mes, descontando los costos
 * por medio de pago (en caso que aplique) y descuentos por medio de pago
 * (en caso que aplique)
 */


/* 
 * Importe total en descuentos aplicados según su tipo de descuento, por
 * canal de venta, por mes. Se entiende por tipo de descuento como los
 * correspondientes a envío, medio de pago, cupones, etc)
 */

/*
 * Porcentaje de envíos realizados a cada Provincia por mes. El porcentaje
 * debe representar la cantidad de envíos realizados a cada provincia sobre
 * total de envío mensuales.
 */

/* 
 * Valor promedio de envío por Provincia por Medio De Envío anual.
 */

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
		MAX(precio_unitario) AS maximo,
		MIN(precio_unitario) AS minimo,
		(MAX(precio_unitario) - MIN(precio_unitario)) / MIN(precio_unitario) AS porcentaje_aumento
	FROM
		GAME_OF_JOINS.BI_compra_producto cp
	INNER JOIN GAME_OF_JOINS.BI_Proveedor p ON
		cp.id_proveedor = p.id_proveedor
	INNER JOIN GAME_OF_JOINS.BI_tiempo tie
		ON cp.id_tiempo = tie.id_tiempo
	GROUP BY
		tie.anio,
		p.cuit,
		cp.id_producto )
	SELECT
		anio,
		proveedor,
		AVG(porcentaje_aumento) AS aumento_promedio
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
		SUM(cp.cantidad) AS cantidad,
		ROW_NUMBER()
	    OVER (
	        PARTITION BY tie.mes
	        ORDER BY SUM(cp.cantidad) DESC
	    ) AS ranking 
	FROM
		GAME_OF_JOINS.BI_compra_producto cp
		INNER JOIN GAME_OF_JOINS.BI_tiempo tie ON
		cp.id_tiempo = tie.id_tiempo
		INNER JOIN GAME_OF_JOINS.BI_producto p
		ON cp.id_producto = p.id_producto
	GROUP BY
		p.codigo,
		p.descripcion,
		tie.anio,
		tie.mes
	)
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

EXEC GAME_OF_JOINS.BI_Migrar_Tiempo
EXEC GAME_OF_JOINS.BI_Migrar_Cliente
EXEC GAME_OF_JOINS.BI_Migrar_Canal
EXEC GAME_OF_JOINS.BI_Migrar_Producto
EXEC GAME_OF_JOINS.BI_Migrar_Producto_Categoria
EXEC GAME_OF_JOINS.BI_Migrar_Provincia
EXEC GAME_OF_JOINS.BI_Migrar_Proveedor
EXEC GAME_OF_JOINS.BI_Migrar_Medio_Pago
EXEC GAME_OF_JOINS.BI_Migrar_Tipo_Envio
EXEC GAME_OF_JOINS.BI_Migrar_Tipo_Descuento
EXEC GAME_OF_JOINS.BI_Migrar_Venta
EXEC GAME_OF_JOINS.BI_Migrar_Compra
EXEC GAME_OF_JOINS.BI_Migrar_Venta_Descuento
EXEC GAME_OF_JOINS.BI_Migrar_Venta_Producto
EXEC GAME_OF_JOINS.BI_Migrar_Compra_Producto

GO

------------------------------------------------
----------- Drop de Procedures -----------------
------------------------------------------------

EXEC GAME_OF_JOINS.BI_Drop_All_Procedures

GO

------------------------------------------------
--------------- Test Views ---------------------
------------------------------------------------

SELECT * FROM GAME_OF_JOINS.BI_VW_productos_mayor_reposicion ORDER BY mes, anio, cantidad DESC
SELECT * FROM GAME_OF_JOINS.BI_VW_aumento_promedio_proveedor ORDER BY anio ASC, proveedor ASC