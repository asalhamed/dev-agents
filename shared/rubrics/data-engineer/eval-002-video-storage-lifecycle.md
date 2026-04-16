# Video Storage Lifecycle Management

**Tags:** data, video, s3, lifecycle, storage

## Input

Design video storage for 200 cameras recording 24/7. Instant playback for 7 days, archived access for 1 year. Minimize cost.

## Expected Behavior

Agent designs S3 bucket structure, lifecycle policies (hot→warm→cold→archive), HLS segment management, presigned URLs for playback, and cost estimates.

## Pass Criteria

- [ ] S3 bucket organized by site/camera/date
- [ ] Lifecycle: hot(7d) → warm(30d) → cold(90d) → archive(365d)
- [ ] HLS segment management
- [ ] Presigned URLs for secure playback
- [ ] Cost per camera estimated
- [ ] Produces implementation-summary

## Fail Criteria

- Flat bucket structure
- No lifecycle policies (all in hot storage)
- Public bucket access
- No cost analysis
