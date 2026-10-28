# Decisiones de diseño del modelo

> Jira: DWI-67 · Responsable: Marco Andrey López Quesada
> La elección del esquema estrella con tabla puente está en `01-esquema-dimensional.md`.

## Tienda = dueña de la copia alquilada

La tienda de cada alquiler se toma de `inventory.store_id`, es decir, la tienda dueña de la copia que se alquiló.

La base tiene otras dos formas de asignar una tienda a un alquiler, y ninguna coincide con la de la copia:

| Alternativa | Coincide con la tienda de la copia |
|---|---|
| Tienda del cliente (`customer.store_id`) | 50,0 % de los alquileres |
| Tienda del empleado que atendió (`staff.store_id`) | 50,3 % de los alquileres |

Se usa la tienda de la copia porque es la que realmente tuvo la película en su inventario. Es la misma tienda que se usa en la pregunta de copias por película (inventario), así que las preguntas por tienda quedan consistentes entre sí.

## Fecha = fecha del alquiler

La dimensión Fecha se une al hecho por `rental.rental_date`. La fecha de pago (`payment.payment_date`) se descarta porque no corresponde al momento real del cobro:

- El **100 %** de los pagos está fechado en **2017**.
- El **98,9 %** de los alquileres (31 724 de 32 088) es de **2005**.
- La mediana entre la fecha del alquiler y la fecha de su pago es de unos **11,7 años**.

Si se usara la fecha de pago, casi todos los ingresos aparecerían en 2017, aunque los alquileres ocurrieron en 2005.
