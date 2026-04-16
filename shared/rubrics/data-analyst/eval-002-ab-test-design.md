# Eval: data-analyst — 002 — A/B Test Design

**Tags:** A/B testing, hypothesis, sample size, guardrail, experiment design
**Skill version tested:** initial

---

## Input (task brief)

```
Design an A/B test comparing current 3-step checkout vs new 1-step checkout.
Current abandonment: 65%.
```

---

## Expected Behavior

The data-analyst should:
1. State a clear hypothesis
2. Define primary metric (checkout completion rate)
3. Define guardrail metric (average order value must not decrease)
4. Provide sample size rationale
5. Recommend test duration
6. Produce a `measurement-plan` contract

---

## Pass Criteria

- [ ] Hypothesis clearly stated (e.g., "1-step checkout will increase completion rate by X%")
- [ ] Primary metric: checkout completion rate (currently 35%)
- [ ] Guardrail: average order value must not decrease
- [ ] Minimum detectable effect defined
- [ ] Sample size calculated with statistical power rationale (e.g., 80% power, 95% confidence)
- [ ] Test duration recommended based on traffic volume
- [ ] `measurement-plan` contract produced

---

## Fail Criteria

- No hypothesis → ❌ can't interpret results
- Missing guardrail → ❌ could ship a change that hurts revenue
- No sample size rationale → ❌ test might be underpowered
- No duration recommendation → ❌ test could run too short or too long
