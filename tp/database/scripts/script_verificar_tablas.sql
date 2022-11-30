USE GD2C2022

------------------------------------------------
-------- View Tablas Modelo Datos --------------
------------------------------------------------

IF Object_id('GAME_OF_JOINS.table_row_count') IS NOT NULL 
  DROP VIEW GAME_OF_JOINS.table_row_count
GO 

CREATE OR ALTER VIEW GAME_OF_JOINS.table_row_count
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
    GO 

SELECT * FROM GAME_OF_JOINS.table_row_count ORDER BY table_name ASC

DROP VIEW GAME_OF_JOINS.table_row_count