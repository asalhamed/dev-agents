# Threat Model

**Producer:** security-agent (phase 1 — after architect)
**Consumer(s):** tech-lead

## Required Fields

- **ADR reference** — which ADR was analyzed
- **Scope** — what was and wasn't analyzed
- **Attack surface** — entry points, trust boundaries, data stores
- **STRIDE analysis** — table: Component, Threat, Risk (Critical/High/Medium/Low), Mitigation
- **Security requirements** — numbered (SR-001...), actionable requirements for implementation team
- **Risk rating summary** — count per severity level

## Validation Checklist

- [ ] All entry points identified
- [ ] Trust boundaries explicitly drawn
- [ ] STRIDE applied to each component
- [ ] Every finding has a risk rating
- [ ] Security requirements are actionable (not "be secure")
- [ ] Auth and authorization flows reviewed

## Example (valid)

```markdown
## THREAT MODEL: Order Confirmation via Domain Event (ADR-007)

**Scope:** Order service confirm endpoint + Kafka publisher. Out of scope: notification consumer.

**Attack surface:**
- POST /api/v1/orders/{id}/confirm — external HTTP endpoint
- Kafka topic order.events — internal message bus
- PostgreSQL order_events table — internal data store

**STRIDE analysis:**
| Component | Threat | Risk | Mitigation |
|-----------|--------|------|------------|
| Confirm endpoint | Spoofing: unauthenticated user confirms another's order | High | Verify JWT, check order.customerId === token.sub |
| Confirm endpoint | DoS: flooding confirm endpoint | Medium | Rate limit: 10 req/user/min |
| Kafka publisher | Repudiation: no audit trail for who triggered confirmation | Low | Include actorId in OrderConfirmed event |
| Kafka publisher | Tampering: consumer modifies event schema | Low | Schema registry with BACKWARD compatibility |

**Security requirements:**
- SR-001 (High): Confirm endpoint must verify JWT and check order.customerId === token.sub
- SR-002 (Medium): Rate limit confirm endpoint: 10 requests per user per minute
- SR-003 (Low): Include actorId and confirmedAt in OrderConfirmed event for audit trail

**Risk rating summary:** 0 Critical, 1 High, 1 Medium, 2 Low
```
