# Multi-Repo Microservice Patterns

## Service Decomposition

Each bounded context = one service = one repo. Signs a service should split:

| Signal | Action |
|--------|--------|
| Two teams frequently conflict on the same repo | Split along team boundaries |
| CI takes >15 minutes | Service is too big — split by subdomain |
| Deploy frequency differs (team A deploys daily, team B monthly) | Split into independent services |
| A failure in module X crashes unrelated module Y | Split for fault isolation |

## Inter-Service Communication

| Pattern | When to use | Contract type |
|---------|-------------|--------------|
| Synchronous REST/gRPC | Query that needs immediate response | OpenAPI / Protobuf |
| Async events (Kafka) | Something happened, consumers react | Avro / AsyncAPI |
| MQTT | Device-to-cloud telemetry | MQTT topic schema |
| WebSocket | Real-time streaming to browser/app | Custom, documented |

### Rules
- **Prefer async events over sync calls** — reduces coupling, improves resilience
- **Sync calls create runtime dependencies** — if service B is down, service A fails
- **Events create eventual consistency** — acceptable for most business operations
- **Commands vs queries** — commands can be async (fire-and-forget); queries must be sync

## Contract Versioning

```
platform-contracts/
├── api/
│   ├── order-service.yaml        # current version
│   └── order-service.v1.yaml     # deprecated, removal date in header
├── events/
│   ├── order-events.avsc         # latest, backward-compatible
│   └── COMPATIBILITY.md          # which versions are still supported
```

### Compatibility Matrix

| Event schema version | Producing services | Consuming services | Status |
|---------------------|--------------------|--------------------|--------|
| order-events v1 | order-service ≤ v2.0 | notification-service, data-platform | Deprecated — remove by YYYY-MM-DD |
| order-events v2 | order-service ≥ v2.1 | notification-service, data-platform, alert-service | Current |

## Local Development

Each developer works on ONE service at a time. Dependencies are stubbed:

```
Option A: Docker Compose (recommended for most devs)
  - Run your service natively
  - Run dependencies via docker-compose.yml

Option B: Full stack (rare, for E2E testing)
  - Use infrastructure/docker-compose.dev.yml
  - Runs ALL services locally
  - Slow, resource-heavy — only for integration debugging

Option C: Stub/mock dependencies
  - Use WireMock for REST dependencies
  - Use embedded Kafka test broker
  - Fastest iteration, but may miss integration issues
```

## Database Isolation

```
❌ NEVER: Two services sharing a database

  order-service ──┐
                  ├── PostgreSQL (shared)
  notification-service ──┘

✅ ALWAYS: Each service owns its database

  order-service ──── order-db (PostgreSQL)
  notification-service ──── notification-db (PostgreSQL)
  video-service ──── video-metadata-db (PostgreSQL) + video-storage (S3)
  device-fleet-service ──── device-db (PostgreSQL) + telemetry-db (TimescaleDB)
```

If service A needs data from service B:
1. Service B publishes a domain event
2. Service A consumes the event and stores its own projection
3. OR service A calls service B's API (sync — creates runtime coupling)

## Schema Registry

Event schemas (Avro/Protobuf) require a schema registry for runtime validation and evolution.
**This choice must be recorded in an ADR before the first Avro schema is deployed.**

| Option | Pros | Cons |
|--------|------|------|
| Confluent Schema Registry | Mature, well-documented, Kafka-native | Requires Confluent licence for some features |
| Apicurio Registry | Open source, Kafka + REST APIs | Less tooling maturity |
| AWS Glue Schema Registry | Managed, no ops | AWS lock-in |

Do not start Avro implementation until the ADR is accepted.
