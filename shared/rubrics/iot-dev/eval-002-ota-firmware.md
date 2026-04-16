# OTA Firmware Update with Rollback

**Tags:** iot, ota, firmware, rollback, security

## Input

Implement OTA firmware update mechanism for a fleet of IoT devices. Updates must be atomic (A/B partition), signature-verified, and rollback-capable if new firmware fails to boot.

## Expected Behavior

Agent designs A/B partition OTA with Ed25519 signature verification, watchdog-triggered rollback, resumable downloads, and MQTT status reporting.

## Pass Criteria

- [ ] A/B partition strategy (not overwrite-in-place)
- [ ] Signature verification before applying update
- [ ] Watchdog triggers rollback on failed boot
- [ ] Update status reported via MQTT
- [ ] Download is resumable
- [ ] Produces device-spec contract

## Fail Criteria

- In-place firmware overwrite (bricking risk)
- No signature verification
- No rollback mechanism
- Full re-download on interruption
