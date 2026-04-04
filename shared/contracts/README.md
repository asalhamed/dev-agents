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

## Validation Rules

Each agent must:
1. **Validate inputs** — if required fields are missing, stop and request them from the sending agent
2. **Produce complete outputs** — never hand off with missing required fields
3. **Use exact field names** — field names are part of the contract; don't rename them

## Files

| Contract | Producer | Consumer(s) |
|----------|----------|------------|
| [`architect-output.md`](architect-output.md) | architect | tech-lead |
| [`task-brief.md`](task-brief.md) | tech-lead | backend-dev, frontend-dev, qa-agent, devops-agent |
| [`implementation-summary.md`](implementation-summary.md) | backend-dev, frontend-dev | qa-agent, reviewer |
| [`devops-summary.md`](devops-summary.md) | devops-agent | reviewer |
| [`qa-report.md`](qa-report.md) | qa-agent | reviewer |
| [`reviewer-decision.md`](reviewer-decision.md) | reviewer | tech-lead |
