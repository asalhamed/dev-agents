# Edge Model Deployment

## ONNX Export

### From PyTorch
```python
import torch

model = load_trained_model()
model.eval()
dummy_input = torch.randn(1, 3, 640, 640)

torch.onnx.export(
    model, dummy_input, "model.onnx",
    input_names=["input"], output_names=["boxes", "scores"],
    dynamic_axes={"input": {0: "batch"}, "boxes": {0: "batch"}, "scores": {0: "batch"}},
    opset_version=17
)
```

### From TensorFlow
```python
import tf2onnx
model = tf.keras.models.load_model("model.h5")
spec = (tf.TensorSpec((None, 640, 640, 3), tf.float32, name="input"),)
model_proto, _ = tf2onnx.convert.from_keras(model, input_signature=spec, output_path="model.onnx")
```

## Post-Training INT8 Quantization

```python
from onnxruntime.quantization import quantize_static, CalibrationDataReader

class CalibReader(CalibrationDataReader):
    def __init__(self, calibration_images):
        self.data = iter(calibration_images)
    def get_next(self):
        try: return {"input": next(self.data)}
        except StopIteration: return None

quantize_static(
    model_input="model_fp32.onnx",
    model_output="model_int8.onnx",
    calibration_data_reader=CalibReader(calib_images),  # 100-500 representative images
    quant_format=QuantFormat.QDQ
)
```

## TFLite Conversion

```python
converter = tf.lite.TFLiteConverter.from_saved_model("saved_model/")
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.representative_dataset = representative_data_gen
converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
converter.inference_input_type = tf.int8
converter.inference_output_type = tf.int8
tflite_model = converter.convert()
```

## Validation After Optimization

```python
# Compare FP32 and INT8 outputs
fp32_session = ort.InferenceSession("model_fp32.onnx")
int8_session = ort.InferenceSession("model_int8.onnx")

for image in validation_set:
    fp32_result = fp32_session.run(None, {"input": image})
    int8_result = int8_session.run(None, {"input": image})
    # Compare mAP, precision, recall
    # Accept if accuracy drop < 2%
```

## Deployment Packaging

```dockerfile
FROM nvcr.io/nvidia/l4t-ml:r35.2.1-py3  # Jetson base image

COPY model_int8.onnx /app/model.onnx
COPY inference.py /app/
COPY requirements.txt /app/

RUN pip install -r /app/requirements.txt
CMD ["python", "/app/inference.py"]
```

## Versioning and Update Strategy

```
/models/
  person-detect/
    v3.1.0/
      model_int8.onnx
      metadata.json    # accuracy, hardware targets, dependencies
      validation.json  # benchmark results on target hardware
    v3.0.0/
      ...
  active → v3.1.0 (symlink)
```

Update flow:
1. Download new model version to edge
2. Run validation suite on device (100 test images)
3. If accuracy ≥ threshold: swap symlink to new version
4. If fails: keep current version, report failure

## Key Rules

- **Always validate after quantization** — never deploy without accuracy check
- **Test on actual target hardware** — emulated benchmarks lie
- **Keep previous version** on device for instant rollback
- **Model + preprocessing must be versioned together** — mismatched preprocessing breaks accuracy
