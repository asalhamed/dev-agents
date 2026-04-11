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

## Cross-Cutting Terms

| Term | Definition |
|------|-----------|
| **Threat Model** | A structured analysis of potential security threats against a system, using STRIDE or similar framework |
| **Attack Surface** | The sum of all points where an attacker could try to enter or extract data from a system |
| **Trust Boundary** | A point in a system where data crosses from one trust level to another (e.g., from internet to internal network) |
| **User Persona** | A fictional but research-based representation of a user segment with goals, pain points, and behaviors |
| **User Journey** | A step-by-step map of how a user interacts with a product to achieve a goal, including emotional state |
| **Usability Requirement** | A measurable target for how easily users can accomplish tasks |
| **PRD (Product Requirements Document)** | A document that defines what a feature should do, why it matters, and how success is measured |
| **Acceptance Criterion** | A testable condition (Given/When/Then) that must be true for a feature to be considered complete |
| **SLO (Service Level Objective)** | An internal target for service reliability (e.g., 99.9% availability over 28 days) |
| **SLI (Service Level Indicator)** | A metric used to measure service reliability (e.g., successful requests / total requests) |
| **Error Budget** | The allowed downtime or error rate before an SLO is breached (e.g., 43.2 minutes/month for 99.9% SLO) |
| **Bounded Context Map** | A diagram showing bounded contexts and how they relate to each other |

---

## Delivery & Process Terms

| Term | Definition |
|------|-----------|
| **Feature Kickoff** | A contract produced by tech-lead that captures scope, estimation, rollout plan, and pipeline-level Definition of Done for a feature |
| **Acceptance Testing** | Validation of a feature against PRD acceptance criteria (not code quality — that's code review) |
| **Scope Change Request** | Formal request to modify feature scope during implementation; requires product-owner approval |
| **Feature Flag** | A configuration toggle that controls whether a feature is visible to users, enabling gradual rollout without separate deployments |
| **Gradual Rollout** | Deploying code to production but enabling it progressively: internal → beta (5%) → GA (100%) |
| **Retrospective** | Post-delivery review capturing timeline accuracy, blockers, scope changes, and action items for improvement |

## Multi-Repo & Microservice Terms

| Term | Definition |
|------|-----------|
| **Platform Contracts** | A dedicated repository (`platform-contracts`) that is the single source of truth for all inter-service API specs, event schemas, and protocol definitions |
| **Contract-First Development** | Defining the inter-service contract (OpenAPI, Avro, Protobuf) before writing implementation code |
| **Producer Contract Test** | A test in the producing service's CI that verifies the service's actual output matches its declared contract spec |
| **Consumer Contract Test** | A test in the consuming service's CI that verifies the service can handle all valid messages defined in the producer's contract |
| **Service Contract Change** | A formal request to modify a shared contract, requiring compatibility analysis and ordered rollout across all consuming services |
| **Backward Compatibility** | A contract change where existing consumers continue to work without modification (e.g., adding an optional field) |
| **Schema Registry** | A centralized service that stores and validates event schemas, enforcing compatibility rules on schema evolution |
| **Trunk-Based Development** | A branching strategy where `main` is always deployable and feature work happens on short-lived feature branches |
| **Independent Deployability** | The property that a service can be built, tested, and deployed without touching any other service's repository |

---

_This glossary is maintained by the architect agent. When a new ADR introduces domain terms,
they should be added here under "Project-Specific Terms"._
