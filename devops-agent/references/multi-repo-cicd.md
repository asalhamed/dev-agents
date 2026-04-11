# Multi-Repo CI/CD Patterns

## Pipeline Per Service

Each service has its own pipeline. It runs independently.

> **Note:** The CI template below uses Rust (`cargo`). Adapt build/test/contract/coverage/scan
> commands per language:
>
> | Language | Build | Test | Contract tests | Coverage | Security scan |
> |----------|-------|------|----------------|----------|---------------|
> | Rust | `cargo build` | `cargo test` | `cargo test --features contract-tests` | `cargo tarpaulin` | `cargo audit` |
> | Scala | `sbt compile` | `sbt test` | `sbt contractTests` | `sbt coverageReport` | `sbt dependencyCheck` |
> | Kotlin/Android | `./gradlew assembleDebug` | `./gradlew test` | `./gradlew contractTest` | `./gradlew jacocoTestReport` | `./gradlew dependencyCheck` |
> | TypeScript | `npm run build` | `npm test` | `npm run contract-test` | `npm run coverage` | `npm audit` |
> | Python | `python -m build` | `pytest` | `pytest tests/contract/` | `pytest --cov` | `pip-audit` |

```yaml
# Template for service CI (.github/workflows/ci.yml)
name: CI — {service-name}

on:
  push:
    branches: [main, 'feature/**']
  pull_request:
    branches: [main]

env:
  CONTRACTS_REPO: org/platform-contracts
  SERVICE_NAME: order-service
  REGISTRY: ghcr.io/org

jobs:
  build-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Get contracts version
        id: contracts
        run: |
          VERSION=$(grep 'platform-contracts version' CONTRACT_DEPS.md | grep -oP 'v[\d.]+')
          echo "version=$VERSION" >> $GITHUB_OUTPUT

      - name: Checkout platform-contracts
        uses: actions/checkout@v4
        with:
          repository: ${{ env.CONTRACTS_REPO }}
          ref: ${{ steps.contracts.outputs.version }}
          path: platform-contracts

      - name: Build
        run: cargo build

      - name: Unit + Integration Tests
        run: cargo test

      - name: Contract Tests
        run: cargo test --features contract-tests
        env:
          CONTRACTS_PATH: ${{ github.workspace }}/platform-contracts

      - name: Security Scan
        run: cargo audit

      - name: Coverage Gate
        run: cargo tarpaulin --fail-under 80

  deploy-staging:
    needs: build-test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - name: Build + push image
        run: |
          SHA=$(git rev-parse --short HEAD)
          docker build -t $REGISTRY/$SERVICE_NAME:main-$SHA .
          docker push $REGISTRY/$SERVICE_NAME:main-$SHA

      - name: Deploy to staging
        run: |
          kubectl set image deployment/$SERVICE_NAME \
            $SERVICE_NAME=$REGISTRY/$SERVICE_NAME:main-$SHA \
            -n staging
```

## Contract CI (platform-contracts repo)

```yaml
# platform-contracts/.github/workflows/validate.yml
name: Validate Contracts

on:
  push:
    branches: [main, 'feature/**']
  pull_request:

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Lint OpenAPI specs
        run: npx @stoplight/spectral-cli lint api/*.yaml

      - name: Validate Avro schemas
        run: |
          for schema in events/*.avsc; do
            python -c "import json; json.load(open('$schema'))"
          done

      - name: Check backward compatibility
        run: |
          PREV_TAG=$(git describe --tags --abbrev=0 HEAD^ 2>/dev/null || echo "")
          if [ -n "$PREV_TAG" ]; then
            ./scripts/check-compatibility.sh $PREV_TAG HEAD
          fi

      - name: Generate SDK clients
        run: ./scripts/generate-sdks.sh
```

## Cross-Service E2E (infrastructure repo)

```yaml
# infrastructure/.github/workflows/e2e.yml
name: Cross-Service E2E

on:
  workflow_dispatch:
  schedule:
    - cron: '0 */4 * * *'  # every 4 hours

jobs:
  e2e:
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v4

      - name: Journey — Device to Alert
        run: ./e2e-tests/device-alert-journey.sh $STAGING_URL

      - name: Journey — Live Video Feed
        run: ./e2e-tests/live-video-journey.sh $STAGING_URL

      - name: Journey — User Notification Preferences
        run: ./e2e-tests/notification-prefs-journey.sh $STAGING_URL

      - name: Notify on failure
        if: failure()
        run: ./scripts/notify-slack.sh "E2E tests failed on staging"
```

## Deployment Orchestration for Multi-Service Features

```yaml
# In the feature's release-plan contract:
deployment_order:
  - repo: platform-contracts
    action: merge + tag v2.4.0
    verify: "All service CIs pass against new version"

  - repo: video-service
    action: deploy to staging
    verify: "video-service health check passes, stream test passes"

  - repo: device-fleet-service
    action: deploy to staging
    verify: "device-fleet health check passes, MQTT connected"

  - repo: monitoring-dashboard
    action: deploy to staging
    verify: "dashboard loads, video player renders"

  - action: "Run cross-service E2E tests"
    verify: "All journey tests pass"

  - action: "Product-owner demo on staging"
    verify: "Sign-off received"

  - action: "Tag releases in all repos"
  - action: "Deploy to production in same order"
  - action: "Enable feature flag gradually"

  # Mobile is a PARALLEL TRACK — Play Store review is unpredictable (hours to days).
  # It does not block and is not blocked by backend go/no-go.
  - repo: monitoring-android
    action: upload to Play Store internal track (parallel — async gate)
    verify: "install + smoke test passes"
    note: "Do not hold backend production deploy waiting for Play Store review"
```

## Rollback Strategy for Multi-Service Features

Rolling back after a partial multi-service deployment is harder because services may already be
consuming the new contract format.

### Rollback decision tree

```
Producer deployed. Consumer deployment FAILED.
  ├── Is the producer change backward-compatible?
  │     YES → Roll back consumer only. Producer stays.
  │           Old consumers still work against the new producer.
  │
  └── NO (breaking change) → Roll back consumer AND producer.
        Producer must redeploy with dual-format support before consumer retries.
        Use the expand-contract pattern (see below).
```

### Expand-contract (strangler fig) for breaking changes

Never deploy a breaking contract change atomically. Instead, use four steps:

| Step | Producer state | Consumer state | Rollback cost |
|------|----------------|----------------|---------------|
| 1 — baseline | Produces v1 | Consumes v1 | Trivial |
| 2 — expand | Produces v1 **+ v2** | Consumes v1 | Revert producer only |
| 3 — migrate | Produces v1 + v2 | Consumes **v2** | Revert consumer only |
| 4 — contract | Produces **v2** only | Consumes v2 | Revert producer only |

At each step, only one service changes. Any single step can be rolled back independently.
Never skip to a state where both producer and consumer must be reverted together.
