# User Story Format

Reference for writing high-quality user stories that are decomposable, testable, and
expressed in domain language.

---

## INVEST Criteria

Every story must pass all six criteria before entering a sprint.

| Letter | Criterion | Definition | ✅ Pass | ❌ Fail |
|--------|-----------|-----------|---------|---------|
| **I** | Independent | Can be developed, tested, and delivered without depending on another story | "As a customer, I want to view my order history" | "As a customer, I want to view order details" (requires order list story first) |
| **N** | Negotiable | Details can be discussed — the story is not a contract | Story with acceptance criteria that the team can refine | A 3-page specification disguised as a story |
| **V** | Valuable | Delivers value to a user or stakeholder | "As a customer, I want to filter orders by status so I can find pending orders quickly" | "As a developer, I want to refactor the DAO layer" |
| **E** | Estimable | Team can estimate the effort required | Clear scope: one endpoint, one UI component, known data model | "Integrate with the payment provider" (which one? what flows?) |
| **S** | Small | Completable within one sprint (ideally 1-3 days) | "As a customer, I want to cancel a draft order" | "As a customer, I want to manage all my orders" (epic) |
| **T** | Testable | Has clear acceptance criteria that can be verified | Given/When/Then criteria defined | "The system should be user-friendly" |

---

## Story Format

```
As a [role],
I want [goal],
so that [benefit].
```

### Guidance

- **Role** — a real user role from your domain, not "user" or "admin" generically. Use personas if available.
- **Goal** — what the user wants to accomplish, in their language. Not technical ("call the API").
- **Benefit** — why this matters. Forces you to justify the story's existence.

### Common Mistakes

| Mistake | Example | Fix |
|---------|---------|-----|
| Technical story | "As a developer, I want to add an index to the orders table" | Not a user story — it's a technical task. Attach to the story it enables. |
| Missing benefit | "As a customer, I want to see my order status" | Add "so that": "...so that I know when to expect delivery" |
| Actor is the system | "As the system, I want to send a notification" | Reframe: "As a customer, I want to receive a notification when my order ships" |
| Solution in the story | "As a customer, I want a dropdown to filter by status" | Keep it solution-agnostic: "I want to filter orders by status" |

---

## Acceptance Criteria (Given/When/Then)

Every story must have at least one acceptance criterion in Given/When/Then format.

```
Given [precondition],
When [action],
Then [expected result].
```

**Example:**
```
Story: As a customer, I want to cancel a draft order so that I'm not charged.

AC-1: Given an order in Draft status,
      When the customer requests cancellation,
      Then the order status changes to Cancelled
      And an OrderCancelled event is published.

AC-2: Given an order in Shipped status,
      When the customer requests cancellation,
      Then the request is rejected with reason "Cannot cancel shipped order."
```

---

## Story Splitting Patterns

When a story is too large (fails the S in INVEST), split it using these patterns.

### By Workflow Step

**Before (epic):** "As a customer, I want to complete checkout"

**After (split):**
1. "As a customer, I want to review my cart before paying"
2. "As a customer, I want to enter shipping details"
3. "As a customer, I want to confirm and pay for my order"

### By Business Rule

**Before (epic):** "As a customer, I want to manage notification preferences"

**After (split):**
1. "As a customer, I want to toggle email notifications per category"
2. "As a customer, I want to toggle push notifications per category"
3. "As a customer, I want the system to enforce at least one channel for SecurityAlerts"

### By Data Variation

**Before (epic):** "As a customer, I want to pay for my order"

**After (split):**
1. "As a customer, I want to pay with a credit card"
2. "As a customer, I want to pay with a bank transfer"
3. "As a customer, I want to pay with a stored payment method"

### By Happy/Unhappy Path

**Before (mixed):** "As a customer, I want to apply a discount code"

**After (split):**
1. "As a customer, I want to apply a valid discount code so that my total is reduced" (happy path)
2. "As a customer, I want to see an error when I enter an expired discount code" (unhappy path)
3. "As a customer, I want to see an error when the code doesn't apply to my items" (unhappy path)

---

## Anti-Patterns

| Anti-Pattern | Symptom | Fix |
|-------------|---------|-----|
| **Epic disguised as story** | Estimated at 13+ points; has 10+ acceptance criteria | Split using patterns above |
| **Too technical** | "Implement a REST endpoint for..." | Rewrite from user perspective |
| **No acceptance criteria** | "Users should be able to manage orders" | Add Given/When/Then for each behavior |
| **God story** | "As a customer, I want the new notification system" | Decompose into individual behaviors |
| **Copy-paste criteria** | Same AC on every story: "system is fast" | Remove; put NFRs in a separate quality attribute document |
