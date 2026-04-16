# WebRTC Architecture for Video Monitoring

## Core Components

```
Camera ──RTSP──► Media Server ──WebRTC──► Browser
                     │
                  STUN/TURN
                     │
                  Signaling (WebSocket)
```

## ICE / STUN / TURN

- **ICE (Interactive Connectivity Establishment):** finds the best path between peers
- **STUN:** discovers public IP. Works for ~80% of NAT types. Free/lightweight.
- **TURN:** relays media when direct connection fails. Required for symmetric NAT. Bandwidth cost.

```
Viewer ──── STUN ────► discovers public IP
Viewer ──── direct ──► Media Server  (if possible)
Viewer ──── TURN ────► relay ────► Media Server  (fallback)
```

**Always deploy TURN.** Without it, ~20% of viewers can't connect.

## SFU vs MCU vs P2P

| Topology | Description | Best For |
|----------|-------------|----------|
| **P2P** | Direct camera-to-viewer | 1:1 calls, <5 viewers |
| **SFU** | Server forwards streams (no transcoding) | Monitoring (10-1000 viewers) |
| **MCU** | Server mixes into single stream | Video conferencing (not monitoring) |

**Use SFU for monitoring.** Scales to many viewers per camera without transcoding overhead.

## SFU Implementations

### Pion (Go)
```go
// Pion SFU — lightweight, Go-native
peerConnection, _ := webrtc.NewPeerConnection(config)
// Add track from RTSP ingest
videoTrack, _ := webrtc.NewTrackLocalStaticRTP(
    webrtc.RTPCodecCapability{MimeType: webrtc.MimeTypeH264}, "video", "camera-1")
peerConnection.AddTrack(videoTrack)
// Forward RTP packets from RTSP source to track
```

- Pros: lightweight, easy to embed, excellent Go ecosystem
- Cons: build your own SFU logic (or use ion-sfu)

### mediasoup (Node.js)
```javascript
// mediasoup — full SFU with room management
const worker = await mediasoup.createWorker();
const router = await worker.createRouter({ mediaCodecs });
const transport = await router.createWebRtcTransport(transportOptions);
const producer = await transport.produce({ kind: 'video', rtpParameters });
// Consumers subscribe to producer
```

- Pros: battle-tested, room management built-in, good for multi-camera dashboards
- Cons: Node.js (more resource-heavy than Go)

## Signaling (WebSocket)

```
Viewer                    Signaling Server              Media Server
  │                            │                            │
  ├── "join camera-1" ────────►│                            │
  │                            ├── "new viewer" ───────────►│
  │                            │◄── SDP offer ──────────────┤
  │◄── SDP offer ──────────────┤                            │
  ├── SDP answer ─────────────►│                            │
  │                            ├── SDP answer ─────────────►│
  │◄── ICE candidates ────────►│◄── ICE candidates ────────►│
  │                            │                            │
  │◄═══════════ WebRTC media stream (direct or via TURN) ══►│
```

## Latency Optimization

1. **No transcoding on the SFU** — passthrough H.264 from camera
2. **Short STUN/TURN timeout** — fail fast to TURN if direct path doesn't work
3. **Trickle ICE** — start streaming before all ICE candidates are gathered
4. **Jitter buffer tuning** — reduce from default 200ms to 50-100ms for monitoring
5. **PLI (Picture Loss Indication)** — request keyframe immediately on viewer connect

## Key Rules

- **SFU, not P2P** for monitoring (centralized control, scales to many viewers)
- **Always have TURN** — 20% of connections need it
- **H.264 passthrough** — don't re-encode on the SFU
- **Signaling is separate from media** — WebSocket for signaling, UDP for media
