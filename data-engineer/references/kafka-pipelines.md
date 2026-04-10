# Kafka Pipelines for IoT

## Topic Design

### Partition Key Strategy
- **By device_id:** all messages from one device go to same partition → ordering guaranteed per device
- **Partition count:** start with 12-24 (can increase later, cannot decrease)

```
Topics:
  telemetry.raw          — all raw device telemetry (key: device_id)
  telemetry.aggregated   — 1-minute summaries (key: device_id)
  alerts.detected        — anomaly/threshold alerts (key: device_id)
  commands.outbound      — commands to devices (key: device_id)
  devices.status         — device online/offline events (key: device_id)
```

### Retention
- **Log retention:** time-based (7 days for raw telemetry) or size-based
- **Compacted topics:** keep latest value per key (device status, config)
- **alerts:** longer retention (30-90 days for audit)

## Consumer Groups

```
consumer-group: telemetry-aggregator    → reads telemetry.raw, writes telemetry.aggregated
consumer-group: alert-engine            → reads telemetry.raw, writes alerts.detected
consumer-group: dashboard-feeder        → reads telemetry.aggregated, updates dashboard cache
consumer-group: long-term-storage       → reads telemetry.aggregated, writes to TimescaleDB
```

Each consumer group gets independent progress. Multiple groups can read same topic.

## Exactly-Once Semantics

**When needed:** billing events, alert state changes, anything where duplicates cause harm.
**Cost:** higher latency (~100ms), more broker coordination, idempotent producer required.

```python
producer = KafkaProducer(
    enable_idempotence=True,
    transactional_id="alert-processor-1"
)
producer.init_transactions()
producer.begin_transaction()
producer.send("alerts.detected", value=alert)
producer.commit_transaction()
```

**Most IoT telemetry doesn't need exactly-once.** At-least-once with idempotent consumers is cheaper.

## Schema Registry

| Format | Size | Schema Evolution | Tooling |
|--------|------|-----------------|---------|
| Avro | Small (binary) | Excellent | Confluent Schema Registry |
| Protobuf | Small (binary) | Good | Buf, Confluent |
| JSON Schema | Large (text) | Basic | Confluent, any |

**Recommendation:** Avro for high-throughput telemetry. JSON Schema for low-volume, human-readable.

## Dead-Letter Queue

```
telemetry.raw → [consumer] → success → telemetry.aggregated
                           → failure → telemetry.raw.dlq
```

After 3 retries, send to DLQ. Monitor DLQ size. Alert if growing.

## Stream Processing

| Tool | Latency | Complexity | Best For |
|------|---------|------------|----------|
| Kafka Streams | Low | Medium | Java/Kotlin teams, moderate complexity |
| Apache Flink | Very low | High | Complex event processing, exactly-once |
| ksqlDB | Low | Low | SQL-based, simple transformations |

For IoT: Kafka Streams is usually sufficient. Flink if you need complex windowing or exactly-once across topics.
