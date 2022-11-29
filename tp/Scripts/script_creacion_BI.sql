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

CREATE TABLE GAME_OF_JOINS.BI_tiempo 
  ( 
	 tiem_id INT PRIMARY KEY IDENTITY(1, 1), 
     tiem_anio INT,
	 tiem_mes  INT,
  )
  
CREATE TABLE GAME_OF_JOINS.BI_provincia
  (
	 prov_id INT PRIMARY KEY IDENTITY(1, 1), 
     prov_descripcion NVARCHAR(255),
  )
  
CREATE TABLE GAME_OF_JOINS.BI_cliente 
  ( 
     clie_codigo INT PRIMARY KEY IDENTITY(1, 1), 
     clie_edad        NVARCHAR(255),
  ) 

CREATE TABLE GAME_OF_JOINS.BI_proveedor 
  ( 
     prove_cuit NVARCHAR(50) PRIMARY KEY, --pk
  ) 
  
CREATE TABLE GAME_OF_JOINS.BI_canal
  (
	 prov_id INT PRIMARY KEY IDENTITY(1, 1), 
     prov_descripcion NVARCHAR(255),
  )
  
CREATE TABLE GAME_OF_JOINS.BI_medio_pago
  (
	 mepa_id INT PRIMARY KEY IDENTITY(1, 1), 
     mepa_descripcion NVARCHAR(255),
  )
  
CREATE TABLE GAME_OF_JOINS.BI_producto_categoria
  (
	 cate_id INT PRIMARY KEY IDENTITY(1, 1), 
     cate_descripcion NVARCHAR(255),
  )
  
CREATE TABLE GAME_OF_JOINS.BI_producto
  (
	 prod_id INT PRIMARY KEY IDENTITY(1, 1), 
     prod_descripcion NVARCHAR(255),
  )
  
CREATE TABLE GAME_OF_JOINS.BI_tipo_descuento
  (
	 descu_id INT PRIMARY KEY IDENTITY(1, 1), 
     descu_descripcion NVARCHAR(255),
  )
  
CREATE TABLE GAME_OF_JOINS.BI_tipo_envio
  (
	 env_id INT PRIMARY KEY IDENTITY(1, 1), 
     env_descripcion NVARCHAR(255),
  )
  
CREATE TABLE GAME_OF_JOINS.BI_ventas
  (
	vent_codigo -- pk
	vent_total
	vent_tiempo --fk
	vent_cliente --fk
	vent_provincia --fk
	vent_canal --fk
	vent_producto --fk
	vent_producto_categoria --fk
	vent_tipo_descuento --fk
	vent_tipo_envio --fk
	vent_medio_pago --fk
  )  
  
CREATE TABLE GAME_OF_JOINS.BI_compras
  (
	comp_codigo --pk
	comp_total
	comp_tiempo --fk
	comp_proveedor --fk
	comp_medio_pago --fk
  )  

  
------------------------------------------------
------------- Definicion de FKs ----------------
------------------------------------------------

-- Regla para nombrar FKs: FK_BI_tabla_origen_nombre_campo 

------------------------------------------------
----------- Funciones auxiliares ---------------
------------------------------------------------

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
                (edad) 
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
                (cana_descripcion) 
	SELECT
		DISTINCT cana_canal
	FROM
		GAME_OF_JOINS.canal

GO 

--proveedor 
IF Object_id('GAME_OF_JOINS.BI_Migrar_Proveedor') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Migrar_Proveedor 

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Migrar_Proveedor 
AS 
    INSERT INTO GAME_OF_JOINS.BI_proveedor 
                (prove_cuit) 
	SELECT
		DISTINCT prove_cuit
	FROM
		GAME_OF_JOINS.proveedor

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

/*
 * Los 3 productos con mayor cantidad de reposición por mes. 
 */

------------------------------------------------
------------ Migracion de datos ----------------
------------------------------------------------

EXEC GAME_OF_JOINS.BI_Migrar_Tiempo
EXEC GAME_OF_JOINS.BI_Migrar_Cliente
EXEC GAME_OF_JOINS.BI_Migrar_Canal
EXEC GAME_OF_JOINS.BI_Migrar_Proveedor

GO

------------------------------------------------
----------- Drop de Procedures -----------------
------------------------------------------------

EXEC GAME_OF_JOINS.BI_Drop_All_Procedures

GO

------------------------------------------------
------------------ Tests -----------------------
------------------------------------------------
