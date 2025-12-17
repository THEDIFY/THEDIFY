# Contributing to Axolotl

First off, thank you for considering contributing to Axolotl! It's people like you that make Axolotl such a great tool for democratizing football analytics.

## Table of Contents
- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Testing](#testing)
- [Documentation](#documentation)

## Code of Conduct

This project and everyone participating in it is governed by the [Code of Conduct](../../CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to rasanti2008@gmail.com.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the [issue tracker](../../issues) as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

**Bug Report Template:**

```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. See error

**Expected behavior**
A clear description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Environment:**
 - OS: [e.g. Ubuntu 22.04]
 - Python Version: [e.g. 3.11.5]
 - GPU: [e.g. NVIDIA RTX 3090]
 - CUDA Version: [e.g. 11.8]
 - Docker Version: [e.g. 20.10.21]

**Additional context**
Add any other context about the problem here.
```

### Suggesting Features

Feature suggestions are tracked as [GitHub issues](../../issues). When creating a feature request, include:

- **Clear title** - Summarize the feature in one line
- **Use case** - Explain why this feature would be useful
- **Proposed solution** - How you envision this feature working
- **Alternatives** - Any alternative solutions you've considered
- **Additional context** - Screenshots, mockups, or examples

**Feature Request Template:**

```markdown
**Is your feature request related to a problem?**
A clear description of what the problem is. Ex. I'm always frustrated when [...]

**Describe the solution you'd like**
A clear and concise description of what you want to happen.

**Describe alternatives you've considered**
A clear and concise description of any alternative solutions or features you've considered.

**Additional context**
Add any other context, screenshots, or mockups about the feature request here.
```

### Your First Code Contribution

Unsure where to begin contributing? You can start by looking through these `beginner` and `help-wanted` issues:

- [Beginner issues](../../issues?q=is%3Aissue+is%3Aopen+label%3Abeginner) - issues which should only require a few lines of code
- [Help wanted issues](../../issues?q=is%3Aissue+is%3Aopen+label%3A"help+wanted") - issues which are a bit more involved

## Development Setup

### Prerequisites

- Python 3.11+
- Node.js 18+ (for frontend)
- Docker 20.10+
- NVIDIA GPU with CUDA 11.8+ (optional but recommended)
- Git

### Initial Setup

1. **Fork the repository**
   ```bash
   # Click 'Fork' on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/THEDIFY.git
   cd THEDIFY/projects/Axolotl
   ```

2. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/THEDIFY/THEDIFY.git
   git fetch upstream
   ```

3. **Set up Python environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # Windows: venv\Scripts\activate
   
   pip install -r code/requirements.txt
   pip install -r requirements-dev.txt  # Development dependencies
   ```

4. **Install pre-commit hooks**
   ```bash
   pre-commit install
   ```

5. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your local configuration
   ```

6. **Start development services**
   ```bash
   # Option 1: Docker (recommended)
   docker compose up -d
   
   # Option 2: Manual
   redis-server &
   python app/backend/app.py
   ```

7. **Install frontend dependencies** (optional)
   ```bash
   cd app/frontend
   npm install
   npm run dev
   ```

### Keeping Your Fork Updated

```bash
# Fetch latest changes from upstream
git fetch upstream

# Merge upstream main into your local main
git checkout main
git merge upstream/main

# Push updates to your fork
git push origin main
```

## Coding Standards

### Python Code Style

We follow [PEP 8](https://pep8.org/) with some modifications:

- **Line length:** 100 characters (not 79)
- **Formatter:** Black (automatically enforced via pre-commit)
- **Linter:** Ruff (fast Python linter)
- **Type hints:** Required for all function signatures

**Example:**

```python
from typing import List, Dict, Optional
import numpy as np

def calculate_speed(
    positions: List[Dict[str, float]],
    timestamps: List[float],
    fps: int = 30
) -> Dict[str, float]:
    """
    Calculate speed metrics from position data.
    
    Args:
        positions: List of position dictionaries with 'x' and 'y' keys
        timestamps: List of timestamps in seconds
        fps: Frames per second of video (default: 30)
    
    Returns:
        Dictionary containing max_speed, avg_speed, and sprint_count
    
    Raises:
        ValueError: If positions and timestamps have different lengths
    """
    if len(positions) != len(timestamps):
        raise ValueError("Positions and timestamps must have same length")
    
    speeds = []
    for i in range(1, len(positions)):
        distance = np.sqrt(
            (positions[i]['x'] - positions[i-1]['x']) ** 2 +
            (positions[i]['y'] - positions[i-1]['y']) ** 2
        )
        time_delta = timestamps[i] - timestamps[i-1]
        speeds.append(distance / time_delta if time_delta > 0 else 0)
    
    return {
        "max_speed": max(speeds) if speeds else 0,
        "avg_speed": sum(speeds) / len(speeds) if speeds else 0,
        "sprint_count": sum(1 for s in speeds if s > 7.0)  # 7 m/s threshold
    }
```

### TypeScript/JavaScript Code Style

We use TypeScript for the frontend with strict mode enabled:

- **Formatter:** Prettier (automatically enforced)
- **Linter:** ESLint
- **Style:** Airbnb TypeScript style guide
- **Naming:** camelCase for variables/functions, PascalCase for components

**Example:**

```typescript
interface PlayerMetrics {
  playerId: string;
  sessionId: string;
  maxSpeed: number;
  avgSpeed: number;
  distanceCovered: number;
}

export const calculateAverageSpeed = (
  metrics: PlayerMetrics[]
): number => {
  if (metrics.length === 0) return 0;
  
  const totalSpeed = metrics.reduce(
    (sum, metric) => sum + metric.avgSpeed,
    0
  );
  
  return totalSpeed / metrics.length;
};

// React component example
export const MetricsCard: React.FC<{ metrics: PlayerMetrics }> = ({
  metrics
}) => {
  return (
    <div className="rounded-lg bg-white p-6 shadow-md">
      <h3 className="text-lg font-semibold">{metrics.playerId}</h3>
      <p>Max Speed: {metrics.maxSpeed.toFixed(1)} km/h</p>
      <p>Avg Speed: {metrics.avgSpeed.toFixed(1)} km/h</p>
    </div>
  );
};
```

### Code Quality Tools

```bash
# Python: Format code with Black
black src/ app/ tests/

# Python: Lint with Ruff
ruff check src/ app/ tests/

# Python: Type check with mypy
mypy src/ app/

# TypeScript: Format with Prettier
npm run format

# TypeScript: Lint with ESLint
npm run lint

# Run all quality checks
./scripts/quality_check.sh
```

## Commit Guidelines

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification.

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `ci`: CI/CD changes
- `build`: Build system changes

**Examples:**

```bash
# Feature
git commit -m "feat(detection): add YOLOv8s model support for higher accuracy"

# Bug fix
git commit -m "fix(tracking): resolve ID switching during player occlusion"

# Documentation
git commit -m "docs(api): update endpoint documentation with examples"

# Performance
git commit -m "perf(pose): optimize MediaPipe inference with batching"

# Breaking change
git commit -m "feat(api)!: change session endpoint response format

BREAKING CHANGE: Session API now returns nested metrics object instead of flat structure"
```

### Commit Best Practices

- **Atomic commits:** Each commit should represent one logical change
- **Clear messages:** Subject line should clearly describe what changed
- **Present tense:** "add feature" not "added feature"
- **Imperative mood:** "fix bug" not "fixes bug"
- **Reference issues:** Include issue number if applicable (#123)

## Pull Request Process

### Before Submitting

1. **Update from upstream**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run tests**
   ```bash
   pytest tests/ -v
   npm test
   ```

3. **Run linters**
   ```bash
   black src/ app/ tests/
   ruff check src/ app/ tests/
   npm run lint
   ```

4. **Update documentation** if you changed APIs or added features

5. **Add tests** for new features or bug fixes

### Creating the Pull Request

1. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Open PR on GitHub**
   - Use a clear, descriptive title
   - Fill out the PR template completely
   - Link related issues (Closes #123)
   - Add screenshots for UI changes
   - Request review from maintainers

### PR Template

```markdown
## Description
Brief description of what this PR does.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## How Has This Been Tested?
- [ ] Unit tests
- [ ] Integration tests
- [ ] Manual testing

## Checklist
- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] Any dependent changes have been merged and published

## Screenshots (if applicable)
Add screenshots here.

## Related Issues
Closes #issue_number
```

### Review Process

1. **Automated checks** must pass (CI/CD pipeline)
2. **Code review** by at least one maintainer
3. **Testing** on various environments
4. **Documentation review** if applicable
5. **Final approval** and merge

### After Merge

- Delete your feature branch (locally and on GitHub)
- Update your local main branch
- Celebrate! 🎉

## Testing

### Running Tests

```bash
# Run all tests
pytest tests/ -v

# Run specific test file
pytest tests/unit/test_detection.py -v

# Run tests with coverage
pytest --cov=src/axolotl --cov=app tests/

# Run tests matching pattern
pytest -k "test_yolo" -v

# Run only unit tests
pytest tests/unit/ -v

# Run only integration tests
pytest tests/integration/ -v
```

### Writing Tests

**Unit Test Example:**

```python
# tests/unit/test_detection.py

import pytest
import numpy as np
from src.axolotl.detection import YOLODetector

@pytest.fixture
def detector():
    return YOLODetector(model_name="yolov8n", device="cpu")

@pytest.fixture
def sample_image():
    return np.random.randint(0, 255, (640, 640, 3), dtype=np.uint8)

def test_detector_initialization(detector):
    assert detector is not None
    assert detector.model_name == "yolov8n"
    assert detector.device == "cpu"

def test_detect_returns_correct_format(detector, sample_image):
    results = detector.detect(sample_image)
    
    assert isinstance(results, list)
    if len(results) > 0:
        assert "bbox" in results[0]
        assert "confidence" in results[0]
        assert "class" in results[0]
        assert len(results[0]["bbox"]) == 4

def test_detect_with_invalid_image(detector):
    with pytest.raises(ValueError):
        detector.detect(None)
```

**Integration Test Example:**

```python
# tests/integration/test_video_pipeline.py

import pytest
from app.backend.services.analysis_service import AnalysisService

@pytest.mark.integration
def test_video_analysis_pipeline(test_video_path, test_db):
    service = AnalysisService(db=test_db)
    
    result = service.analyze_video(
        video_path=test_video_path,
        player_data={"name": "Test Player", "position": "midfielder"}
    )
    
    assert result["status"] == "queued"
    assert "job_id" in result
    assert "session_id" in result
```

### Test Coverage Goals

- **Overall:** >80%
- **Critical paths:** >90%
- **AI/ML modules:** >85%
- **API endpoints:** >75%

## Documentation

### Documentation Standards

- **API docs:** OpenAPI/Swagger format
- **Code comments:** Docstrings for all public functions/classes
- **User guides:** Markdown with screenshots
- **Architecture:** Mermaid diagrams

### Writing Documentation

**Python Docstrings (Google Style):**

```python
def process_video_frame(
    frame: np.ndarray,
    model: YOLODetector,
    tracker: ByteTracker
) -> Dict[str, Any]:
    """
    Process a single video frame through detection and tracking pipeline.
    
    This function takes a video frame, runs object detection to identify
    players, and tracks them across frames using ByteTrack algorithm.
    
    Args:
        frame: Input video frame as numpy array (H, W, 3)
        model: Initialized YOLO detector instance
        tracker: Initialized ByteTrack tracker instance
    
    Returns:
        Dictionary containing:
            - detections: List of detected bounding boxes
            - tracks: List of tracked objects with IDs
            - timestamp: Processing timestamp
    
    Raises:
        ValueError: If frame is None or has invalid shape
        RuntimeError: If model inference fails
    
    Example:
        >>> frame = cv2.imread("frame.jpg")
        >>> model = YOLODetector("yolov8n")
        >>> tracker = ByteTracker()
        >>> result = process_video_frame(frame, model, tracker)
        >>> print(result["tracks"])
        [{"track_id": 1, "bbox": [100, 200, 150, 300], ...}]
    """
    # Implementation
```

### Updating Documentation

When making changes:

1. **Update README.md** if you changed installation/setup
2. **Update API.md** if you modified API endpoints
3. **Update architecture docs** if you changed system design
4. **Add examples** for new features
5. **Update CHANGELOG.md** with your changes

## Questions?

If you have questions about contributing:

- **GitHub Discussions:** [Ask in Q&A](../../discussions/new?category=q-a)
- **Email:** rasanti2008@gmail.com
- **Issues:** [Open an issue](../../issues/new) for bugs or features

## Recognition

Contributors will be recognized in:
- README.md Contributors section
- CHANGELOG.md for each release
- GitHub contributors page

Thank you for contributing to Axolotl! 🙏⚽
