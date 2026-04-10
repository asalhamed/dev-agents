# Protocol Specification

**Producer:** iot-dev ↔ backend-dev (bidirectional)
**Consumer(s):** architect, tech-lead

## Required Fields

- **Protocol type** — MQTT / HTTP / WebSocket / CoAP / custom
- **Topic/endpoint definitions** — full topic hierarchy or endpoint list
- **Message schemas** — payload format with version, field types, examples
- **QoS/reliability guarantees** — delivery semantics (at-most-once, at-least-once, exactly-once)
- **Authentication mechanism** — how clients authenticate to the broker/server
- **Error handling** — malformed message behavior, rejection codes, retry guidance

## Validation Checklist

- [ ] All topics/endpoints documented with direction (device→cloud, cloud→device, bidirectional)
- [ ] Message schemas versioned (breaking changes require new topic/version)
- [ ] Auth mechanism specified (mutual TLS, token, API key)
- [ ] Error/rejection behavior defined (what happens with malformed or unauthorized messages)

## Example (valid)

```markdown
## PROTOCOL SPEC: Device Fleet MQTT

**Protocol:** MQTT 3.1.1 over TLS 1.3
**Broker:** EMQX cluster (mqtt.platform.internal:8883)
**Auth:** Mutual TLS (X.509 client certificates)

### Topic Hierarchy

| Topic | Direction | QoS | Purpose |
|-------|-----------|-----|---------|
| `devices/{id}/telemetry` | device→cloud | 1 | Sensor readings |
| `devices/{id}/status` | device→cloud | 1 (retained) | Online/offline/battery |
| `devices/{id}/commands` | cloud→device | 1 | Remote commands |
| `devices/{id}/commands/response` | device→cloud | 1 | Command acknowledgment |
| `devices/{id}/ota/notify` | cloud→device | 1 | New firmware available |
| `devices/{id}/ota/status` | device→cloud | 1 | OTA progress reporting |

### Last Will and Testament
Topic: `devices/{id}/status`
Payload: `{"status": "offline", "timestamp": "..."}`
QoS: 1, Retained: true

### Error Handling
- Malformed JSON: broker logs, message dropped (QoS 0 behavior)
- Unauthorized topic: connection terminated, event logged
- Schema version mismatch: consumer logs warning, processes best-effort
```
