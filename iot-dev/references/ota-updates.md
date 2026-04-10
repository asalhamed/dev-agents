# OTA Update Strategies

## A/B Partition Strategy

```
Flash Layout:
┌──────────────┐
│ Bootloader   │  (read-only, never updated OTA)
├──────────────┤
│ Partition A  │  ← currently running
├──────────────┤
│ Partition B  │  ← download new firmware here
├──────────────┤
│ Config/NVS   │  (persistent across updates)
└──────────────┘
```

1. Download firmware to inactive partition (B)
2. Verify signature
3. Set boot flag to B
4. Reboot
5. New firmware runs health check
6. If healthy: mark B as confirmed
7. If unhealthy: watchdog reboots → bootloader falls back to A

## Signature Verification

```
Build server signs firmware with Ed25519 private key
Device has Ed25519 public key (in bootloader, immutable)

Verification:
1. Download firmware image + signature file
2. Compute SHA-256 hash of firmware
3. Verify Ed25519 signature against hash using embedded public key
4. If invalid: reject, do not flash
```

Never skip verification. Never update the verification key via OTA.

## Rollback Triggers

| Trigger | Action |
|---------|--------|
| Boot loop (3 failed boots) | Watchdog reboot → bootloader selects previous partition |
| Health check fails | Firmware marks itself unhealthy → reboot to previous |
| Manual rollback command | Cloud sends rollback command via MQTT |
| Connectivity lost >5min after update | Auto-rollback (can't report status = probably broken) |

## Delta Updates

For bandwidth-constrained devices:
- Generate binary diff (bsdiff) between old and new firmware
- Device applies patch to current firmware → writes result to inactive partition
- Typical savings: 60-90% smaller than full image
- Tradeoff: device needs enough RAM to apply patch

## Update Flow

```
Cloud                           Device
  │                               │
  ├── ota/notify ────────────────►│  "v1.3.0 available"
  │                               │
  │◄── ota/status ────────────────┤  "downloading"
  │                               │  ... download chunks ...
  │◄── ota/status ────────────────┤  "verifying"
  │                               │  ... signature check ...
  │◄── ota/status ────────────────┤  "applying"
  │                               │  ... flash + reboot ...
  │◄── ota/status ────────────────┤  "success" (or "rollback")
```

## Status Reporting

```json
{
  "device_id": "th100-a1b2c3",
  "update_id": "upd-2025-001",
  "status": "success",
  "from_version": "1.2.0",
  "to_version": "1.3.0",
  "duration_s": 45,
  "timestamp": "2025-01-15T10:30:00Z"
}
```

## Key Rules

- **Never update bootloader via OTA** — if bootloader is broken, device is bricked
- **Always verify before flashing** — cryptographic signature, not just checksum
- **Rollback must be automatic** — don't rely on cloud to trigger rollback
- **Resumable downloads** — interrupted download resumes, doesn't restart
- **Staged rollout** — update 1% → 10% → 50% → 100%, with monitoring between stages
