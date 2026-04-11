# Release Plan Contract

**Producer:** tech-lead (with devops-agent)
**Consumers:** product-owner (approval), devops-agent (execution)
**Purpose:** Orchestrates the actual release — the full path from "reviewer approved" to production, including gradual rollout and rollback triggers.

---

## RELEASE PLAN

### Feature Reference
**Feature ID:** F-[NNN]
**Release version:** [v1.2.0 or similar]
**Target release date:** [ISO 8601]

### Pre-Release Checklist
- [ ] All acceptance criteria pass (acceptance-test contract signed off by product-owner)
- [ ] Reviewer approved (reviewer-decision contract)
- [ ] Security scan clean — no High/Critical findings
- [ ] Performance within SLO (perf-report)
- [ ] Observability instrumented (observability-audit)
- [ ] Documentation updated (docs-summary)
- [ ] Release notes drafted
- [ ] Feature flag configured (if applicable)
- [ ] Stakeholder demo completed and approved
- [ ] Database migrations tested on staging
- [ ] Rollback plan documented and tested

### Release Sequence
| Step | Action | Owner | Verify |
|------|--------|-------|--------|
| 1 | Run db-migration on staging | devops-agent | Migrations apply cleanly |
| 2 | Deploy backend services to staging | devops-agent | Health checks pass |
| 3 | [Add component-specific steps] | [owner] | [verification] |
| 4 | Run full E2E on staging | qa-agent | All journeys pass |
| 5 | Stakeholder demo on staging | product-owner | Sign-off received |
| 6 | Enable feature flag for internal users | devops-agent | Internal dogfood |
| 7 | Monitor for 24h | observability-agent | No anomalies |
| 8 | Enable for beta ([X]% of fleet) | devops-agent | Monitor error rate |
| 9 | Monitor for 48h | observability-agent | No anomalies |
| 10 | Full rollout (100%) | devops-agent | Monitor 48h post-GA |

### Rollback Triggers
| Signal | Threshold | Action |
|--------|-----------|--------|
| Error rate spike | > 1% for 5 min | Disable feature flag immediately |
| P1 bug reported | Any | Pause rollout, assess severity |
| Performance degradation | SLO violated for 15 min | Disable feature flag, investigate |
| Unexpected data anomaly | Any | Pause rollout, alert data-analyst |

### Rollback Procedure
**Feature-level rollback:** [how to disable — feature flag off / revert commit / other]
**Data rollback:** [any data migration to reverse? Yes/No + procedure]
**Estimated rollback time:** [minutes]
**Rollback tested:** Yes / No

### Post-Release
- [ ] Confirm success metrics are being collected (data-analyst)
- [ ] Customer onboarding docs updated (customer-success, if applicable)
- [ ] Feature flag removal scheduled (if applicable — target date: [ISO 8601])
- [ ] Retrospective scheduled (target date: [ISO 8601])
- [ ] Feature closed in tracking

### Release Sign-Off
**Approved by:** product-owner
**Date:** [ISO 8601]

## Example (valid)

```markdown
## RELEASE PLAN

### Feature Reference
**Feature ID:** F-012
**Release version:** v1.3.0

### Pre-Release Checklist
- [x] All acceptance criteria pass
- [x] Reviewer approved
- [x] Security scan clean
- [x] Video latency <3s p95 (perf-report)
- [x] Observability instrumented
- [x] Documentation updated
- [x] Feature flag `feature_live_video_alerts` configured (OFF)
- [x] Stakeholder demo completed on staging
- [x] Database migrations tested on staging
- [x] Rollback plan tested

### Release Sequence
| Step | Action | Owner | Verify |
|------|--------|-------|--------|
| 1 | Deploy video-service to staging | devops-agent | Stream test passes |
| 2 | Deploy backend (alert API) to staging | devops-agent | Health check + alert test |
| 3 | Deploy edge-runtime update to 1 test device | iot-dev | Motion detection triggers |
| 4 | Upload Android APK to Play Store internal | android-dev | Install + smoke test |
| 5 | Full E2E on staging | qa-agent | All journeys pass |
| 6 | Stakeholder demo | product-owner | Sign-off received |
| 7 | Tag v1.3.0 in all repos | tech-lead | Tags pushed |
| 8 | Deploy to production (same order) | devops-agent | Health checks green |
| 9 | Enable flag for internal team | devops-agent | Dogfood 24h |
| 10 | Enable for beta (5%) | devops-agent | Monitor error rate |
| 11 | Full rollout (100%) | devops-agent | Monitor 48h |

### Rollback Triggers
| Signal | Action |
|--------|--------|
| Error rate > 1% for 5 min | Disable feature flag |
| Video latency > 5s p95 for 15 min | Disable feature flag |
| >3 beta user complaints about false alerts | Pause rollout, investigate thresholds |

### Release Sign-Off
**Approved by:** product-owner
**Date:** 2026-05-14T11:00:00Z
```
