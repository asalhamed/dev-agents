# Eval: qa-agent — 002 — Tests Verify Behavior, Not Implementation

**Tags:** FP testing, behavior vs implementation, test quality
**Skill version tested:** initial

---

## Input (task brief)

The qa-agent receives a task to write tests for the Money value object in Rust (Stack: Rust, Layer: domain).

The Money implementation has: pub struct Money with private amount: i64 and currency: Currency fields; Currency enum with USD/EUR/GBP; Money::new() returning Result rejecting negative amounts; add() returning Result with CurrencyMismatch error; amount() and currency() getters.

Definition of Done:
- Tests cover: construction, addition (same currency), addition (different currency), negative amount
- Tests verify behavior/domain invariants, NOT implementation details
- Pure tests — no mocks needed
- Property-based test for associativity of addition
- Coverage >= 80%

---

## Expected Behavior

The qa-agent should:
1. Write tests named after domain behavior ("money with same currency can be added")
2. NOT mirror the implementation (no "test that add returns Ok")
3. Include at least one property-based test
4. Verify domain invariants: non-negative amounts, currency matching
5. Produce a valid `qa-report` contract

---

## Pass Criteria

- [ ] Test names describe behavior in domain language (e.g., "given_usd_and_eur_when_add_then_currency_mismatch")
- [ ] No test mirrors implementation (e.g., no "test that new() sets amount field to input value")
- [ ] Tests verify: negative amount rejected, same-currency addition works, cross-currency addition fails
- [ ] At least one property-based test (proptest or quickcheck) for addition associativity or non-negative invariant
- [ ] All tests are pure — no I/O, no database, no mocking
- [ ] Test names use given/when/then or equivalent behavioral naming
- [ ] `qa-report` contract produced with all required fields
- [ ] Domain Invariants Verified table is filled in (not empty)

---

## Fail Criteria

- Tests named "test_new", "test_add", "test_currency" → implementation mirroring, not behavioral
- Tests verify internal field values instead of behavior → fragile / implementation coupled
- No property-based test when one was requested → DoD not met
- Tests require mocks for pure domain code → domain purity issue
- Missing `qa-report` or Domain Invariants table empty → contract violation
