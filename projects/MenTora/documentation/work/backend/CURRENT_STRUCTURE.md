# Backend Current Structure

**Last Updated**: 2025-11-22
**Created for**: Phase 0 - Mobile UX Redesign Feature 002

## Overview
The backend is built with FastAPI 0.104.1, Python 3.8+, and Pydantic 2.5.0. It uses Azure Cosmos DB for data storage and implements REST API endpoints for the frontend.

## Directory Structure

```
backend/
├── app/
│   ├── db/                 # Database modules
│   ├── models/             # Pydantic models
│   ├── routes/             # API route handlers
│   ├── schemas/            # Response schemas
│   ├── services/           # Business logic services (MOSTLY EMPTY - NEEDS CREATION)
│   └── __init__.py
├── static/                 # Static files
├── tests/                  # Test files
├── config.py              # Configuration
├── main.py                # Application entry point
├── requirements.txt       # Python dependencies
└── verify_routes.py       # Route verification script
```

## Database Modules (app/db/)

### store.py
Main database interface for Azure Cosmos DB operations.

**Key Functions/Classes**:
- Database connection management
- CRUD operations for learning paths
- CRUD operations for user progress
- CRUD operations for user profiles
- Query methods for filtering and search

**Integration Points**:
- Azure Cosmos DB client
- Connection string from environment variables
- Container management for different entity types

### fallback_store.py
Fallback/mock database for development and testing.

**Purpose**:
- In-memory storage when Cosmos DB unavailable
- Testing without live database
- Development without Azure credentials

## Models (app/models/)

### learning_path.py
Pydantic models for learning path entities.

**Key Models**:
- `LearningPath` - Course/learning path definition
- `Module` - Course module (lesson, exercise, video, quiz)
- `Content` - Module content items
- DSL-related models for course creation

**Attributes** (likely):
- `id`: str
- `title`: str
- `description`: str
- `modules`: List[Module]
- `difficulty`: str
- `duration_weeks`: int
- `category`: str
- `instructor`: str
- `rating`: float
- `students`: int

### progress.py
Pydantic models for user progress tracking.

**Key Models**:
- `UserProgress` - User's progress in a learning path
- `ModuleProgress` - Progress for individual modules
- `ContentProgress` - Progress for content items

**Attributes** (likely):
- `user_id`: str
- `learning_path_id`: str
- `completed_modules`: List[str]
- `current_module`: int
- `completion_percentage`: float
- `streak`: int
- `weekly_progress`: dict
- `points`: int
- `level`: int

### profile.py
Pydantic models for user profiles.

**Key Models**:
- `UserProfile` - User profile and preferences
- `OnboardingData` - Data collected during onboarding

**Attributes** (likely):
- `user_id`: str
- `email`: str
- `name`: str
- `learning_goal`: str
- `experience_level`: str
- `hours_per_week`: int
- `learning_style`: str
- `preferred_topics`: List[str]
- `motivation`: str

## Routes (app/routes/)

### auth.py / auth_fixed.py
Authentication endpoints using Google OAuth.

**Endpoints** (likely):
- `POST /api/auth/google` - Google OAuth callback
- `GET /api/auth/verify` - Verify JWT token
- `POST /api/auth/refresh` - Refresh token
- `POST /api/auth/logout` - Logout user

**Dependencies**:
- Google OAuth library
- JWT token generation/validation
- User session management

### learning_paths.py
Learning path endpoints for students.

**Endpoints** (likely):
- `GET /api/learning-paths` - List all learning paths
- `GET /api/learning-paths/{id}` - Get specific learning path
- `POST /api/learning-paths/{id}/enroll` - Enroll in learning path
- `GET /api/learning-paths/{id}/modules` - Get modules for path

**Missing** (to be added in Phase 1+):
- Search/filter endpoints
- Recommendation endpoints
- Category listing endpoints

### admin_learning_paths.py
Admin endpoints for managing learning paths.

**Endpoints** (likely):
- `POST /api/admin/learning-paths` - Create learning path
- `PUT /api/admin/learning-paths/{id}` - Update learning path
- `DELETE /api/admin/learning-paths/{id}` - Delete learning path
- `POST /api/admin/dsl/parse` - Parse DSL to create course

**Missing** (to be added in Phase 1+):
- DSL preview endpoint
- DSL sanitization endpoint
- Enhanced content type support (video, quiz, exercise)

### progress.py
Progress tracking endpoints.

**Endpoints** (likely):
- `GET /api/progress/{user_id}` - Get user's overall progress
- `GET /api/progress/{user_id}/{path_id}` - Get progress for specific path
- `POST /api/progress/{user_id}/{path_id}/complete` - Mark module complete
- `GET /api/progress/{user_id}/stats` - Get statistics (streak, points, level)

**Missing** (to be added in Phase 1+):
- Continue learning endpoint (next incomplete lesson)
- Recent activity endpoint
- Achievement/badge endpoints

### onboarding.py / onboarding_backup.py / onboarding_clean.py
Onboarding flow endpoints (multiple versions - needs cleanup).

**Endpoints** (likely):
- `POST /api/onboarding/profile` - Submit onboarding data
- `GET /api/onboarding/recommendations` - Get recommended courses
- `POST /api/onboarding/complete` - Complete onboarding

**Note**: Multiple versions suggest refactoring in progress. Needs consolidation in Phase 1.

### payments.py
Stripe payment integration endpoints.

**Endpoints** (likely):
- `POST /api/payment/create-session` - Create Stripe checkout session
- `POST /api/payment/webhook` - Stripe webhook handler
- `GET /api/payment/status` - Check payment status

**Dependencies**:
- Stripe Python SDK
- Webhook signature verification

### seed_data.py
Seed data management endpoints (development/testing).

**Endpoints** (likely):
- `POST /api/seed-data/populate` - Populate database with sample data
- `DELETE /api/seed-data/clear` - Clear all seed data
- `GET /api/seed-data/status` - Check seed data status

## Schemas (app/schemas/)

### response.py
Standardized response schemas.

**Likely Schemas**:
- `SuccessResponse` - Standard success response
- `ErrorResponse` - Standard error response
- `PaginatedResponse` - Paginated list response

## Services (app/services/)

### Current State
**⚠️ CRITICAL**: Services directory exists but is MOSTLY EMPTY except for stripe_service.py

### stripe_service.py
Stripe payment service logic.

**Functions** (likely):
- Create checkout session
- Handle webhooks
- Process payments
- Manage subscriptions

### Missing Services (To Create in Phase 1)
According to tasks.md Phase 1, these services MUST be created:

1. **CourseService** (backend/app/services/course_service.py)
   - Search courses with filters
   - Get course recommendations
   - Get course categories
   - CRUD operations for courses

2. **LearningPathService** (backend/app/services/learning_path_service.py)
   - Generate path visualization data (path_nodes)
   - Get learning path details
   - Manage module structure

3. **ProgressService** (backend/app/services/progress_service.py)
   - Track user progress
   - Calculate streak, weekly progress
   - Get enrolled courses
   - Get recent activity
   - Find next incomplete lesson

4. **DSLService** (backend/app/services/dsl_service.py)
   - Parse DSL syntax
   - Support VIDEO, QUIZ, EXERCISE, SUMMARY syntax
   - Generate preview HTML
   - Sanitize content (XSS prevention)

## Configuration (config.py)

**Configuration Items** (likely):
- Azure Cosmos DB connection string
- Stripe API keys
- Google OAuth credentials
- JWT secret key
- CORS origins
- Environment (dev/staging/production)

**Missing** (to be added in Phase 1+):
- Structlog configuration for JSON logging
- Bleach sanitization configuration
- Rate limiting configuration

## Main Application (main.py)

**FastAPI Application Setup**:
- App initialization
- CORS middleware
- Route registration
- Exception handlers
- Startup/shutdown events

**Current Routes Registered** (from route files):
- `/api/auth/*` - Authentication
- `/api/learning-paths/*` - Learning paths
- `/api/admin/*` - Admin operations
- `/api/progress/*` - Progress tracking
- `/api/onboarding/*` - Onboarding
- `/api/payment/*` - Payments
- `/api/seed-data/*` - Seed data

## Dependencies (requirements.txt)

### Core Framework
- **fastapi**: 0.104.1 ✅
- **uvicorn[standard]**: 0.24.0 ✅
- **pydantic**: 2.5.0 ✅
- **python-dotenv**: 1.0.0 ✅

### Authentication & Security
- **python-jose[cryptography]**: 3.3.0 ✅
- **passlib[bcrypt]**: 1.7.4 ✅
- **google-auth**: 2.23.4 ✅
- **google-auth-oauthlib**: 1.1.0 ✅
- **google-auth-httplib2**: 0.1.1 ✅

### Database
- **azure-cosmos**: 4.5.1 ✅

### Payments
- **stripe**: 7.8.0 ✅

### Content Sanitization
- **bleach**: 6.1.0 ✅ (XSS prevention - available but usage needs verification)

### Other
- **python-multipart**: 0.0.6 ✅ (file uploads)
- **gunicorn**: 21.2.0 ✅ (production server)

### Missing Dependencies (To Add in Phase 1+)
- **structlog**: ~23.x (structured JSON logging)
- **redis** or **redis-py**: (if caching added later)

## Testing

### Tests Directory
Located in `backend/tests/`

**Existing Tests**:
- Test files in parent directory:
  - `test_comprehensive_lesson.py`
  - `test_lesson_simple.py`
  - `test_lesson_standalone.py`

**Testing Framework** (assumed):
- pytest
- pytest-asyncio (for async tests)
- pytest-cov (for coverage)

**Missing Tests** (to be added in Phase 1+):
- Service layer tests (CourseService, LearningPathService, etc.)
- Route tests for new endpoints
- Model validation tests
- Integration tests

## API Endpoints Summary

### Current Endpoints

**Authentication**:
- `POST /api/auth/google`
- `GET /api/auth/verify`
- `POST /api/auth/refresh`

**Learning Paths**:
- `GET /api/learning-paths`
- `GET /api/learning-paths/{id}`
- `POST /api/learning-paths/{id}/enroll`

**Admin Learning Paths**:
- `POST /api/admin/learning-paths`
- `PUT /api/admin/learning-paths/{id}`
- `DELETE /api/admin/learning-paths/{id}`
- `POST /api/admin/dsl/parse`

**Progress**:
- `GET /api/progress/{user_id}`
- `GET /api/progress/{user_id}/{path_id}`
- `POST /api/progress/{user_id}/{path_id}/complete`

**Onboarding**:
- `POST /api/onboarding/profile`
- `GET /api/onboarding/recommendations`

**Payments**:
- `POST /api/payment/create-session`
- `POST /api/payment/webhook`
- `GET /api/payment/status`

**Seed Data**:
- `POST /api/seed-data/populate`
- `DELETE /api/seed-data/clear`

### Missing Endpoints (To Add in Phase 1+)

**Course Discovery**:
- `GET /api/v1/courses/search` - Search with filters (FR-011)
- `GET /api/v1/courses/categories` - Get categories (FR-013)
- `GET /api/v1/courses/recommendations` - Get recommendations (FR-024)

**Learning Path Visualization**:
- `GET /api/v1/learning-paths/{id}/path-nodes` - Get path visualization (FR-026)

**Progress Extensions**:
- `GET /api/v1/progress/{course_id}/continue` - Get next lesson (FR-043)
- `GET /api/v1/progress/{user_id}/recent-activity` - Recent activity (FR-042)
- `GET /api/v1/progress/{user_id}/enrolled-courses` - Enrolled courses (FR-041)

**Admin DSL Extensions**:
- `POST /api/v1/admin/dsl/preview` - Preview DSL (FR-064)
- `POST /api/v1/admin/dsl/sanitize` - Sanitize DSL (FR-066)

## Integration Points

### Azure Cosmos DB
- **Connection**: Via azure-cosmos SDK
- **Containers**: 
  - learning_paths
  - user_progress
  - user_profiles
  - (others to be confirmed)
- **Queries**: Direct SQL queries via Cosmos DB SDK
- **Indexes**: Need to add composite indexes for filtering (Phase 2)

### Google OAuth
- **Library**: google-auth, google-auth-oauthlib
- **Flow**: Frontend receives token → Backend verifies token
- **JWT**: python-jose for token generation

### Stripe
- **Library**: stripe SDK
- **Integration**: Checkout sessions, webhooks
- **Service**: stripe_service.py

### Frontend Integration
- **CORS**: Configured for frontend origin
- **Response Format**: JSON responses
- **Authentication**: JWT tokens in Authorization header

## Phase 1 Service Layer Requirements

### Constitution Compliance
The codebase violates Constitution Principle V (Modular & Maintainable Code) by having business logic directly in route handlers instead of a service layer.

### Service Layer Pattern (Required)
All business logic MUST be moved to service classes:

```
Route Handler (routes/*.py)
    ↓
Service Layer (services/*.py)
    ↓
Database Layer (db/store.py)
```

### Phase 1 Tasks (T014-T018)
1. **T014**: Create CourseService skeleton
2. **T015**: Create LearningPathService skeleton
3. **T016**: Create ProgressService skeleton
4. **T017**: Create DSLService skeleton
5. **T018**: Migrate route logic to services

## Notes for Phase 1+ Implementation

### Must Preserve
- ✅ Existing API contracts (don't break frontend)
- ✅ Azure Cosmos DB integration
- ✅ Google OAuth authentication flow
- ✅ Stripe payment integration
- ✅ JWT token validation
- ✅ Current database schema

### Must Refactor
- ⬜ Extract business logic to service layer
- ⬜ Consolidate onboarding routes (3 versions → 1)
- ⬜ Add service layer tests
- ⬜ Add structured logging (structlog)

### Must Add (Phase 1+)
- ⬜ CourseService with search/filter/recommendations
- ⬜ LearningPathService with path visualization
- ⬜ ProgressService with enhanced tracking
- ⬜ DSLService with enhanced parsing (video, quiz, exercise)
- ⬜ Bleach sanitization integration
- ⬜ Rate limiting middleware
- ⬜ Composite indexes in Cosmos DB
- ⬜ New API endpoints for mobile UX features

### Must Test
- ⬜ Service layer unit tests
- ⬜ Route integration tests
- ⬜ Model validation tests
- ⬜ DSL parsing tests
- ⬜ Sanitization tests

## Conclusion

The backend is functional but needs significant enhancement to support mobile UX redesign:
- Service layer is MISSING (only stripe_service.py exists)
- Business logic is in route handlers (violates Constitution)
- Many endpoints for feature 002 are missing
- No structured logging (structlog not configured)
- Bleach installed but usage not verified
- Multiple versions of some routes need consolidation

Phase 1 will create the service layer foundation and prepare for feature 002 implementation.
