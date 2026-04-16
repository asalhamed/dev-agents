# Key Management — Firmware OTA

**Scope:** How the firmware-ota-agent treats signing keys for the update metadata chain,
from HSM ceremony through rotation and compromise response.

## Key hierarchy (TODO — fill in Phase 3)
- **Root key** — offline, cold-stored, k-of-n quorum
- **Targets key** — online, signs firmware catalog
- **Snapshot key** — online, signs consistency view
- **Timestamp key** — online, signs freshness proof
- **Delegated targets keys** — per cohort / product line / region

Document for each: cryptographic algorithm (ed25519 preferred; ECDSA P-256 for HSM
compatibility), quorum threshold, rotation cadence.

## HSM ceremony (TODO — fill in Phase 3)
Root key generation and rotation must be a witnessed, audited ceremony:
- Minimum two role-separated officers (security officer + independent witness)
- HSM with FIPS 140-2/3 certification appropriate to the risk profile
- Air-gapped workstation; new install from known-good media
- Output: signed root metadata + attestation of the ceremony
- Backup: sharded via Shamir Secret Sharing; geographically distributed

## Rotation schedule (TODO — fill in Phase 3)
Baseline (revise per risk profile):
- **Timestamp:** daily or on-demand
- **Snapshot:** weekly
- **Targets:** quarterly
- **Delegated targets:** per product-line policy
- **Root:** every 1–2 years, or immediately on compromise

Each rotation ships a new metadata chain; devices verify continuity via the previous
role's signature.

## Device trust anchors (TODO — fill in Phase 3)
- Baked at manufacturing — fuse or tamper-resistant storage
- Rotation requires an OTA that updates the anchor itself; design carefully
- Never share anchor sets across unrelated SKUs

## Compromise response (TODO — fill in Phase 3)
Per-role playbooks:
- Timestamp/snapshot compromise — rotate online, low blast radius
- Targets compromise — rotate via root quorum; audit the last window of signed bundles
- Root compromise — invoke the planned root rotation procedure; fleet-wide impact
- Delegated-targets compromise — revoke delegation, re-issue via root

## Audit
- Every signing operation is logged with operator, purpose, and metadata hash
- Logs stored append-only; reviewed quarterly
- Ceremony recordings retained per policy (coordinate with `compliance-agent`)

## See also
- `tuf-uptane.md` — the role structure the keys protect
- `staged-rollout.md` — what a compromise halts
