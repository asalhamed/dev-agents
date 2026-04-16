# Alert Effectiveness Metrics

**Tags:** analytics, alerts, metrics, false-positive, fatigue

## Input

Build an alert effectiveness report tracking alert-to-resolution time, false positive rate, and alert fatigue metrics across all customers.

## Expected Behavior

Agent defines metrics clearly, creates dbt models joining alert and resolution events, tracks false positive rate by type, and identifies alert fatigue patterns.

## Pass Criteria

- [ ] Clear metric definitions
- [ ] dbt models joining alerts with resolutions
- [ ] False positive rate per alert type and customer
- [ ] Alert fatigue metric (alerts/day vs response rate)
- [ ] Produces implementation-summary

## Fail Criteria

- Vague metric definitions
- No join between alerts and resolutions
- No per-customer breakdown
- No fatigue analysis
