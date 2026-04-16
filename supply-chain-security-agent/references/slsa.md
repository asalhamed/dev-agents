# SLSA and in-toto — Provenance

**Scope:** The provenance model this project uses to attest how artifacts were built, at
what SLSA level, and with what gaps to the next level.

## SLSA levels (TODO — fill in Phase 3)
- **Level 1** — scripted build; provenance exists
- **Level 2** — hosted build service; signed provenance
- **Level 3** — hardened build service; non-forgeable, isolated provenance
- **Level 4** — two-party review; hermetic, reproducible build

Document the target level per artifact class. Enterprise baseline: Level 3 for
containers and primary distributables. Firmware: aim higher, coordinate with
`firmware-ota-agent`.

## in-toto attestations (TODO — fill in Phase 3)
Attestations are typed statements about artifacts. Types we use:
- **slsaprovenance** — build provenance (source, builder, materials, timestamps)
- **vuln** — vulnerability scan snapshot at release time
- **custom** (as needed) — e.g., model-training provenance for ML artifacts

Attestations signed the same way as artifacts (`cosign attest`).

## Build provenance fields (TODO — fill in Phase 3)
Minimum:
- `buildType` — URI identifying the build schema
- `builder.id` — which CI runner / identity
- `invocation` — how the build was triggered
- `materials` — source commit + any external inputs with digests
- `metadata.buildStartedOn` / `buildFinishedOn`
- `metadata.reproducible` — claim of reproducibility

## Gap analysis (TODO — fill in Phase 3)
For each artifact class: current level → target level → specific gaps → remediation plan.

## Customer delivery (TODO — fill in Phase 3)
- Attestations attached alongside artifacts (OCI referrers, release assets)
- Verification command in release notes
- Reference implementation in the release evidence bundle

## See also
- `sbom.md`
- `artifact-signing.md`
- `../../shared/standards.md` *(Phase 3)* — SLSA spec, in-toto spec, NIST SSDF pointers
