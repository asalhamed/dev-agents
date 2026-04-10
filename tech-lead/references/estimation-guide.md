# Estimation Guide

## T-Shirt Sizing

| Size | Duration | Complexity | Examples |
|------|----------|------------|---------|
| S | < 1 day | Single file, clear pattern, minimal risk | Add a field, fix a bug, add a test |
| M | 1-3 days | Multiple files, moderate complexity | New endpoint, new component, new migration |
| L | 3-5 days | Cross-layer, integration required | New aggregate, new streaming pipeline, new ML model |
| XL | 5+ days | Must be decomposed further | New bounded context, new service, major refactor |

XL is not a valid task size. If a task estimates at XL, split it before creating the feature-kickoff.

## How to Estimate

**Estimate the task, not the ideal scenario.** Include time for:
- Reading and understanding existing code
- Understanding patterns and constraints
- Actual implementation
- Writing tests (unit + integration)
- Self-review against principles checklist
- Likely one round of reviewer feedback

**Think in confidence bands:**
| Confidence | Meaning | Buffer |
|------------|---------|--------|
| High | Done this exact thing before, clear requirements | +20% |
| Medium | Similar but new context, mostly clear | +50% |
| Low | New technology, first-time pattern, or unclear requirements | +100% — flag to user |

**Dependencies add time.** If task B is blocked by task A, don't overlap estimates. Add:
- Integration time between tasks (typically S = half a day)
- Buffer for handoff latency between agents

## Common Estimation Pitfalls

| Pitfall | What actually happens | Correction |
|---------|----------------------|------------|
| "It's just a small change" | Integration, testing, and review take longer than the change | Estimate the full task cycle, not just the implementation |
| Ignoring cross-agent handoffs | Waiting for other agents adds latency | Add integration time between dependent tasks |
| Not accounting for review cycles | Assume at least one round of changes-requested | Build one review cycle into every task estimate |
| Parallel work isn't faster | Parallel tasks still need integration + may conflict | Add integration time after parallel tasks converge |
| Happy path only | Edge cases and error handling double the work | Estimate includes tests for error paths |

## Scope Impact Rules

When scope changes arrive mid-pipeline (via scope-change-request.md), re-estimate:
- Small scope addition: +S or +M — low risk, absorb with buffer
- Medium scope addition: +M or +L — requires timeline update and product-owner confirmation
- Large scope addition: +L or XL — strongly recommend deferring to next release

## Buffer Application

Total estimated days → apply buffer → target delivery:

```
Estimated: 8 days
Confidence: Medium → +50% buffer = 4 days buffer
Total: 12 days
Target delivery: today + 12 business days
```

If the buffered estimate exceeds 2 weeks for a single feature, recommend splitting:
- Slice a "Phase 1" that delivers user value independently
- Defer "Phase 2" to the next release cycle
