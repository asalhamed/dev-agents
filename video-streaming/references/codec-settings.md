# Codec Settings for Video Surveillance

## H.264 vs H.265

| Feature | H.264 (AVC) | H.265 (HEVC) |
|---------|-------------|---------------|
| Compression | Baseline | ~40% better at same quality |
| CPU encode cost | Lower | 2-3x higher |
| Hardware support | Universal | Most modern devices |
| Browser support | Universal | Safari, some Chrome |
| Licensing | MPEG LA pool | Complex, patent pools |
| Recommendation | Default choice | Use when bandwidth is critical |

## Recommended Profiles for Surveillance

### H.264
- **Main Profile, Level 4.0** — 1080p@30fps, good balance
- **High Profile, Level 4.1** — 1080p@30fps, better compression, more CPU
- **Baseline Profile** — only for very constrained devices (no B-frames)

### H.265
- **Main Profile, Level 4.0** — 1080p@30fps
- **Main 10 Profile** — 10-bit color depth (rarely needed for surveillance)

## Bitrate Ladders

### Adaptive Streaming (HLS/DASH)

| Rendition | Resolution | FPS | H.264 Bitrate | H.265 Bitrate |
|-----------|-----------|-----|---------------|---------------|
| High | 1920×1080 | 15 | 4 Mbps | 2.5 Mbps |
| Medium | 1280×720 | 15 | 2 Mbps | 1.2 Mbps |
| Low | 640×360 | 10 | 500 Kbps | 300 Kbps |
| Thumbnail | 320×180 | 5 | 150 Kbps | 100 Kbps |

### Fixed Bitrate for Recording
- 1080p@15fps surveillance: 2-4 Mbps CBR (constant bitrate)
- VBR with cap: target 2 Mbps, max 6 Mbps (spikes during motion)

## Keyframe Interval

- **Live streaming:** 1-2 seconds (for fast channel switching)
- **Recording:** 2-4 seconds (balance between seek time and compression)
- **Low bandwidth:** 4-6 seconds (better compression, slower seek)

Rule: keyframe interval = segment duration for HLS (if 6s segments, use 6s keyframes)

## Hardware vs Software Encoding

| Factor | Hardware (GPU/ASIC) | Software (CPU) |
|--------|-------------------|----------------|
| Speed | Real-time, many streams | 1-4 streams per core |
| Quality per bit | Slightly lower | Better (more tuning options) |
| Cost | GPU required | CPU-only |
| Flexibility | Limited codec options | Any codec, any setting |
| Recommendation | Production (many cameras) | Development, single stream |

### Hardware Options
- **NVIDIA NVENC:** excellent H.264/H.265, use with FFmpeg or GStreamer
- **Intel QSV:** good, available on most Intel CPUs
- **AMD VCE/VCN:** decent, less common in servers
- **Raspberry Pi:** hardware H.264 encode via V4L2 (limited to 1080p@30fps)
