-- creación de tablas: 

--Crear una tabla pedidos con los siguientes campos:
--id_pedido (PK, autoincremental)
--id_cliente (FK que apunte a clientes)
--fecha_pedido (DATE)
--metodo_pago (VARCHAR)
--estado (ENUM: 'pendiente', 'preparacion', 'entregado', 'cancelado')
--total (DECIMAL(10,2))


CREATE TABLE pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metodo_pago VARCHAR(80),
    estado ENUM('pendiente','en preparacion','entregado','cancelado') NOT NULL DEFAULT 'pendiente',
    total DECIMAL(10,2),
    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

--campos minimos: id_pedido, id_pizza y cantidad.
CREATE TABLE detalle_pedido (
    id_detalle       INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido        INT NOT NULL,
    id_pizza         INT NOT NULL,
    cantidad         INT NOT NULL DEFAULT 1,
    precio_unitario  INT NOT NULL,
    subtotal         INT NOT NULL,
    CONSTRAINT fk_detalle_pedido
        FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_detalle_pizza
        FOREIGN KEY (id_pizza) REFERENCES pizzas(id_pizza)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_cantidad CHECK (cantidad > 0)
);

