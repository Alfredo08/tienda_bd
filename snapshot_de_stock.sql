-- Datos de stock ficticios: no se deducen de las ventas ni modifican inventario real.
BEGIN;

-- Grano: stock de un producto en una sucursal al cierre de un día.
-- Es una tabla de hechos diferente de hechos_ventas, porque mide un estado.
-- No se crean FK hacia tablas permanentes desde esta tabla temporal.
CREATE TEMP TABLE hechos_stock_demo (
    fecha date NOT NULL,
    sucursal varchar(30) NOT NULL,
    producto_id integer NOT NULL,
    stock integer NOT NULL CHECK (stock >= 0),
    PRIMARY KEY (fecha, sucursal, producto_id)
) ON COMMIT DROP;

-- Simula dos fotografías del producto 1 (Teclado) en dos sucursales.
INSERT INTO hechos_stock_demo VALUES
('2026-03-01', 'Centro', 1, 10),
('2026-03-01', 'Norte', 1, 5),
('2026-03-02', 'Centro', 1, 8),
('2026-03-02', 'Norte', 1, 4);

-- Reutiliza dim_producto para describir los hechos de stock.
-- La dimensión producto se comparte entre ventas e inventario.
SELECT s.fecha, s.sucursal, p.nombre AS producto, s.stock
FROM hechos_stock_demo AS s
JOIN analisis_tienda.dim_producto AS p ON p.producto_id = s.producto_id
ORDER BY s.fecha, s.sucursal;

-- Suma sucursales dentro del mismo corte y para el mismo producto.
-- Resultado: 15 teclados el día 1 y 12 el día 2.
SELECT fecha, producto_id, SUM(stock) AS stock_total_del_dia
FROM hechos_stock_demo GROUP BY fecha, producto_id
ORDER BY fecha, producto_id;

-- Error deliberado: sumar las dos fechas da 27, que no es el stock final.
-- La medida stock es semi-aditiva: no se suma entre días para obtener existencias.
SELECT SUM(stock) AS suma_incorrecta_para_stock_final FROM hechos_stock_demo;

-- Descarta la demostración y deja el modelo estrella intacto.
ROLLBACK;
