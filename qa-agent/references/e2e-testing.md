# End-to-End Testing Guide

## When to Write E2E Tests

Write E2E tests when:
- The feature crosses 2+ agent boundaries (e.g., backend + mobile)
- PRD acceptance criteria describe a user journey (not just a function)
- Real-time components are involved (video streaming, push notifications, MQTT events)
- Integration between services was built by different agents

Do not write E2E tests for:
- Pure domain logic (use unit tests)
- Single-service API behavior (use integration tests)

## E2E Test Structure

```
Given: [initial state — user logged in, device online, camera streaming]
When:  [user action — opens live feed, triggers motion event]
Then:  [expected outcome — video displays within 3s SLO, alert appears]
And:   [secondary outcomes — alert logged in DB, push notification delivered]
```

Every E2E test maps to one or more PRD acceptance criteria. Include the AC ID in the test name/description.

## Integration Point Testing

For each pair of components that communicate, test the boundary explicitly:

| Producer | Consumer | What to test |
|----------|----------|-------------|
| iot-dev (MQTT) | backend-dev (ingestion) | Message published → event processed → stored correctly |
| video-streaming (WebRTC/RTSP) | android-dev (player) | Stream established → video renders → latency within SLO |
| edge-agent (motion alert) | backend-dev (alert API) | Motion detected → alert API called → push notification sent |
| backend-dev (REST API) | frontend-dev (dashboard) | API response → UI renders correctly → state updates |
| ml-engineer (model output) | edge-agent (consumer) | Inference result → alert classification → correct routing |
| data-engineer (pipeline) | analytics-engineer (dashboard) | Event ingested → transformed → queryable in BI layer |

## E2E vs Integration vs Unit

| Level | Scope | Speed | Use for |
|-------|-------|-------|---------|
| Unit | Single function/class | Fast (ms) | Domain logic, pure functions, invariants |
| Integration | Two components (one boundary) | Medium (seconds) | API + DB, service + queue, HTTP client |
| E2E | Full user journey (all components) | Slow (minutes) | Acceptance criteria, user flows, release gates |

Run all levels. Don't substitute E2E for unit tests or vice versa.

## Tools by Stack

| Stack | Unit/Integration | E2E |
|-------|-----------------|-----|
| Rust | `cargo test`, `tokio::test` | REST: reqwest + tokio; custom harness |
| Scala 3 | ScalaTest, MUnit | sttp + Docker compose test env |
| TypeScript | Vitest, Jest | Playwright (web), Supertest (API) |
| Android (Kotlin) | JUnit, Mockito | Espresso, UI Automator |
| IoT / MQTT | Custom test client | MQTT test broker + telemetry validators |
| Video / WebRTC | Unit probes | WebRTC stats API, custom latency probes |

## Acceptance Test Checklist

For each PRD acceptance criterion:
- [ ] Criterion has a corresponding test (automated or documented manual test)
- [ ] Test covers the full Given/When/Then (not just the "When")
- [ ] Test runs against a realistic environment (staging, not mocked-out stubs)
- [ ] Result is deterministic (not flaky)
- [ ] Evidence captured (screenshot, log, metric, or assertion output)

## Cross-Component Test Environment

For multi-component E2E tests, use the staging environment:
- All services deployed (same versions as the release candidate)
- Real infrastructure (real MQTT broker, real video pipeline, real DB)
- Test data seeded and isolated (don't share test data across runs)
- Tear down test data after each test run

Do not run E2E tests against production.
