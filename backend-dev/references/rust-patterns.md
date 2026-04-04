# Rust Backend Patterns

Reference guide for backend-dev when working on Rust projects.

## Project Structure (DDD-aligned)

```
src/
├── domain/
│   ├── mod.rs
│   ├── order/
│   │   ├── mod.rs
│   │   ├── aggregate.rs      # Order aggregate root
│   │   ├── events.rs         # OrderPlaced, OrderConfirmed, etc.
│   │   ├── errors.rs         # OrderError enum
│   │   └── value_objects.rs  # OrderId, OrderItem, etc.
│   └── user/
│       └── ...
├── application/
│   ├── mod.rs
│   └── order/
│       ├── create_order.rs   # CreateOrderUseCase
│       └── confirm_order.rs  # ConfirmOrderUseCase
├── infrastructure/
│   ├── persistence/
│   │   ├── postgres_order_repo.rs
│   │   └── schema.rs
│   ├── messaging/
│   │   └── kafka_event_publisher.rs
│   └── http/
│       └── order_routes.rs
└── main.rs
```

## Error Handling

```rust
// domain/order/errors.rs
use thiserror::Error;

#[derive(Debug, Error, Clone, PartialEq)]
pub enum OrderError {
    #[error("Cannot modify order in status: {status}")]
    InvalidStatusTransition { status: String },

    #[error("Order must have at least one item")]
    EmptyOrder,

    #[error("Item {item_id} is not available")]
    ItemNotAvailable { item_id: ItemId },
}

// application layer — aggregate with anyhow for context
pub async fn confirm_order(
    id: OrderId,
    repo: &dyn OrderRepository,
) -> anyhow::Result<Order> {
    let order = repo.find_by_id(id).await?
        .ok_or_else(|| anyhow::anyhow!("Order {id} not found"))?;
    order.confirm().map_err(|e| anyhow::anyhow!("Confirm failed: {e}"))
}
```

## Newtype / Value Objects

```rust
use uuid::Uuid;
use std::fmt;

// ✅ Newtype — domain primitive with no leaking
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct OrderId(Uuid);

impl OrderId {
    pub fn new() -> Self { Self(Uuid::new_v4()) }
    pub fn inner(&self) -> Uuid { self.0 }
}

impl fmt::Display for OrderId {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result { write!(f, "{}", self.0) }
}

// ✅ Self-validating value object
#[derive(Debug, Clone, PartialEq)]
pub struct Email(String);

impl TryFrom<String> for Email {
    type Error = ValidationError;
    fn try_from(s: String) -> Result<Self, Self::Error> {
        if s.contains('@') && s.len() > 3 {
            Ok(Email(s))
        } else {
            Err(ValidationError::InvalidEmail(s))
        }
    }
}
```

## Aggregate Pattern

```rust
// ✅ Aggregate with pure mutation (returns new state)
#[derive(Debug, Clone)]
pub struct Order {
    pub id: OrderId,
    pub items: Vec<OrderItem>,
    pub status: OrderStatus,
    pub customer_id: CustomerId,
}

impl Order {
    pub fn new(id: OrderId, customer_id: CustomerId) -> Self {
        Self { id, items: vec![], status: OrderStatus::Draft, customer_id }
    }

    // Pure — returns Result<NewState, Error> — never mutates self
    pub fn add_item(self, item: OrderItem) -> Result<Self, OrderError> {
        match self.status {
            OrderStatus::Draft => Ok(Self { items: [self.items, vec![item]].concat(), ..self }),
            _ => Err(OrderError::InvalidStatusTransition { status: format!("{:?}", self.status) }),
        }
    }

    pub fn confirm(self) -> Result<Self, OrderError> {
        match (&self.status, self.items.is_empty()) {
            (OrderStatus::Draft, false) => Ok(Self { status: OrderStatus::Confirmed, ..self }),
            (OrderStatus::Draft, true) => Err(OrderError::EmptyOrder),
            _ => Err(OrderError::InvalidStatusTransition { status: format!("{:?}", self.status) }),
        }
    }
}
```

## Repository Trait

```rust
// ✅ Domain owns the interface — infrastructure implements it
#[async_trait::async_trait]
pub trait OrderRepository: Send + Sync {
    async fn find_by_id(&self, id: OrderId) -> Result<Option<Order>, RepositoryError>;
    async fn save(&self, order: &Order) -> Result<(), RepositoryError>;
    async fn find_by_customer(&self, customer_id: CustomerId) -> Result<Vec<Order>, RepositoryError>;
}

// ✅ In-memory implementation for tests
pub struct InMemoryOrderRepository {
    store: Arc<Mutex<HashMap<OrderId, Order>>>,
}

#[async_trait::async_trait]
impl OrderRepository for InMemoryOrderRepository {
    async fn find_by_id(&self, id: OrderId) -> Result<Option<Order>, RepositoryError> {
        Ok(self.store.lock().unwrap().get(&id).cloned())
    }
    async fn save(&self, order: &Order) -> Result<(), RepositoryError> {
        self.store.lock().unwrap().insert(order.id, order.clone());
        Ok(())
    }
    async fn find_by_customer(&self, customer_id: CustomerId) -> Result<Vec<Order>, RepositoryError> {
        Ok(self.store.lock().unwrap().values()
            .filter(|o| o.customer_id == customer_id)
            .cloned().collect())
    }
}
```

## Domain Events

```rust
// ✅ Immutable facts — past tense, all data needed to reconstruct what happened
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum OrderEvent {
    OrderPlaced {
        order_id: OrderId,
        customer_id: CustomerId,
        items: Vec<OrderItem>,
        occurred_at: DateTime<Utc>,
    },
    OrderConfirmed {
        order_id: OrderId,
        confirmed_at: DateTime<Utc>,
    },
    OrderCancelled {
        order_id: OrderId,
        reason: CancellationReason,
        cancelled_at: DateTime<Utc>,
    },
}
```

## Testing Patterns

```rust
#[cfg(test)]
mod tests {
    use super::*;

    // ✅ Pure domain test — no mocks needed
    #[test]
    fn order_cannot_be_confirmed_when_empty() {
        let order = Order::new(OrderId::new(), CustomerId::new());
        let result = order.confirm();
        assert!(matches!(result, Err(OrderError::EmptyOrder)));
    }

    #[test]
    fn order_can_be_confirmed_with_items() {
        let item = OrderItem::new(ItemId::new(), Quantity::try_from(1).unwrap());
        let order = Order::new(OrderId::new(), CustomerId::new())
            .add_item(item)
            .unwrap();
        let confirmed = order.confirm();
        assert!(confirmed.is_ok());
        assert_eq!(confirmed.unwrap().status, OrderStatus::Confirmed);
    }

    // ✅ Application test with in-memory repo
    #[tokio::test]
    async fn create_order_persists_to_repo() {
        let repo = Arc::new(InMemoryOrderRepository::default());
        let order_id = create_order(CustomerId::new(), repo.clone()).await.unwrap();
        let found = repo.find_by_id(order_id).await.unwrap();
        assert!(found.is_some());
    }
}
```

## Async Patterns

```rust
// ✅ Tokio runtime, async traits via async_trait
use tokio::sync::RwLock;

// ✅ Prefer Arc<dyn Trait> for shared services
pub struct AppState {
    pub order_repo: Arc<dyn OrderRepository>,
    pub event_publisher: Arc<dyn EventPublisher>,
}

// ✅ No blocking calls in async context
// Bad:  std::thread::sleep — blocks the thread
// Good: tokio::time::sleep — yields the task
```
