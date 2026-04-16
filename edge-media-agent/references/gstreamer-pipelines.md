# GStreamer Pipeline Patterns

## RTSP Ingestion

```bash
# Basic RTSP receive and display
gst-launch-1.0 rtspsrc location=rtsp://admin:pass@192.168.1.100:554/stream1 \
  latency=100 ! rtph264depay ! h264parse ! avdec_h264 ! videoconvert ! autovideosink

# RTSP receive, keep H.264 encoded (no decode)
gst-launch-1.0 rtspsrc location=rtsp://camera:554/stream1 \
  latency=200 protocols=tcp ! rtph264depay ! h264parse ! queue ! fakesink
```

## Transcoding

```bash
# H.264 → H.265 transcoding
gst-launch-1.0 rtspsrc location=rtsp://camera:554/stream1 \
  ! rtph264depay ! h264parse ! avdec_h264 \
  ! videoconvert ! x265enc bitrate=2000 speed-preset=fast \
  ! h265parse ! mp4mux ! filesink location=output.mp4

# Resize and re-encode
gst-launch-1.0 rtspsrc location=rtsp://camera:554/stream1 \
  ! rtph264depay ! h264parse ! avdec_h264 \
  ! videoscale ! video/x-raw,width=1280,height=720 \
  ! x264enc bitrate=2000 speed-preset=fast tune=zerolatency \
  ! h264parse ! mp4mux ! filesink location=output.mp4
```

## Recording to File

```bash
# Record RTSP to MP4 (passthrough, no re-encode)
gst-launch-1.0 rtspsrc location=rtsp://camera:554/stream1 \
  ! rtph264depay ! h264parse ! mp4mux ! filesink location=recording.mp4

# Segmented recording (new file every 5 minutes)
gst-launch-1.0 rtspsrc location=rtsp://camera:554/stream1 \
  ! rtph264depay ! h264parse \
  ! splitmuxsink location=recording_%05d.mp4 max-size-time=300000000000
```

## HLS Output

```bash
# RTSP → HLS segments
gst-launch-1.0 rtspsrc location=rtsp://camera:554/stream1 \
  ! rtph264depay ! h264parse \
  ! hlssink2 playlist-root=https://cdn.example.com/cam1 \
    location=segment_%05d.ts \
    playlist-location=playlist.m3u8 \
    target-duration=6 max-files=10
```

## WebRTC Output (with webrtcbin)

```python
# Python GStreamer for WebRTC (conceptual)
pipeline = Gst.parse_launch("""
    rtspsrc location=rtsp://camera:554/stream1 latency=100
    ! rtph264depay ! h264parse ! queue
    ! rtph264pay config-interval=-1 pt=96
    ! webrtcbin name=webrtc bundle-policy=max-bundle
""")

webrtc = pipeline.get_by_name("webrtc")
webrtc.connect("on-negotiation-needed", on_negotiation_needed)
webrtc.connect("on-ice-candidate", on_ice_candidate)
```

## Tee (Fork Pipeline)

```bash
# Live WebRTC + HLS recording from single RTSP source
gst-launch-1.0 rtspsrc location=rtsp://camera:554/stream1 latency=100 \
  ! rtph264depay ! h264parse ! tee name=t \
  t. ! queue ! rtph264pay ! webrtcbin \
  t. ! queue ! hlssink2 target-duration=6 location=seg_%05d.ts playlist-location=live.m3u8
```

## Key Rules

- **Use `queue` between branches** of a tee to prevent blocking
- **`latency=100-200`** on rtspsrc for low-latency live viewing
- **`protocols=tcp`** if UDP is unreliable on the network
- **Passthrough when possible** — avoid decode/re-encode unless you need to resize or change codec
- **`speed-preset=fast` or `ultrafast`** for real-time encoding (not `slow`/`veryslow`)
