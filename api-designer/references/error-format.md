# Error Format Reference

Standardized error responses using RFC 7807 Problem Details.

---

## RFC 7807 Problem Details

**Content-Type:** `application/problem+json`

### Standard Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | URI | Recommended | URI reference identifying the error type. Should be a documentation URL. Default: `about:blank` |
| `title` | string | Recommended | Short, human-readable summary. Should be the same for all instances of this error type. |
| `status` | integer | Recommended | HTTP status code (duplicated for convenience when body is parsed without headers). |
| `detail` | string | Optional | Human-readable explanation specific to this occurrence. May differ per instance. |
| `instance` | URI | Optional | URI reference identifying this specific occurrence (e.g., a log correlation ID). |

### Extension Fields

You can add any additional fields relevant to the error:

```json
{
  "type": "https://api.example.com/errors/validation-failed",
  "title": "Validation Failed",
  "status": 422,
  "detail": "The request body contains 2 validation errors.",
  "instance": "/logs/errors/abc-123",
  "errors": [
    { "field": "email", "message": "Must be a valid email address" },
    { "field": "quantity", "message": "Must be greater than 0" }
  ]
}
```

---

## Error Catalog Pattern

Centralize error types with stable URIs. Each error type has a documentation page.

### Structure

```
https://api.example.com/errors/
├── validation-failed          → 422 validation errors
├── resource-not-found         → 404 generic not found
├── order-not-found            → 404 order-specific
├── duplicate-email            → 409 email conflict
├── insufficient-balance       → 422 business rule
├── rate-limit-exceeded        → 429 throttling
├── unauthorized               → 401 auth required
└── forbidden                  → 403 insufficient permissions
```

### Domain Error → HTTP Error Mapping

```typescript
// Domain errors (no HTTP knowledge)
type OrderError =
  | { kind: 'not_found'; orderId: string }
  | { kind: 'already_confirmed'; orderId: string }
  | { kind: 'empty_order' }
  | { kind: 'insufficient_stock'; itemId: string; available: number };

// Mapping layer (HTTP adapter)
function toHttpError(error: OrderError): ProblemDetail {
  switch (error.kind) {
    case 'not_found':
      return {
        type: 'https://api.example.com/errors/order-not-found',
        title: 'Order Not Found',
        status: 404,
        detail: `Order ${error.orderId} does not exist.`,
      };
    case 'already_confirmed':
      return {
        type: 'https://api.example.com/errors/order-already-confirmed',
        title: 'Order Already Confirmed',
        status: 409,
        detail: `Order ${error.orderId} has already been confirmed and cannot be modified.`,
      };
    case 'empty_order':
      return {
        type: 'https://api.example.com/errors/empty-order',
        title: 'Empty Order',
        status: 422,
        detail: 'Cannot confirm an order with no items.',
      };
    case 'insufficient_stock':
      return {
        type: 'https://api.example.com/errors/insufficient-stock',
        title: 'Insufficient Stock',
        status: 422,
        detail: `Item ${error.itemId} has only ${error.available} units available.`,
        itemId: error.itemId,
        available: error.available,
      };
  }
}
```

---

## Common Error Scenarios

### 404 Not Found

```http
GET /v1/orders/non-existent-id

HTTP/1.1 404 Not Found
Content-Type: application/problem+json

{
  "type": "https://api.example.com/errors/order-not-found",
  "title": "Order Not Found",
  "status": 404,
  "detail": "Order 'non-existent-id' does not exist.",
  "instance": "/logs/req/abc-123"
}
```

### 422 Validation Failure

```http
POST /v1/orders
Content-Type: application/json
{"items": [], "customerEmail": "not-an-email"}

HTTP/1.1 422 Unprocessable Entity
Content-Type: application/problem+json

{
  "type": "https://api.example.com/errors/validation-failed",
  "title": "Validation Failed",
  "status": 422,
  "detail": "The request body contains 2 validation errors.",
  "errors": [
    { "field": "items", "message": "Must contain at least one item." },
    { "field": "customerEmail", "message": "Must be a valid email address." }
  ]
}
```

### 409 Conflict

```http
POST /v1/users
Content-Type: application/json
{"email": "maria@example.com", "name": "Maria Chen"}

HTTP/1.1 409 Conflict
Content-Type: application/problem+json

{
  "type": "https://api.example.com/errors/duplicate-email",
  "title": "Email Already Registered",
  "status": 409,
  "detail": "A user with email 'maria@example.com' already exists."
}
```

### 401 Unauthorized

```http
GET /v1/orders
(no Authorization header)

HTTP/1.1 401 Unauthorized
Content-Type: application/problem+json
WWW-Authenticate: Bearer

{
  "type": "https://api.example.com/errors/unauthorized",
  "title": "Authentication Required",
  "status": 401,
  "detail": "This endpoint requires a valid Bearer token in the Authorization header."
}
```

### 403 Forbidden

```http
DELETE /v1/orders/order-123
Authorization: Bearer <valid-token-for-viewer-role>

HTTP/1.1 403 Forbidden
Content-Type: application/problem+json

{
  "type": "https://api.example.com/errors/forbidden",
  "title": "Insufficient Permissions",
  "status": 403,
  "detail": "Your role (viewer) does not have permission to delete orders."
}
```

---

## Anti-Patterns

### ❌ 200 OK with Error in Body

```json
HTTP/1.1 200 OK

{
  "success": false,
  "error": "Order not found"
}
```

**Why it's wrong:** HTTP clients, caches, and monitoring tools rely on status codes.
A 200 with an error body bypasses all of that infrastructure.

### ❌ Generic Error Messages

```json
HTTP/1.1 500 Internal Server Error

{ "error": "Something went wrong" }
```

**Why it's wrong:** Gives the client no information about what happened or what to do.
Use specific error types and messages. Log the details server-side.

### ❌ Leaking Stack Traces

```json
HTTP/1.1 500 Internal Server Error

{
  "error": "NullPointerException at com.example.OrderService.confirm(OrderService.java:42)",
  "stack": "at com.example.OrderService.confirm(OrderService.java:42)\n  at ..."
}
```

**Why it's wrong:** Exposes internal implementation details (class names, line numbers,
library versions) that help attackers. Log the full stack trace server-side, return
a generic 500 to the client.

### ❌ Inconsistent Error Shapes

Different endpoints returning different error structures:

```json
// Endpoint A
{ "error": "Not found" }

// Endpoint B
{ "message": "Not found", "code": 404 }

// Endpoint C
{ "errors": [{ "msg": "Not found" }] }
```

**Why it's wrong:** Clients can't build a single error handler. Use RFC 7807 everywhere.
