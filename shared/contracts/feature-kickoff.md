# Feature Kickoff Contract

**Producer:** tech-lead
**Consumers:** all assigned agents, product-owner (for tracking)
**Purpose:** Single source of truth for a feature as it moves through the pipeline. Created once, updated as the feature progresses.

---

## FEATURE KICKOFF

### Feature Identity
**Feature ID:** F-[NNN]
**Title:** [Short descriptive title]
**PRD reference:** [link to PRD]
**ADR reference:** [link to ADR or "N/A — small feature"]
**Priority:** P0 (critical) | P1 (high) | P2 (medium) | P3 (low)

### Scope
**In scope:** [bullet list — what this feature DOES include]
**Out of scope:** [bullet list — what this feature does NOT include, even if related]
**Scope freeze date:** [date after which scope changes require a formal change request]

### Acceptance Criteria (from PRD)
<!-- Copy verbatim from PRD — these are the criteria for acceptance testing -->
- [ ] AC-1: [Given/When/Then]
- [ ] AC-2: [Given/When/Then]
- [ ] AC-3: [Given/When/Then]

### Success Metrics (from measurement-plan)
| Metric | Baseline | Target | Measurement method |
|--------|----------|--------|-------------------|
| [metric] | [current] | [goal] | [how measured] |

### Estimation
| Task ID | Agent | Description | Estimate | Actual | Status |
|---------|-------|-------------|----------|--------|--------|
| T-001 | backend-dev | [task description] | S | — | Not started |
| T-002 | android-dev | [task description] | M | — | Not started |
| T-003 | video-streaming | [task description] | L | — | Not started |

**Estimates:** S = <1 day, M = 1-3 days, L = 3-5 days, XL = 5+ days (decompose further)

**Total estimated:** [N days]
**Target delivery:** [ISO 8601 date]
**Confidence:** High | Medium | Low

### Rollout Plan
**Strategy:** feature-flag | canary | phased | big-bang
**Feature flag name:** `feature_[domain]_[capability]` (if applicable)
**Rollout phases:**
1. Internal dogfood (team only)
2. Beta customers ([X]% of fleet)
3. General availability

### Rollback Plan
**Feature-level rollback:** [how to disable — feature flag off, revert commit, etc.]
**Data rollback:** [any data migration to reverse? Yes/No + details]

### Definition of Done (Pipeline-Level)
- [ ] All acceptance criteria pass (validated by product-owner)
- [ ] Code review approved (reviewer)
- [ ] Security scan clean — no High/Critical (security-agent)
- [ ] Performance within SLO (perf-agent)
- [ ] Observability instrumented (observability-agent)
- [ ] Documentation updated (docs-agent)
- [ ] Monitoring/alerting configured for new endpoints
- [ ] Feature flag configured (if applicable)
- [ ] Stakeholder demo completed and approved
- [ ] Release notes drafted

### Status Log
| Date | Phase | Update |
|------|-------|--------|
| [ISO 8601] | Kickoff | Feature kickoff produced by tech-lead |
