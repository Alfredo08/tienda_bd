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

-- 14. INNER JOIN: relaciona cada venta con su cliente y su producto.
-- Muestra diez filas. Elena no aparece porque no realizó compras.
SELECT v.id AS venta, TRIM(c.nombre) AS cliente, p.nombre AS producto,
       v.cantidad, v.cantidad * v.precio_unitario AS importe
FROM ventas AS v
INNER JOIN clientes AS c ON c.id = v.cliente_id
INNER JOIN productos AS p ON p.id = v.producto_id
ORDER BY v.id;

-- 15. LEFT JOIN: conserva a todos los clientes, incluso los que no compraron.
-- COUNT(v.id) no cuenta NULL: Elena aparece con cero ventas.
SELECT c.id, TRIM(c.nombre) AS cliente, COUNT(v.id) AS cantidad_ventas
FROM clientes AS c
LEFT JOIN ventas AS v ON v.cliente_id = c.id
GROUP BY c.id, c.nombre
ORDER BY c.id;

-- 16. RIGHT JOIN: conserva todos los productos de la tabla de la derecha.
-- La lámpara aparece con venta NULL porque nunca se vendió.
SELECT p.nombre AS producto, v.id AS venta
FROM ventas AS v
RIGHT JOIN productos AS p ON p.id = v.producto_id
ORDER BY p.id, v.id;

-- 17. FULL JOIN: combina dos listas de clientes construidas desde ventas.
-- Izquierda: compradores de teclado. Derecha: compradores de taza.
-- Ana aparece en ambos lados; Bruno solo a la izquierda; Carla y Diego a la derecha.
-- DISTINCT deja una fila por cliente en cada lista antes de relacionarlas.
SELECT t.cliente_id AS comprador_teclado, z.cliente_id AS comprador_taza
FROM (SELECT DISTINCT cliente_id FROM ventas WHERE producto_id = 1) AS t
FULL JOIN
     (SELECT DISTINCT cliente_id FROM ventas WHERE producto_id = 4) AS z
ON t.cliente_id = z.cliente_id
ORDER BY COALESCE(t.cliente_id, z.cliente_id);

-- 18. UNION: reúne compradores de teclado o cuaderno, sin repetir clientes.
-- Esperado: identificadores 1, 2 y 4.
SELECT cliente_id FROM ventas WHERE producto_id = 1
UNION
SELECT cliente_id FROM ventas WHERE producto_id = 3
ORDER BY cliente_id;

-- 19. UNION ALL: reúne las mismas listas y conserva las repeticiones.
-- Esperado: 1, 1, 2, 2, 4. UNION compara filas completas, no solo claves.
SELECT cliente_id FROM ventas WHERE producto_id = 1
UNION ALL
SELECT cliente_id FROM ventas WHERE producto_id = 3
ORDER BY cliente_id;

-- 20. INTERSECT: encuentra clientes que compraron tanto teclado como cuaderno.
-- Esperado: identificadores 1 y 2.
SELECT cliente_id FROM ventas WHERE producto_id = 1
INTERSECT
SELECT cliente_id FROM ventas WHERE producto_id = 3
ORDER BY cliente_id;

-- 21. ALTER TABLE: agrega un teléfono opcional a los clientes.
-- BEGIN y ROLLBACK permiten probar el cambio sin dejarlo guardado.
BEGIN;
ALTER TABLE clientes ADD COLUMN telefono varchar(20);

-- Guarda un teléfono de ejemplo para Ana dentro de esta transacción.
UPDATE clientes SET telefono = '555-0101' WHERE id = 1;

-- Comprueba que la nueva columna está disponible y contiene el teléfono.
SELECT id, nombre, telefono FROM clientes ORDER BY id;

-- Deshace la columna y la actualización. Ejecuta todo el bloque anterior junto.
ROLLBACK;

-- 22. CREATE INDEX: crea un índice para búsquedas de ventas por cliente.
-- Con diez filas PostgreSQL puede preferir leer toda la tabla; es normal.
BEGIN;
CREATE INDEX idx_ventas_cliente ON ventas(cliente_id);

-- EXPLAIN muestra cómo PostgreSQL planea buscar las ventas de Ana.
EXPLAIN SELECT id, fecha, cantidad FROM ventas WHERE cliente_id = 1;

-- Elimina el índice de prueba al deshacer la transacción.
ROLLBACK;

-- 23. TRIGGER: convierte a minúsculas y quita espacios de correos nuevos.
-- En PostgreSQL se necesita primero una función y después el trigger.
BEGIN;
CREATE FUNCTION limpiar_email()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.email := LOWER(TRIM(NEW.email));
    RETURN NEW;
END;
$$;

-- Hace que la función se ejecute antes de insertar o modificar un correo.
CREATE TRIGGER normalizar_email
BEFORE INSERT OR UPDATE OF email ON clientes
FOR EACH ROW
EXECUTE FUNCTION clase_simple.limpiar_email();

-- Inserta un cliente con espacios y mayúsculas; el trigger limpia su correo.
INSERT INTO clientes (id, nombre, email, ciudad)
VALUES (6, 'Fabio Mora', '  FABIO@ejemplo.test  ', 'Puebla');

-- Comprueba que se guardó fabio@ejemplo.test, sin espacios ni mayúsculas.
SELECT id, nombre, email FROM clientes WHERE id = 6;

-- Deshace el cliente de prueba, el trigger y su función para poder repetir.
-- El trigger no modifica automáticamente a los clientes que ya existían.
ROLLBACK;

-- 24. COMMIT: confirma un cambio y permite verlo después de la transacción.
BEGIN;
UPDATE productos SET precio = 550 WHERE id = 1;
COMMIT;

-- Comprueba que el teclado ahora cuesta 550. Sus ventas históricas no cambian.
SELECT id, nombre, precio FROM productos WHERE id = 1;

-- Devuelve el precio original para dejar la base lista para repetir la clase.
BEGIN;
UPDATE productos SET precio = 500 WHERE id = 1;
COMMIT;

-- 25. ROLLBACK: deshace una modificación que todavía no se confirmó.
BEGIN;
UPDATE productos SET precio = 999 WHERE id = 1;

-- Dentro de la transacción se observa el precio temporal de 999.
SELECT id, nombre, precio FROM productos WHERE id = 1;

-- Cancela el cambio de precio.
ROLLBACK;

-- Comprueba que el precio volvió a 500.