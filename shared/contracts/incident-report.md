# Incident Report

**Producer:** incident-responder
**Consumer(s):** tech-lead, observability-agent

## Required Fields

- **Incident ID** — unique identifier (e.g., INC-2025-042)
- **Severity** — P1 / P2 / P3 (with definition reference)
- **Start/end time** — UTC timestamps for detection, mitigation, resolution
- **Impact** — customers affected (count/percentage), services affected, data loss (if any)
- **Timeline of events** — factual, timestamped sequence of events
- **Root cause** — actual underlying cause (not just symptoms)
- **Mitigation taken** — what was done to restore service
- **Action items** — each with owner, due date, and priority

## Validation Checklist

- [ ] Timeline is factual (not editorialized — "we noticed" not "someone failed to")
- [ ] Root cause identified (not just symptoms — "connection pool exhausted" not "service was slow")
- [ ] Action items have owners and due dates
- [ ] Blameless (no individual blamed — focus on systems, not people)
- [ ] Customers notified if P1/P2

## Example (valid)

```markdown
## INCIDENT REPORT: INC-2025-042

**Severity:** P2
**Duration:** 2025-03-15 14:22 UTC → 2025-03-15 15:07 UTC (45 min)
**Impact:** 12% of customers experienced degraded live video (frozen frames).
Zero data loss. Recording unaffected.

### Timeline
- 14:22 — Alert: WebRTC SFU error rate > 5% (PagerDuty)
- 14:25 — On-call engineer acknowledges, begins investigation
- 14:31 — Root cause identified: TURN server ran out of relay allocations
- 14:38 — Mitigation: scaled TURN server pool from 2 → 4 instances
- 14:52 — Error rate dropping, new connections succeeding
- 15:07 — All metrics nominal, incident resolved

### Root Cause
TURN server max-allocations was set to 500 (default). Customer growth pushed
concurrent relay connections to 480+ during peak hours. New connections failed
when allocation limit was hit.

### Action Items
1. Increase TURN allocation limit to 2000 and add monitoring — @devops — 2025-03-17
2. Add TURN allocation usage to capacity dashboard — @observability — 2025-03-19
3. Auto-scaling policy for TURN servers at 70% allocation — @devops — 2025-03-22
```
