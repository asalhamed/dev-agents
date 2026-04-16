# Eval: perf-agent — 002 — Rust Hot Path Unnecessary Clone

**Tags:** Rust, clone, hot path, allocation, borrowing
**Skill version tested:** initial

---

## Input (task brief)

```
Review this Rust hot path called 10,000 times/second:
fn format_order(order: Order) -> String { format!("{:?}", order.clone()) }
```

---

## Expected Behavior

The perf-agent should:
1. Flag the unnecessary `clone()` — function takes ownership, then clones anyway
2. Flag `Debug` formatting in a hot path (allocates a new String every call)
3. Recommend taking `&Order` instead of `Order` to avoid move/clone
4. Suggest `Display` trait instead of `Debug` for production output
5. Suggest criterion benchmarking to measure improvement
6. Produce a `perf-report` contract

---

## Pass Criteria

- [ ] Unnecessary `clone()` identified
- [ ] `Debug` formatting allocation flagged as wasteful in hot path
- [ ] Recommendation: `fn format_order(order: &Order) -> String`
- [ ] Recommendation: implement `Display` instead of using `Debug`
- [ ] Benchmark suggestion (criterion or similar)
- [ ] `perf-report` contract produced

---

## Fail Criteria

- Misses the `clone()` issue → ❌ primary detection failure
- Ignores allocation from `format!("{:?}", ...)` → ❌ incomplete analysis
- Suggests `Rc`/`Arc` instead of borrowing → ❌ over-engineering for this case
- No benchmark recommendation → ❌ incomplete (can't verify fix without measurement)
