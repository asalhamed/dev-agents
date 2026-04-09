# UI Specification

**Producer:** ui-designer
**Consumer(s):** frontend-dev

## Required Fields

- **Feature** — what is being designed
- **Component hierarchy** — what components and how they nest
- **Component states** — for each component: default, hover, active, disabled, error, loading, empty
- **Responsive behavior** — breakpoints and layout changes
- **Design tokens** — colors, spacing, typography, or reference to design system
- **Accessibility specs** — focus indicators, ARIA labels, contrast ratios

## Validation Checklist

- [ ] All component states defined (not just happy path)
- [ ] Mobile layout defined (minimum 320px)
- [ ] Contrast ratios meet WCAG 2.1 AA
- [ ] Focus indicators specified
- [ ] All interactive elements have accessible names

## Example (valid)

```markdown
## UI SPEC: Notification Preferences Panel

**Component hierarchy:**
- NotificationPreferencesPage
  - PageHeader ("Notification Preferences")
  - NotificationCategoryList
    - NotificationCategoryRow (per category)
      - CategoryLabel
      - ChannelToggleGroup
        - ChannelToggle (email / push / SMS)
  - PauseAllControl
  - SaveButton

**ChannelToggle states:**
- On: filled blue (token: color.action.primary = #2563EB)
- Off: grey (token: color.neutral.300 = #D1D5DB)
- Disabled: muted, cursor: not-allowed, aria-disabled="true"
- Focus: 2px solid outline (token: color.focus.ring = #2563EB)

**NotificationCategoryRow — SecurityAlert variant:**
- Lock icon (🔒) next to label
- Tooltip on hover: "Security alerts require at least one channel"
- Cannot disable last enabled toggle (disabled state applied programmatically)

**SaveButton states:**
- Default: "Save preferences" — primary button style
- Saving: spinner + "Saving..." — all inputs disabled
- Success: brief "Saved" text, then revert to default

**Responsive behavior:**
- ≥768px: category label (30%) + channel toggles side-by-side (70%)
- <768px: category label above, channel toggles below in a row

**Design tokens:**
- color.action.primary: #2563EB
- color.neutral.300: #D1D5DB
- color.focus.ring: #2563EB
- spacing.md: 16px

**Accessibility:**
- ChannelToggle uses role="switch" with aria-checked
- Toggle label: "Email notifications for {category}" (not just "Email")
- Error message uses role="alert"
- Contrast: label text on white = 7:1 ✅
```
