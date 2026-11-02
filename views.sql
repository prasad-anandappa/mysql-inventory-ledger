-- views.sql
USE inventory_ledger;
CREATE OR REPLACE VIEW v_current_stock AS
SELECT w.code AS warehouse_code, w.name AS warehouse_name, p.sku, p.name AS product_name,
       p.category, COALESCE(b.quantity_on_hand, 0) AS quantity_on_hand,
       p.unit_cost, COALESCE(b.quantity_on_hand, 0) * p.unit_cost AS stock_value
FROM products p
CROSS JOIN warehouses w
LEFT JOIN stock_balances b ON b.product_id = p.product_id AND b.warehouse_id = w.warehouse_id
WHERE p.is_active = 1 AND w.is_active = 1;
CREATE OR REPLACE VIEW v_low_stock AS
SELECT w.code AS warehouse_code, p.sku, p.name AS product_name,
       COALESCE(b.quantity_on_hand, 0) AS quantity_on_hand, p.reorder_point,
       p.reorder_point - COALESCE(b.quantity_on_hand, 0) AS shortfall
FROM products p
JOIN warehouses w ON w.is_active = 1
LEFT JOIN stock_balances b ON b.product_id = p.product_id AND b.warehouse_id = w.warehouse_id
WHERE COALESCE(b.quantity_on_hand, 0) <= p.reorder_point;
CREATE OR REPLACE VIEW v_stock_valuation AS
SELECT w.code AS warehouse_code, SUM(COALESCE(b.quantity_on_hand, 0) * p.unit_cost) AS total_value,
       COUNT(DISTINCT p.product_id) AS distinct_products
FROM warehouses w
LEFT JOIN stock_balances b ON b.warehouse_id = w.warehouse_id
LEFT JOIN products p ON p.product_id = b.product_id
GROUP BY w.code;
