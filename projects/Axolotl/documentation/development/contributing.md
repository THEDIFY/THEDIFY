# Contributing Guide

Thank you for your interest in contributing to Axolotl! This guide will help you understand how to contribute effectively to the project.

## Table of Contents
- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Requirements](#testing-requirements)
- [Documentation Standards](#documentation-standards)
- [Pull Request Process](#pull-request-process)
- [Issue Guidelines](#issue-guidelines)
- [Security Considerations](#security-considerations)

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for everyone, regardless of:
- Experience level
- Gender identity and expression
- Sexual orientation
- Disability
- Personal appearance
- Body size
- Race
- Ethnicity
- Age
- Religion
- Nationality

### Our Standards

**Positive behaviors**:
- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

**Unacceptable behaviors**:
- Trolling, insulting/derogatory comments, and personal or political attacks
- Public or private harassment
- Publishing others' private information without explicit permission
- Other conduct which could reasonably be considered inappropriate in a professional setting

### Enforcement

Violations may result in:
1. Warning
2. Temporary ban
3. Permanent ban

Report violations to [project maintainers].

## Getting Started

### Prerequisites

Before contributing, ensure you have:

**Required**:
- Python 3.12+
- Node.js 18+
- Git
- Docker & Docker Compose
- Basic understanding of Flask and React

**Recommended**:
- Familiarity with computer vision concepts
- Understanding of sports analytics
- Experience with AI/ML development

### Setup

1. **Fork the Repository**
   ```bash
   # Go to https://github.com/THEDIFY/axolotl
   # Click "Fork" button
   ```

2. **Clone Your Fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/axolotl.git
   cd axolotl
   ```

3. **Add Upstream Remote**
   ```bash
   git remote add upstream https://github.com/THEDIFY/axolotl.git
   ```

4. **Set Up Development Environment**
   ```bash
   # Copy environment template
   cp .env.example .env
   
   # Install Python dependencies
   pip install -r requirements.txt
   
   # Install frontend dependencies
   cd app/frontend
   npm install
   cd ../..
   
   # Start services
   docker compose up -d
   ```

5. **Verify Setup**
   ```bash
   # Run tests
   pytest tests/
   
   # Check application
   curl http://localhost:8080/health
   ```

## Development Workflow

### 1. Find or Create an Issue

**Before starting work**:
- Check existing issues for your idea
- Comment on the issue to express interest
- Wait for maintainer approval for large changes
- Create a new issue if none exists

**Issue types**:
- `bug`: Something isn't working
- `feature`: New functionality request
- `enhancement`: Improvement to existing feature
- `documentation`: Documentation improvements
- `good-first-issue`: Good for newcomers

### 2. Create a Feature Branch

```bash
# Sync with upstream
git checkout main
git pull upstream main

# Create feature branch
git checkout -b feature/descriptive-name
# or for bugs
git checkout -b fix/bug-description
```

**Branch naming conventions**:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test additions
- `chore/` - Maintenance tasks

### 3. Make Changes

**Follow these principles**:

✅ **DO**:
- Make focused, incremental changes
- Write clear, descriptive commit messages
- Add tests for new functionality
- Update documentation
- Follow coding standards
- Keep changes minimal and relevant

❌ **DON'T**:
- Mix unrelated changes in one PR
- Modify working code unnecessarily
- Remove or modify tests without good reason
- Add commented-out code
- Include debugging code
- Commit large binary files

### 4. Commit Your Changes

```bash
# Stage specific files
git add <files>

# Commit with descriptive message
git commit -m "Add feature: brief description

- Detailed point 1
- Detailed point 2
- Related issue: #123"
```

**Commit message format**:
```
<type>: <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance

**Example**:
```
feat: Add speed zone visualization to dashboard

- Add bar chart component for speed zones
- Calculate time spent in each zone
- Add color coding for zone intensity
- Update dashboard layout

Related: #456
```

### 5. Push Changes

```bash
# Push to your fork
git push origin feature/descriptive-name
```

### 6. Create Pull Request

1. Go to your fork on GitHub
2. Click "New Pull Request"
3. Select your feature branch
4. Fill out PR template completely
5. Link related issues
6. Add screenshots for UI changes
7. Request reviews from maintainers

### 7. Address Review Feedback

**When you receive feedback**:
1. Read all comments carefully
2. Ask questions if anything is unclear
3. Make requested changes
4. Push changes to same branch (PR updates automatically)
5. Respond to comments when addressed
6. Be patient and professional

## Coding Standards

### Python Code

**Style Guide**: PEP 8

**Linting**:
```bash
# Run flake8
flake8 app/backend/

# Run black formatter
black app/backend/
```

**Standards**:

```python
# ✅ GOOD
def calculate_speed(
    positions: List[Tuple[float, float]], 
    timestamps: List[float],
    fps: int = 30
) -> float:
    """
    Calculate average speed from position trajectory.
    
    Args:
        positions: List of (x, y) coordinates in meters
        timestamps: List of timestamps in seconds
        fps: Frames per second (default: 30)
    
    Returns:
        Average speed in km/h
    
    Raises:
        ValueError: If positions and timestamps length mismatch
    """
    if len(positions) != len(timestamps):
        raise ValueError("Positions and timestamps must have same length")
    
    total_distance = 0.0
    for i in range(len(positions) - 1):
        dx = positions[i+1][0] - positions[i][0]
        dy = positions[i+1][1] - positions[i][1]
        distance = np.sqrt(dx**2 + dy**2)
        total_distance += distance
    
    duration = timestamps[-1] - timestamps[0]
    speed_mps = total_distance / duration if duration > 0 else 0
    speed_kmh = speed_mps * 3.6
    
    return speed_kmh


# ❌ BAD
def calc_speed(pos, ts):
    # no docstring, unclear variable names, no type hints
    d = 0
    for i in range(len(pos)-1):
        d += np.sqrt((pos[i+1][0]-pos[i][0])**2+(pos[i+1][1]-pos[i][1])**2)
    return d/(ts[-1]-ts[0])*3.6
```

**Key points**:
- Use type hints for all function signatures
- Write comprehensive docstrings
- Use descriptive variable names
- Handle errors explicitly
- Keep functions focused and small
- Use list comprehensions appropriately
- Avoid global variables

### TypeScript/React Code

**Style Guide**: Airbnb + TypeScript

**Linting**:
```bash
cd app/frontend
npm run lint
```

**Standards**:

```typescript
// ✅ GOOD
interface SpeedMetric {
  max_speed: number
  avg_speed: number
  speed_zones: {
    walking: number
    jogging: number
    running: number
    sprinting: number
  }
}

interface SpeedChartProps {
  metrics: SpeedMetric
  unit?: 'kmh' | 'mph'
  showZones?: boolean
}

/**
 * Speed visualization chart component
 * Displays speed metrics with zone breakdown
 */
export const SpeedChart: React.FC<SpeedChartProps> = ({ 
  metrics, 
  unit = 'kmh',
  showZones = true 
}) => {
  const convertSpeed = useCallback((speed: number) => {
    return unit === 'mph' ? speed * 0.621371 : speed
  }, [unit])
  
  const chartData = useMemo(() => {
    return Object.entries(metrics.speed_zones).map(([zone, time]) => ({
      zone: zone.charAt(0).toUpperCase() + zone.slice(1),
      time,
      percentage: (time / getTotalTime(metrics.speed_zones)) * 100
    }))
  }, [metrics.speed_zones])
  
  return (
    <div className="speed-chart">
      <h3>Speed Analysis</h3>
      <div className="metrics">
        <Metric 
          label="Max Speed" 
          value={convertSpeed(metrics.max_speed)} 
          unit={unit} 
        />
        <Metric 
          label="Avg Speed" 
          value={convertSpeed(metrics.avg_speed)} 
          unit={unit} 
        />
      </div>
      {showZones && (
        <BarChart data={chartData} />
      )}
    </div>
  )
}


// ❌ BAD
// No types, no documentation, unclear logic
export const SpeedChart = ({ metrics, unit, showZones }) => {
  return (
    <div>
      <h3>Speed</h3>
      <div>{metrics.max_speed}</div>
      <div>{metrics.avg_speed}</div>
      {showZones && <BarChart data={Object.entries(metrics.speed_zones)} />}
    </div>
  )
}
```

**Key points**:
- Use TypeScript interfaces for all props
- Write JSDoc comments for complex components
- Use functional components with hooks
- Memoize expensive computations
- Use semantic HTML
- Follow React best practices
- Use Tailwind for styling

### File Organization

**New API Endpoint**:
```
1. Route: app/backend/blueprints/feature_bp.py
2. Service: app/backend/services/feature_service.py
3. Tests: tests/integration/test_feature.py
4. Docs: documentation/architecture/api-reference.md
```

**New AI Module**:
```
1. Module: src/axolotl/module_name/
   - __init__.py
   - model.py
   - utils.py
   - README.md
2. Tests: tests/unit/test_module_name.py
3. Demo: examples/demos/demo_module_name.py
4. Docs: documentation/ai-ml/module-name.md
```

**New Frontend Feature**:
```
1. Component: app/frontend/src/components/Feature.tsx
2. Types: app/frontend/src/types/feature.ts
3. Store: app/frontend/src/stores/featureStore.ts (if needed)
4. Tests: app/frontend/src/test/Feature.test.tsx
```

## Testing Requirements

### Test Coverage

All contributions must include tests:

**Required**:
- Unit tests for new functions/methods
- Integration tests for new API endpoints
- Component tests for new React components

**Test types**:

**Unit Tests** (`tests/unit/`):
```python
def test_calculate_speed():
    """Test speed calculation with known values."""
    positions = [(0, 0), (10, 0), (20, 0)]  # 10m intervals
    timestamps = [0, 1, 2]  # 1 second intervals
    
    speed = calculate_speed(positions, timestamps)
    
    # 10 m/s = 36 km/h
    assert speed == pytest.approx(36.0, rel=0.01)

def test_calculate_speed_empty():
    """Test speed calculation with empty input."""
    with pytest.raises(ValueError):
        calculate_speed([], [])
```

**Integration Tests** (`tests/integration/`):
```python
def test_scan_quick_endpoint(client):
    """Test quick scan endpoint with valid video."""
    with open('tests/data/sample_video.mp4', 'rb') as video:
        response = client.post(
            '/api/scan/quick',
            data={
                'video': video,
                'player_id': 'player_123',
                'session_type': 'training'
            },
            content_type='multipart/form-data'
        )
    
    assert response.status_code == 200
    data = response.json
    assert 'session_id' in data
    assert 'job_id' in data
```

**Frontend Tests** (`app/frontend/src/test/`):
```typescript
import { render, screen, fireEvent } from '@testing-library/react'
import { SpeedChart } from '../SpeedChart'

describe('SpeedChart', () => {
  const mockMetrics = {
    max_speed: 28.5,
    avg_speed: 24.3,
    speed_zones: {
      walking: 120,
      jogging: 300,
      running: 450,
      sprinting: 130
    }
  }
  
  it('renders speed metrics', () => {
    render(<SpeedChart metrics={mockMetrics} />)
    
    expect(screen.getByText('28.5')).toBeInTheDocument()
    expect(screen.getByText('24.3')).toBeInTheDocument()
  })
  
  it('converts to mph when specified', () => {
    render(<SpeedChart metrics={mockMetrics} unit="mph" />)
    
    // 28.5 km/h ≈ 17.7 mph
    expect(screen.getByText(/17\.7/)).toBeInTheDocument()
  })
})
```

### Running Tests

```bash
# All tests
pytest tests/

# Specific test file
pytest tests/unit/test_kpi_calculator.py

# Specific test function
pytest tests/unit/test_kpi_calculator.py::test_calculate_speed

# With coverage
pytest tests/ --cov=app.backend --cov-report=html

# Frontend tests
cd app/frontend
npm run test
```

## Documentation Standards

### Code Documentation

**Python docstrings** (Google style):
```python
def triangulate_points(
    points_2d: Dict[str, np.ndarray],
    camera_matrices: Dict[str, np.ndarray]
) -> np.ndarray:
    """
    Triangulate 3D points from multiple 2D camera views.
    
    Uses Direct Linear Transform (DLT) method to compute 3D coordinates
    from corresponding 2D points across multiple camera views.
    
    Args:
        points_2d: Dictionary mapping camera IDs to 2D point arrays
            Shape: (N, 2) where N is number of points
        camera_matrices: Dictionary mapping camera IDs to projection matrices
            Shape: (3, 4) projection matrices
    
    Returns:
        Array of 3D points in world coordinates
        Shape: (N, 3)
    
    Raises:
        ValueError: If fewer than 2 cameras provided
        ValueError: If point arrays have mismatched lengths
    
    Example:
        >>> points_2d = {
        ...     'cam1': np.array([[100, 200], [150, 250]]),
        ...     'cam2': np.array([[300, 220], [350, 270]])
        ... }
        >>> camera_matrices = {...}
        >>> points_3d = triangulate_points(points_2d, camera_matrices)
        >>> points_3d.shape
        (2, 3)
    """
```

**TypeScript JSDoc**:
```typescript
/**
 * Fetch session data from API
 * 
 * @param sessionId - Unique session identifier
 * @param includeKpis - Whether to include KPI data (default: true)
 * @returns Promise resolving to session data
 * @throws ApiError if request fails
 * 
 * @example
 * ```typescript
 * const session = await fetchSession('sess_123', true)
 * console.log(session.kpis)
 * ```
 */
async function fetchSession(
  sessionId: string, 
  includeKpis: boolean = true
): Promise<Session> {
  // ...
}
```

### README Files

Every module should have a README:

```markdown
# Module Name

Brief description of what this module does.

## Overview

Detailed explanation of the module's purpose and functionality.

## Features

- Feature 1
- Feature 2
- Feature 3

## Usage

\`\`\`python
from src.axolotl.module_name import ClassName

# Example usage
instance = ClassName()
result = instance.method(params)
\`\`\`

## API Reference

### ClassName

Brief description.

**Methods**:
- `method(param1, param2)`: Description
- `another_method()`: Description

## Technical Details

Implementation details, algorithms used, etc.

## Dependencies

- dependency1
- dependency2

## Related Documentation

- [Link to related doc](../path/to/doc.md)
```

## Pull Request Process

### Before Submitting

**Checklist**:
- [ ] Code follows style guidelines
- [ ] All tests pass
- [ ] New tests added for new functionality
- [ ] Documentation updated
- [ ] Commit messages are clear
- [ ] Branch is up to date with main
- [ ] No merge conflicts
- [ ] Security considerations addressed

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Related Issues
Fixes #123
Related to #456

## Changes Made
- Change 1
- Change 2
- Change 3

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing performed

## Screenshots (if applicable)
[Add screenshots for UI changes]

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-reviewed code
- [ ] Commented complex sections
- [ ] Updated documentation
- [ ] No new warnings
- [ ] Tests pass locally
```

### Review Process

1. **Automated Checks**: CI/CD runs automatically
2. **Code Review**: Maintainers review changes
3. **Feedback**: Address any comments or requests
4. **Approval**: Once approved, PR is merged
5. **Cleanup**: Delete feature branch after merge

## Issue Guidelines

### Creating Issues

**Bug Reports**:
```markdown
## Bug Description
Clear description of the bug

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- OS: [e.g., Ubuntu 22.04]
- Python version: [e.g., 3.12.0]
- Browser: [e.g., Chrome 118]

## Screenshots
[If applicable]

## Additional Context
[Any other relevant information]
```

**Feature Requests**:
```markdown
## Feature Description
Clear description of the proposed feature

## Use Case
Why is this feature needed?

## Proposed Solution
How would you implement this?

## Alternatives Considered
Other approaches considered

## Additional Context
[Any other relevant information]
```

## Security Considerations

### Security Best Practices

**DO**:
- Use environment variables for secrets
- Validate all user inputs
- Sanitize data before database queries
- Use parameterized queries
- Implement rate limiting
- Use HTTPS in production
- Keep dependencies updated

**DON'T**:
- Commit secrets to git
- Trust user input
- Use string concatenation for SQL
- Expose sensitive data in errors
- Store passwords in plain text
- Disable security features

### Reporting Security Issues

**DO NOT** open public issues for security vulnerabilities.

Instead:
1. Email security contact privately
2. Provide detailed description
3. Wait for acknowledgment
4. Coordinate disclosure timing

## Related Documentation

- [Newcomer Onboarding](../newcomer-onboarding.md)
- [Repository Structure](../repository-structure.md)
- [Testing Guide](testing.md)
- [Architecture Overview](../architecture/overview.md)
