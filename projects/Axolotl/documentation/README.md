# Axolotl Documentation

Welcome to the Axolotl Football Analysis Platform documentation. This guide will help you get started, understand the architecture, and develop new features.

## 📚 Documentation Structure

### 🚀 Getting Started
- [Quick Start Guide](getting-started/quick-start.md) - Get up and running in minutes with Docker
- [Configuration](getting-started/configuration.md) - Environment variables and settings
- [Troubleshooting](getting-started/troubleshooting.md) - Common issues and solutions

### 🏗️ Architecture
- [System Overview](architecture/overview.md) - High-level architecture and components
- [Backend Architecture](architecture/backend.md) - Flask application structure
- [Frontend Architecture](architecture/frontend.md) - React/TypeScript frontend
- [Database Schema](architecture/database.md) - Data models and relationships
- [API Reference](architecture/api-reference.md) - REST API endpoints

### 📂 Repository Organization
- [Repository Structure](repository-structure.md) - Complete codebase organization guide
- [Newcomer Onboarding](newcomer-onboarding.md) - Comprehensive guide for new contributors

### Features
- [Live Analysis](features/live-analysis.md) - Real-time performance tracking
- [Calendar & Training Planning](features/calendar-planning.md) - AI-powered training calendar
- [Player Dashboard](features/player-dashboard.md) - Performance metrics and visualization
- [Mobile Pairing](features/mobile-pairing.md) - QR code device pairing
- [AI Feedback Engine](features/ai-feedback.md) - LLM-powered coaching insights
- [Session History](features/session-history.md) - Session indexing and retrieval

### AI & Machine Learning
- [Models Overview](ai-ml/models.md) - AI/ML models used in the platform
- [Detection](ai-ml/detection.md) - Object and player detection
- [Tracking](ai-ml/tracking.md) - Multi-player tracking algorithms
- [Pose Estimation](ai-ml/pose.md) - 3D pose estimation and SMPL fitting
- [Event Spotting](ai-ml/event-spotting.md) - Automatic event detection
- [RAG System](ai-ml/rag-system.md) - Retrieval-augmented generation
- [Model Training](ai-ml/training.md) - Training and fine-tuning models

### 👨‍💻 Development
- [Contributing Guide](development/contributing.md) - How to contribute to the project
- [Coding Standards](development/coding-standards.md) - Code style and best practices
- [Testing Guide](development/testing.md) - Running and writing tests
- [CI/CD Pipeline](development/ci-cd.md) - Continuous integration and deployment
- [Docker Development](development/docker.md) - Working with Docker containers

### Deployment
- [Production Deployment](deployment/production.md) - Deploying to production
- [Kubernetes Setup](deployment/kubernetes.md) - Running on Kubernetes
- [Azure Deployment](deployment/azure.md) - Deploying to Azure
- [Local Edge](deployment/local-edge.md) - Edge deployment for offline use

### Archive
- [Implementation Notes](archive/implementation-notes/) - Historical implementation documentation

## 🔍 Quick Navigation

### I want to...
- **Get started quickly** → [Quick Start Guide](getting-started/quick-start.md)
- **Understand the system** → [System Overview](architecture/overview.md)
- **Navigate the codebase** → [Repository Structure](repository-structure.md)
- **Start contributing** → [Newcomer Onboarding](newcomer-onboarding.md)
- **Add a new feature** → [Contributing Guide](development/contributing.md)
- **Follow code standards** → [Coding Standards](development/coding-standards.md)
- **Understand the API** → [API Reference](architecture/api-reference.md)
- **Learn about AI models** → [AI/ML Models](ai-ml/models.md)
- **Train a model** → [Model Training](ai-ml/training.md)
- **Deploy to production** → [Production Deployment](deployment/production.md)
- **Fix a bug** → [Testing Guide](development/testing.md)

## 🛠️ Technology Stack

- **Backend**: Flask, Python 3.12+
- **Frontend**: React, TypeScript, Vite, TailwindCSS
- **AI/ML**: PyTorch, YOLO, MediaPipe, Transformers
- **Database**: PostgreSQL (production), SQLite (development)
- **Infrastructure**: Docker, Redis, Azure services
- **Testing**: pytest, Playwright

## 📖 Additional Resources

- [Main README](../README.md) - Project overview
- [GitHub Repository](https://github.com/THEDIFY/axolotl)
- [Issue Tracker](https://github.com/THEDIFY/axolotl/issues)

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](development/contributing.md) for details on how to get started.

## 📄 License

This project is licensed under the terms specified in the [LICENSE](../LICENSE) file.
