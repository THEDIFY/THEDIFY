# Event Spotting Usage Guide

This guide shows how to use the event spotting functionality in the Axolotl Football Analysis Platform.

## Quick Start

### 1. Training a Model

```bash
# Using configuration file
python models/spotting/train_spotter.py --config configs/spotting_config.yaml

# Using command line arguments  
python models/spotting/train_spotter.py \
    --data_dir data/soccernet \
    --epochs 50 \
    --batch_size 4 \
    --learning_rate 1e-4
```

### 2. Running Inference

```bash
# Basic inference
python inference/spot_events.py \
    --video input_video.mp4 \
    --tracks tracking/video_id/tracks.json \
    --model models/spotting/checkpoints/best_model.pth

# With custom output path and confidence threshold
python inference/spot_events.py \
    --video input_video.mp4 \
    --tracks tracking/video_id/tracks.json \
    --model models/spotting/checkpoints/best_model.pth \
    --output events/custom_output.json \
    --confidence 0.6
```

### 3. Demo and Testing

```bash
# Run component tests
python -m pytest tests/test_event_spotting.py -v

# Run demo (components only)
python demo_event_spotting.py --components-only

# Create sample data for testing
python demo_event_spotting.py --create-sample-data
```

## Pipeline Integration

The event spotting module integrates with the existing detection and tracking pipeline:

```
Video Input → YOLO Detection → ByteTracker → Event Spotting → Events Output
     ↓              ↓               ↓             ↓            ↓
   frames    detections.jsonl   tracks.json   predictions   events.json
```

## Output Format

The event spotting produces JSON files with the following structure:

```json
{
    "video_id": "match_123",
    "video_path": "/path/to/video.mp4",
    "tracks_path": "/path/to/tracks.json",
    "model_path": "/path/to/model.pth",
    "events": [
        {
            "timestamp": 45.2,
            "class": "pass",
            "confidence": 0.83,
            "involved_player_ids": [1, 3, 7]
        },
        {
            "timestamp": 127.8,
            "class": "shot",
            "confidence": 0.91,
            "involved_player_ids": [5]
        }
    ],
    "metadata": {
        "num_events": 2,
        "confidence_threshold": 0.5,
        "model_config": {...},
        "event_classes": {
            "0": "background",
            "1": "pass", 
            "2": "shot",
            "3": "goal",
            "4": "foul",
            "5": "cross"
        }
    }
}
```

## Event Classes

The model detects 5 main football events:

1. **Pass** - Ball transfer between players
2. **Shot** - Attempt to score a goal
3. **Goal** - Successful scoring
4. **Foul** - Rule violation/contact
5. **Cross** - Ball played into penalty area

## Model Architecture

- **Input**: Visual features (ResNet) + Tracking features (ball-player distances, velocities, zones)
- **Model**: Transformer encoder with positional encoding
- **Output**: Per-frame event probabilities + confidence scores
- **Training**: Focal loss + temporal consistency + confidence regularization
- **Inference**: Sliding windows + non-maximum suppression

## Configuration

Key configuration parameters in `configs/spotting_config.yaml`:

```yaml
# Model settings
d_model: 256              # Transformer dimension
nhead: 8                  # Attention heads
num_layers: 6             # Transformer layers
window_size: 1800         # 60s at 30fps
stride: 300               # 10s stride

# Training settings
epochs: 50
batch_size: 4
learning_rate: 1e-4
focal_gamma: 2.0          # Focal loss parameter
temporal_weight: 0.1      # Temporal consistency weight

# Inference settings
confidence_threshold: 0.5
nms_window: 30            # 1s NMS window
```

## Performance Targets

Based on SoccerNet Action Spotting benchmark:

- **mAP@1s**: Target similar to Ball Action Spotting baseline performance
- **mAP@5s**: Higher tolerance for temporal localization
- **Real-time**: Process 60s windows efficiently for live analysis
- **Classes**: Support all 5 major football event types

## Data Requirements

### SoccerNet Format
- Video files in MP4 format
- Labels in `Labels-v2.json` format with timestamps
- Pre-extracted features or raw video for feature extraction

### Axolotl Format
- Detection results from YOLO: `detections.jsonl`
- Tracking results from ByteTracker: `tracks.json`
- Video metadata and frame information

## Troubleshooting

### Common Issues

1. **CUDA out of memory**: Reduce batch_size or window_size
2. **Low mAP scores**: Adjust focal_gamma, increase training epochs
3. **Missing events**: Lower confidence_threshold, check tracking quality
4. **Too many false positives**: Increase confidence_threshold, improve NMS

### Performance Optimization

- Use GPU for training and inference
- Enable mixed precision training (FP16)
- Pre-extract and cache visual features
- Use smaller backbone for faster feature extraction

## Example Workflow

```bash
# 1. Extract detections from video
python models/detection/infer_yolo.py --video match.mp4

# 2. Generate tracks from detections  
python tracking/bytetracker_interface.py --detections detections.jsonl

# 3. Spot events from video + tracks
python inference/spot_events.py \
    --video match.mp4 \
    --tracks tracks.json \
    --model trained_model.pth \
    --output events/match.json

# 4. Visualize results (future feature)
python visualization/plot_events.py --events events/match.json
```

This completes the event spotting implementation for Phase 2.4 of the Axolotl Football Analysis Platform.