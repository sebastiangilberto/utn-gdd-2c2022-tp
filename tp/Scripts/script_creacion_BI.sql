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
	valor_envio DECIMAL(18,2) NOT NULL,
	mepa_costo DECIMAL(18,2) NOT NULL,
	mepa_descuento DECIMAL(18,2) NOT NULL,
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
	id_producto_categoria INT NOT NULL, --fk
	id_tiempo INT NOT NULL, --fk
	id_cliente INT NOT NULL, --fk
	precio DECIMAL(18,2) NOT NULL, --fk
	cantidad DECIMAL(18,2) NOT NULL, --fk
  )  

  
------------------------------------------------
------------- Definicion de FKs ----------------
------------------------------------------------

-- Regla para nombrar FKs: FK_BI_tabla_origen_nombre_campo 

------------------------------------------------
----------- Funciones auxiliares ---------------
------------------------------------------------

-- devuelve el rango etario en base a una fecha
IF Object_id('GAME_OF_JOINS.BI_Obtener_Rango_Edad') IS NOT NULL 
  DROP FUNCTION GAME_OF_JOINS.BI_Obtener_Rango_Edad 

GO 

CREATE FUNCTION GAME_OF_JOINS.BI_Obtener_Rango_Edad(@fecha_nacimiento DATE) 
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
		DISTINCT GAME_OF_JOINS.BI_obtener_rango_edad(clie_fecha_nac)
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

--venta_descuento
/*
IF Object_id('GAME_OF_JOINS.BI_Migrar_Venta_Descuento') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Migrar_Venta_Descuento 

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Migrar_Venta_Descuento 
AS 
    INSERT INTO GAME_OF_JOINS.BI_venta_descuento
                (id_venta, id_tipo_descuento, importe) 
	SELECT
		GAME_OF_JOINS.BI_Obtener_Id_Venta(vede_venta_codigo),
		GAME_OF_JOINS.BI_Obtener_Id_Tipo_Descuento(vede_descuento),
		GAME_OF_JOINS.BI_Obtener_Id_Tipo_Descuento(vede_descuento),
	FROM
		GAME_OF_JOINS.venta_descuento

GO
*/
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


--provincia 
/*
IF Object_id('GAME_OF_JOINS.BI_Migrar_Venta') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Migrar_Venta 

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Migrar_Venta
AS 
    INSERT INTO GAME_OF_JOINS.BI_venta
                (total, id_cliente, id_provincia, id_canal, id_tipo_envio, id_medio_pago) 
		
	SELECT
		v.vent_total,
		GAME_OF_JOINS.BI_Obtener_Id_Cliente(v.vent_cliente),
		GAME_OF_JOINS.BI_Obtener_Id_Provincia(v.vent_cliente),
		GAME_OF_JOINS.BI_Obtener_Id_Canal(v.vent_codigo),
		GAME_OF_JOINS.BI_Obtener_Id_Tipo_Envio(v.vent_codigo),
		GAME_OF_JOINS.BI_Obtener_Id_Medio_Pago(v.vent_venta_medio_pago),
	FROM
		GAME_OF_JOINS.venta v

GO 
*/
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

/*
 * Los 3 productos con mayor cantidad de reposición por mes. 
 */

------------------------------------------------
------------ Migracion de datos ----------------
------------------------------------------------

EXEC GAME_OF_JOINS.BI_Migrar_Tiempo
EXEC GAME_OF_JOINS.BI_Migrar_Cliente
EXEC GAME_OF_JOINS.BI_Migrar_Canal
--EXEC GAME_OF_JOINS.BI_Migrar_Producto
EXEC GAME_OF_JOINS.BI_Migrar_Producto_Categoria
EXEC GAME_OF_JOINS.BI_Migrar_Provincia
EXEC GAME_OF_JOINS.BI_Migrar_Proveedor
EXEC GAME_OF_JOINS.BI_Migrar_Medio_Pago
EXEC GAME_OF_JOINS.BI_Migrar_Tipo_Envio
EXEC GAME_OF_JOINS.BI_Migrar_Tipo_Descuento
--EXEC GAME_OF_JOINS.BI_Migrar_Venta
--EXEC GAME_OF_JOINS.BI_Migrar_Compra
--EXEC GAME_OF_JOINS.BI_Migrar_Venta_Producto
--EXEC GAME_OF_JOINS.BI_Migrar_Compra_Producto

GO

------------------------------------------------
----------- Drop de Procedures -----------------
------------------------------------------------

EXEC GAME_OF_JOINS.BI_Drop_All_Procedures

GO

------------------------------------------------
------------------ Tests -----------------------
------------------------------------------------

IF Object_id('GAME_OF_JOINS.BI_table_row_count') IS NOT NULL 
  DROP VIEW GAME_OF_JOINS.BI_table_row_count
GO 

CREATE OR ALTER VIEW GAME_OF_JOINS.BI_table_row_count
AS
	SELECT
		o.NAME as table_name,
		i.rowcnt as row_count
	FROM
		sysindexes AS i
	INNER JOIN sysobjects AS o ON
		i.id = o.id
	WHERE
		i.indid < 2
		AND OBJECTPROPERTY(o.id,
		'IsMSShipped') = 0
		AND o.name LIKE 'BI_%'
GO 

--SELECT * FROM GAME_OF_JOINS.BI_table_row_count ORDER BY table_name ASC

DROP VIEW GAME_OF_JOINS.BI_table_row_count
