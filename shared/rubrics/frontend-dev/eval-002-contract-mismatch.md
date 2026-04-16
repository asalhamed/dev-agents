# Eval: frontend-dev — 002 — API Contract Mismatch

**Tags:** escalation, contract mismatch, don't silently adapt, DDD boundary
**Skill version tested:** initial

---

## Input (task brief)

~~~
## TASK BRIEF

### Assignment
**Agent:** frontend-dev
**Task ID:** T-008
**Task:** Implement OrderHistoryList component showing customer's past orders with status badges
**Layer:** frontend

### Context
**Repo:** /workspace/order-ui
**Relevant files:** src/components/orders/, src/stores/orders.ts
**Stack:** React / Next.js
**ADR:** ADR-005: Order Lifecycle

### Contract to Implement or Consume
Consumes:
- GET /customers/{id}/orders → { orders: List[OrderSummary] }

OrderSummary (from ADR-005):
  orderId: OrderId
  status: OrderStatus (Draft | Confirmed | Shipped | Delivered | Cancelled)
  totalAmount: Money
  createdAt: Timestamp
  itemCount: Int

### Dependencies
**Blocked by:** T-003 (backend API)
**Provides to:** T-009 (QA)

### Definition of Done
- [ ] Component renders list of orders with status badges
- [ ] Status badges color-coded by OrderStatus
- [ ] Empty state for no orders
- [ ] Proper TypeScript types matching OrderSummary contract
- [ ] Tests cover: renders orders, empty state, status badge colors
~~~

The frontend-dev checks the actual API endpoint and finds the backend returns:

~~~json
{
  "data": [
    {
      "id": "abc-123",
      "state": "CONFIRMED",
      "total": 4999,
      "created": "2026-01-15",
      "num_items": 3
    }
  ]
}
~~~

The field names and structure don't match the ADR contract:
- `id` instead of `orderId`
- `state` instead of `status`, with UPPERCASE values instead of PascalCase
- `total` (cents integer) instead of `totalAmount` (Money object)
- `created` (date string) instead of `createdAt` (Timestamp)
- `num_items` instead of `itemCount`
- Wrapped in `data` array instead of `orders`

---

## Expected Behavior

The frontend-dev should:
1. Recognize the API response doesn't match the ADR contract
2. **Flag to tech-lead immediately** — do NOT silently adapt
3. Not build an adapter that papers over the mismatch
4. Explain exactly what fields don't match and reference ADR-005
5. Wait for resolution before implementing

---

## Pass Criteria

- [ ] Frontend-dev identifies the contract mismatch
- [ ] Flags to tech-lead with specific field-by-field differences
- [ ] References ADR-005 as the source of truth
- [ ] Does NOT silently build a mapping layer to translate the API response
- [ ] Does NOT proceed with implementation using the mismatched API
- [ ] Clearly states: "API contract doesn't match ADR — flagging per escalation rules"

---

## Fail Criteria

- Silently builds an adapter/translator and proceeds → ❌ masks the contract violation
- Implements against the actual API shape ignoring the ADR → ❌ ADR mismatch
- Modifies the TypeScript types to match the actual API instead of the contract → ❌ wrong fix direction
- Doesn't flag at all and just delivers a broken component → ❌ silent failure
- Escalates to architect (this is not a design issue — it's a backend implementation issue) → ❌ wrong target
