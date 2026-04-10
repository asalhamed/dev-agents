# Camera Integration — CameraX + ExoPlayer

## CameraX for Device Camera

```kotlin
// Preview + capture in Compose
@Composable
fun CameraPreview(modifier: Modifier = Modifier) {
    val lifecycleOwner = LocalLifecycleOwner.current
    AndroidView(
        factory = { ctx ->
            PreviewView(ctx).apply {
                val cameraProviderFuture = ProcessCameraProvider.getInstance(ctx)
                cameraProviderFuture.addListener({
                    val cameraProvider = cameraProviderFuture.get()
                    val preview = Preview.Builder().build().also {
                        it.setSurfaceProvider(surfaceProvider)
                    }
                    cameraProvider.bindToLifecycle(
                        lifecycleOwner, CameraSelector.DEFAULT_BACK_CAMERA, preview
                    )
                }, ContextCompat.getMainExecutor(ctx))
            }
        },
        modifier = modifier
    )
}
```

## ExoPlayer for IP Camera Streams (HLS/RTSP)

```kotlin
@Composable
fun LiveFeed(rtspUrl: String, modifier: Modifier = Modifier) {
    val context = LocalContext.current
    val player = remember {
        ExoPlayer.Builder(context).build().apply {
            setMediaItem(MediaItem.fromUri(rtspUrl))
            playWhenReady = true
            prepare()
        }
    }
    DisposableEffect(Unit) { onDispose { player.release() } }
    AndroidView(factory = { PlayerView(it).apply { this.player = player } }, modifier = modifier)
}
```

## RTSP with Reconnection

```kotlin
class StreamManager(private val context: Context) {
    private var player: ExoPlayer? = null
    private var retryCount = 0
    private val maxRetry = 10

    private val playerListener = object : Player.Listener {
        override fun onPlayerError(error: PlaybackException) {
            if (retryCount < maxRetry) {
                val delay = minOf(1000L * (1 shl retryCount), 60_000L) // exponential backoff, max 60s
                retryCount++
                handler.postDelayed({ reconnect() }, delay)
            }
        }
        override fun onIsPlayingChanged(isPlaying: Boolean) {
            if (isPlaying) retryCount = 0 // reset on success
        }
    }

    fun connect(url: String) {
        player = ExoPlayer.Builder(context)
            .setLoadControl(DefaultLoadControl.Builder()
                .setBufferDurationsMs(500, 2000, 500, 500) // low-latency
                .build())
            .build().apply {
                addListener(playerListener)
                setMediaItem(MediaItem.fromUri(url))
                prepare(); playWhenReady = true
            }
    }
}
```

## Camera Permissions

```kotlin
val cameraPermission = rememberLauncherForActivityResult(
    ActivityResultContracts.RequestPermission()
) { granted -> if (granted) showCamera() else showRationale() }

// Check before using
if (ContextCompat.checkSelfPermission(context, Manifest.permission.CAMERA) == GRANTED) {
    showCamera()
} else {
    cameraPermission.launch(Manifest.permission.CAMERA)
}
```

## Background Streaming (Foreground Service)

```kotlin
class StreamingService : Service() {
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Live Stream Active")
            .setSmallIcon(R.drawable.ic_videocam)
            .build()
        startForeground(NOTIFICATION_ID, notification)
        // Initialize ExoPlayer here for background playback
        return START_STICKY
    }
}
```

## Key Rules

- **CameraX** for device camera (not deprecated Camera2 API directly)
- **ExoPlayer** for IP camera streams (RTSP, HLS) — not raw `MediaPlayer`
- **Low-latency buffer** settings for live feeds (500ms buffer, not default 15s)
- **Foreground service required** for background streaming (Android 12+)
- **Handle permissions gracefully** — explain why camera access is needed
