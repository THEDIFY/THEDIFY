# Repository Structure Guide

## Table of Contents
- [Introduction](#introduction)
- [Repository Overview](#repository-overview)
- [Directory Structure](#directory-structure)
- [Key Directories Explained](#key-directories-explained)
- [File Organization Principles](#file-organization-principles)
- [Where to Find Things](#where-to-find-things)
- [Where to Add New Code](#where-to-add-new-code)

## Introduction

This guide provides a comprehensive overview of how the Axolotl repository is organized. Understanding this structure will help you navigate the codebase efficiently and know where to place new code.

**Last Updated**: Phase 10.1 Completion (October 2025)  
**Structure Version**: 2.0 (Post-Cleanup)

## Repository Overview

The Axolotl repository follows a modular, domain-driven structure with clear separation between:
- **Application code** (`app/`) - The main web application
- **Core library** (`src/axolotl/`) - Reusable AI/ML modules
- **Tests** (`tests/`) - All testing code
- **Documentation** (`documentation/`) - Comprehensive guides
- **Infrastructure** (`docker/`, `infra/`, `scripts/`) - Deployment and tooling
- **Examples** (`examples/`) - Demo scripts and usage examples

## Directory Structure

```
axolotl/
├── 📄 Configuration Files (Root)
│   ├── README.md                    # Main project overview
│   ├── REPOSITORY_STRUCTURE.md      # This structure summary
│   ├── LICENSE                      # Project license
│   ├── requirements.txt             # Python dependencies
│   ├── setup.py                     # Package setup configuration
│   ├── pytest.ini                   # Test configuration
│   ├── docker-compose.yml           # Docker services definition
│   ├── .gitignore                   # Git ignore rules
│   ├── .env.example                 # Environment template
│   └── .env.local.example           # Local environment template
│
├── 🏗️ Main Application (app/)
│   ├── backend/                     # Flask REST API
│   │   ├── app.py                   # Flask app entry point
│   │   ├── worker.py                # Background worker
│   │   ├── blueprints/              # API route modules (8 blueprints)
│   │   │   ├── scan_bp.py           # Video scanning & analysis
│   │   │   ├── feedback_bp.py       # AI coaching feedback
│   │   │   ├── live_bp.py           # Real-time analysis
│   │   │   ├── calendar_bp.py       # Training planning
│   │   │   ├── dashboard_bp.py      # Performance metrics
│   │   │   ├── session_bp.py        # Session management
│   │   │   ├── pairing_bp.py        # Device pairing
│   │   │   └── local_edge_bp.py     # Edge device communication
│   │   ├── services/                # Business logic layer (11 services)
│   │   │   ├── auth_utils.py        # Authentication
│   │   │   ├── calendar_service.py  # Calendar logic
│   │   │   ├── kpi_calculator.py    # Performance metrics
│   │   │   ├── live_processor.py    # Live stream processing
│   │   │   ├── multiview_recon.py   # 3D reconstruction
│   │   │   ├── pairing_service.py   # Device pairing logic
│   │   │   ├── rules_engine.py      # Training safety rules
│   │   │   └── ...                  # More services
│   │   ├── static/                  # Frontend build output
│   │   └── templates/               # HTML templates
│   │
│   └── frontend/                    # React/TypeScript SPA
│       ├── src/                     # Source code
│       │   ├── components/          # React components
│       │   ├── pages/               # Page components
│       │   ├── hooks/               # Custom hooks
│       │   ├── stores/              # State management (Zustand)
│       │   ├── types/               # TypeScript definitions
│       │   ├── utils/               # Utility functions
│       │   ├── styles/              # Global styles
│       │   ├── App.tsx              # Root component
│       │   └── main.tsx             # Entry point
│       ├── package.json             # Node dependencies
│       ├── vite.config.ts           # Vite build config
│       ├── tsconfig.json            # TypeScript config
│       └── tailwind.config.js       # Tailwind CSS config
│
├── 🐍 Core Library (src/axolotl/)
│   ├── __init__.py                  # Package initialization
│   ├── config.py                    # Core configuration
│   ├── rag_schema_utils.py          # RAG utilities
│   │
│   ├── detection/                   # Object detection (YOLO)
│   │   ├── __init__.py
│   │   ├── detector.py              # Main detector class
│   │   └── README.md                # Module documentation
│   │
│   ├── tracking/                    # Multi-object tracking (ByteTrack)
│   │   ├── __init__.py
│   │   ├── byte_tracker.py          # Tracker implementation
│   │   └── README.md
│   │
│   ├── pose/                        # Pose estimation (MediaPipe)
│   │   ├── __init__.py
│   │   ├── estimator.py             # Pose estimator
│   │   └── README.md
│   │
│   ├── multiview/                   # 3D reconstruction
│   │   ├── __init__.py
│   │   ├── triangulate.py           # Triangulation algorithms
│   │   ├── calibration.py           # Camera calibration
│   │   └── README.md
│   │
│   ├── biomech/                     # Biomechanics (SMPL)
│   │   ├── __init__.py
│   │   ├── smpl_fitter.py           # SMPL model fitting
│   │   └── README.md
│   │
│   ├── llm/                         # LLM & RAG system
│   │   ├── __init__.py
│   │   ├── feedback_engine.py       # Coaching feedback
│   │   ├── recommendation.py        # Training recommendations
│   │   ├── templates/               # Prompt templates
│   │   └── README.md
│   │
│   ├── web_ingest/                  # Web content retrieval
│   │   ├── __init__.py
│   │   ├── scraper.py               # Content scraping
│   │   └── indexer.py               # Search indexing
│   │
│   ├── capture/                     # Multi-camera capture
│   │   ├── __init__.py
│   │   └── sync_capture.py          # Synchronized capture
│   │
│   ├── calibration/                 # Camera calibration tools
│   │   └── __init__.py
│   │
│   └── api/                         # API utilities
│       └── __init__.py
│
├── 🧪 Testing (tests/)
│   ├── integration/                 # Integration tests (11 files)
│   │   ├── test_calendar_api.py     # Calendar endpoint tests
│   │   ├── test_feedback_api.py     # Feedback endpoint tests
│   │   ├── test_live_analysis.py    # Live analysis tests
│   │   ├── test_scan_api.py         # Scan endpoint tests
│   │   └── ...
│   │
│   ├── unit/                        # Unit tests (2 files)
│   │   ├── test_kpi_calculator.py   # KPI calculation tests
│   │   └── test_rules_engine.py     # Rules engine tests
│   │
│   ├── e2e/                         # End-to-end tests
│   │   ├── test_full_workflow.py    # Complete user workflows
│   │   └── data/                    # E2E test data
│   │
│   ├── ui/                          # UI tests
│   │   └── lighthouse_check.js      # Performance tests
│   │
│   ├── frontend/                    # Frontend tests
│   │   └── setup.ts                 # Test setup
│   │
│   └── data/                        # Test data
│       ├── sample_frames/           # Test images
│       ├── sample_sessions/         # Test session data
│       └── mocks/                   # Mock data
│
├── 📚 Documentation (documentation/)
│   ├── README.md                    # Documentation index
│   │
│   ├── getting-started/             # Quick start guides
│   │   ├── quick-start.md           # Fast setup with Docker
│   │   ├── configuration.md         # Environment setup
│   │   └── troubleshooting.md       # Common issues
│   │
│   ├── architecture/                # System design (NEW)
│   │   ├── overview.md              # System architecture
│   │   ├── backend.md               # Backend details
│   │   ├── frontend.md              # Frontend details
│   │   ├── database.md              # Database schema
│   │   └── api-reference.md         # Complete API docs
│   │
│   ├── features/                    # Feature guides (5 docs)
│   │   ├── ai-feedback.md           # AI coaching feedback
│   │   ├── calendar-planning.md     # Training calendar
│   │   ├── mobile-pairing.md        # Device pairing
│   │   └── session-history.md       # Session management
│   │
│   ├── ai-ml/                       # AI/ML documentation (7 docs)
│   │   ├── models.md                # Model overview
│   │   ├── detection.md             # Object detection
│   │   ├── tracking.md              # Multi-object tracking
│   │   ├── pose.md                  # Pose estimation
│   │   ├── event-spotting.md        # Event detection
│   │   ├── rag-system.md            # RAG implementation
│   │   └── training.md              # Model training
│   │
│   ├── development/                 # Developer guides (3 docs)
│   │   ├── contributing.md          # How to contribute (TODO)
│   │   ├── testing.md               # Testing guide
│   │   ├── ci-cd.md                 # CI/CD pipeline
│   │   └── docker.md                # Docker development
│   │
│   ├── deployment/                  # Deployment guides (2 docs)
│   │   ├── production.md            # Production deployment
│   │   └── local-edge.md            # Edge deployment
│   │
│   └── archive/                     # Historical docs
│       └── implementation-notes/    # Implementation tracking
│
├── 📝 Examples & Demos (examples/)
│   ├── demos/                       # Demo scripts (8 files)
│   │   ├── README.md                # Demo documentation
│   │   ├── demo_detection.py        # Detection demo
│   │   ├── demo_tracking.py         # Tracking demo
│   │   ├── demo_pose.py             # Pose estimation demo
│   │   ├── demo_multiview.py        # 3D reconstruction demo
│   │   └── ...
│   │
│   ├── coaching_feedback_example.py # Feedback generation example
│   ├── live_client_example.py       # Live streaming example
│   ├── event_spotting_usage.md      # Event spotting guide
│   └── opensim_models/              # OpenSim examples
│       └── README.md
│
├── 🐳 Infrastructure (docker/, infra/, scripts/)
│   ├── docker/                      # Docker configuration
│   │   ├── Dockerfile.prod          # Production Docker image
│   │   ├── README.md                # Docker documentation
│   │   └── k8s/                     # Kubernetes manifests
│   │
│   ├── infra/                       # Infrastructure as Code
│   │   └── bicep/                   # Azure Bicep templates
│   │       ├── main.bicep           # Main infrastructure
│   │       └── ...
│   │
│   ├── scripts/                     # Utility scripts (14 files)
│   │   ├── start.sh                 # Start application (Linux/Mac)
│   │   ├── start.ps1                # Start application (Windows)
│   │   ├── local_dev_up.sh          # Quick local setup
│   │   ├── run_local_edge.sh        # Edge device setup
│   │   ├── fit_smpl.py              # SMPL fitting script
│   │   ├── verify_all.sh            # Verification suite
│   │   └── ...
│   │
│   └── ci/                          # CI/CD configuration
│       └── checks/                  # CI check scripts
│
├── 🔧 Configuration (configs/, schemas/, migrations/)
│   ├── configs/                     # Application configs
│   │   └── ...
│   │
│   ├── schemas/                     # JSON schemas (4 files)
│   │   ├── training_session.schema.json
│   │   ├── match_segment.schema.json
│   │   ├── knowledge_base.schema.json
│   │   └── rag_registry.schema.json
│   │
│   ├── migrations/                  # Database migrations
│   │   └── ...
│   │
│   └── .github/                     # GitHub configuration
│       ├── workflows/               # GitHub Actions
│       └── copilot-instructions.md
│
├── 🎯 Feature Modules (Root Level)
│   ├── inference/                   # Event spotting inference
│   ├── ingest/                      # Session indexing pipeline
│   ├── vision/                      # Field mapping
│   ├── tracking/                    # ByteTrack standalone
│   ├── multiview/                   # Multi-camera standalone
│   ├── biomech/                     # Biomechanics examples
│   ├── poses/                       # Pose data storage (.gitignored)
│   ├── models/                      # Model storage
│   ├── mobile_client/               # Mobile app integration
│   ├── checks/                      # Phase validation checks
│   ├── dev/                         # Development utilities
│   └── tools/                       # Additional tools
│
├── 📊 Data & Notebooks (notebooks/)
│   ├── field_mapping_demo.ipynb     # Field mapping demo
│   ├── kinematics_examples.ipynb    # Kinematics analysis
│   └── triangulation_test.ipynb     # 3D triangulation
│
└── 💾 Runtime Directories (Git-Ignored)
    ├── storage/                     # File storage (.gitkeep only)
    ├── output_videos/               # Processed videos (.gitkeep only)
    ├── poses/                       # Pose data (.gitkeep only)
    ├── reports/                     # Test reports (.gitkeep only)
    ├── data/                        # Database files (local dev)
    └── logs/                        # Application logs
```

## Key Directories Explained

### Application (`app/`)

**Purpose**: Main web application with frontend and backend

**Structure**:
- `backend/` - Flask REST API server
  - `app.py` - Main Flask application
  - `worker.py` - Background job processor
  - `blueprints/` - 8 API modules (scan, feedback, live, calendar, dashboard, session, pairing, local_edge)
  - `services/` - 11 business logic services
  - `static/` - Frontend build output (auto-generated)
  - `templates/` - HTML templates

- `frontend/` - React/TypeScript SPA
  - `src/` - All source code
  - Build configuration (Vite, TypeScript, Tailwind)

**When to use**: All application-level code belongs here

### Core Library (`src/axolotl/`)

**Purpose**: Reusable AI/ML modules that can be imported by any part of the system

**Modules**:
- `detection/` - YOLO-based player detection
- `tracking/` - ByteTrack multi-object tracking
- `pose/` - MediaPipe pose estimation
- `multiview/` - 3D reconstruction and triangulation
- `biomech/` - SMPL body model fitting
- `llm/` - LLM and RAG system
- `web_ingest/` - Web scraping and indexing
- `capture/` - Multi-camera synchronization
- `calibration/` - Camera calibration tools

**When to use**: Place domain-specific AI/ML code here that could be reused across multiple parts of the application

### Tests (`tests/`)

**Purpose**: All testing code organized by test type

**Structure**:
- `integration/` - API endpoint tests, workflow tests
- `unit/` - Component unit tests
- `e2e/` - End-to-end user scenario tests
- `ui/` - UI performance and accessibility tests
- `frontend/` - Frontend component tests
- `data/` - Test fixtures and sample data

**When to use**: All test files go here, organized by type

### Documentation (`documentation/`)

**Purpose**: Centralized documentation hub

**Structure**:
- `getting-started/` - Installation, configuration, troubleshooting
- `architecture/` - System design, API reference, database schema
- `features/` - Feature-specific user guides
- `ai-ml/` - AI/ML model documentation
- `development/` - Contributing guides, testing, CI/CD
- `deployment/` - Production deployment guides
- `archive/` - Historical implementation notes

**When to use**: All user-facing and developer documentation

### Examples (`examples/`)

**Purpose**: Demo scripts and usage examples

**Structure**:
- `demos/` - 8 standalone demo scripts with README
- Individual example files showing API usage
- OpenSim model examples

**When to use**: Example code demonstrating how to use features

### Infrastructure

**Docker** (`docker/`):
- Dockerfile.prod - Production container
- k8s/ - Kubernetes manifests

**Scripts** (`scripts/`):
- Startup scripts (start.sh, start.ps1)
- Utility scripts (SMPL fitting, validation)
- Verification and testing scripts

**Infra** (`infra/`):
- Azure Bicep templates for cloud deployment

## File Organization Principles

### 1. Single Source of Truth

- **Backend**: `app/backend/` is THE backend (no old `backend/` folder)
- **Frontend**: `app/frontend/` is THE frontend (no old `frontend/` folder)
- **Tests**: `tests/` contains ALL tests (none in root)
- **Docs**: `documentation/` contains ALL docs (none scattered in root)

### 2. Modular Organization

Each major component is self-contained:
- Each blueprint has its own file in `app/backend/blueprints/`
- Each service has its own file in `app/backend/services/`
- Each AI module has its own directory in `src/axolotl/`
- Each test type has its own directory in `tests/`

### 3. README Pattern

Important directories contain README files:
- `documentation/README.md` - Documentation index
- `examples/demos/README.md` - Demo guide
- Each `src/axolotl/*/` module has a README
- Each blueprint has documentation (README_*.md)

### 4. Configuration

All configuration at root level:
- `.env.example` - Environment template
- `docker-compose.yml` - Service orchestration
- `requirements.txt` - Python dependencies
- `setup.py` - Package setup

### 5. Git Ignore Strategy

Runtime-generated content is ignored:
- `storage/`, `output_videos/`, `poses/`, `reports/`
- `data/`, `logs/`
- Build outputs (`dist/`, `build/`, `node_modules/`)
- Frontend build (`app/backend/static/`)
- Large model files (`models/*.pt`, `models/*.pth`)

## Where to Find Things

### I want to...

**Run the application**
→ `README.md` → Quick Start section

**Add a new API endpoint**
→ `app/backend/blueprints/` → Add route to appropriate blueprint

**Add business logic**
→ `app/backend/services/` → Create or modify service

**Add a frontend component**
→ `app/frontend/src/components/` → Create component file

**Add a new page**
→ `app/frontend/src/pages/` → Create page component

**Add AI/ML functionality**
→ `src/axolotl/` → Create or modify module

**Write tests**
→ `tests/` → Add to appropriate test type directory

**Add documentation**
→ `documentation/` → Add to appropriate category

**Create a demo**
→ `examples/demos/` → Add demo script

**Configure deployment**
→ `docker/` or `infra/` → Modify deployment configs

**Add a utility script**
→ `scripts/` → Add script file

**Define data schema**
→ `schemas/` → Add JSON schema file

## Where to Add New Code

### New API Feature

1. **Backend Route**: `app/backend/blueprints/feature_bp.py`
2. **Business Logic**: `app/backend/services/feature_service.py`
3. **Frontend Page**: `app/frontend/src/pages/FeaturePage.tsx`
4. **Frontend Components**: `app/frontend/src/components/Feature*.tsx`
5. **Tests**: `tests/integration/test_feature_api.py`
6. **Documentation**: `documentation/features/feature-name.md`

### New AI/ML Model

1. **Core Module**: `src/axolotl/model_name/`
   - `__init__.py`
   - `model.py`
   - `README.md`
2. **Integration**: `app/backend/services/` - Service using the model
3. **Tests**: `tests/unit/test_model_name.py`
4. **Documentation**: `documentation/ai-ml/model-name.md`
5. **Demo**: `examples/demos/demo_model_name.py`

### Database Change

1. **Migration**: Create migration in `migrations/`
2. **Model**: Update model in `app/backend/models.py`
3. **Schema Doc**: Update `documentation/architecture/database.md`

### Frontend Feature

1. **Component**: `app/frontend/src/components/FeatureName.tsx`
2. **Page** (if needed): `app/frontend/src/pages/FeaturePage.tsx`
3. **State** (if needed): `app/frontend/src/stores/featureStore.ts`
4. **Types**: `app/frontend/src/types/feature.ts`
5. **Tests**: `app/frontend/src/test/FeatureName.test.tsx`

### Documentation

1. **User Guide**: `documentation/features/feature-name.md`
2. **API Docs**: `documentation/architecture/api-reference.md`
3. **Architecture**: `documentation/architecture/overview.md` (if architectural change)
4. **Development**: `documentation/development/` (if dev process change)

## Navigation Checklist

Use this checklist when working with the codebase:

- [ ] I know which blueprint handles my feature → `app/backend/blueprints/`
- [ ] I know which service contains the business logic → `app/backend/services/`
- [ ] I know where the frontend component is → `app/frontend/src/components/`
- [ ] I know where the AI module lives → `src/axolotl/`
- [ ] I know where to add tests → `tests/`
- [ ] I know where documentation goes → `documentation/`
- [ ] I checked if similar code already exists
- [ ] I know what's git-ignored → `.gitignore`

## Import Patterns

### Backend Imports

```python
# Correct (use app.backend)
from app.backend.blueprints.scan_bp import scan_bp
from app.backend.services.kpi_calculator import calculate_kpis
from app.backend.worker import submit_smpl_job

# Core library imports
from src.axolotl.llm.feedback_engine import FeedbackEngine
from src.axolotl.multiview.triangulate import triangulate_points
from src.axolotl.detection.detector import YOLODetector
```

### Frontend Imports

```typescript
// Component imports (using @ alias)
import { Dashboard } from '@/components/Dashboard'
import { LiveAnalysis } from '@/pages/LiveAnalysis'
import { useWebSocket } from '@/hooks/useWebSocket'
import { useSessionStore } from '@/stores/sessionStore'
import { api } from '@/utils/api'
```

## Related Documentation

- [Main README](../README.md) - Project overview
- [Architecture Overview](architecture/overview.md) - System design
- [Backend Architecture](architecture/backend.md) - Backend details
- [Frontend Architecture](architecture/frontend.md) - Frontend details
- [Contributing Guide](development/contributing.md) - How to contribute
- [Quick Start](getting-started/quick-start.md) - Getting started
