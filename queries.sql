-- queries.sql : operational pack
USE inventory_ledger;
-- 1. Current stock by warehouse
SELECT * FROM v_current_stock ORDER BY warehouse_code, sku;
-- 2. Low stock needing reorder
SELECT * FROM v_low_stock ORDER BY shortfall DESC;
-- 3. Ledger for one product (audit trail)
SELECT movement_id, warehouse_id, movement_type, quantity, reference_type, reference_id, moved_at
FROM stock_movements WHERE product_id = 1 ORDER BY moved_at, movement_id;
-- 4. Running balance per product using a window function
SELECT product_id, movement_id, moved_at, quantity,
       SUM(quantity) OVER (PARTITION BY warehouse_id, product_id ORDER BY moved_at, movement_id) AS running_balance
FROM stock_movements ORDER BY warehouse_id, product_id, moved_at;
-- 5. Net movement by type in the last 30 days
SELECT movement_type, COUNT(*) AS movements, SUM(quantity) AS net_quantity
FROM stock_movements WHERE moved_at >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY)
GROUP BY movement_type ORDER BY movement_type;
-- 6. Products that have never moved
SELECT p.sku, p.name FROM products p
LEFT JOIN stock_movements m ON m.product_id = p.product_id
WHERE m.movement_id IS NULL;
