# Research Findings: Mobile-Responsive UX Redesign

**Feature**: 002-mobile-ux-redesign  
**Date**: 2025-11-22  
**Status**: Complete

## Overview

This document consolidates technical research findings for implementing the mobile-responsive UX redesign. All NEEDS CLARIFICATION items from the plan have been resolved with specific implementation guidance.

---

## 1. React 19.x Migration Strategy

**Decision**: Upgrade to React 19.x before starting navigation refactoring

**Rationale**:
- React 19 includes performance improvements for concurrent rendering and transitions (critical for 60fps animations)
- New hooks (`useFormStatus`, `useOptimistic`) beneficial for quiz/exercise feedback
- Breaking changes are minimal and can be addressed in isolated refactoring phase
- Upgrading later would require retesting all new components

**Migration Checklist**:
1. Update `package.json`: `react@^19.0.0`, `react-dom@^19.0.0`
2. Update TypeScript types: `@types/react@^19.0.0`
3. Replace deprecated lifecycle methods (none identified in current codebase)
4. Test existing components for breaking changes (focus on context API usage)
5. Enable strict mode and concurrent features in root
6. Update React Router to v6.20+ (compatible with React 19)

**Breaking Changes to Address**:
- `ReactDOM.render` → `ReactDOM.createRoot` (already done in current codebase)
- PropTypes removed (use TypeScript instead)
- Legacy context deprecated (use new Context API)

**Alternatives Considered**:
- Stay on React 18: Rejected due to missing performance optimizations needed for mobile 60fps target
- Upgrade during implementation: Rejected due to risk of introducing bugs during feature development

**Implementation Notes**:
- Run full test suite after upgrade
- Monitor bundle size (React 19 is slightly smaller)
- Update Vite to 5.0.8+ for optimal React 19 support

**Risks**:
- Third-party library incompatibilities (mitigate: check Motion, TanStack Query compatibility first)
- Unexpected behavior changes (mitigate: comprehensive testing before feature work)

---

## 2. TanStack Query Infinite Scroll Implementation

**Decision**: Use TanStack Query v5 with `useInfiniteQuery` for course catalog infinite scroll

**Rationale**:
- Built-in support for cursor-based pagination (aligns with Cosmos DB continuation tokens)
- Automatic loading state management reduces boilerplate
- Smart refetching and background updates improve perceived performance
- Cache management prevents redundant API calls during navigation

**Implementation Pattern**:
```typescript
import { useInfiniteQuery } from '@tanstack/react-query';

const useCourseSearch = (filters: CourseFilters) => {
  return useInfiniteQuery({
    queryKey: ['courses', filters],
    queryFn: ({ pageParam }) => 
      fetchCourses({ ...filters, cursor: pageParam }),
    getNextPageParam: (lastPage) => lastPage.nextCursor,
    initialPageParam: undefined,
    staleTime: 5 * 60 * 1000, // 5 minutes
    gcTime: 10 * 60 * 1000, // 10 minutes (formerly cacheTime)
  });
};
```

**Key Features**:
- `queryKey` includes filters for automatic re-fetching when filters change
- `pageParam` passes continuation cursor to backend
- `getNextPageParam` extracts next cursor from API response
- `staleTime` prevents unnecessary refetches during user interactions
- `gcTime` (renamed from `cacheTime` in v5) keeps data in memory for back navigation

**Intersection Observer Integration**:
```typescript
const { ref, inView } = useInView({ threshold: 0.8 });
const { data, fetchNextPage, hasNextPage, isFetchingNextPage } = useCourseSearch(filters);

useEffect(() => {
  if (inView && hasNextPage && !isFetchingNextPage) {
    fetchNextPage();
  }
}, [inView, hasNextPage, isFetchingNextPage, fetchNextPage]);
```

**Alternatives Considered**:
- Custom scroll listener: Rejected due to reinventing wheel and missing cache management
- SWR library: Rejected due to less mature infinite scroll support
- Apollo Client (GraphQL): Rejected as backend uses REST API

**Implementation Notes**:
- Backend must return `{ courses: Course[], nextCursor: string | null }`
- Use `react-intersection-observer` for scroll detection
- Debounce filter changes (300ms) to prevent excessive queries (FR-022)
- Display loading skeleton during `isFetchingNextPage`

**Risks**:
- Large result sets may cause memory issues (mitigate: implement virtual scrolling with `react-window` if >200 courses loaded)
- Cursor expiration in Cosmos DB (mitigate: implement cursor TTL and handle expiration gracefully)

---

## 3. Platform Detection Strategies

**Decision**: Use combination of `navigator.userAgent` parsing and viewport width for platform detection

**Rationale**:
- User agent provides OS information (Windows, iOS, Android)
- Viewport width determines navigation UI (left panel vs bottom bar)
- Combination provides highest reliability across browsers and PWA installs
- Avoids false positives from browser emulation modes

**Implementation Pattern**:
```typescript
const usePlatformDetection = () => {
  const [platform, setPlatform] = useState<'windows' | 'ios' | 'android'>('windows');
  const [viewportWidth, setViewportWidth] = useState(window.innerWidth);

  useEffect(() => {
    const userAgent = navigator.userAgent.toLowerCase();
    const isIOS = /iphone|ipad|ipod/.test(userAgent);
    const isAndroid = /android/.test(userAgent);
    const isWindows = /windows/.test(userAgent) || (!isIOS && !isAndroid);

    setPlatform(isIOS ? 'ios' : isAndroid ? 'android' : 'windows');

    const handleResize = () => setViewportWidth(window.innerWidth);
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  const isMobile = viewportWidth < 1024;
  const showBottomNav = isMobile && (platform === 'ios' || platform === 'android');
  const showLeftPanel = !isMobile || platform === 'windows';

  return { platform, viewportWidth, isMobile, showBottomNav, showLeftPanel };
};
```

**Breakpoint Strategy**:
- Mobile: < 768px (1 column grid, bottom nav, stacked layout)
- Tablet: 768px - 1023px (2 column grid, bottom nav, hybrid layout)
- Desktop: ≥ 1024px (3-4 column grid, left panel, spacious layout)

**Edge Cases**:
- iPadOS reports as Mac in user agent: Use touch capability detection (`navigator.maxTouchPoints > 0`)
- PWA installed on desktop: User agent stays the same, use viewport width
- Browser developer tools emulation: Correctly shows mobile UI based on viewport

**Alternatives Considered**:
- `navigator.platform` (deprecated): Rejected due to deprecation warnings
- CSS media queries only: Rejected as React components need platform info for logic
- `window.matchMedia('(display-mode: standalone)')`: Useful for PWA detection but doesn't determine OS

**Implementation Notes**:
- Store platform in Zustand for global access
- Re-evaluate on window resize with debounce (200ms)
- Test on physical iOS/Android devices (BrowserStack for CI)

**Risks**:
- User agent spoofing: Low risk as detection is for UX optimization, not security
- Future browser changes: Monitor deprecation notices, fallback to viewport-only detection

---

## 4. Pyodide Integration Patterns

**Decision**: Load Pyodide lazily in Web Worker with CDN-hosted packages

**Rationale**:
- Web Worker isolation prevents blocking main thread during Python execution
- CDN hosting (jsdelivr.com) reduces bundle size and leverages browser caching
- Lazy loading only when user encounters first coding exercise reduces initial load time
- 50MB+ Pyodide runtime acceptable as one-time download for users doing exercises

**Implementation Pattern**:
```typescript
// workers/codeExecutor.worker.ts
import { loadPyodide } from 'pyodide';

let pyodide: any = null;

self.onmessage = async (event) => {
  const { code, expectedOutput } = event.data;

  if (!pyodide) {
    pyodide = await loadPyodide({
      indexURL: 'https://cdn.jsdelivr.net/pyodide/v0.24.1/full/',
    });
  }

  try {
    const result = await pyodide.runPythonAsync(code);
    const output = result?.toString() || '';
    const isCorrect = output.trim() === expectedOutput.trim();
    
    self.postMessage({ success: true, output, isCorrect });
  } catch (error) {
    self.postMessage({ success: false, error: error.message });
  }
};
```

**React Hook**:
```typescript
const useCodeExecution = () => {
  const workerRef = useRef<Worker | null>(null);

  useEffect(() => {
    workerRef.current = new Worker(
      new URL('./workers/codeExecutor.worker.ts', import.meta.url),
      { type: 'module' }
    );
    return () => workerRef.current?.terminate();
  }, []);

  const executeCode = (code: string, expectedOutput: string): Promise<ExecutionResult> => {
    return new Promise((resolve) => {
      workerRef.current!.onmessage = (e) => resolve(e.data);
      workerRef.current!.postMessage({ code, expectedOutput });
    });
  };

  return { executeCode };
};
```

**Performance Optimization**:
- Cache Pyodide instance across exercises (don't reload)
- Implement 10-second timeout for code execution
- Show loading indicator during first Pyodide load (~5-10 seconds)
- Preload Pyodide when user navigates to lesson with exercises

**Alternatives Considered**:
- Server-side execution: Rejected per clarifications (browser-based only)
- Skulpt (Python-in-JS): Rejected due to limited Python 3 support
- Brython: Rejected due to incomplete standard library

**Implementation Notes**:
- Use Vite worker plugin for bundling
- Set appropriate CORS headers if self-hosting Pyodide
- Implement resource limits (can't fully prevent infinite loops, use timeout)
- Display friendly error messages for common mistakes (indentation, syntax)

**Risks**:
- 50MB download on slow connections: Mitigate with loading progress indicator
- Browser compatibility (need SharedArrayBuffer for some features): Acceptable as not required for basic execution
- Security concerns (arbitrary code execution): Acceptable as runs in user's browser, not server

---

## 5. Motion (Framer Motion) Performance Best Practices

**Decision**: Use Motion (Framer Motion fork) with GPU-accelerated transforms and layout animations

**Rationale**:
- Motion is actively maintained fork of Framer Motion with better TypeScript support
- GPU-accelerated transforms (translate, scale, opacity) achieve 60fps on mobile
- Layout animations automatically optimize for performance
- Exit animations during route changes enhance perceived quality

**60fps Animation Patterns**:
```typescript
// Prefer transform over position changes
<motion.div
  initial={{ opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
  exit={{ opacity: 0, y: -20 }}
  transition={{ duration: 0.3, ease: [0.4, 0.0, 0.2, 1] }} // easeInOut
/>

// Use layoutId for morphing animations
<motion.div layoutId="course-card-123" />

// Stagger children for sequential reveal
<motion.div
  variants={{
    hidden: { opacity: 0 },
    visible: { opacity: 1, transition: { staggerChildren: 0.1 } }
  }}
>
  {items.map(item => <motion.div variants={itemVariants} key={item.id} />)}
</motion.div>
```

**Performance Checklist**:
- ✅ Use `transform` (translate, scale, rotate) instead of `top`, `left`, `width`, `height`
- ✅ Use `opacity` for fade effects
- ✅ Add `will-change: transform` for animated elements (Motion does this automatically)
- ✅ Use `layout="position"` instead of `layout` for better performance
- ✅ Avoid animating `box-shadow` (use `filter: drop-shadow` or scale trick)
- ✅ Use `AnimatePresence` with `mode="wait"` for route transitions
- ✅ Implement `reduced-motion` media query support

**Reduced Motion Support**:
```typescript
const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

const transition = prefersReducedMotion 
  ? { duration: 0 } 
  : { duration: 0.3, ease: [0.4, 0.0, 0.2, 1] };
```

**Alternatives Considered**:
- CSS transitions only: Rejected due to lack of orchestration for complex sequences
- React Spring: Rejected due to steeper learning curve and less declarative API
- GSAP: Rejected due to license cost and overkill for simple transitions

**Implementation Notes**:
- Use `<AnimatePresence>` wrapper for exit animations
- Monitor performance with Chrome DevTools (Paint Flashing, FPS meter)
- Test on low-end Android devices (target: Snapdragon 600 series)
- Disable animations in E2E tests for speed

**Risks**:
- Bundle size (~35KB gzipped): Acceptable for animation benefits
- Older browser compatibility: Gracefully degrades to instant transitions

---

## 6. Tailwind Dark Mode Implementation

**Decision**: Use class-based dark mode with manual toggle and localStorage persistence

**Rationale**:
- Class-based approach (`dark:` variants) provides instant switching with JavaScript
- localStorage persistence maintains theme across sessions (FR-053)
- Manual control allows theme toggle independent of system preference
- Tailwind's dark mode utilities provide consistent styling across all components

**Configuration**:
```javascript
// tailwind.config.js
module.exports = {
  darkMode: 'class', // class-based instead of 'media'
  theme: {
    extend: {
      colors: {
        // Bright theme (default)
        'bright-base': '#FFFFFF',
        'bright-panel': '#F8F9FA',
        'bright-text': '#1A1A1A',
        'bright-border': '#E5E7EB',
        
        // Dark theme
        'dark-base': '#0B0B0B',
        'dark-panel': '#111318',
        'dark-text': '#E5E7EB',
        'dark-border': '#2D3748',
        
        // Accent colors (same for both themes)
        'primary': {
          500: '#3B82F6',
          600: '#2563EB',
          700: '#1D4ED8',
        },
      },
    },
  },
};
```

**Theme Hook**:
```typescript
const useTheme = () => {
  const [theme, setTheme] = useState<'bright' | 'dark'>(() => {
    return (localStorage.getItem('theme') as 'bright' | 'dark') || 'bright';
  });

  useEffect(() => {
    const root = document.documentElement;
    if (theme === 'dark') {
      root.classList.add('dark');
    } else {
      root.classList.remove('dark');
    }
    localStorage.setItem('theme', theme);
  }, [theme]);

  const toggleTheme = () => setTheme(prev => prev === 'bright' ? 'dark' : 'bright');

  return { theme, toggleTheme };
};
```

**Component Styling Example**:
```tsx
<div className="bg-bright-base dark:bg-dark-base text-bright-text dark:dark-text">
  <h1 className="text-2xl font-bold">Course Title</h1>
  <p className="text-gray-600 dark:text-gray-400">Description</p>
</div>
```

**Smooth Transitions**:
```css
/* Add to global CSS */
* {
  transition: background-color 300ms ease, color 300ms ease, border-color 300ms ease;
}

/* Disable transitions during theme change to prevent flash */
.theme-transitioning * {
  transition: none !important;
}
```

**Alternatives Considered**:
- Media query approach (`prefers-color-scheme`): Rejected as manual toggle required (FR-051)
- CSS custom properties only: Rejected due to Tailwind integration complexity
- Separate CSS files per theme: Rejected due to bundle size and switching complexity

**Implementation Notes**:
- Test color contrast ratios (WCAG AA: 4.5:1 for text)
- Ensure all components respect dark mode (no hardcoded colors)
- Handle theme during SSR (read from cookie if implementing SSR later)
- Add theme toggle to navigation bar and settings page

**Risks**:
- Flash of unstyled content on load: Mitigate with inline script in HTML head
- Missing dark variants on some components: Mitigate with thorough review and testing

---

## 7. Zustand Global State Patterns

**Decision**: Use Zustand for navigation context and theme state with TypeScript and persist middleware

**Rationale**:
- Minimal boilerplate compared to Redux (no actions, reducers, providers)
- Built-in TypeScript support with strong typing
- Persist middleware handles localStorage synchronization automatically
- No Context Provider needed (simpler component tree)
- DevTools integration for debugging

**Navigation Store**:
```typescript
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface NavigationState {
  platform: 'windows' | 'ios' | 'android';
  viewportWidth: number;
  activeRoute: string;
  setPlatform: (platform: NavigationState['platform']) => void;
  setViewportWidth: (width: number) => void;
  setActiveRoute: (route: string) => void;
}

export const useNavigationStore = create<NavigationState>()(
  persist(
    (set) => ({
      platform: 'windows',
      viewportWidth: 1024,
      activeRoute: '/',
      setPlatform: (platform) => set({ platform }),
      setViewportWidth: (width) => set({ viewportWidth: width }),
      setActiveRoute: (route) => set({ activeRoute: route }),
    }),
    {
      name: 'navigation-storage',
      partialize: (state) => ({ activeRoute: state.activeRoute }), // Only persist route
    }
  )
);
```

**Theme Store**:
```typescript
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
    {
      name: 'theme-storage',
    }
  )
);
```

**Usage in Components**:
```typescript
// Select specific state slices (automatic re-render only when changed)
const platform = useNavigationStore(state => state.platform);
const theme = useThemeStore(state => state.theme);
const toggleTheme = useThemeStore(state => state.toggleTheme);
```

**DevTools Integration**:
```typescript
import { devtools } from 'zustand/middleware';

export const useNavigationStore = create<NavigationState>()(
  devtools(
    persist(
      (set) => ({ /* store implementation */ }),
      { name: 'navigation-storage' }
    ),
    { name: 'NavigationStore' }
  )
);
```

**Alternatives Considered**:
- Context API: Rejected due to boilerplate and potential re-render issues
- Redux Toolkit: Rejected due to overkill for simple state management
- Jotai/Recoil: Rejected due to less mature ecosystem and different mental model

**Implementation Notes**:
- Keep stores small and focused (single responsibility)
- Use selectors to prevent unnecessary re-renders
- Avoid storing derived state (compute in components)
- Test stores independently with `act()` from React Testing Library

**Risks**:
- No time-travel debugging: Acceptable as DevTools provide sufficient debugging
- localStorage limitations (5MB): Not a concern for navigation/theme state

---

## 8. Structured Logging in FastAPI

**Decision**: Integrate structlog with FastAPI middleware for JSON-formatted request logging

**Rationale**:
- Structured logging provides machine-parseable JSON output for log aggregation
- Middleware approach automatically logs all requests without per-route configuration
- Context binding (user_id, request_id) enables request tracing
- JSON format enables easy parsing for manual analysis (requirement from clarifications)

**Configuration**:
```python
import structlog
from fastapi import FastAPI, Request
import time
import uuid

# Configure structlog
structlog.configure(
    processors=[
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.JSONRenderer()
    ],
    wrapper_class=structlog.make_filtering_bound_logger(logging.INFO),
    context_class=dict,
    logger_factory=structlog.PrintLoggerFactory(),
)

logger = structlog.get_logger()
```

**Middleware Implementation**:
```python
@app.middleware("http")
async def log_requests(request: Request, call_next):
    request_id = str(uuid.uuid4())
    
    # Bind request context
    structlog.contextvars.bind_contextvars(
        request_id=request_id,
        method=request.method,
        endpoint=request.url.path,
        user_id=getattr(request.state, "user_id", None),
    )
    
    start_time = time.time()
    response = await call_next(request)
    duration = time.time() - start_time
    
    # Log request completion
    logger.info(
        "request_completed",
        status_code=response.status_code,
        response_time_ms=round(duration * 1000, 2),
    )
    
    structlog.contextvars.unbind_contextvars("request_id", "method", "endpoint", "user_id")
    
    return response
```

**Log Output Example**:
```json
{
  "event": "request_completed",
  "level": "info",
  "timestamp": "2025-11-22T10:30:45.123Z",
  "request_id": "550e8400-e29b-41d4-a716-446655440000",
  "method": "GET",
  "endpoint": "/api/v1/courses/search",
  "user_id": "user_12345",
  "status_code": 200,
  "response_time_ms": 45.67
}
```

**Error Logging**:
```python
try:
    result = await course_service.search(filters)
except Exception as e:
    logger.error("course_search_failed", error=str(e), error_type=type(e).__name__)
    raise
```

**Alternatives Considered**:
- Application Insights: Rejected per clarifications (structured logging only)
- Python logging with JSON formatter: Rejected due to lack of context binding
- Custom logging wrapper: Rejected due to reinventing structlog's proven patterns

**Implementation Notes**:
- Add `structlog>=23.0.0` to requirements.txt
- Extract user_id from JWT token in auth dependency
- Log error details but sanitize sensitive data (no passwords, tokens in logs)
- Configure log rotation in production (Azure App Service handles this)

**Risks**:
- Performance overhead of JSON serialization: Minimal (~1ms per request)
- Missing logs during crashes: Mitigate with exception handler and flush on critical errors

---

## 9. Cosmos DB Index Optimization

**Decision**: Create composite index for (category, difficulty, title) with case-insensitive text search

**Rationale**:
- Composite index reduces RU cost for multi-filter queries by 50-70%
- Category and difficulty are exact match filters (efficient indexing)
- Title requires full-text search (use Cosmos DB's Contains() function)
- Case-insensitive collation improves search UX

**Index Policy Configuration**:
```json
{
  "indexingPolicy": {
    "automatic": true,
    "indexingMode": "consistent",
    "includedPaths": [
      { "path": "/*" }
    ],
    "compositeIndexes": [
      [
        { "path": "/category", "order": "ascending" },
        { "path": "/difficulty", "order": "ascending" },
        { "path": "/title", "order": "ascending" }
      ],
      [
        { "path": "/category", "order": "ascending" },
        { "path": "/enrollmentCount", "order": "descending" }
      ]
    ]
  }
}
```

**Query Pattern**:
```python
# Efficient query with composite index
query = """
    SELECT * FROM c 
    WHERE c.category = @category 
    AND c.difficulty = @difficulty 
    AND CONTAINS(LOWER(c.title), LOWER(@search_query))
    ORDER BY c.enrollmentCount DESC
"""

parameters = [
    {"name": "@category", "value": "AI"},
    {"name": "@difficulty", "value": "Beginner"},
    {"name": "@search_query", "value": "machine learning"}
]

results = container.query_items(
    query=query,
    parameters=parameters,
    enable_cross_partition_query=True
)
```

**RU Cost Estimation**:
- Simple query (no filters): ~3 RU
- Single filter (category): ~5 RU
- Multi-filter with text search (indexed): ~15-25 RU
- Multi-filter without index: ~50-100 RU

**Cursor-Based Pagination**:
```python
# Use continuation token for infinite scroll
results_iterable = container.query_items(
    query=query,
    parameters=parameters,
    max_item_count=20  # Page size
)

results_by_page = results_iterable.by_page()
page = next(results_by_page)

courses = list(page)
continuation_token = results_by_page.continuation_token  # Return to frontend
```

**Alternatives Considered**:
- Azure Cognitive Search: Rejected due to added cost and infrastructure complexity
- Client-side filtering: Rejected due to poor performance and scalability issues
- Single-column indexes only: Rejected due to high RU cost for multi-filter queries

**Implementation Notes**:
- Deploy index policy via Bicep template in `/infra`
- Monitor RU consumption with Azure Portal metrics
- Add `enrollmentCount` field to Course model for popularity sorting
- Test queries with sample data to validate index usage

**Risks**:
- Index rebuild time: ~5-10 minutes for existing data
- Increased storage cost: Minimal (~10% increase for composite indexes)
- Query complexity limits: Cosmos DB supports max 100 composite indexes (not a concern)

---

## 10. Bleach XSS Sanitization Patterns

**Decision**: Configure Bleach with allow-list for safe HTML/markdown in DSL content

**Rationale**:
- Bleach is mature Python library for HTML sanitization (used by Mozilla, PyPI)
- Allow-list approach (whitelist) is more secure than blocklist
- Supports markdown-safe tags while blocking XSS vectors (script, iframe, etc.)
- Integration with DSL parser provides defense-in-depth

**Bleach Configuration**:
```python
import bleach

ALLOWED_TAGS = [
    # Text formatting
    'p', 'br', 'strong', 'em', 'u', 'code', 'pre',
    # Lists
    'ul', 'ol', 'li',
    # Headings
    'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
    # Links (sanitized separately)
    'a',
    # Blockquote
    'blockquote',
]

ALLOWED_ATTRIBUTES = {
    'a': ['href', 'title'],
    '*': ['class'],  # Allow class for styling
}

ALLOWED_PROTOCOLS = ['http', 'https', 'mailto']

def sanitize_dsl_content(raw_content: str) -> str:
    """Sanitize user-provided DSL content to prevent XSS."""
    return bleach.clean(
        raw_content,
        tags=ALLOWED_TAGS,
        attributes=ALLOWED_ATTRIBUTES,
        protocols=ALLOWED_PROTOCOLS,
        strip=True  # Remove disallowed tags entirely
    )
```

**Video Embed Sanitization**:
```python
import re

ALLOWED_VIDEO_DOMAINS = ['youtube.com', 'youtu.be', 'vimeo.com']

def sanitize_video_url(url: str) -> str:
    """Validate video URLs to prevent XSS via iframe."""
    parsed = urlparse(url)
    
    # Check domain whitelist
    if not any(domain in parsed.netloc for domain in ALLOWED_VIDEO_DOMAINS):
        raise ValueError(f"Video domain not allowed: {parsed.netloc}")
    
    # Ensure HTTPS
    if parsed.scheme != 'https':
        raise ValueError("Video URLs must use HTTPS")
    
    return url
```

**DSL Parser Integration**:
```python
def parse_dsl(raw_dsl: str) -> ParsedCourse:
    """Parse DSL with sanitization at multiple stages."""
    
    # Stage 1: Sanitize raw DSL before parsing
    sanitized_dsl = sanitize_dsl_content(raw_dsl)
    
    # Stage 2: Parse into structured format
    parsed = DSLParser.parse(sanitized_dsl)
    
    # Stage 3: Sanitize specific content types
    for module in parsed.modules:
        for lesson in module.lessons:
            for item in lesson.content:
                if item.type == 'video':
                    item.url = sanitize_video_url(item.url)
                elif item.type == 'text':
                    item.text = bleach.linkify(item.text)  # Auto-linkify URLs safely
    
    return parsed
```

**Testing XSS Vectors**:
```python
# Test cases to verify sanitization
xss_vectors = [
    '<script>alert("XSS")</script>',
    '<img src=x onerror=alert("XSS")>',
    '<iframe src="javascript:alert(\'XSS\')"></iframe>',
    '<a href="javascript:alert(\'XSS\')">Click</a>',
    '<svg onload=alert("XSS")>',
]

for vector in xss_vectors:
    sanitized = sanitize_dsl_content(vector)
    assert '<script' not in sanitized.lower()
    assert 'javascript:' not in sanitized.lower()
    assert 'onerror' not in sanitized.lower()
```

**Alternatives Considered**:
- DOMPurify (JavaScript): Rejected as sanitization must happen server-side (FR-066)
- nh3 (Rust binding): Rejected due to compilation complexity and Python preference
- Custom regex-based sanitizer: Rejected due to high risk of bypasses

**Implementation Notes**:
- Add `bleach>=6.1.0` to requirements.txt
- Log sanitization events for security auditing
- Display sanitized preview in admin interface before saving
- Test with OWASP XSS cheat sheet vectors

**Risks**:
- False positives (legitimate content blocked): Mitigate with clear admin documentation
- Bleach bypasses (rare): Mitigate with regular library updates and security monitoring

---

## Summary & Recommendations

### Critical Path Items

1. **React 19 Migration** (1-2 days): Must complete before refactoring
2. **App.tsx Refactoring** (3-5 days): Unblocking requirement for P1 features
3. **Backend Service Layer** (2-3 days): Constitution requirement, unblocks clean API implementation
4. **TanStack Query Setup** (1 day): Required for course discovery infinite scroll

### Technology Stack Readiness

| Technology | Maturity | Production Ready | Notes |
|------------|----------|------------------|-------|
| React 19 | Stable | ✅ Yes | Released, well-tested |
| TanStack Query v5 | Stable | ✅ Yes | Production-proven |
| Motion (Framer Motion) | Stable | ✅ Yes | Fork with active maintenance |
| Pyodide 0.24 | Stable | ✅ Yes | Used in production by JupyterLite |
| Zustand | Stable | ✅ Yes | Lightweight, battle-tested |
| Structlog | Stable | ✅ Yes | Industry standard for Python |
| Bleach | Stable | ✅ Yes | Used by Mozilla, PyPI |

### Risk Mitigation

**High Risk**:
- App.tsx refactoring complexity → Mitigate with incremental approach, comprehensive tests
- Pyodide bundle size (50MB+) → Mitigate with lazy loading, progress indicators

**Medium Risk**:
- React 19 migration breaking changes → Mitigate with thorough testing before feature work
- Cosmos DB RU costs for text search → Mitigate with index optimization, query profiling

**Low Risk**:
- Platform detection accuracy → Acceptable fallback to viewport-only detection
- Theme switching edge cases → Mitigate with comprehensive E2E tests

### Next Steps

1. ✅ Research complete - all technical unknowns resolved
2. ⏭️ **Proceed to Phase 1**: Generate data-model.md, API contracts, quickstart.md
3. ⏭️ **Run agent context update**: Add new technologies to Copilot instructions
4. ⏭️ **Begin implementation**: Start with React 19 migration and App.tsx refactoring

---

**Research Status**: ✅ COMPLETE  
**All NEEDS CLARIFICATION Resolved**: Yes  
**Ready for Phase 1 Design**: Yes
