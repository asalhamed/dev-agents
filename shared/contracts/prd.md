# Product Requirements Document (PRD)

**Producer:** product-owner
**Consumer(s):** business-analyst, ux-researcher

## Required Fields

- **Feature name** — short, memorable
- **Business objective** — problem, audience, why now
- **Success metrics** — measurable outcomes (primary, secondary, guardrail)
- **Scope (MoSCoW)**
  - Must-have: [list]
  - Should-have: [list]
  - Could-have: [list]
  - Won't-have (this release): [list]
- **Acceptance criteria** — Given/When/Then format, one per testable behavior
- **Dependencies** — what must exist or be done first
- **Risks** — what could go wrong
- **Constraints** — hard limits (deadline, budget, compliance, existing contracts)

## Validation Checklist

- [ ] Business objective is clear: problem + audience + why now
- [ ] Every Must-have has at least one acceptance criterion
- [ ] Every acceptance criterion is testable (not "should feel intuitive")
- [ ] Won't-have list is explicit (prevents scope creep)
- [ ] Success metrics are measurable
- [ ] Dependencies identified

## Example (valid)

```markdown
## PRD: Notification Preferences

**Business objective:** Users are unsubscribing from the platform because they receive
irrelevant notifications. We need to give users control over what they receive and how,
reducing unsubscribes by 30% within 90 days of launch.

**Success metrics:**
- Primary: unsubscribe rate ↓ 30% within 90 days
- Secondary: notification open rate ↑ 15%
- Guardrail: no increase in support tickets about missed notifications

**Scope:**
- Must-have: per-channel toggle (email/push/SMS) per notification category
- Must-have: SecurityAlert cannot be fully disabled (at least one channel required)
- Should-have: "pause all" for N days
- Could-have: per-notification-type preferences
- Won't-have (this release): notification scheduling, digest mode

**Acceptance criteria:**
- Given a user on the preferences page, when they disable email for MarketingUpdates,
  then they receive no further marketing emails until they re-enable
- Given a user trying to disable the last channel for SecurityAlert,
  when they submit the form, then they see an error and the preference is not saved

**Dependencies:** user authentication, notification service, email/push/SMS providers
**Risks:** users may still receive transactional notifications they consider spam
**Constraints:** GDPR opt-out must be honored within 24 hours; existing API cannot change shape
```
