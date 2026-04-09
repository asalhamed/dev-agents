# Prioritization Frameworks

Reference for structured feature prioritization. Use these frameworks to make scope decisions
transparent, repeatable, and defensible.

---

## RICE Scoring

**Use when:** you need an objective, quantitative comparison across many features.

RICE = (Reach × Impact × Confidence) ÷ Effort

| Dimension | Definition | Scale |
|-----------|-----------|-------|
| **Reach** | How many users/customers will this affect per quarter? | Estimated count (e.g., 500, 5000, 50000) |
| **Impact** | How much will this move the target metric per user? | 3 = massive, 2 = high, 1 = medium, 0.5 = low, 0.25 = minimal |
| **Confidence** | How sure are we about the estimates above? | 100% = high (data-backed), 80% = medium (informed guess), 50% = low (speculation) |
| **Effort** | Person-months of work required | Estimated person-months (e.g., 0.5, 1, 3, 6) |

### Worked Example

| Feature | Reach | Impact | Confidence | Effort | RICE Score |
|---------|-------|--------|------------|--------|------------|
| Notification preferences | 10,000 | 2 | 80% | 2 | (10000 × 2 × 0.8) ÷ 2 = **8,000** |
| Dark mode | 8,000 | 0.5 | 100% | 1 | (8000 × 0.5 × 1.0) ÷ 1 = **4,000** |
| SSO login | 2,000 | 3 | 50% | 3 | (2000 × 3 × 0.5) ÷ 3 = **1,000** |

**Winner:** Notification preferences — highest reach × impact relative to effort.

### Tips
- Be honest about Confidence. Inflated confidence defeats the purpose.
- Effort should include design, implementation, QA, and deployment — not just coding.
- Re-score quarterly as data changes.

---

## MoSCoW Method

**Use when:** you need stakeholder alignment on scope for a specific release or milestone.

| Category | Definition | Decision Rule |
|----------|-----------|---------------|
| **Must** | Non-negotiable. Without these, the release has no value or is non-functional. | Would we cancel the release without this? If no → it's not Must. |
| **Should** | Important but the release still delivers value without them. | Significant value, but workarounds exist. |
| **Could** | Nice to have. Include if time permits. | Low cost, marginal value. |
| **Won't** | Explicitly out of scope for this release. May be reconsidered later. | Agreed as out of scope — not "forgotten." |

### Common Mistakes

| Mistake | Consequence | Fix |
|---------|------------|-----|
| Everything is Must | Nothing gets cut when time runs short | Force a max: Musts ≤ 40% of total scope |
| No Won't list | Scope creep by omission | Explicitly list what you're NOT doing |
| Confusing Must with "stakeholder wants it" | Priority by politics, not value | Ask: "Would we cancel the release without this?" |

### Facilitation Tips
1. Start with Won't — it's easier to agree on what you're NOT doing
2. Then identify Musts by the "cancel the release?" test
3. Everything else starts as Could, then promote to Should with justification
4. Time-box the discussion: 60 minutes max

---

## Impact/Effort Matrix

**Use when:** you need a quick visual triage of many items (backlog grooming, brainstorming output).

```
              High Impact
                  │
   Big Bets       │    Quick Wins ★
   (plan carefully)│    (do first)
                  │
  ────────────────┼────────────────
                  │
   Time Sinks ✗   │    Fill-ins
   (avoid/defer)  │    (do if spare capacity)
                  │
              Low Impact

  High Effort ←───┼───→ Low Effort
```

| Quadrant | Action |
|----------|--------|
| **Quick Wins** (high impact, low effort) | Do these first. Immediate ROI. |
| **Big Bets** (high impact, high effort) | Plan carefully. Validate with RICE before committing. |
| **Fill-ins** (low impact, low effort) | Good for spare capacity or new team members ramping up. |
| **Time Sinks** (low impact, high effort) | Avoid. Defer indefinitely unless circumstances change. |

### How to Plot
1. List all candidate features on sticky notes / cards
2. As a group, place each on the 2×2 grid
3. Discuss disagreements — they reveal different assumptions about impact or effort
4. Prioritize Quick Wins → Big Bets → Fill-ins → Time Sinks

---

## When to Use Each

| Framework | Best For | Strengths | Weaknesses |
|-----------|----------|-----------|------------|
| **RICE** | Comparing 5-20 features objectively | Quantitative, reduces bias | Requires decent estimates |
| **MoSCoW** | Aligning stakeholders on release scope | Forces explicit scope decisions | Qualitative, subject to politics |
| **Impact/Effort** | Quick triage of large backlogs | Fast, visual, collaborative | Imprecise, no nuance |

**Recommended flow:**
1. Impact/Effort matrix for initial triage (cut Time Sinks early)
2. RICE scoring for the remaining candidates
3. MoSCoW for the final release scope with stakeholders
