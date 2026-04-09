# Documentation Summary

**Producer:** docs-agent
**Consumer(s):** tech-lead

## Required Fields

- **Trigger** — what implementation or ADR this was generated from
- **Documents updated** — list with what changed
- **API docs** — what endpoints were documented or updated
- **ADR index** — was it updated? New entries?
- **Changelog** — entry added?
- **Breaking changes flagged** — yes/no, where

## Validation Checklist

- [ ] All new endpoints in API docs
- [ ] ADR index up to date
- [ ] Changelog entry added (Keep a Changelog format)
- [ ] No stale references
- [ ] Breaking changes explicitly noted

## Example (valid)

```markdown
## DOCS SUMMARY: Order Confirmation Feature (T-001 through T-008)

**Trigger:** Approved implementation of ADR-007

**Documents updated:**
| Document | Change |
|----------|--------|
| docs/api/orders.md | Added POST /orders/{id}/confirm endpoint |
| docs/adr/index.md | Added ADR-007: Order Confirmation via Domain Event |
| CHANGELOG.md | Added v1.3.0 entry |

**API docs:** Documented confirm endpoint with request, responses (200, 409, 422, 403), and RFC 7807 error format examples.

**ADR index:** ADR-007 added. Status: Accepted. No supersessions.

**Changelog entry:**
```
## [1.3.0] - 2026-04-09
### Added
- Order confirmation publishes OrderConfirmed domain event to Kafka
### Changed
- Notification service is now an async consumer of OrderConfirmed event
### Breaking changes
- None (notification delivery is now async; timing may differ by <1s)
```

**Breaking changes flagged:** No API-level breaking changes.
```
