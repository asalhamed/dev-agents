# Vibration Anomaly Detection for Industrial Equipment

**Tags:** ml, anomaly-detection, time-series, vibration, predictive-maintenance

## Input

Design an anomaly detection system for vibration sensor data from industrial equipment. Detect bearing failures 24-48h before they occur with false positive rate <5%.

## Expected Behavior

Agent selects appropriate time-series model, defines FFT-based feature engineering, addresses false positive budget, uses temporal train/validation split, and includes drift detection plan.

## Pass Criteria

- [ ] Appropriate time-series model (isolation forest, LSTM autoencoder, or Prophet)
- [ ] False positive rate <5% explicitly addressed
- [ ] FFT features for vibration data
- [ ] Temporal train/validation split (not random)
- [ ] Drift detection plan defined
- [ ] Produces model-spec contract

## Fail Criteria

- Random train/test split (data leakage)
- No false positive rate consideration
- Generic features (no FFT)
- No drift monitoring
