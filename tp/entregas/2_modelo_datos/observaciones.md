# DER

- Falta guardar el costo del canal de venta aplicado a cada venta en particular.
- Falta guardar el costo del medio de pago aplicado a cada venta en particular. esto también se detalló en la corrección anterior. De la manera que lo han resuelto si se actualiza uno de estos costos, hacen variar a las ventas pasadas (inflación)

# Migracion

- Al ejecutar el script dio error, se adjunta [la salida](error.log)
- Por el error de ejecución quedaron entidades vacías, compra, productos_compra, compra_descuento y proveedor. El resto de las entidades pareciera tener las cantidades correctas. Ojo con los detalles de las compras con estar agrupando items, mucho cuidado como hacen el group by ya que les cambia sustancialmente el resultado final.

# General

- Observación, por lo general, una buena práctica es que las entidades lleven un nombre en singular y no plural, modela una idea ya que sea por sentado que puede haber más de un valor.
