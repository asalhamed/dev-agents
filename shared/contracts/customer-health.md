# Customer Health Report

**Producer:** customer-success
**Consumer(s):** product-owner, data-analyst

## Required Fields

- **Customer name** — account identifier
- **Health score** — green / yellow / red (with scoring methodology reference)
- **Device uptime %** — fleet average and worst performers
- **Support ticket volume** — count, trend (increasing/stable/decreasing), avg resolution time
- **Adoption metrics** — features used, API call volume, active users
- **Renewal date** — contract end date and auto-renewal terms
- **Risks** — specific concerns with likelihood and impact
- **Expansion opportunities** — upsell/cross-sell potential with rationale

## Validation Checklist

- [ ] Health score based on objective metrics (not gut feeling)
- [ ] At-risk accounts flagged with specific risks (not just "seems unhappy")
- [ ] Feature requests documented and forwarded to product-owner
- [ ] Renewal timeline noted (flag if <90 days out)

## Example (valid)

```markdown
## CUSTOMER HEALTH: BuildCorp Industries — Q1 2025

**Health score:** 🟡 Yellow
**Devices:** 200 sensors, 12 cameras
**Renewal:** 2025-09-15 (auto-renew, 60-day cancellation notice)

### Device Uptime
- Fleet average: 97.2% (target: 99%)
- Worst: 3 sensors at Site B consistently dropping (WiFi coverage issue)

### Support
- Tickets this quarter: 14 (up from 8 last quarter)
- Avg resolution: 4.2h (SLA: 8h)
- Trend: increasing — driven by Site B connectivity issues

### Adoption
- Dashboard: 8 daily active users (up from 5)
- Mobile app: 3 users (low — training opportunity)
- API: 12K calls/day (stable)
- Unused features: anomaly detection, scheduled reports

### Risks
1. **Site B connectivity** — 3 devices chronically offline. Customer frustrated.
   Likelihood: high. Impact: may block expansion or trigger churn discussion.
2. **Low mobile adoption** — field teams not using mobile app.

### Expansion Opportunities
- Customer expanding to 2 new sites (Q3) — potential +80 devices
- Anomaly detection upsell — customer asked about predictive maintenance
```
