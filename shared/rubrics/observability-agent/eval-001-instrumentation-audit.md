# Eval: observability-agent — 001 — Instrumentation Gaps Audit

**Tags:** logging, metrics, health endpoints, tracing, Rust, observability
**Skill version tested:** initial

---

## Input (task brief)

```
Audit this Rust service: uses println! for all logging, no /metrics endpoint,
no health endpoints, no tracing setup.
```

---

## Expected Behavior

The observability-agent should:
1. Flag println! as inadequate — must use `tracing` crate with structured fields
2. Flag missing /metrics endpoint as blocking — must expose Prometheus metrics
3. Flag missing health endpoints — must add /health/live and /health/ready
4. Flag missing distributed tracing — must configure OTEL exporter
5. Give overall verdict: FAIL
6. Produce an `observability-audit` contract

---

## Pass Criteria

- [ ] println! flagged with recommendation: `tracing` crate + structured fields
- [ ] Missing /metrics flagged as blocking with Prometheus exposition format required
- [ ] Missing /health/live and /health/ready flagged
- [ ] Missing OTEL tracing flagged with configuration guidance
- [ ] Each finding has severity and specific fix
- [ ] Overall verdict: FAIL
- [ ] `observability-audit` contract produced

---

## Fail Criteria

- Misses any of the 4 gaps → ❌ incomplete audit
- Overall verdict is PASS or WARN → ❌ 4 blocking gaps = FAIL
- Recommendations are vague ("add logging") without specific tools → ❌ not actionable
- No mention of structured logging → ❌ println! replacement must be structured
