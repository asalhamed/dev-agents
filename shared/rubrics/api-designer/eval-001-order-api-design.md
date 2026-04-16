# Eval: api-designer — 001 — Order CRUD API Design

**Tags:** REST, resource design, status codes, RFC 7807, pagination
**Skill version tested:** initial

---

## Input (task brief)

```
Design a REST API for the Order aggregate: create order, get order, list orders
(paginated), add item to order, confirm order, cancel order.
```

---

## Expected Behavior

The api-designer should:
1. Design resource URLs using nouns (not verbs)
2. Use correct HTTP methods and status codes
3. Apply RFC 7807 Problem Details for all error responses
4. Use cursor-based pagination on the list endpoint
5. Never return 200 OK with an error in the body
6. Produce an `api-spec` contract

---

## Pass Criteria

- [ ] URLs are noun-based: `/orders`, `/orders/{id}`, `/orders/{id}/items`, `/orders/{id}/confirm`
- [ ] POST /orders → 201 Created with Location header
- [ ] GET /orders/{id} → 200 OK
- [ ] GET /orders → 200 OK with cursor pagination (nextCursor field)
- [ ] POST /orders/{id}/confirm → 204 No Content
- [ ] All errors use RFC 7807 format (type, title, status, detail)
- [ ] Content-Type for errors: `application/problem+json`
- [ ] `api-spec` contract produced

---

## Fail Criteria

- Verb URLs like `/createOrder` or `/confirmOrder` → ❌ REST violation
- 200 OK returned for error conditions → ❌ anti-pattern
- Offset pagination instead of cursor → ❌ doesn't scale
- Missing RFC 7807 error format → ❌ contract requirement
- POST /orders returns 200 instead of 201 → ❌ wrong status code
