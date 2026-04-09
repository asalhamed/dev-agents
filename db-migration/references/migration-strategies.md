# Migration Strategies Reference

Patterns for evolving database schemas in production without downtime.

---

## Expand-Contract (Parallel Change) Pattern

The core pattern for zero-downtime schema changes. Three phases:

1. **Expand** — add new structure alongside old (backward compatible)
2. **Migrate** — move data, update application to use new structure
3. **Contract** — remove old structure

### Example: Adding a NOT NULL Column

**Phase 1 — Expand:** Add column as nullable with default

```sql
-- Migration 001: Add column (nullable, no lock on existing rows)
ALTER TABLE orders ADD COLUMN priority VARCHAR(10) DEFAULT 'normal';
```

**Phase 2 — Migrate:** Backfill existing data, deploy app writing to new column

```sql
-- Migration 002: Backfill in batches
UPDATE orders SET priority = 'normal'
WHERE priority IS NULL
  AND id BETWEEN 1 AND 10000;
-- Repeat for next batch...
```

Application now writes `priority` on all new rows.

**Phase 3 — Contract:** Add NOT NULL constraint

```sql
-- Migration 003: After backfill is verified complete
ALTER TABLE orders ALTER COLUMN priority SET NOT NULL;
```

### Example: Renaming a Column

Never rename directly — `ALTER TABLE ... RENAME COLUMN` breaks running application instances.

**Phase 1 — Expand:**

```sql
-- Add new column
ALTER TABLE orders ADD COLUMN customer_email VARCHAR(255);

-- Create trigger to keep in sync during transition
CREATE OR REPLACE FUNCTION sync_order_email() RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    NEW.customer_email := COALESCE(NEW.customer_email, NEW.email);
    NEW.email := COALESCE(NEW.email, NEW.customer_email);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER order_email_sync
  BEFORE INSERT OR UPDATE ON orders
  FOR EACH ROW EXECUTE FUNCTION sync_order_email();
```

**Phase 2 — Migrate:**

```sql
-- Backfill
UPDATE orders SET customer_email = email WHERE customer_email IS NULL;
```

Deploy application reading/writing `customer_email` instead of `email`.

**Phase 3 — Contract:**

```sql
-- After all app instances use customer_email
DROP TRIGGER order_email_sync ON orders;
DROP FUNCTION sync_order_email();
ALTER TABLE orders DROP COLUMN email;
```

### Example: Changing a Column Type

Changing `price` from `INTEGER` (cents) to `NUMERIC(10,2)` (dollars).

**Phase 1 — Expand:**

```sql
ALTER TABLE products ADD COLUMN price_decimal NUMERIC(10,2);

CREATE OR REPLACE FUNCTION sync_product_price() RETURNS TRIGGER AS $$
BEGIN
  IF NEW.price_decimal IS NULL AND NEW.price IS NOT NULL THEN
    NEW.price_decimal := NEW.price / 100.0;
  END IF;
  IF NEW.price IS NULL AND NEW.price_decimal IS NOT NULL THEN
    NEW.price := (NEW.price_decimal * 100)::INTEGER;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER product_price_sync
  BEFORE INSERT OR UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION sync_product_price();
```

**Phase 2 — Migrate:**

```sql
UPDATE products SET price_decimal = price / 100.0 WHERE price_decimal IS NULL;
```

**Phase 3 — Contract:**

```sql
DROP TRIGGER product_price_sync ON products;
DROP FUNCTION sync_product_price();
ALTER TABLE products DROP COLUMN price;
ALTER TABLE products RENAME COLUMN price_decimal TO price;
```

---

## Blue-Green Schema Deployment

Maintain two database schemas and switch traffic between them.

**When to use:**
- Major schema restructuring that can't be done incrementally
- Complete table redesign

**Tradeoffs:**
- ✅ Clean cutover, easy rollback
- ❌ Requires double storage during transition
- ❌ Complex data synchronization
- ❌ Requires application support for schema switching

**Typically not worth it** for individual column changes — expand-contract is simpler.
Reserve for wholesale schema redesigns or major version upgrades.

---

## Zero-Downtime Index Creation

### PostgreSQL

```sql
-- ❌ Blocks writes for the entire duration
CREATE INDEX idx_orders_status ON orders(status);

-- ✅ Non-blocking — allows writes during index build
CREATE INDEX CONCURRENTLY idx_orders_status ON orders(status);
```

**Caveats:**
- `CONCURRENTLY` cannot run inside a transaction block
- If it fails partway, it leaves an `INVALID` index — check with:
  ```sql
  SELECT indexrelid::regclass, indisvalid FROM pg_index WHERE NOT indisvalid;
  ```
- Drop invalid index and retry: `DROP INDEX CONCURRENTLY idx_orders_status;`
- Takes longer than regular index creation (two table scans)

### MySQL

```sql
-- MySQL 5.6+ supports online DDL for most index operations
ALTER TABLE orders ADD INDEX idx_orders_status (status), ALGORITHM=INPLACE, LOCK=NONE;
```

`ALGORITHM=INPLACE, LOCK=NONE` is the closest MySQL equivalent to PostgreSQL's `CONCURRENTLY`.

---

## Safe Column Rename (Full Timeline)

| Step | Migration | App Deploy | Duration |
|------|-----------|------------|----------|
| 1. Add new column + sync trigger | `ALTER TABLE ADD COLUMN` + trigger | — | Minutes |
| 2. Backfill existing data | Batch `UPDATE` | — | Hours (large tables) |
| 3. Deploy app using new column | — | Reads/writes new column, falls back to old | Rolling deploy |
| 4. Verify all instances use new column | — | Monitor for old column writes | 1-2 deploy cycles |
| 5. Drop trigger and old column | `DROP TRIGGER` + `ALTER TABLE DROP COLUMN` | — | Minutes |

**Total timeline:** Typically 1-2 weeks for large production systems with multiple deploy cycles.

---

## Data Migration Safety

### Batch Sizes

```sql
-- ❌ Full table lock on large table
UPDATE orders SET priority = 'normal' WHERE priority IS NULL;

-- ✅ Batch processing
DO $$
DECLARE
  batch_size INT := 5000;
  rows_updated INT;
BEGIN
  LOOP
    UPDATE orders SET priority = 'normal'
    WHERE id IN (
      SELECT id FROM orders
      WHERE priority IS NULL
      LIMIT batch_size
      FOR UPDATE SKIP LOCKED
    );

    GET DIAGNOSTICS rows_updated = ROW_COUNT;
    EXIT WHEN rows_updated = 0;

    RAISE NOTICE 'Updated % rows', rows_updated;
    PERFORM pg_sleep(0.1);  -- Brief pause to reduce lock contention
  END LOOP;
END $$;
```

### Timeout Handling

```sql
-- Set statement timeout to prevent runaway queries
SET statement_timeout = '30s';

-- For the migration session
SET lock_timeout = '5s';  -- Don't wait forever for locks
```

### Idempotency Requirement

Every migration must be safe to run multiple times:

```sql
-- ✅ Idempotent — IF NOT EXISTS
CREATE TABLE IF NOT EXISTS audit_log (...);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS priority VARCHAR(10);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_status ON orders(status);

-- ✅ Idempotent — WHERE clause prevents double-processing
UPDATE orders SET priority = 'normal' WHERE priority IS NULL;
```

### Dry-Run Mode

Before running data migrations on production:

1. Run on a staging database with production-like data volume
2. Measure execution time and lock contention
3. Verify row counts before and after
4. Check that the migration is reversible

```sql
-- Dry run: wrap in transaction and rollback
BEGIN;
  -- Run migration statements...
  SELECT count(*) FROM orders WHERE priority IS NULL;  -- Should be 0
ROLLBACK;  -- Don't actually commit
```
