# Eval: frontend-dev — 003 — Leptos Pure Component

**Tags:** Rust, Leptos, WASM, reactive primitives, server functions, FP
**Skill version tested:** initial

---

## Input (task brief)

The frontend-dev agent receives this task:

**Agent:** frontend-dev
**Task ID:** T-007
**Task:** Implement OrderSummary component displaying order details with confirm action
**Layer:** frontend
**Stack:** Leptos (Rust/WASM)
**ADR:** ADR-009: Monetary Values / ADR-007: Order Confirmation

### Contract to Implement

The component must:
- Accept a `ReadSignal<Order>` prop (not owned data, not global state)
- Display order items in a list using `For` component with `key`
- Compute total via `create_memo` (pure derived state)
- Confirm order via `create_server_action` (not direct HTTP call)
- Show "Confirm Order" button ONLY for `Draft` orders
- Display pending state when action is in-flight (disable button, show "Confirming...")
- Display error from action value if confirm fails
- No `unwrap()` in component code
- No `panic!()` in component code
- Component name must use domain language: `OrderSummary`

### Domain Types

```rust
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

#[server(ConfirmOrder)]
pub async fn confirm_order(order_id: String) -> Result<(), ServerFnError> {
    // Server-side implementation
}
```

### Definition of Done
- [ ] Component accepts `ReadSignal<Order>` as prop
- [ ] Total computed via `create_memo`
- [ ] Confirm uses `create_server_action`
- [ ] Pending state: button disabled + "Confirming..." text
- [ ] Error state: displayed from action value
- [ ] Button only visible for Draft orders
- [ ] No `unwrap()` or `panic!()` in component code
- [ ] `For` component with `key` for item list
- [ ] Component named `OrderSummary`
- [ ] Produce `implementation-summary` contract

---

## Expected Behavior

The frontend-dev agent should:
1. Read `references/leptos-patterns.md` for Leptos-specific patterns
2. Use reactive primitives: `ReadSignal`, `create_memo`, `create_server_action`
3. Build a pure presentational component — no direct HTTP calls
4. Handle all states: loading, error, success, and conditional button visibility
5. Use Rust error handling (match, if let) — no unwrap or panic

---

## Pass Criteria

- [ ] Component prop is `ReadSignal<Order>` — not owned `Order` or global state
- [ ] Total computed via `create_memo` — not inline calculation in view
- [ ] Confirm action via `create_server_action` — not direct `reqwest` or `fetch`
- [ ] Pending state: button shows "Confirming..." or equivalent and is disabled
- [ ] Error displayed from `action.value()` — not silently swallowed
- [ ] Confirm button only visible when `order.status == OrderStatus::Draft`
- [ ] No `unwrap()` in component code (test helpers are fine)
- [ ] No `panic!()` in component code
- [ ] Component is named `OrderSummary` (domain language)
- [ ] `For` component uses `key` for efficient list rendering
- [ ] `implementation-summary` contract produced with all required fields

---

## Fail Criteria

- Global state (lazy_static, thread_local, or module-level signal) → violates prop-based data flow
- Direct `reqwest::get` or `web_sys::fetch` in component → should use `create_server_action`
- `unwrap()` in component code → panics crash WASM silently
- `panic!()` in component code → crashes WASM silently
- Non-domain component name (e.g., "DataPanel", "OrderView123") → must be `OrderSummary`
- No pending state handling → users see no feedback during server call
- No error display → errors swallowed silently
- Missing `implementation-summary` contract → contract violation
