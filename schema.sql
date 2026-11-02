-- mysql-inventory-ledger : schema.sql
-- MySQL 8.0+, InnoDB, append-only stock ledger
CREATE DATABASE IF NOT EXISTS inventory_ledger CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE inventory_ledger;

CREATE TABLE warehouses (
  warehouse_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  code VARCHAR(20) NOT NULL,
  name VARCHAR(120) NOT NULL,
  city VARCHAR(80) NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (warehouse_id),
  UNIQUE KEY uq_warehouses_code (code)
) ENGINE=InnoDB;

CREATE TABLE products (
  product_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  sku VARCHAR(40) NOT NULL,
  name VARCHAR(160) NOT NULL,
  category VARCHAR(80) NOT NULL,
  unit VARCHAR(20) NOT NULL DEFAULT 'each',
  unit_cost DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  reorder_point INT NOT NULL DEFAULT 10,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (product_id),
  UNIQUE KEY uq_products_sku (sku),
  KEY idx_products_category (category)
) ENGINE=InnoDB;

CREATE TABLE stock_movements (
  movement_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  warehouse_id INT UNSIGNED NOT NULL,
  product_id INT UNSIGNED NOT NULL,
  movement_type ENUM('RECEIPT','ISSUE','ADJUSTMENT','TRANSFER_IN','TRANSFER_OUT','RETURN') NOT NULL,
  quantity INT NOT NULL,
  reference_type VARCHAR(40) NULL,
  reference_id VARCHAR(60) NULL,
  note VARCHAR(255) NULL,
  moved_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by VARCHAR(80) NOT NULL DEFAULT 'system',
  PRIMARY KEY (movement_id),
  KEY idx_movements_wh_product_time (warehouse_id, product_id, moved_at),
  KEY idx_movements_product_time (product_id, moved_at),
  CONSTRAINT fk_movements_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses (warehouse_id),
  CONSTRAINT fk_movements_product FOREIGN KEY (product_id) REFERENCES products (product_id),
  CONSTRAINT chk_movements_quantity_nonzero CHECK (quantity <> 0)
) ENGINE=InnoDB;

CREATE TABLE stock_balances (
  warehouse_id INT UNSIGNED NOT NULL,
  product_id INT UNSIGNED NOT NULL,
  quantity_on_hand INT NOT NULL DEFAULT 0,
  last_movement_at TIMESTAMP NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (warehouse_id, product_id),
  CONSTRAINT fk_balances_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses (warehouse_id),
  CONSTRAINT fk_balances_product FOREIGN KEY (product_id) REFERENCES products (product_id)
) ENGINE=InnoDB;
