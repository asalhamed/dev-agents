# Design Tokens Reference

Design tokens are the single source of truth for visual design values — colors, spacing,
typography, etc. They bridge design and code.

---

## Token Categories

### Color

**Primitive tokens** (raw values):

```
color.blue.50:   #eff6ff
color.blue.100:  #dbeafe
color.blue.500:  #3b82f6
color.blue.700:  #1d4ed8
color.blue.900:  #1e3a5f
color.gray.50:   #f9fafb
color.gray.200:  #e5e7eb
color.gray.500:  #6b7280
color.gray.900:  #111827
color.red.500:   #ef4444
color.green.500: #22c55e
color.amber.500: #f59e0b
```

**Semantic tokens** (intent-based, reference primitives):

```
color.action.primary:      {color.blue.600}
color.action.primary.hover: {color.blue.700}
color.action.danger:       {color.red.500}
color.action.success:      {color.green.500}

color.text.primary:        {color.gray.900}
color.text.secondary:      {color.gray.500}
color.text.inverse:        #ffffff
color.text.disabled:       {color.gray.300}

color.bg.primary:          #ffffff
color.bg.secondary:        {color.gray.50}
color.bg.elevated:         #ffffff

color.border.default:      {color.gray.200}
color.border.focus:        {color.blue.500}
color.border.error:        {color.red.500}
```

### Spacing

4px base scale:

```
spacing.xs:   4px    (0.25rem)
spacing.sm:   8px    (0.5rem)
spacing.md:   16px   (1rem)
spacing.lg:   24px   (1.5rem)
spacing.xl:   32px   (2rem)
spacing.2xl:  48px   (3rem)
spacing.3xl:  64px   (4rem)
```

### Typography

```
typography.font.sans:        'Inter', system-ui, -apple-system, sans-serif
typography.font.mono:        'JetBrains Mono', 'Fira Code', monospace

typography.heading.2xl.size:    30px (1.875rem)
typography.heading.2xl.weight:  700
typography.heading.2xl.leading: 36px (2.25rem)

typography.heading.xl.size:     24px (1.5rem)
typography.heading.xl.weight:   600
typography.heading.xl.leading:  32px (2rem)

typography.heading.lg.size:     20px (1.25rem)
typography.heading.lg.weight:   600
typography.heading.lg.leading:  28px (1.75rem)

typography.body.md.size:        16px (1rem)
typography.body.md.weight:      400
typography.body.md.leading:     24px (1.5rem)

typography.body.sm.size:        14px (0.875rem)
typography.body.sm.weight:      400
typography.body.sm.leading:     20px (1.25rem)

typography.label.size:          12px (0.75rem)
typography.label.weight:        500
typography.label.leading:       16px (1rem)
```

### Border Radius

```
radius.sm:    4px   (0.25rem)
radius.md:    8px   (0.5rem)
radius.lg:    12px  (0.75rem)
radius.xl:    16px  (1rem)
radius.full:  9999px
```

### Shadows

```
shadow.sm:    0 1px 2px 0 rgba(0, 0, 0, 0.05)
shadow.md:    0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1)
shadow.lg:    0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1)
shadow.xl:    0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1)
```

### Z-Index

```
z.dropdown:   1000
z.sticky:     1100
z.overlay:    1200
z.modal:      1300
z.popover:    1400
z.tooltip:    1500
z.toast:      1600
```

---

## Token Naming Convention

**Pattern:** `category.variant.modifier`

```
color.action.primary          → category: color, variant: action, modifier: primary
spacing.md                    → category: spacing, modifier: md
typography.heading.xl         → category: typography, variant: heading, modifier: xl
shadow.lg                     → category: shadow, modifier: lg
```

**Rules:**
- Lowercase, dot-separated
- Category first (what kind of token)
- Variant describes the semantic use (action, text, bg, heading, body)
- Modifier for size/state (primary, hover, sm, md, lg)

---

## Semantic vs Primitive Tokens

| | Primitive | Semantic |
|---|---|---|
| **Definition** | Raw value: `color.blue.500: #3b82f6` | Intent-based: `color.action.primary: {color.blue.500}` |
| **Use in code** | ❌ Rarely — only inside token definitions | ✅ Always use semantic tokens in components |
| **Theming** | Same across themes | Changes per theme (light/dark) |
| **Example** | `color.gray.900` | `color.text.primary` (→ gray.900 in light, gray.50 in dark) |

**Rule:** Components should only reference semantic tokens. Primitive tokens are the
"periodic table" — semantic tokens are the "molecules" you build with.

```css
/* ❌ Primitive token in component */
.button { background: var(--color-blue-500); }

/* ✅ Semantic token in component */
.button { background: var(--color-action-primary); }
```

---

## Tailwind CSS Mapping

```javascript
// tailwind.config.js
const tokens = require('./tokens.json');

module.exports = {
  theme: {
    colors: {
      action: {
        primary: tokens.color.action.primary,
        'primary-hover': tokens.color.action['primary.hover'],
        danger: tokens.color.action.danger,
        success: tokens.color.action.success,
      },
      text: {
        primary: tokens.color.text.primary,
        secondary: tokens.color.text.secondary,
        inverse: tokens.color.text.inverse,
        disabled: tokens.color.text.disabled,
      },
      bg: {
        primary: tokens.color.bg.primary,
        secondary: tokens.color.bg.secondary,
      },
      border: {
        DEFAULT: tokens.color.border.default,
        focus: tokens.color.border.focus,
        error: tokens.color.border.error,
      },
    },
    spacing: {
      xs: tokens.spacing.xs,
      sm: tokens.spacing.sm,
      md: tokens.spacing.md,
      lg: tokens.spacing.lg,
      xl: tokens.spacing.xl,
      '2xl': tokens.spacing['2xl'],
    },
    fontFamily: {
      sans: [tokens.typography.font.sans],
      mono: [tokens.typography.font.mono],
    },
    borderRadius: {
      sm: tokens.radius.sm,
      md: tokens.radius.md,
      lg: tokens.radius.lg,
      xl: tokens.radius.xl,
      full: tokens.radius.full,
    },
    boxShadow: {
      sm: tokens.shadow.sm,
      md: tokens.shadow.md,
      lg: tokens.shadow.lg,
      xl: tokens.shadow.xl,
    },
    zIndex: {
      dropdown: tokens.z.dropdown,
      sticky: tokens.z.sticky,
      overlay: tokens.z.overlay,
      modal: tokens.z.modal,
      popover: tokens.z.popover,
      tooltip: tokens.z.tooltip,
      toast: tokens.z.toast,
    },
  },
};
```

Usage in components:

```html
<button class="bg-action-primary hover:bg-action-primary-hover text-text-inverse
               rounded-md px-lg py-sm shadow-sm">
  Save Order
</button>
```
