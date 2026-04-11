# Branching Strategy & Release Policy

**Type:** Standing policy — all agents that produce or review code must follow this.

---

## Branch Model: Trunk-Based Development with Feature Branches

```
main (trunk)                          ← always deployable, protected
  │
  ├── feature/F-012-live-video-alerts ← one branch per feature
  │     ├── commits reference T-NNN
  │     └── PR to main when feature complete
  │
  ├── feature/F-013-predictive-maint  ← another feature in parallel
  │
  ├── hotfix/H-001-video-crash        ← urgent fix, branches from main
  │     └── PR to main, cherry-pick to release if needed
  │
  └── release/v1.2.0                  ← cut from main when ready to ship
        └── only hotfixes allowed after cut
```

## Branch Naming Convention

| Type | Pattern | Example |
|------|---------|---------|
| Feature | `feature/F-{NNN}-{short-slug}` | `feature/F-012-live-video-alerts` |
| Hotfix | `hotfix/H-{NNN}-{short-slug}` | `hotfix/H-001-video-crash` |
| Release | `release/v{major}.{minor}.{patch}` | `release/v1.2.0` |

- `F-NNN` matches the Feature ID from `shared/contracts/feature-kickoff.md`
- `short-slug` is 2-4 words, lowercase, hyphenated
- All feature work happens on feature branches — **never commit directly to main**

## Commit Message Convention

```
{type}({scope}): {description}

Refs: F-{NNN}, T-{NNN}
```

| Type | When |
|------|------|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `refactor` | Code restructuring, no behavior change |
| `test` | Adding or updating tests |
| `docs` | Documentation changes |
| `chore` | Build, CI, config changes |
| `perf` | Performance improvement |
| `security` | Security fix or hardening |

**Examples:**
```
feat(order): add confirm() method to Order aggregate

Refs: F-012, T-002
Implements OrderConfirmed event per ADR-007.

fix(video): handle RTSP connection timeout gracefully

Refs: F-012, T-009
Returns Result instead of panicking on timeout.

test(order): add property-based test for Money addition

Refs: F-012, T-008
Uses proptest to verify associativity.
```

**Rules:**
- Every commit references at least one T-NNN task ID
- Feature branch commits also reference the F-NNN feature ID
- Hotfix commits reference H-NNN
- Scope matches the bounded context or component name

## Pull Request Convention

```markdown
## PR: feature/F-012-live-video-alerts → main

### Feature
**Feature ID:** F-012
**Title:** Live Video Feed with Motion-Based Alerts
**ADR:** ADR-015

### Tasks Completed
- [x] T-001 — backend-dev — Order aggregate (domain layer)
- [x] T-002 — video-streaming — RTSP→WebRTC bridge
- [x] T-003 — android-dev — Live feed viewer component
- [x] T-004 — edge-agent — Motion detection at edge
- [x] T-005 — backend-dev — Alert API endpoint
- [x] T-006 — qa-agent — Tests + acceptance tests
- [x] T-007 — devops-agent — K8s manifests + feature flag

### Contracts Produced
- [x] implementation-summary for each dev task
- [x] qa-report with acceptance-test
- [x] security-scan (clean)
- [x] perf-report (latency within SLO)
- [x] observability-audit (instrumented)

### Feature Flag
**Flag name:** `feature_live_video_alerts`
**Initial state:** OFF (enabled post-merge via rollout plan)

### How to Test
1. Enable feature flag for your user
2. [step-by-step test instructions]

### Rollback
Disable feature flag `feature_live_video_alerts` — no deployment needed.
```

## Branch Lifecycle

```
1. tech-lead creates feature branch:
   git checkout -b feature/F-012-live-video-alerts main

2. Dev agents commit to the branch:
   Each task (T-NNN) = one or more commits on the feature branch
   Commits reference both F-NNN and T-NNN

3. CI runs on every push to feature branch:
   - Build + lint + test + security scan
   - Blocks merge if any gate fails

4. When all tasks complete:
   - qa-agent runs acceptance tests
   - tech-lead opens PR to main
   - reviewer reviews the PR (code quality + pipeline DoD)
   - product-owner validates acceptance-test results

5. PR merges to main:
   - CI runs full pipeline on main
   - Auto-deploys to staging environment
   - Feature is behind feature flag (OFF by default)

6. Release cut:
   - When ready, cut release/vX.Y.Z from main
   - Tag with version
   - Deploy to production (feature still behind flag)

7. Gradual rollout:
   - Enable feature flag progressively
   - Monitor rollback triggers
```

## Branch Protection Rules

```yaml
# main branch protection
main:
  required_reviews: 1           # reviewer agent approval
  required_status_checks:
    - ci/build
    - ci/test
    - ci/lint
    - ci/security-scan
  require_up_to_date: true      # must be current with main
  no_direct_push: true          # all changes via PR
  require_linear_history: true  # squash or rebase, no merge commits

# release/* branch protection
release/*:
  required_reviews: 1
  allowed_merge_sources:
    - hotfix/*                  # only hotfixes on release branches
  no_direct_push: true
```

---

## Validation (reviewer checks on every PR)

- [ ] Branch name follows convention: `feature/F-NNN-slug`, `hotfix/H-NNN-slug`, or `release/vX.Y.Z`
- [ ] All commits reference F-NNN or H-NNN
- [ ] PR description includes Feature ID, Task IDs, and ADR reference
- [ ] Feature flag name specified (if applicable)
- [ ] No commits directly on main

## Example (valid PR description)

```markdown
## PR: feature/F-012-live-video-alerts → main

### Feature
**Feature ID:** F-012
**Title:** Live Video Feed with Motion-Based Alerts
**ADR:** ADR-015

### Tasks Completed
- [x] T-001 — video-streaming — RTSP→WebRTC bridge
- [x] T-002 — edge-agent — Motion detection
- [x] T-003 — backend-dev — Alert API + push
- [x] T-004 — android-dev — Live feed viewer
- [x] T-005 — devops-agent — K8s + feature flag
- [x] T-006 — qa-agent — Tests + acceptance

### Feature Flag
**Flag name:** `feature_live_video_alerts`
**Initial state:** OFF

### Rollback
Disable feature flag — instant, no deployment needed.
```
