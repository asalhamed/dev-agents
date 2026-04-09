# Leptos Frontend Patterns

Reference guide for Rust/Leptos/WASM frontend development with functional programming conventions.

---

## Project Structure

```
project-root/
├── src/
│   ├── app.rs                # Root App component, router setup
│   ├── components/
│   │   ├── order_summary.rs  # Presentational — pure rendering
│   │   ├── order_page.rs     # Container — data + state management
│   │   ├── item_row.rs       # Presentational — single item display
│   │   └── error_display.rs  # Reusable error boundary fallback
│   ├── domain/
│   │   ├── order.rs          # Order, OrderStatus, OrderItem types
│   │   └── money.rs          # Money, Currency (client-side mirror)
│   ├── services/
│   │   └── order_api.rs      # #[server] functions — API layer
│   ├── stores/
│   │   └── order_store.rs    # Shared reactive state (if needed)
│   └── main.rs               # Mount point
├── Cargo.toml
├── Trunk.toml                # Trunk build config (CSR)
└── style/
    └── main.css
```

**Rules:**
- `components/` contains only rendering logic — no direct HTTP calls
- `domain/` mirrors backend domain types for the client — Serialize/Deserialize
- `services/` houses `#[server]` functions — the only place that talks to the backend
- `stores/` for shared reactive state across components (use sparingly)

---

## Reactive Primitives

### `create_signal` — Local Mutable State

```rust
use leptos::*;

#[component]
fn Counter() -> impl IntoView {
    // ReadSignal + WriteSignal pair
    let (count, set_count) = create_signal(0);

    view! {
        <p>"Count: " {move || count.get()}</p>
        <button on:click=move |_| set_count.update(|n| *n += 1)>
            "Increment"
        </button>
    }
}
```

### `create_memo` — Derived State (Pure)

```rust
#[component]
fn OrderTotal(order: ReadSignal<Order>) -> impl IntoView {
    // Pure computation — recalculates only when order changes
    let total = create_memo(move |_| {
        order.get().items.iter()
            .map(|item| item.price_cents * item.quantity as i64)
            .sum::<i64>()
    });

    view! {
        <p>"Total: $" {move || format!("{:.2}", total.get() as f64 / 100.0)}</p>
    }
}
```

### `create_resource` — Async Data Loading

```rust
#[component]
fn OrderLoader(order_id: String) -> impl IntoView {
    // Async resource — fetches data, tracks loading/error state
    let order = create_resource(
        move || order_id.clone(),
        |id| async move { get_order(id).await }
    );

    view! {
        <Suspense fallback=move || view! { <p>"Loading..."</p> }>
            {move || order.get().map(|result| match result {
                Ok(o) => view! { <OrderSummary order=o /> }.into_view(),
                Err(e) => view! { <p class="error">{e.to_string()}</p> }.into_view(),
            })}
        </Suspense>
    }
}
```

---

## Presentational Components — Pure

Presentational components take signals as props and render UI. No side effects, no data fetching.

```rust
#[component]
fn OrderSummary(order: ReadSignal<Order>) -> impl IntoView {
    // Pure derived state
    let total = create_memo(move |_| {
        order.get().items.iter()
            .map(|item| item.price_cents * item.quantity as i64)
            .sum::<i64>()
    });

    let item_count = create_memo(move |_| order.get().items.len());

    view! {
        <div class="order-summary">
            <h2>"Order #" {move || order.get().id}</h2>
            <p>{move || item_count.get()} " items"</p>

            <For
                each=move || order.get().items
                key=|item| item.id.clone()
                children=|item| view! {
                    <ItemRow item=item />
                }
            />

            <p class="total">
                "Total: $" {move || format!("{:.2}", total.get() as f64 / 100.0)}
            </p>
        </div>
    }
}

#[component]
fn ItemRow(item: OrderItem) -> impl IntoView {
    view! {
        <div class="item-row">
            <span class="name">{&item.product_name}</span>
            <span class="qty">"× " {item.quantity}</span>
            <span class="price">
                {format!("${:.2}", item.price_cents as f64 / 100.0)}
            </span>
        </div>
    }
}
```

**Rules:**
- Props are `ReadSignal<T>` or owned values — never `WriteSignal`
- All derived state via `create_memo` — never compute in the view macro
- No `#[server]` calls inside presentational components
- `For` component with `key` for efficient list rendering

---

## Container Components — Data + State

Container components load data, manage state, and compose presentational components.

```rust
#[component]
fn OrderPage(order_id: String) -> impl IntoView {
    let order_resource = create_resource(
        move || order_id.clone(),
        |id| async move { get_order(id).await }
    );

    view! {
        <div class="order-page">
            <Suspense fallback=move || view! { <p>"Loading order..."</p> }>
                <ErrorBoundary fallback=|errors| view! {
                    <div class="error-panel">
                        <p>"Failed to load order:"</p>
                        <ul>
                            {move || errors.get()
                                .into_iter()
                                .map(|(_, e)| view! { <li>{e.to_string()}</li> })
                                .collect_view()
                            }
                        </ul>
                    </div>
                }>
                    {move || order_resource.get().map(|result| match result {
                        Ok(order) => {
                            let (order_signal, _) = create_signal(order);
                            view! { <OrderSummary order=order_signal /> }.into_view()
                        }
                        Err(e) => view! { <p class="error">{e.to_string()}</p> }.into_view(),
                    })}
                </ErrorBoundary>
            </Suspense>
        </div>
    }
}
```

---

## Server Functions — API Layer

Server functions use the `#[server]` macro for typed RPC between client and server.

```rust
// ✅ Query — read-only, typed return
#[server(GetOrder)]
pub async fn get_order(order_id: String) -> Result<Order, ServerFnError> {
    let service = use_context::<OrderService>()
        .ok_or_else(|| ServerFnError::ServerError("OrderService not available".to_string()))?;

    let id = OrderId::try_from(order_id)
        .map_err(|e| ServerFnError::ServerError(e.to_string()))?;

    service.find_by_id(id).await
        .map_err(|e| ServerFnError::ServerError(e.to_string()))
}

// ✅ Command — mutating operation, typed input
#[server(ConfirmOrder)]
pub async fn confirm_order(order_id: String) -> Result<(), ServerFnError> {
    let service = use_context::<OrderService>()
        .ok_or_else(|| ServerFnError::ServerError("OrderService not available".to_string()))?;

    let id = OrderId::try_from(order_id)
        .map_err(|e| ServerFnError::ServerError(e.to_string()))?;

    service.confirm(id).await
        .map_err(|e| ServerFnError::ServerError(e.to_string()))
}
```

**Rules:**
- `use_context` for dependency injection — no global state
- All errors converted to `ServerFnError` — typed on the server, string on the client
- Commands and queries named after domain actions, not HTTP verbs
- No business logic in server functions — delegate to domain services

---

## Actions — Commands from UI

Use `create_server_action` for user-triggered commands with pending and error state.

```rust
#[component]
fn OrderConfirmButton(order: ReadSignal<Order>) -> impl IntoView {
    let confirm_action = create_server_action::<ConfirmOrder>();

    let is_pending = confirm_action.pending();
    let action_value = confirm_action.value();

    // Only show button for Draft orders
    let is_draft = create_memo(move |_| order.get().status == OrderStatus::Draft);

    view! {
        <Show when=move || is_draft.get()>
            <button
                on:click=move |_| {
                    confirm_action.dispatch(ConfirmOrder {
                        order_id: order.get().id.clone(),
                    });
                }
                disabled=move || is_pending.get()
            >
                {move || if is_pending.get() { "Confirming..." } else { "Confirm Order" }}
            </button>
        </Show>

        // Display error from action result
        {move || action_value.get().map(|result| match result {
            Err(e) => view! { <p class="error">{e.to_string()}</p> }.into_view(),
            Ok(_) => view! { <p class="success">"Order confirmed!"</p> }.into_view(),
        })}
    }
}
```

**Rules:**
- `pending()` signal for loading state — disable button, show spinner
- `value()` signal for result — display errors inline
- Dispatch from event handler, never from rendering logic

---

## Error Handling in Components

Use `ErrorBoundary` for graceful error display.

```rust
#[component]
fn SafeOrderPage(order_id: String) -> impl IntoView {
    view! {
        <ErrorBoundary fallback=|errors| view! {
            <div class="error-boundary">
                <h3>"Something went wrong"</h3>
                <ul>
                    {move || errors.get()
                        .into_iter()
                        .map(|(_, e)| view! { <li>{e.to_string()}</li> })
                        .collect_view()
                    }
                </ul>
                <button on:click=move |_| { /* retry logic */ }>
                    "Try Again"
                </button>
            </div>
        }>
            <OrderPage order_id=order_id />
        </ErrorBoundary>
    }
}
```

---

## Domain Types — Client-Side Mirror

Mirror backend domain types for serialization. These are data types, not business logic.

```rust
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
pub struct Order {
    pub id: String,
    pub customer_id: String,
    pub items: Vec<OrderItem>,
    pub status: OrderStatus,
}

#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
pub enum OrderStatus {
    Draft,
    Confirmed,
    Cancelled,
}

#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
pub struct OrderItem {
    pub id: String,
    pub product_name: String,
    pub price_cents: i64,
    pub quantity: u32,
}
```

**Required derives:** `Serialize`, `Deserialize`, `Clone`, `PartialEq`
- `Clone` — needed for signal reactivity
- `PartialEq` — needed for memo equality checks
- `Serialize/Deserialize` — needed for server function transport

---

## FP Conventions for Leptos

| Convention | Rule |
|-----------|------|
| Components are pure functions | `(props) → impl IntoView` — same props, same output |
| No DOM manipulation | Never use `web_sys` directly — use reactive primitives |
| `create_memo` for derived state | Pure computation from signals — no side effects |
| `create_effect` for side effects | Logging, local storage, analytics — clearly isolated |
| No `unwrap()` in components | Use `match`, `if let`, or `unwrap_or` — panics crash WASM |
| No `panic!` in components | Display errors gracefully — `ErrorBoundary` + result handling |
| Domain language in names | `OrderSummary`, not `DataPanel`; `confirm_order`, not `handleSubmit` |
| Unidirectional data flow | `Signal → memo → view → action → signal update` |

---

## Build & Test

```yaml
build_csr: trunk build
build_ssr: cargo leptos build
test_unit: cargo test
test_wasm: wasm-pack test --headless --chrome
lint: cargo clippy -- -D warnings
format: cargo fmt --check
```

**CI pipeline steps:**
1. `cargo fmt --check` — formatting
2. `cargo clippy -- -D warnings` — lint
3. `cargo test` — unit tests (server-side logic)
4. `wasm-pack test --headless --chrome` — WASM browser tests
5. `trunk build` (CSR) or `cargo leptos build` (SSR) — verify build
