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

------------------------------------------------
------------ Drop de FKs y Tablas --------------
------------------------------------------------

EXEC GAME_OF_JOINS.Erase_All_Foreign_Keys
EXEC GAME_OF_JOINS.Drop_All_Tables
EXEC GAME_OF_JOINS.Drop_All_Procedures

GO

------------------------------------------------
------------ Definicion de datos ---------------
------------------------------------------------

CREATE TABLE GAME_OF_JOINS.venta
  ( 
     vent_codigo DECIMAL(19,0) PRIMARY KEY, 
     vent_fecha    DATETIME2, 
     vent_cliente INT, --fk
     vent_total     DECIMAL(18,2), 
     vent_venta_medio_pago   INT,  --fk
  )  

CREATE TABLE GAME_OF_JOINS.venta_medio_pago 
  ( 
     vmep_id       INT IDENTITY(1,1) PRIMARY KEY, 
     vmep_costo     DECIMAL(18,2),
     vmep_medio_pago    INT, --fk
  ) 

CREATE TABLE GAME_OF_JOINS.medio_pago 
  ( 
     mepa_id     INT IDENTITY(1,1) PRIMARY KEY, 
     mepa_descuento DECIMAL(18,2), 
     mepa_medio_pago  nvarchar(255), 
	 mepa_precio_actual  DECIMAL(18,2), 
  ) 


CREATE TABLE GAME_OF_JOINS.venta_descuento 
  ( 
     vede_id     INT IDENTITY(1,1) PRIMARY KEY, 
     vede_venta_codigo  DECIMAL(19,0), --fk
     vede_importe   DECIMAL(18,2),
	 vede_descuento   INT, --fk
  ) 

CREATE TABLE GAME_OF_JOINS.venta_canal 
  ( 
     veca_id     INT IDENTITY(1,1) PRIMARY KEY, 
     veca_venta_codigo  DECIMAL(19,0), --fk
     veca_canal  INT,  --fk
     veca_costo DECIMAL(18,2), 
  ) 

CREATE TABLE GAME_OF_JOINS.venta_cupon 
  ( 
     vecu_venta_codigo DECIMAL(19,0) NOT NULL, --fk
     vecu_codigo     nvarchar(255) NOT NULL,   --fk
     vecu_importe   DECIMAL(18,2),
  ) 

CREATE TABLE GAME_OF_JOINS.cliente
  ( 
  	 clie_id INT IDENTITY(1,1) PRIMARY KEY,
     clie_dni DECIMAL(18,0), 
     clie_apellido nvarchar(255), 
     clie_nombre         nvarchar(255), 
     clie_direccion    nvarchar(255), 
     clie_telefono       DECIMAL(18,0), 
     clie_mail       nvarchar(255), 
     clie_fecha_nac       DATETIME2, 
     clie_codigo_postal       INT,  --fk
  ) 

CREATE TABLE GAME_OF_JOINS.cupon 
  ( 
     cupo_codigo      nvarchar(255) PRIMARY KEY, 
     cupo_fecha_desde         DATETIME2, 
     cupo_fecha_hasta         DATETIME2, 
     cupo_valor        DECIMAL(18,2), 
     cupo_tipo INT,  --fk
  ) 

CREATE TABLE GAME_OF_JOINS.cupon_tipo
  ( 
     cuti_id      INT IDENTITY(1,1) PRIMARY KEY, 
     cuti_tipo nvarchar(50), 
  ) 

CREATE TABLE GAME_OF_JOINS.canal
  ( 
     cana_id      INT IDENTITY(1, 1) PRIMARY KEY, 
     cana_canal nvarchar(255), 
	 cana_precio_actual DECIMAL(18,2),
  ) 

CREATE TABLE GAME_OF_JOINS.descuento
  ( 
     descu_id      INT IDENTITY(1,1) PRIMARY KEY, 
     descu_tipo nvarchar(255),
  ) 
  
CREATE TABLE GAME_OF_JOINS.variante
  ( 
     vari_id      INT IDENTITY(1,1) PRIMARY KEY, 
     vari_variante nvarchar(50), 
     vari_tipo    INT, --fk
  ) 

CREATE TABLE GAME_OF_JOINS.variante_tipo
  ( 
     vati_id      INT IDENTITY(1,1) PRIMARY KEY, 
     vati_tipo    nvarchar(50), 
  ) 

CREATE TABLE GAME_OF_JOINS.venta_envio
  ( 
     veen_id      INT IDENTITY(1,1) PRIMARY KEY, 
     veen_venta_codigo DECIMAL(19,0),  --fk
     veen_precio    DECIMAL(18,2), 
     veen_medio_habilitado      INT,  --fk
  ) 

CREATE TABLE GAME_OF_JOINS.medio_envio_habilitado
  ( 
     menh_id      INT IDENTITY(1,1) PRIMARY KEY, 
     menh_medio_envio INT,  --fk
     menh_codigo_postal    INT,  --fk
     menh_precio_actual      DECIMAL(18,2), 
	 menh_tiempo_estimado_envio		   DECIMAL(19,0)
  ) 

CREATE TABLE GAME_OF_JOINS.codigo_postal
  ( 
     copo_id INT IDENTITY(1,1) PRIMARY KEY,
     copo_codigo_postal      DECIMAL(18,0), 
     copo_localidad INT,  --fk
  ) 

CREATE TABLE GAME_OF_JOINS.localidad
  ( 
     loca_id      INT IDENTITY(1,1) PRIMARY KEY, 
     loca_localidad nvarchar(255), 
     loca_provincia    INT,  --fk
  ) 

CREATE TABLE GAME_OF_JOINS.provincia
  ( 
     prov_id      INT IDENTITY(1,1) PRIMARY KEY, 
     prov_provincia nvarchar(255), 
  ) 

CREATE TABLE GAME_OF_JOINS.medio_envio 
  ( 
     menv_id INT IDENTITY(1,1) PRIMARY KEY,
	 menv_medio_envio nvarchar(255),
  ) 

CREATE TABLE GAME_OF_JOINS.producto_material 
  ( 
	 pmat_id INT IDENTITY(1,1) PRIMARY KEY,
     pmat_material    nvarchar(50),  
  ) 

CREATE TABLE GAME_OF_JOINS.producto_marca 
  ( 
	 pmar_id INT IDENTITY(1,1) PRIMARY KEY,
     pmar_marca    nvarchar(255), 
  ) 

CREATE TABLE GAME_OF_JOINS.producto_categoria
  ( 
     pcat_id      INT IDENTITY(1,1) PRIMARY KEY, 
     pcat_categoria nvarchar(255), 
  ) 

CREATE TABLE GAME_OF_JOINS.venta_producto 
  ( 
	 vpro_id INT IDENTITY(1,1) PRIMARY KEY,
     vpro_producto_codigo    nvarchar(50),  --fk
	 vpro_venta_codigo   DECIMAL(19,0), --fk
     vpro_producto_variante_codigo    nvarchar(50),  --fk
     vpro_cantidad    DECIMAL(18,0), 
     vpro_precio    DECIMAL(18,2), 
     vpro_total    DECIMAL(18,2), 
  ) 

CREATE TABLE GAME_OF_JOINS.producto_variante 
  ( 
	 pvar_codigo nvarchar(50) PRIMARY KEY,
     pvar_producto_codigo    nvarchar(50),  --fk
	 pvar_variante   INT, --fk
     pvar_precio_actual    DECIMAL(18,2),
     pvar_stock INT NOT NULL, 
  ) 

CREATE TABLE GAME_OF_JOINS.compra_producto
  ( 
	 cpro_id INT IDENTITY(1,1) PRIMARY KEY,
     cpro_producto_codigo    nvarchar(50),  --fk
	 cpro_compra_numero   DECIMAL(19,0), --fk
     cpro_producto_variante_codigo    nvarchar(50),  --fk
     cpro_cantidad    DECIMAL(18,2), 
     cpro_precio    DECIMAL(18,2), 
     cpro_total    DECIMAL(18,2), 
  ) 

CREATE TABLE GAME_OF_JOINS.compra_descuento 
  ( 
	 code_id INT IDENTITY(1,1) PRIMARY KEY,
     code_compra_numero    DECIMAL(19,0),  --fk
	 code_valor   DECIMAL(18,2),
     code_codigo    DECIMAL(19,0), 
  ) 

CREATE TABLE GAME_OF_JOINS.compra
  ( 
	 comp_numero DECIMAL(19,0) PRIMARY KEY,
     comp_fecha    DATETIME2, 
	 comp_proveedor_cuit   nvarchar(50), --fk
     comp_medio_pago   INT, --fk
     comp_total    DECIMAL(18,2), 
  ) 

CREATE TABLE GAME_OF_JOINS.compra_medio_pago 
  ( 
	 cmep_id INT IDENTITY(1,1) PRIMARY KEY,
     cmep_medio_pago    nvarchar(255), 
  ) 

CREATE TABLE GAME_OF_JOINS.producto 
  ( 
	 prod_codigo nvarchar(50) PRIMARY KEY,
     prod_nombre    nvarchar(50), 
	 prod_descripcion   nvarchar(50),
     prod_categoria    INT,  --fk
     prod_marca    INT,  --fk
     prod_material    INT,  --fk
  ) 

CREATE TABLE GAME_OF_JOINS.proveedor
  ( 
	 prove_cuit nvarchar(50) PRIMARY KEY,
     prove_razon_social   nvarchar(50), 
	 prove_domicilio   nvarchar(50),
     prove_mail    nvarchar(50), 
     prove_codigo_postal    INT,  --fk
  ) 

------------------------------------------------
------------- Definicion de FKs ----------------
------------------------------------------------

-- Regla para nombrar FKs: FK_tabla_origen_nombre_campo 

--venta 
ALTER TABLE GAME_OF_JOINS.venta 
  ADD CONSTRAINT fk_venta_vent_cliente FOREIGN KEY (vent_cliente) REFERENCES GAME_OF_JOINS.cliente(clie_id) 

ALTER TABLE GAME_OF_JOINS.venta 
  ADD CONSTRAINT fk_venta_vent_venta_medio_pago FOREIGN KEY (vent_venta_medio_pago) REFERENCES GAME_OF_JOINS.venta_medio_pago(vmep_id) 

GO

--venta_medio_pago 
ALTER TABLE GAME_OF_JOINS.venta_medio_pago 
  ADD CONSTRAINT fk_venta_medio_pago_vmep_medio_pago FOREIGN KEY (vmep_medio_pago) REFERENCES GAME_OF_JOINS.medio_pago(mepa_id)

GO

--venta_descuento 
ALTER TABLE GAME_OF_JOINS.venta_descuento 
  ADD CONSTRAINT fk_venta_descuento_vede_venta_codigo FOREIGN KEY (vede_venta_codigo) REFERENCES GAME_OF_JOINS.venta(vent_codigo)

ALTER TABLE GAME_OF_JOINS.venta_descuento 
  ADD CONSTRAINT fk_venta_descuento_vede_descuento FOREIGN KEY (vede_descuento) REFERENCES GAME_OF_JOINS.descuento(descu_id)

GO

--venta_canal 
ALTER TABLE GAME_OF_JOINS.venta_canal 
  ADD CONSTRAINT fk_venta_canal_veca_venta_codigo FOREIGN KEY (veca_venta_codigo) REFERENCES GAME_OF_JOINS.venta(vent_codigo)

ALTER TABLE GAME_OF_JOINS.venta_canal 
  ADD CONSTRAINT fk_venta_canal_veca_canal FOREIGN KEY (veca_canal) REFERENCES GAME_OF_JOINS.canal(cana_id)

GO

--venta_cupon 
ALTER TABLE GAME_OF_JOINS.venta_cupon 
  ADD CONSTRAINT pk_venta_cupon  PRIMARY KEY (vecu_venta_codigo, vecu_codigo)

ALTER TABLE GAME_OF_JOINS.venta_cupon 
  ADD CONSTRAINT fk_venta_cupon_vecu_venta_codigo FOREIGN KEY (vecu_venta_codigo) REFERENCES GAME_OF_JOINS.venta(vent_codigo)

ALTER TABLE GAME_OF_JOINS.venta_cupon 
  ADD CONSTRAINT fk_venta_cupon_vecu_codigo FOREIGN KEY (vecu_codigo) REFERENCES GAME_OF_JOINS.cupon(cupo_codigo)

GO

--cliente
ALTER TABLE GAME_OF_JOINS.cliente
  ADD CONSTRAINT fk_cliente_clie_codigo_postal FOREIGN KEY (clie_codigo_postal) REFERENCES GAME_OF_JOINS.codigo_postal(copo_id) 

GO

--cupon
ALTER TABLE GAME_OF_JOINS.cupon 
  ADD CONSTRAINT fk_cupon_cupo_tipo FOREIGN KEY (cupo_tipo) REFERENCES GAME_OF_JOINS.cupon_tipo(cuti_id)

GO

--venta_envio
ALTER TABLE GAME_OF_JOINS.venta_envio 
  ADD CONSTRAINT fk_venta_envio_veen_venta_codigo FOREIGN KEY (veen_venta_codigo) REFERENCES GAME_OF_JOINS.venta(vent_codigo) 

ALTER TABLE GAME_OF_JOINS.venta_envio
  ADD CONSTRAINT fk_venta_envio_veen_medio_habilitado FOREIGN KEY (veen_medio_habilitado) REFERENCES GAME_OF_JOINS.medio_envio_habilitado(menh_id)

GO

--medio_envio_habilitado
ALTER TABLE GAME_OF_JOINS.medio_envio_habilitado 
  ADD CONSTRAINT fk_medio_envio_habilitado_menh_medio_envio FOREIGN KEY (menh_medio_envio) REFERENCES GAME_OF_JOINS.medio_envio(menv_id)

ALTER TABLE GAME_OF_JOINS.medio_envio_habilitado
  ADD CONSTRAINT fk_medio_envio_habilitado_menh_codigo_postal FOREIGN KEY (menh_codigo_postal) REFERENCES GAME_OF_JOINS.codigo_postal(copo_id)

GO

--codigo_postal
ALTER TABLE GAME_OF_JOINS.codigo_postal 
  ADD CONSTRAINT fk_codigo_postal_copo_localidad FOREIGN KEY (copo_localidad) REFERENCES GAME_OF_JOINS.localidad(loca_id) 

GO

--localidad
ALTER TABLE GAME_OF_JOINS.localidad 
  ADD CONSTRAINT fk_localidad_loca_provincia FOREIGN KEY (loca_provincia) REFERENCES GAME_OF_JOINS.provincia(prov_id) 

GO

--venta_producto
ALTER TABLE GAME_OF_JOINS.venta_producto
  ADD CONSTRAINT fk_venta_producto_vpro_producto_codigo FOREIGN KEY (vpro_producto_codigo) REFERENCES GAME_OF_JOINS.producto(prod_codigo) 

ALTER TABLE GAME_OF_JOINS.venta_producto 
  ADD CONSTRAINT fk_venta_producto_vpro_venta_codigo FOREIGN KEY (vpro_venta_codigo) REFERENCES GAME_OF_JOINS.venta(vent_codigo) 

ALTER TABLE GAME_OF_JOINS.venta_producto 
  ADD CONSTRAINT fk_venta_producto_vpro_producto_variante_codigo FOREIGN KEY (vpro_producto_variante_codigo) REFERENCES GAME_OF_JOINS.producto_variante(pvar_codigo) 

GO

--producto_variante
ALTER TABLE GAME_OF_JOINS.producto_variante 
  ADD CONSTRAINT fk_producto_variante_pvar_producto_codigo FOREIGN KEY (pvar_producto_codigo) REFERENCES GAME_OF_JOINS.producto(prod_codigo) 

ALTER TABLE GAME_OF_JOINS.producto_variante 
  ADD CONSTRAINT fk_producto_variante_pvar_variante FOREIGN KEY (pvar_variante) REFERENCES GAME_OF_JOINS.variante(vari_id) 

GO

--variante
ALTER TABLE GAME_OF_JOINS.variante 
  ADD CONSTRAINT fk_variante_vari_tipo FOREIGN KEY (vari_tipo) REFERENCES GAME_OF_JOINS.variante_tipo(vati_id) 

GO

--compra_producto
ALTER TABLE GAME_OF_JOINS.compra_producto 
  ADD CONSTRAINT fk_compra_producto_cpro_producto_codigo FOREIGN KEY (cpro_producto_codigo) REFERENCES GAME_OF_JOINS.producto(prod_codigo) 

ALTER TABLE GAME_OF_JOINS.compra_producto 
  ADD CONSTRAINT fk_compra_producto_cpro_compra_numero FOREIGN KEY (cpro_compra_numero) REFERENCES GAME_OF_JOINS.compra(comp_numero) 

ALTER TABLE GAME_OF_JOINS.compra_producto 
  ADD CONSTRAINT fk_compra_producto_cpro_producto_variante_codigo FOREIGN KEY (cpro_producto_variante_codigo) REFERENCES GAME_OF_JOINS.producto_variante(pvar_codigo) 

GO

--compra_descuento
ALTER TABLE GAME_OF_JOINS.compra_descuento 
  ADD CONSTRAINT fk_compra_descuento_code_compra_numero FOREIGN KEY (code_compra_numero) REFERENCES GAME_OF_JOINS.compra(comp_numero) 

GO

--compra
ALTER TABLE GAME_OF_JOINS.compra 
  ADD CONSTRAINT fk_compra_comp_proveedor_cuit FOREIGN KEY (comp_proveedor_cuit) REFERENCES GAME_OF_JOINS.proveedor(prove_cuit) 

ALTER TABLE GAME_OF_JOINS.compra 
  ADD CONSTRAINT fk_compra_comp_medio_pago FOREIGN KEY (comp_medio_pago) REFERENCES GAME_OF_JOINS.compra_medio_pago(cmep_id) 

GO

--producto
ALTER TABLE GAME_OF_JOINS.producto 
  ADD CONSTRAINT fk_producto_prod_categoria FOREIGN KEY (prod_categoria) REFERENCES GAME_OF_JOINS.producto_categoria(pcat_id) 

ALTER TABLE GAME_OF_JOINS.producto 
  ADD CONSTRAINT fk_producto_prod_marca FOREIGN KEY (prod_marca) REFERENCES GAME_OF_JOINS.producto_marca(pmar_id) 

ALTER TABLE GAME_OF_JOINS.producto 
  ADD CONSTRAINT fk_producto_prod_material FOREIGN KEY (prod_material) REFERENCES GAME_OF_JOINS.producto_material(pmat_id) 

GO

--proveedor
ALTER TABLE GAME_OF_JOINS.proveedor 
  ADD CONSTRAINT fk_proveedor_prove_codigo_postal FOREIGN KEY (prove_codigo_postal) REFERENCES GAME_OF_JOINS.codigo_postal(copo_id) 

GO

------------------------------------------------
-------- Procedures para migracion -------------
------------------------------------------------

--canal 
IF Object_id('GAME_OF_JOINS.Migrar_Canal') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Canal 
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Canal 
AS 
    INSERT INTO GAME_OF_JOINS.canal 
                (cana_canal, cana_precio_actual) 
	SELECT
		DISTINCT VENTA_CANAL,
		VENTA_CANAL_COSTO
	FROM
		gd_esquema.Maestra
	WHERE
		VENTA_CANAL IS NOT NULL

GO

--producto_categoria
IF Object_id('GAME_OF_JOINS.Migrar_Producto_Categoria') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Producto_Categoria 
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Producto_Categoria 
AS 
    INSERT INTO GAME_OF_JOINS.producto_categoria 
                (pcat_categoria)
	SELECT
		DISTINCT PRODUCTO_CATEGORIA
	FROM
		gd_esquema.maestra
	WHERE
		PRODUCTO_CATEGORIA IS NOT NULL

GO

--cliente
IF Object_id('GAME_OF_JOINS.Migrar_Cliente') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Cliente 
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Cliente 
AS 
    INSERT INTO GAME_OF_JOINS.cliente 
                (clie_dni,
                clie_apellido,
                clie_nombre,
                clie_direccion,
                clie_telefono,
                clie_mail,
                clie_fecha_nac,
                clie_codigo_postal
                ) 
	SELECT
		DISTINCT m.CLIENTE_DNI,
		m.CLIENTE_APELLIDO,
		m.CLIENTE_NOMBRE,
		m.CLIENTE_DIRECCION,
		m.CLIENTE_TELEFONO,
		m.CLIENTE_MAIL,
		m.CLIENTE_FECHA_NAC,
		cp.copo_id
	FROM
		gd_esquema.maestra m
	INNER JOIN GAME_OF_JOINS.provincia p ON
		p.prov_provincia = m.CLIENTE_PROVINCIA
	INNER JOIN GAME_OF_JOINS.localidad l ON
		l.loca_localidad = m.CLIENTE_LOCALIDAD
		AND l.loca_provincia = p.prov_id
	INNER JOIN GAME_OF_JOINS.codigo_postal cp ON
		cp.copo_localidad = l.loca_id
		AND cp.copo_codigo_postal = m.CLIENTE_CODIGO_POSTAL
	WHERE
		m.CLIENTE_DNI IS NOT NULL

GO

--codigo_postal
IF Object_id('GAME_OF_JOINS.Migrar_Codigo_Postal') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Codigo_Postal 
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Codigo_Postal 
AS 
    INSERT INTO GAME_OF_JOINS.codigo_postal 
                (copo_codigo_postal,
                copo_localidad
                )
    (
	SELECT
		DISTINCT m.CLIENTE_CODIGO_POSTAL,
		l.loca_id
	FROM
		gd_esquema.maestra m
	INNER JOIN GAME_OF_JOINS.localidad l ON
		m.CLIENTE_LOCALIDAD = l.loca_localidad
	WHERE
		m.CLIENTE_CODIGO_POSTAL IS NOT NULL
	UNION
	SELECT
		DISTINCT m.PROVEEDOR_CODIGO_POSTAL,
		l.loca_id
	FROM
		gd_esquema.maestra m
	INNER JOIN GAME_OF_JOINS.localidad l ON
		m.PROVEEDOR_LOCALIDAD = l.loca_localidad
	WHERE
		m.PROVEEDOR_CODIGO_POSTAL IS NOT NULL
	)

GO

--compra
IF Object_id('GAME_OF_JOINS.Migrar_Compra') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Compra 
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Compra 
AS 
    INSERT INTO GAME_OF_JOINS.compra
                (comp_numero, comp_fecha, comp_proveedor_cuit, comp_medio_pago, comp_total) 
	SELECT
		DISTINCT m.COMPRA_NUMERO,
		m.COMPRA_FECHA,
		m.PROVEEDOR_CUIT,
		cmp.cmep_id,
		m.COMPRA_TOTAL
	FROM
		gd_esquema.maestra m
	INNER JOIN GAME_OF_JOINS.compra_medio_pago cmp ON
		cmp.cmep_medio_pago = m.COMPRA_MEDIO_PAGO
	WHERE
		m.COMPRA_NUMERO IS NOT NULL

GO

--compra_descuento
IF Object_id('GAME_OF_JOINS.Migrar_Compra_Descuento') IS NOT NULL
	DROP PROCEDURE GAME_OF_JOINS.Migrar_Compra_Descuento
GO 
CREATE PROCEDURE GAME_OF_JOINS.Migrar_Compra_Descuento
AS
	INSERT
		INTO
		GAME_OF_JOINS.compra_descuento (code_compra_numero, code_valor, code_codigo)
		
	SELECT
		DISTINCT COMPRA_NUMERO,
		DESCUENTO_COMPRA_VALOR,
		DESCUENTO_COMPRA_CODIGO
	FROM
		gd_esquema.maestra
	WHERE
		COMPRA_NUMERO IS NOT NULL
		AND DESCUENTO_COMPRA_CODIGO IS NOT NULL
GO

--compra_medio_pago
IF Object_id('GAME_OF_JOINS.Migrar_Compra_Medio_Pago') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Compra_Medio_Pago 
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Compra_Medio_Pago 
AS 
    INSERT INTO GAME_OF_JOINS.compra_medio_pago 
                (cmep_medio_pago) 
	SELECT
		DISTINCT COMPRA_MEDIO_PAGO
	FROM
		gd_esquema.Maestra
	WHERE
		COMPRA_MEDIO_PAGO IS NOT NULL

GO

--cupon
IF Object_id('GAME_OF_JOINS.Migrar_Cupon') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Cupon 
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Cupon
AS 
    INSERT INTO GAME_OF_JOINS.cupon
                (cupo_codigo, cupo_fecha_desde, cupo_fecha_hasta, cupo_valor, cupo_tipo) 
	(	
		SELECT		DISTINCT 
					m.VENTA_CUPON_CODIGO,
					m.VENTA_CUPON_FECHA_DESDE,
					m.VENTA_CUPON_FECHA_HASTA,
					m.VENTA_CUPON_VALOR,
					ct.cuti_id
		FROM		gd_esquema.Maestra M
		INNER JOIN	GAME_OF_JOINS.cupon_tipo ct
		ON			m.VENTA_CUPON_TIPO = ct.cuti_tipo
	)

GO

--descuento
IF Object_id('GAME_OF_JOINS.Migrar_Descuento') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Descuento 
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Descuento
AS 
    INSERT INTO GAME_OF_JOINS.descuento
                (descu_tipo) 
	SELECT
		'Medio Pago'
	UNION
	SELECT
		'Envio Gratis'
	UNION
	SELECT
		'Especial'
GO

--localidad
IF Object_id('GAME_OF_JOINS.Migrar_Localidad') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Localidad 
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Localidad 
AS 
    INSERT INTO GAME_OF_JOINS.localidad 
                (loca_localidad,
                loca_provincia
                )
	SELECT
		DISTINCT m.PROVEEDOR_LOCALIDAD,
		p.prov_id
	FROM
		gd_esquema.maestra m
	INNER JOIN GAME_OF_JOINS.provincia p ON
		m.PROVEEDOR_PROVINCIA = p.prov_provincia
	WHERE
		PROVEEDOR_LOCALIDAD IS NOT NULL
	UNION
	SELECT
		DISTINCT CLIENTE_LOCALIDAD,
		p.prov_id
	FROM
		gd_esquema.maestra m
	INNER JOIN GAME_OF_JOINS.provincia p ON
		m.CLIENTE_PROVINCIA = p.prov_provincia
	WHERE
		CLIENTE_LOCALIDAD IS NOT NULL

GO

--medio_envio_habilitado
IF Object_id('GAME_OF_JOINS.Migrar_Medio_Envio_Habilitado') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Medio_Envio_Habilitado 
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Medio_Envio_Habilitado
AS 
    INSERT INTO GAME_OF_JOINS.medio_envio_habilitado
                (menh_medio_envio, menh_codigo_postal, menh_precio_actual, menh_tiempo_estimado_envio) 
	SELECT
		DISTINCT me.menv_id,
		cp.copo_id as codigo_postal,
		MAX(m.VENTA_ENVIO_PRECIO) as precio_actual,
		1 as tiempo_estimado_envio
	FROM
		gd_esquema.maestra m
	INNER JOIN GAME_OF_JOINS.medio_envio me ON
		me.menv_medio_envio = m.VENTA_MEDIO_ENVIO
	INNER JOIN GAME_OF_JOINS.provincia p ON
		p.prov_provincia = m.CLIENTE_PROVINCIA
	INNER JOIN GAME_OF_JOINS.localidad l ON
		l.loca_localidad = m.CLIENTE_LOCALIDAD
		AND l.loca_provincia = p.prov_id
	INNER JOIN GAME_OF_JOINS.codigo_postal cp ON
		cp.copo_localidad = l.loca_id
		AND cp.copo_codigo_postal = m.CLIENTE_CODIGO_POSTAL
	WHERE
		m.VENTA_MEDIO_ENVIO IS NOT NULL
	GROUP BY 
		me.menv_id, cp.copo_id
GO
	
--medio_pago
IF Object_id('GAME_OF_JOINS.Migrar_Medio_Pago') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Medio_Pago 
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Medio_Pago
AS 
    INSERT INTO GAME_OF_JOINS.medio_pago
                (mepa_descuento, mepa_medio_pago, mepa_precio_actual) 
	SELECT
		DISTINCT 0,
		VENTA_MEDIO_PAGO,
		VENTA_MEDIO_PAGO_COSTO
	FROM
		gd_esquema.Maestra
	WHERE
		VENTA_MEDIO_PAGO IS NOT NULL
GO

--producto
IF Object_id('GAME_OF_JOINS.Migrar_Producto') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Producto 
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Producto
AS 
    INSERT INTO GAME_OF_JOINS.producto
                (prod_codigo, prod_nombre, prod_descripcion, prod_categoria, prod_marca, prod_material) 
	(
		SELECT
			DISTINCT m.PRODUCTO_CODIGO,
			m.PRODUCTO_NOMBRE,
			m.PRODUCTO_DESCRIPCION,
			pcat.pcat_id,
			pmar.pmar_id,
			pmat.pmat_id
		FROM
			gd_esquema.Maestra M
		INNER JOIN GAME_OF_JOINS.producto_categoria pcat ON
			m.PRODUCTO_CATEGORIA = pcat.pcat_categoria
		INNER JOIN GAME_OF_JOINS.producto_marca pmar ON
			m.PRODUCTO_MARCA = pmar.pmar_marca
		INNER JOIN GAME_OF_JOINS.producto_material pmat ON
			m.PRODUCTO_MATERIAL = pmat.pmat_material
	)
GO

--compra_producto
IF Object_id('GAME_OF_JOINS.Migrar_Compra_Producto') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Compra_Producto 
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Compra_Producto
AS 
    INSERT INTO GAME_OF_JOINS.compra_producto
                (cpro_producto_codigo, cpro_compra_numero, cpro_producto_variante_codigo, cpro_cantidad, cpro_precio, cpro_total)
	SELECT
		m.PRODUCTO_CODIGO,
		m.COMPRA_NUMERO,
		m.PRODUCTO_VARIANTE_CODIGO,
		SUM(m.COMPRA_PRODUCTO_CANTIDAD) AS cantidad,
		m.COMPRA_PRODUCTO_PRECIO,
		SUM(m.COMPRA_PRODUCTO_CANTIDAD) * m.COMPRA_PRODUCTO_PRECIO AS total
	FROM
		gd_esquema.maestra m
	INNER JOIN GAME_OF_JOINS.producto_variante pv ON
		m.PRODUCTO_CODIGO = pv.pvar_producto_codigo
		AND m.PRODUCTO_VARIANTE_CODIGO = pv.pvar_codigo
	WHERE
		m.COMPRA_NUMERO IS NOT NULL
		AND m.PRODUCTO_CODIGO IS NOT NULL
		AND m.PRODUCTO_VARIANTE_CODIGO IS NOT NULL
	GROUP BY
		m.PRODUCTO_CODIGO,
		m.COMPRA_NUMERO,
		m.PRODUCTO_VARIANTE_CODIGO,
		m.COMPRA_PRODUCTO_PRECIO

GO

--producto_marca
IF Object_id('GAME_OF_JOINS.Migrar_Producto_Marca') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Producto_Marca 
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Producto_Marca 
AS 
    INSERT INTO GAME_OF_JOINS.producto_marca
                (pmar_marca)
	SELECT
		DISTINCT PRODUCTO_MARCA
	FROM
		gd_esquema.maestra
	WHERE
		PRODUCTO_MARCA IS NOT NULL
	ORDER BY
		1 ASC

GO

--producto_material
IF Object_id('GAME_OF_JOINS.Migrar_Producto_Material') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Producto_Material 
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Producto_Material 
AS 
    INSERT INTO GAME_OF_JOINS.producto_material 
                (pmat_material)
	SELECT
		DISTINCT PRODUCTO_MATERIAL
	FROM
		gd_esquema.maestra
	WHERE
		PRODUCTO_MATERIAL IS NOT NULL

GO

--venta_producto
IF Object_id('GAME_OF_JOINS.Migrar_Venta_Producto') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Venta_Producto 
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Venta_Producto 
AS 
    INSERT INTO GAME_OF_JOINS.venta_producto 
                (vpro_producto_codigo,
                vpro_venta_codigo,
                vpro_producto_variante_codigo,
                vpro_cantidad,
                vpro_precio,
                vpro_total
                ) 
	SELECT
		m.PRODUCTO_CODIGO,
		m.VENTA_CODIGO,
		m.PRODUCTO_VARIANTE_CODIGO,
		m.VENTA_PRODUCTO_CANTIDAD,
		m.VENTA_PRODUCTO_PRECIO,
		m.VENTA_PRODUCTO_CANTIDAD * m.VENTA_PRODUCTO_PRECIO as vendido
	FROM
		gd_esquema.maestra m
	INNER JOIN GAME_OF_JOINS.producto_variante pv ON
			m.PRODUCTO_CODIGO = pv.pvar_producto_codigo AND 
			m.PRODUCTO_VARIANTE_CODIGO = pv.pvar_codigo
	WHERE
		m.VENTA_CODIGO IS NOT NULL
		AND m.PRODUCTO_CODIGO IS NOT NULL
		AND m.PRODUCTO_VARIANTE_CODIGO IS NOT NULL

GO

--proveedor
IF Object_id('GAME_OF_JOINS.Migrar_Proveedor') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Proveedor 
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Proveedor 
AS 
    INSERT INTO GAME_OF_JOINS.proveedor
                (prove_cuit,
                prove_razon_social,
                prove_domicilio,
                prove_mail,
                prove_codigo_postal
                ) 
	SELECT
		DISTINCT m.PROVEEDOR_CUIT,
		m.PROVEEDOR_RAZON_SOCIAL,
		m.PROVEEDOR_DOMICILIO,
		m.PROVEEDOR_MAIL,
		cp.copo_id
	FROM
		gd_esquema.maestra m		
	INNER JOIN GAME_OF_JOINS.provincia p ON
		p.prov_provincia = m.PROVEEDOR_PROVINCIA
	INNER JOIN GAME_OF_JOINS.localidad l ON
		l.loca_localidad = m.PROVEEDOR_LOCALIDAD
		AND l.loca_provincia = p.prov_id
	INNER JOIN GAME_OF_JOINS.codigo_postal cp ON
		cp.copo_localidad = l.loca_id
		AND cp.copo_codigo_postal = m.PROVEEDOR_CODIGO_POSTAL		
	WHERE
		m.PROVEEDOR_CUIT IS NOT NULL

GO

--provincia
IF Object_id('GAME_OF_JOINS.Migrar_Provincia') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Provincia 
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Provincia
AS 
    INSERT INTO GAME_OF_JOINS.provincia
                (prov_provincia) 
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

--cupon_tipo
IF Object_id('GAME_OF_JOINS.Migrar_Cupon_Tipo') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Cupon_Tipo 
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Cupon_Tipo
AS 
    INSERT INTO GAME_OF_JOINS.cupon_tipo
                (cuti_tipo) 
	SELECT
		DISTINCT VENTA_CUPON_TIPO
	FROM
		gd_esquema.Maestra
	WHERE
		VENTA_CUPON_TIPO IS NOT NULL
GO

--variante_tipo
IF Object_id('GAME_OF_JOINS.Migrar_Variante_Tipo') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Variante_Tipo 
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Variante_Tipo
AS 
    INSERT INTO GAME_OF_JOINS.variante_tipo
                (vati_tipo) 
	SELECT
		DISTINCT PRODUCTO_TIPO_VARIANTE
	FROM
		gd_esquema.Maestra
	WHERE
		PRODUCTO_TIPO_VARIANTE IS NOT NULL
GO

--variante
IF Object_id('GAME_OF_JOINS.Migrar_Variante') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Variante 
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Variante
AS 
    INSERT INTO GAME_OF_JOINS.variante
                (vari_variante, vari_tipo) 
	(
		SELECT
			DISTINCT m.PRODUCTO_VARIANTE,
			vt.vati_id
		FROM
			gd_esquema.Maestra M
		INNER JOIN GAME_OF_JOINS.variante_tipo vt ON
			m.PRODUCTO_TIPO_VARIANTE = vt.vati_tipo
	)
GO

--producto_variante
IF Object_id('GAME_OF_JOINS.Migrar_Producto_Variante') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Producto_Variante 
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Producto_Variante
AS 
    INSERT INTO GAME_OF_JOINS.producto_variante
                (pvar_codigo,
				pvar_producto_codigo, 
				pvar_variante,
				pvar_precio_actual,
				pvar_stock) 
	SELECT
		DISTINCT m.PRODUCTO_VARIANTE_CODIGO,
		m.PRODUCTO_CODIGO,
		v.vari_id AS id_variante,
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
		SELECT
			sum(COMPRA_PRODUCTO_CANTIDAD)
		FROM
			gd_esquema.maestra m2
		WHERE
			PRODUCTO_CODIGO = m.PRODUCTO_CODIGO
			AND PRODUCTO_VARIANTE_CODIGO = m.PRODUCTO_VARIANTE_CODIGO
			AND COMPRA_NUMERO IS NOT NULL AND COMPRA_PRODUCTO_CANTIDAD IS NOT NULL ) - (
		SELECT
			sum(VENTA_PRODUCTO_CANTIDAD)
		FROM
			gd_esquema.maestra m3
		WHERE
			PRODUCTO_CODIGO = m.PRODUCTO_CODIGO
			AND PRODUCTO_VARIANTE_CODIGO = m.PRODUCTO_VARIANTE_CODIGO
			AND VENTA_CODIGO IS NOT NULL AND VENTA_PRODUCTO_CANTIDAD IS NOT NULL ) ) AS stock
	FROM
		gd_esquema.maestra m
	INNER JOIN GAME_OF_JOINS.variante_tipo vt ON
		vt.vati_tipo = m.PRODUCTO_TIPO_VARIANTE
	INNER JOIN GAME_OF_JOINS.variante v ON
		v.vari_tipo = vt.vati_id
		AND v.vari_variante = m.PRODUCTO_VARIANTE
	WHERE
		m.PRODUCTO_CODIGO IS NOT NULL
		AND m.PRODUCTO_VARIANTE_CODIGO IS NOT NULL
GO

--venta
IF Object_id('GAME_OF_JOINS.Migrar_Venta') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Venta
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Venta
AS 
    INSERT INTO GAME_OF_JOINS.venta
                (vent_codigo, vent_fecha, vent_cliente, vent_venta_medio_pago, vent_total) 
	SELECT
		DISTINCT m.VENTA_CODIGO,
		m.VENTA_FECHA,
		c.clie_id as id_cliente,
		vmp.vmep_id as id_venta_medio_pago,
		m.VENTA_TOTAL
	FROM
		gd_esquema.maestra m
	INNER JOIN GAME_OF_JOINS.cliente c ON
		c.clie_dni = m.CLIENTE_DNI
		AND c.clie_nombre = m.CLIENTE_NOMBRE
		AND c.clie_apellido = m.CLIENTE_APELLIDO
	INNER JOIN GAME_OF_JOINS.medio_pago mp ON
		mp.mepa_medio_pago = m.VENTA_MEDIO_PAGO
	INNER JOIN GAME_OF_JOINS.venta_medio_pago vmp ON
		vmp.vmep_medio_pago = mp.mepa_id

GO
	
--venta_canal
IF Object_id('GAME_OF_JOINS.Migrar_Venta_Canal') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Venta_Canal 
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Venta_Canal
AS 
    INSERT INTO GAME_OF_JOINS.venta_canal
                (veca_venta_codigo, veca_canal, veca_costo) 
	SELECT
		DISTINCT m.VENTA_CODIGO,
		c.cana_id,
		m.VENTA_CANAL_COSTO
	FROM
		gd_esquema.maestra m
	INNER JOIN GAME_OF_JOINS.canal c ON
		m.VENTA_CANAL = c.cana_canal
	WHERE
		m.VENTA_CODIGO IS NOT NULL

GO

--venta_cupon
IF Object_id('GAME_OF_JOINS.Migrar_Venta_Cupon') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Venta_Cupon 
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Venta_Cupon
AS 
    INSERT INTO GAME_OF_JOINS.venta_cupon
                (vecu_venta_codigo, vecu_codigo, vecu_importe) 
	(
		SELECT
			DISTINCT m.VENTA_CODIGO,
			m.VENTA_CUPON_CODIGO,
			m.VENTA_CUPON_IMPORTE
		FROM
			gd_esquema.Maestra m
		INNER JOIN GAME_OF_JOINS.cupon c ON
			m.VENTA_CUPON_CODIGO = c.cupo_codigo
		WHERE
			m.VENTA_CODIGO IS NOT NULL
	)
GO

--venta_descuento
IF Object_id('GAME_OF_JOINS.Migrar_Venta_Descuento') IS NOT NULL
	DROP PROCEDURE GAME_OF_JOINS.Migrar_Venta_Descuento
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Venta_Descuento
AS
	INSERT INTO GAME_OF_JOINS.venta_descuento
		(vede_venta_codigo, vede_importe, vede_descuento)
	SELECT
		DISTINCT VENTA_CODIGO,
		VENTA_DESCUENTO_IMPORTE,
		CASE
			WHEN VENTA_MEDIO_ENVIO IS NOT NULL
			AND VENTA_ENVIO_PRECIO = VENTA_DESCUENTO_IMPORTE THEN (
			SELECT
				descu_id
			FROM
				GAME_OF_JOINS.descuento
			WHERE
				descu_tipo = 'Envio Gratis')
			WHEN VENTA_MEDIO_ENVIO IS NOT NULL
			AND (VENTA_ENVIO_PRECIO IS NULL
			OR VENTA_ENVIO_PRECIO = 0)
			AND VENTA_MEDIO_ENVIO != 'Entrega en sucursal' THEN (
			SELECT
				descu_id
			FROM
				GAME_OF_JOINS.descuento
			WHERE
				descu_tipo = 'Envio Gratis')
			WHEN VENTA_DESCUENTO_CONCEPTO IN ('Efectivo', 'Transferencia') THEN (
			SELECT
				descu_id
			FROM
				GAME_OF_JOINS.descuento
			WHERE
				descu_tipo = 'Medio Pago')
			ELSE (
			SELECT
				descu_id
			FROM
				GAME_OF_JOINS.descuento
			WHERE
				descu_tipo = 'Especial')
		END AS descu_id
	FROM
		gd_esquema.maestra
	WHERE
		VENTA_CODIGO IS NOT NULL
		AND VENTA_DESCUENTO_CONCEPTO IS NOT NULL
GO

--medio_envio
IF Object_id('GAME_OF_JOINS.Migrar_Medio_Envio') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Medio_Envio
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Medio_Envio
AS 
    INSERT INTO GAME_OF_JOINS.medio_envio
                (menv_medio_envio) 
	SELECT
		DISTINCT VENTA_MEDIO_ENVIO
	FROM
		gd_esquema.maestra
	WHERE
		VENTA_MEDIO_ENVIO IS NOT NULL
GO

--venta_envio
IF Object_id('GAME_OF_JOINS.Migrar_Venta_Envio') IS NOT NULL
	DROP PROCEDURE GAME_OF_JOINS.Migrar_Venta_Envio
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Venta_Envio
AS
	INSERT INTO GAME_OF_JOINS.venta_envio
		(veen_venta_codigo, veen_precio, veen_medio_habilitado)
	SELECT
		DISTINCT VENTA_CODIGO,
		VENTA_ENVIO_PRECIO,
		menv.menv_id
	FROM
		gd_esquema.maestra m
	INNER JOIN GAME_OF_JOINS.medio_envio menv ON
		m.VENTA_MEDIO_ENVIO = menv.menv_medio_envio
	INNER JOIN GAME_OF_JOINS.codigo_postal cp ON
		m.CLIENTE_CODIGO_POSTAL = cp.copo_codigo_postal
	INNER JOIN GAME_OF_JOINS.medio_envio_habilitado meh ON
		menv.menv_id = meh.menh_medio_envio
		AND cp.copo_id = meh.menh_codigo_postal
	WHERE
		m.VENTA_CODIGO IS NOT NULL
GO

--venta_medio_pago
IF Object_id('GAME_OF_JOINS.Migrar_Venta_Medio_Pago') IS NOT NULL 
  DROP PROCEDURE GAME_OF_JOINS.Migrar_Venta_Medio_Pago 
GO 

CREATE PROCEDURE GAME_OF_JOINS.Migrar_Venta_Medio_Pago
AS 
    INSERT INTO GAME_OF_JOINS.venta_medio_pago
                (vmep_costo, vmep_medio_pago) 
	(
		SELECT
			DISTINCT VENTA_MEDIO_PAGO_COSTO,
			mp.mepa_id
		FROM
			gd_esquema.Maestra m
		INNER JOIN GAME_OF_JOINS.medio_pago mp ON
			m.VENTA_MEDIO_PAGO = mp.mepa_medio_pago
	)
GO


------------------------------------------------
------------ Migracion de datos ----------------
------------------------------------------------

EXEC GAME_OF_JOINS.Migrar_Medio_Pago
EXEC GAME_OF_JOINS.Migrar_Producto_Marca
EXEC GAME_OF_JOINS.Migrar_Producto_Material
EXEC GAME_OF_JOINS.Migrar_Producto_Categoria
EXEC GAME_OF_JOINS.Migrar_Canal
EXEC GAME_OF_JOINS.Migrar_Medio_Envio
EXEC GAME_OF_JOINS.Migrar_Venta_Medio_Pago
EXEC GAME_OF_JOINS.Migrar_Cupon_Tipo
EXEC GAME_OF_JOINS.Migrar_Cupon
EXEC GAME_OF_JOINS.Migrar_Provincia
EXEC GAME_OF_JOINS.Migrar_Localidad
EXEC GAME_OF_JOINS.Migrar_Codigo_Postal
EXEC GAME_OF_JOINS.Migrar_Medio_Envio_Habilitado
EXEC GAME_OF_JOINS.Migrar_Descuento
EXEC GAME_OF_JOINS.Migrar_Producto
EXEC GAME_OF_JOINS.Migrar_Cliente
EXEC GAME_OF_JOINS.Migrar_Proveedor
EXEC GAME_OF_JOINS.Migrar_Venta
EXEC GAME_OF_JOINS.Migrar_Venta_Canal
EXEC GAME_OF_JOINS.Migrar_Venta_Cupon
EXEC GAME_OF_JOINS.Migrar_Venta_Envio
EXEC GAME_OF_JOINS.Migrar_Venta_Descuento
EXEC GAME_OF_JOINS.Migrar_Variante_Tipo
EXEC GAME_OF_JOINS.Migrar_Variante
EXEC GAME_OF_JOINS.Migrar_Compra_Medio_Pago
EXEC GAME_OF_JOINS.Migrar_Compra
EXEC GAME_OF_JOINS.Migrar_Compra_Descuento
EXEC GAME_OF_JOINS.Migrar_Producto_Variante
EXEC GAME_OF_JOINS.Migrar_Compra_Producto
EXEC GAME_OF_JOINS.Migrar_Venta_Producto

GO

------------------------------------------------
----------- Drop de Procedures -----------------
------------------------------------------------

EXEC GAME_OF_JOINS.Drop_All_Procedures

GO