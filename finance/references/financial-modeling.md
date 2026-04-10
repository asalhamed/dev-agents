# Financial Modeling for IoT SaaS

## Key Metrics

### Revenue
- **MRR:** Monthly Recurring Revenue = sum of all active subscriptions
- **ARR:** Annual Recurring Revenue = MRR × 12
- **Net Revenue Retention (NRR):** (Starting MRR + expansion - contraction - churn) / Starting MRR
  - Target: >110% (expansion exceeds churn)

### Churn
- **Gross churn:** MRR lost from downgrades + cancellations / Starting MRR
  - Target: <2% monthly (24% annual)
- **Logo churn:** customers lost / total customers
  - Target: <5% annual for enterprise

### Unit Economics
- **LTV:** ACV × gross margin ÷ annual churn rate
  - Example: $50K ACV × 75% margin ÷ 15% churn = $250K LTV
- **CAC:** total sales & marketing spend ÷ new customers acquired
  - Target: LTV/CAC > 3x
- **CAC payback:** CAC ÷ (ACV × gross margin)
  - Target: <18 months

## IoT-Specific Unit Economics

### Device-Level
```
Revenue per device: $25/month
COGS per device:
  - Cloud compute:   $1.50
  - Connectivity:    $8.00
  - Storage:         $0.50
  - Support:         $2.00
  Total COGS:        $12.00
Gross profit/device: $13.00 (52% margin)
```

### Hardware Margin (if selling devices)
- Don't sell hardware at cost — 20-40% margin minimum
- Hardware should not be a profit center — it's a channel to platform revenue
- Consider hardware-as-a-service (include device in monthly subscription)

## Runway Modeling

```
Runway (months) = Cash ÷ Monthly Burn

Monthly Burn = Payroll + Infrastructure + Office + Marketing + G&A - Revenue

Scenario Planning:
  Base case: current trajectory
  Optimistic: pipeline converts at 50%
  Conservative: no new customers, current churn rate
  Worst case: lose largest customer + no new sales
```

## Key Rules
- Revenue recognition: recognize monthly as service is delivered (not upfront)
- Hardware revenue: recognize on delivery (not subscription)
- Always model worst case: what happens if largest customer churns?
- Watch NRR: most important metric for IoT SaaS (expansion > churn = compounding growth)
