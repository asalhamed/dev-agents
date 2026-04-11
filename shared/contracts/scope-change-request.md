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

---

## Validation (product-owner checks before deciding)

- [ ] Change description is specific (not "we need more time")
- [ ] Reason is technical, not preference-based
- [ ] Impact assessment includes timeline and affected agents
- [ ] At least two options presented (include vs defer)
- [ ] Decision section filled in after review

## Example (valid)

```markdown
## SCOPE CHANGE REQUEST

### Feature Reference
**Feature ID:** F-012
**Requested by:** backend-dev (T-003)
**Date:** 2026-05-05T14:30:00Z

### Change Description
**What changed:** Alert API needs to support configurable motion sensitivity thresholds per camera, not just a global threshold
**Why:** During implementation, discovered that different camera locations (indoor vs outdoor) have vastly different motion baselines — a global threshold causes excessive false positives outdoors

### Impact Assessment
**Timeline impact:** +2 days (M estimate for per-camera config)
**Agents affected:** backend-dev (config API), edge-agent (threshold config sync), android-dev (settings UI)
**Tasks to add:** T-003b (config API), T-002b (edge threshold sync)
**Tasks to remove:** none
**Risk:** Without this, outdoor cameras will generate 10x false positive alerts

### Options
| Option | Impact | Recommendation |
|--------|--------|----------------|
| A: Include per-camera thresholds | +2 days | Recommended — prevents false positive flood |
| B: Defer to F-015 | No delay | Risk: poor first impression for beta users |

### Decision
**Decision:** A — include in this release
**Rationale:** False positives would undermine the feature's core value
**PRD updated:** Yes — added AC-4 for per-camera threshold
**Feature kickoff updated:** Yes — T-003b and T-002b added, target date +2 days
**Date:** 2026-05-05T16:00:00Z
**Decided by:** product-owner
```
