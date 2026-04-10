# Video Storage (Object Storage)

## Bucket Structure

```
s3://video-recordings/
  └── {site_id}/
      └── {camera_id}/
          └── {date}/
              ├── segments/
              │   ├── 2025-01-15T10-00-00_000.ts
              │   ├── 2025-01-15T10-00-06_001.ts
              │   └── ...
              ├── playlists/
              │   └── 2025-01-15T10-00-00.m3u8
              └── thumbnails/
                  ├── 2025-01-15T10-00-00.jpg
                  └── ...
```

Key: `{site_id}/{camera_id}/{date}/segments/{timestamp}_{seq}.ts`

## Lifecycle Policies

```json
{
  "Rules": [
    {
      "ID": "hot-to-warm",
      "Filter": {"Prefix": ""},
      "Transitions": [
        {"Days": 7, "StorageClass": "STANDARD_IA"},
        {"Days": 30, "StorageClass": "GLACIER_IR"},
        {"Days": 90, "StorageClass": "GLACIER"}
      ],
      "Expiration": {"Days": 365}
    }
  ]
}
```

| Tier | Duration | Storage Class | Access | Cost |
|------|----------|---------------|--------|------|
| Hot | 0-7 days | Standard | Instant | $$$ |
| Warm | 7-30 days | IA / Infrequent | Instant, higher retrieval | $$ |
| Cold | 30-90 days | Glacier IR | Minutes | $ |
| Archive | 90-365 days | Glacier | Hours | ¢ |
| Delete | >365 days | — | — | Free |

## HLS Segment Management

- Segment duration: 6 seconds (standard) or 2 seconds (LL-HLS)
- Playlist: rolling window (last 10 segments for live) + full VOD playlist
- Clean up: delete segments when lifecycle policy expires, or compact into MP4

## Presigned URLs for Playback

```python
import boto3

s3 = boto3.client("s3")
url = s3.generate_presigned_url(
    "get_object",
    Params={"Bucket": "video-recordings", "Key": playlist_key},
    ExpiresIn=3600  # 1 hour
)
# Return presigned URL to frontend for HLS.js playback
```

Never expose S3 bucket publicly. Always use presigned URLs with short expiry.

## Cost Optimization

- **Don't store what you don't need:** motion-only recording saves 60-80% storage
- **Downsample for archive:** keep 1080p for 7 days, then transcode to 720p or 480p
- **Use S3-compatible (MinIO)** for on-premises: same API, customer-controlled storage
- **Calculate cost per camera:**
  - 1080p@15fps, H.264, 4Mbps = ~1.8 GB/hour = ~43 GB/day
  - S3 Standard: $0.023/GB = ~$1/day/camera
  - After 7 days → IA: ~$0.35/day/camera
  - With motion-only (30% activity): ~$0.30/day/camera (hot)
