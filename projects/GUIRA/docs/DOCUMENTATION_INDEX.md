# GUIRA Documentation Index

Complete guide to all documentation resources for the GUIRA project.

## 📚 Core Documentation

### [README.md](README.md) - **START HERE**
The main project documentation with comprehensive overview, architecture diagrams, and getting started guide.

**Contents:**
- Project overview and mission
- Problem statement and target users
- Key features with technical details
- System architecture (8 Mermaid diagrams)
- Performance metrics and field testing results
- Installation and quick start
- Technology stack
- Project structure
- Testing guidelines
- Roadmap and status
- Contributing information

**Length:** 975 lines | **Size:** 34KB

---

## 🛠️ Technical Documentation

### [API.md](API.md)
Complete REST API reference with endpoint specifications, request/response formats, and code examples.

**Contents:**
- Authentication
- Detection endpoints (fire, smoke, vegetation, wildlife)
- Prediction endpoints (fire spread, risk assessment)
- Monitoring and WebSocket
- Map generation
- Data models
- Error handling
- Rate limiting
- Python/JavaScript/cURL examples

**Length:** 465 lines | **Size:** 12KB

### [ARCHITECTURE.md](ARCHITECTURE.md)
Detailed system architecture documentation with component diagrams, data flows, and design decisions.

**Contents:**
- System overview and principles
- Component diagrams (Mermaid)
- Data flow architecture
- Model pipeline orchestration
- Cloud and edge deployment
- Database schema
- Security architecture
- Scalability considerations
- Technology decisions
- Monitoring and disaster recovery

**Length:** 770 lines | **Size:** 18KB

---

## 👥 Contributing & Community

### [CONTRIBUTING.md](CONTRIBUTING.md)
Complete guide for contributing to GUIRA including code standards, workflows, and community guidelines.

**Contents:**
- Code of Conduct
- How to contribute (bugs, features, code, docs)
- Development setup
- Coding standards (Python style, documentation, testing)
- Commit guidelines (Conventional Commits)
- Pull request process
- Community and recognition

**Length:** 580 lines | **Size:** 15KB

---

## 🚀 Deployment & Operations

### [DEPLOYMENT.md](DEPLOYMENT.md)
Comprehensive deployment guide for all environments from local to cloud production.

**Contents:**
- Prerequisites (hardware/software)
- Local development setup
- Docker deployment
- Cloud deployment (Azure, AWS, GCP)
- Edge deployment (NVIDIA Jetson)
- Configuration management
- Monitoring setup (Prometheus, Grafana)
- Backup and recovery
- Security checklist

**Length:** 380 lines | **Size:** 9.3KB

### [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
Common issues and solutions for installation, runtime, and deployment problems.

**Contents:**
- Installation issues (GDAL, PyTorch, PostGIS)
- Runtime errors (OOM, imports)
- Performance problems (slow inference, high CPU)
- API issues (401, 500 errors)
- Database problems
- Model loading errors
- Geospatial processing
- Docker and Kubernetes issues
- FAQ and support information

**Length:** 435 lines | **Size:** 9.9KB

---

## 📋 Project Information

### [CHANGELOG.md](../CHANGELOG.md)
Version history with detailed release notes for each version.

**Contents:**
- Version 0.4.0 - Documentation Release
- Version 0.3.0 - Prediction & Geospatial
- Version 0.2.0 - Multi-Modal AI
- Version 0.1.0 - Initial Prototype
- Upcoming releases roadmap

**Length:** 260 lines | **Size:** 5.9KB

---

## 📖 Original Technical Documentation

Located in `../documentation/` directory:

### [PROJECT_OVERVIEW.md](../documentation/PROJECT_OVERVIEW.md)
Comprehensive technical overview of the entire fire prevention system.

**Contents:**
- System overview and capabilities
- Techniques and architectures (YOLOv8, TimeSFormer, ResNet50, CSRNet, Fire Spread)
- Dataset descriptions and sources
- Integration workflow
- Training strategy and limitations
- Architecture diagrams
- Codebase references

**Length:** 1,017 lines | **Highly Technical**

### [TECHNICAL_ALGORITHMS_GUIDE.md](../documentation/TECHNICAL_ALGORITHMS_GUIDE.md)
In-depth mathematical and algorithmic explanations for all AI models.

**Contents:**
- Mathematical foundations (linear algebra, calculus)
- Computer vision fundamentals
- Deep learning architectures
- Model-specific algorithms
- Optimization techniques
- Performance benchmarks

**Length:** Very comprehensive | **For Researchers/Advanced Users**

### Additional Technical Docs

- **[fire_detection.md](../documentation/fire_detection.md)** - YOLOv8 implementation details
- **[smoke_detection.md](../documentation/smoke_detection.md)** - TimeSFormer temporal analysis
- **[vegetation_health.md](../documentation/vegetation_health.md)** - ResNet50 + VARI monitoring
- **[fauna_detection.md](../documentation/fauna_detection.md)** - CSRNet wildlife tracking
- **[fire_spread.md](../documentation/fire_spread.md)** - Hybrid simulation model
- **[REGISTRY.md](../documentation/REGISTRY.md)** - Dataset registry and licenses

---

## 🎯 Specialized Guides

### [Reproducibility Guide](../reproducibility/reproduce.md)
Step-by-step guide to reproduce GUIRA's results.

**Contents:**
- System requirements
- Environment setup (Docker/native)
- Download test data
- Run detection pipeline
- Temporal analysis
- Vegetation analysis
- Geospatial risk mapping
- Validation

**Length:** 259 lines | **Practical**

---

## 🏗️ Assets & Media

### Screenshots Directory: `../assets/screenshots/`
Contains (or will contain) application screenshots:
- Fire detection demo
- Risk map visualization
- System dashboard
- Vegetation health analysis
- Fire spread prediction
- Wildlife tracking

### Diagrams Directory: `../assets/diagrams/`
Standalone diagram exports (SVG/PNG):
- System architecture
- Detection pipeline
- Data flow
- Deployment architecture

### Videos Directory: `../assets/videos/`
Demo videos and tutorials:
- System demo (60-90s)
- Field testing footage
- Setup tutorial

---

## 📊 Documentation Statistics

**Total Documentation:**
- **Lines of Code/Text:** 3,900+ lines
- **Total Size:** ~100KB
- **Files:** 20+ documentation files
- **Mermaid Diagrams:** 8+ embedded diagrams
- **Code Examples:** Python, JavaScript, Bash, SQL, YAML
- **Coverage:** Complete system documentation

**Quality Indicators:**
- ✅ Comprehensive API documentation
- ✅ Detailed architecture diagrams
- ✅ Step-by-step installation guides
- ✅ Troubleshooting for common issues
- ✅ Multi-cloud deployment instructions
- ✅ Contributing guidelines
- ✅ Version history and roadmap

---

## 🗺️ Documentation Navigation Guide

### **For New Users:**
1. Start with [README.md](README.md) - Overview and quick start
2. Try [Reproducibility Guide](../reproducibility/reproduce.md) - Hands-on
3. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) if issues arise

### **For Developers:**
1. Read [README.md](README.md) - Project overview
2. Study [ARCHITECTURE.md](ARCHITECTURE.md) - System design
3. Follow [CONTRIBUTING.md](CONTRIBUTING.md) - Development workflow
4. Review [API.md](API.md) - API integration

### **For Deployers:**
1. Review [README.md](README.md) - Requirements
2. Follow [DEPLOYMENT.md](DEPLOYMENT.md) - Environment-specific guide
3. Use [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Issue resolution

### **For Researchers:**
1. Start with [PROJECT_OVERVIEW.md](../documentation/PROJECT_OVERVIEW.md)
2. Deep dive into [TECHNICAL_ALGORITHMS_GUIDE.md](../documentation/TECHNICAL_ALGORITHMS_GUIDE.md)
3. Review individual model documentation in `/documentation/`

---

## 🔗 External Resources

**Project Repository:** https://github.com/THEDIFY/THEDIFY  
**Issues:** https://github.com/THEDIFY/THEDIFY/issues  
**Discussions:** https://github.com/THEDIFY/THEDIFY/discussions  
**Contact:** rasanti2008@gmail.com

---

## 📝 Documentation Standards

All GUIRA documentation follows these standards:
- **Markdown Format:** GitHub-flavored markdown
- **Code Blocks:** Language-specified for syntax highlighting
- **Diagrams:** Mermaid for embedded, SVG/PNG for standalone
- **Examples:** Real, working code snippets
- **Links:** Relative paths within repository
- **Updates:** Version-controlled with git
- **Maintenance:** Updated with each release

---

## 🎯 Quick Reference

| I want to... | Go to... |
|--------------|----------|
| Understand the project | [README.md](README.md) |
| Install and run GUIRA | [README.md#getting-started](README.md#getting-started) |
| Use the API | [API.md](API.md) |
| Deploy to production | [DEPLOYMENT.md](DEPLOYMENT.md) |
| Fix an error | [TROUBLESHOOTING.md](TROUBLESHOOTING.md) |
| Contribute code | [CONTRIBUTING.md](CONTRIBUTING.md) |
| Understand architecture | [ARCHITECTURE.md](ARCHITECTURE.md) |
| Learn algorithms | [TECHNICAL_ALGORITHMS_GUIDE.md](../documentation/TECHNICAL_ALGORITHMS_GUIDE.md) |
| Reproduce results | [reproduce.md](../reproducibility/reproduce.md) |
| See what changed | [CHANGELOG.md](../CHANGELOG.md) |

---

**Documentation Version:** 1.0  
**Last Updated:** December 17, 2025  
**Maintained by:** Santiago (THEDIFY)

---

*This is a living document. Contributions to improve documentation are always welcome!*
