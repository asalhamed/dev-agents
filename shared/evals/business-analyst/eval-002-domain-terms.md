# Eval: business-analyst — 002 — Domain Term Identification

**Tags:** domain terms, ubiquitous language, glossary, DDD
**Skill version tested:** initial

---

## Input (task brief)

```
Identify domain terms from: 'Users can pay for orders using credit cards. Payments
can be refunded within 30 days. Disputed payments trigger a chargeback process.'
```

---

## Expected Behavior

The business-analyst should:
1. Extract key domain terms: Payment, Refund, Dispute, Chargeback, PaymentMethod/CreditCard
2. Define each term in clear business language
3. Distinguish between Refund (merchant-initiated) and Chargeback (bank-initiated)
4. Mark terms for addition to shared/glossary.md
5. Produce a `business-requirements` contract

---

## Pass Criteria

- [ ] Identifies: Payment, Refund, Dispute, Chargeback, CreditCard/PaymentMethod
- [ ] Each term has a business-language definition (not technical)
- [ ] Refund vs Chargeback distinction noted (merchant-initiated vs bank-initiated)
- [ ] 30-day refund window captured as a business rule
- [ ] Terms flagged for glossary addition
- [ ] `business-requirements` contract produced

---

## Fail Criteria

- Misses Chargeback as distinct from Refund → ❌ domain confusion
- Definitions are technical ("database record") not business ("a reversal of payment") → ❌ wrong language
- Fewer than 4 terms identified → ❌ incomplete extraction
- No mention of glossary integration → ❌ terms lost
