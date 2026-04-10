# dev-agents

A reusable multi-agent development team for OpenClaw. Each agent is an AgentSkill with a focused role in a DDD-aligned, FP-first, clean-code development pipeline.

## Engineering Canon

All agents operate under three non-negotiable principles — read [`PRINCIPLES.md`](PRINCIPLES.md) first:

| Principle | Summary |
|-----------|---------|
| **Functional Programming** | Pure functions, immutability, effects as values, typed errors, total functions |
| **Domain-Driven Design** | Bounded contexts, aggregates, domain events, ubiquitous language, layered architecture |
| **Clean Code** | Names reveal intent, functions do one thing, no magic, no noise |

## Agent Team (35 Agents)

### Business Division
| Agent | Role |
|-------|------|
| `product-owner` 📋 | PRDs, acceptance criteria, feature prioritization |
| `business-analyst` 📊 | User stories, business rules, domain terms |
| `data-analyst` 📈 | Success metrics, analytics instrumentation, A/B tests |

### Design Division
| Agent | Role |
|-------|------|
| `ux-researcher` 🔬 | User needs, personas, journey mapping |
| `ui-designer` 🎨 | Component specs, design system, responsive layouts |
| `api-designer` 📐 | REST/GraphQL contracts, OpenAPI specs |

### Engineering Division
| Agent | Role |
|-------|------|
| `architect` 🏛️ | Domain modeling, bounded contexts, ADRs |
| `tech-lead` 🧑‍💼 | Task decomposition, pipeline coordination |
| `backend-dev` 💻 | Domain logic, services, APIs (Rust, Scala 3, Go, TypeScript) |
| `frontend-dev` 🖥️ | UI components, state management (Vue/Nuxt, React, Leptos) |
| `devops-agent` 🚀 | K8s manifests, CI/CD, infrastructure |
| `qa-agent` 🧪 | Behavioral tests, domain invariant coverage |
| `reviewer` 🔍 | FP/DDD gate, coverage enforcement, final approval |
| `security-agent` 🛡️ | Threat modeling, security scanning, OWASP review |
| `db-migration` 🗄️ | Schema evolution, migration safety, rollback scripts |
| `perf-agent` ⚡ | Benchmarks, profiling, N+1 detection |

### Operations Division
| Agent | Role |
|-------|------|
| `observability-agent` 📡 | Instrumentation audit, SLO validation, alert rules |
| `docs-agent` 📝 | API docs, ADR index, changelogs |

### Domain Engineering
| Agent | Role |
|-------|------|
| `android-dev` 📱 | Android app, live video, offline-first, Kotlin/Compose |
| `iot-dev` 🔌 | Firmware, MQTT, device protocols, embedded Rust |
| `video-streaming` 🎥 | Video pipelines, WebRTC, RTSP, HLS, recording |
| `edge-agent` 🖥️ | Edge computing, local inference, store-and-forward |
| `ml-engineer` 🧠 | ML models, anomaly detection, video analytics, MLOps |

### Data Platform
| Agent | Role |
|-------|------|
| `data-engineer` 🔧 | Data pipelines, Kafka, time-series, video storage |
| `analytics-engineer` 📊 | Dashboards, dbt models, fleet analytics, reporting |

### Business Operations
| Agent | Role |
|-------|------|
| `marketing` 📣 | Content, campaigns, positioning, lead generation |
| `sales` 💼 | Proposals, RFPs, pipeline management, deal closing |
| `customer-success` 🤝 | Onboarding, health scoring, retention, support |
| `finance` 💰 | Pricing, unit economics, runway, financial modeling |
| `legal` ⚖️ | Contracts, privacy, compliance, SLA review |
| `hr` 👥 | Hiring, job descriptions, team structure, onboarding |

### Strategy
| Agent | Role |
|-------|------|
| `growth-strategist` 🚀 | GTM strategy, market analysis, vertical targeting |
| `partnerships-agent` 🤝 | Hardware partners, channel partners, integrations |

### Specialized Operations
| Agent | Role |
|-------|------|
| `incident-responder` 🚨 | Incident management, postmortems, runbooks |
| `compliance-agent` 🔒 | SOC2, GDPR, ISO 27001, IoT security standards |

## Pipeline

### Full Flow (18 agents)

```
  ┌──────────────┐
  │product-owner │  ← "what should we build and why"
  └──────┬───────┘
         │ PRD
    ┌────┼────────────┐
┌───▼────────┐  ┌─────▼──────┐
│business-   │  │data-analyst│
│analyst     │  │            │
└───┬────────┘  └─────┬──────┘
    │ user stories     │ measurement plan
    │ business rules   │
    └────┬─────────────┘
         │
  ┌──────▼───────┐
  │ux-researcher │  ← "who are the users, what do they need"
  └──────┬───────┘
         │ UX spec
    ┌────┼────┐
┌───▼───┐ ┌──▼──────────┐
│ui-    │ │api-designer │
│design │ │             │
└───┬───┘ └──┬──────────┘
    │ UI      │ API
    │ spec    │ spec
    └────┬────┘
         │
  ┌──────▼───────┐
  │  architect   │  ← "how should we build it"
  └──────┬───────┘
         │ ADR + contracts
    ┌────┼────────────┐
┌───▼────────┐  ┌─────▼──────────┐
│db-migration│  │security-agent  │ ← threat model
└───┬────────┘  └─────┬──────────┘
    │ migration        │ security reqs
    │ scripts          │
    └────┬─────────────┘
         │
  ┌──────▼───────┐
  │  tech-lead   │  ← "who does what, in what order"
  └──────┬───────┘
         │ task briefs
    ┌────┼────────────┐
┌───▼──────┐ ┌───▼──────┐ ┌───▼──────┐
│backend-  │ │frontend- │ │devops-   │
│dev       │ │dev       │ │agent     │
└───┬──────┘ └───┬──────┘ └───┬──────┘
    └────────────┼────────────┘
                 │ implementations
          ┌──────▼───────┐
          │  qa-agent    │
          └──────┬───────┘
                 │ test results
    ┌────────────┼────────────┐
┌───▼──────────┐ ┌───▼──────┐ ┌───▼─────────────┐
│security-agent│ │perf-agent│ │observability-    │
│(scan phase)  │ │          │ │agent             │
└───┬──────────┘ └───┬──────┘ └───┬─────────────┘
    └────────────────┼────────────┘
                     │
              ┌──────▼───────┐
              │  reviewer    │
              └──────┬───────┘
                     │
        ┌────────────┼────────────┐
   ✅ Approve   🔁 Fix        🏛️ Escalate
        │
  ┌─────▼────┐
  │docs-agent│  ← post-approval documentation
  └──────────┘
```

### Shortcut: Engineering Only

For small tasks, bug fixes, or tasks with an existing pattern — skip business and design layers:

```
tech-lead → backend-dev / frontend-dev / devops-agent → qa-agent → reviewer
```

## When to Start Where

| Signal | Start at |
|---|---|
| "new market", "growth opportunity", "GTM" | growth-strategist |
| "partnership", "hardware vendor", "integration" | partnerships-agent |
| "feature idea", "PRD", "roadmap", "what to build" | product-owner |
| "user research", "persona", "journey" | ux-researcher |
| "API design", "endpoint" | api-designer |
| "system design", "bounded context", "ADR" | architect |
| "Android app", "mobile feature" | android-dev |
| "firmware", "MQTT", "device protocol", "IoT" | iot-dev |
| "video stream", "camera feed", "WebRTC", "RTSP" | video-streaming |
| "edge processing", "local inference" | edge-agent |
| "ML model", "anomaly detection", "computer vision" | ml-engineer |
| "data pipeline", "time-series", "Kafka" | data-engineer |
| "dashboard", "analytics", "reporting" | analytics-engineer |
| "security review", "threat model" | security-agent |
| "schema change", "migration" | db-migration |
| "bug fix", "implement", "small task" | tech-lead |
| "marketing", "content", "campaign" | marketing |
| "sales", "proposal", "demo" | sales |
| "customer issue", "onboarding", "churn" | customer-success |
| "pricing", "budget", "runway" | finance |
| "contract", "NDA", "privacy policy" | legal |
| "SOC2", "GDPR audit", "compliance" | compliance-agent |
| "incident", "outage", "postmortem" | incident-responder |
| "hiring", "job description", "team structure" | hr |
| "performance", "slow", "benchmark" | perf-agent |
| "monitoring", "alerting", "SLO" | observability-agent |
| "documentation", "API docs" | docs-agent |

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
├── README.md
├── PRINCIPLES.md                      ← FP + DDD + Clean Code + Security + Product canon
├── CONTRIBUTING.md
├── .gitignore
│
├── shared/
│   ├── glossary.md                    ← ubiquitous language dictionary
│   ├── contracts/                     ← 18 handoff contracts between agents
│   │   ├── README.md                  ← contract chain diagram + index
│   │   ├── prd.md                     ← product-owner → business-analyst, ux-researcher
│   │   ├── business-requirements.md   ← business-analyst → architect, ux-researcher
│   │   ├── measurement-plan.md        ← data-analyst → tech-lead, devs
│   │   ├── ux-spec.md                ← ux-researcher → ui-designer, architect
│   │   ├── ui-spec.md               ← ui-designer → frontend-dev
│   │   ├── api-spec.md              ← api-designer → backend-dev, frontend-dev, docs-agent
│   │   ├── architect-output.md       ← architect → tech-lead, db-migration, security-agent
│   │   ├── threat-model.md           ← security-agent → tech-lead
│   │   ├── migration-plan.md         ← db-migration → tech-lead, backend-dev
│   │   ├── task-brief.md             ← tech-lead → dev agents
│   │   ├── implementation-summary.md ← backend-dev / frontend-dev → qa-agent + reviewer
│   │   ├── devops-summary.md         ← devops-agent → reviewer
│   │   ├── qa-report.md              ← qa-agent → reviewer
│   │   ├── security-scan.md          ← security-agent → reviewer
│   │   ├── perf-report.md            ← perf-agent → reviewer
│   │   ├── observability-audit.md    ← observability-agent → reviewer
│   │   ├── reviewer-decision.md      ← reviewer → tech-lead
│   │   └── docs-summary.md           ← docs-agent → tech-lead
│   └── evals/                         ← detailed markdown eval cases (all 18 agents)
│
│── Business Division
├── product-owner/
│   ├── SKILL.md
│   ├── evals/evals.json
│   └── references/
├── business-analyst/
│   ├── SKILL.md
│   ├── evals/evals.json
│   └── references/
├── data-analyst/
│   ├── SKILL.md
│   ├── evals/evals.json
│   └── references/
│
│── Design Division
├── ux-researcher/
│   ├── SKILL.md
│   ├── evals/evals.json
│   └── references/
├── ui-designer/
│   ├── SKILL.md
│   ├── evals/evals.json
│   └── references/
├── api-designer/
│   ├── SKILL.md
│   ├── evals/evals.json
│   └── references/
│
│── Engineering Division
├── architect/
│   ├── SKILL.md
│   ├── evals/evals.json
│   └── references/
│       └── example-adr.md
├── tech-lead/
│   ├── SKILL.md
│   └── evals/evals.json
├── backend-dev/
│   ├── SKILL.md
│   ├── evals/evals.json
│   └── references/
│       ├── rust-patterns.md
│       ├── scala3-patterns.md
│       ├── go-patterns.md
│       └── typescript-patterns.md
├── frontend-dev/
│   ├── SKILL.md
│   ├── evals/evals.json
│   └── references/
│       ├── leptos-patterns.md
│       └── a11y-standards.md
├── qa-agent/
│   ├── SKILL.md
│   └── evals/evals.json
├── devops-agent/
│   ├── SKILL.md
│   ├── evals/evals.json
│   ├── scripts/
│   │   └── validate_manifests.sh
│   └── references/
│       └── observability.md
├── reviewer/
│   ├── SKILL.md
│   ├── evals/evals.json
│   └── scripts/
│       └── automated_gates.sh
├── security-agent/
│   ├── SKILL.md
│   ├── evals/evals.json
│   └── references/
│       ├── owasp-top10.md
│       ├── auth-patterns.md
│       └── dependency-scanning.md
├── db-migration/
│   ├── SKILL.md
│   ├── evals/evals.json
│   └── references/
│       ├── migration-strategies.md
│       └── migration-tools.md
├── perf-agent/
│   ├── SKILL.md
│   ├── evals/evals.json
│   └── references/
│       ├── rust-perf.md
│       ├── scala-perf.md
│       └── load-testing.md
│
│── Operations Division
├── observability-agent/
│   ├── SKILL.md
│   ├── evals/evals.json
│   └── references/
│       ├── slo-template.md
│       └── runbook-template.md
└── docs-agent/
    ├── SKILL.md
    ├── evals/evals.json
    └── references/
        ├── openapi-template.md
        ├── changelog-format.md
        └── context-map.md
```
