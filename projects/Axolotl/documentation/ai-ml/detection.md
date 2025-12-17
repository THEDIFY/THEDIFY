# Soccer Object Detection Module

## Overview

The detection module implements high-quality soccer-specific object detection using YOLOv8 for the Axolotl Football Analysis Platform. It detects players, referees, and the ball in single-camera match analysis videos.

## Quick Start

### 1. Run Sample Inference (Testing)

```bash
# Create and test with sample video
python models/detection/infer_sample.py --create-sample
python models/detection/infer_sample.py --video sample_soccer.mp4
```

### 2. Process Your Own Video

```bash
# Basic inference
python models/detection/infer_yolo.py --video your_match.mp4

# With custom model
python models/detection/infer_yolo.py --video your_match.mp4 --model models/detection/runs/best.pt

# Fast processing (10 FPS limit)
python models/detection/infer_yolo.py --video your_match.mp4 --fps-limit 10

# Small ball detection with tiling
python models/detection/infer_yolo.py --video your_match.mp4 --tiling
```

## Architecture

### Classes Detected

- **Class 0: player** - Soccer players on the field
- **Class 1: ball** - Soccer ball
- **Class 2: referee** - Referees and officials

### Model Specifications

- **Base Model**: YOLOv8n with COCO pretrained weights
- **Input Resolution**: 1280px (broadcast quality) / 640px (standard)
- **Target Performance**: 
  - Player mAP@0.5 ≥ 0.85
  - Ball mAP@0.5 ≥ 0.5

### Output Format

Detections are saved as JSONL files in `tracking/frames/{video_id}/detections.jsonl`:

```json
{
  "video_id": "match_abc123",
  "frame": 42,
  "timestamp": 1.4,
  "detections": [
    {
      "class_id": 0,
      "class_name": "player",
      "confidence": 0.85,
      "bbox": {
        "x1": 100.0, "y1": 200.0,
        "x2": 150.0, "y2": 300.0,
        "center_x": 125.0, "center_y": 250.0,
        "width": 50.0, "height": 100.0
      },
      "area": 5000.0
    }
  ],
  "metadata": {
    "frame_width": 1920,
    "frame_height": 1080,
    "model_info": {...}
  }
}
```

## Training

### 1. Create Training Data

```bash
# Create dummy dataset for testing
python models/detection/train_yolo.py --create-dummy-data

# Or prepare your own dataset in YOLO format:
models/detection/data/soccer/
├── train/
│   ├── images/
│   └── labels/
├── val/
│   ├── images/
│   └── labels/
└── test/
    ├── images/
    └── labels/
```

### 2. Configure Training

Edit `configs/yolo_soccer.yaml`:

```yaml
# Dataset paths
path: ./models/detection/data/soccer
train: train
val: val
test: test

# Soccer classes
names:
  0: player
  1: ball
  2: referee

# Training settings
epochs: 100
batch: 8
imgsz: 1280
lr0: 0.001
```

### 3. Start Training

```bash
# Full training
python models/detection/train_yolo.py --config configs/yolo_soccer.yaml

# Quick test training
python models/detection/train_yolo.py --config configs/yolo_soccer.yaml --epochs 5 --batch 4
```

## Advanced Features

### Small Ball Detection

For better ball detection in high-resolution videos:

```bash
# Use tiled inference
python models/detection/infer_yolo.py --video match.mp4 --tiling
```

**How it works:**
- Splits high-res frames into overlapping tiles
- Runs inference on each tile
- Merges results with NMS to remove duplicates
- Better for detecting small balls in broadcast footage

### Data Augmentation

The training pipeline includes soccer-specific augmentations:

- **Photometric**: HSV variations for different lighting
- **Geometric**: Scale (0.5-1.5x) for various camera distances  
- **Mosaic**: Combines 4 images for small object detection
- **Flip**: Horizontal flipping (soccer field symmetry)

### Multi-scale Training

Trains on both 640px and 1280px resolutions:
- 640px: Fast inference, mobile-friendly
- 1280px: High accuracy, broadcast quality

## Performance Optimization

### Speed vs Accuracy Trade-offs

1. **Fast (Real-time)**: YOLOv8n @ 640px, conf=0.4
2. **Balanced**: YOLOv8s @ 1280px, conf=0.25  
3. **Accurate**: YOLOv8m @ 1280px + tiling, conf=0.15

### Hardware Requirements

- **Minimum**: CPU-only, 8GB RAM
- **Recommended**: GPU with 4GB+ VRAM
- **Optimal**: RTX 3060+ or better

## Integration with Tracking

The detection output feeds into the tracking module:

```
Detection → Tracking → Analysis
     ↓         ↓         ↓
  JSONL    Player IDs  Insights
```

## Testing

```bash
# Run unit tests
python -m pytest tests/test_detection.py -v

# Test sample inference (integration test)
python models/detection/infer_sample.py --video sample.mp4

# Validate specific output
python models/detection/infer_sample.py --validate-only path/to/detections.jsonl
```

## Troubleshooting

### Common Issues

1. **Low ball detection rate**
   - Solution: Use `--tiling` flag
   - Increase training data with more ball examples
   - Lower confidence threshold: `--conf 0.15`

2. **Slow inference**
   - Solution: Use `--fps-limit 10` for faster processing
   - Switch to YOLOv8n instead of YOLOv8s/m
   - Reduce input resolution in config

3. **High false positives**
   - Solution: Increase confidence: `--conf 0.4`
   - Add more negative training examples
   - Improve dataset quality

### Debugging

```bash
# Enable verbose output
export YOLO_VERBOSE=True

# Check model info
python -c "from ultralytics import YOLO; m=YOLO('models/detection/runs/best.pt'); print(m.info())"

# Validate dataset
python models/detection/train_yolo.py --config configs/yolo_soccer.yaml --epochs 1 --batch 1
```

## References

- [Ultralytics YOLOv8 Documentation](https://docs.ultralytics.com/)
- [SoccerNet Dataset](https://www.soccer-net.org/)
- [Roboflow Soccer Ball Datasets](https://universe.roboflow.com/search?q=soccer%20ball)

## Next Steps

After detection:
1. **Phase 2.2**: Multi-object tracking (DeepSORT/ByteTrack)
2. **Phase 2.3**: Player identification and jersey recognition  
3. **Phase 3**: Tactical analysis and performance metrics