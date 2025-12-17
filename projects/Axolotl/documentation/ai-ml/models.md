# AI/ML Models Overview

The Axolotl platform uses multiple AI and machine learning models for football analysis. This document provides an overview of all models, their purposes, and metadata.

## Model Inventory

### 1. Player Detection (YOLO)

**MODEL**: YOLOv8n (Nano)  
**Purpose**: Real-time player and ball detection in video frames  
**Deployment**: `ultralytics/yolov8n.pt` (downloaded automatically)

**DATA**:
- Training: COCO dataset + custom football data
- Classes: person, sports ball
- Input: RGB images, 640x640 pixels
- Output: Bounding boxes [x, y, w, h] + confidence scores

**TRAINING/BUILD RECIPE**:
- Framework: Ultralytics YOLOv8
- Backbone: CSPDarknet
- Default pretrained weights used
- Fine-tuning optional on custom football datasets

**EVAL & ACCEPTANCE**:
- mAP@0.5: > 0.85 on football videos
- Inference speed: > 30 FPS on CPU, > 100 FPS on GPU
- Minimum confidence threshold: 0.5

**Usage**:
```python
from ultralytics import YOLO
model = YOLO('yolov8n.pt')
results = model.predict(frame, conf=0.5)
```

---

### 2. Pose Estimation (MediaPipe)

**MODEL**: MediaPipe Pose  
**Purpose**: 2D/3D keypoint detection for player body tracking  
**Deployment**: `mediapipe` library (version 0.9.0+)

**DATA**:
- Training: Google's internal pose dataset
- Keypoints: 33 body landmarks (COCO format + face/hands)
- Input: RGB images, any resolution
- Output: (x, y, z, visibility) for each keypoint

**TRAINING/BUILD RECIPE**:
- Pre-trained Google model
- BlazePose architecture
- Optimized for mobile/edge devices
- No retraining required

**EVAL & ACCEPTANCE**:
- Keypoint accuracy: > 90% on visible joints
- Inference speed: > 25 FPS on CPU
- Minimum visibility score: 0.5

**Usage**:
```python
import mediapipe as mp
mp_pose = mp.solutions.pose
pose = mp_pose.Pose()
results = pose.process(image)
```

**See**: [Pose Estimation Guide](pose.md)

---

### 3. Multi-Object Tracking (ByteTrack)

**MODEL**: ByteTrack  
**Purpose**: Associate detections across frames to track individual players  
**Deployment**: Custom implementation in `src/axolotl/tracking/`

**DATA**:
- Input: YOLO detections per frame
- Output: Track IDs + trajectories
- Works with MOT17, MOT20 benchmark formats

**TRAINING/BUILD RECIPE**:
- Association: IoU + Kalman filtering
- Matching: Hungarian algorithm
- No training required (rule-based)
- Hyperparameters: track_thresh=0.5, track_buffer=30, match_thresh=0.8

**EVAL & ACCEPTANCE**:
- MOTA: > 65% on football videos
- IDF1: > 70% (identity preservation)
- FPS: > 20 on detection outputs

**Usage**:
```python
from tracking.bytetracker_interface import ByteTracker
tracker = ByteTracker()
tracks = tracker.update(detections)
```

**See**: [Tracking Guide](tracking.md)

---

### 4. Event Spotting Model

**MODEL**: Custom event spotting network  
**Purpose**: Detect football events (pass, shot, tackle, goal)  
**Deployment**: `models/event_spotting.pth`

**DATA**:
- Training: SoccerNet dataset (v2)
- Events: 17 action classes
- Input: Video clips (5 second windows) + optical flow
- Output: Event type + timestamp + confidence

**TRAINING/BUILD RECIPE**:
- Architecture: ResNet-50 + LSTM
- Frames: 5 FPS sampling from clips
- Batch size: 32
- Epochs: 50
- Optimizer: Adam (lr=1e-4)
- Loss: Focal loss (class imbalance)
- Training time: ~8 hours on V100 GPU

**EVAL & ACCEPTANCE**:
- mAP: > 0.55 (tight window)
- Average mAP: > 0.65 (loose window)
- Per-class precision: > 0.60 for critical events
- Test command: `pytest tests/test_event_spotting.py`

**Usage**:
```python
from src.axolotl.event_spotting import EventSpotter
spotter = EventSpotter('models/event_spotting.pth')
events = spotter.predict_video(video_path)
```

**See**: [Event Spotting Guide](event-spotting.md)

---

### 5. SMPL Body Model

**MODEL**: SMPL (Skinned Multi-Person Linear Model)  
**Purpose**: 3D body mesh reconstruction from 2D poses  
**Deployment**: SMPL model files + optimization code

**DATA**:
- Input: 2D keypoints from MediaPipe
- Output: 3D mesh (6890 vertices, 10 shape params, 72 pose params)
- Body model: SMPL neutral gender

**TRAINING/BUILD RECIPE**:
- Method: Optimization-based fitting
- Optimizer: L-BFGS
- Loss: 2D reprojection + pose priors + shape priors
- Iterations: 100 per frame
- Processing time: ~2-3 seconds per frame on GPU

**EVAL & ACCEPTANCE**:
- Reprojection error: < 10 pixels RMSE
- 3D joint error (MPJPE): < 80mm on validation set
- Output format: OBJ mesh + JSON parameters

**Usage**:
```python
from biomech.smpl_fitter import SMPLFitter
fitter = SMPLFitter()
mesh = fitter.fit_frame(keypoints_2d, camera_params)
```

---

### 6. Azure OpenAI (GPT-4)

**MODEL**: gpt-4 (Azure deployment)  
**Purpose**: AI coaching feedback and training recommendations  
**Deployment**: Azure OpenAI Service

**DATA**:
- Input: Player performance metrics, session history, RAG context
- Output: Natural language feedback, drill recommendations
- Context window: 8K tokens
- Temperature: 0.7

**TRAINING/BUILD RECIPE**:
- Pretrained GPT-4 from Azure OpenAI
- No fine-tuning (uses prompt engineering)
- System prompts in `src/axolotl/llm/templates/`
- RAG: Azure Cognitive Search for context retrieval

**EVAL & ACCEPTANCE**:
- Response quality: Manual evaluation by coaches
- Latency: < 5 seconds for feedback generation
- Safety: Content filtering enabled
- Cost: Monitor token usage per request

**Usage**:
```python
from src.axolotl.llm.feedback_engine import FeedbackEngine
engine = FeedbackEngine()
feedback = engine.generate_feedback(session_data)
```

**See**: [AI Feedback System](../features/ai-feedback.md), [RAG System](rag-system.md)

---

### 7. Text Embeddings (Azure OpenAI)

**MODEL**: text-embedding-3-large  
**Purpose**: Convert text to vectors for RAG semantic search  
**Deployment**: Azure OpenAI Service

**DATA**:
- Input: Session summaries, drill descriptions, coach notes
- Output: 3072-dimensional embedding vectors
- Storage: Azure Cognitive Search vector index

**TRAINING/BUILD RECIPE**:
- Pretrained embedding model
- Cosine similarity for retrieval
- Top-K: 5 most relevant documents
- Reranking: Optional with cross-encoder

**EVAL & ACCEPTANCE**:
- Retrieval accuracy: > 80% relevant results in top-5
- Latency: < 500ms for embedding generation
- Index refresh: Daily batch updates

---

### 8. Field Homography Mapping

**MODEL**: Classical CV (not ML-based)  
**Purpose**: Map pixel coordinates to real-world field coordinates  
**Deployment**: `src/axolotl/multiview/field_mapper.py`

**DATA**:
- Input: Field line detections, corner points
- Output: 3x3 homography matrix
- Reference: Standard football pitch dimensions (105m x 68m)

**TRAINING/BUILD RECIPE**:
- Algorithm: RANSAC + perspective transform
- Point matching: Line intersections
- No training required

**EVAL & ACCEPTANCE**:
- Reprojection error: < 5 pixels on field lines
- Coverage: Works with partial field views

**See**: `docs/field_mapping.md`

---

## Model Storage

### Local Development
```
models/
├── yolov8n.pt              # Downloaded on first use
├── event_spotting.pth      # Custom trained model
└── smpl/                   # SMPL body model files
    ├── SMPL_NEUTRAL.pkl
    └── smpl_mean_params.npz
```

### Production (Azure Blob Storage)
```
AZURE_STORAGE_CONTAINER=models
├── event_spotting_v2.pth
├── pose_tracking_v1.pth
└── custom_yolo_football.pt
```

## Model Updates

### Downloading Models
```bash
# Run setup script to download all models
python scripts/download_models.py
```

### Training Custom Models
See [Model Training Guide](training.md) for instructions on fine-tuning models.

### Model Versioning
- Models are versioned in Azure Blob Storage
- Model registry: `models/model_registry.json`
- CI/CD automatically deploys updated models

## Performance Benchmarks

| Model | CPU (FPS) | GPU (FPS) | Memory (GB) |
|-------|-----------|-----------|-------------|
| YOLOv8n | 30 | 120 | 0.5 |
| MediaPipe Pose | 25 | 60 | 0.3 |
| ByteTrack | 50 | 100 | 0.2 |
| Event Spotting | 10 | 45 | 2.0 |
| SMPL Fitting | 0.5 | 5 | 4.0 |

*Tested on: Intel i7-11700K (CPU), NVIDIA RTX 3090 (GPU)*

## Next Steps

- [Detection Guide](detection.md) - YOLO detection details
- [Tracking Guide](tracking.md) - Multi-object tracking
- [Pose Estimation](pose.md) - 3D pose and SMPL fitting
- [Training Guide](training.md) - Train custom models
- [Event Spotting](event-spotting.md) - Event detection details
