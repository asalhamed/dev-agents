# Service Contract Change Request

**Producer:** any dev agent that needs a contract change
**Consumer:** architect (approves), api-designer (implements), all consuming teams (review)
**Purpose:** Prevent breaking changes between independently deployed services

---

## Required Fields

Fill out the following template when requesting a contract change:

```markdown
## SERVICE CONTRACT CHANGE

### Change Identity
**Change ID:** SCC-[NNN]
**Feature reference:** F-[NNN]
**Requesting service:** [service name]
**Requesting team:** [team name]

### Contract Being Changed
**Contract repo:** platform-contracts
**Contract file:** [path — e.g., api/order-service.yaml]
**Contract type:** OpenAPI | AsyncAPI | Avro | Protobuf | MQTT Schema

### Change Description
**Type:** additive | breaking | deprecation
**Summary:** [what is changing and why]

### Affected Consumers
<!-- REQUIRED: List every service that consumes this contract -->
| Consumer service | Consumer repo | Impact | Action needed |
|-----------------|---------------|--------|---------------|
| [service] | [repo] | None / Update required / Breaking | [what they need to do] |

### Compatibility Analysis
**Backward compatible:** yes | no
**Forward compatible:** yes | no

If **NOT backward compatible**, provide a migration plan:
1. [step 1 — e.g., add new field as optional]
2. [step 2 — e.g., consumers adopt new field]
3. [step 3 — e.g., make field required in next version]

### Version Strategy
**Current version:** v[X]
**New version:** v[X+1] (if breaking) | v[X] (if additive)
**Deprecation timeline:** [old version supported until YYYY-MM-DD]

### Rollout Order
<!-- REQUIRED for breaking changes: which services deploy in what order -->
| Step | Service | Action | Verify |
|------|---------|--------|--------|
| 1 | [producer] | Deploy with both old + new format | Old consumers still work |
| 2 | [consumer A] | Update to consume new format | Tests pass |
| 3 | [consumer B] | Update to consume new format | Tests pass |
| 4 | [producer] | Remove old format support | All consumers migrated |
```

## Validation (architect must check)
- [ ] All consumers identified (no "I think these are the only ones")
- [ ] Backward compatibility assessed honestly
- [ ] If breaking: migration plan with ordered rollout steps
- [ ] Version bump follows semver (additive = minor, breaking = major)
- [ ] Deprecation timeline specified for old version
