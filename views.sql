=====================================================================
-- VISTA 1: view_resumen_pedidos_cliente
-- Nombre del cliente, cantidad de pedidos y total gastado.
-- No cuenta los pedidos cancelados como "gastado".
-- =====================================================================
 
CREATE VIEW view_resumen_pedidos_cliente AS
SELECT c.id_cliente, CONCAT(per.nombre, ' ', per.apellido) AS nombre_cliente, COUNT(p.id_pedido) AS cantidad_pedidos, SUM(p.total) AS total_gastado, CONCAT('$', REPLACE(FORMAT(SUM(p.total), 0), ',', '.'), ' COP') AS total_gastado_formato
FROM clientes c
JOIN persona per ON per.id_persona = c.id_cliente
JOIN pedidos p ON p.id_cliente = c.id_cliente
WHERE p.estado <> 'cancelado'
GROUP BY c.id_cliente, nombre_cliente;
 

 
-- =====================================================================
-- VISTA 3: v_stock_bajo_minimo
-- Ingredientes cuyo stock actual ya está por debajo del mínimo permitido.
-- =====================================================================
 
CREATE VIEW view_stock_bajo_minimo AS
SELECT id_ingrediente, nombre, stock_actual, stock_minimo,unidad_medida, (stock_minimo - stock_actual) AS cantidad_faltante
FROM ingredientes
WHERE stock_actual < stock_minimo;
 

-- Ejemplos de uso:
-- SELECT * FROM view_resumen_pedidos_cliente;
-- SELECT * FROM view_desempeno_repartidores;
-- SELECT * FROM view_stock_bajo_minimo;

-- 