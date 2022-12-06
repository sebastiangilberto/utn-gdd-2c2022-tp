# General

Su Trabajo de Gestión de Datos ha sido corregido.
No cumplen con los requisitos de aprobación.

Su TP presenta los siguientes problemas:

# Migracion Transaccional

Ok

# Migracion BI.

- No se determina que es una tabla de HECHOS y que es una DIMENSIÓN. Leer enunciado donde se aclara como deben referenciarse.
- El script de migracion BI dio error, SE adjunta salida.
- Tengan en cuenta lo siguiente: En el modelo OLAP deben tener un tratamiento de la info del modelo relacional, debe haber una agrupación por las dimensiones propuestas. A simple vista lo que parece ser la tabla de HECHOS_COMPRA y HECHOS_VENTA tienen casi la misma cantidad de registros de sus respectivas tablas transaccionales. Nos referimos por ej a que el hecho_venta debería tener un registro por la combinatoria de las dimensiones que participan y no todos los registros de venta_detalle.
- Se sugiere no tener descuentos en los hechos de ventas. Pensar en la posibilidad de tener hechos para los descuentos y hechos para los medios de envío. Pensar que si relacionan ventas - producto y descuentos en una sola tabla de hecho, se repiten valores.

Deben corregir los puntos mencionados anteriormente en la siguiente entrega.
