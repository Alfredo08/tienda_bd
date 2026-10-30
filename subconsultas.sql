
-- 1 | SUBCONSULTA ESCALAR: ventas con importe superior al promedio general.
-- La consulta interna devuelve un solo número: 365.
-- La consulta externa conserva las ventas cuyo importe supera ese valor.
-- Resultado esperado: ventas 1, 2, 5, 9 y 10.
SELECT id, fecha, cantidad * precio_unitario AS importe
FROM ventas
WHERE cantidad * precio_unitario > (
    SELECT AVG(cantidad * precio_unitario)
    FROM ventas
)
ORDER BY id;

-- 2 | SUBCONSULTA DE CONJUNTO + DISTINCT: ciudades de compradores de cuaderno.
-- La consulta interna devuelve los clientes que compraron el producto 3.
-- IN comprueba si el cliente está en ese conjunto.
-- DISTINCT evita mostrar Monterrey dos veces, porque allí viven Ana y Bruno.
-- Resultado esperado: Monterrey y Puebla.
SELECT DISTINCT ciudad
FROM clientes
WHERE id IN (
    SELECT cliente_id
    FROM ventas
    WHERE producto_id = 3
)
ORDER BY ciudad;

-- 3 | SUBCONSULTA CORRELACIONADA: clientes que nunca compraron.
-- La consulta interna usa c.id, que pertenece a la consulta externa.
-- NOT EXISTS conserva al cliente cuando no encuentra ventas relacionadas.
-- Resultado esperado: Elena Torres (id 5).
SELECT c.id, TRIM(c.nombre) AS cliente
FROM clientes AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM ventas AS v
    WHERE v.cliente_id = c.id
)
ORDER BY c.id;

-- 4 | CTE + RANK: ordenar las ventas por su importe, de mayor a menor.
-- La CTE solo da nombre al cálculo del importe; no agrupa ni relaciona tablas.
-- RANK asigna la misma posición a ventas con el mismo importe.
-- Las cuatro ventas de 500 empatan en el puesto 1; la de 450 ocupa el 5.
WITH importes AS (
    SELECT id, cantidad * precio_unitario AS importe
    FROM ventas
)
SELECT id, importe,
       RANK() OVER (ORDER BY importe DESC) AS puesto
FROM importes
ORDER BY importe DESC, id;

-- 5 | LAG: mostrar el importe de cada venta y el de la venta anterior.
-- ORDER BY fecha, id define qué significa "anterior".
-- La primera venta no tiene una anterior: su resultado es NULL.
-- No se limita a compras del mismo cliente: recorre todas las ventas de la tienda.
SELECT id, fecha,
       cantidad * precio_unitario AS importe,
       LAG(cantidad * precio_unitario) OVER (
           ORDER BY fecha, id
       ) AS importe_anterior
FROM ventas
ORDER BY fecha, id;

-- 6 | PARTITION BY: mostrar cada venta junto al total de su cliente.
-- SUM suma los importes de todas las ventas que tienen el mismo cliente_id.
-- La ventana conserva las diez filas: no las reduce como GROUP BY.
-- Para Ana (cliente 1), sus tres ventas muestran un total de 950 cada una.
-- Ese total ya está calculado: no se deben sumar otra vez sus repeticiones.
SELECT id AS venta, cliente_id,
       cantidad * precio_unitario AS importe,
       SUM(cantidad * precio_unitario) OVER (
           PARTITION BY cliente_id
       ) AS total_del_cliente
FROM ventas
ORDER BY cliente_id, fecha, id;


-- Lo mostrado en clase

SELECT *
FROM ventas;

SELECT AVG(cantidad * precio_unitario)
FROM ventas;

SELECT id, fecha, cantidad * precio_unitario AS importe
FROM ventas
WHERE cantidad * precio_unitario > (
	SELECT AVG(cantidad * precio_unitario)
	FROM ventas);

SELECT *
FROM ventas;

SELECT *
FROM ventas
WHERE producto_id = 3;


SELECT nombre, ciudad
FROM clientes
WHERE id IN (
	SELECT cliente_id
	FROM ventas
	WHERE producto_id = 3);

SELECT DISTINCT ciudad
FROM clientes
WHERE id IN (
	SELECT cliente_id
	FROM ventas
	WHERE producto_id = 3);

SELECT *
FROM clientes;


SELECT c.id, c.nombre
FROM clientes c
WHERE NOT EXISTS
	(SELECT 1
	FROM ventas v
	WHERE v.cliente_id = c.id);


WITH tabla_con_cuadernos AS (
	SELECT cliente_id
	FROM ventas
	WHERE producto_id = 3
)
SELECT DISTINCT ciudad
FROM clientes
WHERE id IN (tabla_con_cuadernos); 

WITH importes AS (
	SELECT id, cantidad * precio_unitario AS importe
	FROM ventas
)
SELECT id, importe, RANK() OVER (ORDER BY importe DESC) AS puesto
FROM importes;


SELECT *
FROM ventas
LIMIT 3;

SELECT *
FROM ventas
ORDER BY id DESC
LIMIT 3
OFFSET 3;

SELECT *
FROM ventas
ORDER BY id DESC
FETCH FIRST 5 ROWS ONLY;