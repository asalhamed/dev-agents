# Eval: backend-dev — 002 — Rust Value Object

**Tags:** Rust, FP, DDD, newtype, self-validating value object  
**Skill version tested:** initial

---

## Input (task brief)

```
## TASK BRIEF

### Assignment
**Agent:** backend-dev
**Task ID:** T-003
**Task:** Implement a Money value object in Rust that represents a monetary amount with currency, validates that amount is non-negative, and supports addition of same-currency amounts.
**Layer:** domain
**Stack:** Rust

### Contract to Implement
Money {
  amount: u64      // in minor units (cents, halalas, etc.) — never negative
  currency: Currency  // enum: SAR | USD | EUR
}

Methods:
- Money::new(amount: u64, currency: Currency) -> Money  (infallible — u64 can't be negative)
- Money::add(self, other: Money) -> Result<Money, MoneyError>  (fails if currencies differ)
- Display: "100 SAR", "50 USD"

MoneyError::CurrencyMismatch { expected: Currency, got: Currency }

### Definition of Done
- [ ] Money is a newtype (not a raw struct with pub fields)
- [ ] Currency is an enum (SAR, USD, EUR)
- [ ] add() returns Result<Money, MoneyError> — panics not allowed
- [ ] Display impl produces "amount currency" format
- [ ] Tests: successful add, currency mismatch error, display format
- [ ] No unwrap() in non-test code
```

---

## Expected Behavior

The backend-dev should:
1. Implement `Money` as a proper newtype wrapping an inner struct (fields private)
2. Implement `Currency` as an enum
3. `add()` returns `Result<Money, MoneyError>` — no panics
4. Use `thiserror` for `MoneyError`
5. `Display` impl formatted correctly
6. Write at least 3 unit tests
7. Produce valid `implementation-summary`

---

## Pass Criteria

- [ ] `Money` fields are private (accessed via methods, not `money.amount` directly)
- [ ] `Currency` is an enum with at least SAR, USD, EUR
- [ ] `add()` signature is `fn add(self, other: Money) -> Result<Money, MoneyError>`
- [ ] `MoneyError` uses `thiserror::Error` derive
- [ ] No `unwrap()` / `expect()` in non-test code
- [ ] No `unsafe` block
- [ ] `Display` impl: output matches "100 SAR" format
- [ ] Test: same-currency add succeeds with correct amount
- [ ] Test: different-currency add returns `Err(MoneyError::CurrencyMismatch { .. })`
- [ ] Test: Display output is correct
- [ ] `implementation-summary` produced with all required fields

---

## Fail Criteria

- `Money` has public fields (`pub amount: u64`) → ❌ encapsulation violation
- `add()` panics on currency mismatch → ❌ FP violation (partial function)
- `MoneyError` is a plain String → ❌ untyped error
- `unwrap()` in non-test code → ❌ hard gate violation
- Missing currency mismatch test → ❌ DoD not met
