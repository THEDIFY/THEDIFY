# Architecture Documentation

## Table of Contents
- [System Architecture Overview](#system-architecture-overview)
- [Component Architecture](#component-architecture)
- [Data Flow](#data-flow)
- [Technology Stack](#technology-stack)
- [Design Patterns](#design-patterns)
- [Scalability](#scalability)
- [Security Architecture](#security-architecture)
- [Performance Optimization](#performance-optimization)

---

## System Architecture Overview

Axolotl is built on a modern microservices-inspired architecture with GPU-accelerated AI/ML processing, enabling real-time football performance analysis.

### High-Level Architecture

```mermaid
graph TB
    subgraph "Client Layer"
        WebUI[Web Dashboard<br/>React + TypeScript]
        MobileApp[Mobile App<br/>iOS/Android]
        EdgeDevice[Edge Devices<br/>Raspberry Pi/NUC]
    end
    
    subgraph "API Gateway & Load Balancing"
        NGINX[NGINX<br/>Reverse Proxy]
        LB[Load Balancer<br/>Round Robin]
    end
    
    subgraph "Application Layer"
        direction TB
        Flask1[Flask Instance 1<br/>Web + API]
        Flask2[Flask Instance 2<br/>Web + API]
        Flask3[Flask Instance N<br/>Web + API]
        
        WS[WebSocket Server<br/>Socket.IO]
    end
    
    subgraph "Processing Layer"
        direction TB
        Worker1[GPU Worker 1<br/>RTX 3090]
        Worker2[GPU Worker 2<br/>RTX 3090]
        WorkerN[GPU Worker N<br/>A100]
        
        Scheduler[Task Scheduler<br/>Celery]
    end
    
    subgraph "AI/ML Layer"
        direction LR
        YOLO[YOLOv8<br/>Detection]
        ByteTrack[ByteTrack<br/>Tracking]
        MediaPipe[MediaPipe<br/>Pose]
        SMPL[SMPL<br/>3D Mesh]
        GPT4[GPT-4<br/>Feedback]
    end
    
    subgraph "Data Layer"
        direction TB
        Redis[(Redis<br/>Cache & Queue)]
        PostgreSQL[(PostgreSQL<br/>Metrics DB)]
        BlobStorage[(Azure Blob<br/>Videos)]
        VectorDB[(Cognitive Search<br/>RAG Vectors)]
    end
    
    WebUI --> NGINX
    MobileApp --> NGINX
    EdgeDevice --> NGINX
    
    NGINX --> LB
    LB --> Flask1
    LB --> Flask2
    LB --> Flask3
    
    Flask1 --> Redis
    Flask2 --> Redis
    Flask3 --> Redis
    
    Flask1 --> WS
    Flask2 --> WS
    Flask3 --> WS
    
    Redis --> Scheduler
    Scheduler --> Worker1
    Scheduler --> Worker2
    Scheduler --> WorkerN
    
    Worker1 --> YOLO
    Worker1 --> ByteTrack
    Worker1 --> MediaPipe
    Worker2 --> SMPL
    WorkerN --> GPT4
    
    Flask1 --> PostgreSQL
    Flask1 --> BlobStorage
    Worker1 --> PostgreSQL
    GPT4 --> VectorDB
    
    style YOLO fill:#A855F7,stroke:#7E22CE,stroke-width:3px
    style ByteTrack fill:#A855F7,stroke:#7E22CE,stroke-width:3px
    style MediaPipe fill:#A855F7,stroke:#7E22CE,stroke-width:3px
    style SMPL fill:#10B981,stroke:#059669,stroke-width:3px
    style GPT4 fill:#10B981,stroke:#059669,stroke-width:3px
```

### Deployment Architecture

#### Development Environment

```mermaid
graph LR
    subgraph "Local Development"
        Dev[Developer Machine]
        DC[Docker Compose]
        
        Dev --> DC
        
        DC --> Web[Web Container<br/>Port 8080]
        DC --> Worker[Worker Container<br/>GPU Access]
        DC --> Redis[Redis Container<br/>Port 6379]
        DC --> DB[SQLite<br/>File-based]
    end
    
    style Web fill:#3B82F6,stroke:#1D4ED8,stroke-width:2px
    style Worker fill:#10B981,stroke:#059669,stroke-width:2px
    style Redis fill:#DC2626,stroke:#991B1B,stroke-width:2px
```

#### Production Environment (Azure)

```mermaid
graph TB
    subgraph "Azure Cloud"
        subgraph "Azure Kubernetes Service"
            Ingress[Ingress Controller<br/>HTTPS/443]
            
            subgraph "Web Pods"
                WP1[Web Pod 1]
                WP2[Web Pod 2]
                WP3[Web Pod 3]
            end
            
            subgraph "Worker Pods"
                GPU1[GPU Worker Pod 1<br/>NC6 VM]
                GPU2[GPU Worker Pod 2<br/>NC6 VM]
            end
            
            RedisCluster[Redis Cluster<br/>Azure Cache]
        end
        
        subgraph "Azure Services"
            PostgreDB[(Azure PostgreSQL<br/>Managed)]
            BlobStore[(Blob Storage<br/>Videos)]
            CogSearch[(Cognitive Search<br/>RAG)]
            OpenAI[Azure OpenAI<br/>GPT-4]
            KeyVault[Key Vault<br/>Secrets]
        end
        
        CDN[Azure CDN<br/>Static Assets]
    end
    
    Internet[Internet] --> CDN
    Internet --> Ingress
    
    Ingress --> WP1
    Ingress --> WP2
    Ingress --> WP3
    
    WP1 --> RedisCluster
    WP2 --> RedisCluster
    WP3 --> RedisCluster
    
    RedisCluster --> GPU1
    RedisCluster --> GPU2
    
    WP1 --> PostgreDB
    WP1 --> BlobStore
    GPU1 --> PostgreDB
    GPU2 --> OpenAI
    
    OpenAI --> CogSearch
    
    WP1 -.-> KeyVault
    GPU1 -.-> KeyVault
    
    style Ingress fill:#0078D4,stroke:#005A9E,stroke-width:3px
    style PostgreDB fill:#3B82F6,stroke:#1D4ED8,stroke-width:2px
    style OpenAI fill:#10B981,stroke:#059669,stroke-width:3px
```

---

## Component Architecture

### Backend Architecture - Flask Application

```mermaid
graph TB
    subgraph "Flask Application (app.py)"
        Main[Main Flask App]
        Config[Configuration<br/>config.py]
        
        Main --> Config
        Main --> Blueprints
        
        subgraph "API Blueprints"
            ScanBP[scan_bp<br/>Video Upload]
            FeedbackBP[feedback_bp<br/>AI Feedback]
            LiveBP[live_bp<br/>Real-time]
            CalendarBP[calendar_bp<br/>Training Plan]
            DashboardBP[dashboard_bp<br/>Metrics]
            SessionBP[session_bp<br/>Sessions]
            PairingBP[pairing_bp<br/>Device Pair]
            EdgeBP[local_edge_bp<br/>Edge]
        end
        
        Main --> SocketIO[Socket.IO<br/>WebSocket]
        Main --> ORM[SQLAlchemy ORM]
        
        Blueprints --> Routes[Route Handlers]
        Routes --> Services[Service Layer]
        Services --> Models[Data Models]
        Services --> Redis[Redis Client]
        
        Models --> ORM
    end
    
    style ScanBP fill:#A855F7,stroke:#7E22CE,stroke-width:2px
    style FeedbackBP fill:#10B981,stroke:#059669,stroke-width:2px
    style LiveBP fill:#F59E0B,stroke:#D97706,stroke-width:2px
```

### Frontend Architecture - React Application

```mermaid
graph TB
    subgraph "React Application"
        Index[index.tsx<br/>Entry Point]
        Router[React Router<br/>Routing]
        
        Index --> Router
        Index --> Store[Zustand Store<br/>State Management]
        
        Router --> Pages
        
        subgraph "Pages"
            Dashboard[Dashboard]
            Live[Live Analysis]
            Sessions[Session List]
            Calendar[Training Calendar]
            Pairing[Device Pairing]
        end
        
        Pages --> Components
        
        subgraph "Reusable Components"
            VideoPlayer[Video Player]
            MetricsChart[Metrics Charts]
            HeatMap[Heat Map]
            Timeline[Timeline]
            ThreeD[3D Visualizer]
        end
        
        Components --> Hooks[Custom Hooks]
        Components --> Utils[Utilities]
        
        Hooks --> API[API Client]
        Hooks --> WS[WebSocket Client]
        
        API --> Backend[Backend API]
        WS --> SocketIO[Socket.IO Server]
    end
    
    style Dashboard fill:#3B82F6,stroke:#1D4ED8,stroke-width:2px
    style Live fill:#F59E0B,stroke:#D97706,stroke-width:2px
    style ThreeD fill:#10B981,stroke:#059669,stroke-width:2px
```

### AI/ML Pipeline Architecture

```mermaid
graph LR
    subgraph "Video Processing Pipeline"
        Video[Input Video] --> Decoder[Video Decoder<br/>FFmpeg]
        Decoder --> Queue[Frame Queue<br/>Redis]
        
        Queue --> Detection[Player Detection<br/>YOLOv8]
        Detection --> Tracking[Multi-Object Tracking<br/>ByteTrack]
        Tracking --> Pose[Pose Estimation<br/>MediaPipe]
        
        Pose --> Branch1[Branch: SMPL Fitting]
        Pose --> Branch2[Branch: KPI Calculation]
        
        Branch1 --> SMPL[3D Mesh Generation<br/>SMPL Model]
        Branch2 --> Metrics[Metric Engine<br/>Physics + Stats]
        
        SMPL --> Storage1[(Mesh Storage<br/>Blob)]
        Metrics --> Storage2[(Metrics DB<br/>PostgreSQL)]
    end
    
    style Detection fill:#A855F7,stroke:#7E22CE,stroke-width:3px
    style Tracking fill:#A855F7,stroke:#7E22CE,stroke-width:3px
    style Pose fill:#A855F7,stroke:#7E22CE,stroke-width:3px
    style SMPL fill:#10B981,stroke:#059669,stroke-width:3px
```

---

## Data Flow

### Video Upload and Analysis Flow

```mermaid
sequenceDiagram
    participant User
    participant Frontend
    participant Flask
    participant Redis
    participant Worker
    participant AI Models
    participant DB
    participant Storage
    
    User->>Frontend: Select Video File
    Frontend->>Flask: POST /api/scan/upload
    Note over Flask: Validate file<br/>size & format
    
    Flask->>Storage: Upload to Blob Storage
    Storage-->>Flask: Video URL
    
    Flask->>DB: Create Session Record
    DB-->>Flask: Session ID
    
    Flask->>Redis: Queue Processing Job
    Redis-->>Flask: Job ID
    
    Flask-->>Frontend: Job ID + Status URL
    Frontend-->>User: Show Upload Success
    
    Redis->>Worker: Dequeue Job
    Worker->>Storage: Download Video
    Storage-->>Worker: Video Stream
    
    loop For Each Frame
        Worker->>AI Models: YOLOv8 Detection
        AI Models-->>Worker: Bounding Boxes
        
        Worker->>AI Models: ByteTrack Tracking
        AI Models-->>Worker: Track IDs
        
        Worker->>AI Models: MediaPipe Pose
        AI Models-->>Worker: 33 Keypoints
    end
    
    Worker->>Worker: Calculate KPIs
    Worker->>DB: Store Metrics
    
    Worker->>Redis: Update Job Status (Completed)
    Redis-->>Frontend: WebSocket Notification
    
    Frontend->>Flask: GET /api/scan/results/{session_id}
    Flask->>DB: Query Metrics
    DB-->>Flask: Performance Data
    Flask-->>Frontend: JSON Response
    Frontend-->>User: Display Dashboard
```

### AI Feedback Generation Flow

```mermaid
sequenceDiagram
    participant Coach
    participant Frontend
    participant Flask
    participant RAG Engine
    participant Vector DB
    participant PostgreSQL
    participant GPT-4
    
    Coach->>Frontend: Ask Question
    Frontend->>Flask: POST /api/feedback/generate
    
    Flask->>RAG Engine: Process Query
    
    RAG Engine->>PostgreSQL: Get Player Metrics
    PostgreSQL-->>RAG Engine: Performance History
    
    RAG Engine->>RAG Engine: Generate Query Embedding
    RAG Engine->>Vector DB: Semantic Search
    Vector DB-->>RAG Engine: Top-5 Relevant Docs
    
    RAG Engine->>RAG Engine: Build Context Prompt
    Note over RAG Engine: Combine:<br/>- Player metrics<br/>- Search results<br/>- Safety filters (U13+)
    
    RAG Engine->>GPT-4: Generate Feedback
    Note over GPT-4: Temperature: 0.7<br/>Max tokens: 1000<br/>System prompt:<br/>Expert coach
    
    GPT-4-->>RAG Engine: Structured Response
    
    RAG Engine->>RAG Engine: Validate Response
    RAG Engine->>RAG Engine: Extract Drills
    
    RAG Engine->>PostgreSQL: Store Feedback
    PostgreSQL-->>RAG Engine: Feedback ID
    
    RAG Engine-->>Flask: JSON Response
    Flask-->>Frontend: Display Feedback
    Frontend-->>Coach: Show Recommendations
```

### Real-Time Analysis Flow

```mermaid
sequenceDiagram
    participant Camera
    participant Mobile App
    participant WebSocket
    participant Live Service
    participant GPU Worker
    participant Frontend
    
    Mobile App->>Live Service: POST /api/live/start
    Live Service-->>Mobile App: Session ID + WS URL
    
    Mobile App->>WebSocket: Connect
    WebSocket-->>Mobile App: Connection Established
    
    loop Real-time Streaming
        Camera->>Mobile App: Capture Frame
        Mobile App->>Mobile App: Compress Image
        Mobile App->>WebSocket: emit('live_frame', frame_data)
        
        WebSocket->>Live Service: Forward Frame
        Live Service->>GPU Worker: Async Processing
        
        par GPU Processing
            GPU Worker->>GPU Worker: YOLOv8 Detection
            GPU Worker->>GPU Worker: ByteTrack Tracking
            GPU Worker->>GPU Worker: Calculate Instant Metrics
        end
        
        GPU Worker-->>Live Service: Results
        Live Service->>WebSocket: emit('live_metrics', results)
        WebSocket-->>Mobile App: Real-time Update
        WebSocket-->>Frontend: Real-time Update
        
        Mobile App-->>Camera: Display Overlay
        Frontend-->>Frontend: Update Dashboard
    end
    
    Mobile App->>Live Service: POST /api/live/{id}/stop
    Live Service->>Live Service: Save Session Summary
    Live Service-->>Mobile App: Final Results
```

---

## Technology Stack

### Complete Technology Matrix

| Layer | Component | Technology | Version | Purpose |
|-------|-----------|------------|---------|---------|
| **Frontend** | Framework | React | 18.x | UI library |
| | Language | TypeScript | 5.x | Type safety |
| | Build Tool | Vite | 4.x | Fast dev builds |
| | Styling | TailwindCSS | 3.x | Utility CSS |
| | State | Zustand | 4.x | State management |
| | Router | React Router | 6.x | Client routing |
| | 3D Graphics | Three.js + R3F | 0.157+ | 3D visualization |
| | Charts | Recharts | 2.8+ | Data viz |
| | Calendar | FullCalendar | 6.1+ | Scheduling |
| | Icons | Lucide React | 0.290+ | Icons |
| **Backend** | Web Framework | Flask | 3.0+ | HTTP server |
| | ASGI Server | Uvicorn | 0.27+ | Production server |
| | WebSocket | Flask-SocketIO | Latest | Real-time |
| | Task Queue | Celery | 5.3+ | Background jobs |
| | ORM | SQLAlchemy | 2.0+ | Database |
| **AI/ML** | Deep Learning | PyTorch | 2.1+ | Neural networks |
| | Detection | YOLOv8 | 8.0+ | Object detection |
| | Pose | MediaPipe | 0.10+ | Skeletal tracking |
| | Tracking | ByteTrack | Custom | Multi-object |
| | Body Model | SMPL | Custom | 3D mesh |
| | LLM | Azure OpenAI | GPT-4 | AI feedback |
| | Embeddings | text-embedding-3-large | Latest | RAG vectors |
| | Computer Vision | OpenCV | 4.8+ | Video processing |
| **Data** | Cache/Queue | Redis | 7.x | In-memory store |
| | Database (Prod) | PostgreSQL | 15+ | Relational DB |
| | Database (Dev) | SQLite | 3.x | File-based DB |
| | Object Storage | Azure Blob | Latest | Video storage |
| | Vector DB | Azure Cognitive Search | Latest | RAG search |
| **Infrastructure** | Containers | Docker | 20.10+ | Packaging |
| | Orchestration | Docker Compose | 2.0+ | Local dev |
| | Production | Kubernetes (AKS) | 1.28+ | Cloud deploy |
| | CI/CD | GitHub Actions | Latest | Automation |
| | Monitoring | Prometheus + Grafana | Latest | Observability |

---

## Design Patterns

### 1. Repository Pattern (Data Access)

```python
# app/backend/repositories/session_repository.py

class SessionRepository:
    def __init__(self, db_session):
        self.db = db_session
    
    def create(self, session_data):
        session = Session(**session_data)
        self.db.add(session)
        self.db.commit()
        return session
    
    def get_by_id(self, session_id):
        return self.db.query(Session).filter_by(id=session_id).first()
    
    def get_by_player(self, player_id, limit=20):
        return self.db.query(Session)\
            .filter_by(player_id=player_id)\
            .order_by(Session.created_at.desc())\
            .limit(limit).all()
```

### 2. Service Layer Pattern (Business Logic)

```python
# app/backend/services/analysis_service.py

class AnalysisService:
    def __init__(self, session_repo, redis_client):
        self.session_repo = session_repo
        self.redis = redis_client
    
    def analyze_video(self, video_path, player_data):
        # Create session
        session = self.session_repo.create(player_data)
        
        # Queue background job
        job_id = self.queue_analysis_job(session.id, video_path)
        
        return {
            "session_id": session.id,
            "job_id": job_id,
            "status": "queued"
        }
    
    def queue_analysis_job(self, session_id, video_path):
        job_data = {
            "session_id": session_id,
            "video_path": video_path,
            "timestamp": datetime.utcnow()
        }
        return self.redis.rpush("video_processing", json.dumps(job_data))
```

### 3. Factory Pattern (Model Loading)

```python
# src/axolotl/detection/model_factory.py

class DetectionModelFactory:
    _models = {}
    
    @classmethod
    def get_model(cls, model_name, device='cuda'):
        key = f"{model_name}_{device}"
        
        if key not in cls._models:
            if model_name == "yolov8n":
                cls._models[key] = YOLO('yolov8n.pt').to(device)
            elif model_name == "yolov8s":
                cls._models[key] = YOLO('yolov8s.pt').to(device)
            else:
                raise ValueError(f"Unknown model: {model_name}")
        
        return cls._models[key]
```

### 4. Observer Pattern (WebSocket Updates)

```python
# app/backend/observers/job_observer.py

class JobObserver:
    def __init__(self, socketio):
        self.socketio = socketio
        self.subscribers = {}
    
    def subscribe(self, job_id, client_sid):
        if job_id not in self.subscribers:
            self.subscribers[job_id] = []
        self.subscribers[job_id].append(client_sid)
    
    def notify(self, job_id, update_data):
        if job_id in self.subscribers:
            for client_sid in self.subscribers[job_id]:
                self.socketio.emit(
                    'analysis_update',
                    update_data,
                    room=client_sid
                )
```

### 5. Strategy Pattern (Metric Calculation)

```python
# app/backend/metrics/strategies.py

class MetricStrategy(ABC):
    @abstractmethod
    def calculate(self, tracking_data):
        pass

class SpeedMetricStrategy(MetricStrategy):
    def calculate(self, tracking_data):
        # Calculate speed from position changes
        speeds = []
        for i in range(1, len(tracking_data)):
            distance = euclidean_distance(
                tracking_data[i-1]['position'],
                tracking_data[i]['position']
            )
            time_delta = tracking_data[i]['timestamp'] - tracking_data[i-1]['timestamp']
            speeds.append(distance / time_delta)
        
        return {
            "max_speed": max(speeds),
            "avg_speed": sum(speeds) / len(speeds)
        }

class DistanceMetricStrategy(MetricStrategy):
    def calculate(self, tracking_data):
        total_distance = 0
        for i in range(1, len(tracking_data)):
            total_distance += euclidean_distance(
                tracking_data[i-1]['position'],
                tracking_data[i]['position']
            )
        return {"total_distance": total_distance}
```

---

## Scalability

### Horizontal Scaling Strategy

```mermaid
graph TB
    subgraph "Load Distribution"
        LB[Load Balancer<br/>NGINX]
        
        LB --> App1[Flask App 1]
        LB --> App2[Flask App 2]
        LB --> App3[Flask App 3]
        LB --> AppN[Flask App N]
    end
    
    subgraph "Shared State"
        Redis[(Redis Cluster<br/>Session Store)]
        DB[(PostgreSQL<br/>Read Replicas)]
    end
    
    App1 --> Redis
    App2 --> Redis
    App3 --> Redis
    AppN --> Redis
    
    App1 --> DB
    App2 --> DB
    App3 --> DB
    AppN --> DB
    
    style LB fill:#0078D4,stroke:#005A9E,stroke-width:3px
```

### GPU Worker Scaling

```mermaid
graph LR
    subgraph "Redis Queue"
        Queue[Job Queue<br/>FIFO]
    end
    
    subgraph "GPU Workers (Auto-scaled)"
        W1[Worker 1<br/>RTX 3090]
        W2[Worker 2<br/>RTX 3090]
        W3[Worker 3<br/>A100]
        WN[Worker N<br/>A100]
    end
    
    Queue --> W1
    Queue --> W2
    Queue --> W3
    Queue --> WN
    
    W1 -.-> Metrics[Prometheus<br/>Metrics]
    W2 -.-> Metrics
    W3 -.-> Metrics
    WN -.-> Metrics
    
    Metrics --> Autoscaler[K8s HPA<br/>Horizontal Pod Autoscaler]
    Autoscaler -.-> W1
    Autoscaler -.-> W2
```

### Database Scaling

**Read Replicas:**
- Master: Write operations
- Replica 1-N: Read operations
- Automatic failover with PostgreSQL streaming replication

**Caching Strategy:**
- Redis for frequently accessed metrics
- TTL: 5 minutes for dashboard data
- Invalidation on metric updates

**Partitioning:**
- Session data partitioned by date
- Monthly partitions for historical data
- Automatic archive after 6 months

---

## Security Architecture

### Authentication Flow

```mermaid
sequenceDiagram
    participant Client
    participant API
    participant Auth Service
    participant Key Vault
    participant Database
    
    Client->>API: Request with API Key
    API->>Auth Service: Validate Key
    Auth Service->>Database: Query Key
    
    alt Valid Key
        Database-->>Auth Service: Key Data + Permissions
        Auth Service->>Auth Service: Check Expiry
        Auth Service-->>API: Authenticated + Permissions
        API->>Client: Process Request
    else Invalid Key
        Database-->>Auth Service: Not Found
        Auth Service-->>API: Unauthorized
        API->>Client: 401 Unauthorized
    end
```

### Security Layers

1. **Network Security:**
   - HTTPS/TLS 1.3 for all communications
   - Web Application Firewall (WAF)
   - DDoS protection via Azure Front Door
   - VPN for admin access

2. **Application Security:**
   - API key authentication
   - Rate limiting (per endpoint)
   - Input validation and sanitization
   - SQL injection prevention (ORM)
   - XSS protection (React escaping)
   - CSRF tokens for state-changing operations

3. **Data Security:**
   - Encryption at rest (Azure Storage)
   - Encryption in transit (TLS)
   - Sensitive data in Azure Key Vault
   - No credentials in code/version control
   - Regular security audits

4. **AI/ML Security:**
   - Content filtering on AI feedback
   - Age-appropriate safety checks (U13+)
   - PII redaction in training data
   - Model access control

---

## Performance Optimization

### Caching Strategy

```mermaid
graph TB
    Request[API Request] --> Cache{Check Redis Cache}
    
    Cache -->|Cache Hit| Return[Return Cached Data]
    Cache -->|Cache Miss| DB[Query Database]
    
    DB --> Process[Process Data]
    Process --> Store[Store in Cache<br/>TTL: 5min]
    Store --> Return
    
    Return --> Client[Client Response]
    
    style Cache fill:#F59E0B,stroke:#D97706,stroke-width:2px
    style Return fill:#10B981,stroke:#059669,stroke-width:2px
```

### Database Query Optimization

**Indexes:**
```sql
CREATE INDEX idx_session_player_date ON sessions(player_id, created_at DESC);
CREATE INDEX idx_metrics_session ON metrics(session_id);
CREATE INDEX idx_tracking_session_frame ON tracking_data(session_id, frame_number);
```

**Query Optimization:**
- Use SELECT specific columns, not SELECT *
- Implement pagination for list endpoints
- Use database views for complex aggregations
- Connection pooling (max 20 connections)

### Video Processing Optimization

**Batching:**
- Process frames in batches of 32
- GPU memory: 8GB for batch processing
- Parallel tracking across multiple videos

**Model Optimization:**
- Use YOLOv8n (nano) for real-time (30 FPS)
- Use YOLOv8s (small) for accuracy (20 FPS)
- TensorRT optimization for production
- FP16 precision for 2x speedup

**Frame Sampling:**
- Training analysis: Process all frames (60 FPS)
- Quick preview: Sample 15 FPS
- Highlights: Sample 30 FPS

---

## Monitoring & Observability

### Metrics Collection

```mermaid
graph LR
    subgraph "Application"
        App[Flask Apps] --> Metrics[Prometheus Client]
        Worker[GPU Workers] --> Metrics
    end
    
    Metrics --> Prometheus[Prometheus<br/>Time-series DB]
    Prometheus --> Grafana[Grafana<br/>Dashboards]
    
    Prometheus --> Alertmanager[Alert Manager]
    Alertmanager --> Email[Email Alerts]
    Alertmanager --> Slack[Slack Notifications]
    
    style Prometheus fill:#E85D00,stroke:#B34700,stroke-width:2px
    style Grafana fill:#F46800,stroke:#D35400,stroke-width:2px
```

### Key Metrics

**Application Metrics:**
- Request rate (requests/second)
- Response time (p50, p95, p99)
- Error rate (errors/total requests)
- Active WebSocket connections

**Processing Metrics:**
- Video processing time (seconds/video)
- GPU utilization (%)
- Queue depth (jobs waiting)
- Job success/failure rate

**Business Metrics:**
- Daily active users
- Videos analyzed per day
- AI feedback requests per hour
- Session duration average

---

## Related Documentation

- [Backend Architecture Details](documentation/architecture/backend.md)
- [Frontend Architecture Details](documentation/architecture/frontend.md)
- [Database Schema](documentation/architecture/database.md)
- [API Reference](API.md)
- [Deployment Guide](DEPLOYMENT.md)
