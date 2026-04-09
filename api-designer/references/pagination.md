# Pagination Reference

Patterns for paginating, filtering, and sorting API responses.

---

## Cursor-Based Pagination

### Why Cursors

- **Stable under mutations:** Inserting/deleting records doesn't shift pages
- **Efficient on large datasets:** Uses indexed seeks, not OFFSET (which scans and discards rows)
- **No "page 500 problem":** OFFSET 50000 is slow; cursor-based is constant time

### Request

```
GET /v1/orders?limit=20&after=eyJpZCI6ImFiYy0xMjMifQ==
```

| Parameter | Description |
|-----------|-------------|
| `limit` | Number of items to return (default: 20, max: 100) |
| `after` | Cursor — return items after this point (opaque base64 string) |
| `before` | Cursor — return items before this point (for backward pagination) |

### Response

```json
{
  "data": [
    { "id": "order-124", "status": "confirmed", "createdAt": "2026-04-09T10:00:00Z" },
    { "id": "order-125", "status": "draft", "createdAt": "2026-04-09T11:00:00Z" }
  ],
  "pagination": {
    "hasNextPage": true,
    "hasPreviousPage": true,
    "nextCursor": "eyJpZCI6Im9yZGVyLTEyNSJ9",
    "previousCursor": "eyJpZCI6Im9yZGVyLTEyNCJ9"
  }
}
```

### Cursor Implementation

The cursor is an opaque base64-encoded value. Internally, it encodes the sort key(s):

```typescript
// Encoding
const cursor = Buffer.from(JSON.stringify({ id: lastItem.id })).toString('base64url');

// Decoding
const { id } = JSON.parse(Buffer.from(cursor, 'base64url').toString());

// SQL query (using id as cursor)
SELECT * FROM orders
WHERE id > $cursorId
ORDER BY id ASC
LIMIT $limit + 1;  -- Fetch one extra to determine hasNextPage
```

Fetching `limit + 1` rows: if you get `limit + 1` results, `hasNextPage = true` and you
return only the first `limit` rows.

---

## Offset Pagination

### When It's Acceptable

- Small, stable datasets (< 10,000 rows)
- Admin/internal UIs where "jump to page 50" is useful
- Reports and exports where total count is needed

### Request

```
GET /v1/users?page=3&per_page=25
```

### Response

```json
{
  "data": [...],
  "pagination": {
    "page": 3,
    "perPage": 25,
    "totalItems": 1234,
    "totalPages": 50
  }
}
```

### Total Count Tradeoffs

- `COUNT(*)` is expensive on large tables (full table scan in PostgreSQL)
- Options: cache the count, update it asynchronously, or omit it (use `hasNextPage` instead)
- For cursor-based pagination, avoid total count — it defeats the performance benefit

---

## Filtering

### Query Parameter Conventions

```
GET /v1/orders?status=confirmed&created_after=2026-01-01&customer_id=user-123
```

| Pattern | Example | Notes |
|---------|---------|-------|
| Exact match | `?status=confirmed` | |
| Date range | `?created_after=2026-01-01&created_before=2026-04-01` | ISO 8601 dates |
| Multiple values | `?status=confirmed,shipped` | Comma-separated for OR |
| Search | `?q=maria` | Full-text or fuzzy search |
| Nested resource | `?customer_id=user-123` | Filter by relationship |

### Filter Rules

- Use `snake_case` for filter parameter names (matches JSON field convention or URL convention — pick one and be consistent)
- Date parameters use ISO 8601 format: `YYYY-MM-DD` or `YYYY-MM-DDTHH:mm:ssZ`
- Return 400 for unknown filter parameters (don't silently ignore them)
- Document all supported filters per endpoint

---

## Sorting

### Single-Field Sort

```
GET /v1/orders?sort=created_at&order=desc
```

| Parameter | Values | Default |
|-----------|--------|---------|
| `sort` | Field name to sort by | `created_at` (or resource-appropriate default) |
| `order` | `asc` or `desc` | `desc` for timestamps, `asc` for alphabetical |

### Multi-Field Sort

```
GET /v1/orders?sort=status,-created_at
```

Convention: prefix with `-` for descending. No prefix means ascending.

This sorts by `status ASC`, then by `created_at DESC`.

### Default Sort

Every list endpoint should have a sensible default sort:
- Timestamp-based resources: `created_at DESC` (newest first)
- Alphabetical resources: `name ASC`
- Priority-based: `priority DESC, created_at ASC`

Document the default sort in the API docs.

---

## Response Envelope

Use a consistent shape for all list endpoints:

```json
{
  "data": [
    { "id": "order-1", "status": "confirmed" },
    { "id": "order-2", "status": "draft" }
  ],
  "pagination": {
    "hasNextPage": true,
    "nextCursor": "eyJpZCI6Im9yZGVyLTIifQ=="
  }
}
```

### Rules

- **`data`** is always an array (even for 0 or 1 results)
- **`pagination`** is always present on list endpoints
- Single-resource endpoints (GET /orders/{id}) return the object directly, no envelope
- Errors use RFC 7807 format (see `error-format.md`), not this envelope

### Full Example with Filters and Sorting

```
GET /v1/orders?status=confirmed&sort=-created_at&limit=10&after=eyJpZCI6Im9yZGVyLTUwIn0=
```

```json
{
  "data": [
    {
      "id": "order-51",
      "status": "confirmed",
      "totalCents": 8900,
      "createdAt": "2026-04-09T12:00:00Z"
    },
    {
      "id": "order-52",
      "status": "confirmed",
      "totalCents": 4500,
      "createdAt": "2026-04-09T11:30:00Z"
    }
  ],
  "pagination": {
    "hasNextPage": true,
    "hasPreviousPage": true,
    "nextCursor": "eyJpZCI6Im9yZGVyLTUyIn0=",
    "previousCursor": "eyJpZCI6Im9yZGVyLTUxIn0="
  }
}
```
