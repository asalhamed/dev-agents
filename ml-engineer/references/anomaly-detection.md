# Anomaly Detection for IoT Monitoring

## Statistical Methods

### Z-Score
```python
z = (value - mean) / std
anomaly = abs(z) > 3  # 3 standard deviations
```
- Simple, fast, no training
- Fails for non-Gaussian distributions
- Fails for seasonal data

### IQR (Interquartile Range)
```python
Q1, Q3 = np.percentile(data, [25, 75])
IQR = Q3 - Q1
anomaly = (value < Q1 - 1.5*IQR) or (value > Q3 + 1.5*IQR)
```
- Robust to outliers
- Good for non-Gaussian data
- Static thresholds (no learning)

## ML-Based Methods

### Isolation Forest
```python
from sklearn.ensemble import IsolationForest
model = IsolationForest(contamination=0.05, random_state=42)
model.fit(training_data)
predictions = model.predict(new_data)  # -1 = anomaly, 1 = normal
```
- Good general-purpose anomaly detector
- No assumptions about distribution
- `contamination` param = expected anomaly rate

### Autoencoder
```python
# Train on NORMAL data only
model = Sequential([
    Dense(64, activation='relu', input_shape=(n_features,)),
    Dense(16, activation='relu'),   # bottleneck
    Dense(64, activation='relu'),
    Dense(n_features, activation='linear')
])
model.compile(optimizer='adam', loss='mse')
model.fit(normal_data, normal_data, epochs=50)

# Anomaly = high reconstruction error
reconstruction = model.predict(new_data)
error = np.mean((new_data - reconstruction)**2, axis=1)
anomaly = error > threshold  # threshold from validation set
```
- Learns normal patterns, flags deviations
- Good for complex, multivariate data
- Requires sufficient normal training data

### Prophet (Facebook)
```python
from prophet import Prophet
model = Prophet(interval_width=0.99)
model.fit(df)  # df with 'ds' (timestamp) and 'y' (value) columns
forecast = model.predict(future)
anomaly = (actual < forecast.yhat_lower) | (actual > forecast.yhat_upper)
```
- Handles seasonality natively (daily, weekly, yearly)
- Good for: temperature, energy, traffic patterns
- Less good for: high-frequency data (>1Hz)

## Choosing Threshold vs Model-Based

| Approach | When to Use |
|----------|-------------|
| Fixed threshold | Simple sensors, known operating range (e.g., temperature 15-35°C) |
| Statistical (z-score) | Stable processes, Gaussian distribution |
| Isolation Forest | Multiple features, no clear distribution, general purpose |
| Autoencoder | Complex patterns, high-dimensional data |
| Prophet | Strong seasonality, time-series with trend |

## Handling Seasonal Patterns

1. **Decompose:** separate trend, seasonality, residual
2. **Detect on residual:** anomalies in the deseasonalized signal
3. **Time-aware thresholds:** different thresholds for day/night, weekday/weekend
4. **Rolling baseline:** 7-day or 30-day rolling statistics

## Evaluation: False Positive/Negative Tradeoff

For monitoring alerts:
- **False positive (false alarm):** alert when nothing is wrong → alert fatigue
- **False negative (missed):** no alert when something is wrong → equipment damage

| Metric | Target (typical) |
|--------|-----------------|
| False positive rate | < 5% (1 in 20 alerts is false) |
| Detection rate (recall) | > 90% (catch 9 out of 10 real anomalies) |
| Detection lead time | > 24h before failure (for maintenance planning) |

Tune threshold to business cost: cost of false alarm vs cost of missed failure.
