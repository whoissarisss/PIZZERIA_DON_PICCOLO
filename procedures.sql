- =====================================================================
-- PROCEDIMIENTO: registrar_entrega
-- Registra la hora de entrega de un domicilio y, en tiempo real,
-- cambia el estado del pedido a 'entregado'.
-- =====================================================================

DELIMITER // 
CREATE PROCEDURE registrar_entrega(IN p_id_pedido INT, IN p_hora_entrega DATETIME)
BEGIN
    UPDATE domicilios
       SET hora_entrega = p_hora_entrega
     WHERE id_pedido = p_id_pedido;
 
    UPDATE pedidos
       SET estado = 'entregado'
     WHERE id_pedido = p_id_pedido;
END //
DELIMITER ;
 
-- ejemplo de uso
-- CALL registrar_entrega(1, NOW());
 
 
 
 