# Scope Change Request Contract

**Producer:** any agent that discovers scope needs to change
**Consumers:** product-owner (approves/rejects), tech-lead (re-estimates)
**Purpose:** Formal mechanism to prevent scope creep mid-pipeline. Any scope change after the scope-freeze-date in feature-kickoff.md must use this contract.

---

## SCOPE CHANGE REQUEST

### Feature Reference
**Feature ID:** F-[NNN]
**Requested by:** [agent name]
**Date:** [ISO 8601]
**Pipeline phase at time of request:** Requirements | Design | Architecture | Implementation | QA | Review | Release

### Change Description
**What changed:** [clear description of the proposed scope change]
**Why:** [technical discovery / user feedback / dependency / blocker / other]
**Discovery context:** [what were you doing when you found this?]

### Impact Assessment
**Timeline impact:** none | +[N] days | unknown — needs re-estimation
**Agents affected:** [list of agents whose tasks change]
**Tasks to add:** [new task IDs and descriptions, or "none"]
**Tasks to remove:** [task IDs no longer needed, or "none"]
**Risk of NOT making this change:** [what breaks or becomes harder if we skip it?]

### Options
| Option | Impact | Recommendation |
|--------|--------|----------------|
| A: Include in this release | +[N] days | [if recommended, why] |
| B: Defer to next release | No timeline impact | [if recommended, why] |
| C: Modify scope (partial include) | [trade-off] | [if recommended, why] |

### Decision
**Decision:** [A / B / C — filled by product-owner]
**Rationale:** [why this option]
**PRD updated:** Yes / No
**Feature kickoff updated:** Yes / No
**Date:** [ISO 8601]
**Decided by:** product-owner
