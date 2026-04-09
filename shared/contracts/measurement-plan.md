# Measurement Plan

**Producer:** data-analyst
**Consumer(s):** tech-lead, backend-dev, frontend-dev

## Required Fields

- **Feature** — what is being measured
- **Primary metric** — the one number that defines success
- **Secondary metrics** — supporting signals
- **Guardrail metrics** — things that must not regress
- **Analytics events** — table: event name, trigger, properties, producer
- **Instrumentation requirements** — what backend/frontend must implement
- **A/B test design** (if applicable) — hypothesis, variants, success criterion, sample size, duration

## Validation Checklist

- [ ] Primary metric directly tied to business objective
- [ ] Guardrail metrics defined
- [ ] Every analytics event has name, trigger, properties, producer
- [ ] Instrumentation requirements specific enough to implement
- [ ] A/B test (if applicable) has minimum detectable effect defined

## Example (valid)

```markdown
## MEASUREMENT PLAN: Notification Preferences

**Primary metric:** 30-day unsubscribe rate (target: ↓ 30%)
**Secondary metrics:** notification open rate (target: ↑ 15%), preferences page visits/week
**Guardrail metrics:** support ticket volume (must not increase), SecurityAlert delivery rate (must stay > 99%)

**Analytics events:**
| Event | Trigger | Properties | Producer |
|-------|---------|------------|----------|
| `preference_page_viewed` | User opens preferences page | userId, source | frontend-dev |
| `preference_updated` | User saves a preference change | userId, category, channel, newState | backend-dev |
| `pause_activated` | User activates pause | userId, durationDays | backend-dev |
| `pause_expired` | Pause timer expires | userId, durationDays | backend-dev (scheduled job) |

**Instrumentation requirements:**
- backend-dev: emit `preference_updated` on every preference save (Kafka topic: analytics.events)
- backend-dev: emit `pause_activated` and `pause_expired` events
- frontend-dev: emit `preference_page_viewed` on page mount with source parameter

**A/B test:** Not required for this feature — changes are user-controlled.
```
