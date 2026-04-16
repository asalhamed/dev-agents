# Eval: observability-agent — 002 — Alert Rules Review

**Tags:** alerting, SLO, RED metrics, burn rate, CPU alerts
**Skill version tested:** initial

---

## Input (task brief)

```
Audit alert rules for an order service. Current alerts: 'CPU > 80% for 5min'.
No latency or error rate alerts.
```

---

## Expected Behavior

The observability-agent should:
1. Note CPU alert as insufficient — not SLO-based, not user-facing
2. Identify missing error rate alert (e.g., 5xx > 1%)
3. Identify missing latency alert (e.g., p99 > threshold)
4. Identify missing domain metric alert (e.g., orders_confirmed_total stalled)
5. Provide actionable recommendations with example alert rules
6. Produce an `observability-audit` contract

---

## Pass Criteria

- [ ] CPU > 80% noted as a symptom, not an SLO — keep but don't rely on it alone
- [ ] Missing: error rate alert (e.g., `rate(http_requests_total{status=~"5.."}[5m])`)
- [ ] Missing: p99 latency alert
- [ ] Missing: domain metric alert (zero throughput on orders_confirmed_total)
- [ ] Recommendations include example Prometheus/Grafana alert rules
- [ ] Burn-rate alerting concept mentioned or recommended
- [ ] `observability-audit` contract produced

---

## Fail Criteria

- Says CPU alert is sufficient → ❌ fundamentally wrong
- Misses error rate or latency alerts → ❌ core RED metrics missing
- No example alert rules provided → ❌ not actionable
- No mention of SLO-based alerting → ❌ missing modern practice
