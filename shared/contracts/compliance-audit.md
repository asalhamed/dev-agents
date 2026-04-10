# Compliance Audit

**Producer:** compliance-agent
**Consumer(s):** legal, reviewer

## Required Fields

- **Framework** — SOC2 Type I/II, ISO 27001, GDPR, NIST, ETSI EN 303 645
- **Audit scope** — systems, services, and data flows in scope
- **Controls assessed** — specific control IDs and descriptions
- **Gaps found** — each with severity (critical/high/medium/low) and description
- **Remediation plan** — prioritized actions with owners and timelines
- **Evidence required** — what documentation/artifacts support each control

## Validation Checklist

- [ ] All in-scope systems assessed (no gaps in coverage)
- [ ] Every gap has severity rating and specific description
- [ ] Remediation items have owners and timelines
- [ ] Evidence collection plan included (what to gather, where it lives)

## Example (valid)

```markdown
## COMPLIANCE AUDIT: SOC2 Type II Gap Analysis

**Framework:** SOC2 Type II
**Scope:** Video monitoring platform (cloud + edge), customer data flows
**Date:** 2025-Q1

### Controls Assessed
- CC6.1 — Logical access controls
- CC6.6 — Encryption of data in transit
- CC7.2 — Monitoring for anomalies and security events
- A1.2 — Recovery mechanisms and incident response

### Gaps Found

| # | Control | Severity | Gap |
|---|---------|----------|-----|
| 1 | CC7.2 | High | No centralized security event logging — edge nodes log locally only |
| 2 | CC6.1 | Medium | Service-to-service auth uses shared API keys, not mTLS |
| 3 | A1.2 | Medium | Disaster recovery plan exists but untested in 12 months |

### Remediation Plan
1. **[High]** Centralize edge logs to SIEM — @devops — 2025-04-15
2. **[Medium]** Migrate service auth to mTLS — @backend-dev — 2025-05-01
3. **[Medium]** Schedule and execute DR test — @incident-responder — 2025-04-30

### Evidence Required
- CC6.1: Access control policy doc, IAM screenshots, audit log samples
- CC7.2: SIEM dashboard, alert rule definitions, sample alert
- A1.2: DR plan document, DR test report with findings
```
