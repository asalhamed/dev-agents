# Eval: security-agent — 001 — Threat Model Payment API

**Tags:** STRIDE, PCI-DSS, threat modeling, payment security
**Skill version tested:** initial

---

## Input (task brief)

```
Threat model an API that handles payment data and publishes PaymentReceived events
to Kafka. The API accepts card details, charges via Stripe, and stores a payment
record in PostgreSQL.
```

---

## Expected Behavior

The security-agent should:
1. Identify PCI-DSS scope due to card data handling
2. Perform STRIDE analysis on each component (API endpoint, Kafka publisher, PostgreSQL store)
3. Flag that raw card numbers must never be stored — only Stripe tokens
4. Define security requirements for authentication, authorization, and audit logging
5. Produce a valid `threat-model` contract

---

## Pass Criteria

- [ ] PCI-DSS scope identified and called out
- [ ] STRIDE analysis covers at least: Spoofing (auth), Tampering (data integrity), Information Disclosure (card data), Denial of Service (rate limiting)
- [ ] Explicit requirement: no card number storage (use Stripe tokenization)
- [ ] Auth requirement on payment endpoint (not public)
- [ ] Audit log requirement for all payment actions
- [ ] Trust boundaries identified (internet → API, API → Kafka, API → PostgreSQL)
- [ ] `threat-model` contract produced with all required fields

---

## Fail Criteria

- Misses PCI-DSS scope entirely → ❌ critical gap
- Allows card number storage in PostgreSQL → ❌ compliance violation
- No STRIDE analysis or only partial (e.g., only Spoofing) → ❌ incomplete
- No trust boundaries identified → ❌ missing core concept
- `threat-model` contract missing required fields → ❌ contract violation
