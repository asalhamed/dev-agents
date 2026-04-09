# OWASP Top 10 (2021) Reference

Quick-reference for code review and threat assessment. Each item includes what it is,
how it shows up in code, how to spot it in review, and how to fix it.

---

## A01: Broken Access Control

**What:** Users act outside their intended permissions — accessing other users' data,
modifying records they shouldn't, or escalating privileges.

**Common code patterns that introduce it:**

```typescript
// ❌ IDOR — no ownership check
app.get('/api/orders/:id', async (req, res) => {
  const order = await db.orders.findById(req.params.id);
  res.json(order); // Anyone can read any order
});

// ❌ Path traversal
app.get('/files/:name', (req, res) => {
  res.sendFile(`/uploads/${req.params.name}`); // ../../etc/passwd
});
```

```rust
// ❌ Missing authorization — only checks authentication
async fn get_order(order_id: Uuid, user: AuthenticatedUser) -> Result<Order> {
    repo.find_by_id(order_id).await // No check: user owns this order?
}
```

**How to detect in review:**
- Endpoint handlers that fetch by ID without filtering by `user_id` or checking ownership
- Missing middleware/guard for role checks on admin routes
- File paths constructed from user input without canonicalization
- `..` or `/` in user-supplied file/path parameters not stripped

**Mitigation:**

| Stack | Fix |
|-------|-----|
| **Rust (Actix/Axum)** | Extractors that enforce ownership: `AuthorizedOrder(order)` that checks `order.user_id == claims.sub`. Use tower middleware for role gates. |
| **Scala (Play/http4s)** | Action composition / middleware that injects authorized context. Never pass raw IDs to repo without ownership filter. |
| **TypeScript (Express/Nest)** | Guards/middleware that verify `req.user.id === resource.ownerId`. Use `path.resolve()` + check prefix for file access. |

**General rules:**
- Default deny — every endpoint requires explicit authorization
- Server-side enforcement — never rely on client hiding UI elements
- Canonicalize paths and reject traversal sequences

---

## A02: Cryptographic Failures

**What:** Sensitive data exposed due to weak/missing encryption, poor key management,
or using broken algorithms.

**Common code patterns:**

```typescript
// ❌ MD5 for password hashing
const hash = crypto.createHash('md5').update(password).digest('hex');

// ❌ Hardcoded encryption key
const key = 'super-secret-key-123';
const cipher = crypto.createCipheriv('aes-128-ecb', key, null); // ECB mode!

// ❌ Sensitive data in logs
logger.info(`User login: email=${email}, password=${password}`);
```

```scala
// ❌ HTTP for sensitive data transmission
val url = s"http://payment-service/charge?card=$cardNumber"
```

**How to detect in review:**
- `md5`, `sha1` used for passwords or security tokens
- `ecb` mode in any cipher
- Encryption keys in source code, env defaults, or config files committed to git
- Sensitive fields (password, SSN, card numbers) logged or returned in API responses
- HTTP URLs for internal service calls carrying sensitive data

**Mitigation:**

| Stack | Fix |
|-------|-----|
| **Rust** | `argon2` crate for password hashing. `aes-gcm` for encryption. Keys from environment/vault, never compiled in. |
| **Scala** | `bcrypt` or `scrypt` via `jBCrypt`. Use `javax.crypto` with AES-GCM. Keys from Vault/config-secret. |
| **TypeScript** | `bcrypt` or `argon2` packages. `crypto.createCipheriv('aes-256-gcm', ...)`. Keys from env/secrets manager. |

**General rules:**
- Argon2id or bcrypt for passwords (never raw hash)
- AES-256-GCM for symmetric encryption (never ECB)
- RSA-2048+ or Ed25519 for asymmetric
- TLS everywhere, including internal services
- Audit logs and API responses for PII leakage

---

## A03: Injection

**What:** Untrusted data sent to an interpreter as part of a command or query — SQL,
OS commands, LDAP, etc.

**Common code patterns:**

```typescript
// ❌ SQL injection via string concatenation
const query = `SELECT * FROM users WHERE name = '${req.query.name}'`;
await db.raw(query);

// ❌ Command injection
const { exec } = require('child_process');
exec(`convert ${req.body.filename} output.png`); // filename = "; rm -rf /"
```

```scala
// ❌ String interpolation in SQL
sql"SELECT * FROM users WHERE name = ${name}".as[User]  // ✅ Slick — parameterized
s"SELECT * FROM users WHERE name = '$name'"              // ❌ Raw string — injectable
```

```rust
// ❌ format! into SQL
let query = format!("SELECT * FROM users WHERE name = '{}'", name);
sqlx::query(&query).fetch_all(&pool).await?;
```

**How to detect in review:**
- `format!`, `f""`, template literals, or `+` concatenation building SQL/commands
- `exec`, `system`, `Process`, `Command::new` with user-derived arguments
- Any query builder bypassing parameterization (`raw()`, `unsafe_raw()`)

**Mitigation:**

| Stack | Fix |
|-------|-----|
| **Rust** | `sqlx::query!` with compile-time checked parameters. `Command::new("convert").arg(filename)` — never shell interpolation. |
| **Scala** | Slick/Doobie parameterized queries. `scala.sys.process` with explicit arg lists, not shell strings. |
| **TypeScript** | Knex/Prisma parameterized queries. `child_process.execFile` with arg array, never `exec` with interpolated strings. |

**General rules:**
- Parameterized queries — always, no exceptions
- Allowlist validation for any value used in commands
- Least privilege DB accounts (read-only where possible)

---

## A04: Insecure Design

**What:** Architectural flaws that can't be fixed by better implementation — missing
threat models, no rate limiting by design, business logic that trusts client state.

**Common patterns:**
- No rate limiting on authentication endpoints
- Password reset via predictable token
- Business rules enforced only on client side
- No account lockout after failed attempts
- Referral/reward systems without abuse limits

**How to detect in review:**
- Auth endpoints without rate limit middleware
- Missing threat model document for new features
- Business logic validation only in frontend code
- No mention of abuse scenarios in design docs

**Mitigation:**
- Require threat modeling for every new feature (STRIDE, attack trees)
- Rate limit all authentication and sensitive endpoints
- Server-side validation of all business rules
- Design abuse scenarios into acceptance criteria
- Use established security design patterns (credential stuffing protection, CAPTCHA after N failures)

---

## A05: Security Misconfiguration

**What:** Insecure default settings, incomplete configurations, verbose error messages,
unnecessary features or services enabled.

**Common patterns:**

```yaml
# ❌ Default credentials in docker-compose
POSTGRES_PASSWORD: postgres
REDIS_PASSWORD: ""

# ❌ Debug mode in production
DEBUG: true
RUST_LOG: trace  # Leaks internal details
```

```typescript
// ❌ Verbose error in production
app.use((err, req, res, next) => {
  res.status(500).json({ error: err.message, stack: err.stack }); // Stack trace!
});
```

**How to detect in review:**
- Default passwords in config files, docker-compose, or helm charts
- `debug: true` or verbose logging in production configs
- Stack traces or internal error details in API error responses
- Unnecessary HTTP headers exposed (`X-Powered-By`, `Server`)
- CORS set to `*` on authenticated endpoints
- Directory listing enabled on static file servers

**Mitigation:**
- Hardening checklist per deployment (disable debug, set strong passwords, strip headers)
- Environment-specific configs — never share dev defaults with production
- Generic error responses in production, detailed only in dev
- Remove `X-Powered-By`, set security headers (CSP, HSTS, X-Frame-Options)
- Automated configuration scanning in CI (e.g., `checkov`, `trivy config`)

---

## A06: Vulnerable and Outdated Components

**What:** Using libraries, frameworks, or OS packages with known vulnerabilities.

**Common patterns:**
- Pinned to old major versions with known CVEs
- No automated dependency update process
- Transitive dependencies never audited
- Using abandoned/unmaintained libraries

**How to detect in review:**
- Lock files with dependencies >1 year old
- No `cargo audit` / `npm audit` / dependency-check in CI
- Libraries with no commits in >2 years
- Known CVE databases flag current versions

**Mitigation:**

| Stack | Fix |
|-------|-----|
| **Rust** | `cargo audit` in CI, `cargo deny` for advisories + licenses, Dependabot/Renovate for updates. |
| **Scala** | `sbt-dependency-check`, Snyk, Dependabot. |
| **TypeScript** | `npm audit --audit-level=high`, Snyk, Dependabot/Renovate. |

See `dependency-scanning.md` for detailed tooling reference.

---

## A07: Identification and Authentication Failures

**What:** Weak authentication mechanisms — allows credential stuffing, brute force,
session hijacking, or identity bypass.

**Common patterns:**

```typescript
// ❌ No password complexity requirement
if (password.length < 4) throw new Error('Too short');

// ❌ Session ID in URL
res.redirect(`/dashboard?sessionId=${session.id}`);

// ❌ No session invalidation on password change
await user.updatePassword(newPassword);
// Old sessions still valid!
```

**How to detect in review:**
- Password policy allows common/short passwords
- No account lockout or rate limiting on login
- Session tokens in URLs or localStorage (XSS-accessible)
- Missing session invalidation on password change/logout
- No MFA option for sensitive operations
- Credentials compared with `===` instead of constant-time comparison

**Mitigation:**
- Minimum 12 characters, check against breached password lists (HaveIBeenPwned API)
- bcrypt/argon2 for storage, constant-time comparison for tokens
- httpOnly, Secure, SameSite cookies for sessions
- Invalidate all sessions on password change
- MFA for admin and sensitive operations
- Rate limit login attempts (e.g., 5 per minute per IP+account)

---

## A08: Software and Data Integrity Failures

**What:** Code and infrastructure that doesn't protect against integrity violations —
unsigned updates, insecure CI/CD pipelines, insecure deserialization.

**Common patterns:**

```typescript
// ❌ Insecure deserialization
const obj = JSON.parse(userInput); // JSON.parse is safe
const obj = deserialize(userInput); // Custom deserializers often aren't

// ❌ No integrity check on CDN resources
<script src="https://cdn.example.com/lib.js"></script>
// Should have: integrity="sha384-..." crossorigin="anonymous"
```

```yaml
# ❌ CI pipeline pulls unverified images
image: some-random-user/build-tool:latest
```

**How to detect in review:**
- CDN scripts without SRI (Subresource Integrity) hashes
- CI/CD pulling unsigned or unverified images/packages
- Deserialization of untrusted data (Java `ObjectInputStream`, Python `pickle`)
- Auto-update mechanisms without signature verification
- npm/pip install from non-registry sources without checksum

**Mitigation:**
- SRI hashes on all CDN-loaded scripts
- Pin and verify container image digests in CI
- Sign artifacts and verify signatures before deployment
- Avoid deserializing untrusted data; use safe formats (JSON) with schema validation
- Lock files committed and `--frozen-lockfile` in CI

---

## A09: Security Logging and Monitoring Failures

**What:** Insufficient logging of security events, no alerting, inability to detect
active breaches or investigate incidents.

**Common patterns:**
- Login failures not logged
- No audit trail for admin actions
- Logs stored only locally (lost on crash/compromise)
- No alerting on anomalous patterns (spike in 401s, mass data export)

**How to detect in review:**
- Auth endpoints with no logging on success/failure
- Admin mutation endpoints with no audit log entry
- No structured logging (can't query/alert on fields)
- Log statements that include sensitive data (passwords, tokens)
- No log shipping to central system (ELK, Datadog, etc.)

**Mitigation:**
- Log all authentication events (success, failure, lockout) with user ID, IP, timestamp
- Audit log for all state-changing admin operations
- Structured JSON logging with correlation IDs
- Ship logs to centralized system, retain ≥90 days
- Alert on: spike in auth failures, unusual data access patterns, privilege escalation
- Never log passwords, tokens, or full credit card numbers

---

## A10: Server-Side Request Forgery (SSRF)

**What:** Application fetches a URL supplied by the user, allowing access to internal
services, cloud metadata endpoints, or other protected resources.

**Common patterns:**

```typescript
// ❌ User-controlled URL fetched server-side
app.post('/api/preview', async (req, res) => {
  const response = await fetch(req.body.url); // Can hit http://169.254.169.254/
  res.json({ content: await response.text() });
});
```

```rust
// ❌ Same pattern in Rust
let url = payload.url; // user-supplied
let body = reqwest::get(&url).await?.text().await?;
```

**How to detect in review:**
- Any endpoint that takes a URL/hostname from user input and fetches it server-side
- Webhook registration without URL validation
- PDF generators, link previews, image proxies — all common SSRF vectors
- No allowlist of permitted destination hosts/IP ranges

**Mitigation:**

| Stack | Fix |
|-------|-----|
| **All** | Allowlist permitted domains/IPs. Resolve DNS and reject private IP ranges (10.x, 172.16-31.x, 192.168.x, 169.254.x, 127.x, ::1). Block cloud metadata IPs. |
| **Rust** | Parse URL, resolve to IP, check against blocked ranges before making request. Use `trust-dns` for controlled resolution. |
| **TypeScript** | `new URL(input)` to parse, resolve hostname with `dns.resolve`, check IP range before `fetch`. Use `ssrf-req-filter` package. |

**General rules:**
- Never fetch arbitrary user-supplied URLs
- If you must (webhooks, previews): allowlist domains, block private IPs, set timeouts
- Network segmentation — the service making outbound requests should not have access to internal admin endpoints
- Disable HTTP redirects or re-validate after redirect
