# Schema Registry Contract

**Producer:** architect + data-engineer
**Consumer(s):** backend-dev, edge-media-agent, iot-dev, ml-engineer, data-engineer,
qa-agent, reviewer, supply-chain-security-agent

## Purpose

Devices, cameras, and edge nodes produce high-frequency, long-lived event streams
(telemetry, stream metadata, inference results, lifecycle events). Their schemas evolve
across years and across fleet-firmware versions. This contract defines how every such
schema is registered, versioned, and evolved without breaking producers or consumers.

Without this discipline, schema drift silently corrupts dashboards, ML training pipelines,
and backfills.

## Required Fields

- **Schema identifier** — `<bounded-context>.<event-or-type-name>` (e.g.,
  `telemetry.camera.stream-metadata`). Matches the glossary term.
- **Schema format** — one of: Avro, Protobuf, JSON Schema. Choose once per bounded
  context; do not mix within a context.
- **Registry location** — the URL or path where the schema is stored (Confluent Schema
  Registry, Apicurio, a git-tracked `platform-contracts/schemas/` directory, etc.)
- **Compatibility mode** per subject:
  - `BACKWARD` (default for producer-owned topics) — new schema can read old data
  - `FORWARD` — old schema can read new data (for consumer-owned shapes)
  - `FULL` — both
  - `NONE` — only where explicitly justified (rare; requires ADR)
- **Ownership** — which agent owns producing messages in this schema
- **Consumers** — list of known consumers (services, analytics pipelines, ML training)
- **Retention of historical schemas** — minimum time or version count
- **Migration ordering** — for breaking changes, the explicit producer-first vs.
  consumer-first rollout sequence with ordered steps

## Validation Checklist

- [ ] Every topic / stream / derived table has a registered schema
- [ ] Compatibility mode is declared per subject, not implicit
- [ ] Producer CI runs a producer-contract test verifying actual output matches the schema
- [ ] Consumer CI runs a consumer-contract test verifying the schema can be parsed
- [ ] Schema version is included in every emitted message (header, field, or wire
  metadata)
- [ ] Schema evolution is additive where the compatibility mode requires it
- [ ] Breaking changes have a documented migration ordering that is known to be safe
- [ ] Device-side producers can serialize the schema within the device's resource budget
  (CBOR / Protobuf preferred for constrained devices)
- [ ] PII / biometric fields are marked as such at the schema level; `privacy-agent`
  reviews before registration

## Example (valid)

```markdown
## SCHEMA: telemetry.camera.stream-metadata (v3)

**Format:** Protobuf (Confluent Schema Registry)
**Registry:** `platform-contracts/schemas/telemetry/camera/stream-metadata.proto` →
registry subject `telemetry.camera.stream-metadata-value`
**Compatibility:** BACKWARD
**Owner:** edge-media-agent
**Consumers:** data-engineer (time-series ingest), analytics-engineer (dashboards),
ml-engineer (training cache)
**Historical retention:** 10 prior versions, minimum 2 years

### Evolution: v2 → v3

- **Added (backward-compatible):** `model_version` (string, required-with-default).
  Producers at firmware <= `camera-v4.2` do not emit it; consumers default to
  `"unknown"`.
- **Deprecated:** `detection_score_v1` (kept for two years of read compatibility).
- **Removed:** none (backward breaks).

### Migration ordering (breaking changes only — N/A for this version)

1. Publish new schema at v+1 with the target compatibility
2. Update consumers to parse v+1
3. Update producers to emit v+1
4. Wait 2× max retention of the old messages
5. Remove v-1 parsing from consumers

### Privacy review

- `subject_track_id`: pseudonymous device-scoped — ✅ (not a ConsentRecord-requiring field)
- `face_embedding`: biometric — REQUIRES a valid `ConsentRecord`. Emission gated on
  consent at the edge; schema carries `consent_record_id` reference.
```

## See also

- `shared/glossary.md` — canonical names for event types and fields
- `service-contract-change.md` — the process for proposing a breaking schema change
- `../FORMAT.md` — skill format (adjacent canon)
- `edge-media-agent/SKILL.md` — primary producer of stream metadata
- `iot-dev/SKILL.md` — primary producer of device telemetry
- `privacy-agent/SKILL.md` — review of schemas with biometric / PII fields
- `supply-chain-security-agent/SKILL.md` — schema registry itself is a supply-chain
  asset (signed, versioned)
