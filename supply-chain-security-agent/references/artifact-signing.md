# Artifact Signing — Sigstore / cosign

**Scope:** How this project signs container images, generic artifacts, ML models, and
language packages, and how consumers verify them.

## Signing models (TODO — fill in Phase 3)
- **Keyless (Sigstore)** — OIDC identity → short-lived cert from Fulcio → signature +
  transparency log entry in Rekor. Default for CI-built containers and generic artifacts.
- **Long-lived key** — where keyless is not acceptable (firmware bundles, air-gapped
  consumers, regulator requirements). Keys in HSM; rotation schedule documented.
- **Both** — dual-sign when migrating, or when the same artifact must be verifiable by
  consumers with different trust anchors.

## Signing: what to sign (TODO — fill in Phase 3)
- Container images, by digest
- Firmware bundles (coordinate with `firmware-ota-agent` — that agent owns the fleet-side
  trust chain; this agent owns the release-side signing)
- ML model artifacts
- Release archives
- SBOM documents
- Provenance attestations

## Commands (TODO — fill in Phase 3)
Examples to fill in:
- `cosign sign --oidc-issuer ... <digest>`
- `cosign attest --predicate slsa.json --type slsaprovenance ...`
- `cosign verify --certificate-identity ... --certificate-oidc-issuer ... <image>`

## Verification in the consumer (TODO — fill in Phase 3)
- K8s admission controller (e.g., policy-controller, Kyverno with cosign policy) for
  internal clusters
- CI pipeline step in downstream repos
- Device-side verification for firmware (→ `firmware-ota-agent`)
- Customer-facing `verify.sh` script with clear pass/fail output

## Transparency log monitoring (TODO — fill in Phase 3)
- Watch Rekor for unexpected entries from our OIDC identities
- Alert on anomalies (new CI identity signing, off-hours signing, etc.)

## Key management (for long-lived signing) (TODO — fill in Phase 3)
Cross-reference with `../firmware-ota-agent/references/key-management.md`; same
discipline, different scope.

## See also
- `sbom.md`
- `slsa.md`
- `../../firmware-ota-agent/references/key-management.md`
