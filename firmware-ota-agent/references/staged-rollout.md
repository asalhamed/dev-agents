# Staged Rollout — Firmware OTA

**Scope:** Cohort definitions, health gates, advancement policy, auto-halt criteria, and
rollback drills for firmware rollouts.

## Cohort design (TODO — fill in Phase 3)
Cohort = a subset of the fleet that receives a new firmware together. Typical axes:
- **Hardware revision** — silicon steppings, camera sensor variants
- **Current firmware version** — avoid mixing two large deltas at once
- **Region** — regulatory or network-characteristic slicing
- **Site / customer tier** — dev sites first, reference customers second, long tail last
- **Device age** — flag devices near EOL for separate handling

Cohorts are explicit, not dynamic — changing them mid-rollout requires a new signed
metadata revision.

## Stages (TODO — fill in Phase 3)
Baseline shape (tune per product):
1. **Internal** — dev / QA sites only (~0.01 % of fleet)
2. **Canary** — 0.1 – 1 %; held for a fixed observation window
3. **Early** — 5 – 10 %
4. **Broad** — 50 %
5. **Full** — 100 %

Advancement is health-gated AND time-gated. Never advance faster than the shortest-valid
observation window for the stage.

## Health gates (TODO — fill in Phase 3)
Define the SLI/SLO with `observability-agent`. Typical KPIs:
- Crash rate (bundle install, post-boot, runtime)
- Reboot loops
- Memory / CPU baseline drift
- Network reconnect churn
- Domain-specific metrics — e.g., camera stream failure rate, sensor anomaly rate

Each gate has a concrete threshold (e.g., "post-install crash rate ≤ 1.2× prior
baseline for the cohort, measured over the observation window").

## Auto-halt criteria (TODO — fill in Phase 3)
Auto-halt is triggered by explicit numeric thresholds, not vibes:
- "3× baseline crash rate sustained for 15 min"
- "5 % of cohort failed to report post-install telemetry within 1 hour"
- "Any device-class reports secure-boot failure"

Auto-halt pauses advancement and alerts the on-call engineer. Recovery is manual — a
human decides whether to roll back, or to continue after diagnosis.

## Rollback drills (TODO — fill in Phase 3)
Run on every supported device class, on every major release:
- Force a rollback via anti-rollback counter
- Force a rollback via signed downgrade manifest
- Simulate a power loss mid-install → verify bootloader lands on the valid slot
- Verify the telemetry event is emitted in every rollback path

## Offline / air-gapped fleets (TODO — fill in Phase 3)
- "Stages" are still meaningful: waves of operators visiting sites
- Auto-halt is replaced by a coordinated pause — the signing service stops issuing new
  bundles until the current wave's health is reviewed

## See also
- `tuf-uptane.md`
- `key-management.md`
- `../../observability-agent/references/realtime-slo.md` *(Phase 3)*
- `../../shared/contracts/runbook-template.md`
