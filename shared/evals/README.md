# Evals

Test cases for each agent skill. Use these to measure whether a skill is actually helping,
to catch regressions when you edit a skill, and to iterate systematically.

## Structure

```
evals/
├── README.md              ← this file
├── architect/
│   ├── eval-001-new-feature-adr.md
│   ├── eval-002-design-escalation.md
│   └── eval-003-cross-context-boundary.md
├── tech-lead/
│   ├── eval-001-task-decomposition.md
│   ├── eval-002-blocker-escalation.md
│   └── eval-003-rust-pipeline.md
├── backend-dev/
│   ├── eval-001-domain-layer-purity.md
│   ├── eval-002-scala3-aggregate.md
│   └── eval-003-rust-value-object.md
├── frontend-dev/
│   ├── eval-001-pure-component.md
│   ├── eval-002-contract-mismatch.md
│   └── eval-003-leptos-component.md
├── qa-agent/
│   ├── eval-001-domain-invariant-coverage.md
│   └── eval-002-no-impl-mirroring.md
│
├── devops-agent/
│   ├── eval-001-no-secrets-in-manifest.md
│   └── eval-002-rollback-plan.md
│
└── reviewer/
    ├── eval-001-approve-clean-output.md
    ├── eval-002-reject-fp-violation.md
    ├── eval-003-reject-ddd-violation.md
    └── eval-004-escalate-design-issue.md
```

## Eval Format

Each eval file contains:
- **Input**: the prompt or artifact the agent receives
- **Expected behavior**: what the agent should do (not word-for-word output)
- **Pass criteria**: specific, verifiable checklist
- **Fail criteria**: things that would constitute a failure
- **Tags**: what principle/behavior is being tested

## Running Evals

Evals are currently manual (read the input, run the agent, check against criteria).
Future: automate via a harness that spawns the agent and scores output against pass/fail criteria.

## Scoring

For each eval: Pass ✅ | Partial ⚠️ | Fail ❌

Track results in a table per agent per date. If an agent fails 2+ evals after a skill edit,
revert and investigate before merging.
