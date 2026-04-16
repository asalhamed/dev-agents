# Eval: db-migration — 001 — Non-Nullable Column on Large Table

**Tags:** expand-contract, zero-downtime, NOT NULL, backfill
**Skill version tested:** initial

---

## Input (task brief)

```
Add a non-nullable 'currency' column (VARCHAR(3)) to the 'order_items' table
which currently has 2 million rows. The service must stay online during migration.
```

---

## Expected Behavior

The db-migration agent should:
1. Identify that adding NOT NULL to an existing table with data is a breaking change
2. Propose an expand-contract migration across 2 phases/releases
3. Phase 1: add nullable column, backfill existing rows with default value
4. Phase 2: add NOT NULL constraint after backfill is confirmed complete
5. Provide up and down scripts for each phase
6. Include explicit rollback procedure
7. Produce a `migration-plan` contract

---

## Pass Criteria

- [ ] Breaking change identified (NOT NULL on existing data)
- [ ] Two-phase approach: nullable first, then constraint
- [ ] Backfill strategy for 2M existing rows (batched, not single UPDATE)
- [ ] Up and down migration scripts for both phases
- [ ] Rollback procedure documented
- [ ] Application code changes noted (handle nullable during transition)
- [ ] `migration-plan` contract produced

---

## Fail Criteria

- Single migration that adds NOT NULL with DEFAULT in one step on 2M rows → ❌ potential downtime
- No rollback plan → ❌ missing safety net
- Missing down migrations → ❌ incomplete
- Ignores application code changes during transition → ❌ incomplete plan
