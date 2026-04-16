# Eval: business-analyst — 001 — Story Decomposition

**Tags:** user stories, INVEST, business rules, domain terms, decomposition
**Skill version tested:** initial

---

## Input (task brief)

```
Decompose the notification preferences PRD into user stories. Requirements:
per-channel toggles, SecurityAlert minimum-one-channel rule, pause-all functionality.
```

---

## Expected Behavior

The business-analyst should:
1. Decompose into at least 4 INVEST-quality user stories
2. Extract business rules with IDs (e.g., BR-001)
3. Identify domain terms for the glossary
4. Produce a `business-requirements` contract

---

## Pass Criteria

- [ ] At least 4 stories: toggle preference, view preferences, SecurityAlert constraint, pause-all
- [ ] Stories follow "As a [role], I want [goal], so that [benefit]" format
- [ ] Each story has Given/When/Then acceptance criteria
- [ ] Stories are small enough for one sprint (INVEST: Small)
- [ ] Business rules extracted: BR-001 SecurityAlert minimum one channel
- [ ] Domain terms identified: NotificationCategory, NotificationChannel, NotificationPreference
- [ ] `business-requirements` contract produced

---

## Fail Criteria

- Fewer than 4 stories (epic-sized stories) → ❌ not decomposed enough
- Missing acceptance criteria → ❌ not testable
- SecurityAlert constraint not extracted as explicit business rule → ❌ lost requirement
- No domain terms identified → ❌ missing glossary contribution
