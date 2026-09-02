
--Consulta SQL que muestre el nombre del cliente, el ID del pedido, el total y el estado del pedido.
SELECT c.id_cliente, CONCAT(per.nombre, ' ', per.apellido) AS cliente, p.id_pedido, SUM(p.total) AS total_gastado, p.estado 
FROM pedidos p
JOIN clientes c ON c.id_cliente = p.id_cliente
JOIN persona per ON per.id_persona = c.id_cliente
GROUP BY p.id_pedido;

--Mostrar los pedidos con estado entregado cuya fecha esté entre dos fechas dadas (usa BETWEEN).
SELECT CONCAT(per.nombre, ' ', per.apellido) AS Cliente, p.id_pedido, p.fecha_hora, p.estado
FROM pedidos p
JOIN clientes c ON c.id_cliente = p.id_cliente
JOIN persona per ON per.id_persona = c.id_cliente
WHERE p.fecha_hora BETWEEN '2026-08-25 00:00:00' AND '2026-08-26 23:59:59' AND p.estado='entregado'
ORDER BY p.fecha_hora;

--Mostrar cuántos pedidos se hicieron por cada método de pago y el total acumulado (GROUP BY).
SELECT p.id_pedido, p.metodo_pago, SUM(p.total) as total_acumulado
FROM pedidos p
GROUP BY p.id_pedido;


--Mostrar los clientes que tengan más de 5 pedidos en total (usa HAVING COUNT(*) > 5).
SELECT c.id_cliente, per.nombre, per.apellido
FROM clientes c
JOIN persona per ON per.id_persona = c.id_cliente
WHERE c.id_cliente IN (SELECT p.id_cliente FROM pedidos p WHERE p.estado <> 'cancelado' GROUP BY p.id_cliente, YEAR(p.fecha_hora), MONTH(p.fecha_hora) HAVING COUNT(*) > 5
);
