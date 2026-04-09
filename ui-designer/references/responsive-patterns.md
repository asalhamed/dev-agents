# Responsive Design Patterns

Patterns and conventions for building interfaces that work across screen sizes.

---

## Mobile-First Approach

**Why mobile-first:**
- Forces prioritization — what's essential when space is limited?
- Progressive enhancement — add complexity for larger screens
- Mobile traffic is 50-60% of web traffic
- Prevents "desktop shrink" problems (trying to cram a desktop layout into mobile)

**How — use `min-width` breakpoints, not `max-width`:**

```css
/* ✅ Mobile-first: base styles are mobile, enhance upward */
.container { padding: 16px; }

@media (min-width: 768px) {
  .container { padding: 24px; max-width: 720px; }
}

@media (min-width: 1024px) {
  .container { padding: 32px; max-width: 960px; }
}

/* ❌ Desktop-first: base styles are desktop, degrade downward */
.container { padding: 32px; max-width: 960px; }

@media (max-width: 1023px) {
  .container { padding: 24px; max-width: 720px; }
}

@media (max-width: 767px) {
  .container { padding: 16px; max-width: 100%; }
}
```

---

## Standard Breakpoints

| Name | Width | Tailwind Class | Typical Devices |
|------|-------|---------------|----------------|
| **xs** | 320px | (default/base) | Small phones |
| **sm** | 640px | `sm:` | Large phones, landscape |
| **md** | 768px | `md:` | Tablets portrait |
| **lg** | 1024px | `lg:` | Tablets landscape, small laptops |
| **xl** | 1280px | `xl:` | Desktops |
| **2xl** | 1536px | `2xl:` | Large desktops |

**Tailwind usage:**

```html
<!-- Stack on mobile, 2 columns on tablet, 3 on desktop -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-md">
  <div>Card 1</div>
  <div>Card 2</div>
  <div>Card 3</div>
</div>
```

---

## Common Layout Patterns

### Stack-to-Grid

Column layout on mobile → grid on desktop. The most common responsive pattern.

```html
<div class="flex flex-col md:grid md:grid-cols-2 lg:grid-cols-3 gap-md">
  <div class="card">...</div>
  <div class="card">...</div>
  <div class="card">...</div>
</div>
```

- **Mobile:** Full-width stacked cards
- **Tablet:** 2-column grid
- **Desktop:** 3-column grid

### Sidebar Collapse

Persistent sidebar on desktop → hidden drawer on mobile.

```html
<!-- Sidebar -->
<aside class="fixed inset-y-0 left-0 w-64 bg-bg-primary shadow-lg
              transform -translate-x-full lg:translate-x-0 lg:static
              transition-transform duration-200 z-overlay">
  <nav>...</nav>
</aside>

<!-- Hamburger button (mobile only) -->
<button class="lg:hidden" aria-label="Open menu">☰</button>

<!-- Main content -->
<main class="lg:ml-64">...</main>
```

- **Mobile:** Sidebar hidden off-screen, hamburger button visible
- **Desktop:** Sidebar visible, hamburger hidden, main content offset

### Table-to-Cards

Data table on desktop → card list on mobile (tables are notoriously bad on small screens).

```html
<!-- Desktop: standard table -->
<table class="hidden md:table w-full">
  <thead>
    <tr>
      <th>Order</th><th>Customer</th><th>Status</th><th>Total</th>
    </tr>
  </thead>
  <tbody>
    <tr><td>#1234</td><td>Maria Chen</td><td>Confirmed</td><td>$89.00</td></tr>
  </tbody>
</table>

<!-- Mobile: card layout -->
<div class="md:hidden space-y-sm">
  <div class="card p-md">
    <div class="font-bold">#1234</div>
    <div class="text-text-secondary">Maria Chen</div>
    <div class="flex justify-between mt-sm">
      <span class="badge">Confirmed</span>
      <span class="font-bold">$89.00</span>
    </div>
  </div>
</div>
```

---

## Navigation Patterns

### Mobile Navigation

**Hamburger menu** — most common. Hidden by default, slides in on tap.

```html
<nav class="lg:hidden">
  <button onclick="toggleMenu()" aria-label="Toggle navigation">☰</button>
  <div id="mobile-menu" class="hidden fixed inset-0 bg-bg-primary z-overlay">
    <button onclick="toggleMenu()" aria-label="Close menu">✕</button>
    <a href="/orders">Orders</a>
    <a href="/customers">Customers</a>
    <a href="/settings">Settings</a>
  </div>
</nav>
```

**Bottom tab bar** — for apps with 3-5 primary sections (iOS/Android pattern).

```html
<nav class="fixed bottom-0 inset-x-0 bg-bg-primary border-t flex justify-around
            py-sm lg:hidden">
  <a href="/home" class="flex flex-col items-center">🏠 Home</a>
  <a href="/orders" class="flex flex-col items-center">📦 Orders</a>
  <a href="/profile" class="flex flex-col items-center">👤 Profile</a>
</nav>
```

### Desktop Navigation

Full horizontal nav bar with all primary links visible.

```html
<nav class="hidden lg:flex items-center gap-lg px-xl py-sm bg-bg-primary shadow-sm">
  <a href="/" class="font-bold text-xl">Logo</a>
  <a href="/orders">Orders</a>
  <a href="/customers">Customers</a>
  <a href="/reports">Reports</a>
  <a href="/settings">Settings</a>
</nav>
```

---

## Touch Targets

**Minimum size: 44×44px** (Apple HIG) / **48×48dp** (Material Design).

```css
/* ✅ Adequate touch target */
.button-mobile {
  min-height: 44px;
  min-width: 44px;
  padding: 12px 16px;
}

/* ✅ Invisible hit area expansion for small icons */
.icon-button {
  position: relative;
  width: 24px;
  height: 24px;
}
.icon-button::after {
  content: '';
  position: absolute;
  inset: -10px; /* Expands touch target to 44x44 */
}
```

**Rules:**
- Minimum 8px spacing between adjacent touch targets
- Larger targets for primary/frequent actions
- Don't rely on hover states for essential interactions on touch devices

---

## Typography Scaling

**Don't use fixed `px` for body text.** Use relative units so text scales with user preferences.

### Using `rem`

```css
html { font-size: 16px; } /* 1rem = 16px base */

body { font-size: 1rem; }         /* 16px */
h1   { font-size: 1.875rem; }     /* 30px */
h2   { font-size: 1.5rem; }       /* 24px */
.small { font-size: 0.875rem; }   /* 14px */
```

### Using `clamp()` for Fluid Typography

```css
/* Fluid heading: 24px at 320px viewport, grows to 36px at 1280px */
h1 {
  font-size: clamp(1.5rem, 1rem + 2vw, 2.25rem);
}

/* Fluid body: 14px minimum, 16px at normal viewports, 18px max */
body {
  font-size: clamp(0.875rem, 0.8rem + 0.4vw, 1.125rem);
}
```

`clamp(min, preferred, max)` — browser picks the preferred value, clamped between min and max.

### What NOT to Do

```css
/* ❌ Fixed px — ignores user's font-size preferences */
body { font-size: 14px; }

/* ❌ Too-small text on mobile */
.caption { font-size: 10px; } /* Below readable threshold */

/* ❌ vw-only — becomes unreadably small on phones, huge on desktops */
h1 { font-size: 4vw; }
```

**Minimum readable size:** 14px (0.875rem) for body text, 12px (0.75rem) for labels/captions.
