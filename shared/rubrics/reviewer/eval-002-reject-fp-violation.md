# Eval: reviewer — 002 — Reject FP Violation

**Tags:** reviewer hard gate, FP violation, unwrap, partial function  
**Skill version tested:** initial

---

## Input

Reviewer receives this `implementation-summary` (contains FP violations):

```
## IMPLEMENTATION SUMMARY

### Task Reference
**Task ID:** T-003
**Agent:** backend-dev
**Task:** Implement Money value object in Rust
**Stack:** Rust
**Layer(s):** domain

### Approach
Implemented Money as a struct with amount and currency fields. Added add() method.

### Files Changed
| File | Change |
|------|--------|
| `src/domain/money.rs` | New Money struct |

### FP / DDD Compliance
- [x] No infrastructure types in domain layer
- [ ] All errors are typed  ← NOT checked
- [x] No mutable state

### Test Results
**Command run:** `cargo test`
**Result:** ✅ PASS
**Coverage:** 82%
**Threshold:** 80%
**New tests added:** 2
```

The reviewer also sees this code snippet in the diff:

```rust
pub struct Money {
    pub amount: i64,     // public fields — encapsulation broken
    pub currency: String, // String instead of enum — stringly typed
}

impl Money {
    pub fn add(&self, other: &Money) -> Money {
        if self.currency != other.currency {
            panic!("Currency mismatch!");  // panic in domain code — partial function
        }
        Money { amount: self.amount + other.amount, currency: self.currency.clone() }
    }
    
    pub fn from_str(s: &str) -> Money {
        let parts: Vec<&str> = s.split(' ').collect();
        Money {
            amount: parts[0].parse().unwrap(), // unwrap in non-test code
            currency: parts[1].to_string(),
        }
    }
}
```

---

## Expected Behavior

The reviewer should:
1. Issue `🔁 REQUEST CHANGES → backend-dev`
2. Identify all FP/DDD violations as **blocking**
3. List each violation with location and required fix

---

## Pass Criteria

- [ ] Decision is `🔁 REQUEST CHANGES → backend-dev` (not approve, not escalate)
- [ ] `panic!()` in `add()` flagged as blocking (partial function / FP violation)
- [ ] `unwrap()` in `from_str()` flagged as blocking (FP violation — hard gate)
- [ ] `pub amount: i64` flagged (public fields break encapsulation / clean code)
- [ ] `currency: String` flagged as blocking (stringly typed — should be enum)
- [ ] FP compliance checklist gap noted (errors not typed checkbox was unchecked)
- [ ] `reviewer-decision` contract format used with blocking issues table

---

## Fail Criteria

- Issues approve despite `panic!` in domain code → ❌ missed hard gate (critical failure)
- Issues approve despite `unwrap()` in non-test code → ❌ missed hard gate (critical failure)
- Escalates to architect (not a design issue — this is implementation) → ❌ wrong decision
- Flags `pub` fields as non-blocking → ❌ should be blocking (encapsulation)
- Missing any of the 4 violations above → ❌ incomplete review
