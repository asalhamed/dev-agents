# OpenAPI 3.1 Reference

Reference for documenting REST APIs using the OpenAPI 3.1 specification.

---

## Top-Level Structure

```yaml
openapi: "3.1.0"         # Specification version
info:                      # API metadata
  title: "Order Service API"
  version: "1.0.0"
  description: "API for managing orders"
servers:                   # Base URLs
  - url: "https://api.example.com/v1"
    description: "Production"
  - url: "https://api.staging.example.com/v1"
    description: "Staging"
paths:                     # Endpoints
  /orders:
    get: ...
    post: ...
  /orders/{orderId}:
    get: ...
components:                # Reusable schemas, parameters, responses
  schemas: ...
  parameters: ...
  responses: ...
  securitySchemes: ...
security:                  # Global security requirements
  - bearerAuth: []
```

---

## Path Item Structure

```yaml
/orders/{orderId}:
  get:
    operationId: getOrder           # Unique operation identifier
    summary: Get order by ID        # Short description
    tags: [Orders]                  # Grouping
    parameters:
      - $ref: '#/components/parameters/OrderId'
    responses:
      '200':
        description: Order found
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/Order'
      '404':
        $ref: '#/components/responses/NotFound'
```

### Parameter Types

| In | Description | Example |
|----|-------------|---------|
| `path` | Part of the URL path | `/orders/{orderId}` |
| `query` | Query string parameter | `?status=confirmed&limit=20` |
| `header` | HTTP header | `X-Request-Id` |
| `cookie` | Cookie value | (rarely used in APIs) |

```yaml
components:
  parameters:
    OrderId:
      name: orderId
      in: path
      required: true
      schema:
        type: string
        format: uuid
      description: Unique order identifier
    
    PageCursor:
      name: cursor
      in: query
      required: false
      schema:
        type: string
      description: Cursor for pagination (opaque string from previous response)
```

### Request Body

```yaml
post:
  requestBody:
    required: true
    content:
      application/json:
        schema:
          $ref: '#/components/schemas/CreateOrderRequest'
```

---

## Schema Definitions

### Using `$ref` for Reuse

Define schemas once in `components/schemas`, reference everywhere:

```yaml
components:
  schemas:
    Order:
      type: object
      required: [id, status, items, createdAt]
      properties:
        id:
          type: string
          format: uuid
        status:
          type: string
          enum: [draft, confirmed, shipped, cancelled]
        items:
          type: array
          items:
            $ref: '#/components/schemas/OrderItem'
        createdAt:
          type: string
          format: date-time
        cancelledAt:
          type: ['string', 'null']    # OpenAPI 3.1 nullable syntax
          format: date-time
```

### Common Types

| Type | Format | Use |
|------|--------|-----|
| `string` | `uuid` | Identifiers |
| `string` | `date-time` | ISO 8601 timestamps |
| `string` | `email` | Email addresses |
| `string` | `uri` | URLs |
| `integer` | `int64` | Large counts, IDs |
| `number` | `double` | Monetary values (or use integer cents) |
| `boolean` | — | Flags |

### Required Fields and Nullable

```yaml
# OpenAPI 3.1 — use type array for nullable
cancelledAt:
  type: ['string', 'null']
  format: date-time

# Required fields listed at object level
required: [id, status, items]
```

---

## Response Patterns

### 200 OK — Resource found

```yaml
'200':
  description: Order retrieved successfully
  content:
    application/json:
      schema:
        $ref: '#/components/schemas/Order'
```

### 201 Created — Resource created

```yaml
'201':
  description: Order created
  headers:
    Location:
      schema:
        type: string
        format: uri
      description: URL of the created order
  content:
    application/json:
      schema:
        $ref: '#/components/schemas/Order'
```

### 204 No Content — Action succeeded, no body

```yaml
'204':
  description: Order confirmed successfully
```

### Error Responses — RFC 7807

All errors use the RFC 7807 Problem Details format:

```yaml
components:
  schemas:
    ProblemDetail:
      type: object
      required: [type, title, status]
      properties:
        type:
          type: string
          format: uri
          description: URI identifying the problem type
        title:
          type: string
          description: Human-readable summary
        status:
          type: integer
          description: HTTP status code
        detail:
          type: string
          description: Human-readable explanation specific to this occurrence
        instance:
          type: string
          format: uri
          description: URI identifying this specific occurrence
  
  responses:
    NotFound:
      description: Resource not found
      content:
        application/problem+json:
          schema:
            $ref: '#/components/schemas/ProblemDetail'
          example:
            type: "https://api.example.com/problems/not-found"
            title: "Not Found"
            status: 404
            detail: "Order with ID 550e8400-e29b-41d4-a716-446655440000 not found"
    
    UnprocessableEntity:
      description: Validation error
      content:
        application/problem+json:
          schema:
            allOf:
              - $ref: '#/components/schemas/ProblemDetail'
              - type: object
                properties:
                  violations:
                    type: array
                    items:
                      type: object
                      properties:
                        field:
                          type: string
                        message:
                          type: string
```

---

## Complete Minimal Example: Orders CRUD

```yaml
openapi: "3.1.0"
info:
  title: "Order Service API"
  version: "1.0.0"
  description: "API for managing customer orders"

servers:
  - url: "https://api.example.com/v1"

security:
  - bearerAuth: []

paths:
  /orders:
    get:
      operationId: listOrders
      summary: List orders with cursor pagination
      tags: [Orders]
      parameters:
        - name: cursor
          in: query
          schema:
            type: string
          description: Pagination cursor from previous response
        - name: limit
          in: query
          schema:
            type: integer
            minimum: 1
            maximum: 100
            default: 20
      responses:
        '200':
          description: Paginated list of orders
          content:
            application/json:
              schema:
                type: object
                required: [items]
                properties:
                  items:
                    type: array
                    items:
                      $ref: '#/components/schemas/Order'
                  nextCursor:
                    type: ['string', 'null']
                    description: Cursor for next page, null if no more results

    post:
      operationId: createOrder
      summary: Create a new order
      tags: [Orders]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateOrderRequest'
      responses:
        '201':
          description: Order created
          headers:
            Location:
              schema:
                type: string
                format: uri
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Order'
        '422':
          $ref: '#/components/responses/UnprocessableEntity'

  /orders/{orderId}:
    get:
      operationId: getOrder
      summary: Get order by ID
      tags: [Orders]
      parameters:
        - $ref: '#/components/parameters/OrderId'
      responses:
        '200':
          description: Order found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Order'
        '404':
          $ref: '#/components/responses/NotFound'

  /orders/{orderId}/items:
    post:
      operationId: addItemToOrder
      summary: Add an item to a draft order
      tags: [Orders]
      parameters:
        - $ref: '#/components/parameters/OrderId'
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/AddItemRequest'
      responses:
        '200':
          description: Item added, updated order returned
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Order'
        '404':
          $ref: '#/components/responses/NotFound'
        '422':
          $ref: '#/components/responses/UnprocessableEntity'

  /orders/{orderId}/confirm:
    post:
      operationId: confirmOrder
      summary: Confirm a draft order
      tags: [Orders]
      parameters:
        - $ref: '#/components/parameters/OrderId'
      responses:
        '204':
          description: Order confirmed
        '404':
          $ref: '#/components/responses/NotFound'
        '422':
          $ref: '#/components/responses/UnprocessableEntity'

  /orders/{orderId}/cancel:
    post:
      operationId: cancelOrder
      summary: Cancel an order
      tags: [Orders]
      parameters:
        - $ref: '#/components/parameters/OrderId'
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [reason]
              properties:
                reason:
                  type: string
                  description: Cancellation reason
      responses:
        '204':
          description: Order cancelled
        '404':
          $ref: '#/components/responses/NotFound'
        '422':
          $ref: '#/components/responses/UnprocessableEntity'

components:
  parameters:
    OrderId:
      name: orderId
      in: path
      required: true
      schema:
        type: string
        format: uuid

  schemas:
    Order:
      type: object
      required: [id, status, items, createdAt]
      properties:
        id:
          type: string
          format: uuid
        status:
          type: string
          enum: [draft, confirmed, shipped, cancelled]
        items:
          type: array
          items:
            $ref: '#/components/schemas/OrderItem'
        createdAt:
          type: string
          format: date-time
        confirmedAt:
          type: ['string', 'null']
          format: date-time
        cancelledAt:
          type: ['string', 'null']
          format: date-time

    OrderItem:
      type: object
      required: [productId, quantity, unitPrice]
      properties:
        productId:
          type: string
          format: uuid
        productName:
          type: string
        quantity:
          type: integer
          minimum: 1
        unitPrice:
          type: integer
          description: Price in smallest currency unit (cents)

    CreateOrderRequest:
      type: object
      required: [items]
      properties:
        items:
          type: array
          minItems: 1
          items:
            $ref: '#/components/schemas/AddItemRequest'

    AddItemRequest:
      type: object
      required: [productId, quantity]
      properties:
        productId:
          type: string
          format: uuid
        quantity:
          type: integer
          minimum: 1

    ProblemDetail:
      type: object
      required: [type, title, status]
      properties:
        type:
          type: string
          format: uri
        title:
          type: string
        status:
          type: integer
        detail:
          type: string
        instance:
          type: string
          format: uri

  responses:
    NotFound:
      description: Resource not found
      content:
        application/problem+json:
          schema:
            $ref: '#/components/schemas/ProblemDetail'

    UnprocessableEntity:
      description: Validation or business rule error
      content:
        application/problem+json:
          schema:
            $ref: '#/components/schemas/ProblemDetail'

  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
```
