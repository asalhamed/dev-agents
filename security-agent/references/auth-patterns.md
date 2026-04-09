# Authentication & Authorization Patterns

Reference for secure auth implementation across stacks.

---

## JWT Best Practices

### Token Structure

A JWT has three base64url-encoded parts: `header.payload.signature`.

```json
// Header
{ "alg": "RS256", "typ": "JWT", "kid": "2024-key-1" }

// Payload
{
  "sub": "user-123",
  "iss": "https://auth.example.com",
  "aud": "https://api.example.com",
  "exp": 1704067200,
  "nbf": 1704063600,
  "iat": 1704063600,
  "roles": ["user"]
}
```

### Rules

| Rule | Why |
|------|-----|
| **Always verify signature** | An unverified JWT is just a base64 string anyone can forge. |
| **Check `exp` and `nbf`** | Reject expired tokens and tokens not yet valid. |
| **Validate `iss` and `aud`** | Prevents token confusion attacks across services. |
| **Use RS256 for distributed systems** | Asymmetric — services verify with public key, only auth service has private key. HS256 requires shared secret on every service. |
| **Never put sensitive data in payload** | The payload is base64-encoded, not encrypted. Anyone can read it. |
| **Store in httpOnly cookie, not localStorage** | localStorage is accessible to any JS on the page (XSS). httpOnly cookies are not. |
| **Short expiry (15 min) + refresh tokens** | Limits the window if a token is stolen. Refresh token is long-lived but stored securely and can be revoked. |
| **Include `kid` (key ID) in header** | Enables key rotation without breaking existing tokens. |

### Token Verification (Rust example)

```rust
use jsonwebtoken::{decode, DecodingKey, Validation, Algorithm};

let mut validation = Validation::new(Algorithm::RS256);
validation.set_issuer(&["https://auth.example.com"]);
validation.set_audience(&["https://api.example.com"]);
// exp and nbf are checked by default

let token_data = decode::<Claims>(
    &token,
    &DecodingKey::from_rsa_pem(public_key_pem)?,
    &validation,
)?;
```

### Token Verification (TypeScript example)

```typescript
import jwt from 'jsonwebtoken';

const decoded = jwt.verify(token, publicKey, {
  algorithms: ['RS256'],
  issuer: 'https://auth.example.com',
  audience: 'https://api.example.com',
});
```

### Anti-patterns

- ❌ `jwt.decode()` without `jwt.verify()` — skips signature check
- ❌ `algorithms: ['none']` in verification options — allows unsigned tokens
- ❌ Using the same secret for HS256 across all microservices
- ❌ JWTs that never expire
- ❌ Storing refresh tokens in localStorage

---

## OAuth2 Flows

### Authorization Code (Web Apps)

**Use when:** Server-rendered web app or web app with a backend.

```
User → Authorization Server: GET /authorize?response_type=code&client_id=...&redirect_uri=...&scope=...&state=RANDOM
User ← Authorization Server: Login page
User → Authorization Server: Credentials
User ← Authorization Server: 302 redirect to redirect_uri?code=AUTH_CODE&state=RANDOM
Backend → Authorization Server: POST /token { grant_type=authorization_code, code=AUTH_CODE, client_secret=... }
Backend ← Authorization Server: { access_token, refresh_token, expires_in }
```

**Key points:**
- `state` parameter prevents CSRF — generate random, store in session, verify on callback
- `client_secret` never leaves the backend
- Auth code is single-use and short-lived (< 10 min)

### Authorization Code + PKCE (Mobile / SPA)

**Use when:** Public client (no client_secret) — mobile apps, single-page apps.

```
Client: Generate code_verifier (random 43-128 chars)
Client: code_challenge = BASE64URL(SHA256(code_verifier))
Client → Auth Server: GET /authorize?...&code_challenge=...&code_challenge_method=S256
... (same redirect flow) ...
Client → Auth Server: POST /token { grant_type=authorization_code, code=AUTH_CODE, code_verifier=ORIGINAL }
```

**Key points:**
- No client_secret needed — PKCE proves the same client that started the flow is finishing it
- `code_verifier` never travels over the network until token exchange
- Always use `S256`, never `plain` for code_challenge_method

### Client Credentials (Service-to-Service)

**Use when:** Backend service authenticating to another backend service. No user context.

```
Service → Auth Server: POST /token { grant_type=client_credentials, client_id=..., client_secret=..., scope=... }
Service ← Auth Server: { access_token, expires_in }
```

**Key points:**
- No refresh token — just request a new access token when it expires
- Scope should be minimal — only what this service needs
- Rotate client_secret periodically
- Store credentials in vault/secrets manager, never in code

### Flow Selection Guide

| Scenario | Flow |
|----------|------|
| Web app with backend | Authorization Code |
| SPA (React, Vue) | Authorization Code + PKCE |
| Mobile app | Authorization Code + PKCE |
| Microservice calling microservice | Client Credentials |
| CLI tool on user's machine | Device Authorization Grant |

---

## RBAC Pattern

### Model

```
User ──has──▶ Role ──grants──▶ Permission ──on──▶ Resource
```

**Example:**

```typescript
// Roles
const roles = {
  admin:  ['orders:read', 'orders:write', 'orders:delete', 'users:read', 'users:write'],
  manager: ['orders:read', 'orders:write', 'users:read'],
  viewer: ['orders:read'],
};

// Middleware
function requirePermission(permission: string) {
  return (req, res, next) => {
    const userPerms = roles[req.user.role] ?? [];
    if (!userPerms.includes(permission)) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    next();
  };
}

app.delete('/api/orders/:id', requirePermission('orders:delete'), deleteOrder);
```

### Rust Example

```rust
#[derive(Debug, Clone, PartialEq)]
pub enum Permission {
    OrdersRead,
    OrdersWrite,
    OrdersDelete,
    UsersRead,
    UsersWrite,
}

pub fn role_permissions(role: &str) -> &[Permission] {
    match role {
        "admin" => &[Permission::OrdersRead, Permission::OrdersWrite, Permission::OrdersDelete,
                     Permission::UsersRead, Permission::UsersWrite],
        "manager" => &[Permission::OrdersRead, Permission::OrdersWrite, Permission::UsersRead],
        "viewer" => &[Permission::OrdersRead],
        _ => &[],
    }
}

// Axum extractor
pub struct Authorized<const P: Permission>;
```

### Design Rules

- Assign roles to users, permissions to roles — never assign permissions directly to users
- Keep permissions granular: `resource:action` format
- Check permissions server-side on every request
- Store role assignments in the database, not in JWTs (JWTs can carry role name for performance, but source of truth is DB)
- Audit role changes

---

## Common Auth Mistakes & Fixes

### 1. Timing Attacks on Token Comparison

```typescript
// ❌ Vulnerable — early exit reveals token length match
if (providedToken === storedToken) { ... }

// ✅ Constant-time comparison
import crypto from 'crypto';
const isValid = crypto.timingSafeEqual(
  Buffer.from(providedToken),
  Buffer.from(storedToken),
);
```

```rust
// ✅ Rust — use constant_time_eq crate
use constant_time_eq::constant_time_eq;
if constant_time_eq(provided.as_bytes(), stored.as_bytes()) { ... }
```

### 2. Weak Signing Keys

```typescript
// ❌ Short/predictable HS256 secret
const token = jwt.sign(payload, 'secret');

// ✅ Strong secret (256+ bits of entropy)
const token = jwt.sign(payload, process.env.JWT_SECRET); // 64+ random hex chars
// Or better: use RS256 with proper key pair
```

### 3. Missing Token Expiry

```typescript
// ❌ Token lives forever
const token = jwt.sign({ sub: userId }, secret);

// ✅ Short-lived access token
const token = jwt.sign({ sub: userId }, secret, { expiresIn: '15m' });
```

### 4. Token in URL Query Parameter

```
❌ https://api.example.com/data?token=eyJhbGci...
```

Tokens in URLs end up in:
- Browser history
- Server access logs
- Referrer headers
- Proxy logs

**Fix:** Send tokens in `Authorization: Bearer <token>` header or httpOnly cookies.

### 5. Overly Broad Permissions

```typescript
// ❌ One token to rule them all
const token = jwt.sign({ sub: userId, scope: '*' }, secret);

// ✅ Minimal scope per use case
const token = jwt.sign({ sub: userId, scope: 'orders:read' }, secret);
```

**Rule of thumb:** A token should have the minimum permissions needed for its purpose.
API keys for read-only integrations should not have write access.
