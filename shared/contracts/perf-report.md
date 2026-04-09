# Performance Report

**Producer:** perf-agent
**Consumer(s):** reviewer

## Required Fields

- **Task(s) analyzed** — which implementation was profiled
- **Hot paths identified** — which code paths are performance-critical
- **Benchmark results** — before/after if applicable, tool and command used
- **Findings** — bottlenecks, N+1 queries, unnecessary allocations
- **Recommendations** — actionable fixes with expected impact
- **Overall verdict** — PASS (meets performance budget) / FAIL / INFORMATIONAL

## Validation Checklist

- [ ] Hot paths identified from implementation summary
- [ ] Benchmark tool appropriate for stack (criterion/JMH/autocannon)
- [ ] N+1 query patterns checked
- [ ] Memory allocation profile reviewed (Rust/JVM)
- [ ] Every FAIL finding has a concrete recommendation

## Example (valid)

```markdown
## PERF REPORT: Money Value Object (T-004)

**Stack:** Rust
**Hot paths:** Money::add() — called in order total calculation on every request

**Benchmark results (criterion):**
```
money_add/same_currency  time: [8.3 ns 8.4 ns 8.5 ns]
money_add/diff_currency  time: [5.1 ns 5.2 ns 5.3 ns]  (early return on mismatch)
```

**Findings:**
- No unnecessary allocations — Money is stack-allocated ✅
- No clone() in hot path ✅
- No heap allocation in add() ✅

**Recommendations:** none — implementation is optimal for this use case

**Overall verdict:** ✅ PASS — within performance budget (target: <100ns for value object operations)
```
