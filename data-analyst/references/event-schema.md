# Analytics Event Schema

Reference for defining, naming, and documenting analytics events.
Consistent event schemas enable reliable instrumentation and analysis.

---

## Naming Convention

Format: `object_action` — noun first, past-tense verb second.

| Rule | Good | Bad |
|------|------|-----|
| Noun first | `order_confirmed` | `confirmed_order` |
| Past tense | `preference_updated` | `update_preference` |
| Snake_case | `cart_item_added` | `cartItemAdded`, `CartItemAdded` |
| Specific noun | `notification_preference_updated` | `setting_changed` |
| No abbreviations | `checkout_completed` | `chk_done` |

### Common Verbs

| Verb | Meaning | Example |
|------|---------|---------|
| `viewed` | User saw something | `page_viewed`, `product_viewed` |
| `clicked` | User clicked an element | `button_clicked`, `link_clicked` |
| `created` | A resource was created | `order_created`, `account_created` |
| `updated` | A resource was modified | `preference_updated`, `profile_updated` |
| `completed` | A flow or task finished | `checkout_completed`, `onboarding_completed` |
| `failed` | An action did not succeed | `payment_failed`, `login_failed` |
| `activated` | A feature/mode was turned on | `pause_activated`, `trial_activated` |
| `deactivated` | A feature/mode was turned off | `pause_deactivated`, `trial_deactivated` |

---

## Standard Properties

Every event must include these properties. No exceptions.

| Property | Type | Description | Example |
|----------|------|-------------|---------|
| `eventName` | string | The event name in `object_action` format | `preference_updated` |
| `userId` | string | Pseudonymized user identifier | `usr_a1b2c3d4` |
| `sessionId` | string | Session identifier | `sess_x9y8z7` |
| `timestamp` | string (ISO 8601) | When the event occurred, UTC | `2024-03-15T14:32:00.000Z` |
| `source` | string | Which service/app emitted the event | `web-app`, `order-service`, `mobile-ios` |
| `eventVersion` | string (semver) | Schema version of this event | `1.0.0` |

### Optional Standard Properties

| Property | Type | Description |
|----------|------|-------------|
| `deviceType` | string | `desktop`, `mobile`, `tablet` |
| `pageUrl` | string | Current page URL (frontend events only) |
| `referrer` | string | Previous page or source |
| `experimentId` | string | A/B test identifier if applicable |
| `experimentVariant` | string | Which variant the user is in |

---

## Event Versioning

Schema changes are inevitable. Handle them without breaking downstream pipelines.

### Rules

1. **Additive changes are safe.** Adding a new optional property is backward-compatible. Bump the patch version: `1.0.0` → `1.0.1`.
2. **Changing a property type is breaking.** Changing `amount: number` to `amount: string` requires a new major version: `1.0.0` → `2.0.0`.
3. **Removing a property is breaking.** Deprecate first (mark as optional, stop relying on it), then remove in the next major version.
4. **Include `eventVersion` in every event** so consumers can handle multiple versions simultaneously.
5. **Document migration paths** when bumping major versions — which properties changed, how to map old → new.

### Version Lifecycle

```
v1.0.0 → v1.1.0 (add optional field)
       → v1.2.0 (add another optional field)
       → v2.0.0 (rename field, change type — BREAKING)
       
Consumers must support v1.x and v2.x during migration window.
```

---

## PII Handling

### Never Include in Events

- Full names
- Email addresses (use hashed identifier)
- Phone numbers
- IP addresses (log server-side only, don't send to analytics)
- Physical addresses
- Payment card numbers or tokens
- Government IDs

### Pseudonymization

- Use opaque, non-reversible user IDs: `usr_a1b2c3d4` not `john.doe@example.com`
- Hash sensitive values with a salt if you need them for analysis: `SHA256(email + salt)`
- Store the mapping (hash → real value) in a separate, access-controlled system
- Ensure pseudonymized IDs are consistent across events for the same user (joinable)

---

## Sample Event Catalog

### 1. `preference_page_viewed`

**Trigger:** User navigates to the notification preferences page.
**Producer:** `web-app` (frontend)

| Property | Type | Description |
|----------|------|-------------|
| `userId` | string | Pseudonymized user ID |
| `sessionId` | string | Session ID |
| `timestamp` | string | ISO 8601 |
| `source` | string | `web-app` |
| `eventVersion` | string | `1.0.0` |
| `currentPreferenceCount` | number | Number of currently active preferences |

### 2. `preference_updated`

**Trigger:** User toggles a notification channel on or off.
**Producer:** `notification-service` (backend)

| Property | Type | Description |
|----------|------|-------------|
| `userId` | string | Pseudonymized user ID |
| `sessionId` | string | Session ID |
| `timestamp` | string | ISO 8601 |
| `source` | string | `notification-service` |
| `eventVersion` | string | `1.0.0` |
| `category` | string | Notification category (e.g., `SecurityAlert`, `OrderUpdate`) |
| `channel` | string | `email`, `push`, or `sms` |
| `newState` | string | `enabled` or `disabled` |
| `previousState` | string | `enabled` or `disabled` |

### 3. `pause_activated`

**Trigger:** User enables the "pause all notifications" toggle.
**Producer:** `notification-service` (backend)

| Property | Type | Description |
|----------|------|-------------|
| `userId` | string | Pseudonymized user ID |
| `sessionId` | string | Session ID |
| `timestamp` | string | ISO 8601 |
| `source` | string | `notification-service` |
| `eventVersion` | string | `1.0.0` |
| `pauseDurationHours` | number | null if indefinite, otherwise duration in hours |

### 4. `order_confirmed`

**Trigger:** Customer confirms an order (status changes to Confirmed).
**Producer:** `order-service` (backend)

| Property | Type | Description |
|----------|------|-------------|
| `userId` | string | Pseudonymized user ID |
| `sessionId` | string | Session ID |
| `timestamp` | string | ISO 8601 |
| `source` | string | `order-service` |
| `eventVersion` | string | `1.0.0` |
| `orderId` | string | Order identifier |
| `itemCount` | number | Number of items in the order |
| `totalAmount` | number | Order total in smallest currency unit (cents) |
| `currency` | string | ISO 4217 currency code |

### 5. `checkout_completed`

**Trigger:** User completes the checkout flow (payment processed).
**Producer:** `checkout-service` (backend)

| Property | Type | Description |
|----------|------|-------------|
| `userId` | string | Pseudonymized user ID |
| `sessionId` | string | Session ID |
| `timestamp` | string | ISO 8601 |
| `source` | string | `checkout-service` |
| `eventVersion` | string | `1.0.0` |
| `orderId` | string | Order identifier |
| `paymentMethod` | string | `credit_card`, `bank_transfer`, `stored_method` |
| `checkoutDurationSeconds` | number | Time from cart to payment confirmation |
| `stepCount` | number | Number of checkout steps completed |
