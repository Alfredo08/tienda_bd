-- Ana (cliente_id 1) se muda a Puebla el 1 de marzo de 2026: situación ficticia.
-- Mantener una misma conexión desde BEGIN hasta ROLLBACK.
BEGIN;

-- Copia la fila de Ana desde LA DIMENSIÓN del esquema estrella, no desde clientes.
CREATE TEMP TABLE dim_cliente_tipo1 ON COMMIT DROP AS
SELECT cliente_id, nombre, ciudad
FROM analisis_tienda.dim_cliente WHERE cliente_id = 1;

-- Muestra Monterrey antes del cambio simulado.
SELECT cliente_id, nombre, ciudad FROM dim_cliente_tipo1;

-- SCD 1 sobrescribe la ciudad sin conservar la versión anterior.
UPDATE dim_cliente_tipo1 SET ciudad = 'Puebla' WHERE cliente_id = 1;

-- Agrupa todos los hechos históricos de Ana por su ciudad actual.
-- Resultado: Puebla 950; responde ciudad actual, no ciudad al comprar.
SELECT c.ciudad, SUM(v.importe) AS ingresos
FROM analisis_tienda.hechos_ventas AS v
JOIN dim_cliente_tipo1 AS c ON c.cliente_id = v.cliente_id
GROUP BY c.ciudad;

-- SCD 2 añade una clave por versión (cliente_sk), fechas y un indicador actual.
-- cliente_id identifica a la persona; cliente_sk identifica una versión.
CREATE TEMP TABLE dim_cliente_tipo2 (
    cliente_sk integer PRIMARY KEY,
    cliente_id integer NOT NULL,
    nombre varchar(100) NOT NULL,
    ciudad varchar(100) NOT NULL,
    desde date NOT NULL,
    hasta date NOT NULL,
    actual boolean NOT NULL,
    CHECK (desde < hasta)
) ON COMMIT DROP;

-- Copia la versión inicial de Ana desde la dimensión original.
-- Para el ejercicio se asume que su ciudad estuvo vigente desde el 1 de enero.
INSERT INTO dim_cliente_tipo2
SELECT 101, cliente_id, nombre, ciudad,
       DATE '2026-01-01', DATE '9999-12-31', true
FROM analisis_tienda.dim_cliente WHERE cliente_id = 1;

-- Cierra la versión antigua: el límite hasta NO se incluye.
UPDATE dim_cliente_tipo2 SET hasta = '2026-03-01', actual = false
WHERE cliente_sk = 101;

-- Abre una versión nueva, con otra clave, a partir del día de la mudanza.
INSERT INTO dim_cliente_tipo2
SELECT 102, cliente_id, nombre, 'Puebla',
       DATE '2026-03-01', DATE '9999-12-31', true
FROM analisis_tienda.dim_cliente WHERE cliente_id = 1;

-- Muestra dos versiones de la misma persona, no dos clientes distintos.
SELECT cliente_sk, cliente_id, nombre, ciudad, desde, hasta, actual
FROM dim_cliente_tipo2 ORDER BY desde;

-- Carga preparada: copia solo los hechos de Ana y busca la versión por fecha.
-- Conserva la clave de la versión en los hechos; el reporte ya no busca por rango.
-- No actualiza ni reemplaza hechos_ventas: es una copia temporal ilustrativa.
CREATE TEMP TABLE hechos_ventas_historia ON COMMIT DROP AS
SELECT v.venta_id, c.cliente_sk, v.producto_id, v.fecha, v.cantidad, v.importe
FROM analisis_tienda.hechos_ventas AS v
JOIN dim_cliente_tipo2 AS c ON c.cliente_id = v.cliente_id
 AND v.fecha >= c.desde AND v.fecha < c.hasta;

-- Reporte por ciudad AL COMPRAR: Monterrey 800 y Puebla 150.
-- La relación hechos-dimensión usa cliente_sk, clave de la versión histórica.
SELECT c.ciudad, SUM(v.importe) AS ingresos
FROM hechos_ventas_historia AS v
JOIN dim_cliente_tipo2 AS c ON c.cliente_sk = v.cliente_sk
GROUP BY c.ciudad ORDER BY c.ciudad;

-- Comprueba que la copia conserva las tres ventas de Ana y su importe total 950.
SELECT COUNT(*) AS ventas_de_ana, SUM(importe) AS total
FROM hechos_ventas_historia;

-- Descarta las versiones y los hechos de prueba. La estrella original no cambia.
ROLLBACK;
