# Data Model Design: Mobile-Responsive UX Redesign

**Feature**: 002-mobile-ux-redesign  
**Date**: 2025-11-22  
**Status**: Complete

## Overview

This document defines the data models, schemas, and relationships for the mobile UX redesign. All models use Pydantic for validation and follow the existing MenTora schema patterns.

---

## 1. New Entities

### 1.1 CourseFilter

**Purpose**: Encapsulates user-selected filters for course search/discovery

**Schema**:
```python
from pydantic import BaseModel, Field
from typing import Optional, List
from enum import Enum

class DifficultyLevel(str, Enum):
    BEGINNER = "Beginner"
    INTERMEDIATE = "Intermediate"
    ADVANCED = "Advanced"

class CourseFilter(BaseModel):
    """Filters for course catalog search."""
    
    category: Optional[str] = Field(
        None,
        description="Course category (e.g., 'AI', 'Web Development')",
        max_length=100
    )
    
    difficulty: Optional[DifficultyLevel] = Field(
        None,
        description="Course difficulty level"
    )
    
    search_query: Optional[str] = Field(
        None,
        description="Text search in title and description",
        max_length=200,
        min_length=2
    )
    
    tag: Optional[str] = Field(
        None,
        description="Single tag filter",
        max_length=50
    )
    
    class Config:
        json_schema_extra = {
            "example": {
                "category": "AI",
                "difficulty": "Beginner",
                "search_query": "machine learning",
                "tag": "python"
            }
        }
```

**Validation Rules**:
- All fields optional (supports filtering by any combination)
- `search_query` minimum 2 characters to prevent excessive results
- Enum enforces valid difficulty levels

**Frontend State**:
```typescript
interface CourseFilter {
  category?: string;
  difficulty?: 'Beginner' | 'Intermediate' | 'Advanced';
  searchQuery?: string;
  tag?: string;
}
```

---

### 1.2 CourseSearchResult

**Purpose**: Paginated response with continuation cursor for infinite scroll

**Schema**:
```python
from pydantic import BaseModel, Field
from typing import List, Optional

class CourseSearchResult(BaseModel):
    """Paginated course search results."""
    
    courses: List[Course] = Field(
        default_factory=list,
        description="List of courses matching filters"
    )
    
    next_cursor: Optional[str] = Field(
        None,
        description="Continuation token for next page (Cosmos DB)"
    )
    
    total_count: Optional[int] = Field(
        None,
        description="Total matching courses (expensive, only returned on first page)",
        ge=0
    )
    
    has_more: bool = Field(
        default=False,
        description="Whether more results exist"
    )
    
    class Config:
        json_schema_extra = {
            "example": {
                "courses": [],  # List of Course objects
                "next_cursor": "g1AAAAG3eJzLYWBg4M...",
                "total_count": 150,
                "has_more": True
            }
        }
```

**Implementation Notes**:
- `next_cursor` is base64-encoded Cosmos DB continuation token
- `total_count` only computed on first page to reduce RU cost
- `has_more` derived from presence of `next_cursor`

**Frontend Consumption**:
```typescript
interface CourseSearchResult {
  courses: Course[];
  nextCursor: string | null;
  totalCount?: number;
  hasMore: boolean;
}
```

---

### 1.3 EnhancedContentItem

**Purpose**: Extends existing ContentItem with new multimedia types

**Schema**:
```python
from pydantic import BaseModel, Field, HttpUrl
from typing import Optional, Literal

class VideoContent(BaseModel):
    """Video lesson content."""
    type: Literal["video"] = "video"
    url: HttpUrl = Field(..., description="Video URL (YouTube, Vimeo)")
    thumbnail: Optional[HttpUrl] = Field(None, description="Thumbnail image URL")
    duration_seconds: Optional[int] = Field(None, ge=1, description="Video duration")

class QuizContent(BaseModel):
    """Quiz lesson content."""
    type: Literal["quiz"] = "quiz"
    questions: List['QuizQuestion'] = Field(..., min_items=1)
    passing_score: int = Field(70, ge=0, le=100, description="Percentage required to pass")

class ExerciseContent(BaseModel):
    """Coding exercise lesson content."""
    type: Literal["exercise"] = "exercise"
    language: Literal["python", "javascript"] = Field(..., description="Programming language")
    starter_code: str = Field(..., description="Initial code template")
    expected_output: str = Field(..., description="Expected program output")
    instructions: str = Field(..., max_length=2000, description="Exercise instructions")
    hints: List[str] = Field(default_factory=list, description="Progressive hints")

class TextContent(BaseModel):
    """Text/markdown lesson content."""
    type: Literal["text"] = "text"
    markdown: str = Field(..., max_length=10000, description="Sanitized markdown")

# Union type for content polymorphism
EnhancedContentItem = VideoContent | QuizContent | ExerciseContent | TextContent
```

**Validation Rules**:
- Video URLs validated as proper HTTP/HTTPS (Pydantic HttpUrl)
- Quiz requires at least 1 question
- Exercise language limited to Python/JavaScript (browser execution)
- Text content limited to 10KB (reasonable for mobile)

---

### 1.4 QuizQuestion

**Purpose**: Individual quiz question with multiple-choice answers

**Schema**:
```python
from pydantic import BaseModel, Field
from typing import List

class QuizQuestion(BaseModel):
    """Single quiz question."""
    
    id: str = Field(..., description="Unique question ID")
    question: str = Field(..., max_length=500, description="Question text")
    options: List[str] = Field(..., min_items=2, max_items=6, description="Answer choices")
    correct_index: int = Field(..., ge=0, description="Index of correct answer")
    explanation: Optional[str] = Field(None, max_length=1000, description="Answer explanation")
    
    class Config:
        json_schema_extra = {
            "example": {
                "id": "q1",
                "question": "What is the capital of France?",
                "options": ["London", "Paris", "Berlin", "Madrid"],
                "correct_index": 1,
                "explanation": "Paris has been the capital of France since 987 AD."
            }
        }
    
    def check_answer(self, user_answer_index: int) -> bool:
        """Validate user answer."""
        return user_answer_index == self.correct_index
```

**Validation Rules**:
- 2-6 answer options (UI constraint)
- `correct_index` must be valid index in `options` array
- Question limited to 500 characters for mobile readability

---

### 1.5 NavigationState

**Purpose**: Zustand store state for navigation context

**Schema** (TypeScript):
```typescript
interface NavigationState {
  // Platform detection
  platform: 'windows' | 'ios' | 'android';
  viewportWidth: number;
  
  // Navigation UI
  activeRoute: string;
  showBottomNav: boolean;  // Computed: mobile + (iOS || Android)
  showLeftPanel: boolean;  // Computed: desktop || Windows
  
  // Actions
  setPlatform: (platform: NavigationState['platform']) => void;
  setViewportWidth: (width: number) => void;
  setActiveRoute: (route: string) => void;
}
```

**Computed Properties**:
```typescript
const isMobile = viewportWidth < 1024;
const showBottomNav = isMobile && (platform === 'ios' || platform === 'android');
const showLeftPanel = !isMobile || platform === 'windows';
```

---

### 1.6 ThemePreference

**Purpose**: User theme selection with persistence

**Schema**:
```python
from pydantic import BaseModel, Field
from enum import Enum

class ThemeName(str, Enum):
    BRIGHT = "bright"
    DARK = "dark"

class ThemePreference(BaseModel):
    """User theme preference."""
    
    user_id: Optional[str] = Field(None, description="User ID (null for anonymous)")
    theme: ThemeName = Field(default=ThemeName.BRIGHT, description="Selected theme")
    
    class Config:
        json_schema_extra = {
            "example": {
                "user_id": "user_12345",
                "theme": "dark"
            }
        }
```

**Storage**:
- Anonymous users: localStorage only
- Authenticated users: localStorage + backend User model

**Frontend**:
```typescript
interface ThemeState {
  theme: 'bright' | 'dark';
  toggleTheme: () => void;
}
```

---

## 2. Extended Entities

### 2.1 Course (Extended)

**New Fields**:
```python
from pydantic import BaseModel, Field
from typing import Optional

class Course(BaseModel):
    # ... existing fields ...
    
    # New fields for FR-011-025
    enrollment_count: int = Field(
        default=0,
        ge=0,
        description="Total user enrollments (for popularity sorting)"
    )
    
    thumbnail_url: Optional[HttpUrl] = Field(
        None,
        description="Course thumbnail for grid display"
    )
    
    estimated_hours: Optional[float] = Field(
        None,
        ge=0.5,
        le=500,
        description="Estimated completion time in hours"
    )
    
    tags: List[str] = Field(
        default_factory=list,
        description="Search tags (e.g., ['python', 'ml', 'beginner'])"
    )
```

**Cosmos DB Index Updates**:
```json
{
  "compositeIndexes": [
    [
      { "path": "/category", "order": "ascending" },
      { "path": "/difficulty", "order": "ascending" },
      { "path": "/enrollmentCount", "order": "descending" }
    ]
  ]
}
```

---

### 2.2 UserProgress (Extended)

**New Fields**:
```python
class LessonProgress(BaseModel):
    """Progress for individual lesson."""
    lesson_id: str
    completed: bool = False
    completed_at: Optional[datetime] = None
    quiz_score: Optional[int] = Field(None, ge=0, le=100)
    exercise_submitted: bool = False
    time_spent_seconds: int = Field(default=0, ge=0)

class UserProgress(BaseModel):
    # ... existing fields ...
    
    # New fields for FR-041-050 (Dashboard)
    recent_lessons: List[str] = Field(
        default_factory=list,
        max_items=10,
        description="IDs of recently viewed lessons (FIFO queue)"
    )
    
    lesson_progress: Dict[str, LessonProgress] = Field(
        default_factory=dict,
        description="Detailed progress per lesson"
    )
    
    last_active: datetime = Field(
        default_factory=datetime.utcnow,
        description="Last activity timestamp for 'Continue Learning'"
    )
```

**Update Triggers**:
- `recent_lessons`: Updated on lesson view (keep last 10)
- `lesson_progress`: Updated on quiz submission, exercise submission, lesson completion
- `last_active`: Updated on any lesson interaction

---

### 2.3 LearningPath (Extended)

**New Fields**:
```python
class PathNode(BaseModel):
    """Node in learning path visualization."""
    module_id: str
    lesson_id: str
    x_position: float = Field(..., ge=0, le=1, description="Normalized X coordinate (0-1)")
    y_position: float = Field(..., ge=0, le=1, description="Normalized Y coordinate (0-1)")
    dependencies: List[str] = Field(default_factory=list, description="IDs of prerequisite lessons")

class LearningPath(BaseModel):
    # ... existing fields ...
    
    # New fields for FR-026-040 (Visualization)
    path_nodes: List[PathNode] = Field(
        default_factory=list,
        description="Coordinates for path visualization"
    )
    
    total_lessons: int = Field(
        default=0,
        ge=0,
        description="Total lessons in path (for progress calculation)"
    )
    
    estimated_weeks: Optional[int] = Field(
        None,
        ge=1,
        le=52,
        description="Estimated completion time in weeks"
    )
```

**Visualization Algorithm**:
```python
def generate_path_positions(modules: List[Module]) -> List[PathNode]:
    """Generate SVG coordinates for path visualization."""
    nodes = []
    y = 0.1  # Start 10% from top
    
    for module in modules:
        x = 0.5  # Center horizontally
        for lesson in module.lessons:
            nodes.append(PathNode(
                module_id=module.id,
                lesson_id=lesson.id,
                x_position=x,
                y_position=y,
                dependencies=lesson.prerequisites
            ))
            y += 0.1  # Vertical spacing
    
    return nodes
```

---

## 3. Relationships

### 3.1 Entity Relationship Diagram

```
┌─────────────────┐       ┌─────────────────┐
│     Course      │1     *│  LearningPath   │
│─────────────────│◄──────│─────────────────│
│ id              │       │ id              │
│ category        │       │ course_id       │
│ difficulty      │       │ path_nodes      │
│ enrollment_count│       │ total_lessons   │
│ tags            │       └─────────────────┘
└─────────────────┘                │
        │                           │
        │1                         1│
        │                           │
        │*                         *│
┌─────────────────┐       ┌─────────────────┐
│  UserProgress   │       │  LessonProgress │
│─────────────────│       │─────────────────│
│ user_id         │       │ lesson_id       │
│ course_id       │       │ completed       │
│ recent_lessons  │       │ quiz_score      │
│ lesson_progress │───────►│ exercise_sub... │
└─────────────────┘       └─────────────────┘
```

### 3.2 Data Flow

**Course Discovery**:
1. User applies filters → `CourseFilter`
2. Backend queries Cosmos DB with composite index
3. Returns `CourseSearchResult` with `next_cursor`
4. Frontend caches results in TanStack Query
5. Scroll triggers `fetchNextPage()` with cursor

**Lesson Progress Tracking**:
1. User completes quiz → Frontend submits answers
2. Backend validates answers → Updates `LessonProgress`
3. Backend recalculates `UserProgress.lesson_progress`
4. Frontend refetches progress → Updates dashboard

**Learning Path Visualization**:
1. Backend generates `path_nodes` on course creation
2. Frontend fetches `LearningPath` with nodes
3. SVG renders path with Motion animations
4. User progress overlays completed lessons

---

## 4. State Transitions

### 4.1 Lesson Completion Flow

```
START
  │
  ├──► [Viewing]
  │      │
  │      ├──► [Quiz Started] ───► [Quiz Completed] ───► [Lesson Completed]
  │      │                             │ (score >= 70%)
  │      │                             └──► [Quiz Failed] ───► [Retry]
  │      │
  │      └──► [Exercise Started] ───► [Exercise Submitted] ───► [Lesson Completed]
  │                                        │ (correct output)
  │                                        └──► [Exercise Failed] ───► [Retry]
  │
  └──► [Lesson Completed] ───► [Next Lesson]
```

**State Tracking**:
```python
class LessonState(str, Enum):
    NOT_STARTED = "not_started"
    IN_PROGRESS = "in_progress"
    QUIZ_FAILED = "quiz_failed"
    EXERCISE_FAILED = "exercise_failed"
    COMPLETED = "completed"
```

### 4.2 Theme Toggle Flow

```
[Bright Mode]
      │
      ├──► User clicks toggle
      │
      ├──► Zustand updates state
      │
      ├──► useEffect triggers
      │         │
      │         ├──► Add 'dark' class to <html>
      │         └──► Save to localStorage
      │
      └──► [Dark Mode]
            │
            └──► (Same flow in reverse)
```

---

## 5. Validation Rules

### 5.1 Input Validation

| Field | Constraint | Error Message |
|-------|-----------|---------------|
| `CourseFilter.search_query` | Min 2 chars | "Search query must be at least 2 characters" |
| `QuizQuestion.options` | 2-6 items | "Quiz must have between 2 and 6 answer options" |
| `ExerciseContent.starter_code` | Max 5KB | "Starter code exceeds 5KB limit" |
| `EnhancedContentItem.markdown` | Max 10KB | "Lesson content exceeds 10KB limit" |
| `ThemePreference.theme` | Enum only | "Invalid theme. Must be 'bright' or 'dark'" |

### 5.2 Business Logic Validation

**Quiz Submission**:
```python
def validate_quiz_submission(questions: List[QuizQuestion], answers: List[int]) -> tuple[bool, int]:
    """Validate quiz submission and calculate score."""
    if len(answers) != len(questions):
        raise ValueError("Answer count must match question count")
    
    correct = sum(1 for q, a in zip(questions, answers) if q.check_answer(a))
    score = int((correct / len(questions)) * 100)
    passed = score >= 70
    
    return passed, score
```

**Exercise Submission**:
```python
def validate_exercise_submission(expected: str, actual: str) -> bool:
    """Validate coding exercise output."""
    # Normalize whitespace
    expected_normalized = ' '.join(expected.split())
    actual_normalized = ' '.join(actual.split())
    
    return expected_normalized == actual_normalized
```

---

## 6. Performance Considerations

### 6.1 Database Indexes

**Required Indexes**:
1. **Composite**: `(category, difficulty, enrollmentCount)` - Course search
2. **Single**: `user_id` on UserProgress - Dashboard queries
3. **Single**: `course_id` on LearningPath - Path lookup
4. **Text**: `title` on Course - Full-text search (Cosmos DB Contains())

**RU Cost Estimates**:
- Course search (indexed): 15-25 RU per page
- UserProgress fetch: 3-5 RU
- LearningPath fetch: 3-5 RU
- Quiz submission: 10-15 RU (update + read)

### 6.2 Caching Strategy

**TanStack Query Cache**:
```typescript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000,  // 5 minutes
      gcTime: 10 * 60 * 1000,    // 10 minutes
      retry: 2,
    },
  },
});
```

**Cache Keys**:
- Courses: `['courses', filters]` (auto-invalidate on filter change)
- Progress: `['progress', userId, courseId]`
- Learning Path: `['path', courseId]`
- Theme: Zustand + localStorage (no server cache)

### 6.3 Payload Optimization

**Lazy Loading**:
- Course thumbnails: `loading="lazy"` attribute
- Pyodide: Only load on first exercise
- Lottie animations: Load on viewport intersection

**Response Size**:
- Course list: ~2KB per course × 20 = 40KB per page
- Learning path: ~10KB (includes all nodes)
- Quiz content: ~5KB (questions + options)

---

## 7. Migration Strategy

### 7.1 Data Migration Scripts

**Add New Fields to Existing Courses**:
```python
async def migrate_courses():
    """Add enrollment_count and tags to existing courses."""
    container = cosmos_client.get_container("courses")
    
    async for course in container.read_all_items():
        if 'enrollment_count' not in course:
            course['enrollment_count'] = 0
        if 'tags' not in course:
            course['tags'] = []
        
        await container.upsert_item(course)
```

**Generate Path Nodes for Learning Paths**:
```python
async def generate_path_visualizations():
    """Generate path_nodes for all learning paths."""
    container = cosmos_client.get_container("learning_paths")
    
    async for path in container.read_all_items():
        if 'path_nodes' not in path:
            modules = path['modules']
            path['path_nodes'] = generate_path_positions(modules)
            path['total_lessons'] = sum(len(m['lessons']) for m in modules)
        
        await container.upsert_item(path)
```

### 7.2 Backward Compatibility

**Optional Fields**:
- All new fields have defaults (backward compatible)
- Frontend handles missing fields gracefully
- Old API clients continue to work (ignore new fields)

**Versioning**:
- No breaking changes to existing endpoints
- New endpoints: `/api/v1/courses/search` (with filters)
- Existing endpoints: Continue to return full dataset (deprecated)

---

## 8. Security Considerations

### 8.1 Input Sanitization

**XSS Prevention**:
```python
import bleach

def sanitize_dsl_markdown(raw: str) -> str:
    """Sanitize markdown content in DSL."""
    return bleach.clean(
        raw,
        tags=['p', 'strong', 'em', 'code', 'pre', 'ul', 'ol', 'li'],
        attributes={},
        strip=True
    )
```

**SQL Injection Prevention**:
- Pydantic validation prevents injection via type checking
- Cosmos DB parameterized queries (no string interpolation)

### 8.2 Data Privacy

**PII Fields**:
- `UserProgress.user_id`: JWT subject claim (no direct user info)
- `ThemePreference.user_id`: Same as above
- No direct storage of email, name in new models

**GDPR Compliance**:
- User can delete account → Cascade delete UserProgress
- Theme preference deleted with account
- No tracking of IP addresses or location

---

## Summary & Next Steps

### Data Model Readiness

✅ All entities defined with Pydantic schemas  
✅ Validation rules documented  
✅ Relationships mapped  
✅ State transitions defined  
✅ Performance considerations addressed  
✅ Migration strategy outlined

### Implementation Order

1. **Backend Models**: Create Pydantic schemas in `backend/app/models/`
2. **Database Migration**: Run scripts to add new fields
3. **API Endpoints**: Implement new routes in `backend/app/routes/`
4. **Frontend Types**: Generate TypeScript types from schemas
5. **Testing**: Unit tests for validation logic, integration tests for API

### Files to Create

- `backend/app/models/course_filter.py`
- `backend/app/models/course_search_result.py`
- `backend/app/models/enhanced_content.py`
- `backend/app/models/quiz.py`
- `backend/app/models/theme.py`
- `frontend/src/types/models.ts` (TypeScript types)

---

**Data Model Status**: ✅ COMPLETE  
**Ready for API Contracts**: Yes  
**Ready for Implementation**: Yes
