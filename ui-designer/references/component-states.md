# Component States Reference

Every interactive component must have clearly defined visual states. This reference
lists required states per component type with visual treatment guidance.

---

## Button

| State | Visual Treatment |
|-------|-----------------|
| **Default** | Solid background (`color.action.primary`), white text, standard border-radius. Cursor: pointer. |
| **Hover** | Slightly darker background (`color.action.primary.hover`), optional subtle shadow lift. Transition: 150ms ease. |
| **Active / Pressed** | Darker still, slight scale-down (transform: scale(0.98)), shadow removed. Feels "pushed in." |
| **Disabled** | Muted background (`color.bg.secondary`), muted text (`color.text.disabled`), no shadow. Cursor: not-allowed. Reduced opacity (0.6) or desaturated. |
| **Loading** | Replace label with spinner or show spinner alongside truncated text. Keep button width stable (prevent layout shift). Disabled interaction. |
| **Focus** | Visible focus ring (`color.border.focus`, 2px offset outline). Must be visible for keyboard navigation. Never remove focus styles. |

**Variants to consider:** primary, secondary (outline), ghost (text only), danger (destructive actions).

---

## Input / TextField

| State | Visual Treatment |
|-------|-----------------|
| **Default** | Light border (`color.border.default`), white background, placeholder text in `color.text.secondary`. |
| **Focus** | Border changes to `color.border.focus` (typically blue). Optional subtle box-shadow glow. Label may animate above the field (floating label pattern). |
| **Filled** | Same as default but with user-entered text in `color.text.primary`. Placeholder hidden. |
| **Error** | Border changes to `color.border.error` (red). Error message appears below the field in red. Error icon optionally shown inside field. Field remains editable. |
| **Disabled** | Background becomes `color.bg.secondary` (light gray). Text is muted. Cursor: not-allowed. Border is lighter/faded. |
| **Read-only** | Similar to filled but no border or subtle border. Background may be transparent or very light. Text is selectable but not editable. No cursor change needed. |

**Accessibility:** Error state must not rely on color alone — include error icon and descriptive text.

---

## Toggle / Switch

| State | Visual Treatment |
|-------|-----------------|
| **On** | Track filled with `color.action.primary`. Thumb positioned right. Label reads current state. |
| **Off** | Track is neutral gray (`color.border.default`). Thumb positioned left. |
| **Disabled-On** | Same as On but with reduced opacity (0.5). Cursor: not-allowed. |
| **Disabled-Off** | Same as Off but with reduced opacity (0.5). Cursor: not-allowed. |
| **Focus** | Focus ring around the entire toggle component. Visible on keyboard tab. |

**Accessibility:** Always pair with a visible label. The toggle alone doesn't communicate what it controls.

---

## Checkbox

| State | Visual Treatment |
|-------|-----------------|
| **Unchecked** | Empty box with border (`color.border.default`). |
| **Checked** | Filled box with `color.action.primary` background, white checkmark icon inside. |
| **Indeterminate** | Filled box with `color.action.primary` background, horizontal dash icon instead of checkmark. Used for "select all" when some children are selected. |
| **Disabled** | Reduced opacity (0.5), cursor: not-allowed. Maintains checked/unchecked visual. |
| **Focus** | Focus ring around the checkbox. Must be visible for keyboard users. |

---

## Card

| State | Visual Treatment |
|-------|-----------------|
| **Default** | White background, subtle border or shadow (`shadow.sm`), standard border-radius. |
| **Hover** (if interactive) | Elevated shadow (`shadow.md`), optional subtle border color change. Cursor: pointer. Smooth transition (150ms). |
| **Selected** | Distinct border color (`color.action.primary`), optionally stronger shadow or subtle background tint. Checkmark badge in corner for clarity. |
| **Loading Skeleton** | Pulsing gray placeholder shapes matching content layout (title bar, text lines, image area). Animated shimmer effect. No real content shown. |

---

## Modal / Dialog

| State | Visual Treatment |
|-------|-----------------|
| **Open** | Centered on viewport. Backdrop: semi-transparent dark overlay (rgba(0,0,0,0.5)). Entrance animation: fade in + slight scale up (150-200ms). Focus trapped inside modal. |
| **Closing Animation** | Fade out + slight scale down. Backdrop fades out. Duration: 100-150ms (shorter than open). |
| **Backdrop** | Clicking backdrop closes the modal (for non-critical dialogs). Backdrop should be visually distinct but not fully opaque. For critical dialogs (unsaved changes), backdrop click may be disabled. |

**Accessibility:** Focus must be trapped in the modal while open. Escape key closes it. On close, focus returns to the element that opened it.

---

## Dropdown / Select

| State | Visual Treatment |
|-------|-----------------|
| **Closed** | Looks like an input field with a chevron-down icon on the right. Shows selected value or placeholder. |
| **Open** | Dropdown menu appears below (or above if near viewport bottom). Chevron rotates to point up. Selected option highlighted. Border changes to focus color. |
| **Option Hover** | Background highlight on hovered option (`color.bg.secondary`). |
| **Selected Option** | Checkmark icon next to selected option. Option text may be bold or colored. |
| **Disabled** | Same as input disabled: muted background, muted text, cursor: not-allowed. Chevron is muted. Clicking does nothing. |

---

## Table Row

| State | Visual Treatment |
|-------|-----------------|
| **Default** | Alternating row backgrounds (white / `color.bg.secondary`) or consistent white with bottom border. |
| **Hover** | Subtle background highlight. Cursor: pointer if row is clickable. |
| **Selected** | Distinct background tint (light blue/primary tint). Checkbox in first column shown as checked. May show a colored left border accent. |
| **Loading Skeleton** | Each cell shows a pulsing gray bar matching expected content width. Maintain column widths. Animate 3-5 skeleton rows. |

---

## General State Guidelines

1. **Transitions:** Use 100-200ms transitions for state changes. Faster feels snappy; slower feels sluggish.
2. **Color alone is insufficient:** Always pair color changes with another indicator (icon, text, border change) for accessibility.
3. **Focus must be visible:** Never set `outline: none` without providing an alternative focus indicator.
4. **Disabled ≠ hidden:** If a user can't interact with something, show it as disabled with explanation (tooltip) rather than hiding it. Hidden elements confuse users who know they should be there.
5. **Loading states prevent layout shift:** Skeletons should match the dimensions of the content they replace.
