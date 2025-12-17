# Newcomer Onboarding Guide

Welcome to the Axolotl Football Analysis Platform! This guide will help you get up to speed with the project, whether you're a new contributor, team member, or just exploring the codebase.

## Table of Contents
- [Welcome](#welcome)
- [What is Axolotl?](#what-is-axolotl)
- [First Steps](#first-steps)
- [Understanding the System](#understanding-the-system)
- [Development Setup](#development-setup)
- [Your First Contribution](#your-first-contribution)
- [Key Concepts](#key-concepts)
- [Workflow Guide](#workflow-guide)
- [Getting Help](#getting-help)
- [Learning Resources](#learning-resources)

## Welcome

👋 Welcome to Axolotl! We're excited to have you here. This guide will take you from zero to productive contributor in a structured way.

**Time Investment**: 
- Quick Start: 30 minutes
- Full Onboarding: 2-3 hours
- Comfortable Contributing: 1-2 weeks

## What is Axolotl?

### Project Overview

Axolotl is an AI-powered football (soccer) analysis platform designed to help coaches, analysts, and players improve performance through:

- **Video Analysis**: Automated processing of training and match videos
- **Performance Metrics**: Comprehensive KPI tracking (speed, distance, technical skills)
- **3D Visualization**: Player movement reconstruction in 3D space
- **AI Coaching**: Intelligent, context-aware feedback and recommendations
- **Training Planning**: AI-powered training schedule generation
- **Real-time Tracking**: Live analysis during training sessions

### Technology Stack

**Backend**:
- Flask (Python web framework)
- PyTorch (Deep learning)
- YOLO (Object detection)
- MediaPipe (Pose estimation)
- Azure OpenAI (AI coaching)
- PostgreSQL/SQLite (Database)
- Redis (Task queue)

**Frontend**:
- React 18 + TypeScript
- Vite (Build tool)
- TailwindCSS (Styling)
- Three.js (3D graphics)
- Socket.IO (Real-time)

**Infrastructure**:
- Docker + Docker Compose
- Azure (Cloud platform)
- Kubernetes (Production)
- GitHub Actions (CI/CD)

### Project Goals

1. **Accessibility**: Make professional sports analysis accessible to grassroots clubs
2. **Intelligence**: Leverage AI to provide insights previously requiring expert analysts
3. **Real-time**: Enable live feedback during training sessions
4. **Comprehensive**: Cover technical, physical, tactical, and mental aspects
5. **Open Source**: Build with transparency and community contribution

## First Steps

### Day 1: Get Oriented

**1. Clone and Explore (15 minutes)**

```bash
# Clone the repository
git clone https://github.com/THEDIFY/axolotl.git
cd axolotl

# Explore the structure
ls -la                    # See top-level files
cat README.md             # Read project overview
cat REPOSITORY_STRUCTURE.md  # Understand organization
```

**2. Read Key Documentation (30 minutes)**

Start with these documents in order:
1. [README.md](../README.md) - Project overview
2. [Repository Structure](repository-structure.md) - Codebase organization
3. [Architecture Overview](architecture/overview.md) - System design
4. [Quick Start Guide](getting-started/quick-start.md) - Running the app

**3. Run the Application (30 minutes)**

```bash
# Quick start with Docker
./scripts/local_dev_up.sh

# Or manually
docker compose up -d

# Access the app
open http://localhost:8080
```

**4. Explore the Running Application (30 minutes)**

- Open http://localhost:8080
- Navigate through different pages (Dashboard, Live, Sessions, Calendar)
- Try uploading a sample video (if available)
- Explore the calendar and training planning features
- Check out the pairing page for mobile integration

### Day 2-3: Understand the Architecture

**1. Backend Deep Dive (2 hours)**

Read and explore:
- [Backend Architecture](architecture/backend.md)
- `app/backend/app.py` - Main application
- `app/backend/blueprints/` - Browse the 8 API modules
- `app/backend/services/` - Check out business logic

**Exercise**: Find where KPI calculation happens
- Answer: `app/backend/services/kpi_calculator.py`

**2. Frontend Deep Dive (2 hours)**

Read and explore:
- [Frontend Architecture](architecture/frontend.md)
- `app/frontend/src/App.tsx` - Application root
- `app/frontend/src/pages/` - Browse page components
- `app/frontend/src/stores/` - State management

**Exercise**: Find where real-time metrics are displayed
- Answer: `app/frontend/src/pages/LiveAnalysis.tsx`

**3. AI/ML Components (2 hours)**

Read and explore:
- [AI/ML Models Overview](ai-ml/models.md)
- `src/axolotl/detection/` - Player detection
- `src/axolotl/tracking/` - Player tracking
- `src/axolotl/pose/` - Pose estimation
- `src/axolotl/llm/` - AI feedback system

**Exercise**: Understand the video processing pipeline
- Video → Detection → Tracking → Pose → KPI Calculation

### Week 1: Get Hands Dirty

**1. Run the Tests (1 hour)**

```bash
# Install dependencies
pip install -r requirements.txt

# Run unit tests
pytest tests/unit/

# Run integration tests
pytest tests/integration/

# Run specific test
pytest tests/integration/test_scan_api.py -v
```

**2. Make a Small Change (2 hours)**

Pick one:
- Add a new metric to KPI calculator
- Add a UI component to the dashboard
- Improve error handling in an API endpoint
- Add a new test case

**3. Understand the Development Workflow (1 hour)**

Read:
- [Contributing Guide](development/contributing.md)
- [Testing Guide](development/testing.md)
- [CI/CD Documentation](development/ci-cd.md)

## Understanding the System

### System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Users                                 │
│         (Web Browser, Mobile App, Edge Devices)              │
└────────────────────┬─────────────────────────────────────────┘
                     │ HTTP/WebSocket
┌────────────────────▼─────────────────────────────────────────┐
│                  Flask Web Service                           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │    8 API Blueprints                                   │   │
│  │  scan │ feedback │ live │ calendar │ dashboard        │   │
│  │  session │ pairing │ local_edge                       │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │    Business Services                                  │   │
│  │  KPI Calculator │ Live Processor │ Rules Engine      │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────┬─────────────────────────────────────────┘
                     │ Redis Queue
┌────────────────────▼─────────────────────────────────────────┐
│                  Worker Service (GPU)                        │
│  - Video Processing                                          │
│  - SMPL Fitting                                              │
│  - Heavy Computations                                        │
└────────────────────┬─────────────────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────────────────┐
│                Core AI/ML Library                            │
│  Detection │ Tracking │ Pose │ Multiview │ Biomech │ LLM    │
└────────────────────┬─────────────────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────────────────┐
│                   Data Layer                                 │
│  PostgreSQL │ Azure Blob │ Azure Search │ Redis             │
└──────────────────────────────────────────────────────────────┘
```

### Request Flow Examples

**1. Video Upload and Analysis**
```
User uploads video
  → POST /api/scan/quick (scan_bp)
  → Video saved to storage
  → Job queued in Redis
  → Worker processes video
     → Detection (YOLO)
     → Tracking (ByteTrack)
     → Pose Estimation (MediaPipe)
     → KPI Calculation
  → Results saved to database
  → User retrieves results
```

**2. AI Feedback Generation**
```
User requests feedback
  → POST /api/feedback/generate (feedback_bp)
  → Session data retrieved
  → RAG system queries similar sessions
  → Azure Cognitive Search returns context
  → Azure OpenAI generates feedback
  → Feedback saved and returned
```

**3. Live Session Tracking**
```
User starts live session
  → WebSocket connection established
  → POST /api/live/start
  → Frames streamed via WebSocket
  → Real-time detection/tracking
  → Metrics calculated on-the-fly
  → Results broadcast to all clients
```

### Key Concepts

#### 1. Sessions

A **session** represents a training or match recording with associated analysis data.

**Properties**:
- Unique ID
- Player ID
- Video file
- Timestamps
- Status (pending, processing, completed)
- KPIs (performance metrics)
- Feedback

#### 2. KPIs (Key Performance Indicators)

Calculated metrics from video analysis:

**Speed Metrics**:
- Max speed
- Average speed
- Speed zones (walking, jogging, running, sprinting)

**Distance Metrics**:
- Total distance
- High-intensity running distance
- Sprint distance

**Technical Metrics**:
- Touches
- Passes
- Pass accuracy
- Shots

**Physical Metrics**:
- Accelerations
- Decelerations
- Jumps

#### 3. Blueprints

Flask blueprints are modular API sections:

- **scan_bp**: Video upload and processing
- **feedback_bp**: AI coaching feedback
- **live_bp**: Real-time analysis
- **calendar_bp**: Training planning
- **dashboard_bp**: Performance visualization
- **session_bp**: Session management
- **pairing_bp**: Device pairing
- **local_edge_bp**: Edge device communication

#### 4. Services

Services contain business logic separated from API routes:

- **kpi_calculator**: Calculates performance metrics
- **live_processor**: Processes live video frames
- **calendar_service**: Manages training events
- **rules_engine**: Validates training safety
- **pairing_service**: Handles device pairing

#### 5. AI/ML Pipeline

```
Video → Detection → Tracking → Pose → Analysis
         (YOLO)    (ByteTrack) (MediaPipe)
```

**Detection**: Identify players in each frame  
**Tracking**: Maintain player identities across frames  
**Pose**: Estimate body keypoints for each player  
**Analysis**: Calculate metrics and generate feedback

#### 6. RAG System

**Retrieval-Augmented Generation** enhances AI feedback:

1. User requests feedback for a session
2. System retrieves similar past sessions
3. External knowledge articles are searched
4. Context is built from retrieved information
5. LLM generates feedback using context
6. Result is more accurate and contextually relevant

## Development Setup

### Prerequisites

**Required**:
- Python 3.12+
- Node.js 18+
- Docker & Docker Compose
- Git

**Optional**:
- PostgreSQL 15+ (for production-like setup)
- Redis 7+ (included in Docker Compose)
- CUDA-capable GPU (for faster processing)

### Setup Steps

**1. Environment Setup**

```bash
# Clone repository
git clone https://github.com/THEDIFY/axolotl.git
cd axolotl

# Copy environment template
cp .env.example .env

# Edit .env with your configuration
# At minimum, set:
# - SECRET_KEY
# - DATABASE_URL (optional, defaults to SQLite)
```

**2. Python Environment**

```bash
# Create virtual environment
python -m venv venv

# Activate (Linux/Mac)
source venv/bin/activate

# Activate (Windows)
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

**3. Frontend Setup**

```bash
cd app/frontend

# Install dependencies
npm install

# Start dev server (optional, for frontend development)
npm run dev

# Build for production
npm run build

cd ../..
```

**4. Docker Setup (Recommended)**

```bash
# Start all services
docker compose up -d

# View logs
docker compose logs -f web

# Stop services
docker compose down
```

**5. Database Setup**

```bash
# If using PostgreSQL
docker compose --profile postgres up -d

# Run migrations (if migrations exist)
# alembic upgrade head
```

### Development Workflow

**Option 1: Docker Development (Easiest)**

```bash
# Start services
docker compose up -d

# Make code changes
# Changes are automatically synced (volume mount)

# Restart if needed
docker compose restart web

# View logs
docker compose logs -f web
```

**Option 2: Local Development**

```bash
# Terminal 1: Start backend
cd app/backend
python app.py

# Terminal 2: Start worker
python worker.py

# Terminal 3: Start frontend
cd app/frontend
npm run dev

# Terminal 4: Start Redis
redis-server
```

### Verification

```bash
# Check services
docker compose ps

# Test backend
curl http://localhost:8080/health

# Test frontend
open http://localhost:8080

# Run tests
pytest tests/
```

## Your First Contribution

### Finding an Issue

1. **Good First Issues**: Look for `good-first-issue` label on GitHub
2. **Documentation**: Improvements to docs are always welcome
3. **Tests**: Adding test coverage is valuable
4. **Bug Fixes**: Check open issues for bugs
5. **Small Features**: Start with small, well-defined features

### Making Changes

**1. Create a Branch**

```bash
git checkout -b feature/my-feature-name
# or
git checkout -b fix/bug-description
```

**2. Make Changes**

Follow these principles:
- **Minimal changes**: Change only what's necessary
- **Test your code**: Add tests for new functionality
- **Follow conventions**: Match existing code style
- **Document**: Add comments and update docs

**3. Test Locally**

```bash
# Run linters
flake8 app/backend/
eslint app/frontend/src/

# Run tests
pytest tests/

# Test manually
# - Run the application
# - Exercise your changes
# - Verify functionality
```

**4. Commit and Push**

```bash
# Stage changes
git add .

# Commit with descriptive message
git commit -m "Add feature: description of what you did"

# Push to your branch
git push origin feature/my-feature-name
```

**5. Create Pull Request**

1. Go to GitHub repository
2. Click "New Pull Request"
3. Select your branch
4. Fill in PR template:
   - Description of changes
   - Related issue number
   - Testing performed
   - Screenshots (if UI changes)
5. Submit for review

### Code Review Process

1. **Automated Checks**: CI/CD runs tests automatically
2. **Review**: Maintainers review your code
3. **Feedback**: You may receive change requests
4. **Iteration**: Make requested changes
5. **Approval**: Once approved, PR is merged

## Workflow Guide

### Daily Development

**Morning**:
```bash
# Pull latest changes
git pull origin main

# Check for conflicts
git status

# Start services
docker compose up -d
```

**During Development**:
```bash
# Make changes
# Test changes
# Commit frequently
git add <files>
git commit -m "Descriptive message"
```

**Before Pushing**:
```bash
# Run full test suite
pytest tests/

# Check code quality
flake8 app/backend/

# Build frontend
cd app/frontend && npm run build

# Manual verification
# Test the actual application
```

### Common Tasks

**Add a New API Endpoint**:
1. Choose appropriate blueprint (`app/backend/blueprints/`)
2. Add route function
3. Add business logic to service (`app/backend/services/`)
4. Add tests (`tests/integration/`)
5. Update API docs (`documentation/architecture/api-reference.md`)

**Add a Frontend Component**:
1. Create component file (`app/frontend/src/components/`)
2. Add TypeScript types (`app/frontend/src/types/`)
3. Use in page component
4. Add tests (`app/frontend/src/test/`)
5. Update component documentation

**Add an AI Model**:
1. Create module directory (`src/axolotl/model_name/`)
2. Implement model class
3. Add README to module
4. Integrate in service (`app/backend/services/`)
5. Add demo (`examples/demos/`)
6. Document (`documentation/ai-ml/`)

## Getting Help

### Resources

**Documentation**:
- [Architecture Overview](architecture/overview.md)
- [Backend Guide](architecture/backend.md)
- [Frontend Guide](architecture/frontend.md)
- [API Reference](architecture/api-reference.md)
- [Testing Guide](development/testing.md)

**Code**:
- Browse `examples/demos/` for usage examples
- Check existing tests for patterns
- Read inline code comments

### Ask Questions

**Where to Ask**:
- GitHub Issues (for bugs and feature requests)
- GitHub Discussions (for questions and ideas)
- PR comments (for code-specific questions)

**How to Ask**:
1. Search existing issues/discussions first
2. Provide context and details
3. Include code snippets if relevant
4. Describe what you've already tried
5. Be respectful and patient

## Learning Resources

### Python/Flask
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Python Type Hints](https://docs.python.org/3/library/typing.html)
- [SQLAlchemy Tutorial](https://docs.sqlalchemy.org/en/14/tutorial/)

### React/TypeScript
- [React Documentation](https://react.dev/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/)
- [Vite Guide](https://vitejs.dev/guide/)

### AI/ML
- [PyTorch Tutorials](https://pytorch.org/tutorials/)
- [YOLO Documentation](https://docs.ultralytics.com/)
- [MediaPipe Pose](https://google.github.io/mediapipe/solutions/pose.html)

### Computer Vision
- [OpenCV Tutorials](https://docs.opencv.org/4.x/d9/df8/tutorial_root.html)
- [Computer Vision Basics](https://www.coursera.org/specializations/computer-vision)

### Sports Analytics
- [Performance Analysis Resources](https://www.scienceforsport.com/)
- [Football Analytics](https://www.footballdatasourcing.com/)

## Next Steps

### Week 2+: Become Productive

**Choose a Focus Area**:
- Backend API development
- Frontend UI/UX
- AI/ML model development
- DevOps and deployment
- Documentation and examples
- Testing and quality assurance

**Build Knowledge**:
- Read relevant documentation thoroughly
- Study existing code in your focus area
- Understand related technologies deeply

**Contribute Regularly**:
- Start with small contributions
- Gradually take on larger tasks
- Help review others' PRs
- Improve documentation
- Share knowledge with newcomers

### Ongoing Learning

- **Stay Updated**: Watch repository for changes
- **Read PRs**: Learn from others' contributions
- **Experiment**: Try new features and technologies
- **Share**: Document what you learn
- **Mentor**: Help new contributors once comfortable

## Welcome Checklist

- [ ] Repository cloned and explored
- [ ] Application running locally
- [ ] Key documentation read
- [ ] Architecture understood at high level
- [ ] Development environment set up
- [ ] Tests run successfully
- [ ] First small change made
- [ ] Git workflow understood
- [ ] Know where to get help
- [ ] Ready to contribute!

---

**Welcome aboard!** We're excited to have you as part of the Axolotl community. Don't hesitate to ask questions and remember: everyone was new once. Your fresh perspective is valuable!

## Related Documentation

- [Repository Structure](repository-structure.md)
- [Architecture Overview](architecture/overview.md)
- [Contributing Guide](development/contributing.md)
- [Quick Start Guide](getting-started/quick-start.md)
- [Testing Guide](development/testing.md)
