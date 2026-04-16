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
tech-lead → [feature-kickoff] → all agents, product-owner      ← Checkpoint 1
tech-lead → [task-brief] → backend-dev, frontend-dev, devops-agent
any agent → [scope-change-request] → product-owner, tech-lead    ← if scope drifts
backend-dev/frontend-dev → [implementation-summary] → qa-agent, reviewer
devops-agent → [devops-summary] → reviewer
qa-agent → [qa-report] → reviewer
qa-agent → [acceptance-test] → product-owner, reviewer
security-agent → [security-scan] → reviewer
perf-agent → [perf-report] → reviewer
observability-agent → [observability-audit] → reviewer
reviewer → [reviewer-decision] → tech-lead                       ← Checkpoint 2
product-owner → [acceptance-test sign-off] → tech-lead            ← Checkpoint 3
tech-lead + devops-agent → [release-plan] → product-owner, devops-agent
docs-agent → [docs-summary] → tech-lead
tech-lead → [retrospective] → all agents, product-owner           ← Checkpoint 4
```

## Validation Rules

Each agent must:
1. **Validate inputs** — if required fields are missing, stop and request them from the sending agent
2. **Produce complete outputs** — never hand off with missing required fields
3. **Use exact field names** — field names are part of the contract; don't rename them

## All Contracts (42)

### Core Engineering Contracts
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

### Domain-Specific Contracts
| Contract | Producer | Consumer(s) | Phase |
|----------|----------|-------------|-------|
| device-spec.md | iot-dev | qa-agent, reviewer | Domain |
| protocol-spec.md | iot-dev ↔ backend-dev | architect, tech-lead | Domain |
| streaming-spec.md | edge-media-agent | devops-agent, qa-agent, reviewer, observability-agent, privacy-agent | Domain |
| model-spec.md | ml-engineer | edge-media-agent, backend-dev | Domain |
| ota-plan.md | firmware-ota-agent | tech-lead, reviewer, compliance-agent, observability-agent, security-agent, iot-dev | Domain |
| privacy-review.md | privacy-agent | tech-lead, reviewer, compliance-agent, legal, product-owner, edge-media-agent, data-engineer | Domain |
| supply-chain-review.md | supply-chain-security-agent | tech-lead, reviewer, devops-agent, firmware-ota-agent, security-agent, compliance-agent | Domain |
| schema-registry.md | architect + data-engineer | backend-dev, edge-media-agent, iot-dev, ml-engineer, data-engineer, qa-agent, reviewer, supply-chain-security-agent | Domain |

### Delivery Lifecycle Contracts
| Contract | Producer | Consumer(s) | Phase |
|----------|----------|-------------|-------|
| feature-kickoff.md | tech-lead | all agents, product-owner | Delivery |
| acceptance-test.md | qa-agent | product-owner, reviewer | Delivery |
| scope-change-request.md | any agent | product-owner, tech-lead | Delivery |
| release-plan.md | tech-lead + devops-agent | product-owner, devops-agent | Delivery |
| retrospective.md | tech-lead | all agents, product-owner | Delivery |

### Standing Policy Contracts
| Contract | Type | Consumers | Phase |
|----------|------|-----------|-------|
| branching-and-release.md | Standing policy | all code-producing agents | Policy |
| ci-cd-pipeline.md | Standing policy | devops-agent, tech-lead | Policy |

### Business Operations Contracts
| Contract | Producer | Consumer(s) | Phase |
|----------|----------|-------------|-------|
| gtm-strategy.md | growth-strategist | product-owner, marketing, sales | Strategy |
| partnership-brief.md | partnerships-agent | product-owner, legal | Strategy |
| incident-report.md | incident-responder | tech-lead, observability-agent | Operations |
| compliance-audit.md | compliance-agent | legal, reviewer | Operations |
| marketing-brief.md | marketing | product-owner | Business Ops |
| sales-proposal.md | sales | legal, finance | Business Ops |
| customer-health.md | customer-success | product-owner, data-analyst | Business Ops |
| hiring-plan.md | hr | finance | Business Ops |
| financial-report.md | finance | growth-strategist, product-owner | Business Ops |


## Multi-Repo Contracts

These contracts support multi-repo microservice coordination:

| Contract | Purpose |
|----------|---------|
| [`service-contract-change.md`](service-contract-change.md) | Request to change a shared API/event contract in `platform-contracts` |
| [`service-dependency-map.md`](service-dependency-map.md) | Standing reference of which services produce/consume which contracts |
| [`cross-service-testing.md`](cross-service-testing.md) | Contract testing strategy (producer, consumer, unknown variant safety) |
| [`repo-setup.md`](repo-setup.md) | Standard repo structure + new service onboarding checklist |
