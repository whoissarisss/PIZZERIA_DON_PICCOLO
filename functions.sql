-- FUNCIÓN: total_pedido
-- Calcula el total de un pedido = (suma de pizzas) + costo de envío + IVA.
-- si el pedido no es a domicilio, no existe fila en domicilios y el
-- costo de envío queda en 0.
 
DELIMITER //
CREATE FUNCTION total_pedido(p_id_pedido INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_subtotal_pizzas DECIMAL(10,2) DEFAULT 0;
    DECLARE v_costo_envio     DECIMAL(10,2) DEFAULT 0;
    DECLARE v_tasa_iva        DECIMAL(4,2)  DEFAULT 0.19;   -- IVA 19%
    DECLARE v_iva             DECIMAL(10,2) DEFAULT 0;
    DECLARE v_total           INT           DEFAULT 0;

    SELECT IFNULL(SUM(subtotal), 0)
      INTO v_subtotal_pizzas
      FROM detalle_pedido
     WHERE id_pedido = p_id_pedido;

    SELECT IFNULL(costo_envio, 0)
      INTO v_costo_envio
      FROM domicilios
     WHERE id_pedido = p_id_pedido;
 
    SET v_iva = v_subtotal_pizzas * v_tasa_iva;
 
    SET v_total = ROUND(v_subtotal_pizzas + v_costo_envio + v_iva, 0);
 
    RETURN v_total;
END //
DELIMITER ;
 

-- FUNCIÓN: ganancia_neta_diaria
-- Ganancia neta de un día = ventas del día (pedidos entregados) - costo de los ingredientes usados ese día.
 
DELIMITER //
CREATE FUNCTION ganancia_neta_diaria(p_fecha DATE)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_ventas   DECIMAL(10,2) DEFAULT 0;
    DECLARE v_costos   DECIMAL(10,2) DEFAULT 0;
    DECLARE v_ganancia INT DEFAULT 0;
 
    -- Ventas: total de los pedidos entregados ese día
    SELECT IFNULL(SUM(p.total), 0)
      INTO v_ventas
      FROM pedidos p
     WHERE DATE(p.fecha_hora) = p_fecha
       AND p.estado = 'entregado';
 
    -- Costos: ingredientes consumidos por esas pizzas
    -- (cantidad pedida x cantidad requerida por receta x costo unitario)
    SELECT IFNULL(SUM(dp.cantidad * pi.cantidad_requerida * i.costo_unitario), 0)
      INTO v_costos
      FROM detalle_pedido dp
      JOIN pedidos p ON p.id_pedido = dp.id_pedido
      JOIN pizza_ingredientes pi ON pi.id_pizza = dp.id_pizza
      JOIN ingredientes i ON i.id_ingrediente = pi.id_ingrediente
     WHERE DATE(p.fecha_hora) = p_fecha AND p.estado = 'entregado';
 
    SET v_ganancia = ROUND(v_ventas - v_costos, 0);
 
    RETURN v_ganancia;
END //
DELIMITER ;
 

-- Ejemplos de uso:

-- SELECT fn_total_pedido(1);
-- SELECT fn_ganancia_neta_diaria('2026-08-26');