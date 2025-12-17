# Developer Quickstart: Mobile-Responsive UX Redesign

**Feature**: 002-mobile-ux-redesign  
**Estimated Setup Time**: 30 minutes  
**Last Updated**: 2025-11-22

---

## Prerequisites

Before starting development, ensure you have:

### Required Software
- **Node.js**: v18.x or v20.x (LTS versions)
- **Python**: 3.8+ (Python 3.11 recommended)
- **Git**: Latest version
- **VS Code** (recommended) or your preferred editor

### Required Accounts
- **Azure Cosmos DB**: Connection string for development database
- **GitHub Personal Access Token** (if using private repos)

### Hardware Requirements
- **RAM**: 8GB minimum, 16GB recommended
- **Disk Space**: 5GB free space for dependencies
- **Mobile Device** (optional): For physical device testing

---

## Quick Start (5 minutes)

### 1. Clone and Install

```powershell
# Clone repository
git clone https://github.com/your-org/mentora.git
cd mentora

# Checkout feature branch
git checkout 002-mobile-ux-redesign

# Install frontend dependencies
cd frontend
npm install

# Install backend dependencies
cd ../backend
pip install -r requirements.txt
```

### 2. Environment Setup

**Frontend** (`frontend/.env`):
```env
VITE_API_URL=http://localhost:8000/api/v1
VITE_ENABLE_PYODIDE=true
```

**Backend** (`backend/.env`):
```env
COSMOS_DB_ENDPOINT=https://your-cosmos-db.documents.azure.com:443/
COSMOS_DB_KEY=your-primary-key
JWT_SECRET_KEY=dev-secret-key-change-in-production
ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000
```

### 3. Start Development Servers

**Terminal 1 (Backend)**:
```powershell
cd backend
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

**Terminal 2 (Frontend)**:
```powershell
cd frontend
npm run dev
```

**Access**:
- Frontend: http://localhost:5173
- Backend API: http://localhost:8000/docs (Swagger UI)

---

## Project Structure

### Key Directories

```
mentora/
├── backend/
│   ├── app/
│   │   ├── models/          # NEW: Pydantic schemas
│   │   │   ├── course_filter.py
│   │   │   ├── course_search_result.py
│   │   │   ├── enhanced_content.py
│   │   │   ├── quiz.py
│   │   │   └── theme.py
│   │   ├── routes/          # API endpoints
│   │   │   ├── courses.py   # MODIFIED: Add search endpoint
│   │   │   ├── learning_paths.py  # MODIFIED: Add visualization
│   │   │   ├── progress.py  # MODIFIED: Add continue endpoint
│   │   │   └── admin_dsl.py # MODIFIED: Add sanitization
│   │   ├── services/        # NEW: Business logic layer
│   │   │   ├── course_service.py
│   │   │   ├── learning_path_service.py
│   │   │   ├── progress_service.py
│   │   │   └── dsl_service.py
│   │   └── db/              # Database utilities
│   ├── tests/               # Backend tests
│   └── requirements.txt
│
├── frontend/
│   ├── src/
│   │   ├── components/      # REFACTOR: Extract from App.tsx
│   │   │   ├── navigation/  # NEW: DesktopNav, MobileNav
│   │   │   ├── courses/     # NEW: CourseGrid, Filters
│   │   │   ├── learning-path/ # NEW: PathVisualization
│   │   │   ├── dashboard/   # NEW: Dashboard components
│   │   │   └── lesson/      # MODIFIED: Add Quiz, Exercise
│   │   ├── hooks/           # NEW: Custom React hooks
│   │   │   ├── useCourseSearch.ts
│   │   │   ├── usePlatformDetection.ts
│   │   │   ├── useCodeExecution.ts
│   │   │   └── useTheme.ts
│   │   ├── stores/          # NEW: Zustand stores
│   │   │   ├── navigationStore.ts
│   │   │   └── themeStore.ts
│   │   ├── workers/         # NEW: Web Workers
│   │   │   └── codeExecutor.worker.ts
│   │   ├── types/           # TypeScript types
│   │   └── App.tsx          # REFACTOR: Reduce from 1099 to <300 lines
│   ├── tests/               # Frontend tests
│   └── package.json
│
└── specs/
    └── 002-mobile-ux-redesign/
        ├── spec.md          # Feature specification
        ├── plan.md          # Implementation plan
        ├── research.md      # Technical research
        ├── data-model.md    # Data schemas
        ├── quickstart.md    # This file
        └── contracts/       # API contracts
            ├── courses-api.yaml
            ├── learning-paths-api.yaml
            └── admin-dsl-api.yaml
```

### Critical Files to Review

**Before Starting Work**:
1. `specs/002-mobile-ux-redesign/spec.md` - Feature requirements (73 FRs)
2. `specs/002-mobile-ux-redesign/plan.md` - Technical implementation plan
3. `specs/002-mobile-ux-redesign/research.md` - Technology decisions
4. `specs/002-mobile-ux-redesign/data-model.md` - Database schemas
5. `.specify/memory/constitution.md` - Project governance rules

**During Development**:
1. `specs/002-mobile-ux-redesign/contracts/*.yaml` - API contracts (OpenAPI specs)
2. `backend/app/models/` - Pydantic models for validation
3. `frontend/src/types/models.ts` - TypeScript types matching backend

---

## Development Workflow

### Phase 0: Critical Refactoring (Week 1)

**MUST complete before P1 features**:

1. **React 19 Migration**:
   ```powershell
   cd frontend
   npm install react@^19.0.0 react-dom@^19.0.0 @types/react@^19.0.0
   npm run build  # Test for breaking changes
   npm test       # Run full test suite
   ```

2. **App.tsx Refactoring**:
   - Current: 1099 lines (violates 500-line constitution limit)
   - Target: <300 lines
   - Strategy: Extract components to `src/components/` directory
   - See: `plan.md` Complexity Tracking section for component extraction plan

3. **Backend Service Layer**:
   ```python
   # Create service files
   backend/app/services/
   ├── course_service.py
   ├── learning_path_service.py
   ├── progress_service.py
   └── dsl_service.py
   ```

### Phase 1: Priority Features (Weeks 2-8)

**Implementation Order** (from `plan.md`):
1. Adaptive Navigation (FR-001-010) - Week 2-3
2. Course Discovery (FR-011-025) - Week 3-5
3. Learning Path Visualization (FR-026-040) - Week 5-6
4. Dashboard (FR-041-050) - Week 6-7
5. Theme Toggle (FR-051-055) - Week 7
6. Admin DSL Enhancements (FR-056-070) - Week 8

### Phase 2: Secondary Features (Weeks 9-11)

See `tasks.md` (generated via `/speckit.tasks` command)

### Phase 3: Polish & Testing (Week 12)

- E2E tests with Playwright
- Performance optimization
- Accessibility audit
- Cross-browser testing

---

## Running Tests

### Backend Tests

```powershell
cd backend

# Run all tests
pytest

# Run with coverage
pytest --cov=app --cov-report=html

# Run specific test file
pytest tests/test_course_service.py -v

# Run specific test
pytest tests/test_course_service.py::test_search_courses -v
```

**Key Test Files**:
- `tests/test_course_service.py` - Course search/filtering logic
- `tests/test_learning_path_service.py` - Path visualization
- `tests/test_progress_service.py` - Progress tracking
- `tests/test_dsl_service.py` - DSL parsing and sanitization

### Frontend Tests

```powershell
cd frontend

# Run unit tests (Vitest)
npm test

# Run with coverage
npm run test:coverage

# Run E2E tests (Playwright)
npm run test:e2e

# Run specific test file
npm test -- src/components/courses/CourseGrid.test.tsx
```

**Key Test Files**:
- `src/components/navigation/__tests__/MobileNav.test.tsx`
- `src/components/courses/__tests__/CourseGrid.test.tsx`
- `src/hooks/__tests__/useCourseSearch.test.ts`
- `e2e/mobile-navigation.spec.ts`

### Storybook (Component Catalog)

```powershell
cd frontend

# Start Storybook
npm run storybook

# Build static Storybook
npm run build-storybook
```

Access: http://localhost:6006

---

## Common Tasks

### 1. Add New API Endpoint

**Backend**:
```python
# backend/app/routes/courses.py
from fastapi import APIRouter, Depends
from app.models.course_filter import CourseFilter
from app.services.course_service import CourseService

router = APIRouter(prefix="/courses", tags=["courses"])

@router.get("/search")
async def search_courses(
    filters: CourseFilter = Depends(),
    service: CourseService = Depends()
):
    return await service.search(filters)
```

**Frontend**:
```typescript
// frontend/src/hooks/useCourseSearch.ts
import { useInfiniteQuery } from '@tanstack/react-query';

export const useCourseSearch = (filters: CourseFilter) => {
  return useInfiniteQuery({
    queryKey: ['courses', filters],
    queryFn: ({ pageParam }) => fetchCourses({ ...filters, cursor: pageParam }),
    getNextPageParam: (lastPage) => lastPage.nextCursor,
  });
};
```

### 2. Create New Component

```bash
# Generate component structure
mkdir -p frontend/src/components/courses
touch frontend/src/components/courses/CourseCard.tsx
touch frontend/src/components/courses/CourseCard.stories.tsx
touch frontend/src/components/courses/__tests__/CourseCard.test.tsx
```

**Component Template**:
```tsx
// CourseCard.tsx
import { motion } from 'motion/react';

interface CourseCardProps {
  course: Course;
  onClick: () => void;
}

export const CourseCard: React.FC<CourseCardProps> = ({ course, onClick }) => {
  return (
    <motion.div
      whileHover={{ scale: 1.05 }}
      className="bg-bright-panel dark:bg-dark-panel rounded-lg p-4"
      onClick={onClick}
    >
      <img src={course.thumbnail_url} alt={course.title} loading="lazy" />
      <h3>{course.title}</h3>
      <p>{course.category} • {course.difficulty}</p>
    </motion.div>
  );
};
```

### 3. Add Zustand Store

```typescript
// frontend/src/stores/themeStore.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface ThemeState {
  theme: 'bright' | 'dark';
  toggleTheme: () => void;
}

export const useThemeStore = create<ThemeState>()(
  persist(
    (set) => ({
      theme: 'bright',
      toggleTheme: () => set((state) => ({
        theme: state.theme === 'bright' ? 'dark' : 'bright'
      })),
    }),
    { name: 'theme-storage' }
  )
);
```

### 4. Add Pydantic Model

```python
# backend/app/models/course_filter.py
from pydantic import BaseModel, Field
from typing import Optional

class CourseFilter(BaseModel):
    category: Optional[str] = Field(None, max_length=100)
    difficulty: Optional[str] = Field(None, regex='^(Beginner|Intermediate|Advanced)$')
    search_query: Optional[str] = Field(None, min_length=2, max_length=200)
    
    class Config:
        json_schema_extra = {
            "example": {
                "category": "AI",
                "difficulty": "Beginner",
                "search_query": "machine learning"
            }
        }
```

### 5. Update Cosmos DB Index

```python
# backend/app/db/cosmos_setup.py
async def create_indexes():
    container = cosmos_client.get_container("courses")
    
    indexing_policy = {
        "indexingPolicy": {
            "compositeIndexes": [
                [
                    {"path": "/category", "order": "ascending"},
                    {"path": "/difficulty", "order": "ascending"},
                    {"path": "/enrollmentCount", "order": "descending"}
                ]
            ]
        }
    }
    
    await container.replace_container(indexing_policy=indexing_policy)
```

---

## Troubleshooting

### Backend Issues

**Issue**: `ImportError: No module named 'structlog'`  
**Solution**:
```powershell
cd backend
pip install -r requirements.txt
```

**Issue**: `Connection to Cosmos DB failed`  
**Solution**: Verify `.env` file has correct `COSMOS_DB_ENDPOINT` and `COSMOS_DB_KEY`

**Issue**: `JWT token invalid`  
**Solution**: Generate new token via `/auth/login` endpoint (see Swagger docs)

### Frontend Issues

**Issue**: `Module not found: Can't resolve '@tanstack/react-query'`  
**Solution**:
```powershell
cd frontend
npm install @tanstack/react-query
```

**Issue**: `React Hook useEffect has a missing dependency`  
**Solution**: Add dependency to useEffect array or use ESLint disable comment if intentional

**Issue**: Pyodide loading fails  
**Solution**: 
1. Check network tab for 404 errors
2. Verify `VITE_ENABLE_PYODIDE=true` in `.env`
3. Clear browser cache and reload

**Issue**: Dark mode not persisting  
**Solution**: Check browser localStorage (DevTools → Application → Local Storage)

### Test Issues

**Issue**: `ModuleNotFoundError` in pytest  
**Solution**:
```powershell
cd backend
pip install -e .  # Install package in editable mode
```

**Issue**: Playwright tests timeout  
**Solution**:
```powershell
cd frontend
npx playwright install  # Install browser binaries
```

---

## Performance Monitoring

### Lighthouse (Frontend)

```powershell
cd frontend
npm run build
npx serve -s dist -p 3000

# In Chrome DevTools:
# Lighthouse tab → Generate report
```

**Targets** (from constitution):
- Performance: >90
- Accessibility: >90
- Best Practices: >90
- SEO: >80

### API Response Times (Backend)

```python
# Check structlog output for response_time_ms
# Target: p95 < 500ms
```

Example log:
```json
{
  "event": "request_completed",
  "level": "info",
  "timestamp": "2025-11-22T10:30:45.123Z",
  "method": "GET",
  "endpoint": "/api/v1/courses/search",
  "status_code": 200,
  "response_time_ms": 45.67
}
```

---

## Debugging Tips

### Backend Debugging

**Enable debug logging**:
```python
# backend/config.py
LOG_LEVEL = "DEBUG"
```

**Use FastAPI interactive docs**:
- http://localhost:8000/docs (Swagger UI)
- http://localhost:8000/redoc (ReDoc)

**VS Code launch.json**:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Python: FastAPI",
      "type": "python",
      "request": "launch",
      "module": "uvicorn",
      "args": ["main:app", "--reload"],
      "cwd": "${workspaceFolder}/backend",
      "env": {"PYTHONPATH": "${workspaceFolder}/backend"}
    }
  ]
}
```

### Frontend Debugging

**React DevTools**:
- Install browser extension
- Inspect component tree
- View props/state

**TanStack Query DevTools**:
```tsx
// frontend/src/App.tsx
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';

<QueryClientProvider client={queryClient}>
  <App />
  <ReactQueryDevtools initialIsOpen={false} />
</QueryClientProvider>
```

**Zustand DevTools**:
```typescript
// Stores automatically connect to Redux DevTools extension
// Install Redux DevTools browser extension
```

**Mobile Device Debugging**:
```powershell
# Expose dev server to local network
cd frontend
npm run dev -- --host
```

Access from mobile: http://YOUR_LOCAL_IP:5173

---

## Resources

### Documentation

- **Feature Spec**: `specs/002-mobile-ux-redesign/spec.md`
- **Implementation Plan**: `specs/002-mobile-ux-redesign/plan.md`
- **Research Findings**: `specs/002-mobile-ux-redesign/research.md`
- **Data Models**: `specs/002-mobile-ux-redesign/data-model.md`
- **API Contracts**: `specs/002-mobile-ux-redesign/contracts/`

### External Links

- [React 19 Migration Guide](https://react.dev/blog/2024/04/25/react-19)
- [TanStack Query Docs](https://tanstack.com/query/latest)
- [Motion (Framer Motion) Docs](https://motion.dev/)
- [Tailwind CSS Dark Mode](https://tailwindcss.com/docs/dark-mode)
- [Pyodide Documentation](https://pyodide.org/en/stable/)
- [Zustand Guide](https://docs.pmnd.rs/zustand/getting-started/introduction)
- [FastAPI Best Practices](https://fastapi.tiangolo.com/tutorial/)
- [Pydantic V2 Migration](https://docs.pydantic.dev/latest/migration/)

### Team Contacts

- **Frontend Lead**: [TBD]
- **Backend Lead**: [TBD]
- **DevOps**: [TBD]
- **Design**: [TBD]

---

## Next Steps

1. ✅ Complete environment setup
2. ✅ Review feature specification
3. ⏭️ Start Phase 0 refactoring:
   - React 19 migration
   - App.tsx component extraction
   - Backend service layer creation
4. ⏭️ Begin Phase 1 implementation (see `plan.md` for details)

**Ready to start? Run `npm test` (frontend) and `pytest` (backend) to verify setup!**

---

**Last Updated**: 2025-11-22  
**Status**: ✅ COMPLETE  
**Next Document**: `tasks.md` (generate via `/speckit.tasks` command)
