# System Architecture Overview

## Table of Contents
- [Introduction](#introduction)
- [High-Level Architecture](#high-level-architecture)
- [Core Components](#core-components)
- [Data Flow](#data-flow)
- [Technology Stack](#technology-stack)
- [Deployment Architecture](#deployment-architecture)

## Introduction

Axolotl is a comprehensive AI-powered football analysis platform designed to track, analyze, and provide coaching feedback on player performance. The system combines computer vision, machine learning, 3D reconstruction, and biomechanics to deliver real-time and post-session analysis.

### Primary Objectives
- **Real-time Analysis**: Process live video streams to track player movements and performance
- **Performance Metrics**: Calculate comprehensive KPIs including speed, distance, technical skills
- **3D Visualization**: Reconstruct player movements in 3D space for detailed analysis
- **AI Coaching**: Provide intelligent, context-aware coaching recommendations
- **Training Planning**: Generate AI-powered training plans based on performance history

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Client Layer                             │
├──────────────────┬──────────────────┬───────────────────────────┤
│  Web Browser     │  Mobile App      │  Edge Devices             │
│  (React SPA)     │  (iOS/Android)   │  (Local Processing)       │
└────────┬─────────┴────────┬─────────┴────────┬──────────────────┘
         │                  │                  │
         │ HTTP/WebSocket   │ HTTP/WebSocket   │ HTTP/WebSocket
         │                  │                  │
┌────────▼──────────────────▼──────────────────▼──────────────────┐
│                     Application Layer                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌────────────────┐  ┌──────────────┐  ┌────────────────────┐  │
│  │  Flask Web     │  │   Worker     │  │   Redis Queue      │  │
│  │  Application   │◄─┤   Service    │◄─┤   & Cache          │  │
│  │  (Port 8080)   │  │   (GPU)      │  │   (Port 6379)      │  │
│  └────────┬───────┘  └──────────────┘  └────────────────────┘  │
│           │                                                       │
│  ┌────────▼───────────────────────────────────────────────────┐ │
│  │               API Blueprints (8 modules)                   │ │
│  ├────────────────────────────────────────────────────────────┤ │
│  │  • scan_bp        • feedback_bp     • live_bp             │ │
│  │  • calendar_bp    • dashboard_bp    • session_bp          │ │
│  │  • pairing_bp     • local_edge_bp                         │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Core Library Layer                        │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              AI/ML Processing Modules                     │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  Detection  │  Tracking  │  Pose Est.  │  Multiview      │  │
│  │  (YOLO)     │  (ByteTrack)│ (MediaPipe) │  (3D Recon)    │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  Biomechanics │ LLM/RAG  │  Web Ingest │  Capture       │  │
│  │  (SMPL)       │ (OpenAI) │  (Azure)    │  (Multi-cam)   │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Data Layer                                │
├─────────────────────────────────────────────────────────────────┤
│  ┌───────────────┐  ┌──────────────┐  ┌────────────────────┐  │
│  │  PostgreSQL/  │  │  Azure Blob  │  │  Azure Cognitive   │  │
│  │  SQLite DB    │  │  Storage     │  │  Search            │  │
│  └───────────────┘  └──────────────┘  └────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Core Components

### 1. Web Service (Flask Application)
**Location**: `app/backend/app.py`

The main Flask application serves as the API gateway and web server.

**Responsibilities**:
- HTTP/REST API endpoint handling
- WebSocket connections for real-time updates
- Static file serving (frontend assets)
- Session management and authentication
- Request routing to appropriate blueprints

**Key Features**:
- 8 modular blueprints for different functionalities
- SocketIO for real-time bidirectional communication
- CORS support for cross-origin requests
- Health check endpoints for monitoring

### 2. Worker Service
**Location**: `app/backend/worker.py`

Background task processor for CPU/GPU-intensive operations.

**Responsibilities**:
- Video processing and analysis
- SMPL model fitting
- 3D pose reconstruction
- Heavy computational tasks
- Async job processing via Redis queue

**Queue Types**:
- `smpl_jobs`: SMPL fitting tasks
- `video_processing`: Video analysis tasks
- `background_tasks`: General async operations

### 3. Frontend Application
**Location**: `app/frontend/`

Modern React/TypeScript single-page application built with Vite.

**Key Pages**:
- **Dashboard**: Performance overview and metrics
- **Live Analysis**: Real-time session tracking
- **Session List**: Historical session browser
- **Calendar**: Training planning and scheduling
- **Pairing**: Mobile device QR code pairing

**Technologies**:
- React 18 with TypeScript
- Vite for fast builds
- TailwindCSS for styling
- React Router for navigation
- Zustand for state management
- Socket.IO for real-time updates
- Three.js for 3D visualization

### 4. Core AI/ML Library
**Location**: `src/axolotl/`

Reusable Python modules for AI/ML operations.

#### Detection (`src/axolotl/detection/`)
- **Purpose**: Player and object detection
- **Model**: YOLOv8 (Ultralytics)
- **Output**: Bounding boxes, confidence scores, class labels

#### Tracking (`src/axolotl/tracking/`)
- **Purpose**: Multi-object tracking across frames
- **Algorithm**: ByteTrack
- **Output**: Unique player IDs, trajectories, tracking continuity

#### Pose Estimation (`src/axolotl/pose/`)
- **Purpose**: 2D/3D skeletal pose detection
- **Model**: MediaPipe Pose
- **Output**: 33 keypoint positions, visibility scores

#### Multiview (`src/axolotl/multiview/`)
- **Purpose**: 3D reconstruction from multiple camera views
- **Techniques**: Triangulation, camera calibration, epipolar geometry
- **Output**: 3D world coordinates from 2D projections

#### Biomechanics (`src/axolotl/biomech/`)
- **Purpose**: Advanced body modeling and kinematics
- **Model**: SMPL (Skinned Multi-Person Linear Model)
- **Output**: 3D mesh, joint angles, body shape parameters

#### LLM/RAG System (`src/axolotl/llm/`)
- **Purpose**: AI-powered coaching feedback and recommendations
- **Model**: Azure OpenAI (GPT models)
- **Features**: Context-aware suggestions, RAG with session history
- **Output**: Natural language coaching insights

#### Web Ingest (`src/axolotl/web_ingest/`)
- **Purpose**: Scrape and index web content for RAG
- **Storage**: Azure Cognitive Search
- **Use Case**: Enrich coaching feedback with external knowledge

#### Capture (`src/axolotl/capture/`)
- **Purpose**: Multi-camera synchronization and capture
- **Features**: Hardware triggering, timestamp alignment
- **Use Case**: Synchronized multi-view recording

### 5. API Blueprints

#### Scan Blueprint (`scan_bp`)
**Endpoints**: `/api/scan/*`
- Video upload and processing
- Session creation and analysis
- KPI calculation and retrieval

#### Feedback Blueprint (`feedback_bp`)
**Endpoints**: `/api/feedback/*`
- AI-powered coaching feedback generation
- Context-aware recommendations using RAG
- Feedback history retrieval

#### Live Blueprint (`live_bp`)
**Endpoints**: `/api/live/*`
- Real-time session tracking
- WebSocket connections for live updates
- Stream ingestion and processing

#### Calendar Blueprint (`calendar_bp`)
**Endpoints**: `/api/calendar/*`
- Training event CRUD operations
- AI-powered training recommendations
- WebSocket updates for real-time calendar sync

#### Dashboard Blueprint (`dashboard_bp`)
**Endpoints**: `/api/dashboard/*`
- Performance metrics aggregation
- Player statistics and trends
- Visualization data preparation

#### Session Blueprint (`session_bp`)
**Endpoints**: `/api/session/*`
- Session management (CRUD)
- Session metadata and attachments
- Historical session queries

#### Pairing Blueprint (`pairing_bp`)
**Endpoints**: `/api/pairing/*`
- QR code generation for device pairing
- Mobile app synchronization
- Device authentication and authorization

#### Local Edge Blueprint (`local_edge_bp`)
**Endpoints**: `/api/local-edge/*`
- Edge device communication
- Local processing coordination
- Offline mode support

## Data Flow

### 1. Video Upload and Analysis Flow
```
User Upload → scan_bp → Redis Queue → Worker
                                        ↓
                                   Detection
                                        ↓
                                    Tracking
                                        ↓
                                  Pose Estimation
                                        ↓
                                 KPI Calculation
                                        ↓
                          Database Storage ← scan_bp
                                        ↓
                              Frontend Dashboard
```

### 2. Real-Time Analysis Flow
```
Live Camera → WebSocket → live_bp → Frame Buffer
                                          ↓
                                    Detection/Tracking
                                          ↓
                                   Real-time Metrics
                                          ↓
                          WebSocket Broadcast → Frontend
```

### 3. AI Feedback Generation Flow
```
User Request → feedback_bp → RAG System
                                  ↓
                        Session History Query
                                  ↓
                        Azure Cognitive Search
                                  ↓
                            Context Building
                                  ↓
                          Azure OpenAI (GPT)
                                  ↓
                       Structured Feedback
                                  ↓
                         Database Storage
                                  ↓
                            Frontend Display
```

### 4. Training Planning Flow
```
User Request → calendar_bp → Rules Engine
                                   ↓
                          Performance History
                                   ↓
                        AI Recommendation Engine
                                   ↓
                         Safety Validation
                                   ↓
                        Training Plan Creation
                                   ↓
                    WebSocket Broadcast → Frontend
```

## Technology Stack

### Backend
| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| Web Framework | Flask | 3.0+ | HTTP server & API |
| ASGI Server | Uvicorn | 0.20+ | Production server |
| Task Queue | Redis | 7.x | Background jobs |
| WebSocket | Flask-SocketIO | Latest | Real-time communication |
| ORM | SQLAlchemy | 1.4+ | Database abstraction |
| Database | PostgreSQL/SQLite | 15/3.x | Data persistence |

### AI/ML
| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| Deep Learning | PyTorch | 1.12+ | Neural networks |
| Computer Vision | OpenCV | 4.5+ | Image processing |
| Object Detection | YOLO (Ultralytics) | 8.0+ | Player detection |
| Pose Estimation | MediaPipe | 0.9+ | Skeletal tracking |
| Body Modeling | Custom SMPL | - | 3D body mesh |
| LLM | Azure OpenAI | 1.0+ | AI feedback |
| Embeddings | Sentence Transformers | 2.2+ | Text embeddings |

### Frontend
| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| Framework | React | 18.x | UI library |
| Language | TypeScript | 5.x | Type safety |
| Build Tool | Vite | 4.x | Fast builds |
| Styling | TailwindCSS | 3.x | Utility CSS |
| State | Zustand | 4.x | State management |
| Router | React Router | 6.x | Navigation |
| 3D Graphics | Three.js + R3F | 0.157+ | 3D visualization |
| UI Components | Lucide React | 0.290+ | Icons |
| Charts | Recharts | 2.8+ | Data visualization |
| Calendar | FullCalendar | 6.1+ | Event scheduling |

### Infrastructure
| Component | Technology | Purpose |
|-----------|-----------|---------|
| Containerization | Docker | Application packaging |
| Orchestration | Docker Compose | Local development |
| Production | Kubernetes | Cloud deployment |
| Cloud Provider | Azure | Hosting & services |
| Storage | Azure Blob | Video/file storage |
| Search | Azure Cognitive Search | RAG system |
| CI/CD | GitHub Actions | Automation |

## Deployment Architecture

### Local Development
```
Docker Compose
├── Redis Container (6379)
├── Web Container (8080)
│   ├── Flask App
│   └── Static Frontend
└── Worker Container
    └── GPU Processing
```

### Production (Azure)
```
Azure Kubernetes Service (AKS)
├── Ingress Controller (HTTPS/443)
├── Web Pods (3+ replicas)
│   └── Load Balanced
├── Worker Pods (GPU nodes)
├── Redis Cache
└── Azure Services
    ├── PostgreSQL (Managed)
    ├── Blob Storage
    ├── Cognitive Search
    └── OpenAI Service
```

### Edge Deployment
```
Local Network
├── Edge Device (Raspberry Pi/NUC)
│   ├── Lightweight Processing
│   ├── Camera Capture
│   └── Local Storage
└── Optional Cloud Sync
```

## Security Considerations

### Authentication & Authorization
- API key-based authentication
- Device pairing via secure QR codes
- Session-based user authentication
- Role-based access control (future)

### Data Protection
- HTTPS for all communications
- Environment-based secrets management
- No credentials in code or version control
- Azure Key Vault for production secrets

### Input Validation
- File upload validation (size, type)
- Request parameter sanitization
- CORS configuration
- Rate limiting (future)

## Scalability

### Horizontal Scaling
- Stateless web service (multiple replicas)
- Redis-backed session storage
- Load balancer distribution

### Vertical Scaling
- GPU nodes for worker service
- Database connection pooling
- Caching strategy (Redis)

### Performance Optimization
- Frontend code splitting
- Lazy loading of components
- Video streaming (not full download)
- Background job processing
- Database query optimization

## Monitoring & Observability

### Health Checks
- `/health` endpoints on all services
- Redis health monitoring
- Database connection checks

### Logging
- Structured logging throughout
- Log levels (DEBUG, INFO, WARNING, ERROR)
- Centralized log aggregation (future)

### Metrics
- Request/response times
- Job queue lengths
- Video processing duration
- Error rates

## Future Architecture Enhancements

### Planned Improvements
1. **Microservices**: Split into independent services
2. **Event Sourcing**: Event-driven architecture
3. **GraphQL**: Alternative to REST API
4. **Service Mesh**: Istio for service communication
5. **ML Pipeline**: MLOps for model management
6. **Real-time Analytics**: Stream processing with Kafka
7. **Multi-tenancy**: Support for multiple organizations

### Scalability Roadmap
- Auto-scaling based on load
- Multi-region deployment
- CDN for static assets
- Database sharding
- Caching layer expansion

## Related Documentation

- [Backend Architecture Details](backend.md)
- [Frontend Architecture Details](frontend.md)
- [Database Schema](database.md)
- [API Reference](api-reference.md)
- [Deployment Guide](../deployment/production.md)
- [Development Guide](../development/contributing.md)
