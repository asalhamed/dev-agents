# Streaming Specification

**Producer:** edge-media-agent
**Consumer(s):** devops-agent, qa-agent, reviewer, observability-agent, privacy-agent

## Required Fields

- **Input source** — RTSP / ONVIF / SRT / WebRTC URL format, camera model, resolution,
  framerate, color depth
- **Output protocols** — WebRTC, HLS, LL-HLS, DASH, RTMP, SRT (with target use case per leg)
- **Transcoding pipeline** — tools (GStreamer / FFmpeg / custom), codec, profile, hardware
  acceleration path, **bitrate ladder**
- **Keyframe cadence** — interval in seconds, chosen for seekability vs. efficiency
- **Recording strategy** — storage location, segment duration, retention per tier
- **Latency SLO** — target and maximum glass-to-glass latency; SLI definition;
  instrumentation points (capture timestamp → encode → egress → viewer render)
- **Bitrate envelope** — min / expected / peak bitrate per stream; CBR vs VBR; burst budget
- **Jitter budget** — tolerable jitter before ABR step-down; measurement window
- **Bandwidth requirements** — per-stream ingest and egress budget + aggregate for the site
- **Error handling** — camera disconnect behavior, reconnect strategy, failover, graceful
  degradation under packet loss (1 %, 5 %, 10 %) and under GPU/CPU saturation
- **Privacy fields** — declared `Purpose`, applicable `RetentionWindow` per tier, applicable
  `RedactionPolicy` for export, link to the `privacy-review.md` contract (owned by
  `privacy-agent`)

## Validation Checklist

- [ ] Latency SLO is a concrete number with a defined SLI and instrumentation points
- [ ] Keyframe cadence stated and matches the use case (seek-friendly vs. bandwidth-efficient)
- [ ] Bitrate envelope covers min / expected / peak; burst budget stated
- [ ] Jitter budget stated with a measurement window
- [ ] Recording retention policy specified per tier; deletion is automated, not manual
- [ ] Camera disconnect/reconnect handled (automatic, with bounded backoff)
- [ ] Bandwidth budget documented per stream and aggregate, including CV metadata egress
- [ ] Graceful degradation under packet loss and resource saturation is specified
- [ ] `Purpose` is declared for every captured stream; cross-referenced to
  `privacy-review.md`
- [ ] If biometric processing occurs, consent-bypass analysis is completed in the
  threat-model contract

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
