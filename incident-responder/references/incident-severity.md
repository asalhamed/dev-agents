# Incident Severity Definitions

## Severity Levels

| Level | Definition | Response Time | Comms Cadence |
|-------|-----------|---------------|---------------|
| **P1** | Platform down, data loss, security breach | 15 min | Every 30 min |
| **P2** | Degraded service, partial outage, >10% customers | 1 hour | Every 2 hours |
| **P3** | Minor degradation, single customer, workaround exists | 4 hours | Daily |

## P1 Examples
- Video platform completely down (no live feeds)
- Data loss (telemetry or video)
- Security breach (unauthorized access to customer data)
- >50% of devices disconnected simultaneously

## P2 Examples
- Live video degraded (frozen frames, high latency)
- Alert delivery delayed >15 minutes
- Single site completely offline
- API error rate >5%

## P3 Examples
- Dashboard slow but functional
- Single device model firmware bug
- Non-critical feature broken
- Single customer configuration issue

## Escalation Matrix

| Role | P1 | P2 | P3 |
|------|----|----|-----|
| On-call engineer | Immediate | 1 hour | 4 hours |
| Engineering manager | 15 min | 2 hours | Next business day |
| VP Engineering | 30 min | 4 hours | If unresolved 48h |
| CEO | 1 hour | If customer-facing 4h | Never |
| Customer comms | 30 min | 2 hours | Only if asked |

## On-Call Rotation
- Primary on-call: 1 week rotation
- Secondary on-call: backup if primary doesn't respond in 10 min
- Handoff: Monday 10 AM, documented in runbook
- Compensation: flat weekly rate + per-incident bonus for P1/P2
