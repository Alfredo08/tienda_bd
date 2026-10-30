-- M2L5: de nuestra tienda a un esquema estrella.
-- Requiere la base tienda_bd de las clases anteriores.
-- Ejecutar por bloques en la misma conexión. No modifica las tablas originales.


-- BLOQUE 2. Crea el modelo DESPUÉS de discutirlo y dibujarlo con el grupo.
-- Ejecutar una sola vez: si el esquema ya existe, falla sin borrarlo.
BEGIN;
CREATE SCHEMA analisis_tienda;

-- Dimensión cliente: describe quién compró y desde qué ciudad.
CREATE TABLE analisis_tienda.dim_cliente (
    cliente_id integer PRIMARY KEY,
    nombre varchar(100) NOT NULL,
    ciudad varchar(100) NOT NULL
);

-- Dimensión producto: describe qué se compró.
CREATE TABLE analisis_tienda.dim_producto (
    producto_id integer PRIMARY KEY,
    nombre varchar(100) NOT NULL
);

-- Dimensión fecha: permite agrupar por día, mes o año sin repetir EXTRACT.
CREATE TABLE analisis_tienda.dim_fecha (
    fecha date PRIMARY KEY,
    anio integer NOT NULL,
    mes integer NOT NULL
);

-- Hechos: una fila por venta original de un producto a un cliente en una fecha.
-- cantidad e importe se pueden sumar. precio_unitario no se suma como ingreso.
CREATE TABLE analisis_tienda.hechos_ventas (
    venta_id integer PRIMARY KEY,
    cliente_id integer NOT NULL REFERENCES analisis_tienda.dim_cliente(cliente_id),
    producto_id integer NOT NULL REFERENCES analisis_tienda.dim_producto(producto_id),
    fecha date NOT NULL REFERENCES analisis_tienda.dim_fecha(fecha),
    cantidad integer NOT NULL CHECK (cantidad > 0),
    precio_unitario numeric(10,2) NOT NULL CHECK (precio_unitario > 0),
    importe numeric(12,2) NOT NULL CHECK (importe = cantidad * precio_unitario)
);
COMMIT;

-- BLOQUE 3. Carga inicial: extraer, transformar y cargar (ETL sencillo).
-- Ejecutar una sola vez y completo. Primero dimensiones; después hechos.
BEGIN;

-- Copia clientes y limpia los espacios de sus nombres.
INSERT INTO analisis_tienda.dim_cliente (cliente_id, nombre, ciudad)
SELECT id, TRIM(nombre), ciudad FROM public.clientes;

-- Copia los productos; el precio histórico estará en los hechos.
INSERT INTO analisis_tienda.dim_producto (producto_id, nombre)
SELECT id, nombre FROM public.productos;

-- Crea una fila por fecha distinta de las ventas y calcula año y mes.
INSERT INTO analisis_tienda.dim_fecha (fecha, anio, mes)
SELECT DISTINCT fecha, EXTRACT(YEAR FROM fecha)::integer,
       EXTRACT(MONTH FROM fecha)::integer
FROM public.ventas;

-- Conserva las diez ventas al mismo nivel de detalle y calcula sus importes.
INSERT INTO analisis_tienda.hechos_ventas
    (venta_id, cliente_id, producto_id, fecha, cantidad, precio_unitario, importe)
SELECT id, cliente_id, producto_id, fecha, cantidad, precio_unitario,
       cantidad * precio_unitario
FROM public.ventas;
COMMIT;


-- BLOQUE 4. Dos reportes que responden preguntas del negocio.

-- Reporte A: ¿Cuánto vendimos cada mes? Esperado: 1600, 950 y 1100.
SELECT f.anio, f.mes, SUM(v.importe) AS ingresos
FROM analisis_tienda.hechos_ventas AS v
JOIN analisis_tienda.dim_fecha AS f ON f.fecha = v.fecha
GROUP BY f.anio, f.mes
ORDER BY f.anio, f.mes;

-- Reporte B: ¿Qué ciudades generan más ingresos?
-- Esperado: Monterrey 2450, Puebla 650, Guadalajara 550.
SELECT c.ciudad, SUM(v.importe) AS ingresos
FROM analisis_tienda.hechos_ventas AS v
JOIN analisis_tienda.dim_cliente AS c ON c.cliente_id = v.cliente_id
GROUP BY c.ciudad
ORDER BY ingresos DESC, c.ciudad;

-- BLOQUE 5. Verifica que el cambio de modelo no perdió ni duplicó ventas.
-- Debe mostrar en ambos lados 10 ventas, 21 unidades e ingresos de 3650.
SELECT 'Origen' AS modelo, COUNT(*) AS ventas, SUM(cantidad) AS unidades,
       SUM(cantidad * precio_unitario) AS ingresos
FROM public.ventas
UNION ALL
SELECT 'Estrella', COUNT(*), SUM(cantidad), SUM(importe)
FROM analisis_tienda.hechos_ventas;
