-- PRACTICA: TRANSACCIONES EN MYSQL / MARIADB
-- Motor requerido: InnoDB. Ejecutar en MySQL Workbench o consola.
-- La práctica usa una base de datos de prueba llamada practica_transacciones.
-- ADVERTENCIA: DROP DATABASE elimina una base con ese nombre. Cambia el nombre
-- si ya tienes una base importante llamada practica_transacciones.

DROP DATABASE IF EXISTS practica_transacciones;
CREATE DATABASE practica_transacciones;
USE practica_transacciones;

CREATE TABLE productos (
    id_producto INT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    precio DECIMAL(10,2) NOT NULL CHECK (precio >= 0),
    existencia INT NOT NULL CHECK (existencia >= 0)
) ENGINE=InnoDB;

CREATE TABLE ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    total DECIMAL(10,2) NOT NULL CHECK (total >= 0),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ventas_productos
        FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
) ENGINE=InnoDB;

INSERT INTO productos (id_producto, nombre, precio, existencia)
VALUES (1, 'Helado de vainilla', 15.00, 10);

-- ESTADO INICIAL: debe mostrar existencia = 10 y ninguna venta.
SELECT * FROM productos;
SELECT * FROM ventas;

-- PRUEBA 1: COMMIT. Se descuentan 2 helados y se registra la venta.
START TRANSACTION;

UPDATE productos
SET existencia = existencia - 2
WHERE id_producto = 1 AND existencia >= 2;

-- Comprobar que el UPDATE afectó una fila antes de continuar.
SELECT * FROM productos WHERE id_producto = 1;

INSERT INTO ventas (id_producto, cantidad, total)
SELECT 1, 2, precio * 2
FROM productos
WHERE id_producto = 1;

-- Antes de COMMIT, consultar en esta misma sesión los cambios provisionales.
SELECT * FROM productos;
SELECT * FROM ventas;

COMMIT;

-- DESPUÉS DEL COMMIT: existencia = 8 y una venta por $30.00.
SELECT * FROM productos;
SELECT * FROM ventas;

-- PRUEBA 2: ROLLBACK. Se simula otra venta, pero se cancela.
START TRANSACTION;

UPDATE productos
SET existencia = existencia - 3
WHERE id_producto = 1 AND existencia >= 3;

INSERT INTO ventas (id_producto, cantidad, total)
SELECT 1, 3, precio * 3
FROM productos
WHERE id_producto = 1;

-- En esta misma sesión, antes de deshacer: existencia provisional = 5
-- y deben verse dos filas en ventas.
SELECT * FROM productos;
SELECT * FROM ventas;

ROLLBACK;

-- DESPUÉS DEL ROLLBACK: debe volver al estado confirmado anterior:
-- existencia = 8 y solo una venta por $30.00.
SELECT * FROM productos;
SELECT * FROM ventas;

-- NOTAS:
-- 1) Los SELECT dentro de la transacción muestran los cambios de la propia sesión.
-- 2) ROLLBACK solo revierte cambios transaccionales aún no confirmados.
-- 3) Si un UPDATE no afecta filas, no debe insertarse una venta; en una aplicación
-- real se debe comprobar el número de filas afectadas y manejar el error.
-- 4) Ejecutar todo el script en una sesión para que las transacciones sean la misma.
