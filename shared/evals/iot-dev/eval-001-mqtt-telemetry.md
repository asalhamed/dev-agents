# MQTT Telemetry Publishing — ESP32

**Tags:** iot, mqtt, esp32, telemetry, offline-buffer

## Input

Implement MQTT telemetry publishing for a temperature/humidity sensor on an ESP32. Publish every 30s, buffer readings when offline, and reconnect with exponential backoff.

## Expected Behavior

Agent produces MQTT client code with proper topic hierarchy, versioned telemetry schema, secure credential loading, bounded offline buffer, and reconnection logic.

## Pass Criteria

- [ ] MQTT topic follows hierarchy (devices/{id}/telemetry)
- [ ] Credentials loaded from secure storage (not hardcoded)
- [ ] Local buffer for offline readings (FIFO, bounded)
- [ ] Exponential backoff on reconnect with jitter
- [ ] Telemetry schema includes version field
- [ ] Produces device-spec contract

## Fail Criteria

- Hardcoded credentials in source
- No offline buffering
- Flat topic structure
- No reconnection logic
- Unbounded buffer (memory leak risk)
