# Eval: ui-designer — 002 — Order History List

**Tags:** list states, status badges, empty state, loading, responsive, a11y
**Skill version tested:** initial

---

## Input (task brief)

```
Design an order history list with status badges (Draft, Confirmed, Shipped, Cancelled).
Include empty, loading, and error states.
```

---

## Expected Behavior

The ui-designer should:
1. Design status badges using text + color (not color alone for accessibility)
2. Define all list states: populated, empty, loading, error
3. Design loading skeletons matching the list layout
4. Include error state with retry action
5. Define responsive layout (table on desktop, cards on mobile)
6. Produce a `ui-spec` contract

---

## Pass Criteria

- [ ] Status badges use text + color (not color alone)
- [ ] Empty state has illustration/message and call-to-action
- [ ] Loading skeleton matches list row dimensions
- [ ] Error state includes error message and retry button
- [ ] Desktop: table layout with sortable columns
- [ ] Mobile: card layout with key info visible
- [ ] `ui-spec` contract produced

---

## Fail Criteria

- Status badges rely on color alone → ❌ a11y violation (color blindness)
- Missing empty state → ❌ incomplete (users will see blank page)
- Missing loading state → ❌ incomplete (users see content flash)
- No responsive breakpoint → ❌ mobile users get broken layout
- Error state has no retry mechanism → ❌ dead end for users
