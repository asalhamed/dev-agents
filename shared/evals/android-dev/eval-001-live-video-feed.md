# Live Video Feed — RTSP Playback in Compose

**Tags:** android, video, exoplayer, compose, rtsp

## Input

Implement a live video feed screen in Kotlin/Jetpack Compose that connects to an RTSP stream from an IP camera. Show connection status, handle reconnection automatically, and support background playback.

## Expected Behavior

Agent produces a Compose screen with ExoPlayer for RTSP playback, a ForegroundService for background streaming, exponential backoff reconnection, and UI state management via StateFlow. No business logic in Composables.

## Pass Criteria

- [ ] ExoPlayer used for RTSP playback (not raw MediaPlayer)
- [ ] ForegroundService for background playback
- [ ] Automatic reconnection with exponential backoff
- [ ] Connection state shown in UI (connecting/playing/error)
- [ ] No business logic in Composable functions
- [ ] Produces implementation-summary contract

## Fail Criteria

- Uses deprecated MediaPlayer API for RTSP
- No background playback support
- Hardcoded RTSP URLs
- Business logic mixed into Composables
- No reconnection logic
