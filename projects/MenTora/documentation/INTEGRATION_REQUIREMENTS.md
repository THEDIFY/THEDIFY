# Integration Requirements - Feature 002

**Last Updated**: 2025-11-22

## Critical Integration Principles

Every task in this feature MUST follow these integration requirements to create a seamless environment:

### 1. Search Before Create
- **ALWAYS** search for existing implementations before creating new files
- Use `grep_search` or `file_search` tools to find related components
- Extend existing code rather than duplicate functionality
- Document findings in `/work/notes/phase-X-existing-*.md`

### 2. User Journey Flow Integration
All components must support the complete user journey:

```
Menu/Intro Page 
  ↓
Start Course Button 
  ↓
Sign In Page 
  ↓
Welcome Page ("Ready to continue your experience with Mentora, [Name]")
  ↓
Quick Quiz (knowing more about user)
  ↓
Profile Creation (simulated custom profile)
  ↓
Payment Page
  ↓
Main App (auto-redirect after payment)
```

**Desktop**: Professional menu page with cool animations, minimalistic dark design, Mentora mission as title, same logo
**Mobile**: Simple intro explaining why Mentora and how it helps (concise)

### 3. Navigation Integration

#### Desktop (Windows PWA - ≥1024px)
- **Left Panel** always visible containing:
  - Main Menu items
  - Course search with recommended courses at top
  - Filter system (difficulty slider with stars, subject, length)
  - Progress section (with animations)
  - Profile section (config, preferences, subscription tier)
- **Center Area** shows:
  - 3 most recent courses (quick continue)
  - Streak (centered)
  - Weekly progress
  - User badge

#### Mobile (iOS/Android - <1024px)
- **Bottom Navigation Bar** (Duolingo-style) with 5 sections:
  - Left: Progress
  - Left-center: Courses
  - Center: Start new course button
  - Right-center: Your Courses
  - Right: Profile
- **Course Cards**: 2 side-by-side with vertical scrolling

### 4. Course Card Integration
Every course card MUST display:
- Course image
- Title
- Subtitle
- Circular progress indicator (fills as user progresses)
- Star-based reviews (in listings)

**Layout**: 
- Mobile: 2 cards side-by-side
- Desktop/Workstation: 3 cards side-by-side

### 5. Learning Path Integration

#### Mobile Path Display
- Intro page with course info
- Below intro: literal path visualization
- Modules on path: lesson, exercise, video, summary, quiz, certificate
- Gray → color transition when completed
- Intro disappears on scroll (Duolingo-style)
- Bottom menu stays fixed
- Learning path remains visible

#### Desktop Path Display
- Small left-side menu showing module progression
- Same animations as mobile
- First module always colored (course introduction)
- Advance button on bottom-right

### 6. Search & Filter Integration
- **Search Location**: Left panel (desktop) or top bar (mobile)
- **Recommended courses** always at top
- **Filters**:
  - Difficulty: Draggable slider with animated stars
  - Shows difficulty level/required fluency below
  - Subject dropdown
  - Course length dropdown
  - Additional filters as needed

### 7. Animation Integration
Target: 60fps performance for all animations

Required animations:
- Progress component interactions (engaging, cool)
- Module state transitions (gray → color)
- Difficulty slider stars
- Course progress indicators (circular fill)
- Navigation transitions

### 8. Theme Integration
- **Both bright and dark modes** required
- **Minimalist premium color palette**
- **Mentora logo and brand colors** preserved
- Theme stored in localStorage via Zustand
- Smooth transitions (300ms ease)

### 9. Admin DSL Integration
DSL must configure ALL course aspects:
- Stars received (rating)
- Course image
- Course intro
- Modules (lesson, exercise, video, summary, quiz, certificate)
- Course title
- Course subtitle
- All other metadata

App must interpret DSL **exactly as written** and generate correct structure.

### 10. Backend Service Integration
All services MUST:
- Integrate with Azure Cosmos DB (existing connection)
- Maintain current data structures
- Support API contracts from `contracts/`
- Use structlog for JSON logging
- Apply Bleach sanitization on user content
- Follow service layer pattern (Constitution requirement)

### 11. API Endpoint Integration
All endpoints MUST:
- Maintain existing API contracts
- Support both frontend and mobile clients
- Return proper HTTP status codes
- Include error handling with meaningful messages
- Integrate with authentication middleware
- Support pagination for list endpoints

### 12. State Management Integration
- **Zustand stores** with localStorage persistence for:
  - Navigation state (user journey progress)
  - Theme preference (bright/dark)
  - User progress (streak, weekly, badges)
- **TanStack Query** for:
  - Course data fetching
  - Progress synchronization
  - Real-time updates

### 13. Production Infrastructure Integration
- All features MUST work with Azure infra folder configuration
- Replace non-production frontend (used only for testing)
- Seamless deployment to production
- No breaking changes to existing Azure resources

### 14. Performance Integration
All components must meet:
- **API**: p95 <500ms response time
- **Animations**: 60fps on mobile devices
- **Bundle**: <500KB gzipped
- **Dashboard load**: <3s initial load

### 15. Accessibility Integration
All UI MUST:
- Support WCAG AA compliance
- Include ARIA labels for navigation
- Support keyboard navigation
- Work with screen readers (NVDA, JAWS, VoiceOver)

## Phase-Specific Integration Checklists

### Phase 0
- [ ] Document ALL existing frontend components in `/work/frontend/CURRENT_STRUCTURE.md`
- [ ] Document ALL existing backend services in `/work/backend/CURRENT_STRUCTURE.md`
- [ ] Document ALL existing infra configs in `/work/infra/CURRENT_STRUCTURE.md`

### Phase 1
- [ ] Verify extracted components integrate with existing routing
- [ ] Ensure navigation maintains Mentora brand identity
- [ ] Confirm service layer integrates with existing Azure Cosmos DB
- [ ] Validate DSL parser supports all required module types

### Phase 2
- [ ] Verify models integrate with existing database schema
- [ ] Confirm stores integrate with user journey flow tracking
- [ ] Ensure theme colors match Mentora brand palette
- [ ] Validate platform detection works for iOS/Android/Windows PWA

### Phase 3+
- [ ] Each user story component integrates with prior phase implementations
- [ ] All new endpoints maintain API contracts
- [ ] Navigation changes preserve user journey flow
- [ ] Animations meet 60fps performance target
- [ ] Theme switching works across all new components

### Phase 9 (Production Readiness)
- [ ] All components integrated with Azure infra
- [ ] User journey flow tested end-to-end
- [ ] Mobile layouts tested on iOS and Android
- [ ] Desktop layout tested on Windows PWA
- [ ] Performance targets met for all features
- [ ] Accessibility standards met
- [ ] Security measures integrated (JWT, XSS prevention)

## Integration Testing Strategy

### E2E Test Scenarios
1. **User Journey Flow**: Menu → Sign In → Welcome → Quiz → Profile → Payment → Main App
2. **Navigation Switch**: Desktop (left panel) ↔ Mobile (bottom bar) on resize
3. **Course Discovery**: Search → Filter (difficulty slider) → Results (2/3 card layout)
4. **Learning Path**: Enroll → View path → Complete module → Verify gray→color transition
5. **Theme Switch**: Toggle bright/dark → Verify all components update → Refresh → Verify persistence
6. **Admin DSL**: Create course with all module types → Verify correct rendering

### Integration Validation Checklist
- [ ] All frontend components use services from backend
- [ ] All API calls match endpoint definitions in contracts/
- [ ] All routes navigate correctly in user journey flow
- [ ] All stores persist data correctly
- [ ] All animations perform at 60fps
- [ ] All themes apply consistently
- [ ] All platform detection triggers correct layouts

## Common Integration Pitfalls to Avoid

1. ❌ **Creating duplicate components** instead of searching for existing ones
2. ❌ **Hardcoding API URLs** instead of using environment configuration
3. ❌ **Breaking existing routing** when adding new routes
4. ❌ **Ignoring user journey flow** in navigation logic
5. ❌ **Not testing on all platforms** (iOS, Android, Windows PWA)
6. ❌ **Skipping theme integration** for new components
7. ❌ **Not documenting findings** in /work/notes/ before implementation
8. ❌ **Creating new services** when existing ones can be extended
9. ❌ **Not preserving Mentora brand identity** (logo, colors, mission)
10. ❌ **Forgetting to update /work/CURRENT_STRUCTURE.md** after changes

## Success Criteria

Feature 002 integration is complete when:
- ✅ All components work seamlessly together
- ✅ User journey flow works end-to-end without breaks
- ✅ Navigation adapts correctly on all platforms
- ✅ Course discovery, enrollment, and completion flow is smooth
- ✅ Admin DSL generates courses that render correctly
- ✅ Themes switch consistently across all components
- ✅ Performance targets met (p95 <500ms, 60fps, <3s load)
- ✅ All tests pass (unit, integration, E2E)
- ✅ Production deployment works with Azure infra
- ✅ No duplicate or unused code exists
