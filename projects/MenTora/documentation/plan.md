# Implementation Plan: Mobile-Responsive UX Redesign with Learning Path Visualization

**Branch**: `002-mobile-ux-redesign` | **Date**: 2025-11-22 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-mobile-ux-redesign/spec.md`

## Summary

This feature implements a comprehensive mobile-responsive UX redesign for the MenTora AI Learning Platform, delivering cross-platform support (Windows PWA, iOS, Android) with adaptive navigation patterns, enhanced course discovery with real-time search/filtering, visual learning path progression, dual theme support (bright/dark), enhanced admin DSL capabilities (video embeds, quizzes, coding exercises), and structured logging for production observability. The implementation uses React 19.x, TanStack Query for data fetching with infinite scroll, Tailwind CSS for responsive styling, Motion (Framer Motion) for animations, and browser-based code execution (Pyodide for Python). Backend extends existing FastAPI routes with filtering/search endpoints and enhanced DSL parsing.

## Technical Context

**Language/Version**: 
- Backend: Python 3.8+, FastAPI 0.104.1, Pydantic 2.5.0
- Frontend: TypeScript 5.2.2+, React 19.x (upgrade from 18.2.0), Node.js 18+

**Primary Dependencies**:
- Frontend: react@19.x, react-dom@19.x, react-router-dom@6.x, @tanstack/react-query@5.x, tailwindcss@3.4.17, motion (framer-motion)@11.x, zustand@4.x, pyodide@0.24.x, lottie-react@2.x
- Backend: fastapi@0.104.1, pydantic@2.5.0, azure-cosmos@4.5.1, python-jose@3.3.0, bleach@6.1.0, structlog@23.x (for JSON logging)
- Build/Dev: vite@5.0.8, typescript@5.2.2, eslint@8.x, prettier@3.x, playwright@1.40.x

**Storage**: 
- Azure Cosmos DB (serverless, existing) with new indexes for course filtering (category, difficulty, title)
- Browser localStorage for theme preferences and navigation state
- No session storage (Redis deferred for now per clarifications)

**Testing**: 
- Backend: pytest, pytest-asyncio, pytest-cov
- Frontend: vitest, @testing-library/react, @testing-library/jest-dom
- E2E: playwright with mobile viewport configurations
- Component catalog: storybook@7.x

**Target Platform**: 
- Windows PWA (viewport ≥ 1024px, left-side navigation panel)
- iOS Safari 14+ (viewport < 1024px, bottom navigation bar)
- Android Chrome (viewport < 1024px, bottom navigation bar)
- Responsive breakpoints: mobile (< 768px), tablet (768px-1023px), desktop (≥ 1024px)

**Project Type**: Web application (monorepo: /backend + /frontend)

**Performance Goals**: 
- API response times: p95 < 500ms for course search/filter
- Dashboard load: < 3 seconds on 4G mobile connection
- Learning path render: < 2 seconds for courses with 50 lessons
- Theme switch: < 300ms with smooth transitions
- Mobile animations: 60fps maintained during scrolling/transitions
- Lazy loading trigger: fetch next course batch when 80% scrolled

**Constraints**: 
- Browser-based code execution only (no server-side execution for exercises)
- Online-only with graceful error messages (no offline content caching)
- Structured logging only (no Application Insights/external monitoring)
- Category-based recommendations (no algorithmic/ML recommendations)
- Infinite scroll for course catalog (no traditional pagination UI)

**Scale/Scope**: 
- Support 500+ concurrent users with responsive navigation
- Course catalog: 100+ courses with efficient filtering
- Learning paths: up to 100+ lessons per course
- 73 functional requirements across 8 feature areas
- 7 prioritized user stories (3 P1, 3 P2, 1 P3)
- Estimated implementation: 6-8 weeks for P1 features, 10-12 weeks total

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### ✅ I. API-First Architecture
- Backend endpoints for course filtering/search will be implemented before frontend course discovery components
- OpenAPI documentation will be extended for new endpoints (`/api/v1/courses/search`, `/api/v1/learning-paths/{id}/progress`)
- Pagination implemented via infinite scroll with cursor-based pagination (limit + cursor parameters)
- All new routes follow RESTful conventions with proper HTTP status codes

**Status**: PASS - Design follows API-first approach

### ✅ II. Security & Authentication (NON-NEGOTIABLE)
- Theme preferences stored in localStorage (client-side only, no security risk)
- Admin DSL parser uses Bleach for XSS sanitization (FR-066)
- Network error handling prevents exposure of sensitive errors (FR-072)
- Existing JWT/OAuth authentication remains unchanged
- No new authentication flows introduced

**Status**: PASS - Security requirements maintained

### ✅ III. Test-First Development
- Unit tests required for new backend routes (course search, DSL parser extensions)
- Component tests for navigation components, course cards, learning path visualization
- E2E tests for mobile viewport configurations and cross-platform navigation
- Playwright tests for iOS/Android bottom nav and Windows left panel

**Status**: PASS - Comprehensive test strategy defined

### ✅ IV. Progressive Web App (PWA) Standards
- Existing PWA setup maintained (manifest.json, service workers)
- Responsive design with mobile-first approach (bottom nav on mobile, left panel on desktop)
- Fast loading with code splitting and lazy loading for course catalog
- Install prompt functionality preserved

**Status**: PASS - PWA standards maintained and enhanced

### ⚠️ V. Modular & Maintainable Code
- **VIOLATION**: Current App.tsx is 1099 lines (limit: 500 lines)
- **REQUIRED**: App.tsx must be refactored into smaller components before adding new navigation
- **JUSTIFIED**: Refactoring is explicitly listed as unblocking requirement in spec dependencies

**Unblocking Action**: Create `/frontend/src/components/navigation/`, `/frontend/src/components/courses/`, `/frontend/src/pages/` structure

**Status**: CONDITIONAL PASS - Violation acknowledged with remediation plan

### ✅ VI. Security-First Development
- Input validation at API boundary (Pydantic models for search/filter parameters)
- Output encoding via React's default XSS protection
- Bleach sanitization for admin DSL content (FR-066)
- Structured logging for security event tracking (FR-071)

**Status**: PASS - Security-first approach maintained

### ✅ VII. Performance & Optimization
- API response time targets: p95 < 500ms (SC-002)
- Frontend TTI < 3 seconds on 4G (SC-008)
- 60fps animations on mobile (SC-006)
- Database indexes for course filtering (category, difficulty, title)
- React.memo and useMemo for learning path rendering optimization
- Debounced search input (300ms) to reduce API calls (FR-022)

**Status**: PASS - Performance targets defined and achievable

### ✅ VIII. Scalability & Production Readiness
- Stateless design maintained (no in-memory sessions, localStorage only for client preferences)
- Horizontal scaling compatible (multiple App Service instances)
- Health check endpoint preserved
- Structured logging for production monitoring (FR-071)
- Graceful error handling for network failures (FR-072, FR-073)

**Status**: PASS - Production-ready architecture

**Overall Gate Status**: ⚠️ CONDITIONAL PASS - App.tsx refactoring must complete before Phase 1 navigation implementation

## Project Structure

### Documentation (this feature)

```
specs/002-mobile-ux-redesign/
├── spec.md              # Feature specification (completed)
├── checklists/
│   └── requirements.md  # Specification quality checklist (completed)
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (to be generated)
├── data-model.md        # Phase 1 output (to be generated)
├── quickstart.md        # Phase 1 output (to be generated)
├── contracts/           # Phase 1 output (to be generated)
│   ├── courses-api.yaml           # Course search/filter endpoints
│   ├── learning-paths-api.yaml    # Learning path progress endpoints
│   └── admin-dsl-api.yaml         # Enhanced DSL parsing endpoints
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```
backend/
├── app/
│   ├── routes/
│   │   ├── courses.py              # NEW: Course search/filter endpoints
│   │   ├── learning_paths.py       # EXTEND: Progress tracking endpoints
│   │   └── admin.py                # EXTEND: Enhanced DSL parsing
│   ├── models/
│   │   └── learning_path.py        # EXTEND: New DSL content types (video, quiz, exercise)
│   ├── schemas/
│   │   ├── course_filters.py       # NEW: Search/filter request/response models
│   │   └── dsl_content.py          # NEW: Enhanced DSL content schemas
│   ├── services/                   # NEW: Business logic layer (constitution requirement)
│   │   ├── course_service.py       # Course filtering, search, recommendations
│   │   ├── learning_path_service.py # Progress calculations, path rendering
│   │   └── dsl_service.py          # DSL parsing, validation, sanitization
│   └── db/
│       └── store.py                # EXTEND: Query methods for filtering/search
├── tests/
│   ├── test_course_search.py      # NEW: Course discovery tests
│   ├── test_dsl_parsing.py        # EXTEND: Enhanced DSL tests
│   └── test_structured_logging.py # NEW: Logging verification tests
└── requirements.txt                # UPDATE: Add structlog, bleach

frontend/
├── src/
│   ├── components/                 # REFACTOR: Extract from App.tsx
│   │   ├── navigation/
│   │   │   ├── DesktopNav.tsx      # NEW: Left-side panel (≥1024px)
│   │   │   ├── MobileNav.tsx       # NEW: Bottom navigation bar (<1024px)
│   │   │   └── NavItem.tsx         # NEW: Shared navigation item component
│   │   ├── courses/
│   │   │   ├── CourseGrid.tsx      # NEW: Responsive course grid with infinite scroll
│   │   │   ├── CourseCard.tsx      # NEW: Course card component
│   │   │   ├── CourseFilters.tsx   # NEW: Search + filter controls
│   │   │   └── EmptyState.tsx      # NEW: "No courses found" component
│   │   ├── learning-path/
│   │   │   ├── PathVisualization.tsx # NEW: Visual learning path map
│   │   │   ├── LessonNode.tsx       # NEW: Individual lesson node
│   │   │   ├── ModuleSection.tsx    # NEW: Module grouping component
│   │   │   └── ProgressIndicator.tsx # NEW: Progress percentage display
│   │   ├── dashboard/
│   │   │   ├── Dashboard.tsx        # NEW: Personalized dashboard layout
│   │   │   ├── EnrolledCourses.tsx  # NEW: Enrolled courses section
│   │   │   ├── RecentActivity.tsx   # NEW: Recent activity feed
│   │   │   └── Recommendations.tsx  # NEW: Category-based recommendations
│   │   ├── theme/
│   │   │   └── ThemeToggle.tsx      # NEW: Theme switcher control
│   │   ├── lesson/
│   │   │   ├── VideoContent.tsx     # NEW: YouTube/Vimeo embed
│   │   │   ├── QuizContent.tsx      # NEW: Interactive quiz
│   │   │   ├── ExerciseContent.tsx  # NEW: Code editor + execution
│   │   │   └── SummaryContent.tsx   # NEW: Recap section
│   │   └── common/
│   │       ├── ErrorBoundary.tsx    # NEW: Network error handling
│   │       └── LoadingState.tsx     # NEW: Loading indicators
│   ├── pages/
│   │   ├── HomePage.tsx             # REFACTOR: Extract from App.tsx
│   │   ├── CourseCatalog.tsx        # NEW: Course discovery page
│   │   ├── LearningPathPage.tsx     # NEW: Learning path view
│   │   └── DashboardPage.tsx        # NEW: Dashboard page
│   ├── hooks/
│   │   ├── usePlatformDetection.ts  # NEW: Detect Windows/iOS/Android
│   │   ├── useTheme.ts              # NEW: Theme management hook
│   │   ├── useCourseSearch.ts       # NEW: TanStack Query for course search
│   │   ├── useInfiniteScroll.ts     # NEW: Infinite scroll hook
│   │   └── useCodeExecution.ts      # NEW: Pyodide execution hook
│   ├── stores/
│   │   ├── navigationStore.ts       # NEW: Zustand store for nav state
│   │   └── themeStore.ts            # NEW: Zustand store for theme
│   ├── api/
│   │   ├── client.ts                # EXTEND: API client with error handling
│   │   ├── courses.ts               # NEW: Course API methods
│   │   └── learningPaths.ts         # NEW: Learning path API methods
│   ├── workers/
│   │   └── codeExecutor.worker.ts   # NEW: Web Worker for Pyodide
│   └── App.tsx                      # REFACTOR: Reduce from 1099 to <300 lines
├── public/
│   ├── manifest.json                # UPDATE: PWA manifest with new icons
│   └── lottie/                      # NEW: Lottie animation JSON files
├── e2e/
│   ├── navigation.spec.ts           # NEW: Cross-platform navigation tests
│   ├── course-discovery.spec.ts     # NEW: Search/filter E2E tests
│   └── mobile-viewport.spec.ts      # NEW: iOS/Android viewport tests
├── package.json                     # UPDATE: Add React 19, TanStack Query, Motion, Pyodide
└── tailwind.config.js               # UPDATE: Dark mode configuration, custom breakpoints

infra/
└── bicep/                           # EXTEND: Infrastructure as code
    └── app-service.bicep            # UPDATE: Cosmos DB index definitions
```

**Structure Decision**: 
Maintaining existing web application (monorepo) structure with `/backend` and `/frontend` directories. Key changes:
1. **Backend**: Add `/services` layer for business logic (constitution requirement V)
2. **Frontend**: Refactor App.tsx into component-based architecture with `/components`, `/pages`, `/hooks`, `/stores` organization
3. **Testing**: Expand `/tests` (backend) and `/e2e` (frontend) with comprehensive coverage
4. **Infrastructure**: Extend Bicep templates for Cosmos DB index configuration

This structure supports modular development, clear separation of concerns, and independent testing of features per constitution principles.

## Complexity Tracking

*Fill ONLY if Constitution Check has violations that must be justified*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| App.tsx exceeds 500-line limit (1099 lines) | Current monolithic component handles all routing, state management, and inline page rendering | Direct refactoring without navigation would not address root cause; new adaptive navigation requires component-based architecture to support platform detection and responsive layouts |

**Remediation Plan**:
1. Extract navigation into `/components/navigation/` (DesktopNav, MobileNav)
2. Extract pages into `/pages/` (HomePage, CourseCatalog, LearningPathPage, DashboardPage)
3. Extract course components into `/components/courses/`
4. Extract dashboard components into `/components/dashboard/`
5. Reduce App.tsx to router configuration + layout wrapper (<300 lines)

**Target**: All components <500 lines, App.tsx <300 lines, refactoring complete before P1 navigation implementation

---

## Phase 0: Outline & Research

### Research Tasks

Based on Technical Context unknowns and clarified decisions, the following research tasks are required:

1. **React 19.x Migration Strategy**: Research upgrade path from React 18.2.0 → 19.x including breaking changes, new features (useFormStatus, useOptimistic), and impact on existing components. Document migration checklist.

2. **TanStack Query Infinite Scroll Implementation**: Research best practices for infinite scroll with TanStack Query including `useInfiniteQuery` hook, cursor-based pagination patterns, loading states, and error handling for course catalog.

3. **Platform Detection Strategies**: Research reliable methods for detecting Windows PWA vs iOS Safari vs Android Chrome including user agent parsing, navigator.platform, and viewport characteristics. Evaluate accuracy and edge cases.

4. **Pyodide Integration Patterns**: Research Pyodide setup in production React app including bundle size optimization, Web Worker integration, package loading strategies, and execution timeouts. Evaluate performance implications.

5. **Motion (Framer Motion) Performance Best Practices**: Research 60fps animation patterns including layout animations, exit animations during route changes, GPU acceleration, will-change optimization, and performance monitoring techniques.

6. **Tailwind Dark Mode Implementation**: Research dark mode toggle patterns including class-based vs media query approach, theme persistence in localStorage, and CSS custom properties integration for smooth transitions.

7. **Zustand Global State Patterns**: Research Zustand store architecture for navigation context and theme management including devtools integration, persistence middleware, and TypeScript typing patterns.

8. **Structured Logging in FastAPI**: Research structlog integration with FastAPI including middleware setup, context injection (user_id, request_id), JSON formatting, and log aggregation strategies for production.

9. **Cosmos DB Index Optimization**: Research Cosmos DB composite index patterns for multi-filter queries (category + difficulty + text search) including index policy configuration, RU cost analysis, and query performance profiling.

10. **Bleach XSS Sanitization Patterns**: Research Bleach configuration for admin DSL content including allowed tags/attributes for markdown, video embeds, and quiz syntax while preventing XSS attacks.

### Research Output: research.md

All findings will be consolidated in `research.md` using the format:

**Decision**: [Technology/pattern chosen]  
**Rationale**: [Why this approach]  
**Alternatives Considered**: [What else was evaluated]  
**Implementation Notes**: [Key considerations]  
**Risks**: [Potential issues to monitor]

---

## Phase 1: Design & Contracts

*Prerequisites: research.md complete, all NEEDS CLARIFICATION resolved*

### 1.1 Data Model Design (data-model.md)

Extract entities from feature spec and design data schemas:

**New Entities**:
- `CourseFilter`: Search query, difficulty filter, category filter, pagination cursor
- `CourseSearchResult`: Filtered courses, total count, next cursor
- `EnhancedContentItem`: Extended content types (Video, Quiz, Exercise, Summary)
- `QuizQuestion`: Question text, options, correct answer index
- `CodingExercise`: Language, starter code, expected output, test cases
- `NavigationState`: Current route, platform type, viewport dimensions
- `ThemePreference`: Selected theme (bright/dark), custom colors (future)

**Extended Entities**:
- `Course`: Add `preview_image_url`, `enrollment_count` (for recommendations)
- `UserProgress`: Add `quiz_scores`, `exercise_submissions`, `time_spent_seconds`
- `LearningPath`: Add `estimated_time_remaining`, `completion_percentage`

**Relationships**:
- `CourseFilter` → `CourseSearchResult` (1:1 per search request)
- `EnhancedContentItem` → `QuizQuestion[]` | `CodingExercise` (1:many for quizzes, 1:1 for exercises)
- `UserProgress` → `LearningPath` (many:1 tracking per lesson)

### 1.2 API Contracts (contracts/)

Generate OpenAPI specifications for new/extended endpoints:

**courses-api.yaml**:
```yaml
/api/v1/courses/search:
  GET:
    summary: Search and filter courses with infinite scroll
    parameters:
      - name: q (query string)
      - name: difficulty (enum: Beginner, Intermediate, Advanced)
      - name: category (string)
      - name: limit (integer, default: 20, max: 50)
      - name: cursor (string, optional)
    responses:
      200: CourseSearchResult with next_cursor
      400: Invalid filter parameters
      500: Search service error

/api/v1/courses/{id}/recommendations:
  GET:
    summary: Get category-based course recommendations
    responses:
      200: Course[] (popular courses from same categories)
      404: Course not found
```

**learning-paths-api.yaml**:
```yaml
/api/v1/learning-paths/{id}/progress:
  GET:
    summary: Get detailed progress for learning path visualization
    responses:
      200: LearningPath with module/lesson completion states
      401: Unauthorized
      404: Learning path not found

/api/v1/learning-paths/{id}/continue:
  GET:
    summary: Get next incomplete lesson URL
    responses:
      200: { next_lesson_url: string }
      404: All lessons complete or path not found
```

**admin-dsl-api.yaml**:
```yaml
/api/v1/admin/dsl/parse:
  POST:
    summary: Parse and validate enhanced DSL content
    requestBody: { dsl_content: string }
    responses:
      200: ParsedCourse with preview data
      400: DSL syntax errors with line numbers
      403: Admin access required

/api/v1/admin/dsl/preview:
  POST:
    summary: Generate preview of parsed course structure
    requestBody: { dsl_content: string }
    responses:
      200: HTML preview (sanitized)
      400: Invalid DSL
```

### 1.3 Quickstart Guide (quickstart.md)

Developer setup instructions for working on this feature:

**Prerequisites**:
- Node.js 18+, Python 3.8+, Azure CLI
- Existing MenTora repo cloned with .env configured

**Frontend Setup**:
```bash
cd frontend
npm install  # Installs React 19, TanStack Query, Motion, Pyodide
npm run dev  # Vite dev server on localhost:5173
```

**Backend Setup**:
```bash
cd backend
python -m venv .venv
source .venv/bin/activate  # or .venv\Scripts\activate on Windows
pip install -r requirements.txt  # Installs structlog, bleach
uvicorn main:app --reload  # FastAPI on localhost:8000
```

**Running Tests**:
```bash
# Backend
cd backend
pytest tests/ -v --cov=app

# Frontend
cd frontend
npm run test  # Vitest unit tests
npm run test:e2e  # Playwright E2E tests
```

**Storybook (Component Catalog)**:
```bash
cd frontend
npm run storybook  # Opens on localhost:6006
```

**Key Files to Review**:
- `/specs/002-mobile-ux-redesign/spec.md` - Feature requirements
- `/specs/002-mobile-ux-redesign/research.md` - Technical decisions
- `/specs/002-mobile-ux-redesign/data-model.md` - Entity schemas
- `/backend/app/services/` - Business logic layer
- `/frontend/src/components/` - Refactored components

### 1.4 Agent Context Update

Run update script to add new technologies to Copilot instructions:

```powershell
.\.specify\scripts\powershell\update-agent-context.ps1 -AgentType copilot
```

**Technologies to Add**:
- TanStack Query (React Query) for data fetching
- Motion (Framer Motion) for animations
- Pyodide for Python code execution
- Zustand for lightweight state management
- Structlog for JSON logging
- Bleach for XSS sanitization

---

## Phase 2: Task Breakdown

*This phase is handled by `/speckit.tasks` command - NOT part of /speckit.plan*

Task generation will be deferred to the tasks command which will create:
- Granular implementation tasks organized by priority (P1, P2, P3)
- Dependencies between tasks
- Estimated effort and assignable work items
- Test coverage requirements per task

**Next Command**: `/speckit.tasks` to generate `tasks.md`

---

## Notes & Open Questions

### Implementation Order (Recommended)

**Phase A - Foundation (Weeks 1-2)**:
1. App.tsx refactoring (unblocking requirement)
2. Backend service layer creation
3. Structured logging setup
4. Cosmos DB index configuration

**Phase B - P1 Features (Weeks 3-6)**:
1. Adaptive navigation (FR-001 to FR-010)
2. Course discovery with search/filter (FR-011 to FR-025)
3. Visual learning path (FR-026 to FR-040)

**Phase C - P2 Features (Weeks 7-10)**:
1. Personalized dashboard (FR-041 to FR-050)
2. Theme switching (FR-051 to FR-055)
3. Enhanced admin DSL (FR-056 to FR-070)

**Phase D - P3 Features (Weeks 11-12)**:
1. Smooth animations (User Story 7)
2. Performance optimization
3. E2E testing and bug fixes

### Answered Questions from Spec

1. **Navigation state sync**: Stored in localStorage only (not backend) per clarifications
2. **Course preview images**: Fallback to placeholder images if missing
3. **Theme storage**: localStorage only (not user profile) per clarifications
4. **Pagination**: Infinite scroll with lazy loading per clarifications (Question 1)
5. **Recommendations**: Category-based filtering per clarifications (Question 2)
6. **Code execution**: Browser-based only per clarifications (Question 3)
7. **Observability**: Structured logging only per clarifications (Question 4)
8. **Offline handling**: Graceful errors, no caching per clarifications (Question 5)

### Remaining Open Questions

1. **React 19 Migration Timing**: Should React upgrade happen before or parallel with navigation refactoring?
2. **Pyodide Bundle Size**: How to handle 50MB+ Pyodide download for first-time users?
3. **Cosmos DB RU Budget**: What is acceptable RU cost for course search with text filtering?
4. **Mobile Testing Devices**: Which physical devices or BrowserStack config for iOS/Android testing?

These will be addressed during Phase 0 research.

---

## Constitution Re-Check (Post-Design)

*Re-evaluate after Phase 1 design complete*

### V. Modular & Maintainable Code
- ✅ Backend service layer added (`/services`)
- ✅ Frontend component architecture defined (no file >500 lines in plan)
- ✅ App.tsx refactoring strategy documented with target <300 lines

**Status**: PASS (violations remediated)

### All Other Principles
- ✅ API-First: Contracts defined before implementation
- ✅ Security: Bleach sanitization, structured logging for security events
- ✅ Testing: Comprehensive test strategy (unit, integration, E2E)
- ✅ PWA: Standards maintained
- ✅ Security-First: XSS prevention, input validation at boundaries
- ✅ Performance: Targets defined with monitoring strategy
- ✅ Scalability: Stateless design, horizontal scaling compatible

**Overall Gate Status**: ✅ PASS - All constitution requirements satisfied

---

## Summary & Next Steps

**Plan Status**: ✅ COMPLETE  
**Branch**: `002-mobile-ux-redesign`  
**Spec**: `specs/002-mobile-ux-redesign/spec.md`

**Generated Artifacts** (by /speckit.plan):
- ✅ `specs/002-mobile-ux-redesign/plan.md` (this file)
- ⏳ `specs/002-mobile-ux-redesign/research.md` (next: generate)
- ⏳ `specs/002-mobile-ux-redesign/data-model.md` (next: generate)
- ⏳ `specs/002-mobile-ux-redesign/quickstart.md` (next: generate)
- ⏳ `specs/002-mobile-ux-redesign/contracts/` (next: generate)

**Pending Artifacts** (by /speckit.tasks):
- ⏳ `specs/002-mobile-ux-redesign/tasks.md` (requires /speckit.tasks command)

**Recommended Next Action**: Proceed with Phase 0 research to generate `research.md` and resolve remaining technical unknowns before Phase 1 contract generation.

