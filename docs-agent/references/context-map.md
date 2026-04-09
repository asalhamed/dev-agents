# Bounded Context Map

Reference for documenting how bounded contexts relate to each other.
A context map is a strategic DDD artifact that makes integration patterns explicit.

---

## What It Shows

A bounded context map visualizes:
- All bounded contexts in the system
- The relationships between them (who depends on whom)
- The integration pattern used at each boundary
- The direction of influence (upstream → downstream)

It does NOT show internal details of each context — just boundaries and connections.

---

## Relationship Patterns

### Shared Kernel

Two contexts share a small subset of domain model code. Changes require coordination.

```
┌───────────┐     ┌───────────┐
│  Context A │─SK──│  Context B │
└───────────┘     └───────────┘
```

**Use when:** Two teams are tightly aligned and share core domain concepts (e.g., Money value object).
**Risk:** Tight coupling — changes in the shared kernel affect both contexts.

### Customer-Supplier (Upstream/Downstream)

Upstream context provides data/services; downstream context consumes them. Upstream accommodates downstream's needs.

```
┌───────────┐         ┌───────────┐
│  Upstream  │──U/D──→│ Downstream │
│ (Supplier) │         │ (Customer) │
└───────────┘         └───────────┘
```

**Use when:** The upstream team is willing to prioritize downstream needs.

### Conformist

Downstream adopts the upstream model as-is, without translation. The upstream team has no obligation to accommodate.

```
┌───────────┐          ┌───────────┐
│  Upstream  │──CF───→│ Downstream │
└───────────┘          └───────────┘
```

**Use when:** Upstream is a large system or third-party API you can't influence (e.g., Stripe's model).

### Anti-Corruption Layer (ACL)

Downstream translates the upstream model into its own domain language via an adapter.

```
┌───────────┐         ┌─────┐  ┌───────────┐
│  Upstream  │────────→│ ACL │──│ Downstream │
└───────────┘         └─────┘  └───────────┘
```

**Use when:** Upstream model doesn't fit your domain and you want to protect your model from external pollution.

### Open Host Service / Published Language (OHS/PL)

Upstream exposes a well-defined, versioned API (the "open host") using a shared data format (the "published language" — e.g., JSON, Protobuf, OpenAPI spec).

```
┌───────────┐
│  Upstream  │──OHS/PL──→ (multiple downstream consumers)
└───────────┘
```

**Use when:** Multiple consumers need your data. Publish a stable API contract instead of ad-hoc integrations.

### Separate Ways

Two contexts have no integration. They are independent.

```
┌───────────┐         ┌───────────┐
│  Context A │         │  Context B │
└───────────┘         └───────────┘
```

**Use when:** Contexts have no shared data or workflows. Integration cost > benefit.

---

## When to Use Each

| Pattern | Use When | Team Dynamics |
|---------|----------|---------------|
| **Shared Kernel** | Tight collaboration, shared core concept | Same team or very close teams |
| **Customer-Supplier** | Upstream willing to support downstream | Cooperative teams, upstream has capacity |
| **Conformist** | Can't change upstream; their model is acceptable | Third-party API, large legacy system |
| **ACL** | Can't change upstream; their model pollutes yours | Third-party API with mismatched domain model |
| **OHS/PL** | Many consumers need your data | Platform/infrastructure team serving others |
| **Separate Ways** | No shared workflows or data | Independent teams, no integration needed |

---

## Simple Box Notation

Use boxes for contexts, labeled arrows for relationships:

```
┌─────────────────┐                    ┌─────────────────┐
│                 │                    │                 │
│   Context Name  │───relationship───→│   Context Name  │
│                 │                    │                 │
└─────────────────┘                    └─────────────────┘
```

Arrow direction: upstream → downstream (data/influence flows with the arrow).

Abbreviations on arrows:
- `SK` — Shared Kernel
- `U/D` — Customer-Supplier (Upstream/Downstream)
- `CF` — Conformist
- `ACL` — Anti-Corruption Layer
- `OHS/PL` — Open Host Service / Published Language
- `SW` — Separate Ways (no arrow — just separate boxes)

---

## Example: E-Commerce Context Map

```
                        ┌──────────────────────┐
                        │                      │
                        │   Order Management   │
                        │                      │
                        └──┬──────┬─────────┬──┘
                           │      │         │
                    U/D    │      │ U/D     │  OHS/PL (OrderPlaced,
                           │      │         │   OrderConfirmed events)
                           ▼      ▼         ▼
              ┌────────────────┐  │  ┌──────────────────┐
              │                │  │  │                  │
              │   Billing      │  │  │  Notification    │
              │                │  │  │                  │
              └───────┬────────┘  │  └──────────────────┘
                      │           │
                  ACL │           │ U/D
                      ▼           ▼
              ┌────────────────┐  ┌──────────────────┐
              │                │  │                  │
              │  Stripe (ext)  │  │   Inventory      │
              │                │  │                  │
              └────────────────┘  └──────────────────┘
```

### Relationships Explained

| From | To | Pattern | Rationale |
|------|----|---------|-----------|
| Order Management | Inventory | Customer-Supplier (U/D) | Order context needs stock checks; inventory team accommodates |
| Order Management | Billing | Customer-Supplier (U/D) | Order triggers billing; billing team supports order needs |
| Order Management | Notification | OHS/PL | Order publishes domain events; notification subscribes to them |
| Billing | Stripe | ACL | Stripe has its own model (charges, intents); billing translates to its Payment model |
| Notification | Inventory | Separate Ways | No direct integration needed |

### Key Observations

- **Order Management** is the upstream hub — most contexts depend on its events
- **Stripe** is an external system — always use ACL to prevent its model from leaking
- **Notification** is a pure consumer — subscribes to events, doesn't produce data others need
- **Inventory** and **Notification** have no relationship — Separate Ways
