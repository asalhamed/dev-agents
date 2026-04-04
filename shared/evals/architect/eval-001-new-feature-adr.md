# Eval: architect — 001 — New Feature ADR

**Tags:** ADR format, domain modeling, DDD, contract definition  
**Skill version tested:** initial

---

## Input

```
We need to add a discount system to the order service. 
Discounts can be percentage-based or fixed-amount. 
A discount is applied to an entire order, not individual items. 
An order can have at most one active discount. 
Discounts expire after a configurable number of days.
```

---

## Expected Behavior

The architect should:
1. Produce a valid ADR following the format in `architect/SKILL.md`
2. Model the discount as a **Value Object** (no identity — it's a property of an order)
3. Identify that `Order` aggregate needs to change (owns the discount invariant)
4. Define an `OrderDiscountApplied` domain event (past tense)
5. Define the discount type as an ADT: `DiscountType` enum with `Percentage(rate)` and `FixedAmount(amount)`
6. Produce a handoff summary for tech-lead

---

## Pass Criteria

- [ ] ADR number, title, status present
- [ ] Problem statement written (2+ sentences)
- [ ] Bounded context identified (`order-management` or equivalent)
- [ ] Discount modeled as Value Object (not Entity — no separate ID)
- [ ] `DiscountType` modeled as ADT/enum with `Percentage` and `FixedAmount` variants
- [ ] `OrderDiscountApplied` domain event defined (past tense, contains discount details)
- [ ] `applyDiscount()` method on Order aggregate described with its invariant (at most one active discount)
- [ ] Expiry handled — mechanism described (e.g., `expiresAt` field on Discount value object)
- [ ] Contract section present: either API or domain event schema
- [ ] Must / Must not constraints listed
- [ ] Handoff summary for tech-lead present (ordered bullet list)

---

## Fail Criteria

- Discount modeled as Entity with its own ID → ❌ DDD violation (no identity needed)
- Domain event missing or in imperative form (`ApplyDiscount`) → ❌ event naming violation
- `DiscountType` represented as String or boolean flags → ❌ stringly-typed
- Infrastructure mentioned in domain model section (DB columns, Kafka topics in aggregate) → ❌ layer leak
- ADR format fields missing (no constraints, no contracts) → ❌ incomplete
- No handoff summary for tech-lead → ❌ missing output
