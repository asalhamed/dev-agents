# Contract: backend-dev / frontend-dev → qa-agent + reviewer

**Producers:** backend-dev, frontend-dev  
**Consumers:** qa-agent, reviewer  
**Trigger:** dev agent completes implementation of their assigned task

---

## Required Fields

```markdown
## IMPLEMENTATION SUMMARY

### Task Reference
**Task ID:** [T-NNN from task brief]
**Agent:** backend-dev | frontend-dev
**Task:** [copy from task brief — single sentence]
**Stack:** [Rust | Scala 3 | TS | Vue | etc.]
**Layer(s):** [domain | application | infrastructure | interface | frontend]

### Approach
<!-- REQUIRED: 2-5 sentences. What did you build and why this way? -->
[approach description]

### Files Changed
<!-- REQUIRED: Every file touched, with a one-line description of what changed -->
| File | Change |
|------|--------|
| `path/to/file.ext` | [what changed] |

### Contracts Implemented
<!-- REQUIRED: What did you implement from the task brief contract? -->
<!-- Reference the field names/types exactly as defined in shared/contracts/architect-output.md -->
| Contract item | Status | Notes |
|---------------|--------|-------|
| [API endpoint / event / schema] | ✅ Implemented / ⚠️ Partial / ❌ Deferred | [notes] |

### Domain Model Changes
<!-- REQUIRED for domain-layer tasks; "N/A" for infra/frontend tasks -->
**Added aggregates:** [list or "none"]
**Added value objects:** [list or "none"]
**Added domain events:** [list or "none"]
**Modified aggregates:** [description or "none"]

### FP / DDD Compliance
<!-- REQUIRED: Self-attestation against PRINCIPLES.md -->
- [ ] No infrastructure types in domain layer
- [ ] No business logic outside domain layer
- [ ] All errors are typed (no thrown exceptions in domain)
- [ ] No null / no unsafe absence
- [ ] No mutable state in domain or application layers
- [ ] Names from domain ubiquitous language
- [ ] All public functions are total (handle all inputs)

### Test Results
<!-- REQUIRED -->
**Command run:** `[exact command]`
**Result:** ✅ PASS | ❌ FAIL
**Coverage:** [before X%] → [after Y%]
**Threshold:** [Z%]
**New tests added:** [N]

### Open Issues
<!-- Optional: Anything qa-agent or reviewer should know -->
[list or "none"]

### Escalations Required
<!-- REQUIRED: "none" or a specific escalation request -->
[none | escalate to architect: [reason] | escalate to tech-lead: [reason]]
```

---

## Validation (qa-agent and reviewer must check on receipt)

Before proceeding:
- [ ] Task ID matches a known task brief
- [ ] All files changed are listed
- [ ] Contracts Implemented section references the architect output contract items
- [ ] FP/DDD compliance checklist is filled in (not all blank)
- [ ] Test results include coverage numbers
- [ ] Escalations field is present (even if "none")

**If any required field is missing:** send back to the producing agent with a list of gaps.

---

## Example (valid — Scala 3 backend)

```markdown
## IMPLEMENTATION SUMMARY

### Task Reference
**Task ID:** T-002
**Agent:** backend-dev
**Task:** Add confirm() method to Order aggregate that validates invariants and produces OrderConfirmed event
**Stack:** Scala 3
**Layer(s):** domain

### Approach
Added confirm() as a pure method on Order returning Either[OrderError, (Order, OrderConfirmed)].
The method enforces two invariants: orders must have items, and must be in Draft status.
OrderConfirmed is a new sealed case in the OrderEvent enum, carrying full item details per ADR-007.
No mocks or infrastructure needed — all pure.

### Files Changed
| File | Change |
|------|--------|
| `src/domain/order/Order.scala` | Added confirm() method |
| `src/domain/order/OrderEvents.scala` | Added OrderConfirmed case to OrderEvent enum |
| `src/domain/order/OrderError.scala` | Added AlreadyProcessed error case |
| `src/test/domain/order/OrderSpec.scala` | Added 4 tests for confirm() |

### Contracts Implemented
| Contract item | Status | Notes |
|---------------|--------|-------|
| OrderConfirmed event schema (ADR-007) | ✅ Implemented | All fields present including ConfirmedItem |
| confirm() returns (Order, OrderConfirmed) | ✅ Implemented | Wrapped in Either[OrderError, _] |
| EmptyOrder error | ✅ Implemented | |
| AlreadyProcessed error | ✅ Implemented | Covers all non-Draft statuses |

### Domain Model Changes
**Added aggregates:** none
**Added value objects:** none
**Added domain events:** OrderConfirmed
**Modified aggregates:** Order — added confirm() method

### FP / DDD Compliance
- [x] No infrastructure types in domain layer
- [x] No business logic outside domain layer
- [x] All errors are typed (no thrown exceptions in domain)
- [x] No null / no unsafe absence
- [x] No mutable state in domain or application layers
- [x] Names from domain ubiquitous language
- [x] All public functions are total (handle all inputs)

### Test Results
**Command run:** `sbt coverage test coverageReport`
**Result:** ✅ PASS
**Coverage:** 74% → 78%
**Threshold:** 75%
**New tests added:** 4

### Open Issues
none

### Escalations Required
none
```

---

## Example (valid — Rust backend)

```markdown
## IMPLEMENTATION SUMMARY

### Task Reference
**Task ID:** T-004
**Agent:** backend-dev
**Task:** Implement Money value object with add() and currency validation
**Stack:** Rust
**Layer(s):** domain

### Approach
Implemented Money as a newtype struct with private fields and a validated constructor via `TryFrom`.
The `add()` method returns `Result<Money, DomainError>` — never panics on currency mismatch.
Currency is an enum (`USD`, `EUR`, `GBP`), not a String. All fields private, accessed via getters.

### Files Changed
| File | Change |
|------|--------|
| `src/domain/money.rs` | New Money struct, Currency enum, TryFrom impl, add() |
| `src/domain/errors.rs` | Added NegativeAmount, CurrencyMismatch variants to DomainError |
| `src/domain/mod.rs` | Added `pub mod money;` |
| `tests/domain/money_test.rs` | 5 unit tests + 1 proptest |

### Contracts Implemented
| Contract item | Status | Notes |
|---------------|--------|-------|
| Money value object (ADR-009) | ✅ Implemented | Private fields, validated constructor |
| Currency enum | ✅ Implemented | USD, EUR, GBP — exhaustive match |
| add() with currency check | ✅ Implemented | Returns Result, no panic |

### Domain Model Changes
**Added aggregates:** none
**Added value objects:** Money, Currency
**Added domain events:** none
**Modified aggregates:** none

### FP / DDD Compliance
- [x] No infrastructure types in domain layer
- [x] No business logic outside domain layer
- [x] All errors are typed (no thrown exceptions in domain)
- [x] No null / no unsafe absence — no unwrap() in non-test code
- [x] No mutable state in domain or application layers
- [x] Names from domain ubiquitous language
- [x] All public functions are total (handle all inputs)

### Test Results
**Command run:** `cargo test`
**Result:** ✅ PASS
**Coverage:** 79% → 84%
**Threshold:** 80%
**New tests added:** 6 (5 unit + 1 property-based)

### Open Issues
none

### Escalations Required
none
```
