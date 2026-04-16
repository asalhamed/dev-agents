# Edge-Cloud Sync Patterns

## Event Sourcing at Edge

```
Edge stores events (immutable facts):
  [timestamp, device_id, event_type, data]

On sync:
  Send unsent events to cloud (ordered by timestamp)
  Cloud applies events to its state
  Edge marks events as synced
```

Benefits: never lose data, cloud can reconstruct full history, idempotent replay.

## CRDTs (Conflict-Free Replicated Data Types)

When edge and cloud both modify the same data:

- **G-Counter:** only increment (count of alerts)
- **PN-Counter:** increment and decrement
- **LWW-Register:** last writer wins with timestamp
- **OR-Set:** add/remove from set, concurrent adds both preserved

```
Edge: config.threshold = 80 (at T1)
Cloud: config.threshold = 90 (at T2)
Sync: T2 > T1 → threshold = 90 (LWW)
```

Use CRDTs for device configuration that can be modified from edge or cloud.

## Last-Write-Wins vs Vector Clocks

### LWW (Simple)
- Each write has a timestamp
- Higher timestamp wins on conflict
- **Problem:** clock skew between edge and cloud

### Vector Clocks (Precise)
- Each node has a logical clock: `{edge: 3, cloud: 5}`
- Detects true conflicts (concurrent writes)
- **Problem:** complexity, growing clock vectors

**Recommendation:** Use LWW with NTP-synced clocks for most cases.
Use vector clocks only for critical data where conflicts must be explicitly resolved.

## Partial Sync

Don't sync everything. Strategies:
- **Changed-only:** track dirty flag per record, sync only dirty records
- **Time-based:** sync records modified since last sync timestamp
- **Priority-based:** alerts sync first, telemetry summaries next, raw data last

```
Sync priority queue:
1. Alerts (immediate — sync within 5s of connectivity)
2. Device status changes (next — within 30s)
3. Aggregated telemetry (batched — every 5 minutes)
4. Raw telemetry (background — when idle bandwidth available)
```

## Handling Clock Skew

Edge devices may have inaccurate clocks (no NTP, RTC drift, battery loss).

Mitigations:
- **NTP sync on boot** (if internet available)
- **Relative timestamps** — monotonic clock for intervals, wall clock for display
- **Cloud assigns canonical timestamp** on receipt (edge timestamp is metadata, not truth)
- **Sequence numbers** — monotonic counter per device, independent of clock

## Sync Protocol

```
Edge                            Cloud
  │                               │
  ├── sync request ──────────────►│  {last_sync_id: 12345}
  │                               │
  │◄── changes since 12345 ──────┤  cloud→edge changes
  │                               │
  ├── edge changes ──────────────►│  edge→cloud changes
  │                               │
  │◄── ack {new_sync_id: 12389} ─┤
  │                               │
  Edge updates last_sync_id       │
```

## Key Rules

- **Idempotent sync** — replaying the same data produces the same result
- **Bounded queue** — don't let sync queue grow unbounded when offline
- **Conflict resolution strategy** — decide before building (LWW, CRDT, or manual)
- **Compression** — gzip sync payloads, especially telemetry batches
