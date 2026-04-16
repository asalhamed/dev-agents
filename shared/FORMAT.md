# Skill Format

This repo uses the **Claude Code skill format** (Anthropic convention). Every agent directory
is a loadable skill that Claude Code auto-dispatches based on the `description` field.

## Directory Layout

```
<agent-name>/
├── SKILL.md              # required — agent entry point with YAML frontmatter
└── references/           # optional — progressive-disclosure docs loaded on demand
    ├── <topic>.md
    └── <topic>.md
```

Agent directories MUST NOT contain:
- `evals.json` or `evals/` — rubric cases live centrally in [rubrics/](rubrics/)
- `metadata.openclaw` YAML blocks — legacy OpenClaw fields are stripped
- Scripts, binaries, or build artifacts — skills are prose + markdown only

## SKILL.md Frontmatter

```yaml
---
name: <kebab-case-agent-name>          # ≤64 chars, matches directory name
description: >                          # ≤1024 chars, plain text (no markdown)
  [1-2 sentences: what the agent does.]
  Trigger keywords: "phrase 1", "phrase 2", ... (8-10 real-user phrases).
  [Supported stacks / tools / constraints.]
  NOT for [explicit exclusions → point to the right agent].
---
```

### Description guidelines
- **Trigger keywords** are load-bearing. Claude Code dispatches on keyword match; vague
  descriptions don't trigger. Err toward listing more phrases users actually say.
- **NOT-for section** is required. It prevents the wrong agent from activating and tells
  the reader where to go instead.
- **Stack list** (where applicable) lets multi-stack agents self-select.
- **No markdown** in the `description` — it's a YAML scalar.

### Body guidelines
- Open with a link to `../PRINCIPLES.md` (the non-negotiable canon).
- Keep the SKILL.md under ~500 lines. Push depth into `references/`.
- Structure: Role → Principles → Workflow (numbered) → Self-Review → Output Contract →
  Escalation Rules.
- Reference `shared/contracts/<name>.md` for any handoff output.
- Reference `shared/glossary.md` when introducing domain terms.

## Progressive Disclosure via `references/`

`references/` files are loaded only when the agent decides they're needed. Use them for:
- Stack-specific patterns (e.g., `rust-patterns.md`, `leptos-patterns.md`)
- Domain-specific standards (e.g., `owasp-top10.md`, `tuf-uptane.md`, `onvif.md`)
- Long templates (e.g., `dpia-template.md`, `runbook-template.md`)

The SKILL.md body should link to references by relative path
(e.g., `references/rust-patterns.md`).

## Rubrics

Rubric cases live in [rubrics/<agent>/](rubrics/) — one markdown file per case. See
[rubrics/README.md](rubrics/README.md) for the rubric format and running instructions.

## Validation Checklist

Before merging a new or modified skill:

- [ ] `SKILL.md` frontmatter parses as valid YAML
- [ ] `name` matches the directory name (kebab-case)
- [ ] `description` is ≤1024 chars and plain text
- [ ] `description` includes a "Trigger keywords:" block with ≥8 phrases
- [ ] `description` includes a "NOT for" clause pointing to alternates
- [ ] Body links to `../PRINCIPLES.md`
- [ ] Output handoff (if any) references a `shared/contracts/*.md` file
- [ ] No `evals.json`, no `evals/`, no `metadata.openclaw:` anywhere in the directory
- [ ] Any new domain terms added to [glossary.md](glossary.md)
- [ ] Rubric case(s) added under `rubrics/<agent>/`

## Migration Note

This repo migrated from the OpenClaw format in 2026. Historical context: OpenClaw used
`metadata.openclaw` frontmatter (emoji + tool requirements) and per-agent `evals.json`
files. These were removed as part of the Claude Code format migration; rubric case IP
was preserved by moving to [rubrics/](rubrics/).
