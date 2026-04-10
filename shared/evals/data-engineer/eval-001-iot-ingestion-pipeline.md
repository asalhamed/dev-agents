# IoT Telemetry Ingestion Pipeline

**Tags:** data, kafka, time-series, ingestion, iot

## Input

Design a data ingestion pipeline for 50,000 IoT devices publishing telemetry every 30s. Data must be queryable within 60s and retained for 30 days raw, 1 year aggregated.

## Expected Behavior

Agent designs Kafka-based ingestion with device_id partition key, time-series storage selection with rationale, downsampling strategy, and retention policies.

## Pass Criteria

- [ ] Kafka ingestion with device_id partition key
- [ ] Time-series DB selection with rationale
- [ ] Downsampling: raw 30d → hourly 1y
- [ ] Query latency <60s for recent data
- [ ] Back-pressure handling
- [ ] Produces implementation-summary

## Fail Criteria

- No Kafka (direct DB writes, won't scale)
- No downsampling (infinite storage growth)
- No retention policy
- No back-pressure handling
