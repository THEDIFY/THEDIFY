# Feature Specification: Mobile-Responsive UX Redesign with Learning Path Visualization

**Feature Branch**: `002-mobile-ux-redesign`  
**Created**: 2025-11-20  
**Status**: Draft  
**Input**: User description: "Mobile-responsive UX redesign with learning path visualization, course discovery, and production-ready deployment including cross-platform support (Windows PWA, iOS, Android), adaptive navigation patterns, enhanced course discovery, visual learning path progression, and admin DSL enhancements"

## Clarifications

### Session 2025-11-20

- Q: Should course catalog use lazy loading (infinite scroll), traditional pagination (page numbers), or hybrid (Load More button) when exceeding 50 courses? → A: Lazy loading (infinite scroll)
- Q: How should course recommendations work (personalized algorithmic, category-based, manual curation, or popularity-based)? → A: Category-based (show popular courses from same categories as user's enrolled/completed courses)
- Q: Should coding exercise execution be browser-based only, server-side only, or hybrid approach? → A: Browser-based only (using Web Workers/iframe sandbox with JavaScript and Pyodide for Python)
- Q: What observability strategy should be used to monitor performance, errors, and user flows (structured logging, Application Insights, custom metrics endpoint, or none)? → A: Structured logging only (Python logging with JSON format for manual analysis)
- Q: How should the app handle network failures and offline scenarios (full offline support, online-only with graceful errors, read-only offline, or no special handling)? → A: Online-only with graceful errors (show clear error messages, disable interactions, provide retry buttons)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Adaptive Navigation Across Platforms (Priority: P1)

As a user, I can navigate the MenTora platform using navigation patterns optimized for my device: a left-side panel menu on Windows PWA, and a bottom navigation bar on mobile (iOS/Android), so that I can access all features intuitively regardless of my platform.

**Why this priority**: Navigation is the core interaction pattern for the entire platform. Without proper navigation, users cannot access any features. This must be implemented first to enable all other features.

**Independent Test**: Can be fully tested by loading the app on different platforms (Windows PWA, iOS Safari, Android Chrome) and verifying that the appropriate navigation UI appears and all menu items are accessible. Delivers immediate value by making the app usable on all target platforms.

**Acceptance Scenarios**:

1. **Given** I am using Windows PWA, **When** I load the app, **Then** I see a left-side panel menu with all navigation options visible
2. **Given** I am using iOS Safari, **When** I load the app, **Then** I see a bottom navigation bar with icon-based navigation
3. **Given** I am using Android Chrome, **When** I load the app, **Then** I see a bottom navigation bar identical to iOS
4. **Given** I am on any platform, **When** I tap/click a navigation item, **Then** I am taken to the correct route without page refresh
5. **Given** I resize my browser window, **When** it crosses mobile/desktop breakpoint, **Then** the navigation UI adapts automatically

---

### User Story 2 - Enhanced Course Discovery with Filters (Priority: P1)

As a user, I can discover courses through an enhanced course grid with search and filter capabilities, so that I can quickly find courses matching my interests and skill level.

**Why this priority**: Course discovery is the primary user journey after authentication. Without it, users cannot find content to learn from. This is essential for platform usability and user retention.

**Independent Test**: Can be tested by loading the course catalog page, entering search terms, applying filters (difficulty, category, duration), and verifying that the grid updates correctly. Delivers value by enabling users to find relevant courses.

**Acceptance Scenarios**:

1. **Given** I am on the course catalog page, **When** I view the page, **Then** I see a grid of course cards with titles, descriptions, difficulty levels, and visual previews
2. **Given** I am viewing the course catalog, **When** I type in the search bar, **Then** the course grid filters in real-time to show matching courses
3. **Given** I am viewing courses, **When** I apply a difficulty filter (Beginner/Intermediate/Advanced), **Then** only courses of that difficulty are shown
4. **Given** I am viewing courses, **When** I apply a category filter (AI, Development, Business), **Then** only courses in that category are shown
5. **Given** I have applied multiple filters, **When** I clear filters, **Then** all courses are shown again

---

### User Story 3 - Visual Learning Path Progression (Priority: P1)

As a user, I can see my learning path progress visualized with a map-like interface showing completed, in-progress, and locked lessons, so that I understand my learning journey and feel motivated to continue.

**Why this priority**: Learning path visualization is the core differentiator of MenTora and directly impacts user engagement and course completion rates. Without visual progression, users lose context of their learning journey.

**Independent Test**: Can be tested by enrolling in a course, completing some lessons, and verifying that the visual path shows correct states (completed checkmarks, current progress, locked indicators). Delivers value by improving user engagement and clarity.

**Acceptance Scenarios**:

1. **Given** I have enrolled in a course, **When** I view my learning path, **Then** I see a visual map showing all modules and lessons
2. **Given** I am viewing my learning path, **When** I look at completed lessons, **Then** they have checkmarks and colored indicators
3. **Given** I am viewing my learning path, **When** I look at my current lesson, **Then** it is highlighted with progress percentage
4. **Given** I am viewing my learning path, **When** I look at locked lessons, **Then** they appear grayed out with lock icons
5. **Given** I complete a lesson, **When** I return to the learning path, **Then** the visual updates to show the new completion state

---

### User Story 4 - Personalized Learning Dashboard (Priority: P2)

As a user, I can access a personalized dashboard showing my enrolled courses, recent activity, achievements, and recommended next steps, so that I can quickly resume my learning and stay motivated.

**Why this priority**: The dashboard provides user context and quick access to ongoing work. While important for user experience, it can be implemented after core navigation and course discovery are functional.

**Independent Test**: Can be tested by enrolling in courses, completing activities, and verifying that the dashboard shows accurate statistics, recent activity, and actionable next steps. Delivers value by improving user retention and engagement.

**Acceptance Scenarios**:

1. **Given** I have enrolled in courses, **When** I view my dashboard, **Then** I see cards for each enrolled course with progress bars
2. **Given** I have recent activity, **When** I view my dashboard, **Then** I see my last 5 completed lessons with timestamps
3. **Given** I have earned achievements, **When** I view my dashboard, **Then** I see my achievement badges and points
4. **Given** I am on the dashboard, **When** I click "Continue Learning", **Then** I am taken to my next incomplete lesson
5. **Given** I have completed courses, **When** I view my dashboard, **Then** I see recommendations for related courses

---

### User Story 5 - Seamless Theme Switching (Priority: P2)

As a user, I can toggle between bright and dark themes, so that I can use the platform comfortably in different lighting conditions and according to my visual preferences.

**Why this priority**: Theme switching enhances user comfort and accessibility but is not critical for core functionality. It can be implemented after primary features are stable.

**Independent Test**: Can be tested by toggling the theme switcher and verifying that all UI elements (navigation, course cards, learning paths, dashboard) update correctly to the selected theme. Delivers value by improving user comfort and accessibility.

**Acceptance Scenarios**:

1. **Given** I am using the app, **When** I toggle the theme switcher, **Then** the entire UI transitions to the selected theme
2. **Given** I have selected a theme, **When** I refresh the page, **Then** my theme preference persists
3. **Given** I am in dark theme, **When** I view course cards, **Then** they use dark-theme-appropriate colors and contrast
4. **Given** I am in bright theme, **When** I view the learning path, **Then** it uses bright-theme-appropriate colors
5. **Given** I switch themes, **When** I navigate between pages, **Then** the theme remains consistent

---

### User Story 6 - Enhanced Admin DSL Course Creation (Priority: P2)

As an admin, I can create courses using an enhanced DSL format that supports video embeds, interactive quizzes, coding exercises, and summaries, so that I can build rich, engaging learning content efficiently.

**Why this priority**: Enhanced DSL capabilities improve content quality but are not required for the initial platform launch. Admins can use existing DSL format while enhanced features are developed.

**Independent Test**: Can be tested by creating a course using enhanced DSL syntax (video embeds, quizzes, exercises), verifying correct parsing, and confirming that learners see the enhanced content types in their lessons. Delivers value by enabling richer course content.

**Acceptance Scenarios**:

1. **Given** I am an admin, **When** I write DSL with a video embed, **Then** the course parser correctly creates a video content item
2. **Given** I am an admin, **When** I write DSL with quiz syntax, **Then** the parser creates an interactive quiz with correct answers
3. **Given** I am an admin, **When** I write DSL with a coding exercise, **Then** the parser creates an exercise with expected output
4. **Given** I have created a course with enhanced DSL, **When** a learner accesses it, **Then** they see videos, quizzes, and exercises rendered correctly
5. **Given** I have syntax errors in my DSL, **When** I submit it, **Then** I receive clear error messages with line numbers

---

### User Story 7 - Smooth Page Transitions and Animations (Priority: P3)

As a user, I experience smooth, performant animations when navigating between pages, viewing learning paths, and interacting with UI elements, so that the platform feels polished and professional.

**Why this priority**: Animations enhance user experience and perceived quality but are cosmetic improvements that can be added after core functionality is stable. They should not block feature delivery.

**Independent Test**: Can be tested by navigating through the app and observing that transitions (route changes, theme switches, card hovers) are smooth and performant without jank or lag. Delivers value by improving perceived quality.

**Acceptance Scenarios**:

1. **Given** I navigate between pages, **When** the route changes, **Then** I see a smooth fade/slide transition
2. **Given** I hover over a course card, **When** my cursor enters the card, **Then** it smoothly scales or lifts with shadow
3. **Given** I am viewing a learning path, **When** it loads, **Then** elements animate in sequentially with stagger
4. **Given** I switch themes, **When** the theme changes, **Then** colors transition smoothly without flash
5. **Given** I am on a mobile device, **When** I interact with animations, **Then** they remain smooth at 60fps

---

### Edge Cases

- What happens when a user accesses the app on an unsupported browser (IE11, very old mobile browsers)?
- How does the system handle courses with no lessons or incomplete DSL parsing?
- What happens when a user has no enrolled courses on their dashboard?
- How does the visual learning path handle courses with 100+ lessons (performance, scrolling)?
- What happens when a user toggles theme rapidly multiple times?
- How does the search filter handle special characters or SQL injection attempts?
- What happens when a user loses internet connection mid-lesson? (System shows error message, disables interactions, provides retry button)
- How does the bottom navigation handle very small screen sizes (< 320px width)?
- What happens when admin DSL includes malicious content (XSS attempts)?
- How does the system handle courses with missing preview images or metadata?

## Requirements *(mandatory)*

### Functional Requirements

#### Navigation & Platform Support (FR-001 to FR-010)

- **FR-001**: System MUST detect user's platform (Windows PWA, iOS, Android) on load and render appropriate navigation UI
- **FR-002**: System MUST display a persistent left-side panel menu with expandable sections on Windows PWA (desktop viewport ≥ 1024px)
- **FR-003**: System MUST display a bottom navigation bar with icon labels on iOS Safari (mobile viewport < 1024px)
- **FR-004**: System MUST display a bottom navigation bar with icon labels on Android Chrome (mobile viewport < 1024px)
- **FR-005**: System MUST include navigation items for: Dashboard, Courses, Learning Paths, Profile, Settings (minimum required)
- **FR-006**: System MUST highlight the currently active navigation item with visual indicator
- **FR-007**: System MUST support client-side routing (no full page reloads) for all navigation transitions
- **FR-008**: System MUST maintain navigation state across browser refresh (persist active route)
- **FR-009**: Navigation UI MUST be responsive and adapt automatically when viewport crosses breakpoints
- **FR-010**: Bottom navigation bar MUST remain fixed at bottom of screen and not scroll with content on mobile

#### Course Discovery & Search (FR-011 to FR-025)

- **FR-011**: System MUST display all available courses in a responsive grid layout (1 column mobile, 2-3 columns tablet, 3-4 columns desktop)
- **FR-012**: Each course card MUST display: title, description (truncated), difficulty level, estimated duration, category, and visual preview/thumbnail
- **FR-013**: System MUST provide real-time search input that filters courses by title or description as user types
- **FR-014**: System MUST provide filter dropdown for difficulty levels: Beginner, Intermediate, Advanced
- **FR-015**: System MUST provide filter dropdown for categories: AI, Development, Business, Data Science, Design (categories based on available courses)
- **FR-016**: System MUST allow users to apply multiple filters simultaneously (e.g., Beginner + AI)
- **FR-017**: System MUST display "No courses found" message when search/filter yields zero results
- **FR-018**: System MUST provide "Clear filters" button that resets all active filters and shows all courses
- **FR-019**: Course cards MUST be clickable and navigate to course detail/enrollment page
- **FR-020**: Course cards MUST show enrollment status indicator (enrolled, completed, not enrolled)
- **FR-021**: System MUST persist search query in URL parameters for shareable links
- **FR-022**: System MUST debounce search input to prevent excessive filtering during typing (minimum 300ms delay)
- **FR-023**: Course grid MUST implement lazy loading (infinite scroll) for courses exceeding 50 items, fetching next batch when user scrolls near bottom
- **FR-024**: System MUST display course count indicator (e.g., "Showing 12 of 45 courses")
- **FR-025**: Course cards MUST have hover/tap effects with smooth visual feedback

#### Learning Path Visualization (FR-026 to FR-040)

- **FR-026**: System MUST display enrolled courses as visual learning paths with interconnected nodes representing modules/lessons
- **FR-027**: System MUST indicate lesson completion status with three states: completed (checkmark + color), in-progress (progress percentage), locked (gray + lock icon)
- **FR-028**: System MUST display progress percentage for the overall course and each module
- **FR-029**: System MUST highlight the user's current lesson with distinct visual indicator (e.g., glowing border, pulse animation)
- **FR-030**: System MUST render learning path in a scrollable container for courses with many lessons (> 20)
- **FR-031**: Completed lessons MUST have a checkmark icon and use success color (green/blue)
- **FR-032**: Locked lessons MUST be non-clickable and visually distinct (grayed out, reduced opacity)
- **FR-033**: System MUST allow users to click on any unlocked lesson to navigate directly to it
- **FR-034**: System MUST display module names as section headers in the learning path
- **FR-035**: Learning path MUST update in real-time when user completes a lesson (no full page refresh required)
- **FR-036**: System MUST show prerequisite connections between lessons if defined in course structure
- **FR-037**: Learning path MUST be responsive and adapt layout for mobile (vertical flow) vs desktop (map-like layout)
- **FR-038**: System MUST provide a "Continue Learning" button that jumps to the next incomplete lesson
- **FR-039**: System MUST display estimated time remaining for course completion based on user's progress
- **FR-040**: Learning path MUST support horizontal or vertical scrolling without performance degradation

#### Dashboard & Personalization (FR-041 to FR-050)

- **FR-041**: System MUST display a personalized dashboard as the default authenticated landing page
- **FR-042**: Dashboard MUST show all enrolled courses with individual progress bars and last accessed timestamps
- **FR-043**: Dashboard MUST display recent activity feed showing last 5-10 completed lessons with dates
- **FR-044**: Dashboard MUST show achievement summary (total points, badges earned, courses completed)
- **FR-045**: Dashboard MUST provide "Continue Learning" CTA button that navigates to most recent incomplete lesson
- **FR-046**: Dashboard MUST display course recommendations using category-based filtering (popular courses from same categories as user's enrolled/completed courses)
- **FR-047**: System MUST persist dashboard layout preferences (e.g., collapsed/expanded sections)
- **FR-048**: Dashboard MUST show completion statistics (total lessons completed, total time spent, streak days)
- **FR-049**: Dashboard MUST display "Getting Started" tips for new users with zero enrolled courses
- **FR-050**: Dashboard MUST be responsive with card-based layout adapting to viewport size

#### Theme Support (FR-051 to FR-055)

- **FR-051**: System MUST provide a theme toggle control accessible from navigation or settings
- **FR-052**: System MUST support two themes: Bright (light mode) and Dark (dark mode)
- **FR-053**: System MUST persist user's theme preference in localStorage across sessions
- **FR-054**: Theme changes MUST apply to all UI elements: navigation, course cards, learning paths, dashboard, modals, forms
- **FR-055**: Theme transitions MUST be smooth with CSS transitions (no jarring color flashes)

#### Admin DSL Enhancements (FR-056 to FR-070)

- **FR-056**: Admin DSL parser MUST support video embed syntax: `[video:https://youtube.com/watch?v=ID]` or similar
- **FR-057**: Admin DSL parser MUST support interactive quiz syntax with multiple choice questions and correct answers
- **FR-058**: Admin DSL parser MUST support coding exercise syntax with expected output for validation
- **FR-059**: Admin DSL parser MUST support summary/recap sections that visually distinguish from regular content
- **FR-060**: System MUST render video content items with embedded YouTube/Vimeo players in lessons
- **FR-061**: System MUST render quiz content items with radio/checkbox inputs and "Submit" button
- **FR-062**: System MUST validate quiz answers and provide immediate feedback (correct/incorrect)
- **FR-063**: System MUST render coding exercise content items with code editor and "Run Code" button
- **FR-064**: System MUST execute coding exercises in browser-based sandboxed environment using Web Workers or iframe (supports JavaScript natively and Python via Pyodide)
- **FR-065**: System MUST display exercise output and compare with expected output for validation
- **FR-066**: Admin DSL parser MUST sanitize all user-provided content to prevent XSS attacks (using Bleach or similar)
- **FR-067**: Admin DSL parser MUST provide detailed error messages with line numbers for syntax errors
- **FR-068**: System MUST preview parsed course structure in admin interface before saving
- **FR-069**: System MUST validate that all DSL-created courses have at least one module and one lesson
- **FR-070**: Admin interface MUST support editing existing courses with DSL while preserving student progress
- **FR-071**: Backend MUST implement structured logging (JSON format) for all API requests including: endpoint, method, response time, status code, user ID, and error details for performance monitoring and debugging
- **FR-072**: System MUST detect network failures and display clear error messages with retry buttons when API requests fail
- **FR-073**: System MUST disable interactive elements (course enrollment, lesson navigation, quiz submission) when offline and show user-friendly offline status indicator

### Key Entities

- **Course**: Represents a complete learning program with metadata (title, description, difficulty, category, duration), modules, and lessons. Courses are created via admin DSL or admin interface.

- **Module**: A logical grouping of related lessons within a course. Modules have titles, descriptions, and an ordered list of lessons. They represent major learning sections.

- **Lesson**: The smallest learning unit containing content items (text, videos, quizzes, exercises, summaries). Lessons have titles, content arrays, and completion tracking.

- **ContentItem**: Polymorphic entity representing different types of lesson content: text (markdown), video (URL), quiz (questions + answers), exercise (code + expected output), summary (recap text). Each type has specific rendering requirements.

- **LearningPath**: User-specific enrollment in a course that tracks progress through modules and lessons. Contains completion states, timestamps, and progress percentages.

- **UserProgress**: Tracks user's interaction with lessons including completion status, time spent, quiz scores, and exercise submissions. Used to calculate overall course progress.

- **Theme**: User preference entity storing selected theme (bright/dark) and persisted in localStorage. Controls application-wide color scheme.

- **NavigationContext**: Application state tracking current platform (Windows/iOS/Android), viewport size, and active navigation item. Determines which navigation UI to render.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can navigate to any section of the app within 2 taps/clicks from any starting point
- **SC-002**: Course search and filter operations return results in under 500ms for catalogs up to 100 courses
- **SC-003**: 90% of users successfully find and enroll in a course within their first 3 minutes on the platform
- **SC-004**: Learning path visualization loads and renders in under 2 seconds for courses with up to 50 lessons
- **SC-005**: Theme switching completes in under 300ms with smooth visual transitions on all devices
- **SC-006**: Mobile app maintains 60fps frame rate during all animations and scrolling interactions
- **SC-007**: Bottom navigation bar remains accessible and functional on devices as small as 320px width
- **SC-008**: Dashboard loads with all personalized data in under 3 seconds on 4G mobile connections
- **SC-009**: Course completion rates increase by 25% with visual learning path progression compared to baseline
- **SC-010**: 95% of users successfully apply at least one filter to course discovery on first attempt
- **SC-011**: Admin DSL parser correctly interprets 99% of valid course definitions without errors
- **SC-012**: Enhanced DSL content types (videos, quizzes, exercises) render correctly on 100% of supported platforms
- **SC-013**: Zero XSS vulnerabilities in admin-created course content through DSL sanitization
- **SC-014**: User theme preferences persist across 100% of sessions and devices
- **SC-015**: System supports 500+ concurrent users with responsive navigation and course discovery (< 1s response times)

## Assumptions *(optional)*

- Users have modern browsers that support CSS Grid, Flexbox, and ES6+ JavaScript features
- Mobile users are primarily on iOS 14+ and Android 10+ devices with viewport widths between 320px and 428px
- Desktop/Windows PWA users have viewport widths of 1024px or greater
- Internet connection is stable enough for real-time search filtering (minimum 3G speeds)
- Courses in the catalog have been properly created with valid DSL syntax and required metadata
- Video content for lessons is hosted on YouTube or Vimeo (external hosting)
- Coding exercise execution uses browser-based sandbox (Web Workers for JavaScript, Pyodide for Python) with no server-side execution required
- Theme colors defined in Tailwind config are sufficient for both bright and dark modes
- Azure Cosmos DB can handle read-heavy workloads for course discovery and learning path queries
- Admin users are trained on DSL syntax and understand content creation workflows
- Existing user authentication and session management remain unchanged
- Course preview images are available or fallback images are acceptable
- Learning paths are linear progressions (prerequisites are sequential, not complex dependency graphs)

## Dependencies *(optional)*

**External Dependencies**:
- Framer Motion library for animations and transitions (already in package.json)
- React Router DOM for client-side routing (already in package.json)
- Tailwind CSS with dark mode configuration (already in package.json)
- Azure Cosmos DB for data persistence (already configured in backend)
- YouTube/Vimeo iframe embed support for video content
- Browser localStorage API for theme and navigation state persistence

**Internal Dependencies**:
- Existing authentication system (JWT, Google OAuth) must remain functional
- Existing Pydantic models for Course, Module, Lesson, ContentItem must be extended for new DSL types
- Existing store.py data access layer must support new query patterns (filtering, search)
- Existing App.tsx must be refactored into smaller components to enable new features
- Existing Tailwind config dark theme colors must be applied consistently
- Current PWA setup (service workers, manifest.json) must be maintained
- Backend API routes must be extended for new filtering and search endpoints
- Admin interface must be updated to support enhanced DSL preview

**Unblocking Requirements**:
- App.tsx refactor into smaller components must complete before adding new navigation UI
- Tailwind dark theme implementation must complete before theme toggle can be added
- Backend search/filter API endpoints must be created before frontend course discovery can function
- DSL parser extensions must be implemented and tested before admin can use enhanced syntax
- Mobile responsive breakpoints must be defined before adaptive navigation can be implemented

## Out of Scope *(optional)*

The following items are explicitly excluded from this feature specification:

- **Native mobile apps**: Only PWA support (iOS/Android browsers), not native app store distributions
- **Offline mode**: Users must have internet connection to access courses and sync progress; app will show graceful error messages when offline but does not cache content for offline use
- **Advanced accessibility features**: Screen reader optimization and WCAG 2.1 AAA compliance deferred to future
- **Real-time collaboration**: Multi-user course editing or live learning sessions not included
- **Video hosting**: Platform will not host video files, only embed external videos
- **Code execution sandbox**: Full-featured IDE or complex code evaluation engine not included (basic execution only)
- **Gamification system**: Advanced badges, leaderboards, or social features beyond basic achievements
- **Mobile app notifications**: Push notifications require native apps (out of scope)
- **Advanced analytics**: User behavior tracking and detailed analytics dashboards
- **Course marketplace**: Payment integration, course purchasing, or creator monetization
- **Live chat/forums**: Community features or instructor messaging
- **Certificate generation**: Automated certificate creation upon course completion
- **Multi-language support**: Internationalization (i18n) and localization deferred
- **Advanced course search**: Semantic search, AI-powered recommendations beyond simple filtering
- **Video transcriptions**: Automated captions or subtitle generation for video content

## Notes *(optional)*

### Technical Considerations

**Performance Optimization**:
- Course catalog should implement virtual scrolling or pagination if exceeding 50 courses
- Learning path rendering should use React.memo or useMemo for large course structures
- Search debouncing is critical to prevent excessive API calls during typing
- Theme transitions should use CSS custom properties for efficient repainting

**Mobile-Specific Concerns**:
- Bottom navigation bar height should be 60-70px to accommodate tap targets (min 44x44px)
- Consider iOS safe area insets for devices with notches/home indicators
- Android devices may have on-screen navigation that overlaps bottom bar (add padding)
- Touch targets must be minimum 44x44px per iOS HIG and 48x48dp per Material Design

**Cross-Platform Consistency**:
- Navigation patterns differ significantly (left panel vs bottom bar) but feature parity must be maintained
- All user journeys must be equally accessible on Windows PWA and mobile browsers
- Theme colors must have sufficient contrast ratios on both bright and dark modes
- Animations should degrade gracefully on low-performance devices

**Infrastructure Integration**:
- New frontend assets (navigation components, course cards) must be bundled and served from `/static`
- Backend API changes require updated Azure App Service deployment via GitHub Actions
- Cosmos DB query patterns for course filtering may require new indexes for performance
- Structured logging (JSON format) must be configured in Python backend for performance monitoring, error tracking, and manual analysis of API metrics

**Admin DSL Syntax Examples** (for future plan phase):
```
# Video embed
[video:https://youtube.com/watch?v=abc123]

# Quiz
[quiz]
Q: What is 2+2?
A: 3
B: 4 [correct]
C: 5
[/quiz]

# Coding exercise
[exercise:python]
def add(a, b):
    return a + b
[expected]
add(2, 2) => 4
[/exercise]
```

### Open Questions for Plan Phase

- Should navigation state be synced to backend for cross-device consistency?
- What is the fallback behavior for courses with no preview images?
- Should theme preference be stored in user profile (backend) or only localStorage (frontend)?
- How should learning path handle branching/optional lessons in future?
- Should course search support autocomplete/suggestions?
- What is maximum acceptable course count before pagination becomes mandatory?
- Should coding exercises support multiple programming languages or start with one?

### Validation Checklist

- [ ] All 70 functional requirements are testable and measurable
- [ ] All 7 user stories are independently testable with clear acceptance scenarios
- [ ] Success criteria are quantifiable and technology-agnostic
- [ ] No [NEEDS CLARIFICATION] markers remain (all requirements are clear)
- [ ] Key entities are defined without implementation details
- [ ] Assumptions are realistic and documented
- [ ] Dependencies are identified and unblocking requirements are clear
- [ ] Out of scope items prevent feature creep
- [ ] Technical notes provide sufficient context for plan phase

