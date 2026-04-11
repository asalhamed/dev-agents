# Service Dependency Map

## How to Read This

- **Produces:** this service publishes this contract (API or event)
- **Consumes:** this service depends on this contract
- **Breaking a produced contract requires notifying ALL consumers**
- **Adding a new consumer requires no notification**

## Dependency Matrix

_Fill in this table for your organization's services. Example below:_

| Service | Produces | Consumes |
|---------|----------|----------|
| order-service | `api/order-service.yaml`, `events/order-events.avsc` | `events/device-telemetry.avsc` (for IoT-triggered orders) |
| notification-service | `api/notification-service.yaml` | `events/order-events.avsc`, `events/alert-events.avsc` |
| video-service | `api/video-service.yaml`, `events/video-events.avsc` | `mqtt/device-fleet.yaml` (camera telemetry) |
| device-fleet-service | `api/device-fleet-service.yaml`, `events/device-telemetry.avsc` | — |
| alert-service | `events/alert-events.avsc` | `events/device-telemetry.avsc`, `events/video-events.avsc` |
| edge-runtime | — | `mqtt/device-fleet.yaml`, `events/alert-events.avsc` |
| ml-pipeline | — | `events/video-events.avsc` (frame extraction), `events/device-telemetry.avsc` |
| monitoring-android | — | `api/order-service.yaml`, `api/video-service.yaml`, `api/device-fleet-service.yaml`, `api/notification-service.yaml` |
| monitoring-dashboard | — | `api/order-service.yaml`, `api/video-service.yaml`, `api/device-fleet-service.yaml` |
| data-platform | — | `events/order-events.avsc`, `events/device-telemetry.avsc`, `events/video-events.avsc`, `events/alert-events.avsc` |

## Visualization

```
                    ┌──────────────────┐
                    │ platform-contracts│
                    │ (single source   │
                    │  of truth)       │
                    └────────┬─────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
   API specs            Event schemas        MQTT schemas
   (OpenAPI)            (Avro/Proto)         (AsyncAPI)
        │                    │                    │
   ┌────┼────┐          ┌────┼────┐          ┌───┼───┐
   │    │    │          │    │    │          │       │
 order notif video   order device alert   device  video
 -svc  -svc  -svc   events telemetry events  fleet   ingest
   │    │    │          │    │    │          │       │
   ▼    ▼    ▼          ▼    ▼    ▼          ▼       ▼
 [consumers fetch     [consumers subscribe  [devices &
  generated SDK        to Kafka topics]      edge-runtime
  from contracts]                            connect via MQTT]
```

## Maintenance Rules

- Update this file whenever a new service is added or a contract is created/deprecated
- This file is the source of truth for "who will break if I change X"
- Maintained by the architect agent; changes require a PR review
