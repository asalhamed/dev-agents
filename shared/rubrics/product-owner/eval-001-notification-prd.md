# Eval: product-owner — 001 — Notification Preferences PRD

**Tags:** PRD, MoSCoW, acceptance criteria, Given/When/Then, success metrics
**Skill version tested:** initial

---

## Input (task brief)

```
We need to add notification preferences to the platform.
```

---

## Expected Behavior

The product-owner should:
1. Define a clear business objective (problem, audience, why now)
2. Scope the feature using MoSCoW with an explicit Won't-have list
3. Write acceptance criteria in Given/When/Then format
4. Capture SecurityAlert as a Must-have constraint
5. Define measurable success metrics
6. Produce a `prd` contract

---

## Pass Criteria

- [ ] Business objective clearly states: problem (too many notifications), audience (all users), why now
- [ ] MoSCoW scope with at least 2 items per category
- [ ] Won't-have list is explicit (not empty)
- [ ] Acceptance criteria in Given/When/Then format
- [ ] SecurityAlert minimum-one-channel constraint captured as Must-have
- [ ] Success metrics are measurable (e.g., "reduce unsubscribes by 30%")
- [ ] `prd` contract produced

---

## Fail Criteria

- No business objective or vague objective → ❌ why are we building this?
- No Won't-have list → ❌ scope creep risk
- Acceptance criteria are vague ("users should be able to...") → ❌ not testable
- SecurityAlert constraint missing → ❌ missed domain requirement
- Success metrics are unmeasurable ("improve user experience") → ❌ can't validate success
