# Evals

Test cases for each agent skill. Use these to measure whether a skill is actually helping,
to catch regressions when you edit a skill, and to iterate systematically.

## Structure

```
evals/
├── README.md
├── architect/
│   ├── eval-001-new-feature-adr.md
│   └── eval-002-cross-context-boundary.md
├── tech-lead/
│   ├── eval-001-task-decomposition.md
│   ├── eval-002-blocker-escalation.md
│   └── eval-003-rust-pipeline.md
├── backend-dev/
│   ├── eval-001-domain-layer-purity.md
│   └── eval-002-rust-value-object.md
├── frontend-dev/
│   ├── eval-001-pure-component.md
│   ├── eval-002-contract-mismatch.md
│   └── eval-003-leptos-component.md
├── qa-agent/
│   ├── eval-001-domain-invariant-coverage.md
│   └── eval-002-no-impl-mirroring.md
├── devops-agent/
│   ├── eval-001-no-secrets-in-manifest.md
│   └── eval-002-rollback-plan.md
├── reviewer/
│   ├── eval-001-approve-clean-output.md
│   ├── eval-002-reject-fp-violation.md
│   └── eval-003-escalate-design-issue.md
├── security-agent/
│   ├── eval-001-threat-model-payment.md
│   ├── eval-002-sql-injection-detection.md
│   └── eval-003-jwt-review.md
├── db-migration/
│   ├── eval-001-non-nullable-column.md
│   └── eval-002-column-rename.md
├── perf-agent/
│   ├── eval-001-n-plus-one-detection.md
│   └── eval-002-rust-hot-path.md
├── ux-researcher/
│   ├── eval-001-notification-preferences.md
│   └── eval-002-checkout-abandonment.md
├── ui-designer/
│   ├── eval-001-notification-panel.md
│   └── eval-002-order-history-list.md
├── api-designer/
│   ├── eval-001-order-api-design.md
│   └── eval-002-api-review-antipatterns.md
├── product-owner/
│   ├── eval-001-notification-prd.md
│   └── eval-002-feature-prioritization.md
├── business-analyst/
│   ├── eval-001-story-decomposition.md
│   └── eval-002-domain-terms.md
├── data-analyst/
│   ├── eval-001-measurement-plan.md
│   └── eval-002-ab-test-design.md
├── observability-agent/
│   ├── eval-001-instrumentation-audit.md
│   └── eval-002-alert-rules-review.md
└── docs-agent/
    ├── eval-001-api-documentation.md
    └── eval-002-adr-index-update.md
```

## Eval Format

Each eval file contains:
- **Input**: the prompt or artifact the agent receives
- **Expected behavior**: what the agent should do (not word-for-word output)
- **Pass criteria**: specific, verifiable checklist
- **Fail criteria**: things that would constitute a failure
- **Tags**: what principle/behavior is being tested

Each agent also has a co-located `evals/evals.json` for tooling compatibility.

## Running Evals

Evals are currently manual (read the input, run the agent, check against criteria).
Future: automate via a harness that spawns the agent and scores output against pass/fail criteria.

## Scoring

For each eval: Pass ✅ | Partial ⚠️ | Fail ❌

Track results in a table per agent per date. If an agent fails 2+ evals after a skill edit,
revert and investigate before merging.
