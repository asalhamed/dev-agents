# Business Requirements

**Producer:** business-analyst
**Consumer(s):** architect, ux-researcher

## Required Fields

- **Source PRD** — reference to the PRD this was derived from
- **User stories** — As a [role], I want [goal], so that [benefit]
- **Business rules** — explicit if/then statements, numbered (BR-001, BR-002...)
- **Domain terms** — new terms identified, added to shared/glossary.md
- **Regulatory requirements** — compliance constraints or "none applicable"
- **Edge cases** — identified boundary conditions

## Validation Checklist

- [ ] Every user story follows INVEST criteria (Independent, Negotiable, Valuable, Estimable, Small, Testable)
- [ ] Business rules are stated explicitly (not implied)
- [ ] Domain terms are defined and added to shared/glossary.md
- [ ] Regulatory requirements addressed (even if "none applicable")
- [ ] Edge cases and error paths covered

## Example (valid)

```markdown
## BUSINESS REQUIREMENTS

**Source PRD:** Notification Preferences PRD

**User stories:**
1. As a registered user, I want to disable email notifications for marketing,
   so that I stop receiving unwanted emails without fully unsubscribing.
2. As a registered user, I want to pause all notifications for a period,
   so that I can take a break without losing my preferences.
3. As a security-conscious user, I want to always receive security alerts on at least one channel,
   so that I'm never locked out of my account without warning.

**Business rules:**
- BR-001: SecurityAlert preference must have at least one enabled channel at all times
- BR-002: Disabling a channel for a category takes effect within 24 hours (GDPR)
- BR-003: Pause duration options: 1 day, 7 days, 30 days
- BR-004: When pause expires, preferences revert exactly to pre-pause state

**Domain terms identified:**
- NotificationCategory: a grouping of notifications (SecurityAlert, MarketingUpdates, OrderStatus)
- NotificationChannel: a delivery mechanism (Email, Push, SMS)
- NotificationPreference: the enabled/disabled state of a channel for a category for a user

(Added to shared/glossary.md)

**Regulatory requirements:** GDPR Article 7 — opt-out must be honored within 24 hours

**Edge cases:**
- User disables all channels for SecurityAlert → BR-001 prevents; show validation error
- User's pause expires while inactive → preferences silently restored
- User has no phone number on file → SMS option not shown
```
