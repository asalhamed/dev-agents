# Kotlin + Android Patterns

## Coroutines

Use structured concurrency. Never use `GlobalScope`.

```kotlin
// ViewModel — survives configuration changes
class DeviceViewModel @Inject constructor(
    private val repo: DeviceRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<UiState>(UiState.Loading)
    val uiState: StateFlow<UiState> = _uiState.asStateFlow()

    init {
        viewModelScope.launch {
            repo.getDevices()
                .catch { _uiState.value = UiState.Error(it.message) }
                .collect { _uiState.value = UiState.Success(it) }
        }
    }
}

// Fragment/Activity — lifecycle-aware
lifecycleScope.launch {
    repeatOnLifecycle(Lifecycle.State.STARTED) {
        viewModel.uiState.collect { state -> renderState(state) }
    }
}
```

## Sealed Classes for UI State

```kotlin
sealed interface UiState {
    data object Loading : UiState
    data class Success(val devices: List<Device>) : UiState
    data class Error(val message: String?) : UiState
}
```

## StateFlow vs SharedFlow

- **StateFlow**: always has a value, replays last value to new collectors. Use for UI state.
- **SharedFlow**: no initial value, configurable replay. Use for one-shot events (navigation, snackbar).

```kotlin
// One-shot events
private val _events = MutableSharedFlow<UiEvent>()
val events: SharedFlow<UiEvent> = _events.asSharedFlow()
```

## Jetpack Compose State Hoisting

```kotlin
// Stateless composable — receives state, emits events
@Composable
fun DeviceCard(
    device: Device,
    onTap: (DeviceId) -> Unit,
    modifier: Modifier = Modifier
) {
    Card(modifier = modifier.clickable { onTap(device.id) }) {
        Text(device.name)
        Text("${device.temperature}°C")
    }
}

// Stateful wrapper at screen level
@Composable
fun DeviceListScreen(viewModel: DeviceViewModel = hiltViewModel()) {
    val state by viewModel.uiState.collectAsStateWithLifecycle()
    when (val s = state) {
        is UiState.Loading -> CircularProgressIndicator()
        is UiState.Success -> LazyColumn { items(s.devices) { DeviceCard(it, viewModel::onDeviceTap) } }
        is UiState.Error -> ErrorMessage(s.message)
    }
}
```

## Hilt Dependency Injection

```kotlin
@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {
    @Provides @Singleton
    fun provideRetrofit(): Retrofit = Retrofit.Builder()
        .baseUrl(BuildConfig.API_URL)
        .addConverterFactory(MoshiConverterFactory.create())
        .build()

    @Provides @Singleton
    fun provideDeviceApi(retrofit: Retrofit): DeviceApi =
        retrofit.create(DeviceApi::class.java)
}

@HiltViewModel
class DeviceViewModel @Inject constructor(
    private val repo: DeviceRepository
) : ViewModel()
```
