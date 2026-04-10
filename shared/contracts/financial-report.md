# Financial Report

**Producer:** finance
**Consumer(s):** growth-strategist, product-owner

## Required Fields

- **Reporting period** — month/quarter with start and end dates
- **MRR/ARR** — monthly and annualized recurring revenue
- **Burn rate** — monthly cash expenditure
- **Runway** — months of cash remaining at current burn
- **CAC** — customer acquisition cost (blended and by channel)
- **LTV** — lifetime value (with calculation methodology)
- **LTV/CAC ratio** — with benchmark comparison
- **Gross margin** — revenue minus COGS as percentage
- **Top cost drivers** — ranked by spend
- **90-day forecast** — projected MRR, burn, key assumptions
- **Key risks** — financial risks and scenarios

## Validation Checklist

- [ ] All assumptions documented (growth rate, churn rate, pricing)
- [ ] Sensitivity analysis included (best/base/worst case)
- [ ] Data sourced from actuals (not estimates where actuals are available)
- [ ] Risks explicitly listed with potential impact

## Example (valid)

```markdown
## FINANCIAL REPORT: March 2025

**Period:** 2025-03-01 → 2025-03-31
**MRR:** $42K | **ARR:** $504K

### Unit Economics
- Customers: 12 (net +2 this month)
- Average ACV: $42K
- CAC (blended): $8.5K | LTV: $126K | **LTV/CAC: 14.8x**
- Gross margin: 72% (COGS: cloud infra $8.2K, connectivity $3.6K)

### Burn & Runway
- Monthly burn: $85K (team: $62K, infra: $12K, other: $11K)
- Cash: $1.2M → **Runway: 14 months**

### Top Cost Drivers
1. Payroll: $62K (73%)
2. Cloud infrastructure: $12K (14%)
3. Connectivity (cellular): $3.6K (4%)

### Cost per Device
- 1,400 active devices → $0.56/device/month COGS
- Revenue/device: $2.50/device/month → **78% device-level margin**

### 90-Day Forecast
- MRR target: $58K (+38%) — based on 3 pipeline deals closing
- Burn increase: $92K (1 new hire)
- Assumption: 0% churn (no contracts up for renewal)

### Risks
- Pipeline deals slip → MRR flat at $42K → runway shrinks to 12 months
- Large customer (30% of MRR) renewal in Q3 — at-risk (Yellow health)
```
