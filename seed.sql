-- seed.sql
USE inventory_ledger;
INSERT INTO warehouses (code, name, city) VALUES
  ('PHX-01','Phoenix Main Warehouse','Phoenix'),
  ('DAL-01','Dallas Distribution','Dallas'),
  ('SEA-01','Seattle Store Room','Seattle');
INSERT INTO products (sku, name, category, unit, unit_cost, reorder_point) VALUES
  ('WIDGET-001','Steel Widget','Hardware','each',12.50,20),
  ('BOLT-M8-100','M8 Bolt Pack (100)','Fasteners','pack',8.75,50),
  ('CABLE-USBC-2M','USB-C Cable 2m','Electronics','each',6.40,30),
  ('SENSOR-TEMP-01','Temperature Sensor','Electronics','each',24.00,15),
  ('BOX-SHIP-M','Medium Shipping Box','Packaging','each',1.20,100);
INSERT INTO stock_movements (warehouse_id, product_id, movement_type, quantity, reference_type, reference_id, note, created_by) VALUES
  (1,1,'RECEIPT',200,'PURCHASE_ORDER','PO-1001','Initial receipt','prasad'),
  (1,2,'RECEIPT',500,'PURCHASE_ORDER','PO-1001','Initial receipt','prasad'),
  (1,3,'RECEIPT',150,'PURCHASE_ORDER','PO-1002','Initial receipt','prasad'),
  (1,4,'RECEIPT',80,'PURCHASE_ORDER','PO-1003','Initial receipt','prasad'),
  (1,5,'RECEIPT',1000,'PURCHASE_ORDER','PO-1004','Initial receipt','prasad'),
  (1,1,'ISSUE',-35,'SALES_ORDER','SO-2001','Customer order','system'),
  (1,3,'ISSUE',-120,'SALES_ORDER','SO-2002','Customer order - leaves stock low','system'),
  (2,1,'RECEIPT',120,'PURCHASE_ORDER','PO-1005','Dallas receipt','prasad'),
  (2,1,'ISSUE',-20,'SALES_ORDER','SO-2003','Customer order','system'),
  (1,5,'ISSUE',-250,'SALES_ORDER','SO-2004','Bulk shipment','system');
