# Device Specification

**Producer:** iot-dev
**Consumer(s):** qa-agent, reviewer

## Required Fields

- **Device type** — hardware model, form factor, intended environment
- **Firmware version** — semantic version, target platform (e.g., ESP32, STM32, nRF52)
- **Supported protocols** — MQTT, BLE, CoAP, HTTP, Modbus, etc.
- **Telemetry schema** — JSON/Protobuf schema with version, field names, types, units
- **Command schema** — inbound commands the device accepts (topic, payload, response)
- **OTA update mechanism** — update delivery, verification, rollback strategy
- **Power/connectivity requirements** — power source, sleep modes, expected uplink bandwidth
- **Security** — authentication method (X.509, PSK, token), encryption (TLS version), credential storage

## Validation Checklist

- [ ] MQTT topic hierarchy defined (follows `devices/{device_id}/telemetry` convention)
- [ ] Telemetry schema versioned (schema_version field in every message)
- [ ] OTA rollback mechanism documented (A/B partition or equivalent)
- [ ] No hardcoded credentials (certs or tokens loaded from secure storage)
- [ ] Power budget documented (active/sleep current, expected battery life if applicable)

## Example (valid)

```markdown
## DEVICE SPEC: TH-100 Temperature/Humidity Sensor

**Device type:** Indoor environmental sensor, DIN-rail mount
**Firmware version:** 1.2.0 (ESP32-S3)
**Protocols:** MQTT 3.1.1 over TLS 1.3

### Telemetry Schema (v2)
Topic: `devices/{device_id}/telemetry`
Interval: 30 seconds
```json
{
  "schema_version": 2,
  "device_id": "th100-a1b2c3",
  "timestamp": "2025-01-15T10:30:00Z",
  "temperature_c": 22.5,
  "humidity_pct": 45.2,
  "battery_v": 3.7
}
```

### Command Schema
Topic: `devices/{device_id}/commands`
- `set_interval` — `{"interval_s": 60}` → changes telemetry interval
- `reboot` — `{}` → triggers device reboot with status confirmation

### OTA
A/B partition. Download from `ota/{device_id}/firmware`. Ed25519 signature verification.
Watchdog triggers rollback if new firmware fails 3 consecutive boot attempts.

### Security
X.509 client certificate provisioned at manufacturing. TLS 1.3. No PSK fallback.
```
