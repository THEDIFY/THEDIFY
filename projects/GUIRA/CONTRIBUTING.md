# Contributing to GUIRA

<div align="center">

![Contributing](https://img.shields.io/badge/Contributions-Welcome-success?style=for-the-badge)
![Community](https://img.shields.io/badge/Community-Friendly-blue?style=for-the-badge)

**Thank you for your interest in contributing to GUIRA!**

*Together, we're building accessible disaster prevention technology for communities worldwide.*

</div>

---

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [How Can I Contribute?](#how-can-i-contribute)
3. [Development Setup](#development-setup)
4. [Contribution Workflow](#contribution-workflow)
5. [Coding Standards](#coding-standards)
6. [Testing Guidelines](#testing-guidelines)
7. [Documentation Guidelines](#documentation-guidelines)
8. [Pull Request Process](#pull-request-process)
9. [Community Guidelines](#community-guidelines)
10. [Recognition](#recognition)

---

## Code of Conduct

### Our Pledge

In the interest of fostering an open and welcoming environment, we pledge to make participation in our project a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

### Our Standards

**Positive Behavior:**
- ✅ Using welcoming and inclusive language
- ✅ Being respectful of differing viewpoints
- ✅ Gracefully accepting constructive criticism
- ✅ Focusing on what is best for the community
- ✅ Showing empathy towards others

**Unacceptable Behavior:**
- ❌ Trolling, insulting/derogatory comments, and personal attacks
- ❌ Public or private harassment
- ❌ Publishing others' private information without permission
- ❌ Other conduct which could be considered inappropriate

### Enforcement

Instances of abusive, harassing, or otherwise unacceptable behavior may be reported by contacting the project team at rasanti2008@gmail.com. All complaints will be reviewed and investigated promptly and fairly.

---

## How Can I Contribute?

### 🐛 Reporting Bugs

**Before Submitting a Bug Report:**
1. Check the [Troubleshooting Guide](TROUBLESHOOTING.md)
2. Search existing [issues](https://github.com/THEDIFY/THEDIFY/issues)
3. Verify the bug exists in the latest version

**How to Submit a Good Bug Report:**

```markdown
### Bug Description
[Clear description of what the bug is]

### Steps to Reproduce
1. [First step]
2. [Second step]
3. [And so on...]

### Expected Behavior
[What you expected to happen]

### Actual Behavior
[What actually happened]

### Environment
- OS: [e.g., Ubuntu 22.04]
- Python: [e.g., 3.11.0]
- PyTorch: [e.g., 2.1.0]
- CUDA: [e.g., 11.8]
- GPU: [e.g., NVIDIA RTX 3080]

### Additional Context
[Screenshots, logs, or other relevant information]
```

### 💡 Suggesting Enhancements

**Enhancement Suggestions Include:**
- New AI model integrations
- Performance improvements
- New features for community protection
- UI/UX improvements
- Documentation enhancements

**Template for Feature Requests:**

```markdown
### Feature Description
[Clear description of the proposed feature]

### Problem Statement
[What problem does this solve?]

### Proposed Solution
[How should this feature work?]

### Alternatives Considered
[Other approaches you've thought about]

### Impact
[Who benefits and how?]

### Implementation Ideas
[Technical approach, if you have ideas]
```

### 📝 Contributing Code

We welcome contributions in these areas:

**AI & Machine Learning:**
- 🔬 Model architecture improvements
- 📊 Performance optimization
- 🎯 Accuracy enhancements
- 🧪 Novel techniques

**System Integration:**
- 🗺️ GIS functionality
- 📡 Satellite data processing
- ☁️ Weather API integration
- 🛰️ Drone communication

**Infrastructure:**
- 🐳 Docker improvements
- ☸️ Kubernetes optimization
- 📈 Monitoring & logging
- 🔒 Security enhancements

**Documentation:**
- 📖 Tutorials and guides
- 🌍 Translations
- 🎓 Educational content
- 📹 Video demonstrations

**Data Contribution:**
- 📸 Fire/smoke datasets
- 🌿 Vegetation imagery
- 🦌 Wildlife observations
- 🗺️ DEM data for specific regions

---

## Development Setup

### Prerequisites

```bash
# System Requirements
- Python 3.11+
- Git 2.30+
- CUDA 11.8+ (for GPU support)
- 16GB RAM minimum (32GB recommended)
```

### Fork & Clone

```bash
# 1. Fork the repository on GitHub
# Click "Fork" button at https://github.com/THEDIFY/THEDIFY

# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/THEDIFY.git
cd THEDIFY/projects/GUIRA

# 3. Add upstream remote
git remote add upstream https://github.com/THEDIFY/THEDIFY.git

# 4. Verify remotes
git remote -v
# Should show:
# origin    https://github.com/YOUR_USERNAME/THEDIFY.git (fetch)
# origin    https://github.com/YOUR_USERNAME/THEDIFY.git (push)
# upstream  https://github.com/THEDIFY/THEDIFY.git (fetch)
# upstream  https://github.com/THEDIFY/THEDIFY.git (push)
```

### Environment Setup

```bash
# 1. Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 2. Install dependencies
cd code
pip install -r requirements.txt

# 3. Install development dependencies
pip install -r requirements-dev.txt

# 4. Install pre-commit hooks
pre-commit install

# 5. Verify installation
python -c "import torch; print(f'PyTorch: {torch.__version__}')"
python -c "import torch; print(f'CUDA: {torch.cuda.is_available()}')"
```

### Development Dependencies

Create `requirements-dev.txt`:

```
# Testing
pytest>=7.4.3
pytest-cov>=4.1.0
pytest-asyncio>=0.21.0
pytest-mock>=3.12.0

# Code Quality
black>=23.12.1
ruff>=0.1.9
mypy>=1.7.1
isort>=5.13.0

# Documentation
sphinx>=7.2.0
sphinx-rtd-theme>=2.0.0
myst-parser>=2.0.0

# Git Hooks
pre-commit>=3.6.0

# Profiling
memory-profiler>=0.61.0
line-profiler>=4.1.0
```

---

## Contribution Workflow

### 1. Create a Feature Branch

```bash
# Fetch latest changes from upstream
git fetch upstream
git checkout main
git merge upstream/main

# Create feature branch
git checkout -b feature/your-feature-name

# Naming conventions:
# feature/add-thermal-detection
# fix/memory-leak-in-smoke-detector
# docs/improve-installation-guide
# refactor/optimize-geospatial-projection
```

### 2. Make Your Changes

**Follow These Principles:**
- ✅ Make small, focused changes
- ✅ Write clear commit messages
- ✅ Add tests for new functionality
- ✅ Update documentation
- ✅ Ensure code passes all checks

**Example Development Flow:**

```python
# 1. Write failing test first (TDD)
def test_fire_detection_accuracy():
    detector = FireDetector()
    image = load_test_image("test_fire.jpg")
    result = detector.detect(image)
    assert result.confidence > 0.9

# 2. Implement feature
class FireDetector:
    def detect(self, image):
        # Your implementation
        return DetectionResult(confidence=0.95)

# 3. Run tests
pytest tests/test_fire_detection.py -v

# 4. Format code
black code/
isort code/

# 5. Lint code
ruff check code/
mypy code/
```

### 3. Commit Your Changes

**Commit Message Format:**

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code formatting (no logic change)
- `refactor`: Code refactoring
- `test`: Adding/updating tests
- `chore`: Maintenance tasks
- `perf`: Performance improvements

**Examples:**

```bash
git commit -m "feat(fire-detection): add thermal image support

- Integrate thermal camera input processing
- Enhance YOLOv8 model for thermal spectrum
- Add tests for thermal detection pipeline

Closes #123"

git commit -m "fix(geospatial): correct DEM intersection algorithm

The ray-terrain intersection was failing for steep slopes.
Updated algorithm to use binary search for precision.

Fixes #456"

git commit -m "docs(readme): update installation instructions

Added troubleshooting section for CUDA installation
on Ubuntu 22.04."
```

### 4. Push to Your Fork

```bash
# Push feature branch to your fork
git push origin feature/your-feature-name
```

### 5. Open Pull Request

1. Navigate to your fork on GitHub
2. Click "Compare & pull request"
3. Fill out the PR template
4. Submit the pull request

---

## Coding Standards

### Python Style Guide

**Follow PEP 8 with These Specifics:**

```python
# Line length: 100 characters (not 79)
# Use Black for formatting
# Use type hints for all functions

# Good example:
def detect_fire(
    image: np.ndarray,
    confidence_threshold: float = 0.65,
    model: Optional[torch.nn.Module] = None,
) -> List[Detection]:
    """
    Detect fire instances in an image.
    
    Args:
        image: Input image as numpy array (H, W, C)
        confidence_threshold: Minimum confidence for detections
        model: Optional pre-loaded model (loads default if None)
    
    Returns:
        List of Detection objects with bounding boxes and scores
    
    Raises:
        ValueError: If image shape is invalid
    """
    if len(image.shape) != 3:
        raise ValueError(f"Expected 3D image, got shape {image.shape}")
    
    # Implementation...
    return detections
```

**Type Hints:**

```python
from typing import List, Dict, Optional, Union, Tuple
import numpy as np
import torch

# Use type hints everywhere
def process_detection(
    detections: List[Dict[str, Union[float, str]]],
    image_size: Tuple[int, int],
) -> np.ndarray:
    """Process detection results."""
    pass

# For complex types, use TypedDict
from typing import TypedDict

class Detection(TypedDict):
    bbox: Tuple[float, float, float, float]
    confidence: float
    class_id: int
    class_name: str
```

**Docstrings:**

Use Google-style docstrings:

```python
def calculate_risk_score(
    fire_detections: List[Detection],
    weather_data: WeatherData,
    vegetation_health: float,
) -> RiskScore:
    """
    Calculate fire risk score based on multiple factors.
    
    This function integrates fire detection results, meteorological
    conditions, and vegetation health to produce a comprehensive
    risk assessment score.
    
    Args:
        fire_detections: List of fire detection results
        weather_data: Current weather conditions including wind,
            humidity, and temperature
        vegetation_health: Normalized vegetation health score [0-1]
            where 0 is dead/dry and 1 is healthy
    
    Returns:
        RiskScore object containing:
            - overall_score: Combined risk score [0-100]
            - severity: Categorical severity (low/medium/high/critical)
            - factors: Individual factor contributions
    
    Raises:
        ValueError: If vegetation_health is outside [0, 1] range
    
    Example:
        >>> detections = [Detection(...), Detection(...)]
        >>> weather = WeatherData(wind_speed=15, humidity=30)
        >>> risk = calculate_risk_score(detections, weather, 0.3)
        >>> print(risk.severity)
        'high'
    
    Note:
        Wind speed is weighted most heavily in the calculation,
        as it's the primary factor in fire spread.
    """
    pass
```

### Code Organization

```python
# File structure:
# 1. Module docstring
# 2. Imports (stdlib, third-party, local)
# 3. Constants
# 4. Type definitions
# 5. Helper functions
# 6. Classes
# 7. Main function (if applicable)

"""
Fire detection module using YOLOv8.

This module provides the FireDetector class for real-time fire
detection in aerial imagery.
"""

# Standard library
import os
from pathlib import Path
from typing import List, Optional

# Third-party
import numpy as np
import torch
from ultralytics import YOLO

# Local imports
from utils.config import Config
from utils.visualization import draw_boxes

# Constants
DEFAULT_MODEL_PATH = Path("models/yolov8_fire.pt")
CONFIDENCE_THRESHOLD = 0.65
INPUT_SIZE = (640, 640)

# Type definitions
Detection = ...

# Helper functions
def preprocess_image(image: np.ndarray) -> torch.Tensor:
    """Preprocess image for model input."""
    pass

# Classes
class FireDetector:
    """YOLOv8-based fire detector."""
    
    def __init__(self, model_path: Optional[Path] = None):
        """Initialize detector."""
        pass
    
    def detect(self, image: np.ndarray) -> List[Detection]:
        """Detect fires in image."""
        pass
```

### Testing Standards

```python
# Use pytest for all tests
# Organize tests to mirror source structure
# tests/
#   unit/
#     test_fire_detection.py
#     test_smoke_detection.py
#   integration/
#     test_pipeline.py
#   performance/
#     test_benchmarks.py

import pytest
import numpy as np
from unittest.mock import Mock, patch

class TestFireDetector:
    """Test suite for FireDetector class."""
    
    @pytest.fixture
    def detector(self):
        """Create FireDetector instance for testing."""
        return FireDetector(model_path="models/test_model.pt")
    
    @pytest.fixture
    def sample_image(self):
        """Create sample test image."""
        return np.random.randint(0, 255, (640, 640, 3), dtype=np.uint8)
    
    def test_initialization(self, detector):
        """Test detector initializes correctly."""
        assert detector is not None
        assert detector.model is not None
    
    def test_detection_with_fire(self, detector, sample_image):
        """Test detection returns results for image with fire."""
        # Arrange
        expected_confidence = 0.95
        
        # Act
        detections = detector.detect(sample_image)
        
        # Assert
        assert len(detections) > 0
        assert detections[0].confidence >= 0.65
    
    def test_detection_empty_image(self, detector):
        """Test detection handles empty images gracefully."""
        with pytest.raises(ValueError, match="Invalid image shape"):
            detector.detect(np.array([]))
    
    @pytest.mark.parametrize("confidence,expected_count", [
        (0.5, 10),
        (0.7, 5),
        (0.9, 1),
    ])
    def test_confidence_thresholding(
        self, detector, sample_image, confidence, expected_count
    ):
        """Test different confidence thresholds."""
        detections = detector.detect(
            sample_image, confidence_threshold=confidence
        )
        assert len(detections) == expected_count
```

---

## Testing Guidelines

### Test Coverage Requirements

- **Minimum coverage:** 80% for all new code
- **Critical paths:** 95% coverage for detection and safety features
- **Documentation:** Test docstrings explaining what is tested

### Running Tests

```bash
# Run all tests
pytest tests/ -v

# Run specific test file
pytest tests/unit/test_fire_detection.py -v

# Run with coverage
pytest --cov=code tests/ --cov-report=html

# Run only fast tests (skip slow integration tests)
pytest -m "not slow" tests/

# Run performance benchmarks
pytest tests/performance/ --benchmark-only
```

### Performance Testing

```python
import pytest

@pytest.mark.benchmark
def test_fire_detection_performance(benchmark, sample_image):
    """Benchmark fire detection speed."""
    detector = FireDetector()
    
    result = benchmark(detector.detect, sample_image)
    
    # Should process at least 30 FPS on GPU
    assert result < 0.033  # 33ms per frame
```

---

## Documentation Guidelines

### Code Documentation

**Inline Comments:**
- Explain *why*, not *what*
- Use sparingly - code should be self-documenting
- Update comments when code changes

```python
# Bad
x = x + 1  # Increment x

# Good
# Adjust for 1-based indexing expected by the API
x = x + 1
```

**Module Documentation:**

```python
"""
Fire Spread Simulation Module.

This module implements a hybrid physics-neural approach to
fire spread prediction, combining cellular automata with
deep learning for accurate simulation.

The module provides:
- PhysicsBasedFireModel: Traditional CA simulation
- FireSpreadNet: Neural dynamics learner
- HybridFireSimulator: Combined approach

Example:
    >>> simulator = HybridFireSimulator()
    >>> prediction = simulator.predict(
    ...     current_state=fire_map,
    ...     weather=weather_data,
    ...     timesteps=10
    ... )
    >>> print(prediction.shape)
    (10, 256, 256)

See Also:
    - documentation/fire_spread.md for algorithm details
    - tests/test_fire_simulation.py for usage examples
"""
```

### Writing Documentation

**Update These Files When Changing Code:**
- README.md - For user-facing changes
- ARCHITECTURE.md - For architectural changes
- API documentation - For new/changed endpoints
- Inline docstrings - Always!

**Documentation Style:**
- Use clear, concise language
- Include code examples
- Add diagrams where helpful
- Keep it up-to-date

---

## Pull Request Process

### PR Checklist

Before submitting your PR, ensure:

- [ ] **Code Quality**
  - [ ] Code follows style guidelines (Black, Ruff, Mypy pass)
  - [ ] Type hints added to all functions
  - [ ] Docstrings follow Google style
  - [ ] No commented-out code
  - [ ] No debug print statements

- [ ] **Testing**
  - [ ] All existing tests pass
  - [ ] New tests added for new functionality
  - [ ] Test coverage ≥ 80%
  - [ ] Performance benchmarks pass

- [ ] **Documentation**
  - [ ] README.md updated if needed
  - [ ] Docstrings added/updated
  - [ ] CHANGELOG.md updated
  - [ ] Technical docs updated if applicable

- [ ] **Git**
  - [ ] Branch is up-to-date with main
  - [ ] Commits are squashed/organized logically
  - [ ] Commit messages follow convention
  - [ ] No merge commits (rebase instead)

- [ ] **Other**
  - [ ] PR description is clear and complete
  - [ ] Related issues are linked
  - [ ] Breaking changes are documented

### PR Template

```markdown
## Description
[Clear description of what this PR does]

## Motivation and Context
[Why is this change needed? What problem does it solve?]

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to change)
- [ ] Documentation update

## How Has This Been Tested?
[Describe the tests you ran to verify your changes]

## Screenshots (if applicable)
[Add screenshots to help explain your changes]

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Commented hard-to-understand areas
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests added that prove fix/feature works
- [ ] All tests pass locally
- [ ] Dependent changes merged

## Related Issues
Closes #[issue number]
```

### Review Process

1. **Automated Checks:** CI/CD runs automatically
2. **Code Review:** Maintainer reviews code
3. **Feedback:** Address review comments
4. **Approval:** Minimum 1 approval required
5. **Merge:** Maintainer merges after approval

**Response Times:**
- Initial response: Within 48 hours
- Full review: Within 1 week
- We appreciate your patience!

---

## Community Guidelines

### Communication Channels

- **GitHub Issues:** Bug reports, feature requests
- **GitHub Discussions:** Questions, ideas, general chat
- **Email:** rasanti2008@gmail.com for sensitive matters

### Being a Good Community Member

**Do:**
- ✅ Be respectful and constructive
- ✅ Help others when you can
- ✅ Share your knowledge
- ✅ Ask questions - there are no stupid questions
- ✅ Celebrate others' contributions

**Don't:**
- ❌ Spam or promote unrelated projects
- ❌ Demand immediate responses
- ❌ Be dismissive of others' ideas
- ❌ Share private information
- ❌ Engage in heated debates

---

## Recognition

### Contributors

All contributors are recognized in:
- README.md Contributors section
- CHANGELOG.md for their contributions
- GitHub contributors page

### Significant Contributions

Outstanding contributors may be recognized as:
- **Core Contributors:** Regular, high-quality contributions
- **Maintainers:** Trusted members helping manage the project
- **Domain Experts:** Specialists in specific areas

---

## Questions?

**Need Help?**
- 📖 Check the [Documentation](documentation/)
- 🐛 Search existing [Issues](https://github.com/THEDIFY/THEDIFY/issues)
- 💬 Start a [Discussion](https://github.com/THEDIFY/THEDIFY/discussions)
- 📧 Email us at rasanti2008@gmail.com

**First Time Contributing?**
- Read [First Contributions Guide](https://github.com/firstcontributions/first-contributions)
- Look for issues tagged `good-first-issue`
- Don't hesitate to ask for help!

---

<div align="center">

**Thank you for contributing to GUIRA!**

*Together, we're building technology that protects communities and saves lives.* 💚

<img src="https://user-images.githubusercontent.com/74038190/212284100-561aa473-3905-4a80-b561-0d28506553ee.gif" width="100%">

**Version:** 0.4.0  
**Last Updated:** December 2025

</div>
