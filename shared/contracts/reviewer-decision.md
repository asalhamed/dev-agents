# Contract: reviewer → tech-lead

**Producer:** reviewer  
**Consumer:** tech-lead  
**Trigger:** reviewer completes review of all agent outputs for a pipeline run

---

## Required Fields — exactly one decision block must be present

### Decision: ✅ APPROVE

```markdown
## REVIEWER DECISION

**Decision:** ✅ APPROVE
**Pipeline run:** [task IDs reviewed, e.g. T-001 through T-005]
**Reviewed by:** reviewer agent
**Timestamp:** [ISO 8601]

### Summary
[1-3 sentences on what was reviewed and why it passes]

### Coverage
**Final coverage:** [X%] — threshold: [Y%] ✅

### Principles
- FP: ✅ [brief note or "no violations"]
- DDD: ✅ [brief note or "no violations"]  
- Clean Code: ✅ [brief note or "no violations"]

### Follow-up Tasks (non-blocking)
<!-- Create tickets for these — do NOT block merge on them -->
- [ ] [optional follow-up 1]
- [ ] [optional follow-up 2]

**Ready to merge. No further action required.**
```

---

### Decision: 🔁 REQUEST CHANGES

```markdown
## REVIEWER DECISION

**Decision:** 🔁 REQUEST CHANGES
**Return to:** [backend-dev | frontend-dev | qa-agent | devops-agent]
**Task ID(s) to rework:** [T-NNN]
**Pipeline run:** [task IDs]
**Timestamp:** [ISO 8601]
**Review cycle:** [1 | 2 | 3 — if cycle 3+, escalate to tech-lead instead]

### Blocking Issues
<!-- REQUIRED: At least one. Be specific — file, line if known, exact fix needed. -->
| # | Issue | Location | Principle violated | Required fix |
|---|-------|----------|--------------------|-------------|
| 1 | [description] | [File:Line or "general"] | FP / DDD / Clean Code / Quality | [what to do] |

### Non-blocking Notes
<!-- Optional — things to fix if time allows, will not block re-review -->
- [note]

### Re-review Scope
**Only the blocking issues above will be re-checked. New issues will not be introduced in the re-review.**
```

---

### Decision: 🏛️ ESCALATE TO ARCHITECT

```markdown
## REVIEWER DECISION

**Decision:** 🏛️ ESCALATE TO ARCHITECT
**Pipeline run:** [task IDs]
**Timestamp:** [ISO 8601]

### Design Concern
<!-- REQUIRED: Why this is a design issue, not an implementation issue -->
[clear explanation — what assumption is wrong at the design level]

### Evidence
<!-- REQUIRED: What in the code reveals the design problem? -->
[specific finding — file, pattern, or structural issue]

### Principle Violated
[DDD bounded context / layer ownership / ADR contradiction / FP structural issue]

### Question for Architect
<!-- REQUIRED: What specific decision needs to be revisited? -->
[clear question]

**All dev work is paused until architect provides a revised ADR or clarification.**
**Tech-lead: do not reassign dev work until architect responds.**
```

---

## Validation (tech-lead must check on receipt)

- [ ] Exactly one decision block is present (not multiple)
- [ ] Decision is one of: APPROVE / REQUEST CHANGES / ESCALATE TO ARCHITECT
- [ ] If REQUEST CHANGES: blocking issues table has at least one entry with all columns filled
- [ ] If ESCALATE: question for architect is specific and actionable
- [ ] Review cycle number is tracked (if cycle 3+ and still requesting changes → tech-lead must intervene)

---

## Example (valid — APPROVE)

```markdown
## REVIEWER DECISION

**Decision:** ✅ APPROVE
**Pipeline run:** T-001 through T-005
**Reviewed by:** reviewer agent
**Timestamp:** 2026-04-09T14:30:00Z

### Summary
Reviewed Order aggregate confirm() implementation in Scala 3 (T-002) and associated QA (T-005).
Domain logic is pure, all errors typed, no infrastructure leakage. Coverage above threshold.

### Coverage
**Final coverage:** 78% — threshold: 75% ✅

### Principles
- FP: ✅ Pure functions, Either-based errors, no var/null
- DDD: ✅ Domain logic in domain layer, events past tense, aggregate enforces invariants
- Clean Code: ✅ Functions do one thing, names from domain, no magic

### Follow-up Tasks (non-blocking)
- [ ] Add property-based test for OrderItem quantity validation (low priority)

**Ready to merge. No further action required.**
```

---

## Example (valid — REQUEST CHANGES)

```markdown
## REVIEWER DECISION

**Decision:** 🔁 REQUEST CHANGES
**Return to:** backend-dev
**Task ID(s) to rework:** T-004
**Pipeline run:** T-001 through T-005
**Timestamp:** 2026-04-09T15:00:00Z
**Review cycle:** 1

### Blocking Issues
| # | Issue | Location | Principle violated | Required fix |
|---|-------|----------|--------------------|-------------|
| 1 | `panic!("Currency mismatch")` in add() | src/domain/money.rs:15 | FP — partial function | Return `Result<Money, DomainError>` instead |
| 2 | `.unwrap()` on parse result | src/domain/money.rs:22 | FP — hard gate | Use `?` operator or explicit match |
| 3 | `pub amount: i64` | src/domain/money.rs:3 | Clean Code — encapsulation | Make fields private, add getter methods |
| 4 | `currency: String` | src/domain/money.rs:4 | Clean Code — primitive obsession | Use Currency enum |

### Non-blocking Notes
- Consider adding `#[derive(Debug)]` on Money

### Re-review Scope
**Only the 4 blocking issues above will be re-checked. New issues will not be introduced in the re-review.**
```
