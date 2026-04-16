# TUF and Uptane — Signed Update Metadata

**Scope:** Metadata chain, role keys, delegation, and the Image/Director split that the
firmware-ota-agent uses to deliver signed updates to the fleet.

## Why a metadata framework
Plain code signing (one key signs one bundle) breaks in four predictable ways:
1. **Key compromise** — no recovery without re-provisioning every device
2. **Mix-and-match attacks** — attacker replays an old signed bundle on a new device
3. **Freeze attacks** — attacker holds a device at a known-vulnerable version
4. **Targeted attacks** — attacker serves a malicious bundle to one device while the fleet
   sees the legitimate one

TUF (The Update Framework) and Uptane (TUF for automotive / safety-critical) each
address all four with a role-based metadata chain.

## TUF roles (TODO — fill in Phase 3)
- **Root** — offline key set; signs the set of other role keys; rotates rarely
- **Targets** — signs the set of valid bundles and their hashes
- **Snapshot** — signs a consistent view of the current targets metadata
- **Timestamp** — short-lived signature over snapshot; freshness proof
- **Delegations** — targets can delegate signing authority to scoped sub-keys
  (per product line, per cohort, per region)

For each role, document: key type, rotation cadence, threshold (k-of-n), and what the
device does when verification fails.

## Uptane split (TODO — fill in Phase 3)
- **Image Repo** — central catalog of every firmware bundle that exists
- **Director Repo** — per-device targeting: signs what *this* device should install now
- Device verifies both: "the bundle exists in the image repo" AND "the director told me
  to install it". Defeats mix-and-match and targeted attacks.

## IETF SUIT for constrained devices (TODO — fill in Phase 3)
- RFC 9019 (architecture), RFC 9124 (information model), RFC 9124 manifest
- CBOR-encoded manifests; small, parseable on ESP32-class devices
- Use when TUF's JSON metadata is too heavy

## Key ceremony (cross-reference)
See `key-management.md` for HSM procedure, quorum rules, and rotation schedule.

## Bundle verification flow on device (TODO — fill in Phase 3)
1. Fetch timestamp → verify freshness
2. Fetch snapshot → verify consistency
3. Fetch targets → verify the bundle is in the catalog
4. Fetch director targets (Uptane) → verify this device was targeted
5. Fetch the bundle → verify hash + signature
6. Verify anti-rollback counter against `min_version`
7. Write to the inactive A/B slot
8. Set boot flag; reboot; health probe; commit-or-rollback

## Revocation (TODO — fill in Phase 3)
- Compromise of a targets key → re-sign with a new targets key via root quorum
- Compromise of the root → offline root ceremony to publish a new root metadata;
  requires prior planning for how devices learn the new root
- Bad bundle shipped → revoke by publishing a new snapshot that omits it; devices refuse
  to install anything not in the current snapshot

## See also
- `key-management.md`
- `staged-rollout.md`
- `../../shared/standards.md` *(Phase 3)*
