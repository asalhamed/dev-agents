# Eval: api-designer — 002 — API Review Anti-Patterns

**Tags:** API review, 200-for-errors, verb URL, RFC 7807, anti-patterns
**Skill version tested:** initial

---

## Input (task brief)

```
Review this API: POST /api/processOrder always returns 200 OK.
Errors come back as {"success": false, "error": "Order not found"}.
```

---

## Expected Behavior

The api-designer should:
1. Flag 200 OK for error conditions as an anti-pattern
2. Flag verb URL (`/processOrder`) and recommend noun-based URL
3. Flag non-standard error format and recommend RFC 7807
4. Propose correct status codes (404, 422, 500)
5. Produce an `api-spec` contract with corrections

---

## Pass Criteria

- [ ] 200 OK for errors explicitly flagged as anti-pattern
- [ ] Correct status codes proposed: 404 (not found), 422 (validation), 500 (server error)
- [ ] RFC 7807 error format recommended with example
- [ ] Verb URL `/processOrder` flagged, noun URL proposed (`/orders/{id}/confirm`)
- [ ] `success` boolean pattern identified as redundant when using proper status codes
- [ ] `api-spec` contract produced with corrected design

---

## Fail Criteria

- Accepts 200 OK for all responses as valid → ❌ misses primary anti-pattern
- Doesn't suggest RFC 7807 → ❌ missing standard error format
- Doesn't flag verb URL → ❌ incomplete review
- Proposes only one fix but misses others → ❌ partial review
