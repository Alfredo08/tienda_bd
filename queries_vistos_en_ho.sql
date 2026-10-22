-- 01. Muestra los cinco clientes para conocer los datos iniciales.
SELECT id, nombre, email, ciudad
FROM clientes
ORDER BY id;

-- 02. EXTRACT: obtiene el año, mes y día de cada venta.
SELECT id, fecha,
       EXTRACT(YEAR FROM fecha) AS anio,
       EXTRACT(MONTH FROM fecha) AS mes,
       EXTRACT(DAY FROM fecha) AS dia
FROM ventas
ORDER BY id;

-- 03. INTERVAL: calcula una fecha de entrega siete días después de cada venta.
SELECT id, fecha, fecha + INTERVAL '7 days' AS fecha_entrega
FROM ventas
ORDER BY id;

-- 04. CONCAT: une el nombre del cliente y su ciudad en una sola etiqueta.
-- TRIM elimina los espacios que tiene Ana al principio y al final del nombre.
SELECT id, CONCAT(TRIM(nombre), ' - ', ciudad) AS etiqueta
FROM clientes
ORDER BY id;

-- 05. SUBSTRING: extrae los primeros tres caracteres del nombre sin espacios.
SELECT nombre, SUBSTRING(TRIM(nombre) FROM 1 FOR 3) AS primeros_caracteres
FROM clientes
ORDER BY id;

-- 06. TRIM, UPPER y LOWER: muestra versiones limpias del texto sin cambiar la tabla.
SELECT nombre, TRIM(nombre) AS nombre_limpio,
       UPPER(TRIM(nombre)) AS nombre_mayusculas,
       LOWER(TRIM(email)) AS email_minusculas
FROM clientes
ORDER BY id;

-- 07. POSITION: indica en qué posición se encuentra la arroba de cada correo.
-- Devuelve cero si no la encuentra. Esto no comprueba que el correo sea válido.
SELECT email, POSITION('@' IN email) AS posicion_arroba
FROM clientes
ORDER BY id;

-- 08. Cuenta ventas y calcula unidades, ingresos, promedio, mínimo y máximo.
-- Cada venta tiene un solo producto; el importe es cantidad por precio_unitario.
-- Esperado: 10 ventas, 21 unidades, 3650 de ingresos y promedio de 365 por venta.
SELECT COUNT(*) AS total_ventas,
       SUM(cantidad) AS unidades_vendidas,
       SUM(cantidad * precio_unitario) AS ingresos,
       ROUND(AVG(cantidad * precio_unitario), 2) AS promedio_por_venta,
       MIN(cantidad * precio_unitario) AS menor_venta,
       MAX(cantidad * precio_unitario) AS mayor_venta
FROM ventas;

-- 09. Cuenta cuántos clientes diferentes realizaron compras. Esperado: 4.
SELECT COUNT(DISTINCT cliente_id) AS clientes_con_compras
FROM ventas;

-- 10. Calcula la dispersión de los importes de venta.
-- VARIANCE y STDDEV son muestrales en PostgreSQL; con una sola fila dan NULL.
SELECT ROUND(VARIANCE(cantidad * precio_unitario), 2) AS varianza,
       ROUND(STDDEV(cantidad * precio_unitario), 2) AS desviacion_estandar
FROM ventas;

-- 11. GROUP BY: calcula los ingresos por año y mes.
-- Esperado: enero 1600, febrero 950 y marzo 1100.
SELECT EXTRACT(YEAR FROM fecha) AS anio,
       EXTRACT(MONTH FROM fecha) AS mes,
       SUM(cantidad * precio_unitario) AS ingresos
FROM ventas
GROUP BY EXTRACT(YEAR FROM fecha), EXTRACT(MONTH FROM fecha)
ORDER BY anio, mes;

-- 12. GROUP BY: cuenta las ventas de cada cliente que tiene compras.
-- Esperado: Ana 3, Bruno 3, Carla 2 y Diego 2.
SELECT cliente_id, COUNT(*) AS cantidad_ventas
FROM ventas
GROUP BY cliente_id
ORDER BY cliente_id;

-- 13. WHERE filtra ventas individuales de febrero en adelante.
-- HAVING conserva solo clientes cuya suma en ese período llega a 600.
-- Esperado: Bruno (id 2) con 1000 y Diego (id 4) con 650.
SELECT cliente_id, SUM(cantidad * precio_unitario) AS total
FROM ventas
WHERE fecha >= DATE '2026-02-01'
GROUP BY cliente_id
HAVING SUM(cantidad * precio_unitario) >= 600
ORDER BY cliente_id;