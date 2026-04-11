# Retrospective Contract

**Producer:** tech-lead
**Consumers:** all participating agents, product-owner
**Purpose:** Learning loop — what went well, what didn't, and what changes before the next feature. Mandatory after every feature delivery.

---

## FEATURE RETROSPECTIVE

### Feature Reference
**Feature ID:** F-[NNN]
**Title:** [title]
**Delivered:** [ISO 8601 date]
**Estimated duration:** [N days]
**Actual duration:** [N days]
**Delta:** [±N days] ([X]% variance)

### Timeline Analysis
| Phase | Estimated | Actual | Delta | Notes |
|-------|-----------|--------|-------|-------|
| Requirements & Design | [N]d | [N]d | [±N]d | |
| Architecture | [N]d | [N]d | [±N]d | |
| Implementation | [N]d | [N]d | [±N]d | |
| QA + Scans | [N]d | [N]d | [±N]d | |
| Review + Release | [N]d | [N]d | [±N]d | |

### What Went Well
- [specific thing that worked — be concrete, not generic]
- [specific thing that worked]

### What Didn't Go Well
- [specific thing that caused delay or quality issue — include root cause]
- [specific thing that caused rework]

### Scope Changes
| Change | When | Impact | Was it avoidable? |
|--------|------|--------|-------------------|
| [description] | [pipeline phase] | +[N] days | Yes/No — [why] |

### Blockers Encountered
| Blocker | Duration | Resolution | How to prevent |
|---------|----------|------------|----------------|
| [description] | [N days] | [how resolved] | [prevention] |

### Success Metrics
| Metric | Target | Actual | Status | Notes |
|--------|--------|--------|--------|-------|
| [from measurement-plan] | [target] | [actual] | ✅ / ❌ | |

### Estimation Accuracy
**Overall accuracy:** actual / estimated = [X]%
**Per-size accuracy:**
| Size | Estimated count | Avg estimated | Avg actual | Accuracy |
|------|-----------------|---------------|------------|----------|
| S | [N] | <1d | [actual] | [X]% |
| M | [N] | 1-3d | [actual] | [X]% |
| L | [N] | 3-5d | [actual] | [X]% |

**Lessons for future estimation:**
- [specific insight about what was over/under-estimated]

### Action Items
| Action | Owner | Due | Status |
|--------|-------|-----|--------|
| [specific, actionable improvement] | [agent] | [ISO 8601] | Open |

### Overall Assessment
**Feature delivered as scoped:** Yes / No / Partially
**Users/customers satisfied:** Yes / No / Unknown (pending data)
**Would we build it the same way again:** Yes / No / With changes — [what changes]

---

## Validation (tech-lead ensures completeness)

- [ ] Timeline analysis has estimated vs actual per phase
- [ ] At least 2 "what went well" items
- [ ] At least 2 "what didn't go well" items
- [ ] Scope changes documented with timeline impact
- [ ] Blockers documented with duration and prevention
- [ ] Metrics show actual vs target from measurement-plan
- [ ] Action items have owners and due dates

## Example (valid)

```markdown
## FEATURE RETROSPECTIVE

### Feature Reference
**Feature ID:** F-012
**Title:** Live Video Feed with Motion-Based Alerts
**Delivered:** 2026-05-16
**Estimated:** 12 days → **Actual:** 15 days

### Timeline Analysis
| Phase | Estimated | Actual | Delta | Notes |
|-------|-----------|--------|-------|-------|
| Architecture | 2d | 2d | 0 | ADR straightforward |
| Implementation | 7d | 9d | +2d | Scope change (per-camera thresholds) |
| QA + Scans | 2d | 2d | 0 | |
| Review + Release | 1d | 2d | +1d | First video feature — extra review time |

### What Went Well
- Feature flag rollout worked perfectly — caught a latency issue at 5% before full rollout
- Edge motion detection accuracy was better than expected (92% precision)

### What Didn't Go Well
- Scope change (per-camera thresholds) added 2 days mid-pipeline
- WebRTC TURN server configuration took longer than expected — no prior experience

### Scope Changes
| Change | When | Impact | Avoidable? |
|--------|------|--------|-----------|
| Per-camera motion thresholds | Day 5 (implementation) | +2 days | Partially — could have been caught in UX research |

### Blockers
| Blocker | Duration | Resolution | Prevention |
|---------|----------|------------|------------|
| TURN server config | 1 day | DevOps agent added TURN reference doc | Add to devops-agent/references/ |

### Metrics
| Metric | Target | Actual (week 1) | Status |
|--------|--------|-----------------|--------|
| Video load time | <3s p95 | 2.1s | ✅ |
| Alert latency | <5s p95 | 2.8s | ✅ |
| Daily active viewers | 50 in 30 days | 23 in 7 days | ✅ On track |

### Action Items
| Action | Owner | Due | Status |
|--------|-------|-----|--------|
| Add TURN server reference to devops-agent | devops-agent | 2026-05-23 | Open |
| Include camera environment analysis in UX research for future features | ux-researcher | Ongoing | Open |

### Overall Assessment
**Feature delivered as scoped:** Yes (with approved scope change)
**Users satisfied:** Yes — positive beta feedback
**Would we build it the same way again:** With changes — do UX research on camera environments earlier
```
