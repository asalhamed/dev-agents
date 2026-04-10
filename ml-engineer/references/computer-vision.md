# Computer Vision for Surveillance

## Object Detection Models

| Model | Size | Speed (GPU) | Speed (Edge) | mAP@0.5 | Use Case |
|-------|------|-------------|--------------|---------|----------|
| YOLOv8-nano | 3.2M | 1.2ms | 40ms (Jetson) | 37.3 | Edge real-time |
| YOLOv8-small | 11.2M | 2.0ms | 80ms (Jetson) | 44.9 | Edge balanced |
| YOLOv8-medium | 25.9M | 4.0ms | 180ms (Jetson) | 50.2 | Cloud or powerful edge |
| SSD MobileNetV2 | 4.3M | 3.5ms | 50ms (Jetson) | 22.0 | Very constrained edge |
| RT-DETR-l | 32M | 5.0ms | N/A | 53.0 | Cloud, high accuracy |

## Detection vs Classification vs Segmentation

- **Classification:** "Is there a person?" → yes/no + confidence
- **Detection:** "Where are the people?" → bounding boxes + confidence
- **Segmentation:** "What pixels are people?" → pixel-level mask
- **For surveillance:** Detection is the sweet spot (location + count, reasonable cost)

## Model Selection for Monitoring

| Task | Recommended Model | Notes |
|------|-------------------|-------|
| Person detection | YOLOv8-nano/small | Most common, well-supported |
| Vehicle detection | YOLOv8-small | Needs more capacity than person |
| Intrusion (zone) | YOLOv8-nano + zone logic | Detection + geofence check |
| PPE detection | YOLOv8-small (custom trained) | Hard hat, vest, gloves |
| Fire/smoke | YOLOv8-small (custom trained) | Small dataset, needs augmentation |

## Transfer Learning

```python
from ultralytics import YOLO

# Load pretrained model
model = YOLO("yolov8n.pt")

# Fine-tune on custom dataset
results = model.train(
    data="custom_dataset.yaml",
    epochs=100,
    imgsz=640,
    batch=16,
    lr0=0.001,  # lower than from-scratch
    freeze=10,  # freeze first 10 layers
)
```

Dataset requirements:
- Minimum: 100 images per class (500+ recommended)
- Balanced: similar count per class
- Representative: various angles, lighting, weather
- Annotated: YOLO format (class x_center y_center width height)

## Evaluation Metrics

- **mAP@0.5:** mean Average Precision at 50% IoU — primary metric
- **mAP@0.5:0.95:** stricter, averages over IoU thresholds 0.5-0.95
- **Precision:** of all detections, how many are correct
- **Recall:** of all actual objects, how many did we detect
- **F1:** harmonic mean of precision and recall

For surveillance, **recall matters more than precision** — missing a person is worse than a false alarm.
But track false positive rate — too many false alarms cause alert fatigue.
