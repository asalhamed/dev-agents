# REST API Conventions

Standard conventions for designing consistent, predictable REST APIs.

---

## URL Design

### Principles

- **Nouns, not verbs:** Resources are things, not actions
- **Plural resource names:** `/users`, `/orders` (not `/user`, `/order`)
- **Hierarchy for relationships:** `/users/{id}/orders` (orders belonging to a user)
- **Max 2 levels of nesting:** `/users/{id}/orders` ✅ — `/users/{id}/orders/{oid}/items/{iid}/notes` ❌
- **Kebab-case:** `/order-items` not `/orderItems` or `/order_items`

### Examples

```
✅ Good
GET    /users
GET    /users/{id}
GET    /users/{id}/orders
POST   /users/{id}/orders
GET    /orders/{id}
PATCH  /orders/{id}
DELETE /orders/{id}

❌ Bad
GET    /getUsers
POST   /createOrder
GET    /users/{id}/orders/{oid}/items/{iid}/notes/{nid}  # Too deep
GET    /orderItems  # Not kebab-case
```

### Deep Nesting Alternative

Instead of deep nesting, use top-level resources with query filters:

```
# Instead of: GET /users/{id}/orders/{oid}/items
GET /order-items?order_id=abc-123
```

---

## HTTP Methods

| Method | Purpose | Idempotent | Request Body | Success Code |
|--------|---------|-----------|-------------|-------------|
| **GET** | Read resource(s) | ✅ Yes | ❌ No body | 200 OK |
| **POST** | Create resource | ❌ No | ✅ Yes | 201 Created + `Location` header |
| **PUT** | Full replace | ✅ Yes | ✅ Yes (complete resource) | 200 OK |
| **PATCH** | Partial update | ✅ Yes* | ✅ Yes (partial fields) | 200 OK |
| **DELETE** | Remove resource | ✅ Yes | ❌ No body | 204 No Content |

*PATCH is idempotent when applying the same partial update produces the same result.

### Key Rules

- **GET must never modify state** — it should be safe to call any number of times
- **POST returns 201 + Location header** pointing to the created resource
- **PUT replaces the entire resource** — omitted fields are set to defaults/null
- **PATCH updates only the fields provided** — omitted fields are unchanged
- **DELETE returns 204 with no body** — subsequent DELETEs on same resource return 404 or 204

---

## Status Codes

### Success

| Code | Name | When to Use |
|------|------|------------|
| **200** | OK | Successful GET, PUT, PATCH. Response body contains the resource. |
| **201** | Created | Successful POST. Include `Location` header with new resource URL. |
| **204** | No Content | Successful DELETE. No response body. |

### Client Errors

| Code | Name | When to Use |
|------|------|------------|
| **400** | Bad Request | Malformed request syntax, invalid JSON, missing required header. |
| **401** | Unauthorized | Missing or invalid authentication credentials. (Misleading name — means "unauthenticated.") |
| **403** | Forbidden | Authenticated but not authorized to access this resource. |
| **404** | Not Found | Resource doesn't exist. Also use to hide existence from unauthorized users. |
| **409** | Conflict | Request conflicts with current state (e.g., duplicate email, version mismatch). |
| **422** | Unprocessable Entity | Request is syntactically valid but semantically wrong (validation errors). |
| **429** | Too Many Requests | Rate limit exceeded. Include `Retry-After` header. |

### Server Errors

| Code | Name | When to Use |
|------|------|------------|
| **500** | Internal Server Error | Unexpected server error. Log it, alert on it, never expose internals. |
| **503** | Service Unavailable | Server is temporarily overloaded or in maintenance. Include `Retry-After`. |

### Decision Guide: 400 vs 422

- **400:** "I can't even parse what you sent me" — malformed JSON, wrong Content-Type
- **422:** "I understand your request but it violates business rules" — email already taken, amount exceeds balance

---

## Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| **URL paths** | kebab-case, plural nouns | `/order-items`, `/user-profiles` |
| **JSON fields** | camelCase | `createdAt`, `orderItems`, `firstName` |
| **Query parameters** | snake_case or camelCase (pick one, be consistent) | `?created_after=2026-01-01` or `?createdAfter=2026-01-01` |
| **Headers** | Title-Case with hyphens | `Content-Type`, `X-Request-Id` |

---

## Versioning

### URL Path Versioning

```
GET /v1/users
GET /v2/users
```

**Pros:** Obvious, easy to route, easy to cache independently.
**Cons:** Clutters URLs, harder to sunset gradually.

**Use when:** Public APIs, APIs consumed by many external clients.

### Header Versioning

```
GET /users
Accept: application/vnd.example.v2+json
```

**Pros:** Clean URLs, supports content negotiation.
**Cons:** Less discoverable, harder to test in browser.

**Use when:** Internal APIs, APIs with sophisticated clients.

### What Constitutes a Breaking Change

**Breaking (requires new version):**
- Removing or renaming a field in the response
- Removing an endpoint
- Changing a field's type (string → integer)
- Adding a new required field to the request
- Changing the meaning/behavior of an existing field

**Non-breaking (safe to add to existing version):**
- Adding a new optional field to request or response
- Adding a new endpoint
- Adding a new optional query parameter
- Adding a new enum value (if clients handle unknown values gracefully)
