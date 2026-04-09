# Accessibility (a11y) Standards

Reference guide for building accessible web interfaces. Applies to all frontend frameworks.

---

## Core Rules

### 1. Semantic HTML First

Use the right HTML element for the job. ARIA is a last resort, not a first choice.

| Need | Use | Not |
|------|-----|-----|
| Navigation | `<nav>` | `<div class="nav">` |
| Button | `<button>` | `<div onclick>` or `<a href="#">` |
| List | `<ul>` / `<ol>` + `<li>` | `<div>` with CSS bullets |
| Heading | `<h1>` – `<h6>` (in order) | `<div class="heading">` or `<span style="font-size:2em">` |
| Form input | `<input>` + `<label>` | `<div contenteditable>` |
| Main content | `<main>` | `<div id="content">` |
| Footer | `<footer>` | `<div class="footer">` |
| Article | `<article>` | `<div class="post">` |
| Table data | `<table>` + `<th>` + `<td>` | `<div>` grid with CSS |

**Rule:** If a native HTML element exists for the purpose, use it. Native elements have built-in keyboard support, focus management, and screen reader semantics.

---

### 2. Keyboard Navigation

Every interactive element must be usable without a mouse.

**Visible focus indicator:**
```css
/* ✅ Always visible, high contrast */
:focus-visible {
  outline: 3px solid #4A90D9;
  outline-offset: 2px;
}

/* ❌ Never do this */
*:focus {
  outline: none;
}
```

**Tab order:**
- Follow the visual reading order (left-to-right, top-to-bottom)
- Use the natural DOM order — avoid `tabindex` values > 0
- `tabindex="0"` adds non-interactive elements to tab order (use sparingly)
- `tabindex="-1"` allows programmatic focus but removes from tab order

**Keyboard patterns:**
| Pattern | Key | Behavior |
|---------|-----|----------|
| Button | `Enter`, `Space` | Activate |
| Link | `Enter` | Navigate |
| Menu | `Arrow keys` | Move between items |
| Dialog | `Tab` | Cycle within dialog (focus trap) |
| Dismiss | `Escape` | Close modal, dropdown, tooltip |
| Select | `Arrow keys` | Navigate options |

**Focus trap for modals:**
When a modal/dialog is open, `Tab` must cycle only within the modal. Focus must return to the triggering element when the modal closes. `Escape` must close the modal.

---

### 3. ARIA When Needed

Use ARIA only when native HTML cannot express the semantics.

**✅ Correct — icon button needs a label:**
```html
<button aria-label="Close dialog">
  <svg><!-- X icon --></svg>
</button>
```

**✅ Correct — loading state:**
```html
<div aria-busy="true" aria-live="polite">
  Loading results...
</div>
```

**✅ Correct — dynamic content update:**
```html
<div aria-live="polite" role="status">
  3 results found
</div>
```

**❌ Incorrect — redundant ARIA on semantic elements:**
```html
<!-- Bad: <button> already has role="button" -->
<button role="button">Submit</button>

<!-- Bad: <nav> already has role="navigation" -->
<nav role="navigation">...</nav>

<!-- Bad: <a href> already has role="link" -->
<a href="/home" role="link">Home</a>
```

**Rule:** The first rule of ARIA is "don't use ARIA" — use native HTML. The second rule is: if you must use ARIA, use it correctly and completely.

---

### 4. Color and Contrast

**Minimum contrast ratios (WCAG 2.1 AA):**
- Normal text (< 18pt): **4.5:1** against background
- Large text (≥ 18pt or 14pt bold): **3:1** against background
- UI components and graphical objects: **3:1** against adjacent colors

**Never rely on color alone:**
```html
<!-- ❌ Color alone -->
<span style="color: red">Error</span>

<!-- ✅ Color + icon + text -->
<span class="error">
  <svg aria-hidden="true"><!-- ⚠ icon --></svg>
  Error: Email is required
</span>
```

**Status badges need text, not just color:**
```html
<!-- ❌ Color-only status -->
<span class="badge badge-green"></span>

<!-- ✅ Color + text -->
<span class="badge badge-green">Active</span>

<!-- ✅ Color + text + icon for emphasis -->
<span class="badge badge-red">
  <svg aria-hidden="true"><!-- ✕ icon --></svg>
  Failed
</span>
```

---

### 5. Forms

Every form input must have a programmatically associated label.

```html
<!-- ✅ Label associated via for/id -->
<div class="form-group">
  <label for="email">Email address</label>
  <input
    id="email"
    type="email"
    aria-required="true"
    aria-describedby="email-error"
  />
  <span id="email-error" role="alert" aria-live="assertive">
    <!-- Error message injected here when validation fails -->
  </span>
</div>

<!-- ✅ Complete form example -->
<form>
  <div class="form-group">
    <label for="name">Full name</label>
    <input id="name" type="text" aria-required="true" />
  </div>

  <div class="form-group">
    <label for="email">Email</label>
    <input
      id="email"
      type="email"
      aria-required="true"
      aria-invalid="true"
      aria-describedby="email-hint email-error"
    />
    <span id="email-hint" class="hint">We'll never share your email.</span>
    <span id="email-error" class="error" role="alert" aria-live="assertive">
      Please enter a valid email address.
    </span>
  </div>

  <button type="submit">Submit</button>
</form>
```

**Rules:**
- `label` with `for` attribute matching input `id` — always
- `aria-describedby` for error messages and hints
- `aria-required="true"` for required fields
- `aria-invalid="true"` when validation fails
- `aria-live="assertive"` on error containers so screen readers announce errors
- Never use `placeholder` as the only label

---

### 6. Images and Media

**Alt text rules:**
- **Informative images:** `alt` describes the content — "Bar chart showing Q3 revenue up 15%"
- **Decorative images:** `alt=""` (empty) + `aria-hidden="true"` — screen readers skip it
- **Functional images (links/buttons):** `alt` describes the action — "Go to homepage"
- **Complex images:** `alt` with brief description + link to full description or `aria-describedby`

```html
<!-- ✅ Informative -->
<img src="chart.png" alt="Revenue chart: Q3 2024 up 15% over Q2" />

<!-- ✅ Decorative -->
<img src="divider.png" alt="" aria-hidden="true" />

<!-- ✅ Complex — with extended description -->
<figure>
  <img src="architecture.png" alt="System architecture diagram" aria-describedby="arch-desc" />
  <figcaption id="arch-desc">
    The system consists of three bounded contexts: Order, Inventory, and Billing,
    communicating via domain events through a Kafka message bus.
  </figcaption>
</figure>
```

**Video and audio:**
- All video must have captions (synchronized text)
- All audio must have a transcript
- Auto-playing media must have a visible pause/stop control
- `prefers-reduced-motion` must be respected for animations

---

### 7. Component Checklist

Before shipping any interactive component, verify:

- [ ] **Keyboard accessible** — all interactions work without a mouse
- [ ] **Visible focus indicator** — focus state is clearly visible (3px+ outline)
- [ ] **Accessible names** — all interactive elements have text labels or `aria-label`
- [ ] **Color independence** — information is not conveyed by color alone
- [ ] **Error and loading states** — announced to screen readers (`aria-live`)
- [ ] **Contrast** — text meets 4.5:1, UI components meet 3:1
- [ ] **Dynamic content** — updates announced via `aria-live` regions

---

## Testing

### Manual Testing

1. **Keyboard tab-through:** Tab through the entire page. Can you reach every interactive element? Can you activate every button? Can you dismiss every modal with Escape?

2. **DevTools audit:** Run Lighthouse Accessibility audit in Chrome DevTools. Fix all critical issues.

3. **Screen reader testing:**
   - **macOS:** VoiceOver (`Cmd + F5`)
   - **Windows:** NVDA (free) or JAWS
   - **Linux:** Orca
   - Navigate the page using only the screen reader. Does it make sense?

4. **axe-core automated testing:** Run `axe-core` in your test suite for automated WCAG checks.

### Automated Test Example (TypeScript)

```typescript
import { axe, toHaveNoViolations } from "jest-axe";
import { render } from "@testing-library/react";

expect.extend(toHaveNoViolations);

describe("OrderSummary accessibility", () => {
  it("has no axe violations", async () => {
    const { container } = render(<OrderSummary order={mockOrder} />);
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });

  it("confirm button has accessible name", () => {
    const { getByRole } = render(<OrderSummary order={mockDraftOrder} />);
    const button = getByRole("button", { name: /confirm order/i });
    expect(button).toBeInTheDocument();
  });

  it("error message is announced to screen readers", () => {
    const { getByRole } = render(<OrderSummary order={mockOrder} error="Failed" />);
    const alert = getByRole("alert");
    expect(alert).toHaveTextContent("Failed");
  });
});
```

### Automated Test Example (Rust / Leptos)

For Leptos components, use `wasm-pack test` with `web_sys` to verify DOM structure:

```rust
#[wasm_bindgen_test]
fn order_summary_has_heading() {
    let document = web_sys::window().unwrap().document().unwrap();
    // Mount component and verify semantic structure
    let heading = document.query_selector("h2").unwrap();
    assert!(heading.is_some(), "OrderSummary must have an h2 heading");
}
```
