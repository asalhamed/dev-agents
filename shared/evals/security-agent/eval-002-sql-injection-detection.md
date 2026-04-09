# Eval: security-agent — 002 — SQL Injection Detection

**Tags:** OWASP, SQL injection, code review, security scan
**Skill version tested:** initial

---

## Input (task brief)

```
Security scan: review this Scala code that builds a SQL query:
val query = s"SELECT * FROM orders WHERE customer_id = '$customerId'"
```

---

## Expected Behavior

The security-agent should:
1. Immediately identify string interpolation in SQL as SQL injection (OWASP A03)
2. Rate the finding as Critical severity
3. Provide a specific fix using parameterized queries or prepared statements
4. Produce a `security-scan` contract with FAIL verdict

---

## Pass Criteria

- [ ] SQL injection identified by name
- [ ] OWASP category referenced (A03:2021 Injection)
- [ ] Severity rated as Critical
- [ ] Specific fix provided: parameterized query / prepared statement
- [ ] Code example of the fix (e.g., using Doobie, Slick, or JDBC PreparedStatement)
- [ ] `security-scan` contract produced with FAIL verdict

---

## Fail Criteria

- Misses SQL injection entirely → ❌ fundamental detection failure
- Rates below High severity → ❌ incorrect risk assessment
- Suggests input sanitization as the primary fix (instead of parameterized queries) → ❌ wrong approach
- No `security-scan` contract produced → ❌ contract violation
