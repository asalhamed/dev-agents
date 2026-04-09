# UX Specification

**Producer:** ux-researcher
**Consumer(s):** ui-designer, architect

## Required Fields

- **Feature** — what is being designed
- **Personas** — who the users are (2+ personas minimum)
- **User journeys** — steps, emotions, pain points (current and desired)
- **Usability requirements** — measurable, not subjective
- **Accessibility requirements** — WCAG level, specific needs
- **Edge cases and error recovery** — how users recover from mistakes

## Validation Checklist

- [ ] At least 2 personas defined
- [ ] Each persona has: goals, pain points, context, technical literacy
- [ ] Journey covers both happy path and error/recovery path
- [ ] Usability requirements are measurable
- [ ] Accessibility level stated explicitly (WCAG 2.1 AA minimum)

## Example (valid)

```markdown
## UX SPEC: Notification Preferences

**Personas:**
1. Power User (Layla, 34, product manager): checks notifications daily, wants fine-grained control,
   frustrated by irrelevant emails, comfortable with settings UI
2. Casual User (Omar, 52, small business owner): checks app weekly, wants "less noise,"
   unfamiliar with notification categories, prefers simple controls

**User journey (current — pain points):**
1. Receives unwanted marketing email → looks for unsubscribe link
2. Unsubscribe link → preferences page → overwhelmed by options
3. Tries to turn off everything → blocked by SecurityAlert rule → confused, no explanation
4. Gives up and unsubscribes entirely

**User journey (desired — happy path):**
1. Enters preferences page from email footer or app settings
2. Sees clear categories with on/off toggles per channel
3. Turns off MarketingUpdates email → immediate visual feedback
4. Tries to disable SecurityAlert entirely → clear explanation of why one channel is required
5. Saves preferences → confirmation message, change takes effect within 24 hours

**Usability requirements:**
- Users must complete "disable one channel" task in under 90 seconds on first use
- SecurityAlert error message understood by 90% of test users without explanation
- Preferences page must work with keyboard-only navigation

**Accessibility requirements:**
- WCAG 2.1 Level AA
- Toggle switches must have visible labels (not color-only states)
- Screen reader announces toggle state changes
- Focus management when form errors appear
```
