# Feature Kickoff Contract

**Producer:** tech-lead
**Consumers:** all assigned agents, product-owner (for tracking)
**Purpose:** Single source of truth for a feature as it moves through the pipeline. Created once, updated as the feature progresses.

---

## FEATURE KICKOFF

### Feature Identity
**Feature ID:** F-[NNN]
**Title:** [Short descriptive title]
**PRD reference:** [link to PRD]
**ADR reference:** [link to ADR or "N/A — small feature"]
**Priority:** P0 (critical) | P1 (high) | P2 (medium) | P3 (low)

### Scope
**In scope:** [bullet list — what this feature DOES include]
**Out of scope:** [bullet list — what this feature does NOT include, even if related]
**Scope freeze date:** [date after which scope changes require a formal change request]

### Acceptance Criteria (from PRD)
<!-- Copy verbatim from PRD — these are the criteria for acceptance testing -->
- [ ] AC-1: [Given/When/Then]
- [ ] AC-2: [Given/When/Then]
- [ ] AC-3: [Given/When/Then]

### Success Metrics (from measurement-plan)
| Metric | Baseline | Target | Measurement method |
|--------|----------|--------|-------------------|
| [metric] | [current] | [goal] | [how measured] |

### Estimation
| Task ID | Agent | Description | Estimate | Actual | Status |
|---------|-------|-------------|----------|--------|--------|
| T-001 | backend-dev | [task description] | S | — | Not started |
| T-002 | android-dev | [task description] | M | — | Not started |
| T-003 | video-streaming | [task description] | L | — | Not started |

**Estimates:** S = <1 day, M = 1-3 days, L = 3-5 days, XL = 5+ days (decompose further)

**Total estimated:** [N days]
**Target delivery:** [ISO 8601 date]
**Confidence:** High | Medium | Low

### Rollout Plan
**Strategy:** feature-flag | canary | phased | big-bang
**Feature flag name:** `feature_[domain]_[capability]` (if applicable)
**Rollout phases:**
1. Internal dogfood (team only)
2. Beta customers ([X]% of fleet)
3. General availability

### Rollback Plan
**Feature-level rollback:** [how to disable — feature flag off, revert commit, etc.]
**Data rollback:** [any data migration to reverse? Yes/No + details]

### Definition of Done (Pipeline-Level)
- [ ] All acceptance criteria pass (validated by product-owner)
- [ ] Code review approved (reviewer)
- [ ] Security scan clean — no High/Critical (security-agent)
- [ ] Performance within SLO (perf-agent)
- [ ] Observability instrumented (observability-agent)
- [ ] Documentation updated (docs-agent)
- [ ] Monitoring/alerting configured for new endpoints
- [ ] Feature flag configured (if applicable)
- [ ] Stakeholder demo completed and approved
- [ ] Release notes drafted

### Status Log
| Date | Phase | Update |
|------|-------|--------|
| [ISO 8601] | Kickoff | Feature kickoff produced by tech-lead |

---

## Validation (product-owner must check before approving kickoff)

- [ ] Feature ID is unique (F-NNN)
- [ ] PRD and ADR references present (or "N/A" with reason)
- [ ] Acceptance criteria copied verbatim from PRD
- [ ] Success metrics have baseline AND target values
- [ ] Every task has an estimate (S/M/L/XL — no XL without decomposition)
- [ ] Target delivery date is realistic (estimate + buffer)
- [ ] Rollout plan specified (feature-flag / canary / phased / big-bang)
- [ ] Rollback plan documented (feature-level, not just infra)
- [ ] Pipeline-level Definition of Done is complete

## Example (valid)

```markdown
## FEATURE KICKOFF

### Feature Identity
**Feature ID:** F-012
**Title:** Live Video Feed with Motion-Based Alerts
**PRD reference:** PRD-012
**ADR reference:** ADR-015
**Priority:** P1 (high)

### Scope
**In scope:**
- Live RTSP→WebRTC video viewing in Android app
- Edge-side motion detection triggering alerts
- Push notification delivery for motion alerts
**Out of scope:**
- Video recording/playback (deferred to F-015)
- Multi-camera simultaneous viewing (deferred)
**Scope freeze date:** 2026-05-01

### Acceptance Criteria (from PRD)
- [ ] AC-1: Given a camera is online, when user taps the camera feed, then live video displays within 3 seconds
- [ ] AC-2: Given motion is detected by edge device, when alert threshold is exceeded, then push notification delivered within 5 seconds
- [ ] AC-3: Given user receives alert, when user taps notification, then app opens to the relevant camera feed

### Success Metrics
| Metric | Baseline | Target | Measurement method |
|--------|----------|--------|-------------------|
| Video load time | N/A (new) | <3s p95 | Client-side instrumentation |
| Alert delivery latency | N/A (new) | <5s p95 | Edge timestamp → push received |
| Daily active video viewers | 0 | 50 within 30 days | Analytics event tracking |

### Estimation
| Task ID | Agent | Description | Estimate | Actual | Status |
|---------|-------|-------------|----------|--------|--------|
| T-001 | video-streaming | RTSP→WebRTC bridge | L | — | Not started |
| T-002 | edge-agent | Motion detection model | M | — | Not started |
| T-003 | backend-dev | Alert API + push notification | M | — | Not started |
| T-004 | android-dev | Live feed viewer + alert UI | M | — | Not started |
| T-005 | devops-agent | K8s manifests + feature flag | S | — | Not started |
| T-006 | qa-agent | Tests + acceptance tests | M | — | Not started |

**Total estimated:** 12 days
**Target delivery:** 2026-05-15
**Confidence:** Medium (first video feature — adding 20% buffer)

### Rollout Plan
**Strategy:** feature-flag
**Feature flag name:** `feature_live_video_alerts`
**Rollout phases:**
1. Internal dogfood (team only) — 2 days
2. Beta customers (5% of fleet) — 3 days
3. General availability — full rollout

### Rollback Plan
**Feature-level rollback:** Disable feature flag `feature_live_video_alerts` — instant, no deployment
**Data rollback:** No new tables; alert history rows can remain (no cleanup needed)

### Definition of Done (Pipeline-Level)
- [ ] All acceptance criteria pass
- [ ] Code review approved
- [ ] Security scan clean
- [ ] Video latency within SLO (<3s p95)
- [ ] Observability instrumented
- [ ] Documentation updated
- [ ] Feature flag configured
- [ ] Stakeholder demo completed
- [ ] Release notes drafted
```
