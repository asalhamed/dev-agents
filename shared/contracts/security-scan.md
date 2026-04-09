# Security Scan Report

**Producer:** security-agent (phase 2 — after qa-agent)
**Consumer(s):** reviewer

## Required Fields

- **Task(s) scanned** — which implementation was reviewed
- **Scan scope** — what was checked
- **Dependency vulnerabilities** — tool used, findings
- **Code findings** — OWASP category, location, severity, recommendation
- **Auth review** — JWT/OAuth2/session findings if auth code changed
- **Secrets scan** — result of scanning for committed secrets
- **Overall verdict** — PASS / FAIL

## Validation Checklist

- [ ] Dependency scan run (cargo audit / sbt-dependency-check / npm audit)
- [ ] OWASP Top 10 reviewed
- [ ] Secrets scan completed
- [ ] Auth patterns reviewed if authentication code changed
- [ ] Every Critical/High finding has a recommended fix

## Example (valid)

```markdown
## SECURITY SCAN: Money Value Object (T-004)

**Scope:** src/domain/money.rs, src/domain/errors.rs — domain layer only

**Dependency scan:** `cargo audit` — 0 vulnerabilities found ✅

**Code findings:**
| # | Category | Location | Severity | Finding | Recommendation |
|---|----------|----------|----------|---------|----------------|
| — | — | — | — | No findings | — |

**Auth review:** N/A — no authentication code in this task

**Secrets scan:** `git diff HEAD~1 | grep -iE "(password|secret|token|key)"` — clean ✅

**Overall verdict:** ✅ PASS — no security findings
```
