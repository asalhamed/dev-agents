# Supply Chain Review

**Producer:** supply-chain-security-agent
**Consumer(s):** tech-lead, reviewer, devops-agent, firmware-ota-agent, security-agent,
  compliance-agent

## Purpose

The signing, provenance, and SBOM posture for a release (or the program-level posture for
the whole organization). Provides the evidence enterprise customers and auditors ask for,
and documents the target SLSA level with gap analysis.

## Required Fields

- **Artifact inventory** — every shipped artifact class: containers, firmware bundles, ML
  models, language packages, Helm charts, Terraform modules, SDKs, CLIs
- **Per-artifact posture** table:
  - Signing mechanism (Sigstore keyless / long-lived key / both)
  - SBOM format (CycloneDX / SPDX / both) and attachment method
  - Provenance attestation (in-toto / SLSA) and where it's stored
  - Current SLSA level
  - Target SLSA level
  - Gaps and remediation plan
- **Dependency vetting policy** — registries, pinning, review gate, transitive monitoring,
  typosquat detection
- **Reproducible-build status** — per artifact class: in-scope / out-of-scope / partial;
  CI job status
- **Release evidence bundle** — what is shipped with each public release
- **Incident runbooks** — dependency compromise, signing-key compromise, pipeline
  compromise; links and last-tested dates
- **Firmware signing coordination** — how fleet bundle signing (owned by
  `firmware-ota-agent`) is evidenced here; shared key-management practices
- **Customer-facing verification** — the `verify.sh` (or equivalent) command customers
  run to check a release

## Validation Checklist

- [ ] Inventory covers every artifact class; nothing "distributed but unlisted"
- [ ] Every artifact has signing, SBOM, and provenance posture stated
- [ ] SLSA gaps have remediation owners and target dates
- [ ] Lockfiles present and pinned in every source repo
- [ ] Base image digests pinned
- [ ] Typosquat / malicious-package scanning runs on every PR
- [ ] Reproducible-build CI exists for the top-risk artifact classes
- [ ] Release-evidence bundle exists for the last N releases
- [ ] Runbooks for dep / signing / pipeline compromise have been tested in the last year
- [ ] Firmware bundle signing is evidenced and linked to the `ota-plan.md` of the
  corresponding rollout

## See also

- `supply-chain-security-agent/SKILL.md`
- `ota-plan.md`
- `security-scan.md`
- `compliance-audit.md`
- `../glossary.md` — `SBOM`, `Provenance`
