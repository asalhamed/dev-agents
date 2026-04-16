# Hardware Attestation and Secure Boot — Device Side

**Scope:** Implementing the device-side trust primitives that the firmware-ota-agent,
security-agent, and compliance-agent rely on. How a device proves who it is, and how it
verifies what it runs.

## Why attestation matters (TODO — fill in Phase 3)
Attestation binds software trust to hardware identity:
- OTA: "the server should only target me with updates signed for my device class,
  and only if I can prove I'm me"
- Pairing: "this camera really is the one with serial X, not a cloned impostor"
- Compliance: NIST SP 800-193 platform resiliency, IEC 62443 device identity (IAC-1),
  ETSI EN 303 645 provisioning of unique identity (Provision 5.4)

## Root of trust options (TODO — fill in Phase 3)
- **TPM 2.0** — discrete or firmware TPM; wide tooling; good for gateways and edge nodes
- **ARM TrustZone** — secure-world execution; common on mid/high-end SoCs
- **Secure Enclave / SE** — STSAFE, ATECC608, OPTIGA Trust — tiny, cheap, embedded-friendly
- **PUF (Physically Unclonable Function)** — unique device key from silicon variation
- **Fuse-based identity** — irreversible write-once keys

Pick per device class; document the choice in the device spec.

## Secure boot chain (TODO — fill in Phase 3)
`ROM boot → verified bootloader → verified kernel → verified rootfs/userspace`. Each stage
verifies the signature of the next against a trust anchor rooted in hardware. Break the
chain → boot fails or drops to recovery.

- **Measured boot** (TPM extends PCRs with each stage's hash) enables remote attestation
- **Anti-rollback** counters per stage, enforced by the immutable root

## Remote attestation (TODO — fill in Phase 3)
- **TPM quote** — a signed report of PCR values over a server-provided nonce
- Server verifies: PCR values match expected, quote signed by a known TPM, nonce fresh
- Integrate with `firmware-ota-agent`: attestation is a prerequisite for targeting

## Credential storage (TODO — fill in Phase 3)
- Private keys generated on-device and never leave it (TPM / SE)
- Long-term device identity keys separate from short-term session keys
- Rotation mechanism documented (`firmware-ota-agent` owns fleet-side key changes)

## Provisioning flow (TODO — fill in Phase 3)
Factory vs. first-boot; trade-offs, threat models, and typical certificate hierarchies.

## Test matrix (TODO — fill in Phase 3)
- Signed boot-chain verification passes for known-good firmware
- Signed boot-chain verification *fails* for tampered firmware, and the device falls back
  to recovery
- Attestation quote verifies against the expected PCRs
- Attestation quote is rejected if the measured stack doesn't match
- Anti-rollback is enforced on downgrade attempts

## See also
- `../../firmware-ota-agent/SKILL.md`
- `../../security-agent/SKILL.md`
- `../../compliance-agent/references/iot-security-standards.md`
- `../../shared/standards.md` *(Phase 3)*
