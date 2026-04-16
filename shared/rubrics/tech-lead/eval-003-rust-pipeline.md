# Eval: tech-lead — 003 — Rust Pipeline Decomposition

**Tags:** task breakdown, Rust stack, pipeline ordering, cargo test
**Skill version tested:** initial

---

## Input (task brief)

The tech-lead receives the architect's output for ADR-009: Monetary Values as Value Objects.

**Architect Output:**

### Problem Statement
The order-management service currently uses raw `i64` values for monetary amounts. This has led to:
- Currency mismatch bugs (adding USD to EUR without validation)
- Negative amount corruption in discount calculations
- No type-level distinction between cents and whole dollars

### Bounded Context
- **Primary:** order-management
- **Affected:** billing (consumes order totals via domain events)

### Domain Model Changes
- **New Value Object:** `Money` — wraps amount (i64 cents) + currency (enum)
- **New Enum:** `Currency` — USD, EUR, GBP (exhaustive)
- **Modified:** `OrderItem.price` field changes from `i64` to `Money`
- **Modified:** `Order.total()` method returns `Money` instead of `i64`

### Constraints
- Reject negative amounts at construction time
- Newtype pattern — no raw i64 for monetary values anywhere
- No f64 — all amounts in integer cents
- No breaking serialization — existing JSON payloads must still deserialize (backward compat)
- Use `thiserror` for domain error types

### Stack
Rust (Cargo.toml present, uses thiserror for errors)

### Handoff Summary
Tasks to decompose:
1. Money value object implementation (domain layer)
2. Currency enum implementation (domain layer)
3. OrderItem.price migration to Money type (domain layer)
4. Serialization compatibility (infrastructure concern)
5. QA — tests for Money including property-based tests
6. Reviewer — final review of all changes

---

## Expected Behavior

The tech-lead should:
1. Decompose into single-concern task briefs using `task-brief.md` format
2. Use Rust-specific tooling: `cargo test`, `cargo tarpaulin`, `cargo clippy`
3. Set coverage threshold to 80% (Rust standard, not 75%)
4. Reference `rust-patterns.md` in relevant task briefs
5. Order tasks: Money → Currency → OrderItem → serialization → QA → reviewer
6. Include `thiserror` and `proptest` in appropriate tasks
7. Use `Result<T, E>` idiom (not `Either`)

---

## Pass Criteria

- [ ] All task briefs use Rust tooling: `cargo test`, `cargo tarpaulin`, `cargo clippy -- -D warnings`
- [ ] Coverage threshold is 80% (not 75%)
- [ ] At least one task brief references `rust-patterns.md` for implementation patterns
- [ ] Error types use `thiserror` (mentioned in Definition of Done)
- [ ] Uses `Result<T, E>` not `Either` (Rust idiom)
- [ ] Each task is single-concern — no bundled "implement Money and Currency" tasks
- [ ] Backward serialization compatibility is in a Definition of Done
- [ ] QA task includes `proptest` for property-based testing
- [ ] All task briefs follow `task-brief.md` format
- [ ] Domain tasks ordered before integration tasks (Money → Currency → OrderItem → serialization)
- [ ] Dependencies between tasks are explicit

---

## Fail Criteria

- Scala idioms used (Either, sbt, scalafmt) → wrong stack profile
- Coverage threshold is 75% → should be 80% for Rust
- Money and Currency bundled into one task → violates single-concern
- No proptest mentioned in QA task → missing property-based testing requirement
- No reference to `rust-patterns.md` → stack-specific patterns not loaded
- Integration tasks ordered before domain tasks → wrong dependency order
- Missing backward compatibility concern for serialization → constraint ignored
