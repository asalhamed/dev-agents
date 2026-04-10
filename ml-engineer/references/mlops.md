# MLOps for IoT/Video ML

## MLflow for Experiment Tracking

```python
import mlflow

mlflow.set_experiment("person-detection-v3")

with mlflow.start_run():
    mlflow.log_params({"model": "yolov8n", "epochs": 100, "imgsz": 640})
    # ... training ...
    mlflow.log_metrics({"mAP50": 0.82, "precision": 0.88, "recall": 0.79})
    mlflow.log_artifact("best.onnx")
    mlflow.pytorch.log_model(model, "model")
```

## Model Registry

```python
# Register model
mlflow.register_model("runs:/abc123/model", "person-detector")

# Promote to production
client = mlflow.tracking.MlflowClient()
client.transition_model_version_stage("person-detector", version=3, stage="Production")
```

Stages: None → Staging → Production → Archived

## Deployment Options

| Tool | Best For | Complexity |
|------|----------|------------|
| FastAPI + ONNX | Simple REST API, single model | Low |
| BentoML | Multiple models, packaging | Medium |
| TorchServe | PyTorch models, batching | Medium |
| Triton | Multi-framework, GPU optimization | High |

### FastAPI (Recommended for IoT)
```python
from fastapi import FastAPI
import onnxruntime as ort

app = FastAPI()
session = ort.InferenceSession("model.onnx")

@app.post("/predict")
async def predict(image: UploadFile):
    frame = preprocess(await image.read())
    result = session.run(None, {"input": frame})
    return {"detections": postprocess(result)}
```

## A/B Deployment

### Shadow Mode
- New model runs alongside production, results logged but not served
- Compare accuracy/latency/resource usage before switching
- Zero risk to users

### Canary
- Route 5% of traffic to new model
- Monitor metrics (accuracy, latency, error rate)
- Gradually increase: 5% → 25% → 50% → 100%
- Auto-rollback if error rate increases

## Drift Detection

### Data Drift
Input distribution changes (e.g., new camera angle, different lighting).
- Monitor: feature distribution (KL divergence, KS test)
- Tool: Evidently AI

### Concept Drift
Relationship between input and output changes (e.g., new uniform that looks different).
- Monitor: model accuracy on labeled samples
- Requires periodic labeling of production data

```python
from evidently.metrics import DataDriftPreset
from evidently.report import Report

report = Report(metrics=[DataDriftPreset()])
report.run(reference_data=training_data, current_data=production_data)
# Alert if drift detected in >30% of features
```

## Key Rules

- **Version everything:** model, training data, preprocessing code, config
- **Reproducibility:** any experiment can be re-run from logged parameters
- **Monitoring is not optional:** drift detection from day one
- **Rollback plan:** every deployment has a one-click rollback to previous version
