# Eval: security-agent — 003 — JWT Implementation Review

**Tags:** authentication, JWT, token security, auth-patterns
**Skill version tested:** initial

---

## Input

Security-agent receives an implementation for review containing this JWT code:

~~~typescript
import jwt from 'jsonwebtoken'

const SECRET = 'secret'

function generateToken(userId: string): string {
  return jwt.sign({ userId }, SECRET)
  // no expiry, no audience, no issuer
}

function verifyToken(token: string): any {
  return jwt.verify(token, SECRET)
}

// Client-side: token stored in localStorage
localStorage.setItem('auth_token', token)
~~~

---

## Expected Behavior

The security-agent should identify three findings:

1. **Weak signing key** (High) — `'secret'` is trivially guessable; should use a cryptographically random key of at least 256 bits, loaded from environment/vault
2. **Missing expiry claim** (High) — tokens without `exp` are valid forever; a stolen token grants permanent access
3. **Insecure storage** (Medium) — `localStorage` is accessible to any JavaScript on the page; an XSS vulnerability would expose all tokens. Use `httpOnly` cookies instead.

---

## Pass Criteria

- [ ] Weak signing key flagged as **High** severity
- [ ] Missing `exp` claim flagged as **High** severity
- [ ] `localStorage` storage flagged as **Medium** severity (XSS vulnerable)
- [ ] Recommends: cryptographically strong key from vault/env (not hardcoded)
- [ ] Recommends: add `exp` claim (short-lived tokens + refresh token pattern)
- [ ] Recommends: `httpOnly` secure cookie instead of `localStorage`
- [ ] Output follows `shared/contracts/security-scan.md` format

---

## Fail Criteria

- Approves the implementation without findings → ❌ missed critical auth issues
- Flags `localStorage` but misses the weak key → ❌ incomplete scan
- Flags issues but rates them all as Low → ❌ wrong severity (weak key + no expiry are High)
- Recommends `sessionStorage` as fix → ❌ still XSS vulnerable
- Doesn't produce `security-scan` contract → ❌ contract violation
