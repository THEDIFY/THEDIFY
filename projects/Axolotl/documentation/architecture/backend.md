# Backend Architecture

## Table of Contents
- [Overview](#overview)
- [Directory Structure](#directory-structure)
- [Flask Application](#flask-application)
- [Blueprints](#blueprints)
- [Services Layer](#services-layer)
- [Worker Service](#worker-service)
- [Database Models](#database-models)
- [Configuration](#configuration)
- [Background Jobs](#background-jobs)
- [WebSocket Communication](#websocket-communication)

## Overview

The Axolotl backend is built on Flask, a lightweight Python web framework. The architecture follows a modular blueprint pattern with a service layer for business logic separation.

**Location**: `app/backend/`

**Key Principles**:
- **Modular Design**: Blueprints for feature isolation
- **Service Layer**: Business logic separated from routes
- **Async Processing**: Heavy tasks offloaded to workers
- **Real-time Updates**: WebSocket support for live features

## Directory Structure

```
app/backend/
├── app.py                      # Main Flask application entry point
├── worker.py                   # Background worker process
├── blueprints/                 # API route modules
│   ├── __init__.py
│   ├── scan_bp.py             # Video scanning and analysis
│   ├── feedback_bp.py         # AI coaching feedback
│   ├── live_bp.py             # Real-time analysis
│   ├── calendar_bp.py         # Training planning
│   ├── dashboard_bp.py        # Performance metrics
│   ├── session_bp.py          # Session management
│   ├── pairing_bp.py          # Device pairing
│   ├── local_edge_bp.py       # Edge device communication
│   ├── README_DASHBOARD.md    # Dashboard documentation
│   └── README_SESSION.md      # Session documentation
├── services/                   # Business logic layer
│   ├── __init__.py
│   ├── auth_utils.py          # Authentication helpers
│   ├── calendar_service.py    # Calendar business logic
│   ├── edge_gateway.py        # Edge device coordination
│   ├── kpi_calculator.py      # Performance metrics
│   ├── live_processor.py      # Live stream processing
│   ├── multiview_recon.py     # 3D reconstruction
│   ├── pairing_service.py     # Device pairing logic
│   ├── rules_engine.py        # Training safety rules
│   ├── stream_handler.py      # Video stream management
│   ├── sync_utils.py          # Data synchronization
│   ├── ws_calendar.py         # Calendar WebSocket
│   ├── README_KPI.md          # KPI calculation docs
│   └── README_PAIRING.md      # Pairing service docs
├── static/                     # Frontend build output
│   └── assets/                # JS, CSS, images
└── templates/                  # HTML templates
    └── index.html             # SPA entry point
```

## Flask Application

### Main Application (`app.py`)

The main application file initializes Flask, registers blueprints, and configures middleware.

```python
# Core initialization
app = Flask(__name__)
socketio = SocketIO(app, cors_allowed_origins="*")

# Blueprint registration
app.register_blueprint(scan_bp)
app.register_blueprint(feedback_bp)
app.register_blueprint(live_bp)
app.register_blueprint(calendar_bp)
app.register_blueprint(dashboard_bp)
app.register_blueprint(session_bp)
app.register_blueprint(pairing_bp)
app.register_blueprint(local_edge_bp)

# WebSocket event registration
register_socketio_events(socketio)
register_calendar_ws_events(socketio)
register_pairing_events(socketio)
register_local_edge_events(socketio)
```

### Key Features

#### CORS Configuration
```python
from flask_cors import CORS

CORS(app, resources={
    r"/api/*": {
        "origins": "*",
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization"]
    }
})
```

#### Error Handling
```python
@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Internal server error'}), 500
```

#### Health Check
```python
@app.route('/health')
def health_check():
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'version': '1.0.0'
    })
```

## Blueprints

Blueprints are Flask's way of organizing related routes into modules. Each blueprint handles a specific domain.

### 1. Scan Blueprint (`scan_bp`)

**Purpose**: Video upload, processing, and analysis

**Key Routes**:
- `POST /api/scan/quick` - Quick scan with single video
- `POST /api/scan/multiview` - Multi-camera scan
- `GET /api/scan/:id/status` - Check scan status
- `GET /api/scan/:id/results` - Get scan results
- `GET /api/scan/:id/kpis` - Get calculated KPIs

**Features**:
- Video file upload handling
- Background job submission
- KPI calculation and caching
- Result retrieval

**Dependencies**:
- `kpi_calculator` service
- `multiview_recon` service
- Redis queue for async processing

### 2. Feedback Blueprint (`feedback_bp`)

**Purpose**: AI-powered coaching feedback generation

**Key Routes**:
- `POST /api/feedback/generate` - Generate coaching feedback
- `GET /api/feedback/:id` - Get feedback by ID
- `GET /api/feedback/session/:session_id` - Get session feedback
- `POST /api/feedback/batch` - Batch feedback generation

**Features**:
- LLM-powered feedback generation
- RAG (Retrieval-Augmented Generation)
- Context-aware recommendations
- Feedback history management

**Dependencies**:
- `src/axolotl/llm/feedback_engine`
- Azure OpenAI API
- Azure Cognitive Search

### 3. Live Blueprint (`live_bp`)

**Purpose**: Real-time session tracking and analysis

**Key Routes**:
- `POST /api/live/start` - Start live session
- `POST /api/live/frame` - Submit frame for processing
- `POST /api/live/stop` - Stop live session
- `GET /api/live/:session_id/status` - Get session status

**WebSocket Events**:
- `connect` - Client connection
- `disconnect` - Client disconnection
- `start_session` - Begin live tracking
- `frame_data` - Frame submission
- `metrics_update` - Real-time metrics broadcast

**Features**:
- Frame buffering
- Real-time detection/tracking
- Live KPI updates
- WebSocket broadcasting

**Dependencies**:
- `live_processor` service
- `stream_handler` service
- Detection and tracking modules

### 4. Calendar Blueprint (`calendar_bp`)

**Purpose**: Training event planning and scheduling

**Key Routes**:
- `GET /api/calendar/events` - List events
- `POST /api/calendar/events` - Create event
- `PUT /api/calendar/events/:id` - Update event
- `DELETE /api/calendar/events/:id` - Delete event
- `POST /api/calendar/recommend` - Get AI recommendations

**WebSocket Events**:
- `calendar_update` - Broadcast event changes
- `recommendation_ready` - AI recommendation complete

**Features**:
- Event CRUD operations
- AI-powered training recommendations
- Safety validation (rules engine)
- Real-time calendar synchronization

**Dependencies**:
- `calendar_service`
- `rules_engine`
- `ws_calendar` WebSocket handler

### 5. Dashboard Blueprint (`dashboard_bp`)

**Purpose**: Performance metrics aggregation and visualization

**Key Routes**:
- `GET /api/dashboard/overview` - Overall performance summary
- `GET /api/dashboard/player/:id` - Player-specific metrics
- `GET /api/dashboard/trends` - Performance trends
- `GET /api/dashboard/comparisons` - Player comparisons

**Features**:
- Metric aggregation
- Trend analysis
- Statistical calculations
- Data visualization preparation

**Dependencies**:
- `kpi_calculator` service
- Database queries
- Caching layer

### 6. Session Blueprint (`session_bp`)

**Purpose**: Session management and history

**Key Routes**:
- `GET /api/sessions` - List sessions (with filters)
- `POST /api/sessions` - Create session
- `GET /api/sessions/:id` - Get session details
- `PUT /api/sessions/:id` - Update session
- `DELETE /api/sessions/:id` - Delete session
- `GET /api/sessions/:id/attachments` - Get session files

**Features**:
- Session CRUD operations
- Metadata management
- File attachments
- Query filtering and pagination
- Session indexing for RAG

**Dependencies**:
- Database models
- File storage (Azure Blob)
- Search indexing

### 7. Pairing Blueprint (`pairing_bp`)

**Purpose**: Mobile device pairing via QR codes

**Key Routes**:
- `POST /api/pairing/generate` - Generate pairing code
- `POST /api/pairing/connect` - Connect device
- `GET /api/pairing/devices` - List paired devices
- `DELETE /api/pairing/:device_id` - Unpair device

**WebSocket Events**:
- `pairing_request` - New pairing attempt
- `pairing_success` - Pairing confirmed
- `pairing_failed` - Pairing error

**Features**:
- QR code generation
- Device authentication
- Secure token management
- WebSocket-based pairing flow

**Dependencies**:
- `pairing_service`
- QR code library
- JWT tokens

### 8. Local Edge Blueprint (`local_edge_bp`)

**Purpose**: Edge device communication and coordination

**Key Routes**:
- `POST /api/local-edge/register` - Register edge device
- `POST /api/local-edge/sync` - Sync data
- `GET /api/local-edge/status` - Get device status
- `POST /api/local-edge/process` - Submit processing job

**WebSocket Events**:
- `edge_connected` - Edge device online
- `edge_disconnected` - Edge device offline
- `sync_update` - Data sync progress

**Features**:
- Edge device registration
- Offline data synchronization
- Local processing coordination
- Bandwidth-optimized transfers

**Dependencies**:
- `edge_gateway` service
- `sync_utils`
- Local storage

## Services Layer

The services layer contains business logic separated from route handlers. This promotes code reuse and testability.

### Authentication Utilities (`auth_utils.py`)

```python
def generate_api_key() -> str:
    """Generate secure API key for device authentication."""

def verify_api_key(key: str) -> bool:
    """Verify API key validity."""

def create_session_token(user_id: str) -> str:
    """Create JWT session token."""
```

### Calendar Service (`calendar_service.py`)

```python
class CalendarService:
    def create_event(self, event_data: dict) -> dict:
        """Create training event with validation."""
    
    def get_recommendations(self, player_id: str) -> List[dict]:
        """Get AI-powered training recommendations."""
    
    def validate_event(self, event: dict) -> Tuple[bool, List[str]]:
        """Validate event against rules engine."""
```

### KPI Calculator (`kpi_calculator.py`)

```python
def calculate_kpis(detections: List, poses: List) -> dict:
    """
    Calculate comprehensive performance metrics.
    
    Returns:
        {
            'speed': {...},
            'distance': {...},
            'technical': {...},
            'physical': {...}
        }
    """

def calculate_speed_metrics(trajectories: np.ndarray) -> dict:
    """Calculate speed-related KPIs."""

def calculate_distance_metrics(trajectories: np.ndarray) -> dict:
    """Calculate distance and movement KPIs."""
```

### Live Processor (`live_processor.py`)

```python
class LiveProcessor:
    def __init__(self):
        self.detector = YOLODetector()
        self.tracker = ByteTracker()
        self.pose_estimator = PoseEstimator()
    
    def process_frame(self, frame: np.ndarray) -> dict:
        """Process single frame for live analysis."""
    
    def get_current_metrics(self, session_id: str) -> dict:
        """Get current session metrics."""
```

### Multiview Reconstruction (`multiview_recon.py`)

```python
def triangulate_points(
    points_2d: Dict[str, np.ndarray],
    camera_params: Dict[str, dict]
) -> np.ndarray:
    """
    Triangulate 3D points from multiple 2D views.
    
    Args:
        points_2d: 2D points per camera
        camera_params: Camera calibration parameters
    
    Returns:
        3D world coordinates
    """
```

### Rules Engine (`rules_engine.py`)

```python
class RulesEngine:
    """Training safety and guideline validation."""
    
    def validate_training_load(
        self, 
        player_age: int,
        recent_sessions: List[dict]
    ) -> Tuple[bool, List[str]]:
        """Validate training load for safety."""
    
    def check_recovery_time(
        self,
        last_session: datetime,
        proposed_session: datetime
    ) -> Tuple[bool, str]:
        """Check adequate recovery time."""
```

## Worker Service

### Overview

The worker service (`worker.py`) processes background jobs using Redis as a task queue.

**Purpose**: Offload CPU/GPU-intensive tasks from the web service

**Key Responsibilities**:
- Video processing
- SMPL model fitting
- 3D reconstruction
- Heavy AI/ML computations

### Architecture

```python
from redis import Redis
from rq import Worker, Queue

# Redis connection
redis_conn = Redis(host='redis', port=6379)

# Job queues
smpl_queue = Queue('smpl_jobs', connection=redis_conn)
video_queue = Queue('video_processing', connection=redis_conn)
background_queue = Queue('background_tasks', connection=redis_conn)

# Worker process
worker = Worker(
    [smpl_queue, video_queue, background_queue],
    connection=redis_conn
)
worker.work()
```

### Job Types

#### SMPL Fitting Job
```python
def fit_smpl_job(session_id: str, pose_data: dict):
    """
    Fit SMPL model to pose data.
    
    Args:
        session_id: Session identifier
        pose_data: Pose estimation results
    """
    from src.axolotl.biomech import SMPLFitter
    
    fitter = SMPLFitter()
    result = fitter.fit(pose_data)
    
    # Store result
    save_smpl_result(session_id, result)
```

#### Video Processing Job
```python
def process_video_job(video_path: str, session_id: str):
    """
    Process uploaded video through full pipeline.
    
    Args:
        video_path: Path to video file
        session_id: Session identifier
    """
    from src.axolotl.detection import YOLODetector
    from src.axolotl.tracking import ByteTracker
    from src.axolotl.pose import PoseEstimator
    
    # Detection
    detector = YOLODetector()
    detections = detector.process_video(video_path)
    
    # Tracking
    tracker = ByteTracker()
    tracks = tracker.track(detections)
    
    # Pose estimation
    pose_estimator = PoseEstimator()
    poses = pose_estimator.estimate(video_path, tracks)
    
    # Calculate KPIs
    kpis = calculate_kpis(tracks, poses)
    
    # Store results
    save_session_results(session_id, {
        'detections': detections,
        'tracks': tracks,
        'poses': poses,
        'kpis': kpis
    })
```

### Job Submission

From blueprints:
```python
from redis import Redis
from rq import Queue

redis_conn = Redis(host='redis', port=6379)
queue = Queue('video_processing', connection=redis_conn)

# Submit job
job = queue.enqueue(
    process_video_job,
    video_path='/storage/uploads/video.mp4',
    session_id='session_123',
    job_timeout='30m'
)

return jsonify({
    'job_id': job.id,
    'status': 'queued'
})
```

### Job Monitoring

```python
from rq.job import Job

def get_job_status(job_id: str) -> dict:
    """Get current job status."""
    job = Job.fetch(job_id, connection=redis_conn)
    
    return {
        'id': job.id,
        'status': job.get_status(),
        'result': job.result,
        'exc_info': job.exc_info,
        'created_at': job.created_at,
        'ended_at': job.ended_at
    }
```

## Database Models

### Session Model
```python
from sqlalchemy import Column, Integer, String, DateTime, JSON

class Session(Base):
    __tablename__ = 'sessions'
    
    id = Column(String, primary_key=True)
    player_id = Column(String, nullable=False)
    session_type = Column(String)  # 'training', 'match', 'analysis'
    created_at = Column(DateTime, default=datetime.utcnow)
    metadata = Column(JSON)
    kpis = Column(JSON)
```

### Event Model
```python
class TrainingEvent(Base):
    __tablename__ = 'training_events'
    
    id = Column(String, primary_key=True)
    player_id = Column(String, nullable=False)
    title = Column(String, nullable=False)
    start_time = Column(DateTime, nullable=False)
    end_time = Column(DateTime, nullable=False)
    event_type = Column(String)  # 'training', 'match', 'recovery'
    drills = Column(JSON)
    ai_generated = Column(Boolean, default=False)
```

### Device Model
```python
class PairedDevice(Base):
    __tablename__ = 'paired_devices'
    
    id = Column(String, primary_key=True)
    device_name = Column(String)
    device_type = Column(String)  # 'mobile', 'edge'
    api_key = Column(String, unique=True)
    paired_at = Column(DateTime, default=datetime.utcnow)
    last_seen = Column(DateTime)
```

## Configuration

### Environment Variables

```python
# app/backend/app.py
import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    # Flask
    SECRET_KEY = os.getenv('SECRET_KEY', 'dev-secret-key')
    DEBUG = os.getenv('FLASK_ENV') == 'development'
    
    # Database
    DATABASE_URL = os.getenv('DATABASE_URL', 'sqlite:///axolotl.db')
    
    # Redis
    REDIS_URL = os.getenv('REDIS_URL', 'redis://localhost:6379')
    
    # Azure Services
    AZURE_OPENAI_ENDPOINT = os.getenv('AZURE_OPENAI_ENDPOINT')
    AZURE_OPENAI_KEY = os.getenv('AZURE_OPENAI_KEY')
    AZURE_SEARCH_ENDPOINT = os.getenv('AZURE_SEARCH_ENDPOINT')
    AZURE_SEARCH_KEY = os.getenv('AZURE_SEARCH_KEY')
    AZURE_STORAGE_CONNECTION = os.getenv('AZURE_STORAGE_CONNECTION')
    
    # Application
    MAX_UPLOAD_SIZE = int(os.getenv('MAX_UPLOAD_SIZE', 500 * 1024 * 1024))  # 500MB
    ALLOWED_VIDEO_FORMATS = ['mp4', 'avi', 'mov', 'mkv']
```

## Background Jobs

### Job Queue Configuration

```python
# Redis job queues with priorities
QUEUES = {
    'critical': Queue('critical', connection=redis_conn),  # Real-time features
    'default': Queue('default', connection=redis_conn),    # Standard processing
    'low': Queue('low', connection=redis_conn)            # Batch operations
}
```

### Job Retry Logic

```python
def retry_job(func, max_retries=3, backoff=5):
    """Decorator for job retry logic."""
    def wrapper(*args, **kwargs):
        for attempt in range(max_retries):
            try:
                return func(*args, **kwargs)
            except Exception as e:
                if attempt == max_retries - 1:
                    raise
                time.sleep(backoff * (attempt + 1))
    return wrapper
```

## WebSocket Communication

### SocketIO Setup

```python
from flask_socketio import SocketIO, emit, join_room, leave_room

socketio = SocketIO(
    app,
    cors_allowed_origins="*",
    async_mode='threading',
    logger=True,
    engineio_logger=False
)
```

### Event Handlers

```python
@socketio.on('connect')
def handle_connect():
    """Handle client connection."""
    print(f'Client connected: {request.sid}')
    emit('connected', {'session_id': request.sid})

@socketio.on('join_session')
def handle_join_session(data):
    """Join a specific session room."""
    session_id = data.get('session_id')
    join_room(session_id)
    emit('joined', {'session_id': session_id}, room=session_id)

@socketio.on('disconnect')
def handle_disconnect():
    """Handle client disconnection."""
    print(f'Client disconnected: {request.sid}')
```

### Broadcasting Updates

```python
def broadcast_metrics_update(session_id: str, metrics: dict):
    """Broadcast real-time metrics to all clients in session."""
    socketio.emit(
        'metrics_update',
        {'metrics': metrics, 'timestamp': datetime.utcnow().isoformat()},
        room=session_id
    )
```

## API Response Standards

### Success Response
```json
{
    "success": true,
    "data": {...},
    "message": "Operation completed successfully",
    "timestamp": "2025-10-24T00:00:00Z"
}
```

### Error Response
```json
{
    "success": false,
    "error": {
        "code": "VALIDATION_ERROR",
        "message": "Invalid input data",
        "details": ["Field 'email' is required"]
    },
    "timestamp": "2025-10-24T00:00:00Z"
}
```

### Pagination Response
```json
{
    "success": true,
    "data": [...],
    "pagination": {
        "page": 1,
        "per_page": 20,
        "total": 145,
        "pages": 8
    }
}
```

## Testing

### Unit Tests
```python
# tests/unit/test_kpi_calculator.py
import pytest
from app.backend.services.kpi_calculator import calculate_speed_metrics

def test_calculate_speed_metrics():
    trajectories = np.array([[0, 0], [1, 0], [2, 0]])
    fps = 30
    
    metrics = calculate_speed_metrics(trajectories, fps)
    
    assert 'max_speed' in metrics
    assert 'avg_speed' in metrics
    assert metrics['max_speed'] > 0
```

### Integration Tests
```python
# tests/integration/test_scan_api.py
def test_quick_scan_endpoint(client):
    with open('tests/data/sample_video.mp4', 'rb') as video:
        response = client.post(
            '/api/scan/quick',
            data={'video': video, 'player_id': 'player_1'},
            content_type='multipart/form-data'
        )
    
    assert response.status_code == 200
    assert 'job_id' in response.json
```

## Related Documentation

- [System Architecture Overview](overview.md)
- [Frontend Architecture](frontend.md)
- [Database Schema](database.md)
- [API Reference](api-reference.md)
- [Development Guide](../development/contributing.md)
