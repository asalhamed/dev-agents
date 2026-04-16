# Edge Person Detection on Raspberry Pi 4

**Tags:** ml, edge, quantization, person-detection, rpi

## Input

Deploy a person detection model to Raspberry Pi 4 (4GB RAM). Must run at ≥10 FPS on 1080p video with <500ms alert latency.

## Expected Behavior

Agent selects lightweight model (YOLOv8-nano or MobileNet), applies INT8 quantization, validates FPS on target hardware, and measures end-to-end alert latency.

## Pass Criteria

- [ ] Lightweight model appropriate for RPi4
- [ ] INT8 quantization applied
- [ ] FPS validated on target hardware
- [ ] End-to-end latency validated
- [ ] Produces model-spec contract

## Fail Criteria

- Full-size model that won't fit in 4GB RAM
- No quantization (too slow)
- Only tests on GPU server, not RPi4
- No end-to-end latency measurement
