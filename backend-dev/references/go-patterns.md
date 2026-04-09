# Go Backend Patterns

Reference guide for DDD-aligned Go backend development with functional programming conventions.

---

## Project Structure

```
project-root/
├── cmd/
│   └── server/
│       └── main.go              # Wiring, config, server start
├── internal/
│   ├── domain/
│   │   ├── order/
│   │   │   ├── aggregate.go     # Order aggregate root
│   │   │   ├── events.go        # OrderConfirmed, OrderCancelled
│   │   │   ├── errors.go        # Sentinel + custom errors
│   │   │   ├── repository.go    # Interface only — no implementation
│   │   │   └── valueobjects.go  # OrderId, Money, Currency
│   │   └── customer/
│   │       ├── aggregate.go
│   │       └── valueobjects.go
│   ├── application/
│   │   ├── confirm_order.go     # Use case / application service
│   │   └── dto.go               # Domain ↔ API translation
│   └── infrastructure/
│       ├── postgres/
│       │   └── order_repo.go    # OrderRepository implementation
│       ├── http/
│       │   └── handlers.go      # HTTP route handlers
│       └── kafka/
│           └── publisher.go     # Event publisher
├── go.mod
├── go.sum
└── Makefile
```

**Rules:**
- `internal/domain/` has zero imports from `infrastructure/` or any framework package
- `internal/application/` orchestrates domain — no business logic lives here
- `internal/infrastructure/` implements domain interfaces and wires external dependencies
- `cmd/` is the composition root — builds the dependency graph and starts the server

---

## Value Objects — Newtype Pattern

Wrap primitive types to enforce domain semantics and self-validation.

```go
// ✅ OrderId — newtype over string
type OrderId string

func NewOrderId(s string) (OrderId, error) {
    if s == "" {
        return "", ErrEmptyOrderId
    }
    return OrderId(s), nil
}

// ✅ CustomerId — newtype over string
type CustomerId string

func NewCustomerId(s string) (CustomerId, error) {
    if s == "" {
        return "", ErrEmptyCustomerId
    }
    return CustomerId(s), nil
}

// ✅ Currency — constrained set
type Currency string

const (
    USD Currency = "USD"
    EUR Currency = "EUR"
    GBP Currency = "GBP"
)

func ParseCurrency(s string) (Currency, error) {
    switch Currency(s) {
    case USD, EUR, GBP:
        return Currency(s), nil
    default:
        return "", fmt.Errorf("%w: %s", ErrInvalidCurrency, s)
    }
}

// ✅ Money — self-validating value object
type Money struct {
    cents    int64    // private — only accessible via getter
    currency Currency // private
}

func NewMoney(cents int64, currency Currency) (Money, error) {
    if cents < 0 {
        return Money{}, ErrNegativeAmount
    }
    return Money{cents: cents, currency: currency}, nil
}

func (m Money) Cents() int64       { return m.cents }
func (m Money) Currency() Currency { return m.currency }

func (m Money) Add(other Money) (Money, error) {
    if m.currency != other.currency {
        return Money{}, fmt.Errorf("%w: cannot add %s to %s", ErrCurrencyMismatch, m.currency, other.currency)
    }
    return NewMoney(m.cents+other.cents, m.currency)
}
```

**Key rules:**
- Constructors return `(T, error)` — never panic
- Fields are unexported — access via getters
- Validation happens at construction time, not at use time
- Zero value of the struct should be safe (or obviously invalid)

---

## Aggregate Root

Aggregates have unexported fields and pure methods that return new state + event + error.

```go
type Order struct {
    id     OrderId
    items  []OrderItem
    status OrderStatus
}

type OrderStatus int

const (
    OrderDraft OrderStatus = iota
    OrderConfirmed
    OrderCancelled
)

// Pure method — returns new state + domain event + error
func (o Order) Confirm() (Order, OrderConfirmed, error) {
    if o.status != OrderDraft {
        return Order{}, OrderConfirmed{}, ErrAlreadyProcessed
    }
    if len(o.items) == 0 {
        return Order{}, OrderConfirmed{}, ErrEmptyOrder
    }

    confirmed := Order{
        id:     o.id,
        items:  o.items,
        status: OrderConfirmed,
    }

    event := OrderConfirmed{
        OrderId:     o.id,
        ConfirmedAt: time.Now(),
        ItemCount:   len(o.items),
    }

    return confirmed, event, nil
}

// Getters — no setters
func (o Order) ID() OrderId        { return o.id }
func (o Order) Items() []OrderItem { return o.items }
func (o Order) Status() OrderStatus { return o.status }
```

**Rules:**
- All fields unexported
- Methods return new state — never mutate the receiver
- Business invariants enforced here, not in application service
- Domain events produced alongside state transitions

---

## Error Handling

### Sentinel Errors

```go
var (
    ErrEmptyOrderId    = errors.New("order id cannot be empty")
    ErrEmptyOrder      = errors.New("cannot confirm order with no items")
    ErrAlreadyProcessed = errors.New("order is already processed")
    ErrNegativeAmount  = errors.New("amount cannot be negative")
    ErrCurrencyMismatch = errors.New("currency mismatch")
    ErrInvalidCurrency = errors.New("invalid currency")
    ErrEmptyCustomerId = errors.New("customer id cannot be empty")
)
```

### Custom Error Types

```go
type ValidationError struct {
    Field   string
    Message string
}

func (e ValidationError) Error() string {
    return fmt.Sprintf("validation error on %s: %s", e.Field, e.Message)
}
```

### Error Wrapping

```go
// ✅ Wrap with context using %w
func (r *PostgresOrderRepo) FindById(ctx context.Context, id OrderId) (Order, error) {
    row := r.db.QueryRowContext(ctx, "SELECT ... WHERE id = $1", string(id))
    if err := row.Scan(&...); err != nil {
        if errors.Is(err, sql.ErrNoRows) {
            return Order{}, fmt.Errorf("order %s: %w", id, ErrNotFound)
        }
        return Order{}, fmt.Errorf("querying order %s: %w", id, err)
    }
    return order, nil
}

// ✅ Check with errors.Is / errors.As
if errors.Is(err, ErrNotFound) { ... }
```

---

## Repository Pattern

### Domain Interface (in `internal/domain/order/repository.go`)

```go
type OrderRepository interface {
    FindById(ctx context.Context, id OrderId) (Order, error)
    Save(ctx context.Context, order Order) error
    FindByCustomer(ctx context.Context, customerId CustomerId) ([]Order, error)
}
```

### Infrastructure Implementation (in `internal/infrastructure/postgres/order_repo.go`)

```go
type PostgresOrderRepo struct {
    db *sql.DB
}

func NewPostgresOrderRepo(db *sql.DB) *PostgresOrderRepo {
    return &PostgresOrderRepo{db: db}
}

func (r *PostgresOrderRepo) FindById(ctx context.Context, id OrderId) (Order, error) {
    // SQL query, scan, map to domain type
    ...
}

func (r *PostgresOrderRepo) Save(ctx context.Context, order Order) error {
    // Upsert logic
    ...
}
```

**Rules:**
- Interface defined in domain — implementation in infrastructure
- Domain never imports infrastructure packages
- Repository methods accept `context.Context` as first parameter

---

## Application Service / Use Case

Thin orchestration layer — no business logic.

```go
type ConfirmOrderUseCase struct {
    repo      order.OrderRepository
    publisher EventPublisher
}

func NewConfirmOrderUseCase(repo order.OrderRepository, pub EventPublisher) *ConfirmOrderUseCase {
    return &ConfirmOrderUseCase{repo: repo, publisher: pub}
}

func (uc *ConfirmOrderUseCase) Execute(ctx context.Context, orderId order.OrderId) error {
    // 1. Load
    o, err := uc.repo.FindById(ctx, orderId)
    if err != nil {
        return fmt.Errorf("loading order: %w", err)
    }

    // 2. Domain logic (delegated to aggregate)
    confirmed, event, err := o.Confirm()
    if err != nil {
        return fmt.Errorf("confirming order: %w", err)
    }

    // 3. Persist
    if err := uc.repo.Save(ctx, confirmed); err != nil {
        return fmt.Errorf("saving order: %w", err)
    }

    // 4. Publish event
    if err := uc.publisher.Publish(ctx, event); err != nil {
        return fmt.Errorf("publishing event: %w", err)
    }

    return nil
}
```

**Rules:**
- No `if/else` business logic — delegate to the aggregate
- Load → call domain method → persist → publish
- Error wrapping at each step for debuggability

---

## Testing

### Pure Domain Tests

```go
func TestOrder_Confirm_HappyPath(t *testing.T) {
    order := newDraftOrderWithItems(2)

    confirmed, event, err := order.Confirm()

    if err != nil {
        t.Fatalf("expected no error, got %v", err)
    }
    if confirmed.Status() != OrderConfirmed {
        t.Errorf("expected status Confirmed, got %v", confirmed.Status())
    }
    if event.ItemCount != 2 {
        t.Errorf("expected 2 items in event, got %d", event.ItemCount)
    }
}
```

### Table-Driven Tests

```go
func TestMoney_Add(t *testing.T) {
    tests := []struct {
        name    string
        a       Money
        b       Money
        want    int64
        wantErr error
    }{
        {
            name:    "same currency adds correctly",
            a:       mustMoney(100, USD),
            b:       mustMoney(250, USD),
            want:    350,
            wantErr: nil,
        },
        {
            name:    "different currencies returns error",
            a:       mustMoney(100, USD),
            b:       mustMoney(250, EUR),
            want:    0,
            wantErr: ErrCurrencyMismatch,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := tt.a.Add(tt.b)
            if tt.wantErr != nil {
                if !errors.Is(err, tt.wantErr) {
                    t.Errorf("expected error %v, got %v", tt.wantErr, err)
                }
                return
            }
            if err != nil {
                t.Fatalf("unexpected error: %v", err)
            }
            if got.Cents() != tt.want {
                t.Errorf("expected %d cents, got %d", tt.want, got.Cents())
            }
        })
    }
}

// Test helper — panics are OK in test helpers
func mustMoney(cents int64, currency Currency) Money {
    m, err := NewMoney(cents, currency)
    if err != nil {
        panic(err)
    }
    return m
}
```

---

## FP Conventions for Go

| Convention | Rule |
|-----------|------|
| Immutability | Return new values from methods — never mutate receivers |
| No panics | Constructors and methods return `(T, error)` — reserve `panic` for test helpers only |
| Context propagation | `context.Context` is always the first parameter for I/O functions |
| No global state | No package-level `var` for mutable state — pass dependencies via constructor |
| Interfaces at consumer | Define interfaces where they are used, not where they are implemented |
| Errors as values | Use `error` return — never panic for expected failure cases |
| Safe zero values | Design structs so the zero value is either safe to use or obviously invalid |
| No init() side effects | `init()` may set constants but must not perform I/O or mutate global state |

---

## Build & Test

```yaml
build: go build ./...
test: go test ./... -race -count=1
lint: golangci-lint run
format: gofmt -w .
coverage: go test ./... -coverprofile=coverage.out && go tool cover -func=coverage.out
coverage_threshold: 75%
```

**CI pipeline steps:**
1. `go fmt ./...` — check formatting
2. `golangci-lint run` — static analysis
3. `go test ./... -race -count=1` — tests with race detector
4. `go test ./... -coverprofile=coverage.out` — coverage report
5. `go build ./...` — verify build succeeds
