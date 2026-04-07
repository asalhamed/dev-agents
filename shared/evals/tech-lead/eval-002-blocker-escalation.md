# Eval: tech-lead — 002 — Handling Blocker Mid-Pipeline

**Tags:** escalation, blocker handling, pipeline pause, scope control
**Skill version tested:** initial

---

## Input

Tech-lead has already spawned 3 tasks for a pipeline run. Backend-dev returns this
`implementation-summary` for T-002 with an escalation:

~~~
## IMPLEMENTATION SUMMARY

### Task Reference
**Task ID:** T-002
**Agent:** backend-dev
**Task:** Implement UpdatePreference use case in application layer
**Stack:** Scala 3
**Layer(s):** application

### Approach
Started implementing UpdatePreference use case. Hit a design issue:
the NotificationPreference aggregate requires checking against a
CustomerPlan (free vs premium) to determine which channels are available.
Free-tier customers can only use Email; SMS and Push require Premium.

This crosses into the billing bounded context — the architect's ADR
(ADR-012) did not mention this constraint or define an ACL for billing.

### Files Changed
| File | Change |
|------|--------|
| (none — blocked before implementation) | |

### Contracts Implemented
| Contract item | Status | Notes |
|---|---|---|
| UpdatePreference use case | ❌ Blocked | Requires billing context data |

### Escalations Required
escalate to architect: ADR-012 does not address channel availability by customer plan.
Need an ACL or domain event from billing context to determine which channels a customer
can use. Cannot implement UpdatePreference without this.
~~~

Meanwhile, T-001 (domain layer) completed successfully, and T-003 (Postgres repo)
has not started yet.

---

## Expected Behavior

The tech-lead should:
1. Recognize this as a **design issue**, not an implementation issue
2. Pause the entire pipeline — do NOT continue with T-003
3. Escalate to architect with a clear description of what's needed
4. Inform the user that the pipeline is paused and why
5. NOT silently expand scope to add billing integration
6. NOT tell backend-dev to work around it

---

## Pass Criteria

- [ ] Pipeline paused — T-003 not spawned or explicitly held
- [ ] Escalation sent to architect (not just flagged — actually escalated)
- [ ] Escalation clearly states: ADR-012 missing billing context dependency
- [ ] Escalation asks architect for specific decision: ACL design or domain event from billing
- [ ] User informed of pause with clear reason
- [ ] No scope expansion — tech-lead does not add billing tasks on their own
- [ ] T-001 result preserved (not discarded)
- [ ] Backend-dev not told to "just mock it" or "work around it"

---

## Fail Criteria

- Continues pipeline despite blocker → ❌ violated escalation rules
- Tells backend-dev to hardcode channel availability → ❌ scope creep + DDD violation
- Silently adds billing integration tasks without architect → ❌ design decision without architect
- Doesn't inform user → ❌ transparency violation
- Escalates to reviewer instead of architect → ❌ wrong escalation target (this is design, not code quality)
- Discards T-001 results and restarts from scratch → ❌ unnecessary rework
