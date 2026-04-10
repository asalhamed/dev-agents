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
