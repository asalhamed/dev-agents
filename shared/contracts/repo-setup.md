# Service Repository Standard

Every service repository must follow this structure.

## Standard Structure

```
{service-name}/
├── README.md                          ← service overview, how to run locally
├── CONTRACT_DEPS.md                   ← which contracts this service produces/consumes
├── Dockerfile
├── docker-compose.yml                 ← local dev with dependencies (DB, Kafka, etc.)
├── .github/
│   └── workflows/
│       ├── ci.yml                     ← build, test, lint, scan
│       ├── contract-test.yml          ← verify against platform-contracts
│       └── deploy.yml                 ← staging/production deployment
├── src/
│   ├── domain/                        ← pure domain logic (FP + DDD)
│   ├── application/                   ← use cases, orchestration
│   ├── infrastructure/                ← DB, Kafka, HTTP, external services
│   └── interface/                     ← HTTP handlers, event consumers
├── tests/
│   ├── unit/                          ← domain logic tests
│   ├── integration/                   ← with testcontainers
│   └── contract/                      ← producer/consumer contract tests
├── k8s/
│   ├── base/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── configmap.yaml
│   └── overlays/
│       ├── staging/
│       └── prod/
└── migrations/                        ← database migrations
```

## CONTRACT_DEPS.md

Every service repo must have this file at the root:

```markdown
# Contract Dependencies

## This service produces:
- `api/order-service.yaml` — REST API (OpenAPI 3.1)
- `events/order-events.avsc` — Domain events (Avro, published to Kafka topic `order.events`)

## This service consumes:
- `events/device-telemetry.avsc` — from device-fleet-service (Kafka topic `device.telemetry`)

## Contract test commands:
- Producer tests: `cargo test --features contract-producer`
- Consumer tests: `cargo test --features contract-consumer`

## platform-contracts version: v2.3.0
```

## Contract Dependency Rules

1. **Pin contract versions.** Each service pins to a specific version of platform-contracts
   (git tag, package version, or submodule commit). Don't use `main` branch — it can change.

2. **Contract CI checks.** Every service's CI must:
   - Pull the pinned platform-contracts version
   - Run producer contract tests (do I produce what my spec says?)
   - Run consumer contract tests (can I handle what my dependencies say they produce?)
   - FAIL the build if any contract test fails

3. **Updating contract dependencies.** When platform-contracts releases a new version:
   - Each consuming service updates its pinned version
   - Runs contract tests against the new version
   - If tests fail, the service must adapt before the old version is deprecated

## New Service Onboarding Checklist

When creating a brand-new service, complete these steps in order:

1. **Define the bounded context** — architect approves the service boundary (ADR required)
2. **Create the repo** — from organization template; name follows `{domain}-service` convention
3. **Add contracts to `platform-contracts`** — open a PR with:
   - `api/{service-name}.yaml` (OpenAPI 3.1)
   - `events/{service-name}-events.avsc` (Avro, if the service publishes events)
   - Update `service-dependency-map.md`
4. **Create `CONTRACT_DEPS.md`** in the new service repo — lists produced and consumed contracts, pinned platform-contracts version
5. **Bootstrap CI workflows** — copy from `infrastructure/ci-templates/`, fill in service name and stack
6. **Add to `infrastructure/docker-compose.dev.yml`** — so the service appears in full-stack local dev
7. **Add entry to the ownership model table** in the architecture documentation
8. **Write `README.md`** — must include: purpose, how to run locally, links to contracts
9. **Pass initial contract tests** — CI must be green before any feature work begins
