# Bandwidth-Constrained Remote Site

**Tags:** video, bandwidth, adaptive, edge, recording

## Input

A remote site has 2Mbps uplink shared by 4 cameras. Design a bandwidth-adaptive solution that prioritizes live viewing over recording and degrades gracefully.

## Expected Behavior

Agent designs bandwidth allocation strategy with priority queuing, adaptive bitrate for live streams, local buffering for recording, and graceful degradation plan.

## Pass Criteria

- [ ] Bandwidth budget allocated between live and recording
- [ ] Live viewing gets priority over recording
- [ ] Adaptive bitrate: reduce quality before dropping
- [ ] Local buffering for recording when constrained
- [ ] Degradation strategy documented
- [ ] Produces streaming-spec contract

## Fail Criteria

- No bandwidth budgeting
- Recording and live compete equally
- Stream drops entirely instead of degrading
- No local buffering
