# Database Schema

## Table of Contents
- [Overview](#overview)
- [Database Technology](#database-technology)
- [Schema Organization](#schema-organization)
- [Core Tables](#core-tables)
- [JSON Schemas](#json-schemas)
- [Indexes and Performance](#indexes-and-performance)
- [Migrations](#migrations)
- [Data Models](#data-models)

## Overview

The Axolotl platform uses a hybrid data storage approach:
- **Relational Database**: PostgreSQL (production) or SQLite (development) for structured data
- **Azure Blob Storage**: Video files and large media assets
- **Azure Cognitive Search**: Full-text search and RAG system indexing
- **Redis**: Caching and background job queues

This document focuses on the relational database schema and data models.

## Database Technology

### Development Environment
- **Database**: SQLite 3.x
- **File Location**: `data/axolotl.db` (git-ignored)
- **Connection String**: `sqlite:///data/axolotl.db`

### Production Environment
- **Database**: PostgreSQL 15+
- **Managed Service**: Azure Database for PostgreSQL
- **Connection String**: Set via `DATABASE_URL` environment variable

### ORM
- **Tool**: SQLAlchemy 1.4+
- **Features**: 
  - Declarative models
  - Automatic schema generation
  - Migration support via Alembic
  - Connection pooling

## Schema Organization

The database schema is organized into logical domains:

```
Database
├── Sessions & Analysis
│   ├── sessions            # Training/match sessions
│   ├── session_kpis       # Calculated performance metrics
│   └── session_files      # Attached media files
├── Players & Users
│   ├── players            # Player profiles
│   ├── users              # User accounts
│   └── teams              # Team/organization data
├── Calendar & Planning
│   ├── training_events    # Scheduled training
│   ├── event_drills       # Drill definitions
│   └── recommendations    # AI-generated plans
├── Devices & Pairing
│   ├── paired_devices     # Mobile/edge devices
│   └── pairing_tokens     # QR code tokens
├── AI & Processing
│   ├── feedback_history   # AI coaching feedback
│   ├── processing_jobs    # Background jobs
│   └── model_versions     # AI model tracking
└── RAG System
    ├── document_index     # Searchable documents
    └── embeddings         # Vector embeddings
```

## Core Tables

### Sessions Table

Stores training and match session metadata.

```sql
CREATE TABLE sessions (
    id VARCHAR(50) PRIMARY KEY,
    player_id VARCHAR(50) NOT NULL,
    user_id VARCHAR(50),
    session_type VARCHAR(20) NOT NULL,  -- 'training', 'match', 'analysis'
    title VARCHAR(200),
    description TEXT,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    duration_seconds INTEGER,
    video_path VARCHAR(500),
    status VARCHAR(20) DEFAULT 'pending',  -- 'pending', 'processing', 'completed', 'failed'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB,  -- Flexible metadata storage
    
    FOREIGN KEY (player_id) REFERENCES players(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX idx_sessions_player_id ON sessions(player_id);
CREATE INDEX idx_sessions_created_at ON sessions(created_at DESC);
CREATE INDEX idx_sessions_status ON sessions(status);
```

**Fields**:
- `id`: Unique session identifier (e.g., `sess_20251024_001`)
- `player_id`: Reference to player being analyzed
- `session_type`: Type of session
- `status`: Processing status
- `metadata`: JSON field for flexible data (camera settings, weather, etc.)

### Session KPIs Table

Stores calculated performance metrics for each session.

```sql
CREATE TABLE session_kpis (
    id SERIAL PRIMARY KEY,
    session_id VARCHAR(50) NOT NULL,
    
    -- Speed metrics
    max_speed_kmh FLOAT,
    avg_speed_kmh FLOAT,
    speed_zones JSONB,  -- Time in different speed zones
    
    -- Distance metrics
    total_distance_m FLOAT,
    high_intensity_distance_m FLOAT,
    sprint_distance_m FLOAT,
    
    -- Technical metrics
    touches INTEGER,
    passes INTEGER,
    pass_accuracy FLOAT,
    shots INTEGER,
    
    -- Physical metrics
    accelerations INTEGER,
    decelerations INTEGER,
    max_acceleration FLOAT,
    jumps INTEGER,
    
    -- Load metrics
    training_load FLOAT,
    player_load FLOAT,
    intensity_score FLOAT,
    
    -- Timestamps
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX idx_session_kpis_session ON session_kpis(session_id);
```

### Players Table

Player profiles and biographical information.

```sql
CREATE TABLE players (
    id VARCHAR(50) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    position VARCHAR(50),  -- 'forward', 'midfielder', 'defender', 'goalkeeper'
    jersey_number INTEGER,
    height_cm INTEGER,
    weight_kg INTEGER,
    team_id VARCHAR(50),
    
    -- Profile data
    profile_image_url VARCHAR(500),
    bio TEXT,
    
    -- Settings
    preferred_unit_system VARCHAR(10) DEFAULT 'metric',  -- 'metric', 'imperial'
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (team_id) REFERENCES teams(id)
);

CREATE INDEX idx_players_team ON players(team_id);
CREATE INDEX idx_players_name ON players(last_name, first_name);
```

### Training Events Table

Calendar events for training planning.

```sql
CREATE TABLE training_events (
    id VARCHAR(50) PRIMARY KEY,
    player_id VARCHAR(50) NOT NULL,
    user_id VARCHAR(50),
    
    -- Event details
    title VARCHAR(200) NOT NULL,
    description TEXT,
    event_type VARCHAR(20) NOT NULL,  -- 'training', 'match', 'recovery', 'assessment'
    
    -- Scheduling
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    all_day BOOLEAN DEFAULT FALSE,
    
    -- Planning
    drills JSONB,  -- Array of drill definitions
    target_kpis JSONB,  -- Target performance metrics
    ai_generated BOOLEAN DEFAULT FALSE,
    recommendation_id VARCHAR(50),
    
    -- Status
    status VARCHAR(20) DEFAULT 'scheduled',  -- 'scheduled', 'in_progress', 'completed', 'cancelled'
    completed_session_id VARCHAR(50),  -- Link to actual session if completed
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (player_id) REFERENCES players(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (completed_session_id) REFERENCES sessions(id)
);

CREATE INDEX idx_events_player ON training_events(player_id);
CREATE INDEX idx_events_time ON training_events(start_time);
CREATE INDEX idx_events_status ON training_events(status);
```

### Paired Devices Table

Mobile and edge device pairing information.

```sql
CREATE TABLE paired_devices (
    id VARCHAR(50) PRIMARY KEY,
    device_name VARCHAR(100),
    device_type VARCHAR(20) NOT NULL,  -- 'mobile', 'edge', 'camera'
    
    -- Authentication
    api_key VARCHAR(100) UNIQUE NOT NULL,
    pairing_code VARCHAR(20),
    
    -- Association
    user_id VARCHAR(50),
    player_id VARCHAR(50),
    
    -- Device info
    device_model VARCHAR(100),
    os_version VARCHAR(50),
    app_version VARCHAR(50),
    
    -- Status
    status VARCHAR(20) DEFAULT 'active',  -- 'active', 'inactive', 'revoked'
    last_seen TIMESTAMP,
    
    -- Timestamps
    paired_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (player_id) REFERENCES players(id)
);

CREATE INDEX idx_devices_user ON paired_devices(user_id);
CREATE INDEX idx_devices_player ON paired_devices(player_id);
CREATE INDEX idx_devices_status ON paired_devices(status);
```

### Feedback History Table

AI-generated coaching feedback records.

```sql
CREATE TABLE feedback_history (
    id VARCHAR(50) PRIMARY KEY,
    session_id VARCHAR(50) NOT NULL,
    player_id VARCHAR(50) NOT NULL,
    
    -- Feedback content
    feedback_text TEXT NOT NULL,
    feedback_type VARCHAR(20),  -- 'technical', 'physical', 'tactical', 'general'
    priority VARCHAR(10),  -- 'high', 'medium', 'low'
    
    -- AI metadata
    model_used VARCHAR(50),
    prompt_tokens INTEGER,
    completion_tokens INTEGER,
    rag_sources JSONB,  -- Documents used for context
    
    -- User interaction
    user_rating INTEGER,  -- 1-5 star rating
    user_notes TEXT,
    dismissed BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (session_id) REFERENCES sessions(id),
    FOREIGN KEY (player_id) REFERENCES players(id)
);

CREATE INDEX idx_feedback_session ON feedback_history(session_id);
CREATE INDEX idx_feedback_player ON feedback_history(player_id);
CREATE INDEX idx_feedback_generated ON feedback_history(generated_at DESC);
```

### Processing Jobs Table

Background job tracking for async operations.

```sql
CREATE TABLE processing_jobs (
    id VARCHAR(50) PRIMARY KEY,
    job_type VARCHAR(50) NOT NULL,  -- 'video_processing', 'smpl_fitting', '3d_reconstruction'
    
    -- Job details
    session_id VARCHAR(50),
    input_data JSONB,
    output_data JSONB,
    
    -- Status tracking
    status VARCHAR(20) DEFAULT 'queued',  -- 'queued', 'running', 'completed', 'failed'
    progress_percent INTEGER DEFAULT 0,
    error_message TEXT,
    
    -- Performance metrics
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    duration_seconds INTEGER,
    
    -- Queue info
    queue_name VARCHAR(50),
    worker_id VARCHAR(50),
    retry_count INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (session_id) REFERENCES sessions(id)
);

CREATE INDEX idx_jobs_status ON processing_jobs(status);
CREATE INDEX idx_jobs_session ON processing_jobs(session_id);
CREATE INDEX idx_jobs_created ON processing_jobs(created_at DESC);
```

### Users Table

User accounts and authentication.

```sql
CREATE TABLE users (
    id VARCHAR(50) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE,
    
    -- Profile
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role VARCHAR(20) DEFAULT 'coach',  -- 'admin', 'coach', 'analyst', 'player'
    
    -- Authentication (if using local auth)
    password_hash VARCHAR(255),
    api_key VARCHAR(100) UNIQUE,
    
    -- Settings
    preferences JSONB,
    timezone VARCHAR(50) DEFAULT 'UTC',
    language VARCHAR(10) DEFAULT 'en',
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
```

### Teams Table

Team/organization information.

```sql
CREATE TABLE teams (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    
    -- Organization details
    club_name VARCHAR(200),
    league VARCHAR(100),
    age_group VARCHAR(50),  -- 'U12', 'U15', 'U18', 'Senior'
    
    -- Contact
    email VARCHAR(255),
    phone VARCHAR(50),
    
    -- Logo and branding
    logo_url VARCHAR(500),
    primary_color VARCHAR(10),
    secondary_color VARCHAR(10),
    
    -- Settings
    default_training_duration_minutes INTEGER DEFAULT 90,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## JSON Schemas

The platform uses JSON schemas to validate structured data stored in JSONB fields and Azure Cognitive Search.

### Training Session Schema

**File**: `schemas/training_session.schema.json`

Used for indexing sessions in the RAG system.

```json
{
  "id": "training_sess_20251024_001",
  "user_id": "user_123",
  "player_id": "player_456",
  "session_id": "sess_20251024_001",
  "doc_type": "training_session",
  "content": {
    "digest_text": "Session summary with key findings...",
    "biomech_summary": {
      "max_speed": 28.5,
      "total_distance": 8200,
      "high_intensity_runs": 15,
      "sprint_count": 8
    },
    "technical_highlights": [
      "Strong passing accuracy (87%)",
      "Good first touch control"
    ]
  },
  "start_timestamp": "2025-10-24T10:00:00Z",
  "end_timestamp": "2025-10-24T11:30:00Z",
  "embedding_model": "text-embedding-3-large",
  "created_at": "2025-10-24T11:35:00Z"
}
```

### Match Segment Schema

**File**: `schemas/match_segment.schema.json`

Used for event spotting and match analysis.

```json
{
  "id": "match_seg_20251024_001",
  "match_id": "match_123",
  "segment_type": "shot",
  "timestamp_start": 125.5,
  "timestamp_end": 130.2,
  "player_id": "player_456",
  "metadata": {
    "outcome": "goal",
    "location": {"x": 85, "y": 45},
    "foot": "right"
  },
  "confidence": 0.92
}
```

### Knowledge Base Schema

**File**: `schemas/knowledge_base.schema.json`

Used for external knowledge articles in RAG system.

```json
{
  "id": "kb_article_001",
  "doc_type": "knowledge_base",
  "title": "Speed Training Best Practices",
  "content": {
    "full_text": "Article content...",
    "summary": "Brief summary..."
  },
  "category": "physical_training",
  "tags": ["speed", "sprinting", "acceleration"],
  "author": "Coach Smith",
  "embedding_model": "text-embedding-3-large",
  "created_at": "2025-10-24T00:00:00Z"
}
```

### RAG Registry Schema

**File**: `schemas/rag_registry.schema.json`

Tracks document ingestion in RAG system.

```json
{
  "id": "reg_001",
  "source_type": "training_session",
  "source_id": "sess_20251024_001",
  "azure_doc_id": "training_sess_20251024_001",
  "indexed_at": "2025-10-24T11:35:00Z",
  "status": "indexed",
  "embedding_model": "text-embedding-3-large"
}
```

## Indexes and Performance

### Primary Indexes

All tables have primary key indexes automatically created.

### Secondary Indexes

Strategic indexes for common query patterns:

```sql
-- Session queries
CREATE INDEX idx_sessions_player_created ON sessions(player_id, created_at DESC);
CREATE INDEX idx_sessions_status_type ON sessions(status, session_type);

-- KPI lookups
CREATE INDEX idx_kpis_player_date ON session_kpis(
    player_id, 
    calculated_at DESC
);

-- Calendar queries
CREATE INDEX idx_events_player_time ON training_events(
    player_id,
    start_time,
    status
);

-- Feedback queries
CREATE INDEX idx_feedback_player_session ON feedback_history(
    player_id,
    session_id,
    generated_at DESC
);
```

### JSONB Indexes

For efficient querying of JSON fields:

```sql
-- GIN indexes for JSONB containment queries
CREATE INDEX idx_sessions_metadata_gin ON sessions USING GIN (metadata);
CREATE INDEX idx_kpis_speed_zones_gin ON session_kpis USING GIN (speed_zones);
CREATE INDEX idx_events_drills_gin ON training_events USING GIN (drills);
```

### Full-Text Search

For text search capabilities:

```sql
-- Full-text search indexes
CREATE INDEX idx_sessions_title_fts ON sessions 
USING GIN (to_tsvector('english', title || ' ' || COALESCE(description, '')));

CREATE INDEX idx_feedback_text_fts ON feedback_history
USING GIN (to_tsvector('english', feedback_text));
```

## Migrations

### Migration Tool

The project uses Alembic for database migrations.

**Location**: `migrations/`

### Creating Migrations

```bash
# Create a new migration
alembic revision --autogenerate -m "Add new column to sessions"

# Apply migrations
alembic upgrade head

# Rollback one migration
alembic downgrade -1

# View migration history
alembic history
```

### Migration Example

```python
# migrations/versions/001_add_sessions_table.py
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import JSONB

def upgrade():
    op.create_table(
        'sessions',
        sa.Column('id', sa.String(50), primary_key=True),
        sa.Column('player_id', sa.String(50), nullable=False),
        sa.Column('session_type', sa.String(20), nullable=False),
        sa.Column('status', sa.String(20), server_default='pending'),
        sa.Column('metadata', JSONB, nullable=True),
        sa.Column('created_at', sa.DateTime, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(['player_id'], ['players.id'])
    )
    
    op.create_index('idx_sessions_player_id', 'sessions', ['player_id'])

def downgrade():
    op.drop_index('idx_sessions_player_id')
    op.drop_table('sessions')
```

## Data Models

### SQLAlchemy Models

Models are defined using SQLAlchemy's declarative base.

**Example Model**:

```python
# app/backend/models.py
from sqlalchemy import Column, String, Integer, Float, DateTime, Boolean, ForeignKey, JSON
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from datetime import datetime

Base = declarative_base()

class Session(Base):
    __tablename__ = 'sessions'
    
    id = Column(String(50), primary_key=True)
    player_id = Column(String(50), ForeignKey('players.id'), nullable=False)
    user_id = Column(String(50), ForeignKey('users.id'))
    session_type = Column(String(20), nullable=False)
    title = Column(String(200))
    description = Column(String)
    start_time = Column(DateTime)
    end_time = Column(DateTime)
    duration_seconds = Column(Integer)
    video_path = Column(String(500))
    status = Column(String(20), default='pending')
    metadata = Column(JSON)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    player = relationship("Player", back_populates="sessions")
    kpis = relationship("SessionKPI", back_populates="session", uselist=False)
    feedback = relationship("FeedbackHistory", back_populates="session")
    
    def __repr__(self):
        return f"<Session(id={self.id}, player_id={self.player_id}, type={self.session_type})>"

class SessionKPI(Base):
    __tablename__ = 'session_kpis'
    
    id = Column(Integer, primary_key=True)
    session_id = Column(String(50), ForeignKey('sessions.id', ondelete='CASCADE'), unique=True)
    
    # Speed metrics
    max_speed_kmh = Column(Float)
    avg_speed_kmh = Column(Float)
    speed_zones = Column(JSON)
    
    # Distance metrics
    total_distance_m = Column(Float)
    high_intensity_distance_m = Column(Float)
    sprint_distance_m = Column(Float)
    
    # Technical metrics
    touches = Column(Integer)
    passes = Column(Integer)
    pass_accuracy = Column(Float)
    
    calculated_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    session = relationship("Session", back_populates="kpis")

class Player(Base):
    __tablename__ = 'players'
    
    id = Column(String(50), primary_key=True)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    date_of_birth = Column(DateTime)
    position = Column(String(50))
    jersey_number = Column(Integer)
    team_id = Column(String(50), ForeignKey('teams.id'))
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    sessions = relationship("Session", back_populates="player")
    team = relationship("Team", back_populates="players")
    
    @property
    def full_name(self):
        return f"{self.first_name} {self.last_name}"
```

### Database Connection

```python
# app/backend/database.py
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import os

DATABASE_URL = os.getenv('DATABASE_URL', 'sqlite:///data/axolotl.db')

engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
    pool_size=10,
    max_overflow=20
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    """Dependency for FastAPI/Flask routes."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

## Related Documentation

- [System Architecture Overview](overview.md)
- [Backend Architecture](backend.md)
- [API Reference](api-reference.md)
- [RAG System Documentation](../ai-ml/rag-system.md)
- [Deployment Guide](../deployment/production.md)
