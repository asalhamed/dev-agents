# dev-agents

A reusable multi-agent development team for OpenClaw. Each agent is an AgentSkill with a focused role in a DDD-aligned, FP-first, clean-code development pipeline.

## Engineering Canon

All agents operate under three non-negotiable principles — read [`PRINCIPLES.md`](PRINCIPLES.md) first:

| Principle | Summary |
|-----------|---------|
| **Functional Programming** | Pure functions, immutability, effects as values, typed errors, total functions |
| **Domain-Driven Design** | Bounded contexts, aggregates, domain events, ubiquitous language, layered architecture |
| **Clean Code** | Names reveal intent, functions do one thing, no magic, no noise |

## The Team

| Agent | Role | File |
|-------|------|------|
| 🏛️ `architect` | Design decisions, ADRs, domain modeling, contract definition | [`architect/SKILL.md`](architect/SKILL.md) |
| 🧑‍💼 `tech-lead` | Task decomposition, pipeline orchestration, agent coordination | [`tech-lead/SKILL.md`](tech-lead/SKILL.md) |
| 🔧 `backend-dev` | Backend implementation (Rust, Scala 3, Scala 2, TS, Go) | [`backend-dev/SKILL.md`](backend-dev/SKILL.md) |
| 🎨 `frontend-dev` | Frontend implementation (Leptos, Vue/Nuxt, React, Svelte) | [`frontend-dev/SKILL.md`](frontend-dev/SKILL.md) |
| 🧪 `qa-agent` | Test writing, coverage, QA reports | [`qa-agent/SKILL.md`](qa-agent/SKILL.md) |
| 🚀 `devops-agent` | CI/CD, K8s manifests, Docker, infra | [`devops-agent/SKILL.md`](devops-agent/SKILL.md) |
| 🔍 `reviewer` | Code review, quality gates, approve/reject/escalate | [`reviewer/SKILL.md`](reviewer/SKILL.md) |

## Pipeline

```
                        ┌─────────────┐
                        │  architect  │  ← entry for new features / design concerns
                        └──────┬──────┘
                               │ ADR + contracts
                        ┌──────▼──────┐
                        │  tech-lead  │  ← entry for small tasks / bug fixes
                        └──────┬──────┘
                               │ task breakdown
              ┌────────────────┼────────────────┐
       ┌──────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐
       │ backend-dev │  │ frontend-dev│  │devops-agent │
       └──────┬──────┘  └──────┬──────┘  └──────┬──────┘
              └────────────────┼────────────────┘
                               │ implementations
                        ┌──────▼──────┐
                        │  qa-agent   │
                        └──────┬──────┘
                               │ test results
                        ┌──────▼──────┐
                        │  reviewer   │
                        └──────┬──────┘
                               │
                ┌──────────────┼──────────────┐
         ✅ Approve      🔁 Fix (→ dev)   🏛️ Escalate (→ architect)
```

**When to start at architect:**
- New services, integrations, cross-context features
- Schema changes or new Kafka topics
- Anything that affects bounded context boundaries

**When to start at tech-lead:**
- Bug fixes, small tasks, single-file changes
- Tasks with a clear, existing pattern to follow

## Stack Support

| Stack | backend-dev | frontend-dev | qa-agent | devops-agent |
|-------|-------------|--------------|----------|--------------|
| 🦀 Rust | ✅ (with references/) | ✅ Leptos | ✅ cargo test / tarpaulin | ✅ multi-stage Docker / GHA |
| ⚡ Scala 3 | ✅ (with references/) | — | ✅ MUnit / scalacheck | ✅ sbt-native-packager / GHA |
| 🔵 Scala 2 | ✅ | — | ✅ ScalaTest | ✅ |
| 🟦 TypeScript | ✅ | ✅ Vue/Nuxt/React/Svelte | ✅ vitest | ✅ |
| 🐳 K8s / Kustomize | — | — | — | ✅ |

## Using in a Project

### Option 1: Copy into project workspace
```bash
cp -r dev-agents/ /path/to/project/.openclaw/skills/
```

### Option 2: Symlink from openclaw skills directory
```bash
ln -s /path/to/dev-agents/* ~/.nvm/versions/node/v24.14.1/lib/node_modules/openclaw/skills/
```

### Option 3: Reference in openclaw config
```yaml
# openclaw.json
agents:
  skills:
    paths:
      - /path/to/dev-agents
```

### Customizing for a project
Each skill has a **stack-specific notes** section (or references/) designed to be filled in per project.
For example, `backend-dev` `references/` contains Rust and Scala 3 patterns — add your own stack there.

## File Structure

```
dev-agents/
├── README.md                          ← this file
├── PRINCIPLES.md                      ← FP + DDD + Clean Code canon (all agents reference this)
├── CONTRIBUTING.md                    ← how to add/modify skills and run evals
├── .gitignore
│
├── shared/
│   ├── glossary.md                    ← ubiquitous language dictionary
│   ├── contracts/
│   │   ├── README.md                  ← contract chain diagram + index
│   │   ├── architect-output.md        ← architect → tech-lead
│   │   ├── task-brief.md              ← tech-lead → dev agents
│   │   ├── implementation-summary.md  ← backend-dev / frontend-dev → qa-agent + reviewer
│   │   ├── devops-summary.md          ← devops-agent → reviewer
│   │   ├── qa-report.md               ← qa-agent → reviewer
│   │   └── reviewer-decision.md       ← reviewer → tech-lead
│   └── evals/                         ← detailed markdown eval cases per agent
│       ├── architect/
│       ├── tech-lead/
│       ├── backend-dev/
│       ├── frontend-dev/
│       ├── qa-agent/
│       ├── devops-agent/
│       └── reviewer/
│
├── architect/
│   ├── SKILL.md
│   ├── evals/evals.json
│   └── references/
│       └── example-adr.md             ← completed ADR as a learning example
├── tech-lead/
│   ├── SKILL.md
│   └── evals/evals.json
├── backend-dev/
│   ├── SKILL.md
│   ├── evals/evals.json
│   └── references/
│       ├── rust-patterns.md           ← Rust DDD patterns, error handling, testing
│       ├── scala3-patterns.md         ← Scala 3 opaque types, ADTs, aggregates, ZIO/cats
│       ├── go-patterns.md             ← Go newtype pattern, error handling, table-driven tests
│       └── typescript-patterns.md     ← branded types, Either/Result, discriminated unions
├── frontend-dev/
│   ├── SKILL.md
│   ├── evals/evals.json
│   └── references/
│       ├── leptos-patterns.md         ← Rust/WASM reactive components, server functions
│       └── a11y-standards.md          ← accessibility requirements for all frameworks
├── qa-agent/
│   ├── SKILL.md
│   └── evals/evals.json
├── devops-agent/
│   ├── SKILL.md
│   ├── evals/evals.json
│   ├── scripts/
│   │   └── validate_manifests.sh      ← pre-commit K8s/Docker/CI validation
│   └── references/
│       └── observability.md           ← metrics, logging, tracing, health endpoints
└── reviewer/
    ├── SKILL.md
    ├── evals/evals.json
    └── scripts/
        └── automated_gates.sh         ← mechanical hard-gate checks (unwrap, var, secrets, etc.)
```
