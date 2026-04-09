# Process Modeling

Reference for capturing business processes, domain events, and business rules
in a format that bridges stakeholder understanding and technical implementation.

---

## Event Storming Basics

Event Storming is a collaborative workshop technique for discovering domain events,
commands, and aggregates. It produces a shared understanding of business processes.

### Sticky Note Colors

| Color | Element | Definition | Example |
|-------|---------|-----------|---------|
| 🟠 Orange | **Domain Event** | Something that happened. Past tense. Immutable fact. | `OrderPlaced`, `PaymentReceived` |
| 🔵 Blue | **Command** | An action that triggers an event. Imperative verb. | `PlaceOrder`, `ProcessPayment` |
| 🟡 Yellow | **Aggregate** | The entity that receives the command and enforces rules. | `Order`, `Payment` |
| 🟣 Purple | **Policy** | A business rule that reacts to an event and triggers a command. "When X happens, do Y." | "When OrderPlaced, then ReserveInventory" |
| 🩷 Pink | **External System** | A system outside your bounded context. | Stripe, Email Service, Warehouse API |
| 🟢 Green | **Read Model / View** | Data a user needs to see to make a decision. | Order Summary, Dashboard |
| 🔴 Red | **Hot Spot / Question** | Something unclear, contentious, or risky. | "Who approves refunds over $500?" |

### How to Run a Session

1. **Invite:** Domain experts + developers. 4-8 people ideal. Max 90 minutes.
2. **Phase 1 — Chaotic Exploration (20 min):** Everyone writes domain events on orange stickies. No discussion yet. Place them roughly in time order on a wall/whiteboard.
3. **Phase 2 — Enforce Timeline (15 min):** Arrange events left-to-right in chronological order. Identify duplicates. Mark hot spots (red stickies) for disagreements.
4. **Phase 3 — Commands + Aggregates (20 min):** For each event, ask "What triggered this?" (blue command) and "What entity handled it?" (yellow aggregate).
5. **Phase 4 — Policies + External Systems (15 min):** Identify automation rules (purple policies) and external integrations (pink).
6. **Phase 5 — Bounded Contexts (20 min):** Draw boundaries around clusters of related events/aggregates. Name each context.

### Output

- A photo/digital capture of the event timeline
- A list of bounded contexts with their aggregates
- A list of hot spots requiring follow-up
- Domain events that become the backbone of your event-driven architecture

---

## Simple Process Flow Notation

For documenting linear business processes. Use when event storming is overkill
(single-context, well-understood process).

### Elements

| Symbol | Element | Use |
|--------|---------|-----|
| ▭ Rectangle | **Step** | An action or task performed by an actor |
| ◇ Diamond | **Decision** | A branching point with yes/no or multiple outcomes |
| ▭ (bold border) | **Swim Lane** | Groups steps by responsible actor/role |
| → Arrow | **Flow** | Direction of the process |
| ● Circle | **Start/End** | Beginning or termination of the process |

### When to Use

- Documenting an existing process before redesigning it
- Communicating a simple workflow to non-technical stakeholders
- Processes with 5-15 steps and 1-3 decision points

### Example: Order Cancellation

```
Customer                    │  Order Service              │  Notification Service
────────────────────────────┼─────────────────────────────┼─────────────────────
● Start                     │                             │
│                           │                             │
▭ Request cancellation ─────→ ◇ Order status?            │
                            │  ├─ Draft/Confirmed ────────→ ▭ Send confirmation email
                            │  │  ▭ Cancel order          │
                            │  │  ▭ Publish OrderCancelled│
                            │  │                          │
                            │  └─ Shipped/Cancelled       │
                            │     ▭ Reject with reason ──→ (no notification)
                            │                             │
                            │                      ● End  │
```

---

## Business Rule Documentation

Business rules are domain invariants that must be enforced regardless of UI or API.
Document them in a standard format so they can be traced from requirements to code.

### Format

| Field | Description |
|-------|-------------|
| **Rule ID** | Unique identifier: `BR-001`, `BR-002`, etc. |
| **Name** | Short descriptive name |
| **Description** | What the rule enforces, in plain business language |
| **Source** | Where this rule comes from (stakeholder, regulation, business policy) |
| **Examples** | Concrete scenarios showing the rule in action |
| **Exceptions** | Known cases where the rule does NOT apply |
| **Enforced By** | Which aggregate/service enforces this rule |

### Example Rules

---

**BR-001: SecurityAlert Minimum Channel**

| Field | Value |
|-------|-------|
| Rule ID | BR-001 |
| Name | SecurityAlert Minimum Channel |
| Description | A user must always have at least one notification channel enabled for SecurityAlert notifications. The system must prevent disabling the last active channel. |
| Source | Security team policy (2024-Q1) |
| Examples | User has Email=on, Push=off, SMS=off. User tries to disable Email → system rejects with explanation. User has Email=on, Push=on. User disables Email → allowed (Push still active). |
| Exceptions | None — this rule has no exceptions. |
| Enforced By | NotificationPreference aggregate |

---

**BR-002: Order Cancellation Window**

| Field | Value |
|-------|-------|
| Rule ID | BR-002 |
| Name | Order Cancellation Window |
| Description | Orders can only be cancelled when in Draft or Confirmed status. Orders that have been Shipped or already Cancelled cannot be cancelled. |
| Source | Operations team / fulfillment policy |
| Examples | Draft order → cancellation allowed. Shipped order → cancellation rejected with "Cannot cancel shipped order." |
| Exceptions | Admin override: support agents can cancel any order regardless of status (separate admin command). |
| Enforced By | Order aggregate |
