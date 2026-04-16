# Eval: tech-lead — 001 — Task Decomposition from ADR

**Tags:** task breakdown, pipeline ordering, agent assignment, contract compliance
**Skill version tested:** initial

---

## Input

Tech-lead receives this `architect-output`:

~~~
## ARCHITECT OUTPUT

### ADR Reference
**ADR:** ADR-012: Customer Notification Preferences
**Status:** Accepted

### Problem Statement
Customers currently receive all notifications by default with no way to opt out of specific
channels. We need a preferences system that lets customers choose which notification types
they receive (email, SMS, push) per event category (order updates, promotions, security alerts).

### Bounded Context
**Context:** notification
**Affected contexts:** customer-profile (provides customer identity), order-management (publishes events that trigger notifications)

### Domain Model Changes
**New aggregates:** NotificationPreference (per customer, per event category)
**New value objects:** Channel (enum: Email, SMS, Push), EventCategory (enum: OrderUpdate, Promotion, SecurityAlert)
**New domain events:** PreferenceUpdated { customerId, category, channels, updatedAt }
**Modified aggregates:** none
**Ubiquitous language additions:**
 - Channel: a delivery mechanism for notifications (email, SMS, push)
 - EventCategory: a class of domain events that can trigger notifications

### Contracts

#### API Contracts
GET /customers/{id}/notification-preferences — Response: { preferences: List[Preference] } — Errors: CustomerNotFound
PUT /customers/{id}/notification-preferences/{category} — Request: { channels: List[Channel] } — Response: { preference: Preference } — Errors: CustomerNotFound | InvalidChannel

#### Domain Event Schemas
PreferenceUpdated {
  customerId: CustomerId
  category: EventCategory
  channels: List[Channel]
  updatedAt: Timestamp
}

#### Schema Changes
notification_preferences table — new table — reversible: yes (drop table)

### Constraints & Decisions
**Must:** default all channels to enabled for new customers
**Must:** validate that at least one channel remains enabled for SecurityAlert category
**Must not:** query customer-profile DB directly — use existing CustomerIdentity ACL
**Must not:** modify order-management service

### Handoff Summary for Tech Lead
- Define NotificationPreference aggregate with invariant enforcement in domain layer
- Define Channel and EventCategory value objects with validation
- Define PreferenceUpdated domain event
- Implement repository interface in domain layer
- Implement use cases: GetPreferences, UpdatePreference in application layer
- Implement Postgres repository in infrastructure layer
- Implement REST endpoints (GET + PUT) in interface layer
- Implement Kafka publisher for PreferenceUpdated
- Write tests at all layers
- Create K8s ConfigMap for notification-service config

### Open Questions
- Should we support per-item granularity within OrderUpdate? (deferred — start with category-level)
~~~

---

## Expected Behavior

The tech-lead should:
1. Validate the architect-output against `shared/contracts/architect-output.md`
2. Decompose into 6-10 individual tasks, each assigned to exactly one agent
3. Order tasks by layer (domain → application → infrastructure → interface → QA)
4. Produce task briefs using `shared/contracts/task-brief.md` format
5. Show task breakdown to user before spawning (>3 tasks)
6. Identify dependencies between tasks (domain must complete before application)
7. Not bundle "implement + test" into one task — QA is separate

---

## Pass Criteria

- [ ] Architect-output validated (all required fields present, events in past tense)
- [ ] Tasks decomposed into single-concern units (no "implement and test" bundles)
- [ ] Each task assigned to exactly one agent
- [ ] Each task targets exactly one layer
- [ ] Domain layer tasks come before application layer tasks
- [ ] Application layer tasks come before infrastructure tasks
- [ ] QA task comes after all implementation tasks
- [ ] Task briefs follow `shared/contracts/task-brief.md` format
- [ ] Dependencies between tasks explicitly stated (Blocked by / Provides to)
- [ ] Cross-context constraint respected — no task modifies order-management or queries customer-profile DB
- [ ] SecurityAlert invariant (at least one channel) is captured in a Definition of Done
- [ ] Frontend/devops tasks identified (REST endpoints → could involve frontend; K8s config → devops-agent)

---

## Fail Criteria

- Bundles domain + application + infrastructure into one task → ❌ violates "one task, one layer"
- Assigns cross-context work to a single agent → ❌ violates DDD boundary
- Skips QA as a separate task → ❌ violates pipeline
- Task briefs missing required fields from contract → ❌ contract violation
- Doesn't validate architect-output before proceeding → ❌ skipped validation
- Starts spawning agents without showing breakdown to user → ❌ (>3 tasks requires confirmation)
- Ignores the SecurityAlert invariant constraint → ❌ missed domain rule
