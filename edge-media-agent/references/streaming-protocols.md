# Streaming Protocol Comparison

| Protocol | Latency | Browser | Infrastructure | Best For |
|----------|---------|---------|----------------|----------|
| **RTSP** | <1s | ❌ (needs plugin/native) | Camera → server | Camera ingestion |
| **WebRTC** | <500ms | ✅ | STUN/TURN/SFU | Live viewing in browser |
| **HLS** | 6-30s (LL-HLS: 2-4s) | ✅ | CDN/S3 | Recording playback, VOD |
| **DASH** | 6-30s | ✅ | CDN | Similar to HLS, less Apple |
| **SRT** | <1s | ❌ | Point-to-point | Contribution feed, unreliable networks |
| **RTMP** | 1-3s | ❌ (Flash dead) | Media server | Legacy ingest (still used) |

## When to Use Each for Remote Monitoring

- **RTSP:** Camera → server ingestion. All IP cameras speak RTSP. Don't expose to browsers.
- **WebRTC:** Live viewing in browser/mobile. Sub-second latency. Requires TURN for NAT traversal.
- **HLS:** Recording playback. Store segments in S3. Works everywhere. Accept 6s+ latency.
- **SRT:** Site-to-cloud contribution over unreliable links. Built-in error correction.

## Typical Pipeline

```
Camera ──RTSP──► Ingest Server ──┬──WebRTC──► Live Viewers
                                 └──HLS────► Recording (S3)
```

## Protocol Details

### RTSP
- Port 554 (TCP) + RTP (UDP or TCP interleaved)
- URL: `rtsp://user:pass@camera-ip:554/stream1`
- Authentication: Basic or Digest (Digest preferred)
- No encryption natively — tunnel over VPN or use RTSPS (TLS)

### WebRTC
- P2P or SFU (prefer SFU for monitoring — centralized control)
- ICE for NAT traversal: STUN (80% of cases), TURN (fallback)
- Codec: H.264 (universal), VP8/VP9 (better compression, less hardware support)
- Signaling: custom (WebSocket typically)

### HLS
- HTTP-based — works with any CDN
- Segments: 6s default (2s for LL-HLS)
- Playlist: `.m3u8` manifest, `.ts` or `.fmp4` segments
- Adaptive bitrate: multiple renditions in master playlist

### SRT
- UDP-based with ARQ (automatic repeat request)
- Configurable latency buffer (tradeoff: latency vs reliability)
- Encryption: AES-128/256 built-in
- Good for: 2-20 Mbps over lossy links (cellular, satellite)
