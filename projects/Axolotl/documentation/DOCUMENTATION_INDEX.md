# Documentation Index

Complete guide to all documentation in the Axolotl Football Analysis Platform.

## 📖 Quick Links

### New to Axolotl?
Start here:
1. [README.md](../README.md) - Project overview and quick start
2. [Newcomer Onboarding](newcomer-onboarding.md) - Step-by-step guide for new contributors
3. [Repository Structure](repository-structure.md) - Understand the codebase organization
4. [Quick Start Guide](getting-started/quick-start.md) - Get the app running in minutes

### Ready to Develop?
5. [Contributing Guide](development/contributing.md) - How to contribute
6. [Coding Standards](development/coding-standards.md) - Code style and best practices
7. [Testing Guide](development/testing.md) - Write and run tests

### Understanding the System
8. [System Architecture](architecture/overview.md) - High-level system design
9. [Backend Architecture](architecture/backend.md) - Flask application details
10. [Frontend Architecture](architecture/frontend.md) - React/TypeScript frontend
11. [API Reference](architecture/api-reference.md) - Complete API documentation
12. [Database Schema](architecture/database.md) - Data models and tables

## 📂 Complete Documentation Structure

### 🚀 Getting Started (3 docs)
- **[Quick Start](getting-started/quick-start.md)** - Docker-based quick setup
- **[Configuration](getting-started/configuration.md)** - Environment variables and settings  
- **[Troubleshooting](getting-started/troubleshooting.md)** - Common issues and solutions

**Use Cases**: First-time setup, environment configuration, debugging setup issues

---

### 🏗️ Architecture (5 docs)
- **[System Overview](architecture/overview.md)** (465 lines)
  - High-level architecture with diagrams
  - Component descriptions
  - Technology stack
  - Data flow diagrams
  - Deployment architecture

- **[Backend Architecture](architecture/backend.md)** (814 lines)
  - Flask application structure
  - 8 API blueprints detailed
  - Services layer
  - Worker service
  - Database models
  - WebSocket communication

- **[Frontend Architecture](architecture/frontend.md)** (972 lines)
  - React/TypeScript application
  - Component architecture
  - State management (Zustand)
  - Routing patterns
  - Real-time communication
  - 3D visualization

- **[Database Schema](architecture/database.md)** (761 lines)
  - Complete database schema
  - Table definitions with SQL
  - JSON schemas for RAG
  - Indexes and optimization
  - Migration guides

- **[API Reference](architecture/api-reference.md)** (1127 lines)
  - Complete REST API documentation
  - All 8 blueprints covered
  - Request/response examples
  - WebSocket events
  - Error codes and handling

**Use Cases**: Understanding system design, API integration, database queries, architectural decisions

---

### 📂 Repository Organization (2 docs)
- **[Repository Structure](repository-structure.md)** (556 lines)
  - Complete directory tree
  - Key directories explained
  - File organization principles
  - Where to find/add code
  - Import patterns
  - Navigation checklist

- **[Newcomer Onboarding](newcomer-onboarding.md)** (744 lines)
  - Day-by-day onboarding plan
  - System understanding guide
  - Development setup
  - First contribution walkthrough
  - Key concepts explained
  - Learning resources

**Use Cases**: Navigating codebase, understanding structure, onboarding new team members

---

### 👨‍💻 Development (5 docs)
- **[Contributing Guide](development/contributing.md)** (820 lines)
  - Code of conduct
  - Development workflow
  - Commit message format
  - Testing requirements
  - Pull request process
  - Issue guidelines
  - Security considerations

- **[Coding Standards](development/coding-standards.md)** (719 lines)
  - Python style guide with examples
  - TypeScript/React standards
  - API design principles
  - Database design conventions
  - Security standards
  - Performance guidelines
  - Error handling patterns

- **[Testing Guide](development/testing.md)** (490 lines)
  - Test types and organization
  - Writing unit tests
  - Integration testing
  - E2E testing
  - Coverage requirements
  - CI/CD integration

- **[CI/CD Pipeline](development/ci-cd.md)** (327 lines)
  - GitHub Actions workflows
  - Automated testing
  - Build process
  - Deployment automation

- **[Docker Development](development/docker.md)** (426 lines)
  - Docker Compose setup
  - Container architecture
  - Development workflow
  - Production builds

**Use Cases**: Contributing code, following standards, testing changes, CI/CD setup

---

### ✨ Features (5 docs)
- **[AI Feedback](features/ai-feedback.md)** (440 lines) - AI coaching feedback system
- **[Calendar Planning](features/calendar-planning.md)** (404 lines) - Training calendar and scheduling
- **[Calendar Quick Start](features/calendar-quick-start.md)** (120 lines) - Quick calendar guide
- **[Mobile Pairing](features/mobile-pairing.md)** (771 lines) - QR code device pairing
- **[Session History](features/session-history.md)** (220 lines) - Session management and indexing

**Use Cases**: Understanding features, using the application, feature documentation

---

### 🤖 AI/ML (7 docs)
- **[Models Overview](ai-ml/models.md)** (314 lines) - AI/ML models inventory
- **[Detection](ai-ml/detection.md)** (246 lines) - YOLO object detection
- **[Tracking](ai-ml/tracking.md)** (278 lines) - ByteTrack multi-object tracking
- **[Pose Estimation](ai-ml/pose.md)** (259 lines) - MediaPipe pose detection
- **[Event Spotting](ai-ml/event-spotting.md)** (200 lines) - Automatic event detection
- **[RAG System](ai-ml/rag-system.md)** (496 lines) - Retrieval-augmented generation
- **[Model Training](ai-ml/training.md)** (733 lines) - Training and fine-tuning

**Use Cases**: Understanding AI models, training models, integrating AI features

---

### 🚀 Deployment (2 docs)
- **[Production Deployment](deployment/production.md)** (471 lines) - Azure/K8s deployment
- **[Local Edge](deployment/local-edge.md)** (156 lines) - Edge device deployment

**Use Cases**: Deploying to production, setting up edge devices

---

### 📦 Archive (11 docs)
Historical implementation notes and phase completion documents.

**Use Cases**: Understanding project history, implementation decisions

---

## 📊 Documentation Statistics

| Category | Files | Total Lines | Coverage |
|----------|-------|-------------|----------|
| Getting Started | 3 | ~600 | ✅ Complete |
| Architecture | 5 | ~4,100 | ✅ Complete |
| Organization | 2 | ~1,300 | ✅ Complete |
| Development | 5 | ~2,800 | ✅ Complete |
| Features | 5 | ~2,000 | ✅ Complete |
| AI/ML | 7 | ~2,500 | ✅ Complete |
| Deployment | 2 | ~600 | ✅ Complete |
| Archive | 11 | ~4,000 | ✅ Complete |
| **TOTAL** | **40** | **~18,000** | **✅ Complete** |

## 🎯 Documentation by Use Case

### I Want To...

#### Learn About the System
1. **Understand at a high level** → [System Overview](architecture/overview.md)
2. **Understand the backend** → [Backend Architecture](architecture/backend.md)
3. **Understand the frontend** → [Frontend Architecture](architecture/frontend.md)
4. **Understand the database** → [Database Schema](architecture/database.md)
5. **Understand the API** → [API Reference](architecture/api-reference.md)

#### Get Started
1. **Run the application** → [Quick Start](getting-started/quick-start.md)
2. **Configure environment** → [Configuration](getting-started/configuration.md)
3. **Fix setup issues** → [Troubleshooting](getting-started/troubleshooting.md)
4. **Start contributing** → [Newcomer Onboarding](newcomer-onboarding.md)

#### Navigate the Code
1. **Understand repository structure** → [Repository Structure](repository-structure.md)
2. **Find where code lives** → [Repository Structure](repository-structure.md#where-to-find-things)
3. **Know where to add code** → [Repository Structure](repository-structure.md#where-to-add-new-code)
4. **Understand import patterns** → [Repository Structure](repository-structure.md#import-patterns)

#### Contribute Code
1. **Follow contribution workflow** → [Contributing Guide](development/contributing.md)
2. **Follow code standards** → [Coding Standards](development/coding-standards.md)
3. **Write tests** → [Testing Guide](development/testing.md)
4. **Create pull requests** → [Contributing Guide](development/contributing.md#pull-request-process)

#### Work with Features
1. **Understand AI feedback** → [AI Feedback](features/ai-feedback.md)
2. **Use calendar planning** → [Calendar Planning](features/calendar-planning.md)
3. **Set up mobile pairing** → [Mobile Pairing](features/mobile-pairing.md)
4. **Manage sessions** → [Session History](features/session-history.md)

#### Work with AI/ML
1. **Overview of models** → [Models Overview](ai-ml/models.md)
2. **Player detection** → [Detection](ai-ml/detection.md)
3. **Player tracking** → [Tracking](ai-ml/tracking.md)
4. **Pose estimation** → [Pose](ai-ml/pose.md)
5. **RAG system** → [RAG System](ai-ml/rag-system.md)
6. **Train models** → [Model Training](ai-ml/training.md)

#### Deploy
1. **Deploy to production** → [Production Deployment](deployment/production.md)
2. **Set up edge devices** → [Local Edge](deployment/local-edge.md)
3. **Use Docker** → [Docker Development](development/docker.md)

## 🔄 Documentation Workflow

### For Readers

```
Start Here → Choose Your Path
    ↓
    ├─→ New User → Newcomer Onboarding → Quick Start
    │
    ├─→ Developer → Repository Structure → Contributing Guide
    │
    ├─→ Architect → System Overview → Architecture Docs
    │
    └─→ ML Engineer → Models Overview → AI/ML Docs
```

### For Contributors

When adding new features, update:
1. **API Reference** - If adding new endpoints
2. **Architecture** - If changing system design
3. **Feature Docs** - If adding user-facing features
4. **AI/ML Docs** - If adding models or algorithms
5. **Repository Structure** - If reorganizing code

## 📝 Documentation Standards

All documentation follows these principles:

### Structure
- Clear table of contents
- Logical organization
- Consistent formatting
- Cross-references to related docs

### Content
- **Code examples** for technical concepts
- **Diagrams** for architecture
- **Step-by-step guides** for processes
- **Use cases** and scenarios
- **Troubleshooting** sections

### Style
- **Clear and concise** writing
- **Active voice** preferred
- **Technical accuracy** verified
- **Up-to-date** with code

### Maintenance
- Updated with code changes
- Versioned with releases
- Reviewed regularly
- Community feedback incorporated

## 🤝 Contributing to Documentation

Documentation contributions are highly valuable! To contribute:

1. **Fix typos or errors** - Submit a PR directly
2. **Improve explanations** - Submit a PR with improvements
3. **Add examples** - Always helpful for clarity
4. **Fill gaps** - If something is unclear, improve it
5. **Update outdated info** - Keep documentation current

See [Contributing Guide](development/contributing.md) for the full process.

## 📧 Documentation Feedback

Found an issue with the documentation?
- Open a GitHub issue with the `documentation` label
- Submit a PR with fixes
- Ask questions in GitHub Discussions

## 🎓 Learning Path

### Beginner (Week 1)
1. [README.md](../README.md) - Project overview
2. [Newcomer Onboarding](newcomer-onboarding.md) - Get oriented
3. [Quick Start](getting-started/quick-start.md) - Run the app
4. [Repository Structure](repository-structure.md) - Navigate code

### Intermediate (Week 2-3)
5. [System Overview](architecture/overview.md) - Understand architecture
6. [Backend Architecture](architecture/backend.md) - Deep dive backend
7. [Frontend Architecture](architecture/frontend.md) - Deep dive frontend
8. [Contributing Guide](development/contributing.md) - Start contributing

### Advanced (Week 4+)
9. [API Reference](architecture/api-reference.md) - Master the API
10. [Database Schema](architecture/database.md) - Understand data
11. [AI/ML Models](ai-ml/models.md) - Learn the AI systems
12. [Model Training](ai-ml/training.md) - Train models

## ✅ Documentation Checklist

When starting with Axolotl, check off these items:

- [ ] Read README.md
- [ ] Complete Newcomer Onboarding guide
- [ ] Run application successfully
- [ ] Understand repository structure
- [ ] Read system architecture overview
- [ ] Explore backend/frontend architecture
- [ ] Review API reference
- [ ] Read contributing guide
- [ ] Understand coding standards
- [ ] Know how to run tests
- [ ] Ready to contribute!

## 🌟 Documentation Highlights

**Most Comprehensive**:
- API Reference (1127 lines)
- Frontend Architecture (972 lines)
- Backend Architecture (814 lines)

**Most Practical**:
- Newcomer Onboarding - Day-by-day plan
- Contributing Guide - Complete workflow
- Coding Standards - Real examples

**Most Technical**:
- Database Schema - Full SQL definitions
- Model Training - Training procedures
- RAG System - AI implementation details

---

**Welcome to Axolotl!** This documentation is here to help you succeed. Start with the [Newcomer Onboarding](newcomer-onboarding.md) guide and explore from there.

**Questions?** Open an issue or discussion on GitHub.

**Last Updated**: October 2025  
**Documentation Version**: 2.0 (Post-Phase 10.1 Cleanup)
