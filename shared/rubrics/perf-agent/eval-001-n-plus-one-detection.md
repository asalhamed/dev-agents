# Eval: perf-agent — 001 — N+1 Query Detection

**Tags:** N+1, database, batch loading, query optimization
**Skill version tested:** initial

---

## Input (task brief)

```
Review this code: for each order in a list of 1000 orders, query the database
separately to load the order's items.
```

---

## Expected Behavior

The perf-agent should:
1. Identify the N+1 query pattern by name
2. Quantify the impact (1000 separate queries vs 1 batch query)
3. Recommend batch loading with IN clause or JOIN
4. Produce a `perf-report` contract with FAIL verdict

---

## Pass Criteria

- [ ] N+1 query pattern identified and named explicitly
- [ ] Impact quantified: 1000+ queries reduced to 1-2 queries
- [ ] Latency impact estimated (network round-trips, connection pool pressure)
- [ ] Fix: batch load with `WHERE order_id IN (...)` or JOIN
- [ ] Code example of the fix provided
- [ ] `perf-report` contract produced with FAIL verdict

---

## Fail Criteria

- Doesn't identify the pattern as N+1 → ❌ missed detection
- Suggests caching as the primary fix (instead of batch loading) → ❌ wrong approach
- No quantification of impact → ❌ incomplete analysis
- Verdict is PASS or WARN → ❌ N+1 on 1000 items is clearly FAIL
