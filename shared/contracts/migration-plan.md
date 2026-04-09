# Migration Plan

**Producer:** db-migration
**Consumer(s):** tech-lead, backend-dev

## Required Fields

- **ADR reference** — which schema changes were analyzed
- **Change classification** — additive / breaking / data migration
- **Zero-downtime strategy** — how the migration runs without service interruption
- **Migration scripts** — up (apply) and down (rollback) for each phase
- **Backward compatibility** — can old code run against new schema during rolling deploy?
- **Rollback procedure** — explicit steps (not just "run down migration")
- **Index strategy** — new indexes and why

## Validation Checklist

- [ ] Both up and down scripts present for each phase
- [ ] Breaking changes use expand-contract or equivalent strategy
- [ ] Rollback procedure is explicit
- [ ] No data loss possible during rollback
- [ ] Indexes defined for foreign keys and common query columns
- [ ] Migration is idempotent (safe to run twice)

## Example (valid)

```markdown
## MIGRATION PLAN: Add Currency Column to Order Items (ADR-009)

**Change classification:** Breaking — adding NOT NULL column to table with existing rows
**Strategy:** Expand-contract over 2 releases

**Phase 1 (this release) — add nullable, backfill:**
```sql
-- up
ALTER TABLE order_items ADD COLUMN currency VARCHAR(3);
UPDATE order_items SET currency = 'USD' WHERE currency IS NULL;

-- down
ALTER TABLE order_items DROP COLUMN currency;
```

**Phase 2 (next release) — add constraint:**
```sql
-- up
ALTER TABLE order_items ALTER COLUMN currency SET NOT NULL;
ALTER TABLE order_items ADD CONSTRAINT chk_currency CHECK (currency IN ('USD','EUR','GBP'));

-- down
ALTER TABLE order_items DROP CONSTRAINT chk_currency;
ALTER TABLE order_items ALTER COLUMN currency DROP NOT NULL;
```

**Backward compatibility:** Phase 1 — old code can run (column nullable). Phase 2 — new code must populate currency before Phase 2 deploys.

**Rollback procedure:**
1. Run down script for current phase
2. Verify `SELECT COUNT(*) FROM order_items WHERE currency IS NULL` = 0 after phase 1 rollback

**Index strategy:** No new indexes — currency is not a query predicate.
```
