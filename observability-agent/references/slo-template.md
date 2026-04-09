# SLO Template

Reference for defining Service Level Objectives, calculating error budgets,
and setting up burn-rate alerting.

---

## SLO vs SLA vs SLI

| Term | Definition | Owner | Consequence of Breach |
|------|-----------|-------|----------------------|
| **SLI** (Service Level Indicator) | A metric that measures service reliability. A number. | Engineering | None directly — it's just data |
| **SLO** (Service Level Objective) | An internal target for an SLI. A goal. | Engineering + Product | Triggers error budget policies (freeze deploys, prioritize reliability) |
| **SLA** (Service Level Agreement) | An external contract with customers. A promise. | Business + Legal | Financial penalties, credits, contractual consequences |

**Rule:** SLO must be stricter than SLA. If your SLA promises 99.9%, your SLO should target 99.95%.

---

## SLO Definition Format

Every SLO must include these fields:

| Field | Description | Example |
|-------|-------------|---------|
| **Service** | Name of the service | `order-service` |
| **SLI** | What's measured and how | Availability: `successful requests (non-5xx) / total requests` |
| **Target** | The percentage target | `99.9%` |
| **Window** | Measurement period | `28 days (rolling)` |
| **Error Budget** | Allowed failure within the window | `40.3 minutes` or `0.1% of requests` |
| **Owner** | Team responsible | `order-team` |
| **Escalation** | What happens when budget is depleted | Freeze non-critical deploys, page on-call |

---

## Common SLIs

### Availability

```
SLI = (total requests - 5xx responses) / total requests × 100%
```

Measures: Is the service responding successfully?
Typical targets: 99.9% (most services), 99.99% (critical path)

### Latency

```
SLI = requests completing within threshold / total requests × 100%
Example: p99 latency < 500ms
```

Measures: Is the service responding fast enough?
Typical targets: 99% of requests < 200ms (internal), 95% < 500ms (user-facing)

### Error Rate

```
SLI = error responses (5xx) / total responses × 100%
```

Measures: How often does the service fail?
Typical targets: < 0.1% (critical), < 1% (non-critical)

### Correctness (domain-specific)

```
SLI = events processed correctly / total events × 100%
Example: orders_confirmed_total increasing at expected rate
```

Measures: Is the service producing correct results?

---

## Error Budget Calculation

**Formula:** `Error Budget = (1 - SLO target) × measurement window`

### Worked Example: 99.9% over 28 days

```
Error budget (time)    = (1 - 0.999) × 28 days × 24 hours × 60 minutes
                       = 0.001 × 40,320 minutes
                       = 40.32 minutes

Error budget (requests) = 0.1% of total requests
                        = If 1,000,000 requests/28 days → 1,000 errors allowed
```

### Common Error Budgets

| SLO Target | 28-Day Budget (time) | 28-Day Budget (% requests) |
|------------|---------------------|---------------------------|
| 99% | 403 minutes (~6.7 hours) | 1% |
| 99.5% | 202 minutes (~3.4 hours) | 0.5% |
| 99.9% | 40.3 minutes | 0.1% |
| 99.95% | 20.2 minutes | 0.05% |
| 99.99% | 4.0 minutes | 0.01% |

---

## Burn Rate Alerting

The burn rate is how fast you're consuming your error budget relative to the window.

```
Burn Rate = (actual error rate) / (error budget rate)

If SLO = 99.9% over 28 days:
  Error budget rate = 0.1%
  If current error rate = 1% → burn rate = 10x
  At 10x burn rate, 28-day budget exhausted in 2.8 days
```

### Alert Tiers

| Alert | Burn Rate | Budget Consumed | Time to Exhaustion | Action |
|-------|-----------|----------------|-------------------|--------|
| **Fast burn (P1 — page now)** | 14.4x | 2% in 1 hour | ~1.9 hours | Page on-call immediately |
| **Fast burn (P1 — confirm)** | 6x | 5% in 6 hours | ~4.7 hours | Page if not self-resolving |
| **Slow burn (P2 — ticket)** | 1x | 10% in 3 days | 28 days | Create ticket, investigate this week |

### Why Burn Rate > Static Threshold

- Static alert (`error rate > 1%`) fires for brief spikes that don't affect the budget
- Burn rate alerts only fire when budget consumption is unsustainable
- Fewer false alarms, more actionable alerts

---

## Complete Example: Order Service SLO

### SLO-001: Order Service Availability

| Field | Value |
|-------|-------|
| **Service** | `order-service` |
| **SLI** | Availability: `(total HTTP requests - 5xx responses) / total HTTP requests` |
| **Target** | 99.9% |
| **Window** | 28 days (rolling) |
| **Error Budget** | 40.3 minutes of downtime OR 0.1% of requests |
| **Owner** | order-team |
| **Data Source** | Prometheus: `http_requests_total{service="order-service"}`, `http_requests_total{service="order-service", status=~"5.."}` |

### SLO-002: Order Service Latency

| Field | Value |
|-------|-------|
| **Service** | `order-service` |
| **SLI** | Latency: `requests with duration < 500ms / total requests` |
| **Target** | 99% of requests under 500ms |
| **Window** | 28 days (rolling) |
| **Error Budget** | 1% of requests may exceed 500ms |
| **Owner** | order-team |
| **Data Source** | Prometheus: `http_request_duration_seconds_bucket{service="order-service", le="0.5"}` |

### SLO-003: Order Confirmation Correctness

| Field | Value |
|-------|-------|
| **Service** | `order-service` |
| **SLI** | Correctness: `orders_confirmed_total` increasing at expected rate during business hours |
| **Target** | No zero-throughput periods > 5 minutes during business hours |
| **Window** | 28 days (rolling) |
| **Error Budget** | 5 minutes of zero throughput per window |
| **Owner** | order-team |
| **Data Source** | Prometheus: `rate(orders_confirmed_total[5m])` |

### Alert Rules (Prometheus)

```yaml
# Fast burn — page immediately
- alert: OrderServiceHighBurnRate
  expr: |
    (
      sum(rate(http_requests_total{service="order-service", status=~"5.."}[1h]))
      /
      sum(rate(http_requests_total{service="order-service"}[1h]))
    ) > 14.4 * 0.001
  for: 2m
  labels:
    severity: page
  annotations:
    summary: "Order service burning error budget at 14.4x rate"

# Slow burn — ticket
- alert: OrderServiceSlowBurnRate
  expr: |
    (
      sum(rate(http_requests_total{service="order-service", status=~"5.."}[3d]))
      /
      sum(rate(http_requests_total{service="order-service"}[3d]))
    ) > 1.0 * 0.001
  for: 1h
  labels:
    severity: ticket
  annotations:
    summary: "Order service error budget trending toward exhaustion"
```
