# SOC2 Type II Gap Analysis

**Tags:** compliance, soc2, gap-analysis, security

## Input

SOC2 gap analysis for IoT platform. Have: RBAC, TLS, daily backups. Missing: centralized logging, automated access reviews.

## Expected Behavior

Agent assesses CC6/CC7/A1 controls, acknowledges existing controls, identifies gaps with severity, and creates remediation plan with evidence requirements.

## Pass Criteria

- [ ] All relevant controls assessed
- [ ] Existing controls acknowledged
- [ ] Gaps with severity ratings
- [ ] Remediation plan with owners/timelines
- [ ] Evidence collection plan
- [ ] Produces compliance-audit

## Fail Criteria

- Incomplete control coverage
- Ignores existing controls
- No severity ratings
- No remediation plan
