# Fleet Health Dashboard

**Tags:** analytics, dashboard, dbt, grafana, fleet

## Input

Design a fleet health dashboard for 10,000 devices across 50 sites. Show real-time device status, uptime trends, and alert on fleet-wide degradation.

## Expected Behavior

Agent produces data model, dbt transformations, dashboard layout (fleet→site→device drill-down), refresh strategy, and alerting rules.

## Pass Criteria

- [ ] Data model separates raw from derived metrics
- [ ] dbt models for uptime and site health
- [ ] Dashboard: fleet overview → site → device drill-down
- [ ] Real-time status, hourly trends
- [ ] Alert on >5% fleet offline
- [ ] Produces implementation-summary

## Fail Criteria

- No drill-down capability
- Raw data displayed (no aggregation)
- No alerting
- Manual refresh only
