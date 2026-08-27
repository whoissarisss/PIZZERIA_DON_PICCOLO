-- =====================================================================
-- TRIGGER: descontar_stock
-- Cuando se agrega una pizza a un pedido (INSERT en detalle_pedido),
-- descuenta automáticamente del stock de cada ingrediente lo que esa
-- pizza necesita, multiplicado por la cantidad pedida.
-- =====================================================================
 
DELIMITER //
CREATE TRIGGER descontar_stock
AFTER INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
    UPDATE ingredientes i
      JOIN pizza_ingredientes pi ON pi.id_ingrediente = i.id_ingrediente
       SET i.stock_actual = i.stock_actual - (pi.cantidad_requerida * NEW.cantidad)
     WHERE pi.id_pizza = NEW.id_pizza;
END //
DELIMITER ;
 
-- =====================================================================
-- TRIGGER: repartidor_disponible
-- Cuando a un domicilio se le registra la hora_entrega (por ejemplo,
-- llamando a registrar_entrega), el repartidor asignado vuelve
-- automáticamente a estado 'disponible' para que le puedan asignar
-- un nuevo domicilio.
-- =====================================================================

DELIMITER //
CREATE TRIGGER repartidor_disponible
AFTER UPDATE ON domicilios
FOR EACH ROW
BEGIN
    IF NEW.hora_entrega IS NOT NULL AND OLD.hora_entrega IS NULL THEN
        UPDATE repartidores
           SET estado = 'disponible'
         WHERE id_repartidor = NEW.id_repartidor;
    END IF;
END //
DELIMITER ;
 
