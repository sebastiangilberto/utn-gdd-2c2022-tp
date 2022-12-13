USE GD2C2022

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
               FROM  sys.tables 
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

IF Object_id('GAME_OF_JOINS.Drop_All_Procedures') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Drop_All_Procedures

GO 

CREATE PROCEDURE GAME_OF_JOINS.Drop_All_Procedures
AS 
    DECLARE @query nvarchar(255) 
    DECLARE query_cursor CURSOR FOR  
    SELECT 'DROP PROCEDURE GAME_OF_JOINS.' + name
               FROM  sys.procedures 
               WHERE schema_id = (SELECT schema_id FROM sys.schemas WHERE name = 'GAME_OF_JOINS') AND name LIKE 'Migrar_%'
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
               WHERE schema_id = (SELECT schema_id FROM sys.schemas WHERE name = 'GAME_OF_JOINS') AND (name LIKE 'BI_Obtener%' OR name LIKE 'BI_Migrar%')
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

IF Object_id('GAME_OF_JOINS.BI_Drop_All_Functions') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Drop_All_Functions

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Drop_All_Functions
AS 
    DECLARE @query nvarchar(255) 
    DECLARE query_cursor CURSOR FOR  
    SELECT 'DROP FUNCTION GAME_OF_JOINS.' + name
               FROM sys.sql_modules m
               INNER JOIN sys.objects o 
        	 	ON m.object_id = o.object_id
               WHERE type_desc like '%function%'
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


IF Object_id('GAME_OF_JOINS.BI_Drop_All_Views') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.BI_Drop_All_Views

GO 

CREATE PROCEDURE GAME_OF_JOINS.BI_Drop_All_Views
AS 
    DECLARE @query nvarchar(255) 
    DECLARE query_cursor CURSOR FOR  
    SELECT 'DROP VIEW GAME_OF_JOINS.' + name
               FROM sys.views
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

EXEC GAME_OF_JOINS.BI_Erase_All_Foreign_Keys

EXEC GAME_OF_JOINS.Erase_All_Foreign_Keys

EXEC GAME_OF_JOINS.BI_Drop_All_Tables

EXEC GAME_OF_JOINS.Drop_All_Tables

EXEC GAME_OF_JOINS.BI_Drop_All_Procedures

EXEC GAME_OF_JOINS.BI_Drop_All_Functions

EXEC GAME_OF_JOINS.BI_Drop_All_Views

EXEC GAME_OF_JOINS.Drop_All_Procedures

DROP PROCEDURE GAME_OF_JOINS.BI_Drop_All_Tables

DROP PROCEDURE GAME_OF_JOINS.Drop_All_Tables

DROP PROCEDURE GAME_OF_JOINS.BI_Erase_All_Foreign_Keys

DROP PROCEDURE GAME_OF_JOINS.Erase_All_Foreign_Keys

DROP PROCEDURE GAME_OF_JOINS.BI_Drop_All_Procedures

DROP PROCEDURE GAME_OF_JOINS.BI_Drop_All_Functions

DROP PROCEDURE GAME_OF_JOINS.BI_Drop_All_Views

DROP PROCEDURE GAME_OF_JOINS.Drop_All_Procedures

DROP SCHEMA GAME_OF_JOINS

GO