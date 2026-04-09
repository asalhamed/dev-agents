# Nielsen's 10 Usability Heuristics

Reference for evaluating interface usability. Each heuristic includes a description,
example violation, and example fix.

---

## 1. Visibility of System Status

**Description:** The system should always keep users informed about what's going on,
through appropriate feedback within reasonable time.

**Example violation:** User clicks "Place Order" and nothing happens for 5 seconds.
No loading indicator, no feedback. User clicks again, creating a duplicate order.

**Example fix:** Show a loading spinner immediately on click, disable the button to
prevent double-submission, display "Processing your order..." text. On completion,
show success confirmation with order number.

---

## 2. Match Between System and the Real World

**Description:** The system should speak the user's language, using words, phrases,
and concepts familiar to the user, rather than system-oriented terms. Follow
real-world conventions, making information appear in a natural and logical order.

**Example violation:** Error message reads: "Error 422: Unprocessable Entity —
validation constraint violation on field `shipping_addr.postal_code`."

**Example fix:** "Please enter a valid ZIP code for your shipping address (e.g., 90210)."

---

## 3. User Control and Freedom

**Description:** Users often choose system functions by mistake and need a clearly
marked "emergency exit" to leave the unwanted state without going through an
extended dialogue. Support undo and redo.

**Example violation:** User accidentally deletes a project. No confirmation dialog,
no undo. Data is permanently gone.

**Example fix:** Show a confirmation dialog for destructive actions. After deletion,
show a toast with "Undo" button (soft delete with 30-second recovery window).
Support trash/archive with restore capability.

---

## 4. Consistency and Standards

**Description:** Users should not have to wonder whether different words, situations,
or actions mean the same thing. Follow platform and industry conventions.

**Example violation:** "Save" button is green on the profile page, blue on settings,
and labeled "Submit" on the order page. Some forms save on blur, others require
explicit button click.

**Example fix:** Use the same primary action color throughout the app. Standardize
action labels: "Save" for persisting changes, "Submit" for sending to others,
"Create" for new items. Document in a style guide.

---

## 5. Error Prevention

**Description:** Even better than good error messages is a careful design which
prevents a problem from occurring in the first place. Eliminate error-prone
conditions or check for them and present users with a confirmation option before
they commit to the action.

**Example violation:** Date picker allows selecting past dates for a delivery
schedule, then shows an error after form submission.

**Example fix:** Disable past dates in the date picker. Gray them out visually.
If the user somehow enters a past date, show inline validation immediately
(not after submission).

---

## 6. Recognition Rather Than Recall

**Description:** Minimize the user's memory load by making objects, actions, and
options visible. The user should not have to remember information from one part
of the dialogue to another.

**Example violation:** User must type the exact product SKU from memory to add
items to an order. No search, no autocomplete, no recent items.

**Example fix:** Provide a searchable product picker with thumbnails. Show recently
used items. Allow searching by name, not just SKU. Display the selected product's
details for confirmation.

---

## 7. Flexibility and Efficiency of Use

**Description:** Accelerators — unseen by the novice user — may often speed up
the interaction for the expert user so that the system can cater to both
inexperienced and experienced users.

**Example violation:** Power users must click through 5 menu levels to reach a
frequently used action. No keyboard shortcuts, no favorites, no quick actions.

**Example fix:** Add keyboard shortcuts (Cmd+K for command palette). Allow users
to pin frequently used actions. Support URL deep-linking to specific views.
Provide a "Quick Actions" search bar.

---

## 8. Aesthetic and Minimalist Design

**Description:** Dialogues should not contain information which is irrelevant or
rarely needed. Every extra unit of information in a dialogue competes with the
relevant information and diminishes its relative visibility.

**Example violation:** Dashboard shows 20 metrics, 5 promotional banners, a news
feed, and 3 call-to-action buttons. The one metric the user cares about is
buried below the fold.

**Example fix:** Show the 3-5 most important metrics prominently. Move secondary
information to expandable sections or separate pages. Let users customize their
dashboard. Remove promotional content from work surfaces.

---

## 9. Help Users Recognize, Diagnose, and Recover from Errors

**Description:** Error messages should be expressed in plain language (no codes),
precisely indicate the problem, and constructively suggest a solution.

**Example violation:** "An error occurred. Please try again later. (ERR_INTERNAL_500)"

**Example fix:** "We couldn't save your changes because the file is too large
(maximum 10 MB). Try compressing the image or choosing a smaller file."
Include: what happened, why, and what the user can do about it.

---

## 10. Help and Documentation

**Description:** Even though it's better if the system can be used without
documentation, it may be necessary to provide help and documentation. Any such
information should be easy to search, focused on the user's task, list concrete
steps, and not be too large.

**Example violation:** Help documentation is a 200-page PDF with no search.
No contextual help in the interface. No tooltips on complex features.

**Example fix:** Add `?` tooltips next to complex fields explaining what they do.
Provide contextual help links that open the relevant doc section (not the homepage).
Include a searchable knowledge base. Offer an interactive onboarding tour for
new users.

---

## Using Heuristics in Review

### Severity Rating Scale

| Rating | Label | Description |
|--------|-------|-------------|
| 0 | Not a problem | Disagree that this is a usability problem |
| 1 | Cosmetic | Fix only if extra time available |
| 2 | Minor | Low priority — causes minor friction |
| 3 | Major | High priority — causes significant difficulty |
| 4 | Catastrophic | Must fix — prevents task completion |

### Review Process

1. Walk through core user tasks independently
2. Note each issue with: heuristic violated, severity, location, description
3. Compare findings with other evaluators (3-5 evaluators find ~75% of issues)
4. Prioritize by severity × frequency
