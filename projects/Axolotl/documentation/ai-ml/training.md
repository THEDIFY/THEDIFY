# AI Model Training Guide

Complete guide for training, fine-tuning, and deploying AI models in the Axolotl Football Analysis Platform.

## 📋 Table of Contents

1. [Overview](#overview)
2. [Detection Models (YOLO)](#detection-models-yolo)
3. [Tracking Models](#tracking-models)
4. [Pose Estimation](#pose-estimation)
5. [SMPL Body Models](#smpl-body-models)
6. [Event Detection](#event-detection)
7. [Training Infrastructure](#training-infrastructure)
8. [Model Deployment](#model-deployment)
9. [See Also](#see-also)

---

## Overview

The Axolotl platform uses multiple AI models for different tasks:

| Task | Current Model | Status | Training Support |
|------|--------------|--------|------------------|
| Player Detection | YOLOv8n | Pre-trained | ✅ Fine-tuning supported |
| Tracking | ByteTrack | Pre-trained | ⚠️ Partial support |
| Pose Estimation | YOLOv8-pose | Pre-trained | ✅ Fine-tuning supported |
| SMPL Fitting | SMPL-X | Pre-trained | ❌ Not supported |
| Event Detection | Custom CNN | Not implemented | ✅ Training from scratch |

---

## Detection Models (YOLO)

### Current Implementation

The platform uses **YOLOv8n** (nano) for player and ball detection.

**MODEL**: YOLOv8n (ultralytics/yolov8n.pt)  
**DATA**: COCO dataset (pre-trained), football-specific fine-tuning recommended  
**TRAINING/BUILD RECIPE**: See below  
**EVAL & ACCEPTANCE**: mAP@0.5 > 0.85 on validation set, FPS > 30 on 1080p video

### Dataset Preparation

#### 1. Collect Training Data

```bash
# Create dataset directory structure
mkdir -p data/football_detection/{images,labels}/{train,val,test}

# Expected structure:
# data/football_detection/
# ├── images/
# │   ├── train/  (80% of data)
# │   ├── val/    (10% of data)
# │   └── test/   (10% of data)
# └── labels/
#     ├── train/
#     ├── val/
#     └── test/
```

#### 2. Annotation Format

Use YOLO format (one .txt file per image):

```
# Each line: class_id center_x center_y width height (normalized 0-1)
0 0.5 0.3 0.15 0.25  # Player
1 0.6 0.7 0.05 0.05  # Ball
```

**Class IDs**:
- 0: Player
- 1: Ball
- 2: Referee (optional)
- 3: Goal (optional)

#### 3. Annotation Tools

Recommended tools:
- [LabelImg](https://github.com/tzutalin/labelImg) - Free, simple GUI
- [CVAT](https://github.com/opencv/cvat) - Advanced, collaborative
- [Roboflow](https://roboflow.com/) - Cloud-based with augmentation

### Training YOLOv8

#### Setup Training Environment

```bash
# Create training directory
cd /path/to/axolotl
mkdir -p models/training/yolo

# Install dependencies
pip install ultralytics opencv-python matplotlib
```

#### Create Dataset Config

Create `data/football_detection/dataset.yaml`:

```yaml
# Dataset configuration for YOLOv8
path: /path/to/axolotl/data/football_detection
train: images/train
val: images/val
test: images/test

# Class names
names:
  0: player
  1: ball
  2: referee
  3: goal

# Number of classes
nc: 4
```

#### Training Script

Create `scripts/train_yolo_detector.py`:

```python
#!/usr/bin/env python3
"""
YOLOv8 Training Script for Football Player Detection

MODEL: YOLOv8n (nano model for speed/accuracy balance)
DATA: Custom football dataset with player, ball, referee annotations
TRAINING/BUILD RECIPE: 
  - Batch size: 16
  - Epochs: 100
  - Image size: 640x640
  - Optimizer: AdamW with cosine LR schedule
  - Augmentation: mosaic, mixup, HSV, affine transforms
EVAL & ACCEPTANCE: mAP@0.5 > 0.85, mAP@0.5:0.95 > 0.55, FPS > 30
"""

from ultralytics import YOLO
import torch

def train_detector():
    # Load pretrained model
    model = YOLO('yolov8n.pt')  # Start from COCO weights
    
    # Train
    results = model.train(
        data='data/football_detection/dataset.yaml',
        epochs=100,
        imgsz=640,
        batch=16,
        device=0,  # GPU 0, or 'cpu' for CPU training
        workers=8,
        project='models/training/yolo',
        name='football_detector_v1',
        
        # Hyperparameters
        lr0=0.01,
        lrf=0.01,
        momentum=0.937,
        weight_decay=0.0005,
        warmup_epochs=3,
        warmup_momentum=0.8,
        
        # Augmentation
        mosaic=1.0,
        mixup=0.15,
        copy_paste=0.3,
        degrees=0.0,
        translate=0.1,
        scale=0.5,
        shear=0.0,
        perspective=0.0,
        flipud=0.0,
        fliplr=0.5,
        hsv_h=0.015,
        hsv_s=0.7,
        hsv_v=0.4,
        
        # Validation
        val=True,
        save=True,
        save_period=10,
        
        # Early stopping
        patience=20,
        
        # Logging
        verbose=True,
        plots=True
    )
    
    # Evaluate on test set
    metrics = model.val(data='data/football_detection/dataset.yaml', split='test')
    
    print(f"\n{'='*60}")
    print(f"Training Complete!")
    print(f"{'='*60}")
    print(f"mAP@0.5: {metrics.box.map50:.4f}")
    print(f"mAP@0.5:0.95: {metrics.box.map:.4f}")
    print(f"Precision: {metrics.box.mp:.4f}")
    print(f"Recall: {metrics.box.mr:.4f}")
    print(f"Model saved to: models/training/yolo/football_detector_v1/weights/best.pt")
    
    return model

if __name__ == "__main__":
    train_detector()
```

#### Run Training

```bash
# On machine with GPU
python scripts/train_yolo_detector.py

# Monitor training with TensorBoard
tensorboard --logdir models/training/yolo/football_detector_v1
```

#### Training on Google Colab (Free GPU)

```python
# In Colab notebook
!pip install ultralytics

from google.colab import drive
drive.mount('/content/drive')

from ultralytics import YOLO

model = YOLO('yolov8n.pt')
results = model.train(
    data='/content/drive/MyDrive/football_detection/dataset.yaml',
    epochs=100,
    imgsz=640,
    batch=16
)
```

### Model Validation

```python
from ultralytics import YOLO

# Load trained model
model = YOLO('models/training/yolo/football_detector_v1/weights/best.pt')

# Validate
metrics = model.val()

# Test on single image
results = model('path/to/test_image.jpg')
results[0].show()

# Test on video
results = model('path/to/test_video.mp4', save=True)
```

### Acceptance Criteria

Model is ready for deployment when:
- ✅ mAP@0.5 > 0.85 on validation set
- ✅ mAP@0.5:0.95 > 0.55
- ✅ FPS > 30 on 1080p video (RTX 3060 or equivalent)
- ✅ No false positives on common backgrounds
- ✅ Detects players at various distances and angles

---

## Tracking Models

### Current Implementation

**MODEL**: ByteTrack (motion-based tracker)  
**DATA**: No training required (uses detection outputs)  
**TRAINING/BUILD RECIPE**: N/A (non-learning based)  
**EVAL & ACCEPTANCE**: IDF1 > 0.7, MOTA > 0.65 on MOT17 benchmark

### Fine-tuning Tracking Parameters

While ByteTrack doesn't require training, you can optimize parameters:

```python
# In tracking/tracker.py
tracker_config = {
    'track_thresh': 0.5,      # Detection confidence threshold
    'track_buffer': 30,       # Frames to keep lost tracks
    'match_thresh': 0.8,      # IOU threshold for matching
    'min_box_area': 100,      # Minimum bounding box area
    'mot20': False            # MOT20 dataset mode
}
```

### Alternative: Deep SORT Training

For appearance-based tracking with Deep SORT:

1. Collect person re-identification dataset
2. Train appearance encoder (ResNet-50)
3. Generate appearance features for tracked objects
4. Combine with motion model

**Not currently implemented** - future enhancement.

---

## Pose Estimation

### Current Implementation

**MODEL**: YOLOv8-pose (keypoint detection)  
**DATA**: COCO keypoints (17 joints)  
**TRAINING/BUILD RECIPE**: Fine-tune on football-specific poses  
**EVAL & ACCEPTANCE**: PCK@0.5 > 0.90, OKS > 0.70

### Training Pose Model

```python
#!/usr/bin/env python3
"""
YOLOv8-Pose Training for Football Players

MODEL: YOLOv8n-pose
DATA: COCO keypoints + football-specific poses
TRAINING/BUILD RECIPE:
  - Batch size: 16
  - Epochs: 200
  - Image size: 640x640
  - Keypoints: 17 (COCO format)
EVAL & ACCEPTANCE: PCK@0.5 > 0.90, OKS > 0.70
"""

from ultralytics import YOLO

def train_pose_model():
    # Load pretrained pose model
    model = YOLO('yolov8n-pose.pt')
    
    # Train
    results = model.train(
        data='data/football_poses/dataset.yaml',
        epochs=200,
        imgsz=640,
        batch=16,
        device=0,
        project='models/training/pose',
        name='football_pose_v1',
        
        # Pose-specific parameters
        pose=17,  # 17 COCO keypoints
        kpt_shape=[17, 3],  # [num_keypoints, (x, y, visibility)]
        
        # Augmentation (less aggressive for poses)
        mosaic=0.5,
        mixup=0.0,
        degrees=10.0,
        translate=0.1,
        scale=0.3,
        fliplr=0.5
    )
    
    return model

if __name__ == "__main__":
    train_pose_model()
```

### Pose Dataset Format

```yaml
# data/football_poses/dataset.yaml
path: /path/to/football_poses
train: images/train
val: images/val

# Keypoint names (COCO format)
kpt_shape: [17, 3]  # 17 keypoints, each with x, y, visibility
flip_idx: [0, 2, 1, 4, 3, 6, 5, 8, 7, 10, 9, 12, 11, 14, 13, 16, 15]

names:
  0: player
```

Annotation format (JSON):
```json
{
  "images": [...],
  "annotations": [{
    "image_id": 1,
    "category_id": 1,
    "bbox": [x, y, width, height],
    "keypoints": [x1, y1, v1, x2, y2, v2, ...],  # 17 keypoints * 3 values
    "num_keypoints": 17
  }]
}
```

---

## SMPL Body Models

### Current Implementation

**MODEL**: SMPL-X (body shape and pose)  
**DATA**: Pre-trained on large human body dataset  
**TRAINING/BUILD RECIPE**: Not supported (requires specialized dataset)  
**EVAL & ACCEPTANCE**: Visual inspection of body mesh fitting

SMPL models are complex and typically used pre-trained. Custom training requires:
- Large dataset of 3D body scans
- Multi-view calibrated camera setups
- Specialized optimization procedures

**Recommendation**: Use pre-trained SMPL/SMPL-X models as-is.

---

## Event Detection

### Training Event Detection Model

Create a custom event detection model for football actions (sprints, passes, shots).

**MODEL**: Custom CNN + LSTM for temporal action recognition  
**DATA**: Annotated football video clips with event labels  
**TRAINING/BUILD RECIPE**: Transfer learning from I3D or SlowFast  
**EVAL & ACCEPTANCE**: F1-score > 0.80 per event class

### Dataset Preparation

```python
# data/event_detection/prepare_dataset.py
"""
Prepare event detection dataset from annotated videos.

Expected structure:
data/event_detection/
├── videos/
│   ├── session_001.mp4
│   └── session_002.mp4
└── annotations/
    ├── session_001.json
    └── session_002.json

Annotation format:
{
  "events": [
    {
      "type": "sprint",
      "start_frame": 100,
      "end_frame": 150,
      "player_id": "player_1",
      "confidence": 1.0
    }
  ]
}
"""

import cv2
import json
import numpy as np
from pathlib import Path

def extract_event_clips(video_path, annotations, output_dir):
    """Extract clips for each event."""
    cap = cv2.VideoCapture(video_path)
    fps = cap.get(cv2.CAP_PROP_FPS)
    
    for event in annotations['events']:
        event_type = event['type']
        start_frame = event['start_frame']
        end_frame = event['end_frame']
        
        # Create output dir for event type
        event_dir = output_dir / event_type
        event_dir.mkdir(parents=True, exist_ok=True)
        
        # Extract frames
        cap.set(cv2.CAP_PROP_POS_FRAMES, start_frame)
        frames = []
        
        for _ in range(end_frame - start_frame):
            ret, frame = cap.read()
            if not ret:
                break
            frames.append(frame)
        
        # Save clip
        clip_path = event_dir / f"{video_path.stem}_{start_frame}_{end_frame}.npy"
        np.save(clip_path, frames)
    
    cap.release()
```

### Training Script

```python
# scripts/train_event_detector.py
"""
Event Detection Model Training

MODEL: 3D CNN (I3D or custom) for temporal action recognition
DATA: Extracted event clips from football videos
TRAINING/BUILD RECIPE:
  - Architecture: I3D or (2+1)D ResNet
  - Batch size: 8
  - Epochs: 50
  - Learning rate: 0.001 with ReduceLROnPlateau
  - Input: 16 frames per clip
EVAL & ACCEPTANCE: F1-score > 0.80, precision > 0.75, recall > 0.75
"""

import torch
import torch.nn as nn
from torch.utils.data import Dataset, DataLoader
import torchvision.models.video as video_models

class EventDataset(Dataset):
    """Dataset for event detection."""
    
    def __init__(self, data_dir, event_types):
        self.clips = []
        self.labels = []
        self.event_types = event_types
        
        for i, event_type in enumerate(event_types):
            event_dir = data_dir / event_type
            for clip_file in event_dir.glob('*.npy'):
                self.clips.append(clip_file)
                self.labels.append(i)
    
    def __len__(self):
        return len(self.clips)
    
    def __getitem__(self, idx):
        # Load clip
        frames = np.load(self.clips[idx])
        
        # Preprocess: resize, normalize, convert to tensor
        # ... preprocessing code ...
        
        return frames_tensor, self.labels[idx]

def train_event_detector():
    # Event types
    event_types = ['sprint', 'pass', 'shot', 'dribble', 'tackle']
    
    # Load pre-trained I3D model
    model = video_models.r3d_18(pretrained=True)
    model.fc = nn.Linear(model.fc.in_features, len(event_types))
    
    # Training setup
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    model = model.to(device)
    
    criterion = nn.CrossEntropyLoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(optimizer, patience=5)
    
    # Data loaders
    train_dataset = EventDataset(Path('data/event_detection/train'), event_types)
    val_dataset = EventDataset(Path('data/event_detection/val'), event_types)
    
    train_loader = DataLoader(train_dataset, batch_size=8, shuffle=True)
    val_loader = DataLoader(val_dataset, batch_size=8)
    
    # Training loop
    best_f1 = 0.0
    for epoch in range(50):
        # Train
        model.train()
        train_loss = 0.0
        
        for clips, labels in train_loader:
            clips, labels = clips.to(device), labels.to(device)
            
            optimizer.zero_grad()
            outputs = model(clips)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            
            train_loss += loss.item()
        
        # Validate
        model.eval()
        val_preds = []
        val_labels = []
        
        with torch.no_grad():
            for clips, labels in val_loader:
                clips = clips.to(device)
                outputs = model(clips)
                preds = outputs.argmax(dim=1).cpu().numpy()
                
                val_preds.extend(preds)
                val_labels.extend(labels.numpy())
        
        # Calculate metrics
        from sklearn.metrics import f1_score, precision_score, recall_score
        f1 = f1_score(val_labels, val_preds, average='macro')
        precision = precision_score(val_labels, val_preds, average='macro')
        recall = recall_score(val_labels, val_preds, average='macro')
        
        print(f"Epoch {epoch+1}/50:")
        print(f"  Train Loss: {train_loss/len(train_loader):.4f}")
        print(f"  Val F1: {f1:.4f}, Precision: {precision:.4f}, Recall: {recall:.4f}")
        
        # Save best model
        if f1 > best_f1:
            best_f1 = f1
            torch.save(model.state_dict(), 'models/event_detector_best.pth')
            print(f"  New best model saved! F1: {best_f1:.4f}")
        
        scheduler.step(val_loss)
    
    return model

if __name__ == "__main__":
    train_event_detector()
```

---

## Training Infrastructure

### Hardware Requirements

| Model Type | Minimum | Recommended | Notes |
|-----------|---------|-------------|-------|
| YOLO Detection | GTX 1660 Ti | RTX 3060 | 6GB VRAM minimum |
| Pose Estimation | RTX 2060 | RTX 3070 | 8GB VRAM minimum |
| Event Detection | RTX 3060 | RTX 3090 | 12GB+ VRAM preferred |

### Cloud Training Options

#### Google Colab (Free)
- Free GPU (T4) for limited hours
- Good for experimentation
- Limited storage

#### Google Colab Pro ($10/month)
- Better GPUs (V100, A100)
- Longer sessions
- More storage

#### AWS EC2
- `p3.2xlarge`: V100 GPU (~$3/hour)
- `p3.8xlarge`: 4x V100 GPUs (~$12/hour)
- Full control, pay per use

#### Azure ML
- Native integration with Azure services
- Auto-scaling training clusters
- Experiment tracking built-in

### Training Best Practices

1. **Start with pre-trained weights** - Faster convergence
2. **Use mixed precision training** - 2x faster, lower memory
3. **Monitor training with TensorBoard** - Track metrics in real-time
4. **Save checkpoints frequently** - Don't lose progress
5. **Validate on separate dataset** - Avoid overfitting
6. **Data augmentation** - Improve generalization
7. **Learning rate scheduling** - Better convergence
8. **Early stopping** - Stop when validation stops improving

---

## Model Deployment

### Export Trained Models

```python
from ultralytics import YOLO

# Load trained model
model = YOLO('models/training/yolo/football_detector_v1/weights/best.pt')

# Export to different formats
model.export(format='onnx')        # ONNX for cross-platform
model.export(format='torchscript') # TorchScript for production
model.export(format='tflite')      # TensorFlow Lite for mobile
model.export(format='openvino')    # Intel OpenVINO for CPU optimization
```

### Integration into Axolotl

```python
# vision/detector.py
from ultralytics import YOLO

class FootballDetector:
    def __init__(self, model_path='models/football_detector.pt'):
        self.model = YOLO(model_path)
    
    def detect(self, frame):
        results = self.model(frame, conf=0.5)
        return results[0].boxes  # Detection boxes
```

### Model Versioning

Use semantic versioning and model registry:

```
models/
├── production/
│   ├── detector_v1.0.0.pt
│   ├── detector_v1.1.0.pt (current)
│   └── pose_v1.0.0.pt
├── staging/
│   └── detector_v1.2.0-rc1.pt (testing)
└── training/
    └── detector_v1.2.0/ (in progress)
```

---

## See Also

- [AI Improvements](AI_IMPROVEMENTS.md) - Future AI enhancements
- [Additional Implementation Steps](ADDITIONAL_IMPLEMENTATION_STEPS.md) - Other features
- [E2E Testing](../tests/e2e/README.md) - Testing trained models

---

**Last Updated**: 2024-10-04  
**Maintainer**: Axolotl AI Team
