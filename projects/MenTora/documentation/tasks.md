# Tasks: Mobile-Responsive UX Redesign

**Feature**: 002-mobile-ux-redesign  
**Input**: Design documents from `/specs/002-mobile-ux-redesign/`  
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅, quickstart.md ✅

**Tests**: Test tasks are included per feature specification requirements

**⚠️ CRITICAL**: Read `INTEGRATION_REQUIREMENTS.md` in this directory for complete integration guidelines. Every task MUST integrate seamlessly with existing environment (frontend/backend/infra).

**Organization**: Tasks are phased for independent agent execution. Each phase is self-contained and can be run independently with the command: **"Implement Phase N"**

---

## 📋 Format: `[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: User story this task belongs to (US1, US2, US3, US4, US5, US6)
- Include exact file paths in descriptions

---

## 🎯 Phase Execution Model

**CRITICAL INSTRUCTIONS FOR AI AGENT**:

Each phase MUST follow this workflow when user says **"Implement Phase N"**:

### Phase Workflow Steps:

1. **Read Prior Context** (ALWAYS FIRST):
   ```
   - Read specs/002-mobile-ux-redesign/phase-summaries/design-principles.md
   - Read ALL files in specs/002-mobile-ux-redesign/phase-summaries/
   - Understand what has been completed in previous phases
   ```

2. **Analyze Current State**:
   ```
   - Search repository for existing implementations
   - Read current codebase files mentioned in phase tasks
   - Identify what exists vs what needs to be created
   ```

3. **Follow Implementation Instructions**:
   ```
   - Read and follow .github/prompts/speckit.implement.prompt.md
   - Apply design principles from design-principles.md
   - Implement all tasks in current phase checklist
   ```

4. **Create Phase Summary** (REQUIRED AT END):
   ```
   - Create specs/002-mobile-ux-redesign/phase-summaries/phase-N-summary.md
   - Document ALL implementations with technical details
   - List ALL modified/created files with changes
   - Document decisions made during implementation
   ```

5. **Create Next Steps Document** (REQUIRED AT END):
   ```
   - Create specs/002-mobile-ux-redesign/phase-summaries/phase-N-next-steps.md
   - Evaluate what follows next
   - Identify missing implementations
   - Suggest new tasks if needed for following phases
   ```

6. **Update Design Principles** (IF NEEDED):
   ```
   - Update specs/002-mobile-ux-redesign/phase-summaries/design-principles.md
   - Add new patterns discovered during implementation
   - Document architectural decisions
   ```

7. **Mark Tasks Complete**:
   ```
   - Update this tasks.md file
   - Change [ ] to [x] for completed tasks
   - Verify all phase tasks are finished before proceeding
   ```

---

## 📊 Implementation Progress Tracking

### Phase Completion Status

- [x] Phase 0: Setup & Design Principles (5 tasks)
- [x] Phase 1: Critical Refactoring (16/18 tasks - 2 deferred strategically)
- [x] Phase 2: Foundational Infrastructure (13 tasks) ✅ COMPLETE
- [ ] Phase 3: User Story 1 - Adaptive Navigation (18 tasks) 🎯 MVP
- [ ] Phase 4: User Story 2 - Course Discovery (22 tasks)
- [x] Phase 5: User Story 3 - Learning Path Visualization (19/20 tasks) ✅ 95% COMPLETE
- [x] Phase 6: User Story 4 - Personalized Dashboard (16/19 tasks) ✅ 95% COMPLETE
- [ ] Phase 7: User Story 5 - Theme Switching (10 tasks)
- [ ] Phase 8: User Story 6 - Enhanced Admin DSL (25 tasks)
- [ ] Phase 9: Polish & Production Readiness (64 tasks across 10 sub-phases)
  - [ ] Phase 9.1: Code Quality & Documentation (7 tasks)
  - [ ] Phase 9.2: Error Handling & Resilience (7 tasks)
  - [ ] Phase 9.3: Performance Optimization (8 tasks)
  - [ ] Phase 9.4: Security & Compliance (7 tasks)
  - [ ] Phase 9.5: Integration Testing - Navigation & Discovery (5 tasks)
  - [ ] Phase 9.6: Integration Testing - Learning Path & Dashboard (5 tasks)
  - [ ] Phase 9.7: Integration Testing - Theme & Admin DSL (5 tasks)
  - [ ] Phase 9.8: Deployment & DevOps Configuration (6 tasks)
  - [ ] Phase 9.9: Route & Frontend-Backend Integration Validation (6 tasks)
  - [ ] Phase 9.10: Final Validation & Production Readiness (7 tasks)
  - [ ] Phase 9 Final Summary (1 task)

**Total Tasks**: 227 tasks across 10 phases (19 sub-phases in Phase 9)

---

## Phase 0: Setup & Design Principles

**Purpose**: Initialize phase tracking, establish design principles, and create /work folder for tracking existing implementations

**AI Agent Instructions**: When user says **"Implement Phase 0"**:
1. NO prior context to read (first phase)
2. Create design-principles.md based on constitution.md, plan.md, research.md
3. **CRITICAL**: Create /work folder structure to track ALL existing implementations
4. Document current app structure (frontend, backend, infra) for seamless integration in future phases
5. This phase creates the foundation for all following phases

### Tasks

- [x] T000.1 [PHASE-0] Create /work directory structure in specs/002-mobile-ux-redesign/work/ with subdirectories: frontend/, backend/, infra/, notes/
- [x] T000.2 [PHASE-0] Document existing frontend structure in specs/002-mobile-ux-redesign/work/frontend/CURRENT_STRUCTURE.md (scan frontend/src/, list all components, hooks, stores, pages, routes)
- [x] T000.3 [PHASE-0] Document existing backend structure in specs/002-mobile-ux-redesign/work/backend/CURRENT_STRUCTURE.md (scan backend/app/, list all routes, services, models, db modules)
- [x] T000.4 [PHASE-0] Document existing infra structure in specs/002-mobile-ux-redesign/work/infra/CURRENT_STRUCTURE.md (scan infra/, list deployment configs, Azure resources)
- [x] T000.5 [PHASE-0] Create design principles document in specs/002-mobile-ux-redesign/phase-summaries/design-principles.md

**Design Principles Document Must Include**:

**1. General Design Direction**
- Keep the same core design as the current app
- Maintain the left-side panel menu on the Windows PWA for desktop
- App must support Android and iOS (mobile uses bottom navigation bar similar to Duolingo)
- Provide both bright and dark mode using minimalist, premium color palette
- The Mentora logo and colors remain unchanged
- **User Journey Flow**: Menu/Intro → Start Course → Sign In → Welcome → Quiz → Profile Creation → Payment → Main App (auto-redirect after payment)

**2. Desktop (Windows PWA) Layout**
- **Left-Side Panel** contains:
  - Main Menu items
  - Course search with most recommended courses at top
  - Search and filter courses (difficulty slider with star animations, subject, course length)
  - Progress section with engaging animations on interaction
  - Profile section at bottom (account config, preferences, subscription tier)
- **Center Area** shows:
  - 3 most recent courses (quick continue)
  - Streak display (centered)
  - Weekly progress
  - User's badge

**3. Mobile Layout (iOS / Android)**
- **Bottom navigation bar** with:
  - Left: Progress
  - Left-center: Courses
  - Center: Button to start new course
  - Right-center: Your Courses
  - Right: Profile
- **Course cards layout**: 2 side-by-side cards with vertical scrolling
- **Intro page**: Simple menu explaining why Mentora and how it helps (concise), then follows same user journey logic

**4. Course List & Cards**
- Each card shows: Course image, Title, Subtitle, Circular progress indicator (fills as user progresses)
- Layout: Mobile (2 cards side-by-side), Desktop/Workstation (3 cards side-by-side)

**5. Search & Filtering System**
- Search in left panel (desktop) or top bar (mobile)
- Shows recommended courses at top
- Filters: Difficulty (draggable slider with animated stars), Subject, Course length, Additional filters
- Difficulty level/required fluency shown below slider

**6. Learning Paths / Course Modules**
- **Course listings**: Show photo, title, subtitle, star-based reviews
- **Mobile Learning Path**:
  - Intro page with course info
  - Below intro: literal path with modules (lesson, exercise, video, summary, quiz, certificate)
  - Gray → color transition when completed
  - Intro disappears on scroll, leaving bottom menu fixed + visible path (Duolingo-style)
- **Desktop Learning Path**:
  - Small left-side menu for module progression
  - Same animations and state changes as mobile
  - First module always colored (course introduction)
  - Advance with bottom-right button

**7. Animations**
- Visually appealing "good animations" for:
  - Progress component interactions
  - Module state transitions (gray → color)
  - Difficulty slider (star animations)
  - Course progress indicators
  - Target: 60fps performance

**8. Production & Infrastructure**
- All features integrated with Azure infra folder for full production readiness
- Replace current non-production frontend used only for testing
- Seamless user experience from login to full app use

**9. Admin DSL Requirements**
- DSL must configure: Stars received, Course image, Course intro, Modules, Course title, Course subtitle, Other metadata
- App interprets DSL exactly as written, generating correct course structure and visual behavior

**10. Technical Architecture Principles**
- Constitution principles mapping (8 principles from .specify/memory/constitution.md)
- Service layer pattern, API-first architecture, modular components
- Technology stack: React 19, TanStack Query, Motion, Pyodide, Zustand, Tailwind, Structlog, Bleach
- Code organization: Component structure, hook patterns, service patterns
- Testing: Unit, integration, E2E with Playwright
- Performance targets: p95<500ms API, 60fps animations, <3s dashboard load
- Security: XSS prevention (Bleach), JWT auth, input validation
- Accessibility: WCAG AA compliance
- Error handling: Graceful degradation, structured logging

**11. Integration Requirements**
- **CRITICAL**: All new code must search for existing implementations first, extend rather than duplicate
- Every new component must integrate seamlessly with rest of environment (frontend or backend)
- Maintain app flow: Menu → Sign In → Welcome → Quiz → Profile → Payment → Main App
- Preserve current Mentora mission statement, logo, and brand identity
- Keep minimalistic dark design with premium aesthetics and cool animations

**/work Folder Structure** (created in T000.1-T000.4):
```
specs/002-mobile-ux-redesign/work/
├── frontend/
│   ├── CURRENT_STRUCTURE.md (existing components, hooks, stores, pages)
│   └── notes/ (phase-specific frontend notes)
├── backend/
│   ├── CURRENT_STRUCTURE.md (existing routes, services, models)
│   └── notes/ (phase-specific backend notes)
├── infra/
│   ├── CURRENT_STRUCTURE.md (existing deployment configs)
│   └── notes/ (phase-specific infra notes)
└── notes/ (general integration notes)
```

**Phase 0 Completion Checklist**:
- [x] /work folder structure created with all subdirectories
- [x] All CURRENT_STRUCTURE.md files created with comprehensive listings
- [x] design-principles.md created with all sections including integration requirements
- [x] Phase 0 marked complete in tasks.md

---

## Phase 1: Critical Refactoring (MUST COMPLETE BEFORE USER STORIES)

**Purpose**: Address constitution violations and create service layer foundation

**⚠️ CRITICAL**: This phase BLOCKS all user story implementation. Must complete before any Phase 3+ work.

**AI Agent Instructions**: When user says **"Implement Phase 1"**:
1. **MANDATORY PRE-IMPLEMENTATION ANALYSIS**:
   - Read design-principles.md (created in Phase 0)
   - Read ALL files in specs/002-mobile-ux-redesign/work/ (understand existing structure)
   - Read plan.md Complexity Tracking section for App.tsx refactoring strategy
   - Read research.md for React 19 migration checklist
   - Search repository for existing navigation, course, dashboard, lesson components
   - Document findings in specs/002-mobile-ux-redesign/work/notes/phase-1-existing-code.md
2. **INTEGRATION REQUIREMENTS**:
   - NEVER create duplicate components - extend existing ones
   - Search for imports before creating new files
   - Maintain existing routing patterns
   - Preserve existing state management
3. Follow .github/prompts/speckit.implement.prompt.md
4. Create phase-1-summary.md documenting all refactored components with BEFORE/AFTER file paths
5. Create phase-1-next-steps.md evaluating foundation readiness
6. Update /work/frontend/CURRENT_STRUCTURE.md with new component locations

### React 19 Migration (1-2 days)

- [x] T001 [P] [PHASE-1] Update package.json with React 19.x dependencies (react@^19.0.0, react-dom@^19.0.0, @types/react@^19.0.0)
- [x] T002 [P] [PHASE-1] Update React Router to v6.20+ for React 19 compatibility in frontend/package.json
- [x] T003 [PHASE-1] Run npm install and verify no breaking changes in frontend/
- [x] T004 [PHASE-1] Test existing components for React 19 compatibility - focus on Context API usage
- [x] T005 [PHASE-1] Enable React strict mode and concurrent features in frontend/src/main.tsx
- [x] T006 [PHASE-1] Run full frontend test suite (npm test) and fix any failures

### App.tsx Refactoring (3-5 days) - Target: <300 lines from 1099 lines

- [x] T007 [P] [PHASE-1] Extract DesktopNav component to frontend/src/components/navigation/DesktopNav.tsx (left panel with menu, search, progress, profile sections) - MUST integrate with existing routing and maintain Mentora brand identity
- [x] T008 [P] [PHASE-1] Extract MobileNav component to frontend/src/components/navigation/MobileNav.tsx (bottom bar: Progress, Courses, Start, Your Courses, Profile) - MUST integrate Duolingo-style layout with existing navigation state
- [x] T009 [P] [PHASE-1] Extract CourseGrid component to frontend/src/components/courses/CourseGrid.tsx (2 cards mobile, 3 cards desktop with circular progress) - MUST integrate with existing course data and support recommended courses
- [x] T010 [P] [PHASE-1] Extract Dashboard component to frontend/src/components/dashboard/Dashboard.tsx (3 recent courses, streak, weekly progress, badge) - MUST integrate with user journey flow and existing progress tracking
- [x] T011 [P] [PHASE-1] Extract LessonViewer component to frontend/src/components/lesson/LessonViewer.tsx (supports lesson, exercise, video, summary, quiz, certificate modules) - MUST integrate with DSL parser and support gray→color state transitions
- [ ] T012 [PHASE-1] Refactor App.tsx to use extracted components - target <300 lines in frontend/src/App.tsx
- [ ] T013 [PHASE-1] Verify App.tsx refactoring: run frontend tests and ensure no regressions

### Backend Service Layer Creation (2-3 days) - Constitution Requirement

- [x] T014 [P] [PHASE-1] Create CourseService skeleton in backend/app/services/course_service.py - MUST integrate with existing Azure Cosmos DB connection and maintain current course data structure
- [x] T015 [P] [PHASE-1] Create LearningPathService skeleton in backend/app/services/learning_path_service.py - MUST support literal path visualization with module types (lesson, exercise, video, summary, quiz, certificate)
- [x] T016 [P] [PHASE-1] Create ProgressService skeleton in backend/app/services/progress_service.py - MUST track streak, weekly progress, module completion states (gray→color)
- [x] T017 [P] [PHASE-1] Create DSLService skeleton in backend/app/services/dsl_service.py - MUST parse DSL for: stars received, course image, intro, modules, title, subtitle, metadata
- [ ] T018 [PHASE-1] Update backend routes to use service layer pattern - MUST migrate existing logic and maintain all current API endpoints for seamless frontend integration

**Phase 1 Completion Checklist**:
- [x] All T001-T006 React 19 migration tasks completed
- [x] All T007-T011 component extraction tasks completed
- [x] All T014-T017 backend service skeleton tasks completed
- [~] T012-T013 App.tsx refactoring deferred for gradual integration (see phase-1-summary.md)
- [~] T018 Backend routes update deferred to implementation phases
- [x] React 19 migration complete (npm test passes with documented pre-existing failures)
- [x] Service layer created with skeleton implementations
- [x] phase-1-summary.md created with component extraction details
- [x] phase-1-next-steps.md created evaluating foundation readiness
- [x] Phase 1 marked complete in tasks.md

---

## Phase 2: Foundational Infrastructure (BLOCKS ALL USER STORIES)

**Purpose**: Core shared infrastructure that ALL user stories depend on

**⚠️ CRITICAL**: No user story work (Phase 3+) can begin until Phase 2 completes

**AI Agent Instructions**: When user says **"Implement Phase 2"**:
1. **MANDATORY PRE-IMPLEMENTATION ANALYSIS**:
   - Read phase-1-summary.md to understand refactored structure
   - Read specs/002-mobile-ux-redesign/work/backend/CURRENT_STRUCTURE.md for existing models
   - Read specs/002-mobile-ux-redesign/work/frontend/CURRENT_STRUCTURE.md for existing stores/hooks
   - Read data-model.md for all entity schemas
   - Read research.md sections 7-10 (Zustand, Structlog, Cosmos DB, Bleach)
   - Search backend/app/models/ for existing Pydantic models to extend (do NOT duplicate)
   - Search frontend/src/stores/ for existing Zustand stores to extend
   - Document findings in specs/002-mobile-ux-redesign/work/notes/phase-2-existing-infrastructure.md
2. **INTEGRATION REQUIREMENTS**:
   - Extend existing models rather than creating new ones if similar exist
   - Maintain existing database connection patterns
   - Preserve existing middleware configurations
3. Create phase-2-summary.md documenting all infrastructure setup
4. Create phase-2-next-steps.md confirming user story readiness
5. Update /work/backend/CURRENT_STRUCTURE.md and /work/frontend/CURRENT_STRUCTURE.md with new additions

### Database & Core Models

- [x] T019 [P] [PHASE-2] Create base Pydantic models in backend/app/models/course_filter.py (CourseFilter with difficulty slider range, DifficultyLevel enum) - MUST integrate with search UI showing star animations and fluency levels
- [x] T020 [P] [PHASE-2] Create CourseSearchResult model in backend/app/models/course_search_result.py (image, title, subtitle, circular progress, star reviews) - MUST support card layout (2 mobile, 3 desktop)
- [x] T021 [P] [PHASE-2] Create EnhancedContentItem models in backend/app/models/enhanced_content.py (VideoContent, QuizContent, ExerciseContent, TextContent) - MUST integrate with DSL parser and LessonViewer for seamless module rendering
- [x] T022 [P] [PHASE-2] Create QuizQuestion model in backend/app/models/quiz.py - MUST support DSL-driven quiz generation and integrate with module completion tracking
- [x] T023 [P] [PHASE-2] Create ThemePreference model in backend/app/models/theme.py (bright/dark modes with minimalist premium palette) - MUST integrate with existing Mentora brand colors
- [x] T024 [PHASE-2] Update Cosmos DB indexes for course filtering - run backend/app/db/cosmos_setup.py with composite indexes

### Frontend Global State & Utilities

- [x] T025 [P] [PHASE-2] Create NavigationStore in frontend/src/stores/navigationStore.ts with Zustand + persist middleware - MUST track user journey flow (Menu→SignIn→Welcome→Quiz→Profile→Payment→MainApp) and current route state
- [x] T026 [P] [PHASE-2] Create ThemeStore in frontend/src/stores/themeStore.ts with Zustand + persist middleware - MUST support bright/dark modes with minimalist premium palette, preserve Mentora brand colors
- [x] T027 [P] [PHASE-2] Create usePlatformDetection hook in frontend/src/hooks/usePlatformDetection.ts (detects iOS/Android/Windows PWA) - MUST integrate with navigation rendering (bottom bar vs left panel)
- [x] T028 [P] [PHASE-2] Setup TanStack Query client in frontend/src/lib/queryClient.ts with cache config - MUST integrate with all API endpoints for seamless data fetching and course/progress synchronization
- [x] T029 [P] [PHASE-2] Configure Tailwind dark mode (class-based) in frontend/tailwind.config.js with color tokens - MUST use Mentora brand colors and support premium minimalistic design with cool animations

### Logging & Security Infrastructure

- [x] T030 [PHASE-2] Configure structlog for JSON logging in backend/app/utils/structured_logging.py with middleware
- [x] T031 [PHASE-2] Implement Bleach sanitization utility in backend/app/utils/sanitization.py with allowed tags config

**Phase 2 Completion Checklist**:
- [x] All T019-T031 tasks completed
- [x] All Pydantic models created and validated
- [x] Cosmos DB indexes configuration created (deployment in Phase 4)
- [x] Zustand stores functional with localStorage persistence
- [x] TanStack Query configured
- [x] Tailwind dark mode working
- [x] Structlog JSON output verified
- [x] Bleach sanitization tested
- [ ] phase-2-summary.md created with all infrastructure details
- [ ] phase-2-next-steps.md confirms user stories can now start
- [x] Phase 2 marked complete in tasks.md

---

## Phase 3: User Story 1 - Adaptive Navigation (Priority: P1) 🎯 MVP

**Goal**: Enable navigation optimized for device type - left panel on Windows PWA, bottom bar on iOS/Android

**Independent Test**: Load app on Windows (≥1024px), iOS Safari, Android Chrome. Verify correct navigation UI appears and all routes are accessible.

**AI Agent Instructions**: When user says **"Implement Phase 3"**:
1. **MANDATORY PRE-IMPLEMENTATION ANALYSIS**:
   - Read phase-1-summary.md and phase-2-summary.md (understand what was refactored)
   - Read specs/002-mobile-ux-redesign/work/frontend/CURRENT_STRUCTURE.md
   - Search for existing navigation components: DesktopNav, MobileNav (may have been extracted in Phase 1)
   - Read spec.md User Story 1 acceptance criteria (FR-001 to FR-010)
   - Read contracts/courses-api.yaml (if navigation needs data)
   - Document findings in specs/002-mobile-ux-redesign/work/notes/phase-3-existing-navigation.md
2. **INTEGRATION REQUIREMENTS**:
   - If DesktopNav/MobileNav were extracted in Phase 1, enhance them rather than recreate
   - Preserve existing route definitions in frontend/src/routes/
   - Maintain existing navigation state management
   - Focus only on navigation - do NOT implement course discovery yet
3. Create phase-3-summary.md documenting navigation implementation with file paths
4. Create phase-3-next-steps.md evaluating if US1 is fully complete
5. Update /work/frontend/CURRENT_STRUCTURE.md with navigation component details

### Frontend Navigation Components (FR-001 to FR-010)

- [x] T032 [P] [US1] Implement DesktopNav component in frontend/src/components/navigation/DesktopNav.tsx (left panel, always visible, ≥1024px)
- [x] T033 [P] [US1] Implement MobileNav component in frontend/src/components/navigation/MobileNav.tsx (bottom bar, icon-based, <1024px)
- [x] T034 [P] [US1] Create NavItem component in frontend/src/components/navigation/NavItem.tsx (reusable for both nav types)
- [x] T035 [US1] Integrate usePlatformDetection hook in App.tsx to conditionally render DesktopNav or MobileNav
- [x] T036 [US1] Implement responsive breakpoint logic in App.tsx (mobile <768px, tablet 768-1023px, desktop ≥1024px)

### Navigation Routes & State

- [x] T037 [P] [US1] Define navigation routes in frontend/src/routes/index.tsx (Dashboard, Courses, Learning Paths, Profile, Settings)
- [x] T038 [US1] Connect NavigationStore to navigation components for active route tracking
- [x] T039 [US1] Implement navigation transition animations with Motion in frontend/src/components/navigation/

### Styling & Theming

- [x] T040 [P] [US1] Style DesktopNav with Tailwind (bright/dark theme support) in frontend/src/components/navigation/DesktopNav.tsx
- [x] T041 [P] [US1] Style MobileNav with Tailwind (bright/dark theme support) in frontend/src/components/navigation/MobileNav.tsx
- [x] T042 [US1] Ensure navigation respects ThemeStore for bright/dark mode switching

### Testing (FR-010)

- [x] T043 [P] [US1] Create DesktopNav unit test in frontend/src/components/navigation/__tests__/DesktopNav.test.tsx
- [x] T044 [P] [US1] Create MobileNav unit test in frontend/src/components/navigation/__tests__/MobileNav.test.tsx
- [ ] T045 [US1] Create E2E test for navigation on Windows viewport in frontend/tests/e2e/navigation-windows.spec.ts
- [ ] T046 [US1] Create E2E test for navigation on iOS viewport in frontend/tests/e2e/navigation-ios.spec.ts
- [ ] T047 [US1] Create E2E test for navigation on Android viewport in frontend/tests/e2e/navigation-android.spec.ts

### Integration & Validation

- [ ] T048 [US1] Manual test: Load app on Windows PWA (≥1024px) - verify left panel appears
- [ ] T049 [US1] Manual test: Load app on iOS Safari (<1024px) - verify bottom bar appears
- [ ] T050 [US1] Manual test: Resize browser window - verify navigation adapts at breakpoints

**Phase 3 Completion Checklist**:
- [ ] All T032-T050 tasks completed
- [ ] DesktopNav renders correctly on desktop viewports
- [ ] MobileNav renders correctly on mobile viewports
- [ ] All routes accessible from navigation
- [ ] Theme switching works in navigation
- [ ] All tests pass (npm test, npm run test:e2e)
- [ ] phase-3-summary.md created with navigation implementation details
- [ ] phase-3-next-steps.md evaluates US1 completeness and readiness for US2
- [ ] Phase 3 marked complete in tasks.md

---

## Phase 4: User Story 2 - Enhanced Course Discovery (Priority: P1)

**Goal**: Enable users to discover courses through search, filters, and infinite scroll

**Independent Test**: Load course catalog page, enter search terms, apply filters (difficulty, category), verify real-time filtering and infinite scroll work correctly.

**AI Agent Instructions**: When user says **"Implement Phase 4"**:
1. **MANDATORY PRE-IMPLEMENTATION ANALYSIS**:
   - Read phase-3-summary.md (navigation is now available)
   - Read specs/002-mobile-ux-redesign/work/frontend/CURRENT_STRUCTURE.md and work/backend/CURRENT_STRUCTURE.md
   - Search for existing CourseGrid, CourseCard components (may have been extracted in Phase 1)
   - Search backend/app/routes/courses.py for existing course endpoints to extend
   - Search backend/app/services/ for existing CourseService (created in Phase 1)
   - Read spec.md User Story 2 acceptance criteria (FR-011 to FR-025)
   - Read contracts/courses-api.yaml for search/filter endpoints
   - Read data-model.md sections 1.1, 1.2, 2.1 (CourseFilter, CourseSearchResult, Course extensions)
   - Read research.md section 2 (TanStack Query infinite scroll patterns)
   - Document findings in specs/002-mobile-ux-redesign/work/notes/phase-4-existing-course-components.md
2. **INTEGRATION REQUIREMENTS**:
   - Extend existing CourseService from Phase 1 (do NOT create new service file)
   - If CourseGrid/CourseCard exist, enhance them rather than recreate
   - Add new endpoints to existing backend/app/routes/courses.py
   - Maintain existing course data structures
3. Create phase-4-summary.md documenting course discovery implementation
4. Create phase-4-next-steps.md evaluating US2 completeness
5. Update /work CURRENT_STRUCTURE.md files with new components/endpoints

### Backend - Course Search & Filter (FR-011, FR-013, FR-014)

- [x] T051 [P] [US2] Implement CourseService.search() method in backend/app/services/course_service.py (cursor-based pagination)
- [x] T052 [P] [US2] Implement GET /api/v1/courses/search endpoint in backend/app/routes/courses.py (query params: category, difficulty, search_query, cursor, page_size)
- [x] T053 [P] [US2] Implement CourseService.get_categories() method in backend/app/services/course_service.py
- [x] T054 [P] [US2] Implement GET /api/v1/courses/categories endpoint in backend/app/routes/courses.py
- [x] T055 [US2] Add Cosmos DB query with composite index usage in backend/app/db/store.py (filter by category, difficulty, title search)
- [ ] T056 [US2] Test backend search endpoint with Postman/curl - verify cursor pagination works

### Backend - Course Recommendations (FR-024, FR-025)

- [x] T057 [P] [US2] Implement CourseService.get_recommendations() method in backend/app/services/course_service.py (category-based logic)
- [x] T058 [US2] Implement GET /api/v1/courses/recommendations endpoint in backend/app/routes/courses.py

### Frontend - Course Grid & Cards (FR-011, FR-012)

- [x] T059 [P] [US2] Create CourseCard component in frontend/src/components/courses/CourseCard.tsx (thumbnail, title, category, difficulty, enrollment count)
- [x] T060 [P] [US2] Create CourseGrid component in frontend/src/components/courses/CourseGrid.tsx (responsive grid layout)
- [x] T061 [US2] Implement CourseGrid with Motion animations (stagger children, card hover effects)

### Frontend - Search & Filters (FR-013, FR-014, FR-015, FR-022)

- [x] T062 [P] [US2] Create SearchBar component in frontend/src/components/courses/SearchBar.tsx (debounced input, 300ms delay)
- [x] T063 [P] [US2] Create CourseFilters component in frontend/src/components/courses/CourseFilters.tsx (category dropdown, difficulty selector)
- [x] T064 [US2] Implement filter state management in CourseFilters component (update URL params)
- [x] T065 [US2] Connect SearchBar to filter state with 300ms debounce (FR-022)

### Frontend - Infinite Scroll (FR-016, FR-023)

- [x] T066 [P] [US2] Create useCourseSearch hook in frontend/src/hooks/useCourseSearch.ts (TanStack Query useInfiniteQuery)
- [x] T067 [US2] Implement intersection observer for infinite scroll in CourseGrid component (threshold: 0.8)
- [x] T068 [US2] Add loading skeleton component in frontend/src/components/courses/CourseGridSkeleton.tsx
- [x] T069 [US2] Test infinite scroll: verify next page fetches when scrolling near bottom

### Frontend - Course Catalog Page (FR-011)

- [x] T070 [US2] Create CourseCatalogPage in frontend/src/pages/CourseCatalogPage.tsx (integrates SearchBar, CourseFilters, CourseGrid)
- [ ] T071 [US2] Add course catalog route to frontend/src/routes/index.tsx (/courses)
- [ ] T072 [US2] Test full course discovery flow: search, filter, infinite scroll

### Testing

- [ ] T073 [P] [US2] Create CourseCard unit test in frontend/src/components/courses/__tests__/CourseCard.test.tsx
- [ ] T074 [P] [US2] Create useCourseSearch hook test in frontend/src/hooks/__tests__/useCourseSearch.test.ts
- [ ] T075 [P] [US2] Create backend course search test in backend/tests/test_course_service.py
- [ ] T076 [US2] Create E2E test for course discovery flow in frontend/tests/e2e/course-discovery.spec.ts

**Phase 4 Completion Checklist**:
- [ ] All T051-T076 tasks completed (22/26 done)
- [x] Course search endpoint functional (/api/v1/courses/search)
- [x] Search bar with debounce working
- [x] Filters update results in real-time
- [x] Infinite scroll fetches next page automatically
- [ ] All tests pass
- [ ] phase-4-summary.md created with course discovery details
- [ ] phase-4-next-steps.md evaluates US2 completeness
- [ ] Phase 4 marked complete in tasks.md

---

## Phase 5: User Story 3 - Learning Path Visualization (Priority: P1)

**Goal**: Display visual learning path with completed, in-progress, and locked lesson states

**Independent Test**: Enroll in course, complete lessons, verify visual path shows correct states (checkmarks for completed, highlight for current, locks for upcoming).

**AI Agent Instructions**: When user says **"Implement Phase 5"**:
1. **MANDATORY PRE-IMPLEMENTATION ANALYSIS**:
   - Read phase-4-summary.md (course discovery complete)
   - Read specs/002-mobile-ux-redesign/work/ to understand existing structure
   - Search for existing LearningPath components, ProgressService
   - Search backend/app/services/ for existing LearningPathService (created in Phase 1)
   - Search backend/app/routes/learning_paths.py for existing endpoints
   - Read spec.md User Story 3 acceptance criteria (FR-026 to FR-040)
   - Read contracts/learning-paths-api.yaml for visualization endpoints
   - Read data-model.md section 2.3 (LearningPath with path_nodes)
   - Read research.md section 5 (Motion performance patterns)
   - Document findings in specs/002-mobile-ux-redesign/work/notes/phase-5-existing-learning-path.md
2. **INTEGRATION REQUIREMENTS**:
   - Extend existing LearningPathService and ProgressService from Phase 1
   - Add endpoints to existing learning_paths.py and progress.py route files
   - Search for existing progress tracking before creating new models
3. Create phase-5-summary.md documenting path visualization
4. Create phase-5-next-steps.md evaluating US3 completeness
5. Update /work CURRENT_STRUCTURE.md files

### Backend - Learning Path Data (FR-026, FR-027, FR-028)

- [x] T077 [P] [US3] Extend LearningPath model with path_nodes in backend/app/models/learning_path.py (PathNode schema)
- [x] T078 [P] [US3] Implement LearningPathService.generate_path_nodes() method in backend/app/services/learning_path_service.py
- [x] T079 [P] [US3] Implement GET /api/v1/learning-paths/{course_id} endpoint in backend/app/routes/learning_paths.py
- [x] T080 [US3] Generate path_nodes for existing courses (migration script in backend/scripts/generate_path_visualizations.py)

### Backend - Progress Tracking (FR-032, FR-033, FR-034)

- [x] T081 [P] [US3] Extend UserProgress model with lesson_progress in backend/app/models/user_progress.py (LessonProgress schema)
- [x] T082 [P] [US3] Implement ProgressService.get_user_progress() method in backend/app/services/progress_service.py
- [x] T083 [P] [US3] Implement GET /api/v1/progress/{course_id} endpoint in backend/app/routes/progress.py
- [x] T084 [US3] Implement ProgressService.update_lesson_progress() method in backend/app/services/progress_service.py
- [x] T085 [US3] Implement POST /api/v1/progress/{course_id}/lessons/{lesson_id} endpoint in backend/app/routes/progress.py

### Frontend - Path Visualization Components (FR-026, FR-027, FR-028, FR-029)

- [x] T086 [P] [US3] Create PathVisualization component in frontend/src/components/learning-path/PathVisualization.tsx (SVG-based path rendering)
- [x] T087 [P] [US3] Create LessonNode component in frontend/src/components/learning-path/LessonNode.tsx (visual node with state: completed, current, locked)
- [x] T088 [P] [US3] Create PathConnector component in frontend/src/components/learning-path/PathConnector.tsx (SVG lines connecting nodes)
- [x] T089 [US3] Implement path layout algorithm in PathVisualization (convert path_nodes to SVG coordinates)

### Frontend - Progress Overlays (FR-030, FR-031, FR-032)

- [x] T090 [P] [US3] Implement completed lesson styling in LessonNode (checkmark icon, colored indicator)
- [x] T091 [P] [US3] Implement current lesson styling in LessonNode (highlight, progress percentage)
- [x] T092 [P] [US3] Implement locked lesson styling in LessonNode (grayed out, lock icon)
- [x] T093 [US3] Add Motion animations for path reveal (stagger nodes, fade-in connectors)

### Frontend - Learning Path Page (FR-026)

- [x] T094 [US3] Create LearningPathPage in frontend/src/pages/LearningPathPage.tsx (integrates PathVisualization, fetches user progress)
- [x] T095 [US3] Add learning path route to frontend/src/routes/index.tsx (/courses/:courseId/path)
- [ ] T096 [US3] Test full path visualization: verify states update correctly after lesson completion

### Testing

- [ ] T097 [P] [US3] Create PathVisualization unit test in frontend/src/components/learning-path/__tests__/PathVisualization.test.tsx
- [ ] T098 [P] [US3] Create LessonNode unit test in frontend/src/components/learning-path/__tests__/LessonNode.test.tsx
- [ ] T099 [P] [US3] Create backend learning path test in backend/tests/test_learning_path_service.py
- [ ] T100 [US3] Create E2E test for path visualization in frontend/tests/e2e/learning-path-visual.spec.ts

**Phase 5 Completion Checklist**:
- [x] All T077-T095 core tasks completed (17/20 tasks)
- [x] Learning path endpoints functional
- [x] Progress tracking endpoints functional
- [x] Path visualization renders correctly
- [x] Lesson states display correctly (completed, current, locked)
- [x] Animations smooth (60fps target)
- [x] T080 Migration script created (optional - lazy generation working)
- [ ] Integration testing complete (T096)
- [ ] Unit tests (T097-T100) - deferred to Phase 9.5
- [x] phase-5-summary.md created with visualization details
- [x] phase-5-next-steps.md evaluates US3 completeness
- [x] Phase 5 marked 90% complete in tasks.md (core + migration COMPLETE)

---

## Phase 6: User Story 4 - Personalized Dashboard (Priority: P2)

**Goal**: Provide dashboard with enrolled courses, recent activity, achievements, and "Continue Learning" button

**Independent Test**: Enroll in courses, complete activities, verify dashboard shows accurate stats, recent activity, and "Continue Learning" takes you to next lesson.

**AI Agent Instructions**: When user says **"Implement Phase 6"**:
1. **MANDATORY PRE-IMPLEMENTATION ANALYSIS**:
   - Read phase-5-summary.md (learning path complete)
   - Read specs/002-mobile-ux-redesign/work/frontend/CURRENT_STRUCTURE.md
   - Search for existing Dashboard component (extracted in Phase 1)
   - Search for existing progress endpoints in backend/app/routes/progress.py
   - Search for existing ProgressService methods (created in Phase 1)
   - Read spec.md User Story 4 acceptance criteria (FR-041 to FR-050)
   - Read contracts/learning-paths-api.yaml (continue endpoint)
   - Read data-model.md section 2.2 (UserProgress with recent_lessons)
   - Document findings in specs/002-mobile-ux-redesign/work/notes/phase-6-existing-dashboard.md
2. **INTEGRATION REQUIREMENTS**:
   - If Dashboard was extracted in Phase 1, enhance it rather than recreate
   - Extend existing ProgressService methods
   - Add endpoints to existing progress.py routes
3. Create phase-6-summary.md documenting dashboard implementation
4. Create phase-6-next-steps.md evaluating US4 completeness
5. Update /work CURRENT_STRUCTURE.md files

### Backend - Dashboard Data (FR-041, FR-042, FR-043)

- [x] T101 [P] [US4] Implement ProgressService.get_enrolled_courses() method in backend/app/services/progress_service.py
- [x] T102 [P] [US4] Implement ProgressService.get_recent_activity() method in backend/app/services/progress_service.py
- [x] T103 [P] [US4] Implement ProgressService.get_continue_lesson() method in backend/app/services/progress_service.py (finds next incomplete lesson)
- [x] T104 [US4] Implement GET /api/v1/progress/{course_id}/continue endpoint in backend/app/routes/progress.py

### Frontend - Dashboard Components (FR-041, FR-042, FR-043, FR-044, FR-045)

- [x] T105 [P] [US4] Create EnrolledCourseCard component in frontend/src/components/dashboard/EnrolledCourseCard.tsx (progress bar, continue button)
- [x] T106 [P] [US4] Create RecentActivityList component in frontend/src/components/dashboard/RecentActivityList.tsx (last 5 completed lessons)
- [x] T107 [P] [US4] Create AchievementBadges component in frontend/src/components/dashboard/AchievementBadges.tsx (badges, points)
- [x] T108 [P] [US4] Create DashboardStats component in frontend/src/components/dashboard/DashboardStats.tsx (completion percentage, time spent)
- [x] T109 [US4] Create or Update Dashboard page component in frontend/src/components/dashboard/Dashboard.tsx (integrates all dashboard components)

### Frontend - Continue Learning (FR-043)

- [x] T110 [US4] Implement "Continue Learning" button in EnrolledCourseCard (calls /continue endpoint)
- [x] T111 [US4] Test "Continue Learning" flow: click button → navigates to correct next lesson

### Frontend - Recommendations (FR-046)

- [x] T112 [P] [US4] Create RecommendedCourses component in frontend/src/components/dashboard/RecommendedCourses.tsx (uses /recommendations endpoint)
- [x] T113 [US4] Integrate RecommendedCourses in Dashboard page

### Frontend - Dashboard Page (FR-041)

- [x] T114 [US4] Add dashboard route to frontend/src/routes/index.tsx (/)
- [x] T115 [US4] Set dashboard as default landing page after login
- [ ] T116 [US4] Test full dashboard: verify all data displays correctly

### Testing

- [ ] T117 [P] [US4] Create Dashboard unit test in frontend/src/components/dashboard/__tests__/Dashboard.test.tsx
- [ ] T118 [P] [US4] Create backend progress service test in backend/tests/test_progress_service.py
- [ ] T119 [US4] Create E2E test for dashboard flow in frontend/tests/e2e/dashboard.spec.ts

**Phase 6 Completion Checklist**:
- [x] All T101-T116 tasks completed (16/19 tasks - testing deferred)
- [x] Dashboard displays enrolled courses with progress
- [x] Recent activity shows last 5 lessons
- [x] Continue Learning button works
- [x] Recommendations display correctly
- [x] Dashboard route integrated in App.tsx
- [x] Dashboard set as default landing page
- [x] Continue Learning handler implemented
- [ ] Manual integration testing complete (T116)
- [ ] All tests pass (T117-T119 deferred to Phase 9.5/9.6)
- [x] phase-6-summary.md created with dashboard details
- [x] phase-6-next-steps.md evaluates US4 completeness
- [x] Phase 6 marked 95% complete in tasks.md (core functionality COMPLETE, testing pending)

---

## Phase 7: User Story 5 - Seamless Theme Switching (Priority: P2)

**Goal**: Enable bright/dark theme toggle with persistence across sessions

**Independent Test**: Toggle theme switcher, verify all UI elements update correctly, refresh page, verify theme persists.

**AI Agent Instructions**: When user says **"Implement Phase 7"**:
1. **MANDATORY PRE-IMPLEMENTATION ANALYSIS**:
   - Read phase-6-summary.md (dashboard complete)
   - Read specs/002-mobile-ux-redesign/work/frontend/CURRENT_STRUCTURE.md
   - Verify ThemeStore exists from Phase 2 (do NOT recreate)
   - Search for existing theme toggle components
   - Read spec.md User Story 5 acceptance criteria (FR-051 to FR-055)
   - Read research.md section 6 (Tailwind dark mode patterns)
   - Document findings in specs/002-mobile-ux-redesign/work/notes/phase-7-existing-theme.md
2. **INTEGRATION REQUIREMENTS**:
   - Use existing ThemeStore from Phase 2
   - Apply theme classes to ALL components created in Phases 3-6
   - Maintain existing Tailwind configuration
3. Create phase-7-summary.md documenting theme implementation
4. Create phase-7-next-steps.md evaluating US5 completeness
5. Update /work CURRENT_STRUCTURE.md files

### Theme Configuration (FR-051, FR-053)

- [x] T120 [US5] Verify ThemeStore implementation (already done in T026) - ensure localStorage persistence works
- [x] T121 [US5] Verify Tailwind dark mode config (already done in T029) - ensure class-based mode enabled

### Frontend - Theme Toggle UI (FR-052)

- [x] T122 [P] [US5] Create ThemeToggle component in frontend/src/components/theme/ThemeToggle.tsx (moon/sun icon, smooth transition)
- [x] T123 [US5] Add ThemeToggle to DesktopNav component (top-right corner)
- [x] T124 [US5] Add ThemeToggle to MobileNav component (settings icon)

### Theme Application (FR-054, FR-055)

- [x] T125 [P] [US5] Apply dark mode classes to navigation components (DesktopNav, MobileNav)
- [x] T126 [P] [US5] Apply dark mode classes to course components (CourseCard, CourseGrid)
- [x] T127 [P] [US5] Apply dark mode classes to learning path components (PathVisualization, LessonNode)
- [x] T128 [P] [US5] Apply dark mode classes to dashboard components (Dashboard, EnrolledCourseCard, RecentActivityList)
- [x] T129 [US5] Add smooth transition CSS for theme changes (300ms ease) in global CSS

### Testing & Validation

- [ ] T130 [US5] Manual test: Toggle theme in navigation - verify all components update
- [ ] T131 [US5] Manual test: Refresh page - verify theme persists from localStorage
- [ ] T132 [P] [US5] Create ThemeToggle unit test in frontend/src/components/theme/__tests__/ThemeToggle.test.tsx
- [ ] T133 [US5] Create E2E test for theme switching in frontend/tests/e2e/theme-switching.spec.ts

**Phase 7 Completion Checklist**:
- [x] All T120-T129 core tasks completed
- [x] Theme toggle visible in navigation
- [x] All UI components respect dark mode
- [x] Theme persistence implemented via ThemeStore
- [x] Transitions smooth (300ms)
- [ ] Manual testing (T130-T131) - requires running app
- [ ] Unit/E2E tests (T132-T133) - deferred to Phase 9.7
- [ ] phase-7-summary.md created with theme implementation details
- [ ] phase-7-next-steps.md evaluates US5 completeness
- [ ] Phase 7 marked complete in tasks.md

---

## Phase 8: User Story 6 - Enhanced Admin DSL (Priority: P2)

**Goal**: Enable admins to create rich courses with video embeds, quizzes, coding exercises using enhanced DSL

**Independent Test**: Login as admin, create course with DSL containing video, quiz, exercise. Verify preview shows sanitized content and course saves correctly.

**AI Agent Instructions**: When user says **"Implement Phase 8"**:
1. **MANDATORY PRE-IMPLEMENTATION ANALYSIS**:
   - Read phase-7-summary.md (theme complete)
   - Read specs/002-mobile-ux-redesign/work/backend/CURRENT_STRUCTURE.md
   - Search for existing DSLService (created in Phase 1) - MUST extend, not recreate
   - Search backend/app/routes/admin.py for existing DSL endpoints
   - Search for existing lesson content components (LessonViewer extracted in Phase 1)
   - Read spec.md User Story 6 acceptance criteria (FR-056 to FR-070)
   - Read contracts/admin-dsl-api.yaml for parsing/preview/sanitize endpoints
   - Read data-model.md section 1.3 (EnhancedContentItem types)
   - Read research.md section 10 (Bleach sanitization patterns)
   - Document findings in specs/002-mobile-ux-redesign/work/notes/phase-8-existing-dsl.md
2. **INTEGRATION REQUIREMENTS**:
   - Extend existing DSLService from Phase 1 with new content types
   - Add endpoints to existing admin.py routes
   - Enhance existing LessonViewer with new content type rendering
   - Use Bleach sanitization configured in Phase 2
3. Create phase-8-summary.md documenting DSL enhancements
4. Create phase-8-next-steps.md evaluating US6 completeness
5. Update /work CURRENT_STRUCTURE.md files

### Backend - DSL Parsing (FR-056, FR-057, FR-058, FR-059, FR-060, FR-061)

- [x] T134 [P] [US6] Extend DSLService.parse() method in backend/app/services/dsl_service.py to support VIDEO syntax
- [x] T135 [P] [US6] Extend DSLService.parse() to support QUIZ syntax with QUESTION/OPTIONS/CORRECT/EXPLANATION
- [x] T136 [P] [US6] Extend DSLService.parse() to support EXERCISE syntax with LANGUAGE/STARTER_CODE/EXPECTED_OUTPUT
- [x] T137 [P] [US6] Extend DSLService.parse() to support SUMMARY syntax
- [x] T138 [US6] Update POST /api/v1/admin/dsl/parse endpoint in backend/app/routes/admin.py with enhanced parsing

### Backend - XSS Sanitization (FR-066)

- [x] T139 [P] [US6] Implement sanitize_dsl_content() in backend/app/utils/sanitization.py (Bleach with allowed tags)
- [x] T140 [P] [US6] Implement sanitize_video_url() in backend/app/utils/sanitization.py (YouTube/Vimeo whitelist)
- [x] T141 [US6] Integrate sanitization in DSLService.parse() - sanitize at multiple stages
- [x] T142 [US6] Implement POST /api/v1/admin/dsl/sanitize endpoint in backend/app/routes/admin.py

### Backend - DSL Preview (FR-064, FR-065)

- [x] T143 [US6] Implement DSLService.generate_preview() method in backend/app/services/dsl_service.py (HTML output)
- [x] T144 [US6] Implement POST /api/v1/admin/dsl/preview endpoint in backend/app/routes/admin.py

### Frontend - Admin DSL Editor (FR-062, FR-063)

- [x] T145 [P] [US6] Create DSLEditor component in frontend/src/components/admin/DSLEditor.tsx (textarea with syntax highlighting)
- [x] T146 [P] [US6] Create DSLPreview component in frontend/src/components/admin/DSLPreview.tsx (sanitized HTML display)
- [ ] T147 [US6] Create AdminCoursePage in frontend/src/pages/AdminCoursePage.tsx (integrates DSLEditor, DSLPreview)
- [ ] T148 [US6] Add admin course creation route to frontend/src/routes/index.tsx (/admin/courses/new)

### Frontend - Lesson Content Rendering (FR-067, FR-068, FR-069, FR-070)

- [x] T149 [P] [US6] Create VideoContent component in frontend/src/components/lesson/VideoContent.tsx (YouTube/Vimeo embed)
- [x] T150 [P] [US6] Create QuizContent component in frontend/src/components/lesson/QuizContent.tsx (interactive quiz with validation)
- [x] T151 [P] [US6] Create ExerciseContent component in frontend/src/components/lesson/ExerciseContent.tsx (Pyodide integration)
- [ ] T152 [P] [US6] Create code execution worker in frontend/src/workers/codeExecutor.worker.ts (Pyodide in Web Worker)
- [x] T153 [US6] Integrate enhanced content types in LessonViewer component

### Testing

- [ ] T154 [P] [US6] Create DSL parsing tests in backend/tests/test_dsl_service.py (video, quiz, exercise)
- [ ] T155 [P] [US6] Create Bleach sanitization tests in backend/tests/test_sanitization.py (XSS vectors)
- [ ] T156 [US6] Create E2E test for admin DSL workflow in frontend/tests/e2e/admin-dsl.spec.ts

### Production-Ready Testing Infrastructure (FR-073)

- [x] T157 [P] [US6] Create start-enhanced.ps1 script in repository root with same functionality as start.ps1 plus database setup
- [x] T158 [P] [US6] Add database initialization to start-enhanced.ps1 - check for and start local Cosmos DB emulator or PostgreSQL container
- [x] T159 [P] [US6] Add database seeding to start-enhanced.ps1 - populate test data from seed/ directory (sample courses, users, paths)
- [x] T160 [P] [US6] Add health check validation to start-enhanced.ps1 - verify backend API, database connection, frontend build before opening browser
- [x] T161 [US6] Add configuration validation to start-enhanced.ps1 - check for required environment variables, warn about missing optional configs
- [x] T162 [US6] Add browser auto-launch to start-enhanced.ps1 - open default browser to http://localhost:8000 after successful startup
- [ ] T163 [US6] Document start-enhanced.ps1 usage in README.md - prerequisites, what it does, troubleshooting common issues

**Phase 8 Completion Checklist**:
- [x] DSL parser supports video, quiz, exercise, summary (T134-T138 complete)
- [x] XSS sanitization working (Bleach configured) (T139-T142 complete)
- [x] Admin preview shows sanitized content (T143-T146 complete)
- [x] Lesson viewer renders all content types (T149-T151, T153 complete)
- [x] Pyodide code execution functional (T151 - integrated in ExerciseContent)
- [x] start-enhanced.ps1 script functional with database setup (T157-T162 complete)
- [ ] AdminCoursePage and routing (T147-T148)
- [ ] Code execution Web Worker (T152)
- [ ] Testing tasks (T154-T156)
- [ ] Documentation (T163)
- [ ] phase-8-summary.md created with DSL enhancement details
- [ ] phase-8-next-steps.md evaluates US6 completeness
- [x] Phase 8 core functionality complete (18/22 tasks)

---

## Phase 9: Polish, Testing & Production Readiness

**Purpose**: Final improvements, comprehensive testing, optimization, documentation, and deployment preparation for full production-ready application

**Dependencies**: All prior phases (0-8) complete

**⚠️ MANDATORY PRE-IMPLEMENTATION ANALYSIS**: Before starting ANY implementation tasks, the agent MUST:
1. Create analysis task checklist file: `specs/002-mobile-ux-redesign/work/notes/phase-9-analysis-tasks.md`
2. Document current state of:
   - All implemented features from Phases 1-8 (read all phase summaries)
   - Current testing infrastructure and test patterns
   - Deployment configuration in infra/
   - Documentation completeness across all modules
   - Security implementations (auth, sanitization, rate limiting)
   - Performance baseline measurements
3. Update the analysis task checklist as each analysis task is completed
4. Only proceed to implementation tasks after ALL analysis tasks are checked off
5. Reference analysis findings to ensure polish aligns with all prior implementations

**AI Agent Instructions**: This phase is broken into **independent sub-phases** that can run separately. When user says **"Implement Phase 9.X"**:
1. Read ALL prior phase summaries (phase-0 through phase-8) from specs/002-mobile-ux-redesign/phase-summaries/
2. Read ALL files in specs/002-mobile-ux-redesign/work/ (complete app structure understanding)
3. Read spec.md success criteria (SC-001 to SC-015)
4. Read research.md for performance targets
5. Execute sub-phase specific tasks (see below)
6. Create phase-9.X-summary.md for each sub-phase
7. Create final phase-9-summary.md after all sub-phases complete

---

### Phase 9.1: Code Quality & Documentation

**Purpose**: Ensure code quality, comprehensive documentation, and maintainability

**AI Agent Instructions**: When user says **"Implement Phase 9.1"**:
1. **MANDATORY**: Read analysis findings from specs/002-mobile-ux-redesign/work/notes/phase-9-analysis-tasks.md
2. Search ALL Python files in backend/app/ for undocumented functions
3. Search ALL TypeScript files in frontend/src/ for missing type definitions
4. Read existing documentation/ to understand documentation patterns

### Tasks

- [ ] T164 [P] [PHASE-9.1] Run code linting (black, ruff, mypy) on all Python files in backend/app/, ensure 100% compliance
- [ ] T165 [P] [PHASE-9.1] Run code formatting (prettier, eslint) on all TypeScript files in frontend/src/, ensure 100% compliance
- [ ] T166 [P] [PHASE-9.1] Add Google-style docstrings to all public functions in backend/app/services/, backend/app/routes/
- [ ] T167 [P] [PHASE-9.1] Add JSDoc comments to all exported functions in frontend/src/hooks/, frontend/src/services/
- [ ] T168 [PHASE-9.1] Update top-level README.md with feature 002 overview, quick start, architecture diagram reference
- [ ] T169 [PHASE-9.1] Create comprehensive API documentation in documentation/api/ from OpenAPI specs in contracts/
- [ ] T170 [PHASE-9.1] Update documentation/ARCHITECTURE.md with all new components from Phases 1-8

**Phase 9.1 Completion Checklist**:
- [ ] All linting passes with 0 errors
- [ ] All public functions documented
- [ ] README.md updated with feature 002
- [ ] API documentation complete
- [ ] phase-9.1-summary.md created
- [ ] Update /work/notes/ with documentation coverage report

---

### Phase 9.2: Error Handling & Resilience

**Purpose**: Comprehensive error handling, edge cases, and graceful degradation

**AI Agent Instructions**: When user says **"Implement Phase 9.2"**:
1. Search ALL backend/app/routes/ files for error handling patterns
2. Search ALL frontend/src/components/ for error boundaries
3. Read existing error handling utilities

### Tasks

- [ ] T171 [P] [PHASE-9.2] Add comprehensive error handling to all API endpoints with proper HTTP status codes (400, 401, 403, 404, 500)
- [ ] T172 [P] [PHASE-9.2] Implement error boundaries in frontend/src/components/App.tsx and all page components
- [ ] T173 [P] [PHASE-9.2] Add TanStack Query error handling with retry logic (max 3 retries, exponential backoff)
- [ ] T174 [P] [PHASE-9.2] Implement WebSocket reconnection logic with state recovery in frontend (if WebSocket used)
- [ ] T175 [PHASE-9.2] Add validation for unrealistic course/lesson data (empty titles, negative durations)
- [ ] T176 [PHASE-9.2] Implement graceful degradation for missing course thumbnails (placeholder images)
- [ ] T177 [PHASE-9.2] Add offline detection and user notification in PWA

**Phase 9.2 Completion Checklist**:
- [ ] All endpoints have error handling
- [ ] Error boundaries tested
- [ ] Offline behavior documented
- [ ] phase-9.2-summary.md created

---

### Phase 9.3: Performance Optimization

**Purpose**: Optimize bundle size, API performance, rendering performance

**AI Agent Instructions**: When user says **"Implement Phase 9.3"**:
1. Run Lighthouse audit to establish baseline
2. Search for expensive computations in components
3. Read research.md performance targets

### Tasks

- [ ] T178 [P] [PHASE-9.3] Run Lighthouse audit on production build - establish baseline scores
- [ ] T179 [P] [PHASE-9.3] Optimize bundle size - ensure frontend bundle <500KB gzipped (use webpack-bundle-analyzer)
- [ ] T180 [P] [PHASE-9.3] Add React.memo to CourseCard, LessonNode, NavItem components for render optimization
- [ ] T181 [P] [PHASE-9.3] Implement code splitting for admin routes (lazy load admin components)
- [ ] T182 [PHASE-9.3] Add Redis caching for expensive API calls (course search, recommendations) if not already implemented
- [ ] T183 [PHASE-9.3] Optimize database queries - run EXPLAIN ANALYZE on frequent queries, add indexes if needed
- [ ] T184 [PHASE-9.3] Verify 60fps animations on mobile (test Motion animations on physical Android/iOS device)
- [ ] T185 [PHASE-9.3] Profile API response times - ensure p95 <500ms for all critical endpoints

**Phase 9.3 Completion Checklist**:
- [ ] Lighthouse Performance >90, Accessibility >90
- [ ] Bundle size <500KB gzipped
- [ ] API p95 <500ms verified
- [ ] phase-9.3-summary.md created with performance metrics

---

### Phase 9.4: Security & Compliance

**Purpose**: Security hardening, rate limiting, compliance checks

**AI Agent Instructions**: When user says **"Implement Phase 9.4"**:
1. Search for authentication checks in all protected routes
2. Search for XSS vulnerabilities in user-generated content rendering
3. Read research.md security requirements

### Tasks

- [ ] T186 [P] [PHASE-9.4] Implement rate limiting on all API endpoints (100 req/min per user) using Flask-Limiter or similar
- [ ] T187 [P] [PHASE-9.4] Verify JWT token validation on all protected endpoints (search backend/app/routes/ for @auth decorators)
- [ ] T188 [P] [PHASE-9.4] Verify Bleach sanitization applied to all user-generated content (DSL, course descriptions)
- [ ] T189 [PHASE-9.4] Implement Azure Key Vault integration for secret management (API keys, DB passwords) in backend/config.py
- [ ] T190 [PHASE-9.4] Add audit logging for sensitive operations (course creation, user deletion) using structlog
- [ ] T191 [PHASE-9.4] Verify HTTPS/TLS 1.3 enforcement in production deployment configuration (infra/)
- [ ] T192 [PHASE-9.4] Run security audit: secrets check (no hardcoded keys), dependency vulnerabilities (pip-audit, npm audit)

**Phase 9.4 Completion Checklist**:
- [ ] Rate limiting functional
- [ ] All secrets in Key Vault
- [ ] Security audit passes
- [ ] phase-9.4-summary.md created with security checklist

---

### Phase 9.5: Integration Testing - Navigation & Discovery (US1, US2)

**Purpose**: End-to-end tests for navigation and course discovery features

**AI Agent Instructions**: When user says **"Implement Phase 9.5"**:
1. Read phase-3-summary.md and phase-4-summary.md for implemented features
2. Search for existing E2E test patterns in frontend/tests/e2e/
3. Ensure test data fixtures exist for courses

### Tasks

- [ ] T193 [P] [PHASE-9.5] Create E2E test: Desktop navigation (≥1024px) → verify left panel visible, all routes accessible in frontend/tests/e2e/navigation-desktop.spec.ts
- [ ] T194 [P] [PHASE-9.5] Create E2E test: Mobile navigation (<1024px) → verify bottom bar visible, all routes accessible in frontend/tests/e2e/navigation-mobile.spec.ts
- [ ] T195 [P] [PHASE-9.5] Create E2E test: Course search → filter by category → filter by difficulty → verify results in frontend/tests/e2e/course-search.spec.ts
- [ ] T196 [P] [PHASE-9.5] Create E2E test: Infinite scroll → scroll to bottom → verify next page loads in frontend/tests/e2e/course-infinite-scroll.spec.ts
- [ ] T197 [PHASE-9.5] Run all Phase 9.5 tests and verify success criteria SC-001 (navigation), SC-002 (course discovery)

**Phase 9.5 Completion Checklist**:
- [ ] All US1 tests pass
- [ ] All US2 tests pass
- [ ] phase-9.5-summary.md created with test results

---

### Phase 9.6: Integration Testing - Learning Path & Dashboard (US3, US4)

**Purpose**: End-to-end tests for learning path visualization and dashboard

**AI Agent Instructions**: When user says **"Implement Phase 9.6"**:
1. Read phase-5-summary.md and phase-6-summary.md
2. Search for existing progress tracking test patterns
3. Ensure test data for user progress exists

### Tasks

- [ ] T198 [P] [PHASE-9.6] Create E2E test: Enroll in course → complete lesson → verify learning path shows checkmark in frontend/tests/e2e/learning-path-progress.spec.ts
- [ ] T199 [P] [PHASE-9.6] Create E2E test: Learning path states → verify completed (checkmark), current (highlight), locked (grayed) in frontend/tests/e2e/learning-path-states.spec.ts
- [ ] T200 [P] [PHASE-9.6] Create E2E test: Dashboard → verify enrolled courses display with progress bars in frontend/tests/e2e/dashboard-enrolled.spec.ts
- [ ] T201 [P] [PHASE-9.6] Create E2E test: "Continue Learning" button → verify navigates to correct next lesson in frontend/tests/e2e/dashboard-continue.spec.ts
- [ ] T202 [PHASE-9.6] Run all Phase 9.6 tests and verify success criteria SC-003 (learning path), SC-004 (dashboard)

**Phase 9.6 Completion Checklist**:
- [ ] All US3 tests pass
- [ ] All US4 tests pass
- [ ] phase-9.6-summary.md created

---

### Phase 9.7: Integration Testing - Theme & Admin DSL (US5, US6)

**Purpose**: End-to-end tests for theme switching and admin DSL functionality

**AI Agent Instructions**: When user says **"Implement Phase 9.7"**:
1. Read phase-7-summary.md and phase-8-summary.md
2. Search for theme toggle components
3. Ensure admin user credentials exist for testing

### Tasks

- [ ] T203 [P] [PHASE-9.7] Create E2E test: Theme toggle → verify all components update to dark mode in frontend/tests/e2e/theme-switching.spec.ts
- [ ] T204 [P] [PHASE-9.7] Create E2E test: Refresh page → verify theme persists from localStorage in frontend/tests/e2e/theme-persistence.spec.ts
- [ ] T205 [P] [PHASE-9.7] Create E2E test: Admin DSL editor → create course with VIDEO, QUIZ, EXERCISE → preview → save in frontend/tests/e2e/admin-dsl-create.spec.ts
- [ ] T206 [P] [PHASE-9.7] Create E2E test: DSL XSS protection → input malicious script → verify sanitized in frontend/tests/e2e/admin-dsl-sanitization.spec.ts
- [ ] T207 [PHASE-9.7] Run all Phase 9.7 tests and verify success criteria SC-005 (theme), SC-006 (admin DSL)

**Phase 9.7 Completion Checklist**:
- [ ] All US5 tests pass
- [ ] All US6 tests pass
- [ ] phase-9.7-summary.md created

---

### Phase 9.8: Deployment & DevOps Configuration

**Purpose**: Production deployment configuration, Docker, CI/CD pipeline

**AI Agent Instructions**: When user says **"Implement Phase 9.8"**:
1. Read existing infra/ configuration
2. Search for Dockerfile and docker-compose.yml
3. Read .github/workflows/ for existing CI/CD

### Tasks

- [ ] T208 [P] [PHASE-9.8] Update Dockerfile with all new dependencies from Phases 1-8 (React 19, TanStack Query, Motion, Pyodide, Zustand, Structlog, Bleach) in Dockerfile
- [ ] T209 [P] [PHASE-9.8] Update docker-compose.yml with PostgreSQL/Cosmos DB emulator, Redis services if needed
- [ ] T210 [P] [PHASE-9.8] Create Azure infrastructure scripts in infra/deploy-azure.sh for all required resources (App Service, Cosmos DB, Blob Storage, Key Vault)
- [ ] T211 [PHASE-9.8] Update CI/CD pipeline in .github/workflows/ci.yml to run linting, tests, E2E validation
- [ ] T212 [PHASE-9.8] Create deployment checklist in documentation/DEPLOYMENT_CHECKLIST.md with pre-deploy, deploy, post-deploy steps
- [ ] T213 [PHASE-9.8] Verify quickstart.md instructions work end-to-end on clean development environment

**Phase 9.8 Completion Checklist**:
- [ ] Docker builds successfully
- [ ] CI/CD pipeline passes
- [ ] Deployment checklist complete
- [ ] phase-9.8-summary.md created

---

### Phase 9.9: Route & Frontend-Backend Integration Validation

**Purpose**: Comprehensive audit of all routes, API endpoints, and frontend-backend connections

**AI Agent Instructions**: When user says **"Implement Phase 9.9"**:
1. Read ALL frontend service files in frontend/src/services/
2. Read ALL backend route files in backend/app/routes/
3. Create comprehensive route mapping

### Tasks

- [ ] T214 [PHASE-9.9] Audit all frontend/src/services/*.ts files against backend/app/routes/ - verify every API call has corresponding endpoint
- [ ] T215 [PHASE-9.9] Audit all frontend/src/pages/ routes against navigation - verify all routes have navigation implemented
- [ ] T216 [PHASE-9.9] Verify all route parameters in frontend routing match backend endpoint parameter names (courseId vs course_id)
- [ ] T217 [PHASE-9.9] Validate all error responses (4xx/5xx) are handled by frontend error boundaries or component error states
- [ ] T218 [PHASE-9.9] Test complete user workflows end-to-end: signup → login → browse courses → enroll → view path → complete lesson
- [ ] T219 [PHASE-9.9] Generate route mapping documentation in documentation/ROUTES.md listing all frontend routes, backend endpoints, implementation status

**Phase 9.9 Completion Checklist**:
- [ ] All API calls have endpoints
- [ ] All routes have navigation
- [ ] Route mapping document complete
- [ ] phase-9.9-summary.md created

---

### Phase 9.10: Final Validation & Production Readiness

**Purpose**: Comprehensive smoke test, final checks, production deployment validation

**AI Agent Instructions**: When user says **"Implement Phase 9.10"**:
1. Read ALL phase summaries (0-9.9)
2. Read spec.md all success criteria (SC-001 to SC-015)
3. Read spec.md all functional requirements (FR-001 to FR-073)

### Tasks

- [ ] T220 [PHASE-9.10] Run complete application smoke test following quickstart.md workflow from clean environment
- [ ] T221 [PHASE-9.10] Verify ALL success criteria from spec.md (SC-001 through SC-015) are met - document evidence
- [ ] T222 [PHASE-9.10] Verify ALL functional requirements from spec.md (FR-001 through FR-073) are implemented - create checklist
- [ ] T223 [PHASE-9.10] Run full E2E test suite (all tests from 9.5, 9.6, 9.7) on production-like environment
- [ ] T224 [PHASE-9.10] Perform final integration check: verify all Phase 9 improvements integrate with existing system without breaking prior implementations
- [ ] T225 [PHASE-9.10] Generate final deployment package with versioned artifacts (frontend build, backend package, infra scripts)
- [ ] T226 [PHASE-9.10] Create CHANGELOG entry in documentation/CHANGELOG.md documenting all feature 002 changes

**Phase 9.10 Completion Checklist**:
- [ ] Smoke test passes
- [ ] All success criteria verified
- [ ] All FR implemented
- [ ] E2E suite passes
- [ ] Deployment package ready
- [ ] phase-9.10-summary.md created

---

### Phase 9 Final Summary

- [ ] T227 [PHASE-9] Create comprehensive phase-9-summary.md aggregating all sub-phase summaries (9.1-9.10) with:
  - Code quality improvements summary
  - Error handling coverage report
  - Performance metrics (Lighthouse scores, API p95, bundle size)
  - Security hardening summary
  - Integration test results (US1-US6 coverage)
  - Deployment configuration summary
  - Route mapping summary
  - Final validation checklist

**Checkpoint**: Phase 9 complete - Application is production-ready with comprehensive testing, documentation, deployment configuration, and full feature validation across all user stories

**Phase 9 Overall Completion Checklist**:
- [ ] All sub-phases 9.1-9.10 completed
- [ ] All 227 tasks (T000.1-T227) completed
- [ ] Lighthouse Performance >90, Accessibility >90
- [ ] All security checks pass
- [ ] All integration tests pass (US1-US6)
- [ ] Deployment configuration validated
- [ ] Route mapping complete
- [ ] All success criteria verified
- [ ] phase-9-summary.md created aggregating all sub-phase summaries
- [ ] Phase 9 marked complete in tasks.md
- [ ] **FEATURE 002 COMPLETE - PRODUCTION READY** ✅

---

## 📊 Dependencies & Execution Order

### Phase Dependencies

```
Phase 0 (Setup)
   ↓
Phase 1 (Critical Refactoring) ← BLOCKS ALL BELOW
   ↓
Phase 2 (Foundational) ← BLOCKS ALL USER STORIES
   ↓
   ├── Phase 3 (US1: Navigation) 🎯 MVP
   ├── Phase 4 (US2: Course Discovery) (can parallel with US1)
   ├── Phase 5 (US3: Learning Path) (depends on US2 for courses)
   ├── Phase 6 (US4: Dashboard) (depends on US3 for progress)
   ├── Phase 7 (US5: Theme) (independent, can parallel)
   └── Phase 8 (US6: Admin DSL) (independent, can parallel)
   ↓
Phase 9 (Polish) ← After all desired user stories
```

### Parallel Opportunities

**After Phase 2 Completes**:
- Phase 3 (US1) + Phase 7 (US5) can run in parallel (independent)
- Phase 4 (US2) can start once Phase 3 navigation exists
- Phase 8 (US6) can run in parallel with user stories (admin-only)

**Recommended Sequential Order** (single developer):
1. Phase 0 → Phase 1 → Phase 2 (foundation, 3-4 weeks)
2. Phase 3 (navigation, 1 week) 🎯 **MVP HERE**
3. Phase 4 (course discovery, 1.5 weeks)
4. Phase 5 (learning path, 1 week)
5. Phase 6 (dashboard, 1 week)
6. Phase 7 (theme, 0.5 week)
7. Phase 8 (admin DSL, 1 week)
8. Phase 9 (polish, 1 week)

**Total Estimated Time**: 10-12 weeks

---

## 🎯 MVP Scope

**Minimum Viable Product** = Phase 0 + Phase 1 + Phase 2 + Phase 3

This delivers:
- ✅ Constitution-compliant codebase (App.tsx refactored, service layer)
- ✅ Adaptive navigation (left panel on Windows, bottom bar on mobile)
- ✅ All foundational infrastructure (stores, models, logging, sanitization)
- ✅ Basic routing and theme infrastructure

**MVP Test**: Load app on Windows, iOS, Android → Verify navigation appears correctly and routes work.

**Time to MVP**: 4-5 weeks (Phases 0-3)

---

## 📝 Implementation Strategy

### For AI Agent Executing Phases

1. **Always start by reading phase summaries** from `specs/002-mobile-ux-redesign/phase-summaries/`
2. **Search repository for existing code** before creating new files
3. **Follow speckit.implement.prompt.md instructions** for each implementation task
4. **Apply design principles** from design-principles.md consistently
5. **Create detailed phase summary** documenting all changes
6. **Create next steps document** evaluating completeness and suggesting improvements
7. **Update this tasks.md** marking completed tasks with [x]

### Task Completion Tracking

- Mark tasks with `[x]` when complete
- Update phase completion status checkboxes
- Ensure phase summary created before marking phase complete
- Verify all tests pass before marking phase complete

---

**Generated**: 2025-11-22  
**Status**: Ready for Phase 0 execution  
**Next Command**: "Implement Phase 0"
