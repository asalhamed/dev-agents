# Observability Audit

**Producer:** observability-agent
**Consumer(s):** reviewer

## Required Fields

- **Services audited** — which services were reviewed
- **Logging coverage** — are domain events and error paths logged structurally?
- **Metrics coverage** — are RED metrics exposed?
- **Tracing coverage** — does trace context propagate through async boundaries?
- **Alert rules** — do alerts exist for SLOs?
- **Health endpoints** — are /health/live and /health/ready present?
- **Gaps** — what's missing, severity (blocking / non-blocking)
- **Overall verdict** — PASS / FAIL

## Validation Checklist

- [ ] Structured logging on all domain events (not println!)
- [ ] RED metrics exposed (Rate, Errors, Duration)
- [ ] At least one domain metric (e.g., orders_confirmed_total)
- [ ] Trace context in HTTP headers and Kafka messages
- [ ] Error rate + latency p99 alerts defined
- [ ] /health/live and /health/ready implemented

## Example (valid)

```markdown
## OBSERVABILITY AUDIT: order-service

**Logging:** ✅ Structured JSON via tracing crate. All domain events logged at INFO with structured fields. Error paths log at ERROR with context.

**Metrics:** ✅ RED metrics on /metrics endpoint.
- http_requests_total{method, path, status} ✅
- http_request_duration_seconds ✅
- orders_confirmed_total (domain metric) ✅

**Tracing:** ✅ traceparent header propagated on outbound HTTP. Kafka messages include trace context in headers.

**Alert rules:** ✅
- error_rate > 1% for 5min → alert ✅
- p99 latency > 500ms for 5min → alert ✅
- orders_confirmed_total no increase for 30min (business alert) ✅

**Health endpoints:** ✅ /health/live and /health/ready both present and correct.

**Gaps:** none

**Overall verdict:** ✅ PASS
```
