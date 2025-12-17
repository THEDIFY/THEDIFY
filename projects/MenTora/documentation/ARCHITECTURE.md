# MenTora Architecture

## Overview

MenTora is an AI-powered learning platform built with a modern tech stack emphasizing performance, scalability, and user experience.

## Technology Stack

### Backend
- **FastAPI** (Python 3.8+) - High-performance async web framework
- **Pydantic** - Data validation and settings management
- **Azure Cosmos DB** - NoSQL database with global distribution
- **JWT** - Stateless authentication
- **Bleach** - HTML sanitization for security
- **Structlog** - Structured logging

### Frontend
- **React 19** - UI framework with concurrent features
- **TypeScript** - Type-safe JavaScript
- **Tailwind CSS** - Utility-first CSS framework
- **Framer Motion** - Animation library
- **Zustand** - Lightweight state management
- **TanStack Query** - Data fetching and caching
- **Vite** - Next-generation frontend build tool
- **PWA** - Progressive Web App support

### Infrastructure
- **Azure Container Instances** - Container hosting
- **Azure CDN** - Global content delivery
- **GitHub Actions** - CI/CD automation

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        FRONTEND (React 19)                       │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────┐    │
│  │  Pages   │  │Components│  │  Hooks   │  │   Stores     │    │
│  ├──────────┤  ├──────────┤  ├──────────┤  ├──────────────┤    │
│  │Welcome   │  │Dashboard │  │useSearch │  │NavigationStore│   │
│  │Courses   │  │CourseGrid│  │usePlatform│ │ThemeStore    │    │
│  │Learning  │  │LessonView│  │useCourse │  │              │    │
│  │Admin     │  │Navigation│  │          │  │              │    │
│  └──────────┘  └──────────┘  └──────────┘  └──────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼ REST API
┌─────────────────────────────────────────────────────────────────┐
│                      BACKEND (FastAPI)                           │
├─────────────────────────────────────────────────────────────────┤
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐    │
│  │    Routes      │  │   Services     │  │    Utils       │    │
│  ├────────────────┤  ├────────────────┤  ├────────────────┤    │
│  │/api/v1/auth    │  │CourseService   │  │sanitization    │    │
│  │/api/v1/courses │  │ProgressService │  │structured_log  │    │
│  │/api/v1/learning│  │LearningPathSvc │  │jwt_auth        │    │
│  │/api/v1/admin   │  │DSLService      │  │                │    │
│  └────────────────┘  └────────────────┘  └────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼ Database
┌─────────────────────────────────────────────────────────────────┐
│                    AZURE COSMOS DB                               │
├─────────────────────────────────────────────────────────────────┤
│  ┌────────────┐  ┌────────────┐  ┌────────────┐                │
│  │  Courses   │  │   Users    │  │  Progress  │                │
│  │ Container  │  │ Container  │  │ Container  │                │
│  └────────────┘  └────────────┘  └────────────┘                │
└─────────────────────────────────────────────────────────────────┘
```

## Component Architecture

### Frontend Components (Phase 1-8)

#### Navigation Components
- `DesktopNav.tsx` - Fixed left-side panel for desktop (≥1024px)
- `MobileNav.tsx` - Bottom navigation bar for mobile (<1024px)
- `NavItem.tsx` - Universal navigation item component

#### Dashboard Components
- `Dashboard.tsx` - Main user dashboard with stats and courses
- `DashboardStats.tsx` - Weekly progress and streak display
- `EnrolledCourseCard.tsx` - Course card with progress indicator
- `RecentActivityList.tsx` - Recent learning activity
- `AchievementBadges.tsx` - User achievements display

#### Course Components
- `CourseGrid.tsx` - Responsive course grid with infinite scroll
- `CourseCard.tsx` - Course card with metadata and progress
- `CourseFilters.tsx` - Category and difficulty filters
- `SearchBar.tsx` - Debounced course search

#### Learning Components
- `LessonViewer.tsx` - Content viewer with module navigation
- `VideoContent.tsx` - YouTube/Vimeo embed with responsive sizing
- `QuizContent.tsx` - Interactive quiz with validation
- `ExerciseContent.tsx` - Code editor with Pyodide execution
- `PathVisualization.tsx` - SVG-based learning path visualization
- `LessonNode.tsx` - Interactive lesson node in visualization

#### Admin Components
- `DSLEditor.tsx` - Syntax-highlighted DSL code editor
- `DSLPreview.tsx` - Real-time course preview

#### Theme Components
- `ThemeToggle.tsx` - Bright/dark mode toggle

### Backend Services (Phase 1-8)

#### CourseService
- `search_courses()` - Full-text search with pagination
- `get_course_by_id()` - Get course by ID
- `get_categories()` - Get all categories with counts
- `get_recommendations()` - AI-powered course recommendations

#### LearningPathService
- `get_learning_path()` - Get path by ID or slug
- `generate_path_nodes()` - Generate visualization nodes
- `get_next_lesson()` - Find next uncompleted lesson
- `calculate_path_progress()` - Calculate overall progress

#### ProgressService
- `get_user_progress()` - Get user's learning progress
- `update_lesson_progress()` - Update on content completion
- `calculate_streak()` - Calculate learning streak
- `get_weekly_progress()` - Get this week's stats

#### DSLService
- `parse_dsl()` - Parse DSL into course structure
- `validate_dsl()` - Validate DSL syntax
- `sanitize_content()` - XSS prevention
- `generate_preview()` - Generate HTML preview

## State Management

### NavigationStore (Zustand)
Manages navigation state across the app:
- `currentStep` - Current route/step
- `previousStep` - Previous step for back navigation
- `platform` - Detected platform (windows/ios/android)
- `viewportWidth` - Current viewport width
- `showBottomNav` / `showLeftPanel` - Navigation visibility

### ThemeStore (Zustand)
Manages theme preferences:
- `theme` - Current theme ('bright' | 'dark')
- `toggleTheme()` - Toggle between themes
- Persisted to localStorage

## API Endpoints

### Authentication
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/register` - User registration
- `GET /api/v1/auth/me` - Get current user

### Courses
- `GET /api/v1/courses/search` - Search courses with filters
- `GET /api/v1/courses/{id}` - Get course details
- `GET /api/v1/courses/categories` - Get all categories
- `GET /api/v1/courses/recommendations` - Get personalized recommendations

### Learning Paths
- `GET /api/v1/learning-paths/{slug}` - Get learning path
- `GET /api/v1/learning-paths/{slug}/visualization` - Get path with nodes
- `POST /api/v1/learning-paths/enroll` - Enroll in path
- `POST /api/v1/learning-paths/{id}/progress` - Update progress

### Admin
- `POST /api/v1/admin/learning-paths` - Create course from DSL
- `PUT /api/v1/admin/learning-paths/{id}` - Update course
- `POST /api/v1/admin/learning-paths/validate` - Validate DSL
- `POST /api/v1/admin/learning-paths/preview` - Preview DSL

## Security

### Authentication
- JWT tokens with configurable expiration
- Secure password hashing with bcrypt
- Google OAuth integration

### Content Security
- Bleach sanitization for all user-generated content
- Video URL whitelist (YouTube, Vimeo only)
- XSS prevention in DSL parsing

### API Security
- Rate limiting (configurable per endpoint)
- CORS configuration for allowed origins
- Input validation with Pydantic

## Performance Optimizations

### Frontend
- Code splitting with React.lazy
- Image lazy loading
- Infinite scroll with cursor pagination
- Debounced search (300ms)
- Optimistic UI updates

### Backend
- Async FastAPI endpoints
- Connection pooling for Cosmos DB
- Query optimization with composite indexes
- Response caching (configurable TTL)

## Deployment

### Development
```bash
# Start with enhanced script
.\start-enhanced.ps1

# Or manual startup
cd backend && uvicorn main:app --reload
cd frontend && npm run dev
```

### Production
See `PRODUCTION_DEPLOYMENT.md` for complete deployment guide.

## Related Documentation

- `README.md` - Quick start guide
- `PRODUCTION_DEPLOYMENT.md` - Production deployment
- `ADMIN_ACCESS_GUIDE.md` - Admin access configuration
- `LEARNING_PATH_FORMAT_GUIDE.md` - DSL format specification
- `specs/002-mobile-ux-redesign/` - Complete feature specification
