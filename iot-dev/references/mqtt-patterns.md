# MQTT Patterns for Device Fleets

## Topic Hierarchy Design

Use hierarchical topics. Never flat.

```
{org}/{site}/{device_type}/{device_id}/{channel}

Example:
acme/site-a/th100/dev-001/telemetry
acme/site-a/th100/dev-001/status
acme/site-a/th100/dev-001/commands
acme/site-a/th100/dev-001/commands/response
acme/site-a/th100/dev-001/ota/notify
acme/site-a/th100/dev-001/ota/status
```

### Naming Conventions
- Lowercase, hyphens (not underscores or camelCase)
- No leading slash (`acme/...` not `/acme/...`)
- No spaces or special characters
- Device ID in topic (not just in payload)

## QoS Levels

| QoS | Name | Use When |
|-----|------|----------|
| 0 | At most once | High-frequency telemetry where occasional loss is acceptable |
| 1 | At least once | Commands, status updates, alerts — must arrive (idempotent consumers) |
| 2 | Exactly once | Billing events, one-time provisioning — rarely needed, expensive |

**Default to QoS 1.** QoS 0 only for telemetry >1Hz where loss is tolerable. QoS 2 almost never.

## Retained Messages

Use retained for state that new subscribers need immediately:
- Device status (online/offline/battery level)
- Current configuration
- Last known location

**Never retain** telemetry streams or commands.

## Last Will and Testament (LWT)

```
Topic: {org}/{site}/{type}/{id}/status
Payload: {"status": "offline", "timestamp": "..."}
QoS: 1
Retain: true
```

On clean disconnect, publish `{"status": "offline", "reason": "shutdown"}` explicitly.
LWT fires only on ungraceful disconnect.

## Reconnect with Exponential Backoff

```
Attempt 1: wait 1s
Attempt 2: wait 2s
Attempt 3: wait 4s
...
Attempt N: wait min(2^N, 60s) + random jitter (0-1s)
```

Add jitter to prevent thundering herd when broker restarts and all devices reconnect simultaneously.

## Wildcard Subscriptions

```
# Single level: + matches one level
acme/site-a/+/+/telemetry    → all devices at site-a telemetry

# Multi level: # matches all remaining levels
acme/site-a/#                 → everything at site-a

# Backend subscribes to:
acme/+/+/+/telemetry          → all telemetry across all sites
```

**Never subscribe to `#`** (all topics) in production. Always scope to what you need.

## Message Format

```json
{
  "schema_version": 2,
  "device_id": "th100-a1b2c3",
  "timestamp": "2025-01-15T10:30:00Z",
  "payload": { "temperature_c": 22.5, "humidity_pct": 45.2 }
}
```

Always include `schema_version` and `timestamp` (ISO 8601 UTC).
