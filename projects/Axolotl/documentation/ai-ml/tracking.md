# Soccer Multi-Object Tracking Module

The tracking module implements persistent object tracking for soccer players, balls, and referees across video frames using a ByteTrack-inspired algorithm.

## Features

- **Persistent Track IDs**: Assigns and maintains unique IDs for objects across frames
- **Multi-Class Support**: Handles players, balls, and referees simultaneously  
- **Robust Association**: Uses IoU-based matching with Hungarian algorithm
- **Recovery Strategy**: Two-stage confidence thresholds for track recovery
- **Soccer-Optimized**: Tuned parameters for football scenarios

## Architecture

```
Detection → ByteTracker → Persistent Tracks → Evaluation/Visualization
    ↓           ↓              ↓                    ↓
  JSONL    Track IDs      Time Series         Metrics/Video
```

## Quick Start

### Basic Tracking

```bash
# Run tracking on detection results
python tracking/bytetracker_interface.py --detections tracking/frames/{video_id}/detections.jsonl

# With custom parameters
python tracking/bytetracker_interface.py \
  --detections tracking/frames/{video_id}/detections.jsonl \
  --high-conf 0.6 --low-conf 0.1 --min-hits 3 --max-age 30
```

### Evaluation

```bash
# Evaluate tracking performance
python tracking/eval_tracks.py tracking/{video_id}/tracks.json

# Save evaluation report
python tracking/eval_tracks.py tracking/{video_id}/tracks.json --output reports/tracking_eval.txt
```

### Visualization

```bash
# Create tracking overlay video
python tracking/visualize_tracks.py tracking/{video_id}/tracks.json --video input.mp4

# Custom output location
python tracking/visualize_tracks.py tracking/{video_id}/tracks.json \
  --video input.mp4 --output tracked_video.mp4 --fps 30
```

## Parameter Tuning

### Confidence Thresholds

- **high_conf_thresh (0.3-0.7)**: Primary detection confidence
- **low_conf_thresh (0.1-0.3)**: Recovery detection confidence

### Tracking Parameters

- **max_age (10-50)**: Frames to keep track without detection
- **min_hits (1-5)**: Minimum detections to confirm track
- **match_thresh (0.5-0.9)**: IoU threshold for association

### Recommended Settings

| Scenario | high_conf | low_conf | max_age | min_hits |
|----------|-----------|----------|---------|----------|
| Broadcast Quality | 0.6 | 0.3 | 30 | 3 |
| Personal Video | 0.4 | 0.15 | 20 | 2 |
| Real-time | 0.5 | 0.2 | 15 | 1 |

## Output Format

### Tracks JSON Structure

```json
{
  "video_id": "match_abc123",
  "tracking_params": {
    "high_conf_thresh": 0.6,
    "low_conf_thresh": 0.1,
    "max_age": 30,
    "min_hits": 3
  },
  "tracks": [
    {
      "frame": 42,
      "timestamp": 1.4,
      "tracks": [
        {
          "track_id": 5,
          "bbox": {
            "x1": 100.0, "y1": 200.0,
            "x2": 150.0, "y2": 300.0,
            "center_x": 125.0, "center_y": 250.0,
            "width": 50.0, "height": 100.0
          },
          "confidence": 0.85,
          "class_id": 0,
          "class_name": "player",
          "hits": 15,
          "age": 18
        }
      ]
    }
  ]
}
```

## Evaluation Metrics

### Proxy Metrics (without ground truth)

- **Proxy IDF1**: Identity preservation based on track consistency
- **Proxy MOTA**: Tracking accuracy based on detection success
- **Track Consistency**: Average track length relative to video duration
- **Confidence Distribution**: Quality indicator for detections

### Performance Targets

- **IDF1 ≥ 0.7**: Broadcast quality
- **IDF1 > 0.6**: Personal video quality
- **MOTA > 0.5**: General tracking quality

## Implementation Details

### ByteTracker Algorithm

1. **Prediction**: Kalman filter motion prediction for existing tracks
2. **High-Confidence Association**: Match high-confidence detections to tracks
3. **Low-Confidence Recovery**: Recover tracks with low-confidence detections
4. **Track Management**: Create new tracks, remove dead tracks

### Kalman Filter State

- **State Vector**: [x, y, s, r, dx, dy, ds, dr]
  - x, y: center coordinates
  - s: scale (area)
  - r: aspect ratio
  - dx, dy, ds, dr: velocities

### Association Strategy

1. Compute IoU matrix between detections and track predictions
2. Hungarian algorithm for optimal assignment
3. Filter matches by IoU threshold
4. Create new tracks for unmatched detections

## Soccer-Specific Optimizations

### Multi-Class Handling

- Different tracking parameters per class
- Ball tracking with smaller object handling
- Player occlusion management

### Field Context

- Boundary-aware tracking (when field detection available)
- Offside considerations
- Team assignment (future feature)

### Performance Considerations

- Real-time processing capability
- Memory-efficient track storage
- Scalable to multiple cameras

## Testing

```bash
# Run tracking tests
python -m pytest tests/test_tracking.py -v

# Test specific components
python -m pytest tests/test_tracking.py::TestByteTracker -v

# Integration test with sample data
python tracking/bytetracker_interface.py --detections tracking/frames/sample_soccer_*/detections.jsonl
```

## Troubleshooting

### Common Issues

1. **No tracks generated**
   - Lower confidence thresholds
   - Reduce min_hits parameter
   - Check detection input format

2. **Track fragmentation**
   - Increase max_age parameter
   - Lower match_thresh for more lenient association
   - Improve detection consistency

3. **ID switching**
   - Tune IoU thresholds
   - Improve motion prediction
   - Add appearance features (future)

### Debug Tools

```bash
# Verbose tracking output
python tracking/bytetracker_interface.py --detections input.jsonl --verbose

# Visual debugging
python tracking/visualize_tracks.py tracks.json --show-trails --show-info
```

## Performance Benchmarks

| Video Type | Resolution | FPS | Tracks/Frame | Processing Speed |
|------------|------------|-----|-------------|------------------|
| Broadcast | 1920x1080 | 30 | 20-25 | 15 FPS |
| Personal | 1280x720 | 30 | 5-15 | 25 FPS |
| Mobile | 640x480 | 30 | 3-10 | 35 FPS |

## Future Enhancements

- [ ] Appearance-based re-identification
- [ ] Team assignment and formation analysis
- [ ] Multi-camera fusion
- [ ] Deep learning motion prediction
- [ ] Real-time optimization
- [ ] Ball possession tracking

## API Reference

### ByteTracker Class

```python
tracker = ByteTracker(
    high_conf_thresh=0.6,
    low_conf_thresh=0.1,
    match_thresh=0.8,
    max_age=30,
    min_hits=3
)

# Update with detections
tracks = tracker.update(detections)
```

### Process Video Function

```python
from tracking.bytetracker_interface import process_video_tracking

tracks_path = process_video_tracking(
    detections_path="detections.jsonl",
    output_path="tracks.json",
    high_conf_thresh=0.6,
    low_conf_thresh=0.1
)
```

### Evaluation Function

```python
from tracking.eval_tracks import evaluate_tracks_file

metrics = evaluate_tracks_file("tracks.json")
print(f"IDF1: {metrics['proxy_idf1']:.3f}")
```

## Integration

The tracking module integrates with:

- **Detection Module**: Consumes YOLO detection outputs
- **Analysis Module**: Provides tracked objects for performance analysis
- **API Module**: Exposes tracking endpoints for web interface
- **Visualization**: Creates tracking overlays and statistics