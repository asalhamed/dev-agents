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

### Required for IoT / camera / edge features

When the feature touches devices, firmware, the edge media pipeline, or video/biometric
data, the following sections are also required (omit with an explicit "N/A — rationale"
statement only):

- **Device compromise** — physical attacker with the hardware; what they can read, modify,
  or impersonate. Coordinate with `iot-dev` and `security-agent`.
- **Firmware tampering** — unauthorized modification of firmware in transit, at rest on the
  device, or via a malicious OTA. Reference the `firmware-ota-agent` controls.
- **OTA rollback failure** — a bad bundle reaches the fleet; how do we halt, revoke, and
  recover? Reference the rollout halt criteria and signed-revocation procedure.
- **Supply-chain compromise** — malicious dependency, compromised build, or signing-key
  compromise. Reference `supply-chain-security-agent` attestations.
- **Side-channel** — timing, power, RF, network-traffic analysis — where applicable to the
  threat model (high for hardware-root-of-trust paths, low for plain cloud endpoints).
- **Physical tamper** — enclosure, sensor, camera cable access; detection and response.
- **Mass-device DoS** — attacker coerces many devices into an unusable state simultaneously
  (bad config push, OTA storm, cert revocation).
- **Privacy exposure** — PII or biometric leakage via the feature. Escalate the privacy
  dimension to `privacy-agent` for a DPIA where the threshold is met.
- **Consent-bypass** — any data path that could deliver a biometric artifact to a
  destination lacking a valid `ConsentRecord`. Must be enumerated or explicitly ruled out.
- **Applicable standards** — map the relevant threat categories to OWASP IoT Top 10, NIST
  8259, ETSI EN 303 645, and (if in scope) IEC 62443 foundational requirements.

## Validation Checklist

- [ ] All entry points identified
- [ ] Trust boundaries explicitly drawn
- [ ] STRIDE applied to each component
- [ ] Every finding has a risk rating
- [ ] Security requirements are actionable (not "be secure")
- [ ] Auth and authorization flows reviewed
- [ ] IoT-specific sections filled in or marked "N/A — rationale" (for IoT / camera / edge
  features only)
- [ ] Consent-bypass analysis complete for any biometric or video feature
- [ ] Standards mapping cites specific controls, not just framework names

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
