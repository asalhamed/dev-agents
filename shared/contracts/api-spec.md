# API Specification

**Producer:** api-designer
**Consumer(s):** backend-dev, frontend-dev, docs-agent

## Required Fields

- **API style** — REST / GraphQL / gRPC
- **Base URL and versioning** — how versions are handled
- **Endpoints** — method, path, request body, response body, status codes
- **Error format** — RFC 7807 Problem Details or stated alternative
- **Pagination** — strategy (cursor/offset), parameters, response shape
- **Authentication** — how requests are authenticated
- **Breaking change policy** — what constitutes a breaking change

## Validation Checklist

- [ ] Every endpoint has success AND error responses documented
- [ ] Error format is consistent (RFC 7807 or stated alternative)
- [ ] No 200 OK with error in body
- [ ] Pagination strategy defined for list endpoints
- [ ] Authentication requirement stated for each endpoint
- [ ] Breaking change policy defined

## Example (valid)

```markdown
## API SPEC: Notification Preferences

**Style:** REST
**Versioning:** URL path — /api/v1/
**Authentication:** Bearer JWT on all endpoints

### GET /api/v1/users/{userId}/notification-preferences
Returns current preferences for a user.

**Response 200:**
```json
{
  "userId": "usr_123",
  "preferences": [
    {
      "category": "SecurityAlert",
      "channels": { "email": true, "push": true, "sms": false },
      "protected": true
    }
  ],
  "pausedUntil": null
}
```
**Response 404:** user not found
**Response 403:** requesting preferences for another user

### PATCH /api/v1/users/{userId}/notification-preferences
Partial update — only provided fields change.

**Response 200:** updated preferences object
**Response 422 (RFC 7807):**
```json
{
  "type": "https://api.example.com/errors/preference-constraint-violation",
  "title": "Preference constraint violation",
  "status": 422,
  "detail": "SecurityAlert requires at least one enabled channel",
  "instance": "/api/v1/users/usr_123/notification-preferences"
}
```

**Breaking change policy:** adding fields to response is non-breaking; removing fields,
changing types, or changing status codes requires a new API version.
```
