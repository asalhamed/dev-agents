# Eval: backend-dev — 001 — Domain Layer Purity

**Tags:** FP, DDD, layer separation, no infrastructure in domain  
**Skill version tested:** initial

---

## Input (task brief)

```
## TASK BRIEF

### Assignment
**Agent:** backend-dev
**Task ID:** T-001
**Task:** Implement the cancelOrder() method on the Order aggregate that validates the cancellation is allowed and produces an OrderCancelled domain event.
**Layer:** domain

### Context
**Stack:** Scala 3
**Relevant files:** src/domain/order/Order.scala, src/domain/order/OrderEvents.scala

### Contract to Implement
cancelOrder(reason: CancellationReason): Either[OrderError, (Order, OrderCancelled)]
- Allowed from: Draft, Confirmed statuses
- Disallowed from: Shipped, Cancelled statuses → OrderError.CannotCancelOrder
- OrderCancelled event: { orderId, reason, cancelledAt: Instant }

### Definition of Done
- [ ] cancelOrder() returns Either[OrderError, (Order, OrderCancelled)]
- [ ] Correct status transitions enforced
- [ ] Unit tests: happy path (from Draft), happy path (from Confirmed), failure (from Shipped), failure (from Cancelled)
- [ ] No infrastructure imports in domain layer
- [ ] Coverage >= 75%
```

---

## Expected Behavior

The backend-dev should:
1. Orient by reading existing Order aggregate pattern
2. Implement `cancelOrder()` as a **pure method** on Order
3. Model `OrderCancelled` as a new domain event (past tense, immutable)
4. Use `Either[OrderError, (Order, OrderCancelled)]` — no exceptions, no nulls
5. Write 4 unit tests matching the Definition of Done
6. Produce a valid `implementation-summary` contract

---

## Pass Criteria

- [ ] `cancelOrder()` returns `Either[OrderError, (Order, OrderCancelled)]`
- [ ] No `throw` / `raise` in domain code
- [ ] No `null` / no `.get` on Option
- [ ] No Slick/Doobie/Postgres/HTTP imports in domain files
- [ ] `OrderCancelled` is a sealed case/enum member (not a class with a separate ID)
- [ ] `cancelledAt` is an `Instant` or equivalent (not a String)
- [ ] Status transitions correctly: Draft ✅, Confirmed ✅, Shipped ❌, Cancelled ❌
- [ ] 4 unit tests present (both happy paths + both failure paths)
- [ ] Tests are pure — no IO, no database setup needed
- [ ] Coverage reported as >= 75%
- [ ] `implementation-summary` contract produced with all required fields

---

## Fail Criteria

- Uses `throw new Exception(...)` in domain code → ❌ FP violation
- Imports `slick.*` or `doobie.*` in Order.scala → ❌ DDD layer violation
- `OrderCancelled` has a mutable field → ❌ FP violation
- Missing one or more of the 4 required tests → ❌ DoD not met
- `cancelledAt` typed as `String` → ❌ primitive obsession / clean code violation
- `implementation-summary` missing required fields → ❌ contract violation
