# Eval: docs-agent — 001 — API Documentation Generation

**Tags:** OpenAPI, API docs, request/response schema, RFC 7807, documentation
**Skill version tested:** initial

---

## Input (task brief)

```
Generate API documentation for the notification preferences feature.
API has GET /users/{id}/notification-preferences and
PATCH /users/{id}/notification-preferences.
```

---

## Expected Behavior

The docs-agent should:
1. Document both endpoints with full details
2. Define request body schema for PATCH
3. Define response body schema for both GET and PATCH
4. Document error responses (404, 422) using RFC 7807
5. Note authentication requirements
6. Produce a `docs-summary` contract

---

## Pass Criteria

- [ ] GET endpoint documented with path parameter, response schema, status codes
- [ ] PATCH endpoint documented with request body schema, response schema, status codes
- [ ] Response schema includes preference structure (categories, channels, states)
- [ ] Error responses use RFC 7807 format (404, 422)
- [ ] Authentication requirement noted (e.g., Bearer token)
- [ ] Examples provided for request and response bodies
- [ ] `docs-summary` contract produced

---

## Fail Criteria

- Missing one of the two endpoints → ❌ incomplete documentation
- No request body schema for PATCH → ❌ consumers can't implement
- No error response documentation → ❌ consumers can't handle failures
- No authentication requirement → ❌ security gap in docs
