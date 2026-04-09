# TypeScript Backend Patterns

Reference guide for DDD-aligned TypeScript backend development with functional programming conventions.

---

## Project Structure

```
project-root/
├── src/
│   ├── domain/
│   │   ├── order/
│   │   │   ├── aggregate.ts       # Order aggregate root (pure functions)
│   │   │   ├── events.ts          # OrderConfirmed, OrderCancelled
│   │   │   ├── errors.ts          # Discriminated union error types
│   │   │   ├── repository.ts      # Interface only
│   │   │   └── value-objects.ts   # OrderId, Money, Currency
│   │   └── customer/
│   │       ├── aggregate.ts
│   │       └── value-objects.ts
│   ├── application/
│   │   ├── confirm-order.ts       # Use case / application service
│   │   └── dto.ts                 # Domain ↔ API translation
│   ├── infrastructure/
│   │   ├── postgres/
│   │   │   └── order-repo.ts      # OrderRepository implementation
│   │   ├── http/
│   │   │   └── routes.ts          # HTTP route handlers
│   │   └── kafka/
│   │       └── publisher.ts       # Event publisher
│   ├── config/
│   │   └── index.ts               # Environment config, typed
│   └── main.ts                    # Composition root, server start
├── tests/
│   ├── domain/
│   │   └── order/
│   │       ├── aggregate.test.ts
│   │       └── value-objects.test.ts
│   └── application/
│       └── confirm-order.test.ts
├── package.json
├── tsconfig.json
└── vitest.config.ts
```

**Rules:**
- `src/domain/` has zero imports from `infrastructure/` or any framework package
- `src/application/` orchestrates domain — no business logic lives here
- `src/infrastructure/` implements domain interfaces and wires external dependencies
- `main.ts` is the composition root — builds the dependency graph and starts the server

---

## Value Objects — Branded Types

Use branded types to prevent primitive confusion at the type level.

```typescript
// ✅ Brand utility — compile-time type safety
declare const __brand: unique symbol;
type Brand<T, B> = T & { readonly [__brand]: B };

// ✅ Branded type aliases
type OrderId = Brand<string, "OrderId">;
type CustomerId = Brand<string, "CustomerId">;

// ✅ Smart constructors returning Either
function createOrderId(s: string): Either<ValidationError, OrderId> {
  if (s.trim() === "") {
    return left({ _tag: "ValidationError", field: "orderId", message: "cannot be empty" });
  }
  return right(s as OrderId);
}

function createCustomerId(s: string): Either<ValidationError, CustomerId> {
  if (s.trim() === "") {
    return left({ _tag: "ValidationError", field: "customerId", message: "cannot be empty" });
  }
  return right(s as CustomerId);
}

// ✅ Email — smart constructor with validation
type Email = Brand<string, "Email">;

function createEmail(s: string): Either<ValidationError, Email> {
  if (!s.includes("@")) {
    return left({ _tag: "ValidationError", field: "email", message: "invalid email format" });
  }
  return right(s as Email);
}

// ✅ Money — immutable value object
interface Money {
  readonly amountInCents: number;
  readonly currency: Currency;
}

type Currency = "USD" | "EUR" | "GBP";

function createMoney(amountInCents: number, currency: Currency): Either<ValidationError, Money> {
  if (amountInCents < 0) {
    return left({ _tag: "ValidationError", field: "amount", message: "cannot be negative" });
  }
  return right({ amountInCents, currency });
}

function addMoney(a: Money, b: Money): Either<DomainError, Money> {
  if (a.currency !== b.currency) {
    return left({ _tag: "CurrencyMismatch", expected: a.currency, got: b.currency });
  }
  return right({ amountInCents: a.amountInCents + b.amountInCents, currency: a.currency });
}
```

---

## Result / Either Type

Minimal Either implementation for domain error handling without throwing.

```typescript
// ✅ Minimal Either
interface Left<E> {
  readonly _tag: "Left";
  readonly value: E;
}

interface Right<A> {
  readonly _tag: "Right";
  readonly value: A;
}

type Either<E, A> = Left<E> | Right<A>;

function left<E>(e: E): Either<E, never> {
  return { _tag: "Left", value: e };
}

function right<A>(a: A): Either<never, A> {
  return { _tag: "Right", value: a };
}

function isLeft<E, A>(either: Either<E, A>): either is Left<E> {
  return either._tag === "Left";
}

function isRight<E, A>(either: Either<E, A>): either is Right<A> {
  return either._tag === "Right";
}

function map<E, A, B>(either: Either<E, A>, f: (a: A) => B): Either<E, B> {
  return isRight(either) ? right(f(either.value)) : either;
}

function flatMap<E, A, B>(either: Either<E, A>, f: (a: A) => Either<E, B>): Either<E, B> {
  return isRight(either) ? f(either.value) : either;
}
```

> **Note:** For production projects, consider using `fp-ts` or `effect-ts` instead of rolling your own.
> These libraries provide comprehensive Either/Option/Task types with full ecosystem support.

---

## Aggregate Root

Aggregates are immutable interfaces with pure functions that return Either.

```typescript
// ✅ Immutable aggregate
interface Order {
  readonly id: OrderId;
  readonly items: readonly OrderItem[];
  readonly status: OrderStatus;
}

interface OrderItem {
  readonly id: string;
  readonly productId: string;
  readonly price: Money;
  readonly quantity: number;
}

type OrderStatus = "Draft" | "Confirmed" | "Cancelled";

// ✅ Pure function returning Either<Error, [NewState, Event]>
function confirmOrder(order: Order): Either<OrderError, readonly [Order, OrderConfirmed]> {
  if (order.status !== "Draft") {
    return left({ _tag: "AlreadyProcessed", orderId: order.id });
  }
  if (order.items.length === 0) {
    return left({ _tag: "EmptyOrder", orderId: order.id });
  }

  const confirmed: Order = {
    ...order,
    status: "Confirmed",
  };

  const event: OrderConfirmed = {
    _tag: "OrderConfirmed",
    orderId: order.id,
    confirmedAt: new Date(),
    itemCount: order.items.length,
  };

  return right([confirmed, event] as const);
}
```

**Rules:**
- All fields `readonly`
- State transitions produce new objects via spread — never mutate
- Business invariants enforced in domain functions, not application layer
- Events produced alongside state changes

---

## Domain Errors — Typed, Not Thrown

Use discriminated unions with `_tag` for exhaustive error handling.

```typescript
// ✅ Discriminated union — exhaustive at compile time
type OrderError =
  | { readonly _tag: "EmptyOrder"; readonly orderId: OrderId }
  | { readonly _tag: "AlreadyProcessed"; readonly orderId: OrderId }
  | { readonly _tag: "ItemNotFound"; readonly itemId: string };

type ValidationError = {
  readonly _tag: "ValidationError";
  readonly field: string;
  readonly message: string;
};

type CurrencyMismatch = {
  readonly _tag: "CurrencyMismatch";
  readonly expected: Currency;
  readonly got: Currency;
};

type DomainError = OrderError | ValidationError | CurrencyMismatch;

// ✅ Exhaustive switch — TypeScript compiler catches missing cases
function orderErrorMessage(error: OrderError): string {
  switch (error._tag) {
    case "EmptyOrder":
      return `Order ${error.orderId} has no items`;
    case "AlreadyProcessed":
      return `Order ${error.orderId} is already processed`;
    case "ItemNotFound":
      return `Item ${error.itemId} not found in order`;
  }
  // No default needed — TypeScript ensures exhaustiveness
}
```

**Rules:**
- Never `throw` in domain layer — return `Either<Error, T>` instead
- Every error type has a `_tag` discriminant
- Use `switch` for exhaustive matching
- Infrastructure layer may convert Either to HTTP status codes

---

## Repository Pattern

### Domain Interface (in `src/domain/order/repository.ts`)

```typescript
interface OrderRepository {
  findById(id: OrderId): Promise<Order | undefined>;
  save(order: Order): Promise<void>;
  findByCustomer(customerId: CustomerId): Promise<readonly Order[]>;
}
```

### Infrastructure Implementation (in `src/infrastructure/postgres/order-repo.ts`)

```typescript
class PostgresOrderRepository implements OrderRepository {
  constructor(private readonly pool: Pool) {}

  async findById(id: OrderId): Promise<Order | undefined> {
    const result = await this.pool.query("SELECT * FROM orders WHERE id = $1", [id]);
    if (result.rows.length === 0) return undefined;
    return mapRowToOrder(result.rows[0]);
  }

  async save(order: Order): Promise<void> {
    await this.pool.query(
      "INSERT INTO orders (id, status, items) VALUES ($1, $2, $3) ON CONFLICT (id) DO UPDATE SET status = $2, items = $3",
      [order.id, order.status, JSON.stringify(order.items)]
    );
  }

  async findByCustomer(customerId: CustomerId): Promise<readonly Order[]> {
    const result = await this.pool.query("SELECT * FROM orders WHERE customer_id = $1", [customerId]);
    return result.rows.map(mapRowToOrder);
  }
}
```

**Rules:**
- Interface defined in domain — implementation in infrastructure
- Domain never imports infrastructure packages
- Repository returns domain types, not DB rows
- `Promise` for async — infrastructure detail stays in infrastructure

---

## Testing

### Pure Domain Tests

```typescript
describe("Order.confirm", () => {
  it("confirms a draft order with items", () => {
    const order = createDraftOrder({ itemCount: 2 });

    const result = confirmOrder(order);

    expect(isRight(result)).toBe(true);
    if (isRight(result)) {
      const [confirmed, event] = result.value;
      expect(confirmed.status).toBe("Confirmed");
      expect(event._tag).toBe("OrderConfirmed");
      expect(event.itemCount).toBe(2);
    }
  });

  it("rejects confirming an empty order", () => {
    const order = createDraftOrder({ itemCount: 0 });

    const result = confirmOrder(order);

    expect(isLeft(result)).toBe(true);
    if (isLeft(result)) {
      expect(result.value._tag).toBe("EmptyOrder");
    }
  });

  it("rejects confirming an already confirmed order", () => {
    const order: Order = { ...createDraftOrder({ itemCount: 1 }), status: "Confirmed" };

    const result = confirmOrder(order);

    expect(isLeft(result)).toBe(true);
    if (isLeft(result)) {
      expect(result.value._tag).toBe("AlreadyProcessed");
    }
  });
});
```

**Rules:**
- No mocks for pure domain tests — functions are pure, just call them
- Test names describe behavior: "confirms a draft order with items"
- Use `describe/it` structure
- Application layer tests may mock repository interface

---

## FP Conventions

| Convention | Rule |
|-----------|------|
| No `any` | Use `unknown` + type guards, or generic `<T>` — never `any` |
| No `throw` in domain | Return `Either<Error, T>` — exceptions are for infrastructure failures only |
| `readonly` everywhere | All interface fields, function parameters, and array types use `readonly` |
| No `null` in domain returns | Use `Option` (undefined) or `Either` — never return `null` from domain functions |
| No `class` for domain models | Use `interface` + pure functions — classes are for infrastructure implementations |
| No mutations | Use spread `{ ...obj, field: newValue }` — never mutate objects |
| Discriminated unions for ADTs | Every sum type uses `_tag` discriminant for exhaustive matching |
| No side effects in domain | Domain functions are pure — I/O lives in infrastructure layer |

---

## Build & Test

```yaml
build: pnpm build
test: vitest run
lint: eslint . --ext .ts
format: prettier --check .
coverage: vitest run --coverage
coverage_threshold: 75%
```

**CI pipeline steps:**
1. `pnpm install --frozen-lockfile` — reproducible install
2. `prettier --check .` — formatting check
3. `eslint . --ext .ts` — static analysis
4. `pnpm build` — type-check and compile
5. `vitest run --coverage` — tests with coverage
