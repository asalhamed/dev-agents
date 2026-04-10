# Streaming Specification

**Producer:** video-streaming
**Consumer(s):** devops-agent, qa-agent, reviewer

## Required Fields

- **Input source** — RTSP URL format, camera type/model, resolution, framerate
- **Output protocols** — WebRTC, HLS, RTMP (with target use case for each)
- **Transcoding pipeline** — tools (GStreamer/FFmpeg), codec, profile, bitrate ladder
- **Recording strategy** — storage location, segment duration, retention policy
- **Latency target** — end-to-end camera-to-viewer latency requirement
- **Bandwidth requirements** — per-stream ingest and egress bandwidth budget
- **Error handling** — camera disconnect behavior, reconnect strategy, failover

## Validation Checklist

- [ ] Latency target defined and measurable (e.g., <1s for live, <10s for HLS)
- [ ] Recording retention policy specified (days, auto-delete, tiered storage)
- [ ] Camera disconnect/reconnect handled (automatic, with backoff)
- [ ] Bandwidth budget documented (per camera and aggregate)

## Example (valid)

```markdown
## STREAMING SPEC: Site Monitoring — Building A

**Input:** 8× Axis M3065-V cameras, RTSP (rtsp://{ip}:554/stream1), 1080p@15fps, H.264
**Live output:** WebRTC via Pion SFU — target <800ms latency
**Recording output:** HLS segments (6s) to S3 — 30-day retention

### Transcoding Pipeline
GStreamer: rtspsrc → h264parse → tee
  Branch 1: → webrtcbin (passthrough H.264, no re-encode)
  Branch 2: → hlssink2 (6s segments, 5-segment playlist)

### Bandwidth Budget
- Per camera ingest: 4 Mbps (1080p H.264 CBR)
- Site uplink for 8 cameras: 32 Mbps (dedicated VLAN)
- WebRTC egress per viewer: 4 Mbps

### Error Handling
- Camera disconnect: retry every 5s with exponential backoff (max 60s)
- WebRTC viewer disconnect: session cleanup after 30s timeout
- Recording gap: log gap event, resume recording on reconnect
```
