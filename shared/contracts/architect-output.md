# Contract: architect → tech-lead

**Producer:** architect  
**Consumer:** tech-lead  
**Trigger:** architect completes an ADR and is ready to hand off

---

## Required Fields

```markdown
## ARCHITECT OUTPUT

### ADR Reference
<!-- REQUIRED: ADR number and title -->
**ADR:** ADR-[number]: [title]
**Status:** Proposed | Accepted

### Problem Statement
<!-- REQUIRED: 2-5 sentences. What problem are we solving and why now? -->
[problem statement]

### Bounded Context
<!-- REQUIRED: Which bounded context owns this change? -->
**Context:** [context name]
**Affected contexts:** [list of other contexts that need to know about this change]

### Domain Model Changes
<!-- REQUIRED: List all domain model additions/changes -->
**New aggregates:** [list or "none"]
**New value objects:** [list or "none"]  
**New domain events:** [list — must be past tense] or "none"
**Modified aggregates:** [list with description of change] or "none"
**Ubiquitous language additions:** [term: definition] or "none"

### Contracts
<!-- REQUIRED: At least one of these must be non-empty -->

#### API Contracts (if applicable)
<!-- Format: METHOD /path — Request: {shape} — Response: {shape} — Errors: [types] -->
[list or "N/A"]

#### Domain Event Schemas (if applicable)
<!-- Format: EventName { field: Type, occurredAt: Timestamp } -->
[list or "N/A"]

#### Schema Changes (if applicable)
<!-- Format: table/collection name — change description — reversible: yes/no -->
[list or "N/A"]

### Constraints & Decisions
<!-- REQUIRED: What must the implementation NOT do? What must it do? -->
**Must:** [list of hard requirements from the ADR]
**Must not:** [list of explicit exclusions — e.g. "must not access partner_service DB directly"]

### Handoff Summary for Tech Lead
<!-- REQUIRED: Plain-language summary of what needs to be built, in the order it should be built -->
[2-10 bullet points, ordered by implementation priority]

### Open Questions
<!-- Optional: Anything unresolved that tech-lead or devs may hit -->
[list or "none"]
```

---

## Validation (tech-lead must check on receipt)

Before proceeding, tech-lead verifies:
- [ ] ADR number and title present
- [ ] Bounded context identified
- [ ] At least one contract section is non-empty (API, event schema, or schema change)
- [ ] `Must` and `Must not` constraints listed
- [ ] Domain events are past tense (e.g. `OrderPlaced`, not `PlaceOrder`)
- [ ] No infrastructure types mentioned in domain model section

**If any required field is missing:** reply to architect with a list of what's missing. Do not proceed.

---

## Example (valid)

```markdown
## ARCHITECT OUTPUT

### ADR Reference
**ADR:** ADR-007: Order Confirmation via Domain Event
**Status:** Accepted

### Problem Statement
Currently the order service calls the notification service directly over HTTP on confirmation.
This creates tight coupling and causes cascading failures when notification is down.
We need to decouple via a domain event.

### Bounded Context
**Context:** order-management
**Affected contexts:** notification (downstream consumer of new event)

### Domain Model Changes
**New aggregates:** none
**New value objects:** none
**New domain events:** OrderConfirmed { orderId: OrderId, customerId: CustomerId, confirmedAt: Timestamp }
**Modified aggregates:** Order — add confirm() method that produces OrderConfirmed event
**Ubiquitous language additions:** none

### Contracts

#### Domain Event Schemas
OrderConfirmed {
  orderId: OrderId       // UUID
  customerId: CustomerId // UUID
  confirmedAt: Timestamp // ISO 8601
  items: List[ConfirmedItem]
}

ConfirmedItem {
  itemId: ItemId
  quantity: Int
  unitPrice: Money
}

#### Schema Changes
order_events table — add event_type column — reversible: yes

### Constraints & Decisions
**Must:** publish OrderConfirmed to Kafka topic `order.events`
**Must:** notification service consumes from Kafka (ADL prescribed in ADR-007)
**Must not:** call notification service directly via HTTP from order service
**Must not:** put notification logic in order domain

### Handoff Summary for Tech Lead
- Add confirm() method to Order aggregate, returning (Order, OrderConfirmed)
- Add OrderConfirmed event schema to domain/events
- Implement Kafka publisher for OrderConfirmed in infrastructure layer
- Wire publisher into ConfirmOrderUseCase in application layer
- Update notification service to consume from `order.events` topic (separate task)

### Open Questions
- Should OrderConfirmed include full item details or just IDs? (assumed full for now — revisit if payload is too large)
```
