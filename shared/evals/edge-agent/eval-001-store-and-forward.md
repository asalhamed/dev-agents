# Store-and-Forward Edge Gateway

**Tags:** edge, mqtt, aggregation, sync, offline

## Input

Implement a store-and-forward edge gateway for 100 local sensors: collect MQTT telemetry, filter noise, aggregate 1-minute summaries, and sync to cloud when connectivity is available.

## Expected Behavior

Agent designs local MQTT broker, aggregation pipeline with 60x data reduction, bounded local buffer (7-day retention), and idempotent cloud sync.

## Pass Criteria

- [ ] Local MQTT broker for device-to-edge communication
- [ ] 1-minute aggregation reduces data volume
- [ ] Bounded local buffer (7 days max)
- [ ] Cloud sync is idempotent
- [ ] Works fully offline (local dashboard)
- [ ] Produces implementation-summary

## Fail Criteria

- No local MQTT broker (devices connect directly to cloud)
- No aggregation (raw data forwarded)
- Unbounded buffer
- Sync not idempotent
