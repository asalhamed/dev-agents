# PRINCIPLES.md — Engineering Canon

All agents in this team operate under these principles. They are non-negotiable.
When in doubt, come back here.

---

## 🧮 Functional Programming (FP)

### Core Rules
1. **Pure functions first** — a function given the same inputs always returns the same output, with no side effects. Default to pure; isolate impurity at the edges.
2. **Immutability by default** — never mutate state in place. Return new values. Use `val`, `let`, `const`, `final` — not `var`, `let mut` (unless necessary in Rust for performance), `var`.
3. **Referential transparency** — any expression can be replaced by its value without changing program behavior. If it can't, it's a side effect — name it and contain it.
4. **Effects are values** — I/O, database calls, HTTP, time, randomness are all effects. Represent them as data, not imperative calls. Use effect systems (ZIO, Cats Effect, Tokio + async, etc.) to model and sequence them.
5. **Composition over inheritance** — build complex behavior by composing small, focused functions. Prefer `f(g(x))` over class hierarchies.
6. **Total functions** — functions should handle all inputs. No partial functions that throw on some inputs. Use `Option`, `Either`, `Result` to represent absence or failure.
7. **No exceptions for control flow** — exceptions are for truly exceptional, unrecoverable situations. Use typed error channels for expected failure modes.

### Algebraic Data Types (ADTs)
- Model your domain with sum types (sealed trait + case classes in Scala, enum in Rust) and product types (case class, struct)
- Exhaustive pattern matching — the compiler should tell you when a case is unhandled
- Make illegal states unrepresentable — if a state shouldn't exist, the type system should prevent it

### FP in Rust
```rust
// ❌ Imperative / mutable
fn process(items: &mut Vec<Item>) {
    for item in items.iter_mut() {
        item.value += 1;
    }
}

// ✅ Functional / immutable
fn process(items: Vec<Item>) -> Vec<Item> {
    items.into_iter().map(|item| Item { value: item.value + 1, ..item }).collect()
}

// ✅ Total function — no panics
fn divide(a: f64, b: f64) -> Option<f64> {
    if b == 0.0 { None } else { Some(a / b) }
}
```

### FP in Scala 3
```scala
// ❌ Mutable, impure
var count = 0
def increment(): Unit = { count += 1 }

// ✅ Pure, immutable
def increment(count: Int): Int = count + 1

// ✅ Effect as value (ZIO)
def fetchUser(id: UserId): ZIO[UserRepo, UserError, User] =
  ZIO.serviceWithZIO[UserRepo](_.findById(id))

// ✅ ADT — illegal states unrepresentable
enum PaymentStatus:
  case Pending
  case Completed(transactionId: TransactionId)
  case Failed(reason: FailureReason)
  case Refunded(originalId: TransactionId, refundId: TransactionId)
```

---

## 🏛️ Domain-Driven Design (DDD)

### Strategic Patterns
- **Bounded Context** — each service/module owns its domain language. The same word can mean different things in different contexts. Never let contexts bleed into each other.
- **Ubiquitous Language** — use the domain expert's vocabulary in code. `Order`, `Invoice`, `Shipment` — not `OrderObject`, `InvoiceDTO`, `ShipmentRecord`.
- **Context Mapping** — know how your bounded context relates to others: upstream/downstream, anti-corruption layer (ACL), shared kernel. Make these relationships explicit.

### Tactical Patterns

#### Entities
- Have identity — two entities with the same ID are the same entity even if all other fields differ
- Identity is stable over time
- In Scala: `case class Order(id: OrderId, ...)` where `OrderId` is an opaque type
- In Rust: `struct Order { id: OrderId, ... }` where `OrderId` is a newtype

#### Value Objects
- No identity — two value objects with the same data are equal
- Immutable
- Self-validating — construction fails if data is invalid
- In Scala: opaque types or case class with `apply` that returns `Either[ValidationError, ValueObject]`
- In Rust: newtype with `TryFrom` impl

```scala
// ✅ Value Object — self-validating
opaque type Email = String
object Email:
  def apply(s: String): Either[ValidationError, Email] =
    if s.contains("@") then Right(s) else Left(ValidationError.InvalidEmail(s))
```

```rust
// ✅ Value Object in Rust
#[derive(Debug, Clone, PartialEq)]
pub struct Email(String);

impl TryFrom<String> for Email {
    type Error = ValidationError;
    fn try_from(s: String) -> Result<Self, Self::Error> {
        if s.contains('@') { Ok(Email(s)) } else { Err(ValidationError::InvalidEmail(s)) }
    }
}
```

#### Aggregates
- Cluster of entities and value objects with a single root (the Aggregate Root)
- All mutations go through the root — never modify child entities directly
- Invariants are enforced at the aggregate boundary
- Aggregates communicate via Domain Events, not direct references

```scala
// ✅ Aggregate Root controls all mutations
case class Order private (id: OrderId, items: List[OrderItem], status: OrderStatus):
  def addItem(item: OrderItem): Either[OrderError, Order] =
    status match
      case OrderStatus.Draft => Right(copy(items = items :+ item))
      case _ => Left(OrderError.CannotModifyNonDraftOrder)
```

#### Domain Events
- Something that happened in the domain — past tense, immutable facts
- `OrderPlaced`, `PaymentReceived`, `ItemShipped` — not `UpdateOrder`, `ProcessPayment`
- Events are the primary integration mechanism between bounded contexts
- Never share database tables between bounded contexts — use events

#### Repositories
- Abstract persistence behind a domain interface
- The domain doesn't know about SQL, Kafka, HTTP — it knows about `UserRepository`, `OrderRepository`
- Repository interfaces live in the domain layer; implementations live in the infrastructure layer

```scala
// ✅ Domain layer — pure interface
trait OrderRepository[F[_]]:
  def findById(id: OrderId): F[Option[Order]]
  def save(order: Order): F[Unit]
  def findByCustomer(customerId: CustomerId): F[List[Order]]

// ✅ Infrastructure layer — implementation
class PostgresOrderRepository[F[_]: Async](xa: Transactor[F]) extends OrderRepository[F]:
  def findById(id: OrderId): F[Option[Order]] = ...
```

#### Application Services
- Orchestrate domain objects to fulfill use cases
- No business logic here — just coordination
- Thin; delegate to domain objects and repositories

#### Anti-Corruption Layer (ACL)
- When integrating with external systems or other bounded contexts, translate their model to yours
- Never let external concepts leak into your domain
- Use adapters and translators at the boundary

### Layered Architecture
```
┌─────────────────────────────┐
│  Interface Layer            │  HTTP handlers, CLI, event consumers
├─────────────────────────────┤
│  Application Layer          │  Use cases, application services, DTOs
├─────────────────────────────┤
│  Domain Layer               │  Entities, Value Objects, Aggregates,
│                             │  Domain Events, Repository interfaces
├─────────────────────────────┤
│  Infrastructure Layer       │  DB, HTTP clients, message brokers,
│                             │  repository implementations
└─────────────────────────────┘
```

**Dependency rule:** each layer only depends on the layer below it. Domain layer has zero external dependencies.

---

## 🧹 Clean Code

### Naming
- **Names should reveal intent** — `getUserById` not `getU`, `calculateMonthlyRevenue` not `calc`
- **No abbreviations** unless universally known (`id`, `url`, `http`)
- **Booleans**: `isActive`, `hasPermission`, `canProceed` — not `active`, `permission`, `proceed`
- **Functions**: verb phrases — `findOrder`, `calculateTotal`, `validateEmail`
- **Types/Classes**: noun phrases — `Order`, `UserRepository`, `PaymentProcessor`
- **Avoid noise words**: `OrderData`, `UserObject`, `InfoManager` — just `Order`, `User`, `Manager`

### Functions
- **Do one thing** — if you need "and" to describe it, split it
- **Small** — aim for <20 lines; hard limit at 40 lines (with justified exceptions)
- **Single level of abstraction** — don't mix high-level orchestration with low-level details in one function
- **No boolean flags as parameters** — `processOrder(order, true)` — true what? Split into two functions
- **Max 3 parameters** — if you need more, introduce a value object or config struct

### Structure
- **DRY** — but don't over-abstract. Three occurrences before you abstract, not two.
- **YAGNI** — don't build what you don't need yet. Speculative generality is technical debt.
- **SOLID** — especially Single Responsibility and Dependency Inversion
- **No magic numbers** — `val MaxRetries = 3` not `if (retries > 3)`
- **Comments explain WHY, not WHAT** — the code shows what; comments explain non-obvious reasoning

### Error Handling
- **Errors are first-class** — type them, don't bury them in logs
- **Fail fast** — validate at the boundary, don't let invalid data propagate deep
- **Distinguish error categories**:
  - Domain errors (expected, typed, recoverable): `Either[DomainError, T]` / `Result<T, E>`
  - Infrastructure errors (retry-able): network timeouts, DB connections
  - Programming errors (bugs, unrecoverable): panics in Rust, runtime exceptions in Scala
- **Never swallow errors silently** — log and rethrow, or return typed error, never `catch { }` with empty body

### Code Smells to Reject in Review
| Smell | Example | Fix |
|-------|---------|-----|
| Long method | >40 lines | Extract functions |
| God class | Does everything | Split by responsibility |
| Feature envy | Method uses another class's data more than its own | Move to that class |
| Data clumps | Same 3 fields always together | Extract value object |
| Primitive obsession | `String` for email, `Int` for money | Use opaque types / newtypes |
| Null / None abuse | `null` returned instead of typed absence | Use `Option`/`Result` |
| Mutable shared state | `var` accessed from multiple places | Immutable + functional update |
| Stringly typed | `status: String` = "active" | Use enum/ADT |

---

## 🔗 How These Principles Work Together

FP + DDD + Clean Code are not separate methodologies — they reinforce each other:

- **DDD** tells you *what* to model (bounded contexts, aggregates, domain events)
- **FP** tells you *how* to model it (immutable value objects, ADTs, pure functions, effect isolation)
- **Clean Code** tells you *how to express* the model (naming, small functions, no magic)

A well-designed system looks like:
```
Domain model expressed as ADTs (DDD + FP)
  → Pure functions transform domain state (FP)
  → Effects isolated at infrastructure boundary (FP)
  → Each function/type named after domain concepts (DDD + Clean Code)
  → Each function does one thing, clearly (Clean Code)
  → Invalid states are unrepresentable by the type system (FP + DDD)
```

---

## Security Principles

Security is a first-class concern, not an afterthought. Apply these principles across all agents.

- **Security is a requirement, not a feature.** Threat model every ADR. The security-agent reviews every ADR before tech-lead decomposes it.
- **Defense in depth.** Never rely on a single security control. Authentication + authorization + input validation + output encoding — all layers, always.
- **Least privilege.** Every service, user, and token gets minimum required permissions. Default deny.
- **Secrets never touch code.** No passwords, tokens, or keys in source code, ever. Use vault, environment injection, or sealed secrets.
- **Validate at the boundary.** Never trust external input — including input from other internal services. Parse, validate, reject early.
- **Fail securely.** When something goes wrong, fail closed (deny access) not open (allow access).
- **Audit everything security-relevant.** Auth events, permission changes, data access — all logged with actor, resource, and timestamp.

---

## Product Principles

Features exist to solve user problems. Keep this chain visible from requirements through delivery.

- **Every feature must have measurable success criteria before work begins.** If we can't measure it, we can't know if it worked. The data-analyst defines metrics before the architect designs.
- **User needs drive design decisions, not technical convenience.** The ux-researcher's findings are inputs to the architect, not afterthoughts.
- **Acceptance criteria are in Given/When/Then format and are testable.** "Users should be able to..." is not acceptance criteria. "Given X, when Y, then Z" is.
- **Business rules are domain rules.** They belong in the domain layer, expressed in ubiquitous language, not scattered across controllers and SQL queries.
- **Scope creep is a pipeline smell.** If requirements expand after the architect has produced an ADR, stop. Go back to product-owner. Don't silently absorb scope.

---

## IoT Principles

- **Offline-first.** Devices and edge systems must function without cloud connectivity. Design for intermittent connectivity; sync when available.
- **Bandwidth-aware.** Never assume unlimited bandwidth. Compress, filter, and prioritize data at the source. Send summaries and alerts, not raw streams.
- **OTA safety.** Firmware updates must be atomic, verified, and rollback-capable. A bad OTA can brick thousands of devices and destroy customer trust.
- **Device identity.** Every device has a cryptographic identity. No shared secrets across a fleet. Certificate rotation must be possible without physical access.
- **Telemetry versioning.** Device telemetry schemas must be backward-compatible. Devices cannot all upgrade simultaneously — plan for version skew.

---

## Video Principles

- **Privacy by design.** Video of people requires consent, data minimization, and retention policies from day one — not as a retrofit.
- **Latency budgets.** Define and enforce end-to-end latency targets. Camera → viewer must meet the use case requirement. Measure it; don't assume it.
- **Graceful degradation.** Reduce quality before dropping frames. Something visible is better than nothing. Adaptive bitrate is not optional for constrained links.
- **Storage lifecycle.** Every video segment has a retention policy. Infinite storage is not a product feature — it is a cost and compliance liability.

---

## Startup Principles

- **Measure before you build.** Every feature must have defined success metrics before development starts. If we cannot measure it, we cannot know if it worked.
- **Customer zero.** The first customer's deployment is the most important. Learn everything from it. Treat it like a partnership, not a transaction.
- **Reversible decisions.** Prefer decisions that can be undone over permanent commitments, especially early on when information is incomplete.
- **Hire for the next 6 months.** Not for what you'll need in 2 years. Over-hiring ahead of product-market fit burns runway.

---

## Delivery Principles

- **Estimate before you start.** Every feature has a kickoff with estimates and a target delivery date before implementation begins. No feature starts without a feature-kickoff contract.
- **Scope is sacred.** Changes after kickoff require a formal scope-change-request. No agent silently absorbs new work — escalate to product-owner first.
- **Acceptance before release.** Product-owner validates against PRD acceptance criteria before any release. Code review is necessary but not sufficient — the feature must do what the user asked for.
- **Ship gradually.** Feature flags and phased rollout for all non-trivial features. Big-bang releases are opt-in exceptions, not the default.
- **Learn from every feature.** Retrospective is mandatory after every delivery. No feature is fully done until lessons are captured and action items assigned.
