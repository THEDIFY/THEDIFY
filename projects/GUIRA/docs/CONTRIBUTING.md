# Contributing to GUIRA

Thank you for your interest in contributing to GUIRA! This project exists to protect vulnerable communities from wildfire disasters through accessible AI technology. Every contribution helps make disaster preparedness more equitable.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Features](#suggesting-features)
  - [Code Contributions](#code-contributions)
  - [Documentation](#documentation)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Community](#community)

---

## Code of Conduct

### Our Pledge

We are committed to making participation in GUIRA a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

### Our Standards

**Examples of behavior that contributes to a positive environment:**
- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

**Examples of unacceptable behavior:**
- The use of sexualized language or imagery and unwelcome sexual attention
- Trolling, insulting/derogatory comments, and personal or political attacks
- Public or private harassment
- Publishing others' private information without explicit permission
- Other conduct which could reasonably be considered inappropriate

### Enforcement

Instances of abusive, harassing, or otherwise unacceptable behavior may be reported by contacting the project maintainer at rasanti2008@gmail.com. All complaints will be reviewed and investigated promptly and fairly.

---

## How Can I Contribute?

### Reporting Bugs

**Before submitting a bug report:**
- Check the [FAQ](FAQ.md) and [Troubleshooting Guide](TROUBLESHOOTING.md)
- Search [existing issues](https://github.com/THEDIFY/THEDIFY/issues) to avoid duplicates
- Collect relevant information (logs, screenshots, system details)

**How to submit a good bug report:**

1. **Use a clear and descriptive title** that identifies the problem
2. **Describe the exact steps to reproduce** the issue
3. **Provide specific examples** (code snippets, command outputs)
4. **Describe the behavior you observed** and what you expected instead
5. **Include screenshots** if applicable
6. **Note your environment:**
   - OS and version
   - Python version
   - GDAL version
   - GPU model (if applicable)

**Bug Report Template:**

```markdown
## Bug Description
[Clear description of the bug]

## Steps to Reproduce
1. Run command X
2. Observe output Y
3. ...

## Expected Behavior
[What should have happened]

## Actual Behavior
[What actually happened]

## Environment
- OS: Ubuntu 22.04
- Python: 3.11.5
- GDAL: 3.8.0
- GPU: NVIDIA RTX 3080

## Additional Context
[Logs, screenshots, etc.]
```

### Suggesting Features

We welcome feature suggestions that align with GUIRA's mission of accessible wildfire prevention.

**Before suggesting a feature:**
- Check if it aligns with the project's core mission
- Search existing feature requests
- Consider if it's broadly useful vs. niche use case

**How to suggest a feature:**

1. **Use a clear and descriptive title**
2. **Provide a detailed description** of the proposed feature
3. **Explain the problem it solves** or value it adds
4. **Describe alternatives you've considered**
5. **Include mockups or examples** if applicable

**Feature Request Template:**

```markdown
## Feature Summary
[Brief description of the feature]

## Problem/Motivation
[What problem does this solve? Who benefits?]

## Proposed Solution
[How would this feature work?]

## Alternatives Considered
[Other approaches you thought about]

## Additional Context
[Mockups, examples, related work]
```

### Code Contributions

**Areas we're actively seeking contributions:**

**High Priority:**
- 🔥 Improve fire detection accuracy in challenging conditions (fog, smoke, low light)
- 📱 Mobile application development (React Native, Flutter)
- 🌍 Multi-language translations and internationalization
- 📊 Enhanced data visualizations and interactive dashboards
- 🧪 Additional test coverage for edge cases

**Research & Innovation:**
- 🧠 Novel AI architectures for fire prediction
- 🛰️ Integration with additional satellite data sources
- 🔬 Validation studies and benchmarking
- 📈 Performance optimization and model compression

**Documentation & Accessibility:**
- 📖 User guides, tutorials, and case studies
- 🎥 Video demonstrations and walkthroughs
- 🗺️ Real-world deployment case studies
- 🌐 Translation of documentation to other languages

### Documentation

Documentation improvements are always welcome:
- Fix typos or clarify confusing sections
- Add missing information
- Create new guides or tutorials
- Translate documentation
- Add code examples

---

## Development Setup

### Prerequisites

- Python 3.11+
- GDAL 3.8+
- PostgreSQL 15+ with PostGIS
- Redis 7.0+
- Git

### Setup Steps

```bash
# 1. Fork the repository on GitHub

# 2. Clone your fork
git clone https://github.com/YOUR-USERNAME/THEDIFY.git
cd THEDIFY/projects/GUIRA

# 3. Add upstream remote
git remote add upstream https://github.com/THEDIFY/THEDIFY.git

# 4. Create virtual environment
cd code
python3.11 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 5. Install dependencies
pip install -r requirements.txt
pip install -r requirements-dev.txt

# 6. Install pre-commit hooks
pre-commit install

# 7. Run tests to verify setup
pytest tests/ -v
```

### Development Dependencies

**Code Quality Tools:**
```txt
black>=23.12.1          # Code formatting
ruff>=0.1.9             # Fast Python linter
mypy>=1.7.1             # Static type checking
pre-commit>=3.5.0       # Git hooks for code quality
```

**Testing Tools:**
```txt
pytest>=7.4.3           # Testing framework
pytest-cov>=4.1.0       # Coverage reporting
pytest-mock>=3.12.0     # Mocking utilities
pytest-asyncio>=0.21.1  # Async testing
```

---

## Coding Standards

### Python Style Guide

We follow **PEP 8** with some modifications:

**Line Length:**
- Maximum 100 characters (not 79)
- Break before binary operators

**Imports:**
```python
# Standard library
import os
import sys

# Third-party packages
import torch
import numpy as np

# Local application
from guira.detection import FireDetector
from guira.utils import load_config
```

**Naming Conventions:**
- `snake_case` for functions and variables
- `PascalCase` for classes
- `UPPER_CASE` for constants
- Prefix private members with `_`

**Type Hints:**
```python
def detect_fire(
    image: np.ndarray,
    confidence_threshold: float = 0.85
) -> tuple[list[dict], float]:
    """
    Detect fire in image.
    
    Args:
        image: Input image as NumPy array
        confidence_threshold: Minimum confidence for detection
        
    Returns:
        Tuple of (detections, processing_time)
    """
    ...
```

### Documentation Standards

**Docstrings:**

Use Google-style docstrings for all public functions and classes:

```python
def calculate_vari(rgb_image: np.ndarray) -> np.ndarray:
    """
    Calculate Visible Atmospherically Resistant Index.
    
    The VARI index is used to assess vegetation health:
    VARI = (Green - Red) / (Green + Red - Blue + ε)
    
    Args:
        rgb_image: RGB image as numpy array with shape (H, W, 3)
        
    Returns:
        VARI index map with shape (H, W)
        
    Raises:
        ValueError: If image is not 3-channel RGB
        
    Example:
        >>> img = load_satellite_image("field.tif")
        >>> vari = calculate_vari(img)
        >>> health_risk = np.mean(vari < 0.2)
    """
    ...
```

**Comments:**
- Use comments sparingly - prefer self-documenting code
- When needed, explain *why*, not *what*
- Keep comments up-to-date with code changes

```python
# Good: Explains reasoning
# Using sigmoid instead of ReLU to ensure smooth probability gradients
activation = torch.sigmoid(logits)

# Bad: Restates what code does
# Calculate sigmoid of logits
activation = torch.sigmoid(logits)
```

### Testing Standards

**Test Structure:**
```python
# tests/unit/test_fire_detection.py

import pytest
from guira.detection import FireDetector

class TestFireDetector:
    """Test suite for fire detection functionality."""
    
    @pytest.fixture
    def detector(self):
        """Create detector instance for testing."""
        return FireDetector(model_path="models/test.pt")
    
    def test_smoke_detection_basic(self, detector):
        """Test basic smoke detection on synthetic image."""
        # Arrange
        test_image = create_synthetic_smoke_image()
        
        # Act
        detections = detector.detect(test_image)
        
        # Assert
        assert len(detections) > 0
        assert detections[0]['class'] == 'smoke'
        assert detections[0]['confidence'] > 0.85
    
    def test_edge_case_empty_image(self, detector):
        """Test detector handles empty images gracefully."""
        empty_image = np.zeros((640, 640, 3), dtype=np.uint8)
        detections = detector.detect(empty_image)
        assert len(detections) == 0
```

**Test Coverage:**
- Aim for >80% code coverage
- Focus on critical paths and edge cases
- Include integration tests for API endpoints
- Add performance benchmarks for models

### Code Formatting

**Automated Formatting:**

```bash
# Format all Python files
black code/

# Check linting
ruff check code/

# Type checking
mypy code/

# Run all checks
pre-commit run --all-files
```

---

## Commit Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/) specification.

### Commit Message Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring (no feature change or bug fix)
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `build`: Build system or dependencies changes
- `ci`: CI/CD changes
- `chore`: Other changes (maintenance, tooling)

### Examples

```bash
# Feature addition
git commit -m "feat(detection): add thermal imaging support for YOLOv8"

# Bug fix
git commit -m "fix(geospatial): resolve coordinate transformation error in DEM projection"

# Documentation
git commit -m "docs(api): add missing endpoint descriptions"

# Performance improvement
git commit -m "perf(smoke): optimize TimeSFormer inference speed by 30%"

# Breaking change
git commit -m "feat(api)!: change detection endpoint response format

BREAKING CHANGE: Detection API now returns GeoJSON instead of plain JSON.
Clients must update to parse new response format."
```

### Commit Best Practices

- **Keep commits atomic:** One logical change per commit
- **Write clear messages:** Describe what and why, not how
- **Reference issues:** Include "Fixes #123" or "Relates to #456"
- **Sign commits:** Use `git commit -s` for DCO sign-off

---

## Pull Request Process

### Before Creating a PR

**Checklist:**
- [ ] Code follows style guidelines (black, ruff pass)
- [ ] All tests pass (`pytest tests/ -v`)
- [ ] New features have tests
- [ ] Documentation is updated
- [ ] Commit messages follow convention
- [ ] Branch is up-to-date with main

### PR Workflow

**1. Create Feature Branch:**
```bash
# Update your fork
git checkout main
git pull upstream main

# Create feature branch
git checkout -b feature/amazing-feature
```

**2. Make Changes:**
```bash
# Make your changes
# Add tests
# Update documentation

# Commit changes
git add .
git commit -m "feat: add amazing feature"
```

**3. Push to Fork:**
```bash
git push origin feature/amazing-feature
```

**4. Create Pull Request:**
- Go to GitHub repository
- Click "New Pull Request"
- Select your branch
- Fill out PR template
- Link related issues

### PR Template

```markdown
## Description
[Brief description of changes]

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing performed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings
- [ ] Tests pass locally

## Related Issues
Fixes #(issue number)
Relates to #(issue number)

## Screenshots (if applicable)
[Add screenshots for UI changes]

## Additional Notes
[Any additional context]
```

### Review Process

**What to Expect:**
1. **Automated Checks:** CI/CD runs tests and linting
2. **Code Review:** Maintainer reviews code quality and design
3. **Discussion:** Questions, suggestions, requested changes
4. **Approval:** Once approved, PR will be merged

**Response Time:**
- Initial review: Within 3-5 business days
- Follow-up reviews: Within 2-3 business days

**Addressing Feedback:**
```bash
# Make requested changes
git add .
git commit -m "refactor: address review feedback"
git push origin feature/amazing-feature

# PR updates automatically
```

---

## Community

### Communication Channels

- **GitHub Issues:** Bug reports and feature requests
- **GitHub Discussions:** Questions, ideas, general discussion
- **Email:** rasanti2008@gmail.com for sensitive matters

### Getting Help

**Stuck on something?**
1. Check [Documentation](README.md)
2. Search [GitHub Issues](https://github.com/THEDIFY/THEDIFY/issues)
3. Ask in [Discussions](https://github.com/THEDIFY/THEDIFY/discussions)
4. Email maintainer

### Recognition

Contributors are recognized in several ways:
- Listed in project README
- Mentioned in release notes
- GitHub contributor badge
- Co-authorship on relevant publications (for significant contributions)

---

## License

By contributing to GUIRA, you agree that your contributions will be licensed under the MIT License.

---

## Questions?

If you have questions about contributing, please:
- Open a [Discussion](https://github.com/THEDIFY/THEDIFY/discussions)
- Email: rasanti2008@gmail.com

**Thank you for helping make wildfire prevention technology accessible to all communities!** 🔥🌍

---

*Last Updated: December 17, 2025*
