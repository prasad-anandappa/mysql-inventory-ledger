# mysql-inventory-ledger

I built this MySQL 8 inventory system around one rule I care about in real stock systems: **the ledger is the truth, the balance is a cache**. Every stock change is an append-only row in `stock_movements`; I never update or delete a movement, and triggers actively block anyone who tries.

## What the schema models

- `warehouses` and `products` (SKU, category, unit cost, reorder point)
- `stock_movements` — append-only ledger: `RECEIPT`, `ISSUE`, `ADJUSTMENT`, `TRANSFER_IN`, `TRANSFER_OUT`, `RETURN`, with reference type/id for traceability
- `stock_balances` — current quantity on hand per warehouse/product, maintained by trigger

## Key pieces

- **Triggers** (`triggers.sql`) — an `AFTER INSERT` trigger upserts `stock_balances`; `BEFORE UPDATE` / `BEFORE DELETE` triggers on the ledger `SIGNAL` an error, enforcing append-only behaviour in the database itself, not just in application code.
- **Procedures** (`procedures.sql`) — `record_movement` rejects zero quantities and any movement that would drive stock negative; `transfer_stock` wraps an out/in pair in a transaction so a transfer can never half-apply.
- **Views** (`views.sql`) — `v_current_stock`, `v_low_stock` (on-hand at or below reorder point, with shortfall), and `v_stock_valuation`.
- **Queries** (`queries.sql`) — running balances with window functions, net movement by type, products that never moved, and the full ledger audit trail for a product.

## How to load it into MySQL 8

```bash
mysql -u root -p < schema.sql
mysql -u root -p inventory_ledger < seed.sql
mysql -u root -p inventory_ledger < triggers.sql
mysql -u root -p inventory_ledger < procedures.sql
mysql -u root -p inventory_ledger < views.sql
mysql -u root -p inventory_ledger < queries.sql   # optional: the reporting pack
```

Load order matters: seed data fires the balance trigger, so I create triggers before loading seed in a strict setup — or load seed after `triggers.sql` if I want balances populated from the seed movements. The seed as shipped inserts movements directly; re-running the trigger file before the seed gives fully derived balances.

## Validation

I validated these files on a machine with **no MySQL/MariaDB server and no Docker**, so I did **not** execute them against a live server and I am not claiming I did. Instead I ran a documented structural lint pass (Python, standard library only) over every `.sql` file in this repo: balanced parentheses and quotes after stripping strings/comments, statement termination, well-formed `DELIMITER` blocks, and a cross-file check that every table/view/procedure referenced is defined in this repo. All files passed that lint. Execution against MySQL 8 remains the reader's final check — the load commands above are the intended path.

## License

MIT — see `LICENSE`. I am a Software Engineer; this is a personal portfolio project.
