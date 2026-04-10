# Hiring Plan

**Producer:** hr
**Consumer(s):** finance (budget approval)

## Required Fields

- **Role title** — specific job title
- **Level** — junior, mid, senior, staff, principal
- **Team/division** — which team this role belongs to
- **Start date target** — when we need this person
- **Compensation band** — base salary range, currency
- **Equity range** — option/RSU grant range
- **Headcount justification** — why this hire is needed now
- **Interview process outline** — stages, interviewers, timeline
- **Success criteria** — how we'll know this hire is working at 90 days

## Validation Checklist

- [ ] Compensation benchmarked to market (source: levels.fyi, Glassdoor, or recruiter data)
- [ ] Headcount approved by finance (budget allocated)
- [ ] Interview process defined before job posting goes live
- [ ] Success criteria defined (specific, not "fits in well")

## Example (valid)

```markdown
## HIRING PLAN: Senior Embedded Software Engineer

**Level:** Senior (L5)
**Team:** IoT / Device Engineering
**Start date target:** 2025-06-01
**Location:** Remote (US timezone overlap required)

### Compensation
- Base: $160K-$190K USD
- Equity: 0.05-0.08% ISO options (4-year vest, 1-year cliff)
- Signing bonus: $10K (for candidates with competing offers)

### Justification
Current team: 1 embedded engineer handling firmware for 3 device types.
Shipping IoT product requires dedicated firmware lead. Blocking on:
OTA update system, BLE provisioning, power optimization.

### Interview Process (3 weeks total)
1. Recruiter screen — 30min — culture fit, logistics
2. Technical screen — 60min — embedded systems questions, Rust/C
3. Take-home — 3h max — implement MQTT client with reconnect logic
4. System design — 60min — design OTA update pipeline
5. Team fit — 45min — with IoT team + tech-lead

### Success Criteria (90 days)
- Shipped OTA update system to staging
- Owned firmware for at least 1 device type end-to-end
- Contributed to device provisioning architecture
```
