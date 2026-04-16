# Eval: data-analyst — 001 — Measurement Plan

**Tags:** metrics, instrumentation, analytics events, guardrail metrics
**Skill version tested:** initial

---

## Input (task brief)

```
Define success metrics and instrumentation for the notification preferences feature.
Business goal: reduce unsubscribes by 30%.
```

---

## Expected Behavior

The data-analyst should:
1. Define primary metric tied to business goal (unsubscribe rate, target -30%)
2. Define guardrail metrics (SecurityAlert delivery must not drop)
3. Design analytics events with schema (name, trigger, properties, producer)
4. Split instrumentation ownership between backend-dev and frontend-dev
5. Produce a `measurement-plan` contract

---

## Pass Criteria

- [ ] Primary metric: unsubscribe rate with -30% target
- [ ] Secondary metrics defined (e.g., preference page engagement)
- [ ] Guardrail: SecurityAlert delivery rate must not decrease
- [ ] Analytics events: preference_updated, pause_activated, preference_page_viewed
- [ ] Each event has: name, trigger condition, properties table, producer service
- [ ] Instrumentation split: frontend events vs backend events
- [ ] `measurement-plan` contract produced

---

## Fail Criteria

- No primary metric or unmeasurable metric → ❌ can't validate success
- Missing guardrail metrics → ❌ risk of unintended side effects
- Events lack properties or trigger conditions → ❌ uninstrumentable
- No producer assignment → ❌ nobody knows who implements what
