# Eval: qa-agent — 001 — Domain Invariant Coverage

**Tags:** FP testing, domain invariants, Given/When/Then, no impl mirroring  
**Skill version tested:** initial

---

## Input

QA agent receives this implementation summary for a Scala 3 domain task:

```
Order.applyDiscount(discount: Discount): Either[OrderError, Order]

Invariants:
1. An order can only have one active discount at a time → OrderError.DiscountAlreadyApplied
2. A discount cannot be applied to a cancelled or shipped order → OrderError.InvalidStatusForDiscount
3. A zero-value discount is not allowed → OrderError.ZeroDiscount
4. Happy path: discount applied to Draft or Confirmed order with no existing discount → Right(updatedOrder)

Stack: Scala 3
Coverage threshold: 75%
Existing coverage: 71%
```

---

## Expected Behavior

The qa-agent should:
1. Write a test plan covering all 4 invariants
2. Write tests with Given/When/Then names describing domain behavior (not method names)
3. Write pure unit tests (no DB, no IO, no mocks for domain tests)
4. Cover all 4 invariants → expect coverage to rise above 75%
5. Produce a valid `qa-report` contract

---

## Pass Criteria

- [ ] Test plan produced before tests are written
- [ ] Test for invariant 1: applying second discount → `DiscountAlreadyApplied`
- [ ] Test for invariant 2: applying discount to Cancelled order → `InvalidStatusForDiscount`
- [ ] Test for invariant 2: applying discount to Shipped order → `InvalidStatusForDiscount`
- [ ] Test for invariant 3: zero-value discount → `ZeroDiscount`
- [ ] Test for happy path: Draft order + no existing discount → `Right(order)`
- [ ] Test for happy path: Confirmed order + no existing discount → `Right(order)`
- [ ] All test names describe behavior in plain language (not `testApplyDiscount_case1`)
- [ ] All tests are pure (no IO, no Ref, no database) — just calling domain methods
- [ ] Coverage reported as rising above 75%
- [ ] `qa-report` contract produced with domain invariants table filled in

---

## Fail Criteria

- Tests mirror implementation structure rather than testing domain invariants → ❌ impl mirroring
- Test names are `test1`, `testApplyDiscount`, `shouldWork` → ❌ non-descriptive
- Tests use `IO`, `Ref`, or mock infrastructure for pure domain code → ❌ FP testing violation
- Missing any of the 4 invariant scenarios → ❌ incomplete coverage
- Coverage doesn't rise above threshold with the new tests → ❌ DoD not met
- `qa-report` domain invariants table is empty → ❌ contract violation
