# Example ADR — ADR-007: Order Confirmation via Domain Event

This is a completed example ADR for reference. Use this as a model when writing new ADRs.

---

# ADR-007: Order Confirmation via Domain Event

**Date:** 2026-01-10
**Status:** Accepted
**Deciders:** architect + human review

## Context
The order service currently calls the notification service directly over HTTP when an order
is confirmed. This creates tight coupling: when the notification service is down, order
confirmation fails — even though notification is not essential to the confirmation itself.

We have experienced three production incidents in 6 months where notification downtime
cascaded into order confirmation failures. The order-management bounded context should not
depend on the notification context for its core operation.

## Domain Model

- **Aggregates involved:** Order (modified — adds confirm() method)
- **Domain events:** OrderConfirmed { orderId, customerId, confirmedAt, items }
- **Value objects introduced:** ConfirmedItem { itemId, quantity, unitPrice }
- **Ubiquitous language additions:** none — all terms already established

## Decision
Decouple order confirmation from notification by publishing an `OrderConfirmed` domain event
to Kafka. The notification service will consume this event asynchronously. Order confirmation
succeeds regardless of notification service availability.

## Options Considered

| Option | Pros | Cons | FP/DDD alignment |
|--------|------|------|-------------------|
| A: Domain event via Kafka | Decoupled, resilient, auditable event log | Adds Kafka dependency, eventual consistency for notifications | ✅ Events as facts, bounded context isolation |
| B: Async HTTP with retry | Simpler infrastructure, no new dependency | Still coupled (retries can fail), no event log, harder to add consumers | ❌ Still couples contexts |
| C: Outbox pattern + polling | No Kafka needed, uses existing DB | More complex, polling latency, harder to scale consumers | ✅ Good DDD alignment but over-engineered for current scale |

**Chosen: Option A** — Kafka event provides clean decoupling, an auditable event log, and
easy addition of future consumers (analytics, fulfillment). The team already operates Kafka
for other services.

## Consequences

- **Easier:** Adding new consumers of order confirmations (analytics, fulfillment, loyalty)
- **Easier:** Notification failures no longer affect order confirmation
- **Harder:** Debugging notification timing (async, not immediate)
- **Tech debt accepted:** None — this is a clean improvement
- **Must do next:** Implement Kafka publisher in infrastructure layer, update notification service to consume

## Contracts

### Domain Events

```
OrderConfirmed {
  orderId: OrderId        // UUID
  customerId: CustomerId  // UUID
  confirmedAt: Timestamp  // ISO 8601
  items: List[ConfirmedItem]
}

ConfirmedItem {
  itemId: ItemId          // UUID
  quantity: Int           // positive
  unitPrice: Money        // cents + currency
}
```

**Topic:** `order.events`
**Partitioning:** by `orderId`

### Schema Changes
- `order_events` table — add `event_type` column (VARCHAR) — reversible: yes (ALTER TABLE DROP COLUMN)

### API
No API changes — confirmation endpoint stays the same. The difference is internal:
instead of calling notification HTTP, we publish to Kafka.
