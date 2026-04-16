# Contributing to dev-agents

## Adding a New Agent Skill

1. **Create the directory** under the repo root:

```
new-agent/
├── SKILL.md
└── references/ # optional — stack-specific or domain-specific docs
```

Rubric cases live centrally under `shared/rubrics/<agent>/`, not in the agent directory.

2. **Write the SKILL.md** with:
   - YAML frontmatter: `name` (required), `description` (required, ~100 words with trigger keywords)
   - Body under 500 lines — push detail into `references/`
   - Workflow section with numbered steps
   - Self-review checklist
   - Output section referencing the appropriate `shared/contracts/` file
   - Escalation rules table

3. **Write the description** with explicit trigger keywords:
```yaml
  description: >
    [What the agent does. 1-2 sentences.]
    Trigger keywords: "phrase 1", "phrase 2", "phrase 3", ...
    [When to use. When NOT to use.]
```
   Aim for 8-10 trigger phrases that real users would say. Be slightly "pushy" —
   err toward triggering when relevant rather than being conservative.

4. **Add handoff contracts** if this agent produces output consumed by another agent:
   - Create `shared/contracts/new-agent-output.md`
   - Follow the format: Required Fields → Validation checklist → Example
   - Update `shared/contracts/README.md` with the new contract chain entry

5. **Write at least 2 rubric cases** in `shared/rubrics/new-agent/`:
   - One happy-path eval testing core behavior
   - One edge-case or escalation eval
   - Follow the format: Input → Expected Behavior → Pass Criteria → Fail Criteria
   - Use realistic prompts with varied tone (some formal, some casual)

6. **Update README.md**:
   - Add the agent to the Team table
   - Add to the pipeline diagram if it fits the flow
   - Update the File Structure section

## Modifying an Existing Skill

1. **Run existing evals first** to establish a baseline
2. Make your changes to SKILL.md or reference files
3. **Re-run all evals** — verify no regressions
4. If adding new capabilities, add matching eval(s)
5. If changing the output format, update the corresponding `shared/contracts/` file

## Modifying Contracts

Contracts are shared interfaces. Changes affect multiple agents.

1. **Check all consumers** of the contract (see `shared/contracts/README.md`)
2. Make the change in the contract file
3. Update all SKILL.md files that reference the changed fields
4. Run evals for both the producing and consuming agents
5. Prefer additive changes (new optional fields) over breaking changes (renamed/removed fields)

## Writing Good Evals

Good evals test behavior, not exact output wording.

**Do:**
- Use realistic prompts with personal context, typos, casual tone
- Test escalation paths (what happens when something goes wrong?)
- Test contract compliance (does the agent produce valid output?)
- Include both pass and fail criteria

**Don't:**
- Write prompts that are obviously "test prompts" — make them feel real
- Test only the happy path — edge cases matter more
- Require exact wording in output — test for presence of required fields/decisions

## Divisions and Entry Points

The team is organized into 4 divisions. Start at the right division to avoid rework:

**Business Division** — use when you need to define *what* to build:
- `product-owner` → feature requests, PRDs, prioritization
- `business-analyst` → user stories, business rules, domain terms
- `data-analyst` → success metrics, analytics instrumentation

**Design Division** — use when you need to define *how it should look and behave*:
- `ux-researcher` → user needs, personas, journey mapping
- `ui-designer` → component specs, responsive layouts, design tokens
- `api-designer` → REST/GraphQL contract design, OpenAPI specs

**Engineering Division** — use for *building it*:
- `architect` → domain modeling, bounded contexts, ADRs
- `tech-lead` → task breakdown, pipeline coordination
- dev agents → `backend-dev`, `frontend-dev`, `devops-agent`
- quality → `qa-agent`, `reviewer`, `security-agent`, `perf-agent`, `db-migration`

**Operations Division** — use *after shipping*:
- `observability-agent` → verify instrumentation, alert rules, SLOs
- `docs-agent` → generate/update API docs, ADR index, changelog

For a full feature, the pipeline runs: Business → Design → Engineering → Operations.
For a bug fix or small change, start at `tech-lead`.

## Principles

Every contribution must respect `PRINCIPLES.md`:
- **FP:** Pure functions, immutability, typed errors, effects at edges
- **DDD:** Bounded contexts, ubiquitous language, domain events, layered architecture
- **Clean Code:** Names reveal intent, functions do one thing, no magic

If a change conflicts with these principles, it needs an explicit justification and
possibly an ADR.
