# Edge ML Deployment — Person Detection on Jetson

**Tags:** edge, ml, onnx, jetson, inference

## Input

Deploy a person detection ML model on NVIDIA Jetson. Run inference on video frames, trigger alerts locally, send only alert clips (not full video) to cloud.

## Expected Behavior

Agent configures ONNX Runtime with TensorRT backend, processes video frames at ≥10 FPS, generates local alerts, and uploads only alert clips to save bandwidth.

## Pass Criteria

- [ ] ONNX Runtime with TensorRT backend
- [ ] Only alert clips uploaded (not continuous video)
- [ ] Local alert before cloud sync
- [ ] ≥10 FPS inference rate
- [ ] Produces implementation-summary

## Fail Criteria

- Streams full video to cloud for processing
- CPU-only inference (too slow)
- No local alerting
- Cloud-dependent operation
