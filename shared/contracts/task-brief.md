# Contract: tech-lead → dev agents

**Producer:** tech-lead  
**Consumers:** backend-dev, frontend-dev, qa-agent, devops-agent  
**Trigger:** tech-lead spawns a specialist agent for a specific task slice

---

## Required Fields

```markdown
## TASK BRIEF

### Assignment
**Agent:** backend-dev | frontend-dev | qa-agent | devops-agent
**Task ID:** [T-001 — sequential, unique within this pipeline run]
**Task:** [Single sentence. One concern. Starts with a verb.]
**Layer:** domain | application | infrastructure | interface | frontend | infra | test

### Context
**Repo:** [path or URL]
**Branch:** `feature/F-{NNN}-{slug}` (create if first task for this feature)
**Relevant files:** [list of paths the agent should read first]
**Stack:** [Rust | Scala 3 | Scala 2 | TypeScript | Vue/Nuxt | React | Leptos | K8s]
**ADR:** [ADR-NNN reference or "N/A — small task"]
**Commit prefix:** `{type}({scope}):  Refs: F-{NNN}, T-{NNN}`

### Contract to Implement or Consume
<!-- REQUIRED: What interface/API/event/schema does this task implement or use? -->
<!-- Copy the relevant section from shared/contracts/architect-output.md -->
[paste relevant contract section or "N/A"]

### Dependencies
**Blocked by:** [task ID(s) that must complete first, or "none"]
**Provides to:** [task ID(s) that depend on this output, or "none"]

### Definition of Done
<!-- REQUIRED: Specific, verifiable criteria -->
- [ ] [criterion 1]
- [ ] [criterion 2]
- [ ] Tests written and passing
- [ ] Coverage at or above threshold
- [ ] No principles violations (FP / DDD / Clean Code — see ../PRINCIPLES.md)

### Output Expected
<!-- REQUIRED: Which contract format should the agent produce? -->
**Produce:** implementation-summary | devops-summary | qa-report
**Send to:** [next agent in pipeline or "tech-lead for review"]
```

---

## Validation (each dev agent must check on receipt)

Before starting:
- [ ] Task is a single concern (if it contains "and", push back to tech-lead for splitting)
- [ ] Layer is specified — agent knows which layer they're working in
- [ ] Contract section is present or "N/A" with a reason
- [ ] Definition of Done has at least 3 specific criteria
- [ ] Stack is specified

**If any required field is missing:** reply to tech-lead with what's missing. Do not start.

---

## Example (valid — backend-dev)

```markdown
## TASK BRIEF

### Assignment
**Agent:** backend-dev
**Task ID:** T-002
**Task:** Add confirm() method to Order aggregate that validates invariants and produces OrderConfirmed event
**Layer:** domain

### Context
**Repo:** /workspace/order-service
**Branch:** `feature/F-012-live-video-alerts`
**Relevant files:**
  - src/domain/order/aggregate.rs (or Order.scala)
  - src/domain/order/events.rs (or OrderEvents.scala)
  - src/domain/order/errors.rs (or OrderError.scala)
**Stack:** Scala 3
**ADR:** ADR-007: Order Confirmation via Domain Event
**Commit prefix:** `feat(order):  Refs: F-012, T-001`

### Contract to Implement or Consume
OrderConfirmed event schema (from ADR-007):
OrderConfirmed {
  orderId: OrderId
  customerId: CustomerId
  confirmedAt: Timestamp
  items: List[ConfirmedItem]
}
confirm() must:
- Fail with OrderError.EmptyOrder if items list is empty
- Fail with OrderError.AlreadyProcessed if status != Draft
- Return (Order with status=Confirmed, OrderConfirmed event)

### Dependencies
**Blocked by:** none (pure domain — no infrastructure deps)
**Provides to:** T-003 (ConfirmOrderUseCase wiring), T-005 (qa-agent)

### Definition of Done
- [ ] Order.confirm() returns Either[OrderError, (Order, OrderConfirmed)]
- [ ] EmptyOrder error returned when items list is empty
- [ ] AlreadyProcessed error returned when status != Draft
- [ ] OrderConfirmed event contains all required fields per ADR-007 schema
- [ ] Unit tests cover: happy path, EmptyOrder, AlreadyProcessed
- [ ] No infrastructure types imported in domain layer
- [ ] Coverage at or above 75%

### Output Expected
**Produce:** implementation-summary
**Send to:** tech-lead
```

---

## Example (valid — Rust backend-dev)

```markdown
## TASK BRIEF

### Assignment
**Agent:** backend-dev
**Task ID:** T-004
**Task:** Implement Money value object with add() and currency validation
**Layer:** domain

### Context
**Repo:** /workspace/order-service
**Branch:** `feature/F-012-live-video-alerts`
**Relevant files:**
  - src/domain/money.rs (new file)
  - src/domain/errors.rs (add DomainError variants)
  - src/domain/mod.rs (add pub mod money)
**Stack:** Rust
**ADR:** ADR-009: Monetary Values as Value Objects
**Commit prefix:** `feat(order):  Refs: F-012, T-002`

### Contract to Implement or Consume
Money value object (from ADR-009):
- Money struct with private fields (amount: i64, currency: Currency)
- Currency enum: USD, EUR, GBP
- Construction via TryFrom: reject negative amounts, return Result
- add() method: returns Result<Money, DomainError>, CurrencyMismatch on mixed currencies
- No f64 — all amounts in cents (i64)
- Newtype pattern — no raw i64 for monetary values

### Dependencies
**Blocked by:** none (pure domain — no infrastructure deps)
**Provides to:** T-005 (OrderItem price field migration), T-008 (qa-agent tests)

### Definition of Done
- [ ] Money struct with private fields, getters for amount and currency
- [ ] TryFrom impl that rejects negative amounts with NegativeAmount error
- [ ] add() returns Result<Money, DomainError> — CurrencyMismatch on mismatched currencies
- [ ] Currency is an enum (USD, EUR, GBP) — not a String
- [ ] No unwrap() or panic!() in non-test code
- [ ] Error types use thiserror for derive(Error)
- [ ] Unit tests: construction, add same currency, add different currency, negative rejection
- [ ] Property-based test (proptest) for addition associativity
- [ ] Coverage at or above 80%
- [ ] No infrastructure types imported in domain layer
- [ ] See references/rust-patterns.md for implementation patterns

### Output Expected
**Produce:** implementation-summary
**Send to:** tech-lead
```
