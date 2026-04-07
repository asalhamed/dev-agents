# Glossary — Ubiquitous Language

Single source of truth for domain terms used across all agents.
When agents name types, events, or functions, they use these terms exactly.

---

## General DDD Terms

| Term | Definition | Example |
|------|-----------|---------| 
| **Aggregate** | A cluster of entities and value objects with a single root that enforces invariants. All mutations go through the root. | `Order` is an aggregate root containing `OrderItem` entities |
| **Aggregate Root** | The entry point entity of an aggregate. External code only references the root. | `Order.confirm()` — not `OrderItem.markConfirmed()` |
| **Value Object** | An immutable object defined by its attributes, not by identity. Two VOs with the same data are equal. Self-validating on construction. | `Email`, `Money`, `OrderId` |
| **Domain Event** | An immutable fact about something that happened in the domain. Always past tense. | `OrderPlaced`, `PaymentReceived`, `ItemShipped` |
| **Bounded Context** | A boundary within which a particular domain model applies. The same word can mean different things in different contexts. | "Order" in order-management vs. "Order" in fulfillment |
| **Anti-Corruption Layer (ACL)** | A translation layer that prevents external models from leaking into your domain. | `StripePaymentAdapter` translates Stripe's model to your `Payment` domain |
| **Repository** | An abstraction over persistence. Interface lives in domain layer; implementation in infrastructure. | `trait OrderRepository` (domain) / `PostgresOrderRepository` (infra) |
| **Use Case** | An application-layer service that orchestrates domain objects to fulfill a business scenario. Contains no business logic itself. | `ConfirmOrderUseCase` calls `order.confirm()` then `repo.save()` |

## Naming Conventions

| Category | Convention | Good | Bad |
|----------|-----------|------|-----|
| Domain events | Past tense, noun phrase | `OrderPlaced` | `PlaceOrder`, `OrderPlacing` |
| Commands | Imperative verb phrase | `ConfirmOrder` | `OrderConfirmation` |
| Value objects | Noun, domain language | `Money`, `Email` | `MoneyValue`, `EmailString` |
| Entities | Noun, domain language | `Order`, `Customer` | `OrderEntity`, `CustomerRecord` |
| Repositories | `[Entity]Repository` | `OrderRepository` | `OrderDao`, `OrderStore` |
| Errors | `[Context]Error.[Variant]` | `OrderError.EmptyOrder` | `Exception("empty")` |

## Project-Specific Terms

_Add project-specific domain terms below as they are defined in ADRs._

| Term | Context | Definition | Introduced in |
|------|---------|-----------|--------------| 
| _example:_ Channel | notification | A delivery mechanism: Email, SMS, or Push | ADR-012 |
| _example:_ EventCategory | notification | A class of domain events that trigger notifications | ADR-012 |

---

_This glossary is maintained by the architect agent. When a new ADR introduces domain terms,
they should be added here under "Project-Specific Terms"._
