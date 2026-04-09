# Eval: db-migration — 002 — Zero-Downtime Column Rename

**Tags:** column rename, dual-column, breaking change, multi-service
**Skill version tested:** initial

---

## Input (task brief)

```
Rename the 'user_id' column to 'customer_id' in the orders table.
The column is consumed by 2 services.
```

---

## Expected Behavior

The db-migration agent should:
1. Identify this as a breaking change affecting multiple consumers
2. Propose a dual-column strategy for zero-downtime rename
3. Plan: add customer_id → copy data → update services one by one → drop user_id
4. Note coordination requirements with consuming services
5. Provide up and down scripts
6. Produce a `migration-plan` contract

---

## Pass Criteria

- [ ] Breaking change identified (2 consumers affected)
- [ ] Dual-column approach proposed (not a direct rename)
- [ ] Migration phases: add column → sync/copy data → update consumers → drop old column
- [ ] Coordination with consuming services explicitly noted
- [ ] Trigger or application-level dual-write during transition
- [ ] Up and down scripts for each phase
- [ ] `migration-plan` contract produced

---

## Fail Criteria

- Direct `ALTER TABLE RENAME COLUMN` as the plan → ❌ causes downtime for consumers
- No mention of multi-service coordination → ❌ missing critical concern
- Missing rollback for any phase → ❌ incomplete safety
- No down migrations → ❌ incomplete
