# Customer Health Scoring

## Metrics to Track

| Metric | Green | Yellow | Red |
|--------|-------|--------|-----|
| Device uptime | >99% | 95-99% | <95% |
| Connectivity rate | >98% | 90-98% | <90% |
| Alert response time | <30min | 30min-2h | >2h or ignored |
| API usage | Stable/growing | Declining 10-20% | Declining >20% |
| Support tickets/month | 0-2 | 3-5 | >5 or escalations |
| Feature adoption | >3 features | 2-3 features | 1 feature only |
| NPS/CSAT | >8 | 6-8 | <6 |

## Scoring Model

```
Health Score = weighted average of component scores

Weights:
  Device uptime:      25%  (core value delivery)
  Support trend:      20%  (satisfaction signal)
  Feature adoption:   20%  (stickiness)
  API usage trend:    15%  (engagement)
  Alert response:     10%  (active usage)
  Connectivity rate:  10%  (infrastructure health)
```

- **Green:** score ≥ 80 — healthy, focus on expansion
- **Yellow:** score 50-79 — at risk, proactive engagement needed
- **Red:** score < 50 — churn risk, executive escalation

## Leading Indicators of Churn

1. **Device offline trend** — increasing number of offline devices over 4 weeks
2. **Support escalations** — repeated escalations on same issue
3. **Low feature adoption** — only using basic monitoring, ignoring analytics/video
4. **Declining API usage** — integration being deprecated or replaced
5. **Champion departure** — primary contact leaves the company
6. **Renewal silence** — no engagement 60 days before renewal
7. **Competitor mentions** — customer asks about competitor features

## Actions by Health Status

### Green (monthly touchpoint)
- Quarterly business review
- Share product roadmap, get feedback
- Identify expansion opportunities

### Yellow (weekly touchpoint)
- Root cause analysis of declining metrics
- Executive sponsor engagement
- Create action plan with timeline

### Red (daily until stabilized)
- Immediate escalation to CS leadership
- Executive-to-executive call
- Remediation plan with committed timeline
- Consider commercial concessions if warranted
