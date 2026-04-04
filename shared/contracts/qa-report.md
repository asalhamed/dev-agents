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
