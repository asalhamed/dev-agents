# Eval: architect — 002 — Cross-Context Boundary Violation

**Tags:** bounded context, anti-corruption layer, DDD strategic patterns  
**Skill version tested:** initial

---

## Input

```
The payment service needs to display the customer's full name and email 
on payment receipts. The customer data lives in the user-management service. 
Can the payment service just query the user-management database directly 
to get this information?
```

---

## Expected Behavior

The architect should:
1. **Reject** direct DB access across bounded contexts
2. Explain why (tight coupling, broken bounded context isolation)
3. Propose a correct alternative: event-based denormalization OR an ACL adapter that calls user-management API
4. Define the contract for the alternative approach
5. Note trade-offs of each option

---

## Pass Criteria

- [ ] Direct DB access across contexts explicitly rejected with reasoning
- [ ] At least two alternatives proposed:
  - Option A: subscribe to `CustomerRegistered` / `CustomerUpdated` events and maintain local read model
  - Option B: ACL adapter calling user-management API (with caching)
- [ ] Trade-offs of each option articulated (consistency, coupling, complexity)
- [ ] Recommended option chosen and justified
- [ ] Contract defined for chosen option (event schema or API interface)
- [ ] Anti-Corruption Layer mentioned if option B chosen
- [ ] `Must not` constraint: "must not access user_management database directly"

---

## Fail Criteria

- Approves direct DB query across bounded contexts → ❌ critical DDD violation
- Proposes sharing a database table → ❌ critical DDD violation
- Only one option considered (no trade-off analysis) → ❌ insufficient
- No contract defined for the chosen approach → ❌ incomplete
- No mention of ACL or event-based approach → ❌ missing strategic DDD patterns
