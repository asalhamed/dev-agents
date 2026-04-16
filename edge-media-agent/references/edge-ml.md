# Edge ML Inference

## ONNX Runtime for Edge

```python
import onnxruntime as ort
import numpy as np

# Load model with TensorRT optimization (NVIDIA)
session = ort.InferenceSession(
    "person_detect_int8.onnx",
    providers=["TensorrtExecutionProvider", "CUDAExecutionProvider", "CPUExecutionProvider"]
)

# Run inference
input_name = session.get_inputs()[0].name
result = session.run(None, {input_name: preprocessed_frame})
boxes, scores = result[0], result[1]
```

Provider priority: TensorRT > CUDA > CPU. Falls back automatically.

## TensorFlow Lite

```python
import tflite_runtime.interpreter as tflite

interpreter = tflite.Interpreter(model_path="model.tflite")
interpreter.allocate_tensors()
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

interpreter.set_tensor(input_details[0]["index"], input_data)
interpreter.invoke()
output = interpreter.get_tensor(output_details[0]["index"])
```

## Model Optimization

### Quantization (INT8)
- **Post-training quantization:** no retraining, ~2% accuracy loss, 4x smaller, 2-3x faster
- **Quantization-aware training:** retrain with quantization, <1% accuracy loss
- Always validate accuracy after quantization on representative dataset

### Pruning
- Remove low-magnitude weights (30-50% sparsity typical)
- Retrain after pruning to recover accuracy
- Best combined with quantization

### Knowledge Distillation
- Train small "student" model to mimic large "teacher" model
- Student is 5-10x smaller with similar accuracy
- Good for: deploying cloud-grade accuracy on edge hardware

## Benchmarking

```bash
# ONNX Runtime benchmark
python -c "
import onnxruntime as ort, numpy as np, time
sess = ort.InferenceSession('model.onnx')
inp = np.random.randn(1,3,640,640).astype(np.float32)
# Warmup
for _ in range(10): sess.run(None, {'input': inp})
# Benchmark
times = []
for _ in range(100):
    t = time.monotonic()
    sess.run(None, {'input': inp})
    times.append(time.monotonic() - t)
print(f'Mean: {np.mean(times)*1000:.1f}ms, P95: {np.percentile(times,95)*1000:.1f}ms')
"
```

## When Edge Inference Is Worth It

✅ **Use edge inference when:**
- Latency requirement <100ms (can't afford round-trip to cloud)
- Bandwidth is constrained (can't stream full video to cloud)
- Privacy requires local processing (video stays on-premises)
- Volume: processing every frame locally is cheaper than streaming to cloud

❌ **Use cloud inference when:**
- Model is too large for edge hardware
- Need to correlate across multiple sites
- Edge hardware cost exceeds cloud inference cost
- Model changes frequently (easier to update cloud)
