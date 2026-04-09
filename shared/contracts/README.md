# Handoff Contracts

Formal data contracts between agents. Every agent that produces output for another agent
must conform to the schema defined here. Every agent that consumes output from another
must validate against the schema defined here.

## Contract Chain

```
architect       → PRODUCES → architect-output.md
                → CONSUMED BY → tech-lead

tech-lead       → PRODUCES → task-brief.md (one per agent spawned)
                → CONSUMED BY → backend-dev, frontend-dev, qa-agent, devops-agent

backend-dev     → PRODUCES → implementation-summary.md
frontend-dev    → PRODUCES → implementation-summary.md
devops-agent    → PRODUCES → devops-summary.md
                → ALL CONSUMED BY → qa-agent, then reviewer

qa-agent        → PRODUCES → qa-report.md
                → CONSUMED BY → reviewer

reviewer        → PRODUCES → reviewer-decision.md
                → CONSUMED BY → tech-lead (to close loop or escalate)
```

## Full Pipeline Contract Flow

```
product-owner → [prd] → business-analyst, ux-researcher
business-analyst → [business-requirements] → architect, ux-researcher
data-analyst → [measurement-plan] → tech-lead, backend-dev, frontend-dev
ux-researcher → [ux-spec] → ui-designer, architect
ui-designer → [ui-spec] → frontend-dev
api-designer → [api-spec] → backend-dev, frontend-dev, docs-agent
architect → [architect-output] → tech-lead, db-migration, security-agent
security-agent → [threat-model] → tech-lead
db-migration → [migration-plan] → tech-lead, backend-dev
tech-lead → [task-brief] → backend-dev, frontend-dev, devops-agent
backend-dev/frontend-dev → [implementation-summary] → qa-agent, reviewer
devops-agent → [devops-summary] → reviewer
qa-agent → [qa-report] → reviewer
security-agent → [security-scan] → reviewer
perf-agent → [perf-report] → reviewer
observability-agent → [observability-audit] → reviewer
reviewer → [reviewer-decision] → tech-lead
docs-agent → [docs-summary] → tech-lead
```

## Validation Rules

Each agent must:
1. **Validate inputs** — if required fields are missing, stop and request them from the sending agent
2. **Produce complete outputs** — never hand off with missing required fields
3. **Use exact field names** — field names are part of the contract; don't rename them

## All Contracts (18)

| Contract | Producer | Consumer(s) | Phase |
|----------|----------|-------------|-------|
| prd.md | product-owner | business-analyst, ux-researcher | Business |
| business-requirements.md | business-analyst | architect, ux-researcher | Business |
| measurement-plan.md | data-analyst | tech-lead, backend-dev, frontend-dev | Business |
| ux-spec.md | ux-researcher | ui-designer, architect | Design |
| ui-spec.md | ui-designer | frontend-dev | Design |
| api-spec.md | api-designer | backend-dev, frontend-dev, docs-agent | Design |
| architect-output.md | architect | tech-lead, db-migration, security-agent | Engineering |
| threat-model.md | security-agent | tech-lead | Engineering |
| migration-plan.md | db-migration | tech-lead, backend-dev | Engineering |
| task-brief.md | tech-lead | backend-dev, frontend-dev, devops-agent | Engineering |
| implementation-summary.md | backend-dev, frontend-dev | qa-agent, reviewer | Engineering |
| devops-summary.md | devops-agent | reviewer | Engineering |
| qa-report.md | qa-agent | reviewer | Engineering |
| security-scan.md | security-agent | reviewer | Engineering |
| perf-report.md | perf-agent | reviewer | Engineering |
| observability-audit.md | observability-agent | reviewer | Engineering |
| reviewer-decision.md | reviewer | tech-lead | Engineering |
| docs-summary.md | docs-agent | tech-lead | Operations |

## Original Contract Files

| Contract | Producer | Consumer(s) |
|----------|----------|------------|
| [`architect-output.md`](architect-output.md) | architect | tech-lead |
| [`task-brief.md`](task-brief.md) | tech-lead | backend-dev, frontend-dev, qa-agent, devops-agent |
| [`implementation-summary.md`](implementation-summary.md) | backend-dev, frontend-dev | qa-agent, reviewer |
| [`devops-summary.md`](devops-summary.md) | devops-agent | reviewer |
| [`qa-report.md`](qa-report.md) | qa-agent | reviewer |
| [`reviewer-decision.md`](reviewer-decision.md) | reviewer | tech-lead |
