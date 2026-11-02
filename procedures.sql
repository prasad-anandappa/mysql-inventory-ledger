-- procedures.sql
USE inventory_ledger;
DELIMITER $$
CREATE PROCEDURE record_movement(
  IN p_warehouse_id INT UNSIGNED,
  IN p_product_id INT UNSIGNED,
  IN p_movement_type VARCHAR(20),
  IN p_quantity INT,
  IN p_reference_type VARCHAR(40),
  IN p_reference_id VARCHAR(60),
  IN p_note VARCHAR(255)
)
BEGIN
  DECLARE v_on_hand INT DEFAULT 0;
  IF p_quantity = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'quantity must be non-zero';
  END IF;
  SELECT COALESCE(quantity_on_hand, 0) INTO v_on_hand
    FROM stock_balances
    WHERE warehouse_id = p_warehouse_id AND product_id = p_product_id;
  IF v_on_hand + p_quantity < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'insufficient stock for this movement';
  END IF;
  INSERT INTO stock_movements (warehouse_id, product_id, movement_type, quantity, reference_type, reference_id, note)
  VALUES (p_warehouse_id, p_product_id, p_movement_type, p_quantity, p_reference_type, p_reference_id, p_note);
END$$
CREATE PROCEDURE transfer_stock(
  IN p_from_warehouse INT UNSIGNED,
  IN p_to_warehouse INT UNSIGNED,
  IN p_product_id INT UNSIGNED,
  IN p_quantity INT,
  IN p_reference_id VARCHAR(60)
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;
  IF p_quantity <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'transfer quantity must be positive';
  END IF;
  START TRANSACTION;
  CALL record_movement(p_from_warehouse, p_product_id, 'TRANSFER_OUT', -p_quantity, 'TRANSFER', p_reference_id, 'Transfer out');
  CALL record_movement(p_to_warehouse, p_product_id, 'TRANSFER_IN', p_quantity, 'TRANSFER', p_reference_id, 'Transfer in');
  COMMIT;
END$$
DELIMITER ;
