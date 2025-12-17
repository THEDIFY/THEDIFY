# Frontend Current Structure

**Last Updated**: 2025-11-22
**Created for**: Phase 0 - Mobile UX Redesign Feature 002

## Overview
The frontend is built with React 18.2.0, TypeScript 5.2.2, and Vite 5.0.8. It currently uses a monolithic App.tsx file (1098 lines) that needs refactoring as part of Phase 1.

## Directory Structure

```
frontend/
├── src/
│   ├── components/          # All UI components
│   ├── test/               # Test files and setup
│   ├── App.tsx             # Main application (1098 lines - NEEDS REFACTORING)
│   ├── App_simple.tsx      # Simplified version
│   └── main.tsx            # Application entry point
├── public/                 # Static assets
├── package.json            # Dependencies
├── vite.config.ts         # Vite configuration
├── tailwind.config.js     # Tailwind CSS configuration
└── tsconfig.json          # TypeScript configuration
```

## Components (Located in src/components/)

### Authentication & User Management
- **AuthPage.tsx** - Main authentication page with Google OAuth
- **AdminAuthPage.tsx** - Admin-specific authentication
- **SignInButtonGoogle.tsx** - Google sign-in button component
- **SignInButtonGoogle_backup.tsx** - Backup version
- **SignInButtonGoogle_new.tsx** - New version

### User Flow & Onboarding
- **OnboardingWizard.tsx** - User onboarding wizard (quiz, profile creation)
- **SimulationPage.tsx** - Profile simulation page
- **PaymentComponent.tsx** - Stripe payment integration
- **ProfileEditor.tsx** - User profile editing

### Dashboard & Progress
- **UserDashboard.tsx** - Main user dashboard (recent courses, stats)
- **AdminDashboard.tsx** - Admin dashboard
- **ProgressTracker.tsx** - Learning progress tracking
- **BadgeSystem.tsx** - Achievement badges and gamification

### Course & Learning Paths
- **CourseSelector.tsx** - Course selection interface
- **LearningPathCard.tsx** - Course card component
- **LearningPathsList.tsx** - List of learning paths
- **LearningPathViewer.tsx** - Main learning path viewer with modules
- **LearningPathViewer_new.tsx** - New version of path viewer
- **ContentRenderer.tsx** - Renders lesson content (text, video, quiz)
- **QuizComponent.tsx** - Interactive quiz component

### Admin Tools
- **AdminEditor.tsx** - DSL editor for course creation
- **SeedDataManager.tsx** - Seed data management

### PWA & Install
- **PWAInstallPrompt.tsx** - PWA installation prompt

## Main Application (App.tsx)

**Current State**: Monolithic 1098-line file managing entire application flow

### State Management (useState hooks)
- `currentStep: AppStep` - Current navigation step
- `userData: UserData | null` - Authenticated user data
- `userProfile: OnboardingData | null` - User onboarding data
- `selectedCourse: Course | null` - Selected course
- `isLoading: boolean` - Loading state
- `error: string | null` - Error messages
- `currentPathSlug: string | null` - Current learning path
- `startModule: number` - Starting module index
- `userEnrollments: any[]` - User's course enrollments
- `userPoints: number` - Gamification points
- `userLevel: number` - User level
- `completedContents: string[]` - Completed content IDs

### App Steps (Navigation Flow)
```
auth → admin-auth → welcome → onboarding → course-selection → 
simulation → payment → dashboard → user-dashboard → admin → 
admin-editor → learning-path-viewer → learning-paths-list
```

### Key Features in App.tsx
1. **Session Persistence**: Uses localStorage for user data, profile, course, and step
2. **Authentication Handling**: Google OAuth integration
3. **User Journey Flow**: Menu → Sign In → Welcome → Quiz → Profile → Payment → Main App
4. **Route Management**: Manual step-based routing (no React Router in current App.tsx)
5. **Admin Mode**: Separate admin authentication and dashboard
6. **Payment Flow**: Stripe integration
7. **Learning Path Viewing**: Module progression and content rendering

### Components Rendered by App.tsx
- PWAInstallPrompt (always visible)
- AuthPage (step: 'auth')
- AdminAuthPage (step: 'admin-auth')
- OnboardingWizard (step: 'onboarding')
- CourseSelector (step: 'course-selection')
- SimulationPage (step: 'simulation')
- PaymentComponent (step: 'payment')
- AdminDashboard (step: 'admin')
- AdminEditor (step: 'admin-editor')
- LearningPathViewer (step: 'learning-path-viewer')
- LearningPathsList (step: 'learning-paths-list')
- UserDashboard (step: 'user-dashboard')

## Hooks (None Currently - Needs Creation in Phase 2)

Currently, no custom hooks exist. Planned hooks:
- `usePlatformDetection` - Detect iOS/Android/Windows PWA
- `useCourseSearch` - TanStack Query for course search
- Additional hooks to be defined in Phase 2

## Stores (None Currently - Needs Creation in Phase 2)

Currently, state is managed via useState in App.tsx. Planned Zustand stores:
- `NavigationStore` - User journey flow state
- `ThemeStore` - Bright/dark theme preferences
- Additional stores to be defined in Phase 2

## Pages (None - All in App.tsx)

Currently, all "pages" are conditional renders in App.tsx based on `currentStep`. 
Planned structure for Phase 1+ refactoring:
- pages/AuthPage.tsx
- pages/OnboardingPage.tsx
- pages/CourseCatalogPage.tsx
- pages/DashboardPage.tsx
- pages/LearningPathPage.tsx
- pages/AdminPage.tsx

## Routes (None - Manual Step Management)

Currently uses manual step-based navigation (`currentStep` state).
React Router not implemented in main App.tsx.

React Router v6.20.1 is installed but not actively used for main navigation flow.

Planned routes structure for Phase 1+:
```
/ → Dashboard (after auth)
/auth → Authentication
/welcome → Welcome screen
/onboarding → Onboarding wizard
/courses → Course catalog
/courses/:id → Course detail
/courses/:id/path → Learning path viewer
/payment → Payment page
/admin → Admin dashboard
/admin/editor → DSL editor
```

## Styling

### Tailwind CSS
- Configured in `tailwind.config.js`
- Dark mode: NOT YET CONFIGURED (needs 'class' mode in Phase 2)
- Custom colors: Need to verify Mentora brand colors

### Framer Motion
- Version: 10.18.0 (needs upgrade to 11.x for Motion in Phase 1)
- Currently used for page transitions in App.tsx
- Used in various components for animations

### App.css
- Global styles
- Animation definitions
- Custom component styles

## Dependencies (package.json)

### Core Dependencies
- **react**: ^18.2.0 (NEEDS UPGRADE to 19.x in Phase 1)
- **react-dom**: ^18.2.0 (NEEDS UPGRADE to 19.x in Phase 1)
- **react-router-dom**: ^6.20.1 ✅ (Compatible with React 19)
- **typescript**: ^5.2.2 ✅

### UI & Styling
- **tailwindcss**: ^3.4.17 ✅
- **framer-motion**: ^10.18.0 (NEEDS UPGRADE to 11.x - Motion)
- **lucide-react**: ^0.295.0 ✅
- **clsx**: ^2.0.0 ✅

### Data & API
- **axios**: ^1.6.2 ✅
- **@stripe/react-stripe-js**: ^2.4.0 ✅
- **@stripe/stripe-js**: ^2.4.0 ✅

### Content Rendering
- **react-markdown**: ^10.1.0 ✅
- **react-syntax-highlighter**: ^15.6.6 ✅
- **remark-gfm**: ^4.0.1 ✅

### Dev Dependencies
- **vite**: ^5.0.8 ✅
- **@vitejs/plugin-react**: ^4.2.1 ✅
- **vite-plugin-pwa**: ^0.17.4 ✅
- **vitest**: ^1.0.4 ✅
- **@testing-library/react**: ^13.4.0 (needs update for React 19)
- **@testing-library/jest-dom**: ^6.1.5 ✅
- **eslint**: ^8.55.0 ✅
- **@typescript-eslint/eslint-plugin**: ^6.14.0 ✅

### Missing Dependencies (To Add in Phase 1+)
- **@tanstack/react-query**: ^5.x (infinite scroll, data fetching)
- **zustand**: ^4.x (state management)
- **pyodide**: ^0.24.x (browser code execution)
- **lottie-react**: ^2.x (animations)
- **structlog** equivalent for frontend (if needed)

## Testing

### Test Setup
- **Framework**: Vitest ^1.0.4
- **Testing Library**: @testing-library/react ^13.4.0
- **Setup File**: src/test/setup.ts

### Existing Tests
- **src/test/AdminEditor.test.tsx** - Admin editor component tests

### Test Commands
```bash
npm test              # Run tests once
npm run test:watch    # Watch mode
npm run test:coverage # Coverage report
```

## Build & Development

### Scripts
```bash
npm run dev           # Start dev server (Vite)
npm run build         # TypeScript compile + Vite build
npm run preview       # Preview production build
npm run lint          # ESLint check
npm run type-check    # TypeScript check (no emit)
```

## Integration Points

### Backend API
- Base URL: Configured via environment variables
- Authentication: Google OAuth JWT tokens
- Endpoints used:
  - `/api/auth/*` - Authentication
  - `/api/learning-paths/*` - Learning paths
  - `/api/progress/*` - Progress tracking
  - `/api/admin/*` - Admin operations
  - `/api/seed-data/*` - Seed data management
  - `/api/onboarding/*` - Onboarding flow
  - `/api/payment/*` - Stripe payments

### LocalStorage Keys
- `MenTora_user_data` - User session data
- `MenTora_user_profile` - Onboarding profile
- `MenTora_selected_course` - Selected course
- `MenTora_current_step` - Current navigation step
- `MenTora_enrollments` - User enrollments
- `MenTora_points` - Gamification points
- `MenTora_level` - User level
- `MenTora_completed_contents` - Completed content IDs

### Azure Integration
- **Stripe**: Payment processing
- **Google OAuth**: Authentication
- **Azure Cosmos DB**: Backend storage (via API)

## Phase 1 Refactoring Targets

### App.tsx Decomposition (Target: <300 lines)
1. **Extract DesktopNav** → frontend/src/components/navigation/DesktopNav.tsx
2. **Extract MobileNav** → frontend/src/components/navigation/MobileNav.tsx
3. **Extract CourseGrid** → frontend/src/components/courses/CourseGrid.tsx
4. **Extract Dashboard** → frontend/src/components/dashboard/Dashboard.tsx
5. **Extract LessonViewer** → frontend/src/components/lesson/LessonViewer.tsx
   - Note: LearningPathViewer.tsx already exists - needs integration analysis

### Create Missing Structures
- **hooks/** directory with custom hooks
- **stores/** directory with Zustand stores
- **pages/** directory with page components
- **services/** directory for API calls
- **lib/** directory for utilities (queryClient, etc.)

### Dependency Updates
- Upgrade React 18.2.0 → 19.x
- Upgrade framer-motion 10.18.0 → 11.x (Motion)
- Add @tanstack/react-query ^5.x
- Add zustand ^4.x
- Add pyodide ^0.24.x
- Update @testing-library/react for React 19 compatibility

## Notes for Phase 1+ Implementation

### Must Preserve
- ✅ User journey flow (Menu→SignIn→Welcome→Quiz→Profile→Payment→MainApp)
- ✅ Mentora brand identity (logo, colors, mission statement)
- ✅ Minimalistic dark design with cool animations
- ✅ Google OAuth authentication
- ✅ Stripe payment integration
- ✅ PWA installation prompt
- ✅ Admin mode functionality
- ✅ Learning path module progression
- ✅ Gamification (points, levels, badges)

### Must Integrate With
- ✅ Existing backend API endpoints
- ✅ Azure Cosmos DB (via backend)
- ✅ LocalStorage persistence
- ✅ Existing component library

### Must Add (Phase 1+)
- ⬜ React Router for route management
- ⬜ Zustand stores for state management
- ⬜ TanStack Query for data fetching
- ⬜ Platform detection (iOS/Android/Windows PWA)
- ⬜ Responsive navigation (left panel desktop, bottom bar mobile)
- ⬜ Bright/dark theme support
- ⬜ Course search and filtering
- ⬜ Learning path visualization
- ⬜ Infinite scroll for courses
- ⬜ Enhanced DSL parsing (video, quiz, exercise)

## Conclusion

The frontend is functional but needs significant refactoring to meet mobile UX redesign requirements:
- App.tsx is too large (1098 lines → target <300 lines)
- No custom hooks or state management solution
- No React Router implementation in main flow
- React 18.2.0 needs upgrade to 19.x
- Missing many required dependencies for feature 002

Phase 1 refactoring will address these issues while preserving all existing functionality and user journey flow.
