# IoT Startup Roles

## Embedded Software Engineer
**Skills:** Rust or C, MQTT, RTOS (FreeRTOS/Zephyr), PCB bring-up, oscilloscope
**Compensation (Senior, US):** $160K-$200K base + equity
**Interview questions:**
- Design an OTA update system with rollback capability
- Debug a sensor that reads correctly 95% of the time but gives noise 5%
- Explain MQTT QoS levels — when would you use each?
- Walk through power optimization for a battery-powered sensor

## Video Engineer
**Skills:** GStreamer, FFmpeg, WebRTC, RTSP, H.264/H.265, Linux video stack
**Compensation (Senior, US):** $170K-$210K base + equity
**Interview questions:**
- Design a pipeline for 50 RTSP cameras to WebRTC + HLS
- How do you debug a 3-second latency in a WebRTC stream?
- Compare SFU vs MCU for a monitoring use case
- Handle camera disconnect/reconnect without viewer interruption

## Android Developer
**Skills:** Kotlin, Jetpack Compose, CameraX, ExoPlayer, MVVM, Room
**Compensation (Senior, US):** $160K-$195K base + equity
**Interview questions:**
- Implement offline-first data sync for a monitoring app
- Integrate RTSP live feed in a Compose UI
- Design state management for a multi-camera dashboard
- Handle background location + push notifications

## ML Engineer
**Skills:** PyTorch, ONNX, TFLite, computer vision, edge deployment
**Compensation (Senior, US):** $180K-$230K base + equity
**Interview questions:**
- Deploy a person detection model on Jetson Nano at 15 FPS
- Design anomaly detection for vibration sensor data
- Quantize a model to INT8 — what accuracy loss is acceptable?
- Monitor model drift in production — what metrics and thresholds?

## Data Engineer
**Skills:** Kafka, ClickHouse/TimescaleDB, Python/Scala, Spark/Flink, dbt
**Compensation (Senior, US):** $160K-$200K base + equity
**Interview questions:**
- Design ingestion pipeline for 100K devices publishing every 30s
- Kafka topic design: partition key strategy for IoT telemetry
- Implement downsampling: raw (30 days) → hourly (1 year) → daily (forever)
- Handle late-arriving data in a streaming pipeline
