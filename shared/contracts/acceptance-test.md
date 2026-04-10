# Acceptance Test Contract

**Producer:** qa-agent (in collaboration with product-owner)
**Consumers:** product-owner (for sign-off), reviewer (as additional gate)
**Purpose:** Validates the feature against PRD acceptance criteria, not just code correctness. Separate from qa-report which validates code quality.

---

## ACCEPTANCE TEST REPORT

### Feature Reference
**Feature ID:** F-[NNN]
**PRD reference:** [link]
**Feature Kickoff reference:** [link]

### Acceptance Criteria Results
| AC ID | Criterion | Test method | Result | Evidence |
|-------|-----------|-------------|--------|----------|
| AC-1 | [Given/When/Then from PRD] | Manual / Automated / E2E | ✅ Pass / ❌ Fail | [screenshot, log, test name] |
| AC-2 | ... | ... | ... | ... |

### E2E Journey Test
**Journey tested:** [end-to-end user flow, e.g. "Field tech opens app → views live feed → receives motion alert → acknowledges alert"]
**Result:** ✅ Pass | ❌ Fail
**Latency observed:** [e.g. "Video stream established in 2.1s — within 3s SLO"]
**Notes:** [any observations about UX, latency, edge cases]

### Cross-Component Integration
| Integration point | Components | Result | Notes |
|---|---|---|---|
| [e.g. "camera → video pipeline → mobile app"] | iot-dev + video-streaming + android-dev | ✅ / ❌ | [latency, errors] |
| [e.g. "motion detection → alert → push notification"] | edge-agent + backend-dev + android-dev | ✅ / ❌ | [details] |

### Test Coverage Summary
**Unit tests:** [X passing / Y total]
**Integration tests:** [X passing / Y total]
**E2E tests:** [X passing / Y total]
**Acceptance criteria:** [X passing / Y total]

### Outstanding Issues
| Issue | Severity | Blocking? | Notes |
|-------|----------|-----------|-------|
| [description] | High / Medium / Low | Yes / No | [details] |

### Product-Owner Sign-Off
**Status:** ✅ Accepted | ❌ Rejected | ⚠️ Accepted with conditions
**Conditions (if any):** [list]
**Signed off by:** product-owner
**Date:** [ISO 8601]
