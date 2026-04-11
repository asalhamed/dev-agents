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

---

## Validation (product-owner checks before sign-off)

- [ ] Every acceptance criterion from PRD has a matching test
- [ ] Each test has clear evidence (screenshot, log, or test name)
- [ ] E2E journey covers the full user flow, not just individual components
- [ ] Cross-component integration points are explicitly tested
- [ ] Sign-off section is filled in (not left blank)

## Example (valid)

```markdown
## ACCEPTANCE TEST REPORT

### Feature Reference
**Feature ID:** F-012
**PRD reference:** PRD-012

### Acceptance Criteria Results
| AC ID | Criterion | Test method | Result | Evidence |
|-------|-----------|-------------|--------|----------|
| AC-1 | Given camera online, when user taps feed, then video in <3s | Automated + manual | ✅ Pass | p95=2.1s (perf-report) |
| AC-2 | Given motion detected, when threshold exceeded, then push in <5s | Automated E2E | ✅ Pass | Avg 2.8s (staging test log) |
| AC-3 | Given alert notification, when user taps, then app opens to camera | Manual on Pixel 7 | ✅ Pass | Screenshot attached |

### E2E Journey Test
**Journey tested:** Field tech opens app → taps site camera → views live feed → motion detected at edge → alert push notification → tech taps notification → app opens to camera feed
**Result:** ✅ Pass
**Notes:** Latency slightly higher on cellular vs WiFi (2.8s vs 1.9s) — within SLO

### Cross-Component Integration
| Integration point | Components | Result |
|---|---|---|
| Camera → video pipeline → Android player | iot-dev + video-streaming + android-dev | ✅ |
| Edge motion detection → alert API → push | edge-agent + backend-dev + android-dev | ✅ |

### Product-Owner Sign-Off
**Status:** ✅ Accepted
**Conditions:** None
**Signed off by:** product-owner
**Date:** 2026-05-14T10:00:00Z
```
