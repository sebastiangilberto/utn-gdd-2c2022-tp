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

------------------------------------------------
----------- Funciones auxiliares ---------------
------------------------------------------------

IF Object_id('GAME_OF_JOINS.BI_Get_Date_Range') IS NOT NULL 
  DROP FUNCTION GAME_OF_JOINS.BI_Get_Date_Range 

GO 

CREATE FUNCTION GAME_OF_JOINS.Bi_get_date_range(@fecha_nacimiento DATE) 
RETURNS NVARCHAR(255) 
AS 
  BEGIN 
      DECLARE @edad AS INT = 0 

      SET @edad = Datediff(year, @fecha_nacimiento, Getdate()) 

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


------------------------------------------------
----------- Drop de Procedures -----------------
------------------------------------------------

EXEC GAME_OF_JOINS.BI_Drop_All_Procedures

GO

------------------------------------------------
------------------ Tests -----------------------
------------------------------------------------
