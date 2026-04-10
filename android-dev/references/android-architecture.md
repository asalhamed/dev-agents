# Android Architecture — MVVM + Clean Architecture

## Layer Separation

```
UI Layer (Compose/Fragment)
  ↓ observes StateFlow
ViewModel Layer
  ↓ calls
UseCase Layer (optional, for complex logic)
  ↓ calls
Repository Layer (single source of truth)
  ↓ coordinates
DataSource Layer (Room, Retrofit, MQTT)
```

## Offline-First with Room + Remote Sync

```kotlin
// Repository — Room is source of truth, network refreshes it
class DeviceRepository @Inject constructor(
    private val local: DeviceDao,
    private val remote: DeviceApi
) {
    fun getDevices(): Flow<List<Device>> = local.observeAll()

    suspend fun refresh(): Result<Unit> = runCatching {
        val devices = remote.fetchDevices()
        local.upsertAll(devices.map { it.toEntity() })
    }
}

// Room DAO
@Dao
interface DeviceDao {
    @Query("SELECT * FROM devices ORDER BY name")
    fun observeAll(): Flow<List<DeviceEntity>>

    @Upsert
    suspend fun upsertAll(devices: List<DeviceEntity>)
}
```

## WorkManager for Background Sync

```kotlin
class SyncWorker @AssistedInject constructor(
    @Assisted context: Context,
    @Assisted params: WorkerParameters,
    private val repo: DeviceRepository
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        return when (repo.refresh()) {
            is kotlin.Result.Success -> Result.success()
            is kotlin.Result.Failure -> if (runAttemptCount < 3) Result.retry() else Result.failure()
        }
    }
}

// Schedule periodic sync
val syncRequest = PeriodicWorkRequestBuilder<SyncWorker>(15, TimeUnit.MINUTES)
    .setConstraints(Constraints.Builder().setRequiredNetworkType(NetworkType.CONNECTED).build())
    .setBackoffCriteria(BackoffPolicy.EXPONENTIAL, 30, TimeUnit.SECONDS)
    .build()
WorkManager.getInstance(context).enqueueUniquePeriodicWork("sync", KEEP, syncRequest)
```

## Error Handling Across Layers

```kotlin
// Domain result type
sealed interface DomainResult<out T> {
    data class Ok<T>(val data: T) : DomainResult<T>
    data class Err(val error: DomainError) : DomainResult<Nothing>
}

sealed interface DomainError {
    data object NetworkUnavailable : DomainError
    data object Unauthorized : DomainError
    data class ServerError(val code: Int, val message: String) : DomainError
    data class Unknown(val throwable: Throwable) : DomainError
}

// Repository maps exceptions to domain errors
suspend fun refresh(): DomainResult<Unit> = try {
    val devices = remote.fetchDevices()
    local.upsertAll(devices)
    DomainResult.Ok(Unit)
} catch (e: UnknownHostException) { DomainResult.Err(DomainError.NetworkUnavailable) }
  catch (e: HttpException) { DomainResult.Err(DomainError.ServerError(e.code(), e.message())) }
  catch (e: Exception) { DomainResult.Err(DomainError.Unknown(e)) }
```

## Key Rules

- **ViewModel never imports Android framework** (except `SavedStateHandle`)
- **Repository is the single source of truth** — UI reads from Room, not network
- **Room flows are reactive** — insert/update automatically triggers UI refresh
- **WorkManager, not AlarmManager** — for deferrable background work
- **No business logic in Compose** — Composables are pure rendering functions
