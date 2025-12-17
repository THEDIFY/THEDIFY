# Integration Testing Guide - Phases 5 & 6

**Date**: 2025-11-24  
**Status**: Ready for Testing  
**Phases**: Phase 5 (Learning Path Visualization) & Phase 6 (Personalized Dashboard)

---

## Overview

This guide provides comprehensive testing scenarios for the integrated features of Phase 5 (Learning Path Visualization) and Phase 6 (Personalized Dashboard). All core functionality has been implemented and is ready for manual integration testing.

---

## Prerequisites

### Backend Setup
```bash
cd backend
# Ensure all dependencies are installed
pip install -r requirements.txt

# Start the backend server
python -m uvicorn app.main:app --reload
```

### Frontend Setup
```bash
cd frontend
# Ensure all dependencies are installed
npm install

# Start the frontend development server
npm run dev
```

### Test Data
- Ensure you have at least 2-3 test learning paths with lessons
- Ensure at least one test user with enrollments
- Use the migration script if needed:
  ```bash
  cd backend
  python scripts/generate_path_visualizations.py
  ```

---

## Phase 5 Testing: Learning Path Visualization

### Test Scenario 1: First-Time Path View
**Objective**: Verify path renders correctly for new user

1. **Setup**: Login as user with no prior progress in a course
2. **Navigate**: Go to course catalog → Select a course → View Learning Path
3. **Verify**:
   - ✅ Path visualization loads without errors
   - ✅ All lesson nodes are visible
   - ✅ First lesson is highlighted as "current"
   - ✅ Subsequent lessons show as "available" or "locked"
   - ✅ Path connectors render between nodes
   - ✅ Animations play smoothly (staggered node appearance)

**Expected Result**: Visual path displays with first lesson ready to start

---

### Test Scenario 2: Progress Overlay
**Objective**: Verify progress state correctly updates visualization

1. **Setup**: User with 3 completed lessons in a path
2. **Navigate**: Go to learning path view
3. **Verify**:
   - ✅ Completed lessons show green checkmark icons
   - ✅ Completed nodes have green color (#10B981)
   - ✅ Current lesson (4th) is highlighted in blue
   - ✅ Current lesson has pulsing animation
   - ✅ Locked lessons are grayed out
   - ✅ Locked lessons show lock icon
   - ✅ Dependencies are enforced correctly

**Expected Result**: Path accurately reflects user progress

---

### Test Scenario 3: Node Interaction
**Objective**: Test interactive elements of path nodes

1. **Navigate**: To learning path with mixed progress
2. **Test Actions**:
   - Click on completed lesson node
   - Click on current lesson node
   - Click on locked lesson node
   - Hover over various nodes
3. **Verify**:
   - ✅ Completed/current nodes navigate to lesson
   - ✅ Locked nodes don't navigate (cursor: not-allowed)
   - ✅ Hover effect scales node slightly
   - ✅ Hover shows tooltip (if implemented)
   - ✅ Click feedback is immediate

**Expected Result**: Nodes respond appropriately based on state

---

### Test Scenario 4: Responsive Behavior
**Objective**: Verify path adapts to different screen sizes

1. **Test Viewports**:
   - Desktop: ≥1024px
   - Tablet: 768-1023px
   - Mobile: <768px
2. **Verify at each size**:
   - ✅ Path scales appropriately
   - ✅ All nodes visible (may require scrolling on mobile)
   - ✅ Connectors remain aligned
   - ✅ Navigation still functional
   - ✅ Animations smooth at all sizes

**Expected Result**: Path is fully functional across all breakpoints

---

### Test Scenario 5: Progress Update Flow
**Objective**: Verify real-time progress updates

1. **Setup**: Open learning path in one tab, lesson in another
2. **Actions**:
   - Complete a lesson in lesson tab
   - Return to learning path tab
3. **Verify**:
   - ✅ Node updates to "completed" state
   - ✅ Checkmark appears
   - ✅ Next node becomes "current"
   - ✅ Progress summary updates
   - ✅ Completion percentage increases

**Expected Result**: Path reflects progress updates immediately

---

## Phase 6 Testing: Personalized Dashboard

### Test Scenario 6: New User Dashboard
**Objective**: Verify dashboard for users with no enrollments

1. **Setup**: Login as new user with no courses
2. **Navigate**: Should land on dashboard automatically
3. **Verify**:
   - ✅ Welcome message displays
   - ✅ Stats show zeros (0 lessons, 0 streak, 0 points)
   - ✅ "Getting Started" section visible
   - ✅ "Browse Courses" button works
   - ✅ Empty states for activity and achievements
   - ✅ No enrolled course cards

**Expected Result**: Dashboard encourages new user to explore

---

### Test Scenario 7: Active User Dashboard
**Objective**: Verify dashboard displays all sections correctly

1. **Setup**: Login as user with 2-3 enrolled courses
2. **Navigate**: Dashboard (should be default landing page)
3. **Verify**:
   - ✅ Welcome message includes user's name
   - ✅ Streak count displayed (if > 0)
   - ✅ DashboardStats shows accurate numbers
   - ✅ Enrolled course cards display (up to 6)
   - ✅ Progress bars show correct percentages
   - ✅ "Continue Learning" buttons visible
   - ✅ Recent activity shows last 5 lessons
   - ✅ Achievement badges display
   - ✅ Recommended courses appear

**Expected Result**: Dashboard provides complete overview of learning

---

### Test Scenario 8: Continue Learning Flow (T111)
**Objective**: Verify Continue Learning button navigation

1. **Setup**: User with partially completed course
2. **Navigate**: Dashboard
3. **Actions**:
   - Locate enrolled course card
   - Click "Continue Learning" button
4. **Verify**:
   - ✅ Button triggers API call to `/progress/{courseId}/continue`
   - ✅ Navigates to learning path viewer
   - ✅ Correct lesson/module is displayed
   - ✅ User can continue where they left off
   - ✅ Back button returns to dashboard

5. **Test Completed Course**:
   - Find 100% complete course
   - Verify "Completed" badge shows (no Continue button)

**Expected Result**: Seamless continuation of learning

---

### Test Scenario 9: Dashboard Navigation
**Objective**: Test all navigation paths from dashboard

1. **Navigate**: Dashboard
2. **Test Each Link**:
   - Click "View All" courses
   - Click activity item
   - Click recommended course
   - Click achievement badge (if has view all)
3. **Verify**:
   - ✅ Each link navigates correctly
   - ✅ Back navigation works
   - ✅ State is preserved
   - ✅ No console errors

**Expected Result**: All dashboard links functional

---

### Test Scenario 10: Responsive Dashboard
**Objective**: Verify dashboard layout at different sizes

1. **Test Viewports**:
   - Desktop: ≥1024px
   - Tablet: 768-1023px
   - Mobile: <768px
2. **Verify at each size**:
   - ✅ Grid adapts (3 cols → 2 cols → 1 col)
   - ✅ Stats cards stack appropriately
   - ✅ All content readable
   - ✅ Buttons remain accessible
   - ✅ Cards don't overflow

**Expected Result**: Dashboard fully responsive

---

## Cross-Phase Integration Testing

### Test Scenario 11: Dashboard → Learning Path Flow
**Objective**: Verify seamless navigation between phases

1. **Start**: Dashboard
2. **Actions**:
   - Click Continue Learning on a course
   - Complete a lesson in the path
   - Return to dashboard
3. **Verify**:
   - ✅ Navigation smooth
   - ✅ Progress updates on dashboard
   - ✅ Recent activity shows new completion
   - ✅ Stats increment
   - ✅ Streak continues

**Expected Result**: Phases work together seamlessly

---

### Test Scenario 12: Theme Switching
**Objective**: Verify dark mode across both phases

1. **Setup**: Ensure theme toggle accessible
2. **Navigate**: Between dashboard and learning path
3. **Actions**:
   - Toggle to dark mode
   - Navigate through both features
4. **Verify**:
   - ✅ All dashboard components update
   - ✅ Learning path visualizations update
   - ✅ Text remains readable
   - ✅ Contrast sufficient
   - ✅ Theme persists across navigation

**Expected Result**: Consistent theming across all pages

---

## Performance Testing

### Test Scenario 13: Animation Performance
**Objective**: Verify 60fps animations

1. **Tools**: Browser DevTools Performance tab
2. **Test**:
   - Navigate to learning path (observe stagger animations)
   - Navigate to dashboard (observe card animations)
   - Hover over interactive elements
3. **Verify**:
   - ✅ Frame rate stays at ~60fps
   - ✅ No jank or stuttering
   - ✅ Transitions smooth
   - ✅ No layout shifts

**Target**: Maintain 60fps throughout

---

### Test Scenario 14: Large Data Sets
**Objective**: Test with many enrollments/lessons

1. **Setup**: User with 10+ enrolled courses, 50+ lessons
2. **Navigate**: Dashboard and learning paths
3. **Verify**:
   - ✅ Dashboard loads in <3 seconds
   - ✅ Path visualization loads in <2 seconds
   - ✅ Scrolling smooth
   - ✅ No memory leaks
   - ✅ Pagination works (if implemented)

**Expected Result**: Good performance with large data

---

## Error Handling

### Test Scenario 15: Network Failures
**Objective**: Verify graceful degradation

1. **Setup**: Throttle network in DevTools
2. **Actions**:
   - Navigate to dashboard
   - Click Continue Learning
   - Load learning path
3. **Verify**:
   - ✅ Loading states display
   - ✅ Error messages clear
   - ✅ Retry buttons work
   - ✅ No crashes
   - ✅ Partial data displays when available

**Expected Result**: App remains usable with poor connection

---

## Bug Reporting Template

When filing bugs found during testing:

```markdown
**Title**: [Phase 5/6] Brief description

**Scenario**: Which test scenario (e.g., "Test Scenario 7")

**Steps to Reproduce**:
1. 
2. 
3. 

**Expected Result**:


**Actual Result**:


**Screenshots**: (if applicable)

**Environment**:
- Browser: 
- Screen Size: 
- User Type: (new/active)
```

---

## Sign-Off Checklist

Before marking phases complete:

### Phase 5
- [ ] All 5 test scenarios pass
- [ ] No critical bugs
- [ ] Responsive on all breakpoints
- [ ] Animations smooth
- [ ] Progress tracking accurate

### Phase 6
- [ ] All 10 test scenarios pass
- [ ] Continue Learning works
- [ ] Dashboard data accurate
- [ ] All navigation functional
- [ ] Responsive on all breakpoints

### Integration
- [ ] Cross-phase navigation works
- [ ] Theme switching functional
- [ ] Performance acceptable
- [ ] Error handling graceful

---

## Next Steps After Testing

1. **Document Findings**: Create summary of test results
2. **Fix Critical Bugs**: Address any blocking issues
3. **Update Tasks**: Mark T096 and T116 complete
4. **Update Summaries**: Note any changes in phase summaries
5. **Prepare for Phase 7**: Ready to proceed with theme switching

---

**Testing Start Date**: ___________  
**Testing Complete Date**: ___________  
**Tester**: ___________  
**Overall Result**: [ ] PASS [ ] FAIL (with notes)
