# IoT Liability & SLA Drafting

## SLA Structure

### Uptime Commitments
| Tier | Uptime | Monthly Downtime | Credit |
|------|--------|------------------|--------|
| Standard | 99.5% | 3.6 hours | 10% |
| Premium | 99.9% | 43 minutes | 15% |
| Enterprise | 99.95% | 22 minutes | 25% |

Measurement: platform availability, not individual device connectivity.

### Alert Delivery SLA
- P1 alerts: delivered within 5 minutes of detection
- P2 alerts: delivered within 15 minutes
- Measurement: time from event to notification delivery (email/SMS/push)

## Liability Caps
- **Standard:** aggregate liability capped at fees paid in prior 12 months
- **Floor:** liability cap should be at least 1x annual fees (customer will negotiate up)
- **Ceiling:** never exceed 3x annual fees without executive approval

## Exclusions
Standard exclusions from SLA:
- Customer's network/internet connectivity failures
- Customer's hardware failures (cameras, sensors not supplied by us)
- Force majeure
- Scheduled maintenance (with 48h notice)
- Customer-caused issues (misconfiguration, API abuse)

## Warranty Limitations
- **No guarantee of detection:** "Platform provides monitoring tools; detection of all events is not guaranteed"
- **No guarantee of prevention:** monitoring ≠ prevention; we observe, we don't control
- **Sensor accuracy:** within manufacturer specifications; we're not liable for sensor errors

## Key Clauses
- **Data ownership:** customer owns their data; we process on their behalf
- **Data return:** on termination, data available for export for 30 days
- **Subprocessors:** list all cloud providers (AWS, etc.) as subprocessors
- **Insurance:** maintain $2M+ cyber liability insurance
