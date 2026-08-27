
-- 1) Clientes con pedidos entre dos fechas (BETWEEN)
SELECT p.nombre, p.apellido, p.id_pedido, p.fecha_hora
FROM pedidos p
JOIN clientes c ON c.id_cliente = p.id_cliente
JOIN persona per ON per.id_persona = c.id_cliente
WHERE p.fecha_hora BETWEEN '2026-08-25 00:00:00' AND '2026-08-26 23:59:59'
ORDER BY p.fecha_hora;


-- 2) Pizzas más vendidas (GROUP BY y COUNT)
-- Se usa SUM(cantidad) para contar unidades vendidas, no solo los pedidos.

SELECT pz.nombre, pz.tamaño, SUM(dp.cantidad) AS unidades_vendidas
FROM detalle_pedido dp
JOIN pizzas pz  ON pz.id_pizza = dp.id_pizza
JOIN pedidos p  ON p.id_pedido = dp.id_pedido
WHERE p.estado <> 'cancelado'
GROUP BY pz.id_pizza, pz.nombre, pz.tamaño
ORDER BY unidades_vendidas DESC;


-- 3) Pedidos (domicilios) por repartidor (JOIN)
-- LEFT JOIN para que también aparezcan los repartidores que no tienen domicilios asignados.

SELECT r.id_repartidor, CONCAT(per.nombre, ' ', per.apellido) AS repartidor, COUNT(d.id_domicilio) AS total_domicilios
FROM repartidores r
JOIN persona per ON per.id_persona = r.id_repartidor
LEFT JOIN domicilios d ON d.id_repartidor = r.id_repartidor
GROUP BY r.id_repartidor, repartidor
ORDER BY total_domicilios DESC;


-- 4) Promedio de tiempo de entrega por zona (AVG y JOIN)
-- Solo se tienen en cuentaa domicilios ya entregados (hora_entrega registrada).

SELECT z.nombre_zona, ROUND(AVG(TIMESTAMPDIFF(MINUTE, d.hora_salida, d.hora_entrega)), 1) AS promedio_minutos_entrega
FROM domicilios d
JOIN zonas z ON z.id_zona = d.id_zona
WHERE d.hora_entrega IS NOT NULL
GROUP BY z.id_zona, z.nombre_zona;

-- 5) Clientes que gastaron más de un monto determinado (HAVING)
-- Ejemplo: clientes que han gastado más de $50.000 (sin contar los pedidos cancelados)

SELECT c.id_cliente, CONCAT(per.nombre, ' ', per.apellido) AS cliente, SUM(p.total) AS total_gastado
FROM pedidos p
JOIN clientes c   ON c.id_cliente = p.id_cliente
JOIN persona per  ON per.id_persona = c.id_cliente
WHERE p.estado <> 'cancelado'
GROUP BY c.id_cliente, cliente
HAVING SUM(p.total) > 50000
ORDER BY total_gastado DESC;


-- 6) Búsqueda por coincidencia parcial del nombre de la pizza (LIKE)
-- Ejemplo: pizzas que contienen "pollo" en el nombre

SELECT id_pizza, nombre, tamaño, precio_base
FROM pizzas
WHERE nombre LIKE '%pollo%';


-- 7) Subconsulta: clientes frecuentes (más de 5 pedidos en un mismo mes)
-- La subconsulta agrupa los pedidos por cliente y por mes.

SELECT c.id_cliente, per.nombre, per.apellido
FROM clientes c
JOIN persona per ON per.id_persona = c.id_cliente
WHERE c.id_cliente IN (SELECT p.id_cliente FROM pedidos p WHERE p.estado <> 'cancelado' GROUP BY p.id_cliente, YEAR(p.fecha_hora), MONTH(p.fecha_hora) HAVING COUNT(*) > 5
);


- 