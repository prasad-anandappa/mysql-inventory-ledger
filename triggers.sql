-- triggers.sql : maintain balances, enforce append-only ledger
USE inventory_ledger;
DELIMITER $$
CREATE TRIGGER trg_movements_after_insert
AFTER INSERT ON stock_movements
FOR EACH ROW
BEGIN
  INSERT INTO stock_balances (warehouse_id, product_id, quantity_on_hand, last_movement_at)
  VALUES (NEW.warehouse_id, NEW.product_id, NEW.quantity, NEW.moved_at)
  ON DUPLICATE KEY UPDATE
    quantity_on_hand = quantity_on_hand + NEW.quantity,
    last_movement_at = NEW.moved_at;
END$$
CREATE TRIGGER trg_movements_no_update
BEFORE UPDATE ON stock_movements
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'stock_movements is append-only: updates are not allowed';
END$$
CREATE TRIGGER trg_movements_no_delete
BEFORE DELETE ON stock_movements
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'stock_movements is append-only: deletes are not allowed';
END$$
DELIMITER ;
