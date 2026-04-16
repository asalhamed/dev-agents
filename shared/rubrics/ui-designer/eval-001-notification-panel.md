# Eval: ui-designer — 001 — Notification Preferences Panel

**Tags:** component hierarchy, toggle states, responsive, a11y, SecurityAlert
**Skill version tested:** initial

---

## Input (task brief)

```
Design the notification preferences panel. Users toggle per-channel (email/push/SMS)
per notification category. SecurityAlert must keep at least one channel.
```

---

## Expected Behavior

The ui-designer should:
1. Define a component hierarchy (page → category rows → channel toggles)
2. Specify all toggle states (on, off, disabled, focus, hover)
3. Design the SecurityAlert variant with lock icon and explanation text
4. Define responsive behavior with mobile breakpoint
5. Ensure WCAG 2.1 AA contrast ratios
6. Produce a `ui-spec` contract

---

## Pass Criteria

- [ ] Component hierarchy clearly defined
- [ ] All toggle states specified: on, off, disabled, focus
- [ ] SecurityAlert variant: lock icon + user-facing explanation
- [ ] Mobile breakpoint defined (e.g., stack toggles vertically)
- [ ] Contrast ratios specified meeting WCAG 2.1 AA (4.5:1 text, 3:1 interactive)
- [ ] Keyboard navigation specified (tab order, space to toggle)
- [ ] `ui-spec` contract produced

---

## Fail Criteria

- No component hierarchy → ❌ missing structural design
- SecurityAlert treated identically to other categories → ❌ missing constraint
- Color alone used to indicate toggle state → ❌ a11y violation
- No responsive behavior defined → ❌ incomplete spec
- No keyboard navigation → ❌ a11y gap
