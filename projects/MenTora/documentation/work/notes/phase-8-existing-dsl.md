# Phase 8 Existing DSL Analysis

**Date**: 2025-11-26  
**Phase**: 8 - User Story 6 (Enhanced Admin DSL)  
**Status**: Analysis Complete

---

## Overview

Phase 8 focuses on enhancing the admin DSL capabilities to support rich course content (video, quiz, exercise) and implementing proper XSS sanitization.

---

## Existing Implementations

### 1. DSLService (backend/app/services/dsl_service.py) - SKELETON ONLY
- Location: `backend/app/services/dsl_service.py`
- Status: SKELETON - Contains placeholder methods only
- Methods to implement:
  - `parse_dsl()` - Currently returns empty dict
  - `validate_dsl()` - Currently returns always valid
  - `sanitize_content()` - Currently returns content unchanged
  - `sanitize_video_url()` - Currently returns url unchanged
  - `generate_preview()` - Currently returns empty dict
  - `parse_video_block()` - Currently returns empty dict
  - `parse_quiz_block()` - Currently returns empty dict
  - `parse_exercise_block()` - Currently returns empty dict

### 2. DSLParser in LearningPath Model (backend/app/models/learning_path.py) - FULLY IMPLEMENTED
- Location: `backend/app/models/learning_path.py`
- Status: ✅ COMPLETE - Full DSL parsing already exists
- Features:
  - VIDEO syntax parsing: `- video: URL | title=Title | points=10 | minutes=15`
  - QUIZ syntax parsing: `- quiz:` followed by `? kind question text`
  - EXERCISE syntax parsing: `- exercise: description | points=20 | minutes=30`
  - SUMMARY syntax parsing: `- summary: text`
  - LESSON syntax parsing: `- lesson: markdown content`
  - Module access tier support
  - Final exam support
  - Bleach sanitization for HTML

### 3. Sanitization Utilities (backend/app/utils/sanitization.py) - IMPLEMENTED
- Location: `backend/app/utils/sanitization.py`
- Status: ✅ COMPLETE
- Features:
  - `sanitize_html()` - XSS prevention with Bleach
  - `sanitize_video_url()` - YouTube/Vimeo whitelist validation
  - `sanitize_markdown()` - Markdown to safe HTML
  - `sanitize_dsl_content()` - DSL-specific sanitization
  - `sanitize_text()` - Plain text sanitization
  - `linkify_text()` - Safe URL linking

### 4. Admin Learning Paths Routes (backend/app/routes/admin_learning_paths.py) - IMPLEMENTED
- Location: `backend/app/routes/admin_learning_paths.py`
- Status: ✅ COMPLETE
- Endpoints:
  - `GET /admin/learning-paths` - List all paths
  - `POST /admin/learning-paths` - Create from DSL or JSON
  - `PUT /admin/learning-paths/{id}` - Update path
  - `POST /admin/learning-paths/{id}/publish` - Toggle publish
  - `POST /admin/learning-paths/parse` - Preview DSL parsing
  - `GET /admin/learning-paths/{id}/export` - Export as DSL
  - `PATCH /admin/learning-paths/{id}/subjects` - Update subjects
  - `DELETE /admin/learning-paths/{id}` - Delete path

### 5. LessonViewer Component (frontend/src/components/lesson/LessonViewer.tsx) - BASIC IMPLEMENTATION
- Location: `frontend/src/components/lesson/LessonViewer.tsx`
- Status: PARTIAL - Basic rendering only
- Features implemented:
  - Module navigation sidebar
  - Content type icons
  - Basic lesson/video/exercise/quiz/summary rendering
  - Content navigation (next/prev)
- Needs enhancement for:
  - VideoContent component (YouTube/Vimeo embed)
  - QuizContent component (interactive quiz)
  - ExerciseContent component (code execution with Pyodide)

### 6. AdminEditor Component (frontend/src/components/AdminEditor.tsx) - COMPLETE
- Location: `frontend/src/components/AdminEditor.tsx`
- Status: ✅ COMPLETE
- Features:
  - DSL editor with textarea
  - JSON preview mode
  - Live preview (structure/student view)
  - Parse preview API integration
  - Save draft functionality
  - Publish/unpublish toggle
  - Validation error display

---

## Gap Analysis

### Backend Gaps
1. **DSLService needs to wrap existing DSLParser** - T134-T138
   - The DSLParser in learning_path.py is complete
   - DSLService just needs to delegate to it
   - Add enhanced validation with line numbers

2. **Sanitization integration in DSLService** - T139-T142
   - Sanitization utils exist but not integrated in DSLService
   - Need to add sanitize endpoints

3. **Preview generation** - T143-T144
   - Need to generate HTML preview of parsed DSL

### Frontend Gaps
1. **VideoContent component** - T149
   - Need YouTube/Vimeo iframe embed
   - Responsive video player

2. **QuizContent component** - T150
   - Interactive quiz with radio/checkbox
   - Submit and validation
   - Score display

3. **ExerciseContent component** - T151-T152
   - Code editor
   - Pyodide for Python execution
   - Web Worker for isolation

4. **LessonViewer integration** - T153
   - Integrate new content components

### Infrastructure Gaps
1. **start-enhanced.ps1** - T157-T163
   - Database initialization
   - Health checks
   - Browser auto-launch

---

## Implementation Strategy

### Phase 8 Task Priority
1. **Complete DSLService wrapper** (T134-T138) - Use existing DSLParser
2. **Enhance sanitization endpoints** (T139-T142) - Use existing utils
3. **Add preview endpoint** (T143-T144)
4. **Create VideoContent component** (T149)
5. **Create QuizContent component** (T150)
6. **Create ExerciseContent component** (T151-T152)
7. **Integrate in LessonViewer** (T153)
8. **Create start-enhanced.ps1** (T157-T163)

### Integration Requirements
- All new endpoints in existing admin.py router
- Extend existing LessonViewer, don't recreate
- Use existing Bleach sanitization
- Maintain dark mode compatibility

---

## File Mapping

### Files to Modify
- `backend/app/services/dsl_service.py` - Implement wrapper methods
- `backend/app/routes/admin_learning_paths.py` - Add sanitize/preview endpoints
- `frontend/src/components/lesson/LessonViewer.tsx` - Integrate new components

### Files to Create
- `frontend/src/components/lesson/VideoContent.tsx`
- `frontend/src/components/lesson/QuizContent.tsx`
- `frontend/src/components/lesson/ExerciseContent.tsx`
- `frontend/src/workers/codeExecutor.worker.ts`
- `start-enhanced.ps1`

---

## Conclusion

Phase 8 has significant existing infrastructure to build upon:
- ✅ DSL parsing is complete in learning_path.py
- ✅ Sanitization utils are complete
- ✅ Admin routes exist for DSL CRUD
- ⚠️ DSLService needs wrapper implementation
- ⚠️ Frontend content components need creation
- ⚠️ Pyodide integration needed for exercises

**Estimated Effort**: 
- Backend: 2-3 hours (mostly wiring existing code)
- Frontend: 4-6 hours (new components + Pyodide)
- Testing: 2-3 hours
