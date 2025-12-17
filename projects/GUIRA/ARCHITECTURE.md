# GUIRA - System Architecture Documentation

<div align="center">

![Architecture](https://img.shields.io/badge/Architecture-Multi--Modal%20AI-A855F7?style=for-the-badge)
![Version](https://img.shields.io/badge/version-0.4.0-blue?style=for-the-badge)

**Detailed Technical Architecture Guide**

</div>

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Architectural Patterns](#architectural-patterns)
3. [Component Architecture](#component-architecture)
4. [Data Flow Design](#data-flow-design)
5. [AI Model Architecture](#ai-model-architecture)
6. [Geospatial System Design](#geospatial-system-design)
7. [API Architecture](#api-architecture)
8. [Database Schema](#database-schema)
9. [Deployment Architecture](#deployment-architecture)
10. [Security Architecture](#security-architecture)
11. [Scalability Considerations](#scalability-considerations)
12. [Performance Optimization](#performance-optimization)

---

## System Overview

GUIRA employs a microservices-based architecture with five specialized AI models working in parallel to provide comprehensive wildfire monitoring and prediction capabilities.

### High-Level Architecture

```mermaid
graph TB
    subgraph "Edge Layer"
        E1[Drone Cameras]
        E2[Ground Sensors]
        E3[Weather Stations]
    end
    
    subgraph "Data Ingestion Layer"
        I1[Video Stream Handler]
        I2[Satellite Data Fetcher]
        I3[Weather API Client]
        I4[DEM Data Loader]
    end
    
    subgraph "Processing Layer"
        P1[Frame Buffer Service]
        P2[AI Inference Engine]
        P3[Geospatial Processor]
        P4[Risk Assessment Service]
        P5[Fire Simulation Service]
    end
    
    subgraph "AI Models Layer"
        M1[YOLOv8 Fire Detection]
        M2[TimeSFormer Smoke Analysis]
        M3[ResNet50 Vegetation Health]
        M4[YOLOv8+CSRNet Wildlife]
        M5[Hybrid Fire Spread Model]
    end
    
    subgraph "Data Layer"
        D1[(PostgreSQL + PostGIS)]
        D2[(Redis Cache)]
        D3[Model Storage]
        D4[DEM Repository]
    end
    
    subgraph "API Layer"
        A1[FastAPI Server]
        A2[WebSocket Service]
        A3[REST Endpoints]
    end
    
    subgraph "Presentation Layer"
        U1[Web Dashboard]
        U2[Mobile App]
        U3[Alert System]
        U4[External Integrations]
    end
    
    E1 --> I1
    E2 --> I1
    E3 --> I3
    I2 --> P1
    I1 --> P1
    I3 --> P4
    I4 --> P3
    
    P1 --> P2
    P2 --> M1
    P2 --> M2
    P2 --> M3
    P2 --> M4
    
    M1 --> P3
    M2 --> P3
    M3 --> P3
    M4 --> P3
    
    P3 --> P4
    P4 --> P5
    P5 --> M5
    
    P2 --> D2
    P3 --> D1
    P4 --> D1
    P5 --> D1
    M1 -.-> D3
    M2 -.-> D3
    M3 -.-> D3
    M4 -.-> D3
    M5 -.-> D3
    P3 -.-> D4
    
    P4 --> A1
    P5 --> A1
    A1 --> A2
    A1 --> A3
    
    A2 --> U1
    A3 --> U1
    A3 --> U2
    A3 --> U3
    A3 --> U4
    
    style M1 fill:#EF4444,stroke:#DC2626,stroke-width:2px
    style M2 fill:#A855F7,stroke:#9333EA,stroke-width:2px
    style M3 fill:#10B981,stroke:#059669,stroke-width:2px
    style M4 fill:#F59E0B,stroke:#D97706,stroke-width:2px
    style M5 fill:#3B82F6,stroke:#2563EB,stroke-width:2px
```

### Key Architectural Decisions

**1. Microservices Architecture**
- **Rationale:** Enables independent scaling and deployment of components
- **Trade-offs:** Increased complexity vs. flexibility and maintainability
- **Implementation:** Docker containers with Kubernetes orchestration

**2. Parallel AI Processing**
- **Rationale:** Multiple models process frames simultaneously for comprehensive analysis
- **Trade-offs:** Higher computational cost vs. complete environmental awareness
- **Implementation:** GPU parallelization with batch processing

**3. Event-Driven Communication**
- **Rationale:** Decouples services and enables real-time responsiveness
- **Trade-offs:** Eventual consistency vs. immediate processing
- **Implementation:** Redis pub/sub with Celery task queue

---

## Architectural Patterns

### Design Patterns Used

#### 1. **Pipeline Pattern**
The system implements a pipeline pattern for sequential data processing:

```python
Frame → Detection → Projection → Assessment → Prediction → Alert
```

**Benefits:**
- Clear separation of concerns
- Easy to add/remove stages
- Parallel processing opportunities

#### 2. **Strategy Pattern**
Multiple detection strategies for different scenarios:

```python
class DetectionStrategy(ABC):
    @abstractmethod
    def detect(self, image):
        pass

class FireDetectionStrategy(DetectionStrategy):
    def detect(self, image):
        return yolov8_model.predict(image)

class SmokeDetectionStrategy(DetectionStrategy):
    def detect(self, image_sequence):
        return timesformer_model.predict(image_sequence)
```

**Benefits:**
- Swappable algorithms
- Easy testing and benchmarking
- Model versioning support

#### 3. **Observer Pattern**
Alert system observers monitor risk assessment changes:

```python
class RiskAssessmentSubject:
    def __init__(self):
        self._observers = []
    
    def attach(self, observer):
        self._observers.append(observer)
    
    def notify(self, risk_data):
        for observer in self._observers:
            observer.update(risk_data)
```

**Benefits:**
- Loose coupling between components
- Multiple alert channels
- Easy to add new notification methods

#### 4. **Factory Pattern**
Model factory for creating different AI model instances:

```python
class ModelFactory:
    @staticmethod
    def create_model(model_type, config):
        if model_type == "fire_detection":
            return FireDetectionModel(config)
        elif model_type == "smoke_detection":
            return SmokeDetectionModel(config)
        # ... more models
```

**Benefits:**
- Centralized model creation
- Configuration management
- Easy to extend with new models

---

## Component Architecture

### 1. Video Processing Pipeline

```mermaid
graph LR
    A[Video Stream] --> B[Frame Extractor]
    B --> C[Frame Buffer<br/>Queue]
    C --> D{Frame<br/>Dispatcher}
    D --> E[Fire Detection<br/>Worker]
    D --> F[Smoke Detection<br/>Worker]
    D --> G[Fauna Detection<br/>Worker]
    D --> H[Vegetation<br/>Worker]
    
    E --> I[Result<br/>Aggregator]
    F --> I
    G --> I
    H --> I
    
    I --> J[Geospatial<br/>Projection]
    J --> K[Risk<br/>Assessment]
    
    style C fill:#FFD700,stroke:#FFA500,stroke-width:2px
    style I fill:#90EE90,stroke:#32CD32,stroke-width:2px
```

**Frame Extractor:**
- Reads video at configurable frame rate (default: 30 FPS)
- Handles multiple stream formats (RTMP, HLS, MP4)
- Implements frame buffering for temporal models

**Frame Buffer Queue:**
- Redis-based FIFO queue
- Configurable buffer size (default: 30 frames)
- Supports temporal sequence extraction

**Model Workers:**
- Independent Celery workers per model
- GPU-accelerated inference
- Batch processing for efficiency

### 2. AI Inference Engine

```mermaid
graph TB
    subgraph "Inference Coordinator"
        IC[Model Manager]
        IC --> LC[Load Balancer]
    end
    
    subgraph "Model Instances"
        LC --> GPU1[GPU 0<br/>Fire + Smoke]
        LC --> GPU2[GPU 1<br/>Vegetation + Fauna]
        LC --> CPU[CPU<br/>Lightweight Tasks]
    end
    
    subgraph "Post-Processing"
        GPU1 --> NMS[Non-Max<br/>Suppression]
        GPU2 --> NMS
        NMS --> CF[Confidence<br/>Filtering]
        CF --> OUT[Detection<br/>Results]
    end
    
    style IC fill:#4169E1,stroke:#0000CD,stroke-width:2px
    style GPU1 fill:#FF6347,stroke:#DC143C,stroke-width:2px
    style GPU2 fill:#32CD32,stroke:#228B22,stroke-width:2px
```

**Model Manager Responsibilities:**
- Model loading and initialization
- GPU memory management
- Batch size optimization
- Fallback to CPU if GPU unavailable

**Load Balancer:**
- Distributes inference tasks across GPUs
- Monitors GPU utilization
- Dynamic batch sizing

### 3. Geospatial Processing System

```mermaid
graph TB
    subgraph "Input Data"
        I1[Detection<br/>Coordinates]
        I2[Camera<br/>Pose Data]
        I3[DEM<br/>Elevation]
    end
    
    subgraph "Coordinate Transformation"
        T1[Image to Camera<br/>Coordinate System]
        T2[Camera to World<br/>Coordinate System]
        T3[DEM Intersection<br/>Algorithm]
    end
    
    subgraph "Output Formats"
        O1[GeoJSON]
        O2[KML]
        O3[Shapefile]
        O4[CSV]
    end
    
    I1 --> T1
    I2 --> T2
    I3 --> T3
    
    T1 --> T2
    T2 --> T3
    
    T3 --> O1
    T3 --> O2
    T3 --> O3
    T3 --> O4
    
    style T3 fill:#FFA500,stroke:#FF8C00,stroke-width:2px
```

**Transformation Pipeline:**

1. **Image to Camera Coordinates:**
   ```python
   X_camera = (x_pixel - cx) / fx
   Y_camera = (y_pixel - cy) / fy
   Z_camera = 1  # normalized
   ```

2. **Camera to World Coordinates:**
   ```python
   [X_world]   [R | t]   [X_camera]
   [Y_world] = [--|--] * [Y_camera]
   [Z_world]   [0 | 1]   [Z_camera]
   ```

3. **DEM Intersection:**
   - Ray-casting from camera through pixel
   - Intersection with terrain surface
   - Accurate ground position

---

## Data Flow Design

### Real-Time Processing Flow

```mermaid
sequenceDiagram
    participant D as Drone
    participant VS as Video Stream Handler
    participant FB as Frame Buffer
    participant IE as Inference Engine
    participant GP as Geospatial Processor
    participant RA as Risk Assessment
    participant FS as Fire Simulator
    participant AS as Alert System
    participant UI as Web Dashboard
    
    D->>VS: RTMP Stream (30 FPS)
    VS->>FB: Extract & Buffer Frames
    
    loop Every Frame
        FB->>IE: Dispatch Frame
        par Parallel AI Processing
            IE->>IE: Fire Detection (YOLOv8)
            IE->>IE: Smoke Analysis (TimeSFormer)
            IE->>IE: Vegetation Health (ResNet50)
            IE->>IE: Wildlife Tracking (CSRNet)
        end
        IE->>GP: Detection Results
    end
    
    GP->>GP: Transform to World Coordinates
    GP->>RA: Geospatial Detections
    RA->>RA: Calculate Risk Score
    
    alt Risk Score > Threshold
        RA->>FS: Trigger Fire Simulation
        FS->>FS: Predict Spread (Hybrid Model)
        FS->>AS: Prediction Results
        AS->>AS: Generate Alerts
        AS-->>UI: Push Real-time Update
        AS-->>D: Alert Emergency Services
    end
    
    RA-->>UI: Update Risk Map
```

### Batch Processing Flow

```mermaid
graph LR
    A[Input Videos] --> B[Video Queue]
    B --> C{Celery<br/>Worker Pool}
    
    C --> D1[Worker 1]
    C --> D2[Worker 2]
    C --> D3[Worker N]
    
    D1 --> E[Process Video]
    D2 --> E
    D3 --> E
    
    E --> F[Extract Frames]
    F --> G[AI Inference]
    G --> H[Geospatial Transform]
    H --> I[Save Results]
    
    I --> J[(Database)]
    I --> K[Export Files]
    
    style C fill:#FFD700,stroke:#FFA500,stroke-width:2px
    style G fill:#FF6347,stroke:#DC143C,stroke-width:2px
```

---

## AI Model Architecture

### 1. YOLOv8 Fire Detection

```mermaid
graph TB
    subgraph "Input Processing"
        I[640x640x3<br/>RGB Image] --> A[Preprocessing<br/>Normalization]
    end
    
    subgraph "Backbone - CSPDarknet"
        A --> B1[Conv Block 1<br/>3->64 channels]
        B1 --> B2[CSP Stage 1<br/>64->128]
        B2 --> B3[CSP Stage 2<br/>128->256]
        B3 --> B4[CSP Stage 3<br/>256->512]
        B4 --> B5[CSP Stage 4<br/>512->1024]
    end
    
    subgraph "Neck - PANet"
        B3 --> N1[P3: 256 ch]
        B4 --> N2[P4: 512 ch]
        B5 --> N3[P5: 1024 ch]
        
        N3 --> N2
        N2 --> N1
        N1 --> N2
        N2 --> N3
    end
    
    subgraph "Head - Detection"
        N1 --> H1[Small Objects<br/>80x80]
        N2 --> H2[Medium Objects<br/>40x40]
        N3 --> H3[Large Objects<br/>20x20]
    end
    
    subgraph "Output"
        H1 --> O[Bounding Boxes<br/>Class: Fire/Smoke<br/>Confidence Scores]
        H2 --> O
        H3 --> O
    end
    
    style B3 fill:#FF6347,stroke:#DC143C,stroke-width:2px
    style B4 fill:#FF6347,stroke:#DC143C,stroke-width:2px
    style B5 fill:#FF6347,stroke:#DC143C,stroke-width:2px
```

**Key Features:**
- **Multi-scale detection:** Detects fires at various distances
- **CSP connections:** Reduces computation while maintaining accuracy
- **PANet fusion:** Combines features from different scales

### 2. TimeSFormer Smoke Detection

```mermaid
graph LR
    subgraph "Input"
        I[8 Frames<br/>224x224x3] --> P[Patch<br/>Embedding]
    end
    
    subgraph "Transformer Encoder"
        P --> T1[Temporal<br/>Attention 1]
        T1 --> S1[Spatial<br/>Attention 1]
        S1 --> T2[Temporal<br/>Attention 2]
        T2 --> S2[Spatial<br/>Attention 2]
        S2 --> TN[... x12 blocks]
    end
    
    subgraph "Classification"
        TN --> GAP[Global Average<br/>Pooling]
        GAP --> FC[Fully Connected<br/>768 -> 2]
        FC --> SM[Softmax]
    end
    
    subgraph "Output"
        SM --> O[Smoke: Yes/No<br/>Confidence Score]
    end
    
    style T1 fill:#A855F7,stroke:#9333EA,stroke-width:2px
    style T2 fill:#A855F7,stroke:#9333EA,stroke-width:2px
```

**Divided Space-Time Attention:**
- Temporal attention across frames
- Spatial attention within frames
- Efficient computation vs. full 3D attention

### 3. ResNet50 + VARI Vegetation Health

```mermaid
graph TB
    subgraph "Input Preparation"
        RGB[RGB Image<br/>3 channels] --> VARI[VARI<br/>Computation]
        VARI --> CONCAT[Concatenate<br/>4 channels]
    end
    
    subgraph "Modified ResNet50"
        CONCAT --> C1[Conv1: 4->64<br/>Modified First Layer]
        C1 --> R1[Residual Block 1<br/>64->256]
        R1 --> R2[Residual Block 2<br/>256->512]
        R2 --> R3[Residual Block 3<br/>512->1024]
        R3 --> R4[Residual Block 4<br/>1024->2048]
    end
    
    subgraph "Classification Head"
        R4 --> GAP[Global Average<br/>Pooling]
        GAP --> FC[Fully Connected<br/>2048 -> 3]
        FC --> SM[Softmax]
    end
    
    subgraph "Output"
        SM --> O[Healthy / Dry / Burned<br/>Class Probabilities]
    end
    
    style C1 fill:#10B981,stroke:#059669,stroke-width:2px
    style VARI fill:#FFD700,stroke:#FFA500,stroke-width:2px
```

**VARI Enhancement:**
- Additional spectral information
- Sensitive to vegetation health
- Improves classification accuracy

### 4. Fire Spread Hybrid Model

```mermaid
graph TB
    subgraph "Inputs"
        I1[Current Fire State<br/>256x256]
        I2[Wind Data<br/>Speed + Direction]
        I3[Humidity]
        I4[Vegetation Density]
        I5[Terrain Slope]
    end
    
    subgraph "Physics Component"
        I1 --> P1[Cellular<br/>Automata]
        I2 --> P2[Spread<br/>Probability]
        I3 --> P2
        I4 --> P2
        I5 --> P2
        
        P2 --> P3[Fire<br/>Propagation]
        P1 --> P3
    end
    
    subgraph "Neural Component"
        I1 --> N1[Fire State<br/>Encoder]
        I2 --> N2[Environmental<br/>Encoder]
        I3 --> N2
        I4 --> N2
        I5 --> N2
        
        N1 --> N3[Feature<br/>Fusion]
        N2 --> N3
        N3 --> N4[CNN<br/>Decoder]
    end
    
    subgraph "Output Fusion"
        P3 --> F[Weighted<br/>Ensemble]
        N4 --> F
        F --> O1[Fire State t+1]
        F --> O2[Ignition Probability]
        F --> O3[Fire Intensity]
    end
    
    style P3 fill:#4169E1,stroke:#0000CD,stroke-width:2px
    style N4 fill:#FF6347,stroke:#DC143C,stroke-width:2px
    style F fill:#32CD32,stroke:#228B22,stroke-width:2px
```

**Hybrid Approach:**
- **Physics:** Interpretable, based on fire behavior science
- **Neural:** Data-driven, captures complex patterns
- **Ensemble:** Combines strengths of both approaches

---

## Geospatial System Design

### Coordinate Transformation Pipeline

```mermaid
graph TB
    subgraph "Input Data"
        I1[Pixel Coordinates<br/>x, y in image]
        I2[Camera Intrinsics<br/>fx, fy, cx, cy]
        I3[Camera Pose<br/>Position + Orientation]
        I4[DEM Data<br/>Elevation Grid]
    end
    
    subgraph "Transformation Steps"
        T1[Undistort Coordinates<br/>Remove lens distortion]
        T2[Image to Camera<br/>Normalized coordinates]
        T3[Camera to World<br/>Apply rotation + translation]
        T4[Ray-DEM Intersection<br/>Find ground point]
    end
    
    subgraph "Output"
        O1[Latitude]
        O2[Longitude]
        O3[Elevation]
    end
    
    I1 --> T1
    I2 --> T1
    I2 --> T2
    T1 --> T2
    I3 --> T3
    T2 --> T3
    I4 --> T4
    T3 --> T4
    
    T4 --> O1
    T4 --> O2
    T4 --> O3
    
    style T4 fill:#FFA500,stroke:#FF8C00,stroke-width:2px
```

### DEM Integration

**Digital Elevation Model Processing:**

1. **DEM Loading:**
   - GeoTIFF format support
   - 30m resolution (SRTM/USGS)
   - Spatial indexing for fast lookup

2. **Ray-Terrain Intersection:**
   ```python
   def intersect_ray_dem(ray_origin, ray_direction, dem):
       # Step along ray until terrain intersection
       step_size = 1.0  # meters
       max_distance = 10000  # meters
       
       for distance in range(0, max_distance, step_size):
           point = ray_origin + distance * ray_direction
           terrain_height = dem.get_elevation(point.lat, point.lon)
           
           if point.elevation <= terrain_height:
               return point  # Intersection found
       
       return None  # No intersection
   ```

3. **Accuracy Optimization:**
   - Binary search for precise intersection
   - Bilinear interpolation of DEM values
   - Error correction for GPS/IMU noise

---

## API Architecture

### RESTful API Design

```mermaid
graph TB
    subgraph "API Gateway"
        AG[FastAPI<br/>Application]
    end
    
    subgraph "Routers"
        R1[/detection<br/>Fire & Smoke]
        R2[/vegetation<br/>Health Monitoring]
        R3[/fauna<br/>Wildlife Tracking]
        R4[/simulation<br/>Fire Spread]
        R5[/alerts<br/>Alert Management]
        R6[/maps<br/>Geospatial Data]
    end
    
    subgraph "Services"
        S1[Detection<br/>Service]
        S2[Vegetation<br/>Service]
        S3[Fauna<br/>Service]
        S4[Simulation<br/>Service]
        S5[Alert<br/>Service]
        S6[Mapping<br/>Service]
    end
    
    subgraph "Data Access"
        D1[(PostgreSQL)]
        D2[(Redis)]
        D3[File Storage]
    end
    
    AG --> R1
    AG --> R2
    AG --> R3
    AG --> R4
    AG --> R5
    AG --> R6
    
    R1 --> S1
    R2 --> S2
    R3 --> S3
    R4 --> S4
    R5 --> S5
    R6 --> S6
    
    S1 --> D1
    S1 --> D2
    S2 --> D1
    S3 --> D1
    S4 --> D1
    S5 --> D1
    S5 --> D2
    S6 --> D1
    S6 --> D3
    
    style AG fill:#009688,stroke:#00796B,stroke-width:2px
```

### API Endpoints

**Detection Endpoints:**
```
POST   /api/v1/detection/fire          - Detect fire in image
POST   /api/v1/detection/smoke         - Analyze smoke in video
POST   /api/v1/detection/batch         - Batch processing
GET    /api/v1/detection/{id}          - Get detection results
```

**Vegetation Endpoints:**
```
POST   /api/v1/vegetation/analyze      - Analyze vegetation health
GET    /api/v1/vegetation/history      - Get historical data
GET    /api/v1/vegetation/risk-zones   - Get high-risk areas
```

**Simulation Endpoints:**
```
POST   /api/v1/simulation/predict      - Predict fire spread
GET    /api/v1/simulation/{id}         - Get simulation results
GET    /api/v1/simulation/parameters   - Get simulation config
```

**WebSocket Endpoints:**
```
WS     /ws/live-feed                   - Real-time detection stream
WS     /ws/alerts                      - Alert notifications
WS     /ws/simulation                  - Live simulation updates
```

---

## Database Schema

### PostgreSQL + PostGIS Schema

```sql
-- Detection Results Table
CREATE TABLE detections (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMPTZ NOT NULL,
    detection_type VARCHAR(50) NOT NULL,  -- fire, smoke, fauna, vegetation
    confidence FLOAT NOT NULL,
    location GEOGRAPHY(POINT, 4326),
    bounding_box GEOMETRY(POLYGON, 4326),
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_detections_location ON detections USING GIST(location);
CREATE INDEX idx_detections_timestamp ON detections(timestamp);
CREATE INDEX idx_detections_type ON detections(detection_type);

-- Fire Events Table
CREATE TABLE fire_events (
    id SERIAL PRIMARY KEY,
    start_time TIMESTAMPTZ NOT NULL,
    last_updated TIMESTAMPTZ NOT NULL,
    status VARCHAR(20) NOT NULL,  -- active, contained, extinguished
    perimeter GEOMETRY(POLYGON, 4326),
    severity INTEGER CHECK (severity >= 1 AND severity <= 5),
    estimated_area FLOAT,  -- square meters
    metadata JSONB
);

CREATE INDEX idx_fire_events_perimeter ON fire_events USING GIST(perimeter);

-- Risk Zones Table
CREATE TABLE risk_zones (
    id SERIAL PRIMARY KEY,
    zone_name VARCHAR(100),
    geometry GEOMETRY(POLYGON, 4326),
    risk_level INTEGER CHECK (risk_level >= 1 AND risk_level <= 5),
    vegetation_type VARCHAR(50),
    last_assessment TIMESTAMPTZ,
    factors JSONB
);

CREATE INDEX idx_risk_zones_geometry ON risk_zones USING GIST(geometry);

-- Fire Spread Predictions Table
CREATE TABLE fire_predictions (
    id SERIAL PRIMARY KEY,
    fire_event_id INTEGER REFERENCES fire_events(id),
    prediction_time TIMESTAMPTZ NOT NULL,
    time_offset INTEGER,  -- minutes into future
    predicted_perimeter GEOMETRY(POLYGON, 4326),
    confidence FLOAT,
    environmental_conditions JSONB
);

-- Alerts Table
CREATE TABLE alerts (
    id SERIAL PRIMARY KEY,
    alert_type VARCHAR(50) NOT NULL,
    severity INTEGER CHECK (severity >= 1 AND severity <= 5),
    location GEOGRAPHY(POINT, 4326),
    affected_area GEOMETRY(POLYGON, 4326),
    message TEXT,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    acknowledged_at TIMESTAMPTZ,
    resolved_at TIMESTAMPTZ
);

CREATE INDEX idx_alerts_location ON alerts USING GIST(location);
CREATE INDEX idx_alerts_created ON alerts(created_at);
```

### Redis Cache Structure

```
# Detection cache (TTL: 5 minutes)
detection:{id} -> JSON{
    "type": "fire",
    "confidence": 0.95,
    "location": [lat, lon],
    "timestamp": "2025-12-17T22:00:00Z"
}

# Frame buffer (FIFO queue)
frames:buffer -> QUEUE[frame1, frame2, ..., frameN]

# Model cache (TTL: 1 hour)
model:fire:predictions:{image_hash} -> JSON{...}

# Alert queue
alerts:pending -> QUEUE[alert1, alert2, ...]

# Session data (TTL: 1 day)
session:{session_id} -> JSON{...}
```

---

## Deployment Architecture

### Container Orchestration

```mermaid
graph TB
    subgraph "Kubernetes Cluster"
        subgraph "Ingress"
            ING[NGINX Ingress<br/>Load Balancer]
        end
        
        subgraph "API Pods"
            API1[FastAPI<br/>Pod 1]
            API2[FastAPI<br/>Pod 2]
            API3[FastAPI<br/>Pod N]
        end
        
        subgraph "Worker Pods"
            W1[Fire Detection<br/>GPU Worker]
            W2[Smoke Detection<br/>GPU Worker]
            W3[Vegetation<br/>GPU Worker]
            W4[Fauna<br/>GPU Worker]
            W5[Simulation<br/>GPU Worker]
        end
        
        subgraph "Storage"
            PV1[Models<br/>Persistent Volume]
            PV2[DEM Data<br/>Persistent Volume]
            PV3[Outputs<br/>Persistent Volume]
        end
        
        subgraph "Services"
            SVC1[PostgreSQL<br/>StatefulSet]
            SVC2[Redis<br/>StatefulSet]
        end
    end
    
    ING --> API1
    ING --> API2
    ING --> API3
    
    API1 --> W1
    API2 --> W2
    API3 --> W3
    API1 --> W4
    API2 --> W5
    
    W1 -.-> PV1
    W2 -.-> PV1
    W3 -.-> PV1
    W4 -.-> PV1
    W5 -.-> PV1
    
    W3 -.-> PV2
    W5 -.-> PV2
    
    API1 --> SVC1
    API2 --> SVC1
    API3 --> SVC1
    
    API1 --> SVC2
    API2 --> SVC2
    API3 --> SVC2
    
    style W1 fill:#FF6347,stroke:#DC143C,stroke-width:2px
    style W2 fill:#A855F7,stroke:#9333EA,stroke-width:2px
    style W3 fill:#10B981,stroke:#059669,stroke-width:2px
```

### Cloud Deployment (Azure)

```yaml
# Azure Resources
Resource Group: guira-production
  
Compute:
  - AKS Cluster (3 nodes)
    - Standard_NC12s_v3 (GPU nodes)
    - Standard_D8s_v3 (CPU nodes)
  
Storage:
  - Azure Blob Storage (model weights)
  - Azure Files (shared data)
  - Premium SSD (databases)
  
Database:
  - Azure Database for PostgreSQL
    - PostGIS extension enabled
    - Geo-replication
  
Cache:
  - Azure Cache for Redis
    - Standard tier
    - Persistence enabled
  
Networking:
  - Application Gateway
  - Virtual Network
  - Private Endpoints
```

---

## Security Architecture

### Authentication & Authorization

```mermaid
graph LR
    subgraph "Client"
        C[User/App]
    end
    
    subgraph "Auth Layer"
        A1[API Gateway]
        A2[JWT Validator]
        A3[Role Checker]
    end
    
    subgraph "Services"
        S1[Detection API]
        S2[Simulation API]
        S3[Admin API]
    end
    
    C --> A1
    A1 --> A2
    A2 --> A3
    
    A3 --> S1
    A3 --> S2
    A3 --> S3
    
    style A2 fill:#FFD700,stroke:#FFA500,stroke-width:2px
    style A3 fill:#FF6347,stroke:#DC143C,stroke-width:2px
```

**Security Measures:**

1. **API Authentication:**
   - JWT tokens with RS256 signing
   - Token expiration: 1 hour
   - Refresh tokens: 7 days

2. **Role-Based Access Control:**
   ```yaml
   Roles:
     - admin: Full system access
     - operator: Detection and simulation
     - viewer: Read-only access
     - api_client: Programmatic access
   ```

3. **Data Encryption:**
   - TLS 1.3 for data in transit
   - AES-256 for data at rest
   - Field-level encryption for sensitive data

4. **Network Security:**
   - Private subnets for databases
   - Security groups with minimal access
   - DDoS protection
   - Rate limiting

---

## Scalability Considerations

### Horizontal Scaling

**Auto-scaling Policies:**

```yaml
API Pods:
  Min replicas: 2
  Max replicas: 10
  Target CPU: 70%
  Target Memory: 80%
  Scale up: +2 pods when threshold exceeded for 2 min
  Scale down: -1 pod when under threshold for 5 min

GPU Workers:
  Min replicas: 1
  Max replicas: 5
  Target GPU: 85%
  Scale based on queue length
```

### Vertical Scaling

**Resource Allocation:**

```yaml
API Pod:
  CPU: 2-4 cores
  Memory: 4-8 GB
  
Fire Detection Worker:
  CPU: 4 cores
  Memory: 16 GB
  GPU: 1x NVIDIA T4/V100
  
Smoke Detection Worker:
  CPU: 4 cores
  Memory: 24 GB
  GPU: 1x NVIDIA V100
```

### Performance Optimization

**Optimization Strategies:**

1. **Model Optimization:**
   - TensorRT for inference acceleration
   - ONNX runtime for cross-platform
   - Quantization (FP16/INT8)

2. **Caching:**
   - Redis for frequently accessed data
   - CDN for static assets
   - Model prediction caching

3. **Database Optimization:**
   - Read replicas for queries
   - Connection pooling
   - Spatial indexing
   - Query optimization

4. **Batch Processing:**
   - Group similar requests
   - Dynamic batch sizing
   - Asynchronous processing

---

## Technology Decisions & Trade-offs

### Key Decisions

**1. PyTorch over TensorFlow**
- ✅ More flexible for research
- ✅ Better debugging experience
- ✅ Strong community support
- ❌ Slower deployment historically (improved with TorchScript)

**2. PostgreSQL + PostGIS over MongoDB**
- ✅ Strong geospatial capabilities
- ✅ ACID compliance
- ✅ Complex query support
- ❌ Requires careful schema design

**3. FastAPI over Flask/Django**
- ✅ Built-in async support
- ✅ Automatic API documentation
- ✅ Type hints and validation
- ❌ Newer ecosystem

**4. Kubernetes over Docker Swarm**
- ✅ Industry standard
- ✅ Rich ecosystem
- ✅ Better scaling capabilities
- ❌ Higher complexity

---

<div align="center">

**Architecture Version:** 0.4.0  
**Last Updated:** December 2025  
**Status:** Research & Testing

*This architecture document is actively maintained and updated as the system evolves.*

</div>
