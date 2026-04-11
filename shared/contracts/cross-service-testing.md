# Cross-Service Testing Strategy

---

## Testing Pyramid (Multi-Repo)

```
                    ┌───────────┐
                    │  E2E /    │  ← few, slow, run in staging
                    │  Journey  │     test full user flows
                    ├───────────┤
                    │ Contract  │  ← medium, fast, run in each repo's CI
                    │  Tests    │     verify producer/consumer compatibility
                    ├───────────┤
                    │Integration│  ← per-service, with testcontainers
                    │  Tests    │     verify service + its own DB/queue
                    ├───────────┤
                    │   Unit    │  ← many, fast, pure domain logic
                    │   Tests   │     no external dependencies
                    └───────────┘
```

## Contract Tests — The Key to Multi-Repo

Contract tests verify that two services agree on their shared interface
WITHOUT deploying both services together.

### Producer-Side Contract Tests

Run in the **producing** service's CI. Verify the service produces what
the contract says it should.

```
# In order-service CI:
# Verify order-service's API matches api/order-service.yaml

1. Load api/order-service.yaml from platform-contracts (git submodule or package)
2. Start order-service locally (testcontainers)
3. For each endpoint in the spec:
   - Send a valid request → verify response matches schema
   - Send an invalid request → verify error format matches spec
4. For each event in events/order-events.avsc:
   - Trigger the event → verify published message matches schema
```

### Consumer-Side Contract Tests

Run in the **consuming** service's CI. Verify the consumer handles
what the producer says it will send.

```
# In notification-service CI:
# Verify notification-service handles order-events correctly

1. Load events/order-events.avsc from platform-contracts
2. Generate sample messages from the schema
3. Feed sample messages to notification-service's event handler
4. Verify: events are processed without errors, expected side effects occur
```

### Unknown Variant Safety (Required)

Consumers MUST handle unknown event types without panicking.
Exhaustive match in Rust/Scala will fail to compile or panic at runtime when a new event type is
added to the schema unless a catch-all arm is present.

```rust
// REQUIRED in every event handler
#[test]
fn handles_unknown_event_variants_gracefully() {
    let unknown = serde_json::json!({"type": "UnknownFutureEvent", "version": 99, "data": {}});
    let result = handle_order_event_raw(unknown);
    assert!(result.is_ok(), "Consumer panicked on unknown event variant — add a catch-all arm");
}
```

### Tooling

| Language | Contract testing tool |
|----------|---------------------|
| Rust | Custom (load OpenAPI YAML + reqwest-based tests) |
| Scala | Pact JVM (requires a running Pact Broker — add `pact-broker` to shared infra), sttp-openapi-verify |
| TypeScript | Pact JS, openapi-backend |
| General | Schemathesis (OpenAPI fuzz testing), Spectral (OpenAPI linting) |

## Cross-Service E2E Tests

Run in a **separate CI pipeline** (not per-service) against staging environment.

```yaml
# In infrastructure repo: .github/workflows/e2e.yml
name: E2E Tests
on:
  workflow_dispatch:
  schedule:
    - cron: '0 */6 * * *'  # every 6 hours

jobs:
  e2e:
    runs-on: ubuntu-latest
    steps:
      - name: Run journey tests against staging
        run: |
          # Journey: device comes online → sends telemetry → triggers alert → push notification
          ./e2e-tests/device-alert-journey.sh staging.api.company.com

          # Journey: user opens app → views live feed → acknowledges alert
          ./e2e-tests/live-video-journey.sh staging.api.company.com
```

## QA Report Contract Extension

Include contract test results in the `qa-report.md`:

```markdown
### Contract Test Results
| Type | Contract | Result |
|------|----------|--------|
| Producer | api/order-service.yaml | ✅ All endpoints match spec |
| Consumer | events/device-telemetry.avsc | ✅ All sample events handled |
| Consumer (unknown variants) | events/order-events.avsc | ✅ Unknown variants handled gracefully |
```

---

## Validation (qa-agent checks per service)

- [ ] Producer contract tests exist for every contract this service produces
- [ ] Consumer contract tests exist for every contract this service consumes
- [ ] Unknown variant handling tested (consumer ignores unknown event types gracefully)
- [ ] Contract test results included in qa-report
- [ ] E2E journey tests defined for features crossing 2+ services

## Example (valid — contract test report section)

```markdown
### Contract Test Results

**Platform-contracts version:** v2.4.0

| Type | Contract | Result | Details |
|------|----------|--------|---------|
| Producer | api/video-service.yaml | ✅ | 15/15 endpoints match spec |
| Producer | events/video-events.avsc | ✅ | 3/3 event types match schema |
| Consumer | events/device-telemetry.avsc | ✅ | All 8 sample messages handled |
| Consumer | mqtt/device-fleet.yaml | ✅ | 12/12 topic messages parsed |
| Unknown variant | events/device-telemetry.avsc | ✅ | Unknown fields ignored gracefully |
```
