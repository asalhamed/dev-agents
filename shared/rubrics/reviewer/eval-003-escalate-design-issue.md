# Eval: reviewer — 003 — Escalate Design Issue

**Tags:** reviewer escalation, bounded context violation, design issue vs implementation issue  
**Skill version tested:** initial

---

## Input

Reviewer receives implementation-summary for a task that implemented order cancellation.
The code is clean (no FP violations, tests pass, coverage ok), but the reviewer sees this in the diff:

```scala
// In order-service: src/infrastructure/persistence/OrderRepository.scala

class PostgresOrderRepository extends OrderRepository[IO]:
  def cancel(orderId: OrderId, reason: CancellationReason): IO[Unit] =
    // Implementation queries partner_service.partners table directly
    // to check if the partner allows cancellations before cancelling
    sql"""
      SELECT allows_cancellation 
      FROM partner_service.partners  -- ← direct cross-schema query
      WHERE partner_id = ${getPartnerIdForOrder(orderId)}
    """.query[Boolean].unique.transact(xa).flatMap { allowed =>
      if allowed then
        sql"UPDATE orders SET status = 'cancelled' ...".update.run.transact(xa).void
      else
        IO.raiseError(OrderError.CancellationNotPermitted)
    }
```

Coverage: 76% ✅. Tests pass ✅. No `unwrap()`. No nulls. Code is otherwise clean.

---

## Expected Behavior

The reviewer should:
1. Recognize this is a **bounded context violation** — order-service is directly querying partner_service's database schema
2. Determine this is a **design issue**, not an implementation issue — the fix requires an architectural decision (how should order-service know about partner cancellation policy?)
3. Issue `🏛️ ESCALATE TO ARCHITECT`
4. NOT issue "request changes" (the fix requires an ADR, not just a code cleanup)

---

## Pass Criteria

- [ ] Decision is `🏛️ ESCALATE TO ARCHITECT` (not approve, not request changes)
- [ ] Cross-schema DB query identified as the specific evidence
- [ ] Bounded context violation named explicitly
- [ ] Explanation: this is a design issue because the fix requires deciding how order-service should access partner cancellation policy (event? API call with ACL? shared kernel?)
- [ ] Specific question for architect formulated (e.g. "How should order-service determine if a partner allows cancellations without querying partner_service DB directly?")
- [ ] "All dev work paused pending architect response" stated
- [ ] `reviewer-decision` escalation format used

---

## Fail Criteria

- Issues approve despite cross-context DB query → ❌ critical DDD violation missed
- Issues "request changes" with "remove the cross-schema query" → ❌ wrong decision type (how to replace it requires design, not just deletion)
- Escalates but doesn't formulate a specific question for architect → ❌ incomplete escalation
- Correct escalation but wrong format (missing required fields) → ❌ contract violation
