# RTSP → WebRTC + HLS Pipeline

**Tags:** video, rtsp, webrtc, hls, sfu, gstreamer

## Input

Design a streaming pipeline that ingests RTSP from 50 IP cameras, delivers live WebRTC streams to browsers (<1s latency), and records HLS segments to S3.

## Expected Behavior

Agent designs GStreamer/FFmpeg pipeline with SFU architecture for WebRTC, TURN server for NAT traversal, HLS recording with S3 lifecycle policies, and camera disconnect handling.

## Pass Criteria

- [ ] RTSP ingestion → transcoding → WebRTC + HLS fork
- [ ] SFU architecture (not P2P for 50 cameras)
- [ ] TURN server for NAT traversal
- [ ] HLS segment lifecycle and S3 retention defined
- [ ] Camera disconnect auto-reconnect
- [ ] Produces streaming-spec contract

## Fail Criteria

- P2P architecture (won't scale to 50 cameras)
- No TURN server (20% of viewers can't connect)
- No recording retention policy
- No disconnect handling
