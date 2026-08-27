DROP DATABASE IF EXISTS pizzeria_don_piccolo_sariss;
CREATE DATABASE pizzeria_don_piccolo_sariss;
USE pizzeria_don_piccolo_sariss;

CREATE TABLE persona (
    id_persona          INT AUTO_INCREMENT PRIMARY KEY,
    nombre              VARCHAR(100) NOT NULL,
    apellido            VARCHAR(100) NOT NULL,
    direccion           VARCHAR(200) NOT NULL,
    correo_electronico  VARCHAR(100) UNIQUE,
    fecha_registro      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE clientes (
    id_cliente  INT PRIMARY KEY,
    telefono    VARCHAR(20) NOT NULL,
    CONSTRAINT fk_cliente_persona
        FOREIGN KEY (id_cliente) REFERENCES persona(id_persona)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE zonas (
    id_zona          INT AUTO_INCREMENT PRIMARY KEY,
    nombre_zona      VARCHAR(50) NOT NULL UNIQUE,
    costo_domicilio  INT NOT NULL,
    CONSTRAINT chk_costo_domicilio CHECK (costo_domicilio >= 0)
);

CREATE TABLE repartidores (
    id_repartidor  INT PRIMARY KEY,
    telefono       VARCHAR(20),
    id_zona        INT NOT NULL,
    estado         ENUM('disponible','no disponible') NOT NULL DEFAULT 'disponible',
    CONSTRAINT fk_repartidor_persona
        FOREIGN KEY (id_repartidor) REFERENCES persona(id_persona)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_repartidor_zona
        FOREIGN KEY (id_zona) REFERENCES zonas(id_zona)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE ingredientes (
    id_ingrediente  INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(100)   NOT NULL UNIQUE,
    stock_actual    DECIMAL(10,2)  NOT NULL DEFAULT 0,
    stock_minimo    DECIMAL(10,2)  NOT NULL DEFAULT 0,
    unidad_medida   VARCHAR(20)    NOT NULL,   -- ej: gramos, ml, unidades
    costo_unitario  INT NOT NULL,
    CONSTRAINT chk_stock_actual   CHECK (stock_actual >= 0),
    CONSTRAINT chk_stock_minimo   CHECK (stock_minimo >= 0),
    CONSTRAINT chk_costo_unitario CHECK (costo_unitario >= 0)
);

CREATE TABLE pizzas (
    id_pizza     INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    tamaño       ENUM('personal','mediana','grande','familiar') NOT NULL,
    precio_base  INT NOT NULL,
    tipo         ENUM('clasica','vegetariana','especial') NOT NULL,
    disponible   BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_precio_base CHECK (precio_base > 0)
);

CREATE TABLE pizza_ingredientes (
    id_pizza            INT NOT NULL,
    id_ingrediente      INT NOT NULL,
    cantidad_requerida  DECIMAL(10,2) NOT NULL,   -- cantidad usada por cada pizza
    PRIMARY KEY (id_pizza, id_ingrediente),
    CONSTRAINT fk_pi_pizza
        FOREIGN KEY (id_pizza) REFERENCES pizzas(id_pizza)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pi_ingrediente
        FOREIGN KEY (id_ingrediente) REFERENCES ingredientes(id_ingrediente)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_cantidad_requerida CHECK (cantidad_requerida > 0)
);

CREATE TABLE pedidos (
    id_pedido     INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente    INT NOT NULL,
    fecha_hora    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metodo_pago   ENUM('efectivo','tarjeta','transferencia') NOT NULL,
    estado        ENUM('pendiente','en preparacion','entregado','cancelado')
                  NOT NULL DEFAULT 'pendiente',
    es_domicilio  BOOLEAN NOT NULL DEFAULT TRUE,
    total         INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

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

CREATE TABLE domicilios (
    id_domicilio   INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido      INT NOT NULL UNIQUE,
    id_repartidor  INT NOT NULL,
    id_zona        INT NOT NULL,
    hora_salida    DATETIME,
    hora_entrega   DATETIME,
    costo_envio    INT NOT NULL,
    CONSTRAINT fk_domicilio_pedido
        FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_domicilio_repartidor
        FOREIGN KEY (id_repartidor) REFERENCES repartidores(id_repartidor)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_domicilio_zona
        FOREIGN KEY (id_zona) REFERENCES zonas(id_zona)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_costo_envio CHECK (costo_envio >= 0)
);

CREATE TABLE pagos (
    id_pago      INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido    INT NOT NULL UNIQUE,
    monto        INT NOT NULL,
    metodo_pago  ENUM('efectivo','tarjeta','transferencia') NOT NULL,
    fecha_pago   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_pago  ENUM('pendiente','pagado','rechazado') NOT NULL DEFAULT 'pendiente',
    CONSTRAINT fk_pago_pedido
        FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
        ON DELETE CASCADE ON UPDATE CASCADE
);


 
ALTER TABLE ingredientes
    MODIFY COLUMN stock_actual   INT NOT NULL DEFAULT 0,
    MODIFY COLUMN stock_minimo   INT NOT NULL DEFAULT 0,
    MODIFY COLUMN costo_unitario INT NOT NULL;
 

ALTER TABLE zonas
    MODIFY COLUMN costo_domicilio INT NOT NULL;
 

ALTER TABLE pizzas
    MODIFY COLUMN precio_base INT NOT NULL;
 

ALTER TABLE pizza_ingredientes
    MODIFY COLUMN cantidad_requerida INT NOT NULL;
 

ALTER TABLE pedidos
    MODIFY COLUMN total INT NOT NULL DEFAULT 0;
 

ALTER TABLE detalle_pedido
    MODIFY COLUMN precio_unitario INT NOT NULL,
    MODIFY COLUMN subtotal        INT NOT NULL;
 
ALTER TABLE domicilios
    MODIFY COLUMN costo_envio INT NOT NULL;
 
    
ALTER TABLE pagos
    MODIFY COLUMN monto INT NOT NULL;
 


-- =====================================================================
-- PERSONA 
-- =====================================================================
INSERT INTO persona (nombre, apellido, direccion, correo_electronico) VALUES
('Laura',   'Gómez',   'Cra 10 #15-20', 'laura.gomez@example.com'),   -- id 1 (cliente)
('Andrés',  'Pérez',   'Cll 45 #12-08', 'andres.perez@example.com'),  -- id 2 (cliente)
('Camila',  'Rojas',   'Cra 20 #34-10', 'camila.rojas@example.com'),  -- id 3 (cliente)
('Julián',  'Torres',  'Cll 8 #22-05',  'julian.torres@example.com'), -- id 4 (repartidor)
('Mateo',   'Suárez',  'Cra 15 #40-02', 'mateo.suarez@example.com');  -- id 5 (repartidor)
 
-- =====================================================================
-- CLIENTES 
-- =====================================================================
INSERT INTO clientes (id_cliente, telefono) VALUES
(1, '3001234567'),
(2, '3012345678'),
(3, '3023456789');
 
-- =====================================================================
-- ZONAS
-- =====================================================================
INSERT INTO zonas (nombre_zona, costo_domicilio) VALUES
('Norte',  5000),   
('Centro', 3500),  
('Sur',    6000);  
 
-- =====================================================================
-- REPARTIDORES
-- =====================================================================
INSERT INTO repartidores (id_repartidor, telefono, id_zona, estado) 
VALUES (4, '3101112233', 1, 'disponible'), (5, '3114445566', 2, 'disponible'); 
 
-- =====================================================================
-- INGREDIENTES
-- Costo unitario = precio por gramo, calculado a partir de tus recetas
-- (ejemplito -> Queso Mozzarella: $4.800 COP / 200 g = $24 COP/g)
-- =====================================================================
INSERT INTO ingredientes (nombre, stock_actual, stock_minimo, unidad_medida, costo_unitario) VALUES
('Masa madurada',                     15000, 3000, 'gramos', 2),   -- id 1
('Salsa de tomate',                    8000, 1500, 'gramos', 7),   -- id 2
('Queso Mozzarella',                  12000, 2500, 'gramos', 24),  -- id 3
('Tomate fresco en rodajas',           3000, 800,  'gramos', 4),   -- id 4
('Albahaca fresca',                     300, 400,  'gramos', 15),  -- id 5  
('Aceite de oliva',                     900, 1000, 'gramos', 30),  -- id 6 
('Pepperoni Premium',                  4000, 1000, 'gramos', 45),  -- id 7
('Jamón de cerdo',                     3500, 800,  'gramos', 16),  -- id 8
('Piña calada en almíbar',             2500, 500,  'gramos', 8),   -- id 9
('Pechuga de pollo desmechada/cocida', 4000, 1000, 'gramos', 18),  -- id 10
('Champiñones laminados',              2200, 500,  'gramos', 22),  -- id 11
('Salami',                             1800, 500,  'gramos', 35),  -- id 12
('Carne molida sazonada',              3000, 700,  'gramos', 15),  -- id 13
('Tocineta en trozos',                 1600, 400,  'gramos', 40);  -- id 14
 
-- =====================================================================
-- PIZZAS
-- Precio de venta fijo por tamaño
-- =====================================================================
INSERT INTO pizzas (nombre, tamaño, precio_base, tipo, disponible) VALUES
('Margarita',                'mediana',  22000, 'clasica',     TRUE),  -- id 1
('Pepperoni',                'grande',   32000, 'clasica',     TRUE),  -- id 2
('Hawaiana',                 'familiar', 45000, 'especial',    TRUE),  -- id 3
('Pollo con Champiñones',    'grande',   35000, 'especial',    TRUE),  -- id 4
('Carnes / Suprema',         'familiar', 48000, 'especial',    TRUE);  -- id 5
 
-- =====================================================================
-- PIZZA_INGREDIENTES (receta de cada pizza, en gramos)
-- Costo total de ingredientes por pizza (verificable sumando):
--   Margarita: 6.475 | Pepperoni: 8.080 | Hawaiana: 7.460
--   Pollo con Champiñones: 8.100 | Carnes/Suprema: 9.290
-- =====================================================================
INSERT INTO pizza_ingredientes (id_pizza, id_ingrediente, cantidad_requerida) VALUES
-- Margarita (1): masa, salsa, queso, tomate fresco, albahaca, aceite de oliva
(1, 1, 250), (1, 2, 80), (1, 3, 200), (1, 4, 60), (1, 5, 5), (1, 6, 10),
-- Pepperoni (2): masa, salsa, queso, pepperoni premium
(2, 1, 250), (2, 2, 80), (2, 3, 180), (2, 7, 60),
-- Hawaiana (3): masa, salsa, queso, jamón, piña
(3, 1, 250), (3, 2, 80), (3, 3, 180), (3, 8, 80), (3, 9, 100),
-- Pollo con Champiñones (4): masa, salsa, queso, pollo, champiñones
(4, 1, 250), (4, 2, 80), (4, 3, 180), (4, 10, 90), (4, 11, 50),
-- Carnes / Suprema (5): masa, salsa, queso, jamón, salami, carne molida, tocineta
(5, 1, 250), (5, 2, 80), (5, 3, 160), (5, 8, 40), (5, 12, 40), (5, 13, 50), (5, 14, 40);
 
-- =====================================================================
-- PEDIDOS
-- =====================================================================
INSERT INTO pedidos (id_pedido, id_cliente, fecha_hora, metodo_pago, estado, es_domicilio, total) VALUES
(1, 1, '2026-08-25 12:30:00', 'tarjeta',      'entregado',      TRUE,  95440),  -- Laura
(2, 2, '2026-08-25 13:10:00', 'efectivo',     'entregado',      TRUE,  57050),  -- Andrés
(3, 3, '2026-08-25 19:45:00', 'transferencia','cancelado',      FALSE, 83300),  -- Camila (cancelado)
(4, 1, '2026-08-26 12:00:00', 'efectivo',     'en preparacion', TRUE,  103770), -- Laura
(5, 2, '2026-08-26 12:20:00', 'tarjeta',      'pendiente',      FALSE, 26180),  -- Andrés (recoge en tienda)
(6, 3, '2026-08-26 13:00:00', 'transferencia','pendiente',      FALSE, 76160);  -- Camila (recoge en tienda)
 
-- =====================================================================
-- DETALLE_PEDIDO
-- =====================================================================
INSERT INTO detalle_pedido (id_pedido, id_pizza, cantidad, precio_unitario, subtotal) VALUES
-- Pedido 1: 2 Margarita + 1 Pepperoni = 76.000
(1, 1, 2, 22000, 44000),
(1, 2, 1, 32000, 32000),
-- Pedido 2: 1 Hawaiana = 45.000
(2, 3, 1, 45000, 45000),
-- Pedido 3: 2 Pollo con Champiñones = 70.000 (cancelado)
(3, 4, 2, 35000, 70000),
-- Pedido 4: 1 Carnes/Suprema + 1 Pollo con Champiñones = 83.000
(4, 5, 1, 48000, 48000),
(4, 4, 1, 35000, 35000),
-- Pedido 5: 1 Margarita = 22.000
(5, 1, 1, 22000, 22000),
-- Pedido 6: 2 Pepperoni = 64.000
(6, 2, 2, 32000, 64000);
 
-- =====================================================================
-- DOMICILIOS (solo pedidos con es_domicilio = TRUE: 1, 2 y 4)
-- =====================================================================
INSERT INTO domicilios (id_pedido, id_repartidor, id_zona, hora_salida, hora_entrega, costo_envio) VALUES
(1, 4, 1, '2026-08-25 12:45:00', '2026-08-25 13:15:00', 5000),  -- entregado
(2, 5, 2, '2026-08-25 13:20:00', '2026-08-25 13:50:00', 3500),  -- entregado
(4, 5, 1, NULL, NULL, 5000); -- aún en preparación, sin salir
 
-- =====================================================================
-- PAGOS
-- (el pedido 3 se canceló, así que no se registra pago)
-- =====================================================================
INSERT INTO pagos (id_pedido, monto, metodo_pago, fecha_pago, estado_pago) VALUES
(1, 95440,  'tarjeta',      '2026-08-25 13:15:00', 'pagado'),
(2, 57050,  'efectivo',     '2026-08-25 13:50:00', 'pagado'),
(4, 103770, 'efectivo',     '2026-08-26 12:00:00', 'pendiente'),
(5, 26180,  'tarjeta',      '2026-08-26 12:20:00', 'pendiente'),
(6, 76160,  'transferencia','2026-08-26 13:00:00', 'pendiente');
 

