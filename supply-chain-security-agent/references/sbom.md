# SBOM — Software Bill of Materials

**Scope:** How this project generates, attaches, and consumes SBOMs for containers,
firmware, language packages, and ML models.

## Formats (TODO — fill in Phase 3)
- **CycloneDX** — primary for security / vulnerability use cases; JSON or XML
- **SPDX** — required by some enterprise / government customers for license compliance;
  ship alongside CycloneDX when contractually required
- Keep the source-of-truth in one format; convert on demand

## Build-time generation (TODO — fill in Phase 3)
Per language / ecosystem:
- **Node / npm** — `@cyclonedx/cdxgen` or `cyclonedx-npm`
- **Python** — `cyclonedx-bom` or `cyclonedx-py`
- **Rust** — `cargo-cyclonedx` or `cargo-sbom`
- **Go** — `cyclonedx-gomod`
- **Java / Maven** — `cyclonedx-maven-plugin`
- **Containers** — `syft` (multi-ecosystem); run inside the build, not over the finished image
- **Firmware / embedded** — case by case; prefer build-system integration over binary scanning

Generate inside the build step so transitive and vendored deps are captured accurately.

## Attachment (TODO — fill in Phase 3)
- **Container artifacts** — attach as OCI referrer (`cosign attach sbom` or native OCI
  referrers API)
- **Language packages** — attach alongside the release (e.g., GitHub release assets, or
  registry-specific attachment where supported)
- **Firmware bundles** — include in the signed metadata manifest; consumed by
  `firmware-ota-agent`

## Consumption (TODO — fill in Phase 3)
- CI gate: SBOM present? → fail the release if not
- Vulnerability scan: `osv-scanner` or equivalent against the SBOM, with severity gates
- Customer delivery: SBOM in the release evidence bundle

## Rebuild policy (TODO — fill in Phase 3)
- SBOM is regenerated on every build, even for the same version
- SBOM hash included in provenance attestation

## See also
- `artifact-signing.md`
- `slsa.md`
- `../../shared/standards.md` *(Phase 3)* — CycloneDX + SPDX spec pointers
