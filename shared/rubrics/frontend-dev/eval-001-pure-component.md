# Eval: frontend-dev — 001 — Pure Component Implementation

**Tags:** FP, pure rendering, no business logic in UI, Vue/Nuxt, contract compliance
**Skill version tested:** initial

---

## Input (task brief)

~~~
## TASK BRIEF

### Assignment
**Agent:** frontend-dev
**Task ID:** T-006
**Task:** Implement NotificationPreferencesPanel component that displays and allows toggling of notification channels per event category
**Layer:** frontend

### Context
**Repo:** /workspace/notification-ui
**Relevant files:** src/components/settings/, src/stores/preferences.ts, src/types/notification.ts
**Stack:** Vue / Nuxt
**ADR:** ADR-012: Customer Notification Preferences

### Contract to Implement or Consume
Consumes:
- GET /customers/{id}/notification-preferences → { preferences: List[Preference] }
- PUT /customers/{id}/notification-preferences/{category} → { channels: List[Channel] }

Types (from backend):
- Channel: Email | SMS | Push
- EventCategory: OrderUpdate | Promotion | SecurityAlert
- Preference: { category: EventCategory, channels: List[Channel] }

UI requirements:
- Show one row per EventCategory
- Each row has toggle switches for Email, SMS, Push
- SecurityAlert must have at least one channel enabled (disable toggle if it's the last one)
- Show loading state while saving
- Show error state if save fails

### Dependencies
**Blocked by:** T-004 (API endpoints must exist)
**Provides to:** T-007 (QA agent)

### Definition of Done
- [ ] Component renders all categories with correct channel toggles
- [ ] Toggle fires updatePreference command through store (not direct API call)
- [ ] SecurityAlert invariant enforced in UI (last channel cannot be disabled)
- [ ] Loading and error states handled
- [ ] No business logic in component — invariant check delegated to store/service
- [ ] Tests: renders correctly, toggle emits correct event, SecurityAlert guard works
- [ ] No `any` types

### Output Expected
**Produce:** implementation-summary
**Send to:** tech-lead
~~~

---

## Expected Behavior

The frontend-dev should:
1. Orient by reading existing component patterns in src/components/settings/
2. Create a pure presentational component (props → UI)
3. Keep the SecurityAlert invariant logic in the store/service layer, NOT in the component
4. Use Composition API with TypeScript
5. Use domain language in component and event names (not `handleClick` / `onToggle`)
6. Produce output per `shared/contracts/implementation-summary.md`

---

## Pass Criteria

- [ ] Component is pure: same props → same render output
- [ ] No direct API calls from the component (goes through store)
- [ ] SecurityAlert invariant enforced, but logic lives in store/composable, not in template
- [ ] Uses `<script setup lang="ts">` (Composition API)
- [ ] Domain-named events: `updatePreference` not `handleToggle`
- [ ] Domain-named component: `NotificationPreferencesPanel` not `SettingsToggles`
- [ ] Loading state rendered while API call in progress
- [ ] Error state rendered on API failure (not blank/broken UI)
- [ ] No `any` types anywhere
- [ ] No `console.log` in production code
- [ ] At least 3 tests: render, toggle event, SecurityAlert guard
- [ ] `implementation-summary` contract produced with all required fields

---

## Fail Criteria

- Component calls fetch/axios directly → ❌ bypasses store layer (DDD violation)
- SecurityAlert invariant check is in the template/component → ❌ business logic in UI
- Uses Options API → ❌ violates stack profile
- Uses `any` type → ❌ hard gate
- Component named `TogglePanel` or `SettingsForm` → ❌ not domain language
- Missing loading/error states → ❌ incomplete implementation
- Missing implementation-summary or wrong format → ❌ contract violation
