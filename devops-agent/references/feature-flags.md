# Feature Flag Patterns

## Implementation Options

| Option | Best for | Complexity |
|--------|----------|------------|
| Environment variable | Simple on/off per deployment, no runtime change needed | Low |
| ConfigMap / config file | Per-environment control, applied on restart | Low |
| Feature flag service (LaunchDarkly, Unleash, Flagsmith) | Gradual rollout, user/tenant targeting, A/B testing | Medium |
| Custom DB-backed flags | Full control, no external dependency, auditable | High |

For most features: start with ConfigMap. Graduate to a flag service when you need user-level targeting or % rollout without redeployment.

## Standard Rollout Sequence

```
1. Deploy all code with flag OFF          ← zero user impact, safe to deploy anytime
2. Enable for internal users              ← team dogfoods; catches obvious breakage
3. Monitor 24h                            ← verify instrumentation, check error rates
4. Enable for beta tenants (5%)           ← real user feedback at small scale
5. Monitor 24-48h                         ← validate SLOs, watch error dashboards
6. Increase: 25% → 50% → 100%            ← gradual confidence building
7. Remove flag (1-2 weeks post-GA)        ← clean up; flag = tech debt after 100% stable
```

Never skip from internal → 100%. Always have a gradual phase.

## Flag Configuration Example

```yaml
# ConfigMap or feature flag service entry
feature_flags:
  feature_video_live_alerts:
    enabled: false           # master switch
    rollout_percentage: 0    # 0-100; only used if enabled=true
    allowed_users: []        # specific user IDs for internal testing
    allowed_tenants: []      # specific customer tenants for beta
    description: "Live video feed with motion-based alerts"
    owner: "tech-lead"
    created: "2026-04-10"
    planned_removal: "2026-04-24"  # always set this
```

## Naming Convention

```
feature_<domain>_<capability>

Examples:
  feature_video_live_alerts
  feature_iot_predictive_maintenance
  feature_dashboard_fleet_overview
  feature_android_offline_mode
```

Use snake_case. Always prefix with `feature_`. Domain = the primary bounded context.

## Rollback

Feature flags provide instant rollback without a deployment:
- Set `enabled: false` (or `rollout_percentage: 0`)
- Propagation: seconds (config reload) to ~1 minute (flag service)
- No code revert needed
- No deployment pipeline needed
- Data written while flag was ON stays — account for this if data schema changed

If data migration was part of the feature, rollback is more complex. Document the data rollback procedure separately in the release-plan before starting rollout.

## Removal Process

Flags are tech debt. Remove them:
1. Feature at 100% for 1-2 weeks with no issues
2. Create a task: "Remove feature flag `feature_video_live_alerts`"
3. Remove flag check from code (make the flagged behavior permanent)
4. Remove flag config from all environments
5. Deploy and verify

Never let flags stay indefinitely. Set `planned_removal` date when creating the flag and treat it as a hard deadline.

## Anti-Patterns

| Anti-pattern | Problem | Fix |
|---|---|---|
| Long-lived flags | Accumulating tech debt, confusing code paths | Set removal date on creation; enforce it |
| Flag in domain layer | Business logic should not know about deployment state | Flags belong in interface/application layer only |
| Nested flags (flag A depends on flag B) | Exponential complexity, impossible to test | One feature = one flag; no dependencies |
| Untested flag-off path | App breaks when flag is disabled | Always test with flag OFF before shipping |
| No monitoring during rollout | Silent failures at scale | Set up dashboard alerts before enabling flag |
