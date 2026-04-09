# Contract: qa-agent → reviewer

**Producer:** qa-agent  
**Consumer:** reviewer  
**Trigger:** qa-agent completes test writing and coverage check

---

## Required Fields

```markdown
## QA REPORT

### Task Reference
**Task ID(s) covered:** [T-NNN, T-NNN — list all implementation tasks this QA run covers]
**Stack:** [Rust | Scala 3 | TS | etc.]
**Test command:** `[exact command run]`

### Suite Result
**Overall:** ✅ PASS | ❌ FAIL
**Pre-existing failures:** [N failures not caused by this change — list them]
**New failures:** [N failures introduced by this change — list them]

### Coverage
| Metric | Before | After | Threshold | Status |
|--------|--------|-------|-----------|--------|
| Statement | X% | Y% | Z% | ✅ / ❌ |
| Branch | X% | Y% | Z% | ✅ / ❌ |

### Tests Written
<!-- REQUIRED: List every new test with what domain behavior it verifies -->
| Test name | Behavior verified | Type |
|-----------|------------------|------|
| `[test name]` | [domain behavior] | Unit / Integration / Property |

### Domain Invariants Verified
<!-- REQUIRED: Which domain invariants from the ADR/spec are now covered by tests? -->
| Invariant | Test(s) covering it | Status |
|-----------|---------------------|--------|
| [invariant description] | `[test name(s)]` | ✅ Covered / ⚠️ Partially / ❌ Not covered |

### Coverage Gaps
<!-- REQUIRED: "none" or a list of untested paths with justification -->
| Uncovered path | Reason not covered | Risk |
|---------------|-------------------|------|
| [path] | [reason — e.g. requires real DB] | Low / Medium / High |

### FP Testing Compliance
<!-- REQUIRED: Self-attestation -->
- [ ] Pure domain functions tested without mocks
- [ ] Mocks used only at infrastructure boundary
- [ ] Tests verify behavior / invariants, not implementation details
- [ ] Test names describe Given/When/Then or behavior in plain language
- [ ] Property-based tests used for domain rules with unbounded input space (if applicable)
- [ ] No flaky tests introduced (all tests pass consistently on re-run)

### Escalations Required
[none | block — coverage dropped: [from X% to Y%] | block — new failures: [list] | flag — pre-existing failures: [list]]
```

---

## Validation (reviewer must check on receipt)

- [ ] Task IDs match known task briefs
- [ ] Overall suite result is present
- [ ] Coverage table has before/after/threshold
- [ ] Domain Invariants Verified table is filled in (not empty)
- [ ] FP Testing Compliance checklist is filled in
- [ ] Escalations field is present

**Hard gates (reviewer blocks on these):**
- New failures present → reject immediately
- Coverage dropped below threshold → reject
- Domain invariants table is empty → send back to qa-agent

---

## Example (valid — Scala 3 domain tests)

```markdown
## QA REPORT

### Task Reference
**Task ID(s) covered:** T-002
**Stack:** Scala 3
**Test command:** `sbt coverage test coverageReport`

### Suite Result
**Overall:** ✅ PASS
**Pre-existing failures:** 0
**New failures:** 0

### Coverage
| Metric | Before | After | Threshold | Status |
|--------|--------|-------|-----------|--------|
| Statement | 74% | 78% | 75% | ✅ |
| Branch | 71% | 76% | 75% | ✅ |

### Tests Written
| Test name | Behavior verified | Type |
|-----------|------------------|------|
| `given empty order when confirm then EmptyOrder` | EmptyOrder invariant | Unit |
| `given non-draft order when confirm then AlreadyProcessed` | Status transition guard | Unit |
| `given draft order with items when confirm then Confirmed` | Happy path confirmation | Unit |
| `confirmed order contains OrderConfirmed event` | Event production | Unit |

### Domain Invariants Verified
| Invariant | Test(s) covering it | Status |
|-----------|---------------------|--------|
| Order must have items to confirm | test 1 | ✅ Covered |
| Order must be in Draft to confirm | test 2 | ✅ Covered |
| confirm() produces OrderConfirmed event | test 4 | ✅ Covered |

### Coverage Gaps
none

### FP Testing Compliance
- [x] Pure domain functions tested without mocks
- [x] Mocks used only at infrastructure boundary
- [x] Tests verify behavior / invariants, not implementation details
- [x] Test names describe Given/When/Then or behavior in plain language
- [ ] Property-based tests used for domain rules with unbounded input space — N/A for this task
- [x] No flaky tests introduced

### Escalations Required
none
```
