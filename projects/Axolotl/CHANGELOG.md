# Changelog

All notable changes to the Axolotl Football Analysis Platform will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive project documentation (README, API, ARCHITECTURE, CONTRIBUTING, DEPLOYMENT, TROUBLESHOOTING)
- Mermaid diagrams for system architecture visualization
- Complete API reference with code examples
- Detailed deployment guides for various environments
- Troubleshooting guide with common issues and solutions

### Changed
- Enhanced README.md with screenshots, badges, and visual elements
- Improved documentation structure and organization

### Fixed
- Documentation links and cross-references

## [0.8.0] - 2025-12-17

### Added
- AI-powered training calendar with intelligent recommendations
- Mobile device pairing via QR codes
- Session history indexing and retrieval system
- AI coaching feedback with RAG (Retrieval-Augmented Generation)
- Real-time WebSocket updates for live analysis
- Multi-camera synchronization support
- SMPL body mesh 3D reconstruction
- Azure OpenAI integration for GPT-4 feedback

### Changed
- Migrated to Flask 3.0+ with modular blueprint architecture
- Updated to React 18 with TypeScript for frontend
- Improved GPU processing pipeline efficiency (45 FPS)
- Enhanced player tracking with ByteTrack algorithm

### Fixed
- Player ID switching during occlusion events
- Memory leaks in long-running video processing
- WebSocket disconnection issues
- Database connection pool exhaustion

### Security
- Implemented API key authentication
- Added rate limiting for API endpoints
- Enabled content filtering for AI-generated feedback
- Implemented age-appropriate safety checks (U13+)

## [0.7.0] - 2024-11-15

### Added
- GPT-4 AI coaching feedback engine
- Azure Cognitive Search for RAG system
- Player performance dashboard
- Advanced tactical metrics calculation
- Event spotting (passes, shots, tackles)

### Changed
- Switched from DeepSORT to ByteTrack for tracking
- Upgraded YOLOv5 to YOLOv8 for detection
- Improved pose estimation with MediaPipe

### Fixed
- Detection accuracy in poor lighting conditions
- Tracking continuity across camera cuts

## [0.6.0] - 2024-09-30

### Added
- 3D pose estimation with SMPL fitting
- Multi-view 3D reconstruction
- Biomechanical analysis features
- Heat map generation for positioning analysis

### Changed
- Optimized video processing pipeline
- Reduced memory usage by 30%

## [0.5.0] - 2024-07-15

### Added
- Interactive React dashboard
- Real-time live analysis mode
- WebSocket support for real-time updates
- Session management system

### Changed
- Frontend completely rewritten in React/TypeScript
- Improved UI/UX with TailwindCSS

## [0.4.0] - 2024-05-01

### Added
- YOLOv8 integration for player detection
- DeepSORT multi-object tracking
- MediaPipe pose estimation
- Basic KPI calculation (speed, distance, positioning)

### Changed
- Migrated from Flask to FastAPI (later reverted to Flask)
- Improved video processing performance

## [0.3.0] - 2024-03-01

### Added
- Video upload and storage system
- Basic player tracking
- Simple metrics calculation
- PostgreSQL database support

### Changed
- Switched from SQLite to PostgreSQL for scalability

## [0.2.0] - 2024-02-01

### Added
- Prototype detection model
- Basic web interface
- Video frame extraction

## [0.1.0] - 2024-01-15

### Added
- Initial project setup
- Basic Flask application
- Literature review and research

---

## Version History Summary

| Version | Date | Key Features |
|---------|------|--------------|
| 0.8.0 | 2025-12-17 | AI feedback, Calendar, QR pairing, SMPL fitting |
| 0.7.0 | 2024-11-15 | GPT-4 integration, ByteTrack, Advanced metrics |
| 0.6.0 | 2024-09-30 | 3D reconstruction, Biomechanics |
| 0.5.0 | 2024-07-15 | React dashboard, Live analysis |
| 0.4.0 | 2024-05-01 | YOLOv8, Pose estimation, KPIs |
| 0.3.0 | 2024-03-01 | Video processing, PostgreSQL |
| 0.2.0 | 2024-02-01 | Prototype detection |
| 0.1.0 | 2024-01-15 | Initial setup |

---

## Upgrade Notes

### Upgrading to 0.8.0

**Breaking Changes:**
- Session API response format changed to nested structure
- Database schema updated (run migrations)
- Environment variables renamed (check `.env.example`)

**Migration Steps:**
```bash
# 1. Backup database
pg_dump axolotl > backup_pre_0.8.0.sql

# 2. Update code
git pull origin main

# 3. Install new dependencies
pip install -r code/requirements.txt --upgrade

# 4. Run database migrations
python app/backend/migrate.py upgrade

# 5. Update environment variables
cp .env .env.backup
cp .env.example .env
# Merge your settings from .env.backup

# 6. Restart services
docker compose down
docker compose up -d
```

---

## Roadmap

See [STATUS.md](STATUS.md) for detailed roadmap.

### Upcoming in v0.9.0 (Q1 2025)
- [ ] Mobile app MVP (iOS/Android)
- [ ] Automated highlight generation
- [ ] Performance optimization (60 FPS target)
- [ ] Enhanced tactical analysis

### Planned for v1.0.0 (Q2 2025)
- [ ] Production launch
- [ ] Team collaboration features
- [ ] Advanced formation detection
- [ ] Public API for integrations

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to contribute to this project.

## License

This project is licensed under the MIT License - see [LICENSE](../../LICENSE) for details.
