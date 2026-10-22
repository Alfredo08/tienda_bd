
CREATE DATABASE tienda_bd;

CREATE TABLE clientes (
    id integer PRIMARY KEY,
    nombre varchar(100) NOT NULL,
    email varchar(100) UNIQUE NOT NULL,
    ciudad varchar(100) NOT NULL
);

CREATE TABLE productos (
    id integer PRIMARY KEY,
    nombre varchar(100) NOT NULL,
    precio numeric(10,2) NOT NULL CHECK (precio > 0)
);

CREATE TABLE ventas (
    id integer PRIMARY KEY,
    cliente_id integer NOT NULL REFERENCES clientes(id),
    producto_id integer NOT NULL REFERENCES productos(id),
    fecha date NOT NULL,
    cantidad integer NOT NULL CHECK (cantidad > 0),
    precio_unitario numeric(10,2) NOT NULL CHECK (precio_unitario > 0)
);

INSERT INTO clientes (id, nombre, email, ciudad) VALUES
(1, '  Ana López  ', 'ANA@ejemplo.test', 'Monterrey'),
(2, 'Bruno Díaz', 'bruno@ejemplo.test', 'Monterrey'),
(3, 'Carla Ruiz', 'carla@ejemplo.test', 'Guadalajara'),
(4, 'Diego Pérez', 'diego@ejemplo.test', 'Puebla'),
(5, 'Elena Torres', 'elena@ejemplo.test', 'Guadalajara');

INSERT INTO productos (id, nombre, precio) VALUES
(1, 'Teclado', 500),
(2, 'Mouse', 250),
(3, 'Cuaderno', 100),
(4, 'Taza', 150),
(5, 'Lámpara', 800);

INSERT INTO ventas (id, cliente_id, producto_id, fecha, cantidad, precio_unitario) VALUES
(1, 1, 1, '2026-01-05', 1, 500),
(2, 2, 2, '2026-01-10', 2, 250),
(3, 1, 3, '2026-01-15', 3, 100),
(4, 3, 4, '2026-01-20', 2, 150),
(5, 2, 1, '2026-02-05', 1, 500),
(6, 4, 3, '2026-02-10', 2, 100),
(7, 3, 2, '2026-02-15', 1, 250),
(8, 1, 4, '2026-03-01', 1, 150),
(9, 2, 3, '2026-03-10', 5, 100),
(10, 4, 4, '2026-03-20', 3, 150);

