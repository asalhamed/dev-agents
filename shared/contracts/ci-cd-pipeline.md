# CI/CD Pipeline Specification

**Type:** Standing policy — devops-agent maintains; all agents must understand the promotion model.

---

## Pipeline Stages

Every push triggers the CI pipeline. Which stages run depends on the branch.

### Stage 1: Build & Lint (all branches)

```yaml
steps:
  - name: Checkout
  - name: Setup toolchain (Rust / JVM / Node — based on stack detection)
  - name: Cache dependencies
  - name: Lint
    # Rust: cargo fmt --check && cargo clippy -- -D warnings
    # Scala: sbt scalafmtCheck
    # TS: eslint . --ext .ts && prettier --check .
    # Android: ./gradlew ktlintCheck
  - name: Build
    # Rust: cargo build
    # Scala: sbt compile
    # TS: pnpm build
    # Android: ./gradlew assembleDebug
```

### Stage 2: Test & Coverage (all branches)

```yaml
steps:
  - name: Unit + Integration Tests
    # Rust: cargo test
    # Scala: sbt coverage test coverageReport
    # TS: vitest run --coverage
    # Android: ./gradlew testDebugUnitTest
  - name: Coverage Gate
    # Rust: 80% threshold
    # Scala/TS/Android: 75% threshold
    # FAILS the pipeline if coverage drops below threshold
  - name: Upload coverage report
```

### Stage 3: Security Scan (all branches)

```yaml
steps:
  - name: Dependency vulnerability scan
    # Rust: cargo audit
    # Scala: sbt dependencyCheck
    # TS: npm audit --audit-level=high
    # Android: ./gradlew dependencyCheckAnalyze
  - name: Static analysis (secrets, injection patterns)
    # All stacks: reviewer/scripts/automated_gates.sh
  - name: FAIL on High/Critical vulnerabilities
```

### Stage 4: Integration Tests (feature/* and main only)

```yaml
steps:
  - name: Start test dependencies (DB, Kafka, MQTT broker)
    # Use testcontainers or docker-compose
  - name: Run integration tests
  - name: Run E2E tests (if defined for this feature)
  - name: FAIL on any test failure
```

### Stage 5: Build Artifacts (main and release/* only)

```yaml
steps:
  - name: Build Docker image
    # Tag: git SHA for main, version for release
    # main branch:    ghcr.io/company/service:main-{sha-short}
    # release branch: ghcr.io/company/service:v1.2.0
    # NEVER use :latest
  - name: Push to container registry
  - name: Build Android APK/AAB (if Android project)
    # Tag with version code + git SHA
  - name: Upload artifacts
```

### Stage 6: Deploy to Staging (main only, auto)

```yaml
steps:
  - name: Apply database migrations to staging
  - name: Deploy to staging namespace
    # kubectl apply or kustomize build overlays/staging
  - name: Run smoke tests against staging
  - name: Notify tech-lead of staging deployment
```

### Stage 7: Deploy to Production (release/* only, manual trigger)

```yaml
steps:
  - name: Require manual approval
    # tech-lead or product-owner must approve
  - name: Apply database migrations to production
  - name: Deploy to production namespace
    # Blue-green or rolling update
  - name: Run smoke tests against production
  - name: Verify feature flag is OFF for new features
  - name: Notify team of production deployment
```

---

## Environment Promotion

```
feature branch → CI (build+test+scan)
       │
       ▼ (merge PR to main)
     main → CI (full pipeline) → auto-deploy → STAGING
       │
       ▼ (cut release branch + tag)
  release/vX.Y.Z → CI (build artifacts) → manual approve → PRODUCTION
       │
       ▼ (enable feature flag gradually)
  feature flag: OFF → internal → 5% → 25% → 100%
```

### Environment Configuration

| Environment | Purpose | Deploy trigger | Feature flags | Data |
|-------------|---------|---------------|---------------|------|
| **Local** | Developer machine | Manual | All configurable | Local/mock |
| **CI** | Automated testing | Every push | All ON | Ephemeral test DB |
| **Staging** | Integration testing, demos | Auto on merge to main | Configurable | Prod schema, synthetic data |
| **Production** | Real users | Manual on release tag | Gradual rollout | Real data |

### Image Tagging Strategy

```
# Feature branch builds (CI only, never deployed)
ghcr.io/company/service:ci-{git-sha-short}

# Main branch (deployed to staging)
ghcr.io/company/service:main-{git-sha-short}

# Release (deployed to production)
ghcr.io/company/service:v1.2.0
ghcr.io/company/service:v1.2.0-{git-sha-short}  # for traceability

# NEVER use :latest in any environment
```

---

## Traceability Chain

Every artifact in the system is traceable back to the original feature request:

```
Feature Request
  → F-NNN (feature-kickoff)
    → PRD (product-owner)
    → ADR-NNN (architect)
    → T-NNN tasks (tech-lead)
      → Git commits: "feat(scope): description  Refs: F-NNN, T-NNN"
      → Git branch: feature/F-NNN-slug
      → PR: feature/F-NNN → main
        → CI run ID
        → Docker image: service:main-{sha}
        → Staging deployment
      → Release tag: vX.Y.Z
        → Docker image: service:vX.Y.Z
        → Production deployment
      → Feature flag: feature_slug
        → Rollout history (% over time)
      → Metrics (from measurement-plan)
        → Success: met target / missed target
    → Retrospective
```

**At any point you can answer:**
- "Which feature is this code from?" → commit message has F-NNN
- "Which tasks make up this feature?" → feature-kickoff has task list
- "What's deployed in staging?" → image tag has git SHA → map to branch → map to feature
- "What's the status of feature F-012?" → feature-kickoff status table
- "Why was this decision made?" → ADR-NNN referenced in feature-kickoff
- "Did we meet our goals?" → measurement-plan metrics in retrospective
