# Observability Patterns

Reference guide for metrics, logging, tracing, health endpoints, and alerting.

---

## The Three Pillars

| Pillar | What | Tool Options | Query Example |
|--------|------|-------------|---------------|
| **Metrics** | Numeric time-series: counters, gauges, histograms | Prometheus, Datadog, InfluxDB, CloudWatch | `rate(http_requests_total{status="500"}[5m])` |
| **Logging** | Structured event records with context | ELK (Elasticsearch + Logstash + Kibana), Loki + Grafana, CloudWatch Logs | `{app="order-service"} |= "error" | json | line_format "{{.msg}}"` |
| **Tracing** | Request-scoped call graphs across services | Jaeger, Zipkin, Tempo, AWS X-Ray, Honeycomb | `service.name=order-service AND http.status_code>=500` |

**Rule:** All three pillars must be present in production. Metrics tell you *what* is wrong, logs tell you *why*, and traces tell you *where* in the call chain.

---

## Structured Logging

### Rust — `tracing` Crate

```rust
use tracing::{info, warn, instrument};

#[instrument(skip(repo), fields(order_id = %order_id))]
async fn confirm_order(
    order_id: OrderId,
    repo: &dyn OrderRepository,
) -> Result<(), DomainError> {
    let order = repo.find_by_id(order_id).await?;

    info!(
        order_id = %order_id,
        item_count = order.items.len(),
        status = ?order.status,
        "Confirming order"
    );

    let confirmed = order.confirm()?;
    repo.save(&confirmed).await?;

    info!(order_id = %order_id, "Order confirmed successfully");
    Ok(())
}
```

**Rules for Rust logging:**
- Use `tracing` crate (not `log`) — it supports structured fields and spans
- `#[instrument]` on async functions for automatic span creation
- `skip` sensitive or large parameters (repos, passwords, request bodies)
- Structured fields: `field_name = %value` for Display, `field_name = ?value` for Debug

### Scala 3 — SLF4J + StructuredArguments + MDC

```scala
import org.slf4j.{LoggerFactory, MDC}
import net.logstash.logback.argument.StructuredArguments.kv

class ConfirmOrderUseCase(repo: OrderRepository):
  private val logger = LoggerFactory.getLogger(getClass)

  def execute(orderId: OrderId): Either[DomainError, Unit] =
    MDC.put("orderId", orderId.toString)
    try
      logger.info("Confirming order", kv("orderId", orderId), kv("action", "confirm"))

      val result = for
        order <- repo.findById(orderId).toRight(OrderNotFound(orderId))
        confirmed <- order.confirm
        _ <- repo.save(confirmed)
      yield
        logger.info("Order confirmed",
          kv("orderId", orderId),
          kv("itemCount", confirmed.items.size)
        )

      result
    finally
      MDC.remove("orderId")
```

**Rules for Scala logging:**
- Use SLF4J with Logback — structured via `StructuredArguments.kv()`
- MDC for request-scoped context (orderId, userId, traceId)
- Always clear MDC in `finally` block or use a bracketing effect
- JSON format in production (logstash-logback-encoder)

### Log Levels

| Level | When | Example |
|-------|------|---------|
| **ERROR** | Action required — something failed that shouldn't | DB connection lost, payment processing failed |
| **WARN** | Attention needed — degraded but functional | Retry succeeded after 2 attempts, cache miss fallback |
| **INFO** | Business events — normal operation milestones | Order confirmed, user logged in, deployment started |
| **DEBUG** | Technical details — useful for debugging | SQL query executed, cache hit/miss, parsed request |
| **TRACE** | Verbose — rarely enabled in production | Individual loop iterations, full request/response bodies |

**Rule:** Production runs at INFO. DEBUG is enabled per-service when investigating issues. TRACE is never on in production.

---

## Metrics

### Prometheus Naming Conventions

```
# Format: <namespace>_<subsystem>_<name>_<unit>
# Examples:
order_service_http_requests_total          # counter
order_service_http_request_duration_seconds # histogram
order_service_active_connections            # gauge
order_service_orders_confirmed_total        # counter (domain)
```

**Rules:**
- Suffix `_total` for counters
- Suffix `_seconds`, `_bytes`, `_ratio` for unit clarity
- Snake_case, lowercase only
- Namespace = service name

### Key Metrics

| Category | Metric | Type | Description |
|----------|--------|------|-------------|
| **RED — Rate** | `http_requests_total` | Counter | Total requests by method, path, status |
| **RED — Error** | `http_requests_total{status=~"5.."}` | Counter | 5xx error count |
| **RED — Duration** | `http_request_duration_seconds` | Histogram | Request latency (p50, p95, p99) |
| **USE — Utilization** | `container_cpu_usage_seconds_total` | Counter | CPU time consumed |
| **USE — Saturation** | `container_memory_working_set_bytes` | Gauge | Memory pressure |
| **USE — Errors** | `container_oom_kills_total` | Counter | OOM kill events |
| **Domain** | `orders_confirmed_total` | Counter | Business event: orders confirmed |
| **Domain** | `payment_processing_duration_seconds` | Histogram | Business SLA: payment latency |
| **Domain** | `inventory_stock_level` | Gauge | Current stock for a product |

### Kubernetes Scrape Annotations

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service
spec:
  template:
    metadata:
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "9090"
        prometheus.io/path: "/metrics"
    spec:
      containers:
        - name: order-service
          ports:
            - name: metrics
              containerPort: 9090
```

---

## Distributed Tracing

### OpenTelemetry Configuration

```yaml
env:
  - name: OTEL_SERVICE_NAME
    value: "order-service"
  - name: OTEL_EXPORTER_OTLP_ENDPOINT
    value: "http://otel-collector:4317"
  - name: OTEL_EXPORTER_OTLP_PROTOCOL
    value: "grpc"
  - name: OTEL_TRACES_SAMPLER
    value: "parentbased_traceidratio"
  - name: OTEL_TRACES_SAMPLER_ARG
    value: "0.1"  # 10% sampling in production
```

### Trace Context Propagation

**HTTP — W3C Trace Context:**
- Always propagate `traceparent` and `tracestate` headers
- Incoming: extract trace context from request headers
- Outgoing: inject trace context into outbound HTTP calls
- Use OpenTelemetry SDK propagators — don't manually parse headers

**Kafka / Message Queues:**
- Inject trace context into message headers (not message body)
- Consumer creates a child span linked to the producer span
- Use `LINK` for batch consumers processing multiple messages

**Rules:**
- Every service must propagate trace context — broken chains make tracing useless
- Use `parentbased_traceidratio` sampler so child services respect the parent's sampling decision
- Tag spans with: `service.name`, `http.method`, `http.status_code`, `db.statement` (parameterized)
- Never put PII in span attributes (no emails, passwords, full names)

---

## Health Endpoints

### Liveness — `/health/live`

```
GET /health/live

200 OK → service process is running and not deadlocked
503 Service Unavailable → service should be restarted (K8s will kill the pod)
```

**What it checks:** Process is alive, not deadlocked. Does NOT check dependencies.

### Readiness — `/health/ready`

```
GET /health/ready

200 OK → service can accept traffic
503 Service Unavailable → remove from load balancer (K8s stops routing traffic)
```

**What it checks:** Database connection pool active, required caches warm, dependent services reachable.

**Rules:**
- Liveness is cheap and fast — never check external dependencies
- Readiness may check dependencies but must have timeouts (< 5s total)
- Both endpoints return JSON: `{ "status": "ok" }` or `{ "status": "degraded", "checks": {...} }`
- Never require authentication on health endpoints

---

## Alerting Rules

Define alerts for conditions that require human attention:

1. **Error rate spike:** `rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.05` — more than 5% errors for 5 minutes
2. **Latency degradation:** `histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m])) > 2.0` — p99 latency exceeds 2 seconds
3. **Pod restart loop:** `increase(kube_pod_container_status_restarts_total[1h]) > 3` — container restarting repeatedly
4. **Disk pressure:** `kubelet_volume_stats_available_bytes / kubelet_volume_stats_capacity_bytes < 0.1` — less than 10% disk remaining

**Rules:**
- Alert on symptoms (error rate, latency), not causes (CPU usage alone)
- Every alert must have a runbook link in the annotation
- Use `for: 5m` or longer to avoid flapping alerts
- Page only for customer-impacting issues; everything else goes to a dashboard

---

## Dashboard Template

Every service should have a standard dashboard with these 5 panels:

1. **Request Rate** — `rate(http_requests_total[5m])` grouped by status code (200/4xx/5xx)
2. **Latency Percentiles** — p50, p95, p99 of `http_request_duration_seconds` over time
3. **Error Rate** — `rate(http_requests_total{status=~"5.."}[5m])` as percentage of total
4. **Resource Usage** — CPU and memory utilization vs. limits (container-level)
5. **Domain Events** — Business metric counters (orders confirmed, payments processed, etc.)

**Rules:**
- Every dashboard has a service selector variable at the top
- Time range defaults to "last 1 hour" with 15s refresh
- RED metrics (Rate, Error, Duration) are always the top row
- Domain metrics are always the bottom row — these are the business SLAs
