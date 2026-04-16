# Eval: docs-agent — 002 — ADR Index Update

**Tags:** ADR, documentation index, versioning, architecture decisions
**Skill version tested:** initial

---

## Input (task brief)

```
Update the ADR index after ADR-009 (Money value object) is accepted.
Current index has ADR-001 through ADR-008.
```

---

## Expected Behavior

The docs-agent should:
1. Add ADR-009 to the index with correct numbering
2. Set status to Accepted with current date
3. Leave existing entries unmodified
4. Handle supersedes/superseded-by fields
5. Produce a `docs-summary` contract

---

## Pass Criteria

- [ ] ADR-009 added with sequential numbering
- [ ] Title: "Money value object" (or equivalent)
- [ ] Status: Accepted
- [ ] Date populated correctly
- [ ] Existing ADR-001 through ADR-008 entries unchanged
- [ ] Supersedes/superseded-by populated or marked N/A
- [ ] `docs-summary` contract produced

---

## Fail Criteria

- ADR-009 numbering wrong (e.g., ADR-010, ADR-9) → ❌ inconsistent
- Existing entries modified → ❌ history corruption
- Missing status or date → ❌ incomplete metadata
- No `docs-summary` contract → ❌ contract violation
