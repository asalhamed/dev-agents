# Edge Computing Architectures

## Pattern: Local Processing + Cloud Sync

```
Devices ──MQTT──► Edge Gateway ──────► Cloud
                      │
                  Local Processing
                  Local Dashboard
                  Local Storage (7 days)
```

Edge gateway handles: data collection, filtering, aggregation, local alerting.
Cloud receives: summaries, alerts, aggregated metrics (not raw telemetry).

## Pattern: Store-and-Forward

For intermittent connectivity:
1. Edge collects all data locally
2. Queues data for cloud upload
3. When connected: sync queue (oldest first or priority-based)
4. Cloud acknowledges receipt → edge deletes synced data
5. Bounded buffer: when full, drop oldest non-critical data

## Edge-Cloud Handoff Decisions

| Process Locally When | Process in Cloud When |
|---------------------|----------------------|
| Latency < 100ms needed | Complex analytics / ML training |
| Bandwidth is constrained | Cross-site correlation |
| Privacy requires local processing | Long-term storage |
| Must work offline | Dashboard for multiple sites |

## K3s for Edge Deployment

```yaml
# Lightweight Kubernetes for edge nodes
# Install: curl -sfL https://get.k3s.io | sh -
# Single node, <512MB RAM

apiVersion: apps/v1
kind: Deployment
metadata:
  name: edge-gateway
spec:
  replicas: 1
  template:
    spec:
      containers:
      - name: mqtt-broker
        image: eclipse-mosquitto:2
        resources:
          limits: { memory: "128Mi", cpu: "200m" }
      - name: edge-processor
        image: edge-processor:latest
        resources:
          limits: { memory: "256Mi", cpu: "500m" }
```

## Resource Budgets

| Hardware | RAM | CPU | Storage | Use Case |
|----------|-----|-----|---------|----------|
| Raspberry Pi 4 (4GB) | 4GB | 4-core ARM | 32-256GB SD | Light edge, <50 sensors |
| Raspberry Pi CM4 | 2-8GB | 4-core ARM | eMMC/NVMe | Industrial edge module |
| NVIDIA Jetson Nano | 4GB | 4-core ARM + 128 CUDA | 32GB eMMC | Edge ML inference |
| NVIDIA Jetson Orin Nano | 8GB | 6-core ARM + 1024 CUDA | 128GB NVMe | Multi-camera ML |
| Intel NUC | 8-32GB | 4-6 core x86 | 256GB-1TB NVMe | Full edge platform |

### Budget Allocation (4GB edge device)
- OS + K3s: ~500MB
- MQTT broker: 128MB
- Edge processor: 256MB
- ML inference: 1-2GB
- Buffer/cache: 1GB
- Reserve: 500MB

## Key Rules

- **Edge must work without cloud** — offline operation is not optional
- **Bounded storage** — always set retention limits, never fill the disk
- **Watchdog everything** — auto-restart crashed processes
- **Remote management** — SSH/VPN access for debugging (with auth)
- **Atomic updates** — edge software updates follow same A/B pattern as firmware
