
BEGIN;

-- Muestra cada hecho con el nombre del producto y los atributos de fecha.
-- Grano original: una venta de un producto a un cliente en una fecha.
SELECT v.venta_id, v.cliente_id, p.nombre AS producto,
       f.fecha, f.anio, f.mes, v.cantidad, v.importe
FROM analisis_tienda.hechos_ventas AS v
JOIN analisis_tienda.dim_producto AS p ON p.producto_id = v.producto_id
JOIN analisis_tienda.dim_fecha AS f ON f.fecha = v.fecha
ORDER BY v.venta_id;

-- Crea un agregado temporal: su grano cambia a una fila por año y mes.
-- Usa anio y mes de dim_fecha: no vuelve a calcularlos desde las ventas originales.
CREATE TEMP TABLE resumen_mensual ON COMMIT DROP AS
SELECT f.anio, f.mes, SUM(v.importe) AS ingresos,
       SUM(v.cantidad) AS unidades, COUNT(*) AS cantidad_ventas
FROM analisis_tienda.hechos_ventas AS v
JOIN analisis_tienda.dim_fecha AS f ON f.fecha = v.fecha
GROUP BY f.anio, f.mes;

-- Muestra tres meses en lugar de diez ventas y calcula su promedio por venta.
-- Esperado: enero 1600/4=400; febrero 950/3=316.67; marzo 1100/3=366.67.
SELECT anio, mes, ingresos, unidades, cantidad_ventas,
       ROUND(ingresos / cantidad_ventas, 2) AS promedio_por_venta
FROM resumen_mensual ORDER BY anio, mes;

-- Compara el promedio global correcto con el promedio simple de promedios.
-- Correcto: 3650/10=365. Promediar meses con distinto número de ventas da 361.11.
SELECT SUM(ingresos) AS ingresos_totales,
       SUM(cantidad_ventas) AS ventas_totales,
       ROUND(SUM(ingresos) / SUM(cantidad_ventas), 2) AS promedio_correcto,
       ROUND(AVG(ingresos / cantidad_ventas), 2) AS promedio_de_promedios
FROM resumen_mensual;

-- Elimina el resumen temporal; conserva los hechos originales al mismo grano.
ROLLBACK;
