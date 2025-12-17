# Phase 5 Pre-Implementation Analysis
# Learning Path Visualization - Existing Code Review

**Date**: 2025-11-23
**Phase**: 5 - User Story 3 (Learning Path Visualization)
**Analysis Type**: Mandatory Pre-Implementation

---

## Overview

This document contains findings from analyzing existing code before implementing Phase 5 tasks. The goal is to understand what exists and what needs to be built/extended.

---

## Existing Backend Infrastructure

### Service Layer (Phase 1 Created)

**File**: `backend/app/services/learning_path_service.py`
- ✅ Service skeleton exists
- ✅ Method stubs defined with TODO comments
- 📝 **Needs Implementation**:
  - `generate_path_nodes()` - Creates visualization nodes
  - `get_path_with_nodes()` - Fetches learning path with visualization
  - `get_next_lesson()` - Finds next lesson in sequence
  - `calculate_path_progress()` - Calculates completion percentage

**File**: `backend/app/services/progress_service.py`
- ✅ Service skeleton exists  
- ✅ Method stubs defined with TODO comments
- 📝 **Needs Implementation**:
  - `get_user_progress()` - Retrieves user progress for course
  - `update_lesson_progress()` - Marks lesson as completed
  - `get_completion_state()` - Returns state: completed/current/locked/available

### Routes

**File**: `backend/app/routes/learning_paths.py`
- ✅ Exists - handles learning path listing
- ✅ Endpoints present:
  - `GET /learning-paths` - List published paths (with filtering)
  - `GET /learning-paths/subjects` - Get all unique subjects
- ❌ **Missing Endpoints** (Phase 5 needs):
  - `GET /api/v1/learning-paths/{course_id}` - Get path with nodes
  - Path visualization endpoint not implemented

**File**: `backend/app/routes/progress.py`
- ✅ Exists - handles progress tracking
- ✅ Endpoints present:
  - `POST /progress/record` - Record progress
- ❌ **Missing Endpoints** (Phase 5 needs):
  - `GET /api/v1/progress/{course_id}` - Get user progress
  - `POST /api/v1/progress/{course_id}/lessons/{lesson_id}` - Update lesson progress

### Models

**File**: `backend/app/models/learning_path.py`
- ✅ Comprehensive LearningPath model exists
- ✅ Contains:
  - `Module`, `Lesson`, `ContentItem` classes
  - DSL parser (fully functional)
  - Content types: video, summary, quiz, exercise, lesson
- ❌ **Missing**:
  - `path_nodes` field (for visualization coordinates)
  - PathNode schema definition

**File**: `backend/app/models/progress.py`
- ✅ Progress models exist:
  - `UserProgress` - Detailed progress tracking
  - `LearningPathProgress` - Overall path progress
  - `ModuleProgress` - Module-level progress
  - `ContentProgress` - Content item progress
- ✅ Contains `lesson_progress` concept via nested models
- ✅ All necessary fields present

---

## Existing Frontend Infrastructure

### Components

**Existing Components** (need to check if Phase 5 extends or creates new):
- `LearningPathViewer.tsx` - Exists (18KB)
- `LearningPathViewer_new.tsx` - Exists (16KB) 
- `ProgressTracker.tsx` - Exists (16KB)
- `LearningPathCard.tsx` - Exists (4.7KB)

**Component Directories**:
- `frontend/src/components/navigation/` - Phase 3 navigation
- `frontend/src/components/courses/` - Phase 4 course discovery
- `frontend/src/components/dashboard/` - Exists (Phase 6 target)
- `frontend/src/components/lesson/` - Exists (Phase 1 extracted)
- ❌ `frontend/src/components/learning-path/` - **Does NOT exist yet**

### Hooks

Need to check:
- `frontend/src/hooks/` for existing progress/learning path hooks

### Stores (Zustand)

From Phase 2:
- `NavigationStore` - Tracks user journey
- `ThemeStore` - Theme preferences
- ❌ Learning path specific store - likely needs creation

---

## API Contract Requirements

**From**: `specs/002-mobile-ux-redesign/contracts/learning-paths-api.yaml`

### Required Endpoints

1. **GET /learning-paths/{course_id}**
   - Returns: LearningPath with `path_nodes`
   - Path nodes include:
     - `module_id`, `lesson_id`
     - `x_position`, `y_position` (0-1 normalized)
     - `dependencies` (array of lesson IDs)
   - Status: ❌ Not implemented

2. **GET /progress/{course_id}**
   - Returns: UserProgress with:
     - `completion_percentage`
     - `lesson_progress` (map of lesson states)
     - `recent_lessons`
   - Status: ❌ Not implemented

3. **POST /progress/{course_id}/lessons/{lesson_id}**
   - Updates lesson completion
   - Returns: Updated progress
   - Status: ❌ Exists as `/progress/record` (needs endpoint adjustment)

---

## Data Model Requirements

**From**: `specs/002-mobile-ux-redesign/data-model.md` (Section 2.3)

### PathNode Schema (NEW - needs creation)

```python
class PathNode(BaseModel):
    module_id: str
    lesson_id: str
    x_position: float  # 0.0 to 1.0
    y_position: float  # 0.0 to 1.0
    dependencies: List[str]  # Lesson IDs that must be completed first
    node_type: Literal["lesson", "quiz", "exercise", "video", "summary", "certificate"]
```

### LearningPath Extension

**Current**: Has modules, lessons, contents
**Needs**: `path_nodes: List[PathNode]` field

### UserProgress Extension

**Current**: Has basic progress tracking
**Needs**: 
- `lesson_progress` (Dict mapping lesson_id to LessonProgress)
- Recent lessons tracking

---

## Phase 4 Integration Points

Phase 4 (Course Discovery) completed:
- ✅ Course search and filtering functional
- ✅ CourseCatalogPage exists
- ✅ Users can browse and view courses
- ⚠️ Route integration to navigation pending (T071)

**Integration for Phase 5**:
- Course detail page should link to learning path visualization
- User enrolls in course → Navigate to `/courses/{slug}/path`

---

## Phase 3 Integration Points

Phase 3 (Adaptive Navigation) completed:
- ✅ DesktopNav component exists
- ✅ MobileNav component exists
- ✅ Navigation adapts to platform

**Integration for Phase 5**:
- Learning path page must work with adaptive navigation
- Path visualization should adapt to mobile (vertical scroll) vs desktop (side panel)

---

## Implementation Strategy

### T077-T080: Backend Learning Path Data

**Approach**: Extend existing models and services

1. **T077**: Add PathNode model to `backend/app/models/learning_path.py`
   - New `PathNode` BaseModel
   - Add `path_nodes: List[PathNode] = []` to `LearningPath`

2. **T078**: Implement `LearningPathService.generate_path_nodes()`
   - Algorithm: Convert linear module/lesson structure to 2D coordinates
   - Layout: Vertical progression with branching
   - Dependencies: Sequential (each lesson depends on previous)

3. **T079**: Add endpoint to `backend/app/routes/learning_paths.py`
   - New route: `GET /api/v1/learning-paths/{course_id}`
   - Calls `LearningPathService.get_path_with_nodes()`

4. **T080**: Migration script
   - Generate path_nodes for all existing learning paths
   - Update Cosmos DB documents

### T081-T085: Backend Progress Tracking

**Approach**: Extend existing progress models and routes

1. **T081**: UserProgress model already has lesson_progress via nested models
   - ✅ No changes needed (verify structure)

2. **T082**: Implement `ProgressService.get_user_progress()`
   - Query user's progress for course
   - Return lesson states

3. **T083**: Add endpoint to `backend/app/routes/progress.py`
   - New route: `GET /api/v1/progress/{course_id}`

4. **T084-T085**: Implement progress update
   - `ProgressService.update_lesson_progress()`
   - `POST /api/v1/progress/{course_id}/lessons/{lesson_id}`

### T086-T093: Frontend Path Visualization

**Approach**: Create new components in `frontend/src/components/learning-path/`

1. **T086**: PathVisualization component
   - SVG-based rendering
   - Takes path_nodes and renders visual path
   - Responsive to viewport size

2. **T087**: LessonNode component
   - Visual representation of single lesson
   - States: completed (✓), current (highlighted), locked (🔒), available
   - Uses Motion for animations

3. **T088**: PathConnector component
   - SVG lines connecting nodes
   - Animated on reveal

4. **T089**: Layout algorithm
   - Convert path_nodes (0-1 coords) to actual SVG coordinates
   - Handle viewport resizing

5. **T090-T092**: State-based styling
   - Completed: Checkmark, colored
   - Current: Highlighted, progress ring
   - Locked: Grayed out, lock icon

6. **T093**: Motion animations
   - Stagger node reveal on page load
   - Fade-in connectors
   - 60fps target

### T094-T096: Frontend Learning Path Page

**Approach**: Create new page component

1. **T094**: LearningPathPage
   - Route: `/courses/:courseId/path`
   - Fetches learning path with nodes
   - Fetches user progress
   - Renders PathVisualization with progress overlay

2. **T095**: Add route to `frontend/src/routes/index.tsx`

3. **T096**: Manual testing

---

## Dependencies & Blockers

### Prerequisites (ALL MET ✅)
- [x] Phase 1: Service layer skeletons exist
- [x] Phase 2: State management (Zustand, TanStack Query)
- [x] Phase 3: Navigation infrastructure
- [x] Phase 4: Course discovery (users can find courses)

### External Dependencies
- ✅ Cosmos DB (existing connection)
- ✅ Motion library (Phase 2 installed)
- ✅ TanStack Query (Phase 2 configured)
- ✅ Zustand (Phase 2 configured)

### No Blockers Identified ✅

---

## Questions & Decisions

### Q1: Path Node Generation Algorithm
**Decision**: Use vertical linear layout with slight horizontal offset for variety
- Y-position: Evenly spaced based on lesson order (0.1, 0.2, 0.3...)
- X-position: Slight sine wave (0.4-0.6 range) for visual interest
- Dependencies: Each lesson depends on previous (sequential learning)

### Q2: Mobile vs Desktop Layout
**Decision**: Same SVG-based visualization, different viewport handling
- Mobile: Vertical scroll, full width
- Desktop: Side panel or center area, fixed aspect ratio

### Q3: Existing LearningPathViewer Components
**Decision**: Phase 5 creates NEW components in `learning-path/` directory
- Existing components may be for different purpose
- Phase 5 focuses on visual path map (not list view)
- Review existing components to avoid duplication

---

## File Changes Summary

### New Files (to be created):
1. `backend/app/models/path_node.py` - PathNode model (or extend learning_path.py)
2. `frontend/src/components/learning-path/PathVisualization.tsx`
3. `frontend/src/components/learning-path/LessonNode.tsx`
4. `frontend/src/components/learning-path/PathConnector.tsx`
5. `frontend/src/pages/LearningPathPage.tsx`
6. `backend/scripts/generate_path_visualizations.py` - Migration script

### Modified Files:
1. `backend/app/models/learning_path.py` - Add path_nodes field
2. `backend/app/services/learning_path_service.py` - Implement methods
3. `backend/app/services/progress_service.py` - Implement methods
4. `backend/app/routes/learning_paths.py` - Add new endpoint
5. `backend/app/routes/progress.py` - Add new endpoints
6. `frontend/src/routes/index.tsx` - Add learning path route

### Test Files (to be created):
1. `frontend/src/components/learning-path/__tests__/PathVisualization.test.tsx`
2. `frontend/src/components/learning-path/__tests__/LessonNode.test.tsx`
3. `backend/tests/test_learning_path_service.py` (extend)
4. `frontend/tests/e2e/learning-path-visual.spec.ts`

---

## Success Criteria (from spec.md)

**FR-026**: Visual learning path displayed ✅
**FR-027**: Path nodes with correct positions ✅
**FR-028**: Module types differentiated (lesson, quiz, video, etc.) ✅
**FR-029**: SVG-based rendering ✅
**FR-030**: Completed lessons show checkmarks ✅
**FR-031**: Current lesson highlighted ✅
**FR-032**: Locked lessons grayed out ✅
**FR-033**: Progress updates in real-time ✅
**FR-034**: Animations smooth (60fps) ✅

---

## Next Steps

1. ✅ Analysis complete
2. ⏭️ Begin T077: Extend LearningPath model with path_nodes
3. ⏭️ Implement backend services (T078-T085)
4. ⏭️ Create frontend components (T086-T093)
5. ⏭️ Build learning path page (T094-T096)
6. ⏭️ Write tests (T097-T100)
7. ⏭️ Create phase-5-summary.md
8. ⏭️ Create phase-5-next-steps.md

---

**Analysis Completed**: 2025-11-23
**Ready to Proceed**: ✅ YES
**Estimated Implementation Time**: 3-5 days (20 tasks)
