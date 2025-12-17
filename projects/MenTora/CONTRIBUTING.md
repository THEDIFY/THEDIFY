# Contributing to MenTora

First off, thank you for considering contributing to MenTora! It's people like you who make MenTora a great tool for democratizing AI education worldwide.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How Can I Contribute?](#how-can-i-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Code Contributions](#code-contributions)
  - [Documentation](#documentation)
- [Development Process](#development-process)
- [Coding Standards](#coding-standards)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Pull Request Process](#pull-request-process)
- [Community](#community)

---

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](../../CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to rasanti2008@gmail.com.

**Our Pledge:**
- Be respectful and inclusive
- Welcome diverse perspectives
- Focus on what's best for the community
- Show empathy towards others

---

## Getting Started

### Prerequisites

Before you begin, ensure you have:
- **Git** installed and configured
- **Python 3.11+** for backend development
- **Node.js 18+** for frontend development (when available)
- **GitHub Account** for pull requests
- **Azure Cosmos DB** account for testing (or emulator)

### Development Setup

1. **Fork the repository**
   ```bash
   # Click "Fork" button on GitHub, then:
   git clone https://github.com/YOUR_USERNAME/THEDIFY.git
   cd THEDIFY/projects/MenTora
   ```

2. **Create a branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Install dependencies**
   ```bash
   # Backend
   cd code
   pip install -r requirements.txt
   
   # Install development dependencies
   pip install pytest black ruff pytest-cov
   ```

4. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with your test database credentials
   ```

5. **Run tests**
   ```bash
   pytest
   ```

For detailed setup instructions, see [Quick Start Guide](documentation/quickstart.md).

---

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include as many details as possible:

**Use this template:**

```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots.

**Environment:**
 - OS: [e.g., Windows 11, macOS 14, Ubuntu 22.04]
 - Python Version: [e.g., 3.11.5]
 - Browser (if frontend): [e.g., Chrome 120, Safari 17]

**Additional context**
Add any other context about the problem.
```

**Label your issue:**
- `bug` - Something isn't working
- `critical` - System breaking bug
- `needs-triage` - Needs review by maintainers

---

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. Before creating one:

1. **Check the roadmap** in [STATUS.md](STATUS.md)
2. **Search existing issues** to avoid duplicates
3. **Describe the use case** clearly

**Use this template:**

```markdown
**Is your feature request related to a problem?**
A clear description of the problem. Ex. I'm always frustrated when [...]

**Describe the solution you'd like**
A clear and concise description of what you want to happen.

**Describe alternatives you've considered**
Other solutions or features you've considered.

**Additional context**
Add mockups, examples from other platforms, or technical details.

**Acceptance criteria** (optional)
- [ ] User can do X
- [ ] System responds with Y
- [ ] Performance meets Z threshold
```

**Label your issue:**
- `enhancement` - New feature or request
- `ui-ux` - User interface improvements
- `documentation` - Documentation enhancements
- `good-first-issue` - Good for newcomers

---

### Code Contributions

We welcome code contributions! Here's what we value:

**High Priority:**
- Bug fixes for reported issues
- Features from the roadmap
- Performance improvements
- Test coverage increases
- Accessibility improvements

**Lower Priority:**
- Large refactorings (discuss first)
- New features not on roadmap (discuss first)
- Breaking API changes (rarely accepted)

**Before you start coding:**
1. Comment on the issue you want to work on
2. Wait for assignment/approval from maintainers
3. Fork and create a branch
4. Follow the development process below

---

### Documentation

Documentation improvements are always welcome! Areas that need help:

- **User Guides:** Tutorials, how-tos, examples
- **API Documentation:** Endpoint descriptions, examples
- **Code Comments:** Inline documentation for complex logic
- **README Improvements:** Clarifications, corrections, examples
- **Translations:** Help us reach non-English speakers (future)

**Documentation Standards:**
- Use clear, simple language
- Include code examples
- Add screenshots for UI features
- Test all commands/code snippets
- Follow existing formatting

---

## Development Process

### 1. Design Phase

For significant changes:

1. **Create a design doc** (use template in `/documentation`)
2. **Discuss in GitHub Discussions** or issue comments
3. **Get feedback** from maintainers
4. **Refine the approach** based on input

### 2. Implementation Phase

1. **Write tests first** (TDD approach)
   ```bash
   # Create test file
   tests/test_new_feature.py
   
   # Write failing tests
   pytest tests/test_new_feature.py  # Should fail
   ```

2. **Implement the feature**
   - Follow coding standards (below)
   - Keep changes focused and minimal
   - Add inline comments for complex logic

3. **Make tests pass**
   ```bash
   pytest tests/test_new_feature.py  # Should pass
   ```

4. **Run full test suite**
   ```bash
   pytest --cov=. --cov-report=html
   ```

### 3. Quality Checks

Before committing:

```bash
# Format code
black .

# Lint code
ruff check .

# Type check (if using type hints)
mypy .

# Run all tests
pytest

# Check coverage (aim for >90%)
pytest --cov=. --cov-report=term-missing
```

### 4. Commit & Push

```bash
# Stage changes
git add .

# Commit with conventional commit message
git commit -m "feat: add course recommendation algorithm"

# Push to your fork
git push origin feature/your-feature-name
```

### 5. Create Pull Request

See [Pull Request Process](#pull-request-process) below.

---

## Coding Standards

### Python (Backend)

**Style Guide:** PEP 8 with Black formatting

**Key Principles:**
```python
# ✅ Good: Clear function names, type hints, docstrings
def calculate_course_progress(
    completed_lessons: int,
    total_lessons: int
) -> float:
    """
    Calculate course completion percentage.
    
    Args:
        completed_lessons: Number of completed lessons
        total_lessons: Total lessons in course
        
    Returns:
        Progress as percentage (0-100)
        
    Raises:
        ValueError: If total_lessons is 0
    """
    if total_lessons == 0:
        raise ValueError("Total lessons cannot be zero")
    return (completed_lessons / total_lessons) * 100


# ❌ Bad: No types, no docstring, unclear name
def calc(a, b):
    return (a / b) * 100
```

**FastAPI Best Practices:**
```python
# ✅ Good: Pydantic models, dependency injection, error handling
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

class CourseFilter(BaseModel):
    category: str | None = None
    difficulty: str | None = None

@router.get("/courses")
async def search_courses(
    filters: CourseFilter = Depends(),
    current_user: User = Depends(get_current_user)
):
    try:
        courses = await course_service.search(filters)
        return {"courses": courses}
    except Exception as e:
        logger.error(f"Course search failed: {e}")
        raise HTTPException(status_code=500, detail="Search failed")
```

**Testing Standards:**
```python
# ✅ Good: Descriptive names, arrange-act-assert, async tests
import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_course_search_filters_by_category(client: AsyncClient):
    # Arrange
    expected_category = "AI"
    
    # Act
    response = await client.get(
        "/api/v1/courses/search",
        params={"category": expected_category}
    )
    
    # Assert
    assert response.status_code == 200
    courses = response.json()["courses"]
    assert all(c["category"] == expected_category for c in courses)
```

### TypeScript/JavaScript (Frontend - when available)

**Style Guide:** Airbnb with Prettier formatting

**Component Standards:**
```typescript
// ✅ Good: TypeScript, props interface, error handling
interface CourseCardProps {
  course: Course;
  onClick: (courseId: string) => void;
}

export const CourseCard: React.FC<CourseCardProps> = ({ course, onClick }) => {
  const handleClick = () => {
    try {
      onClick(course.id);
    } catch (error) {
      console.error('Course click failed:', error);
    }
  };

  return (
    <div onClick={handleClick} className="course-card">
      <h3>{course.title}</h3>
      <p>{course.description}</p>
    </div>
  );
};
```

### General Principles

**DRY (Don't Repeat Yourself):**
- Extract repeated code into functions
- Use configuration for repeated values
- Create reusable components

**KISS (Keep It Simple, Stupid):**
- Prefer simple solutions over clever ones
- Write code for humans to read
- Avoid premature optimization

**SOLID Principles:**
- Single Responsibility: One class/function, one purpose
- Open/Closed: Open for extension, closed for modification
- Dependency Inversion: Depend on abstractions, not concretions

---

## Commit Message Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/) specification.

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only changes
- `style`: Code style changes (formatting, semicolons, etc.)
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Performance improvement
- `test`: Adding or correcting tests
- `chore`: Changes to build process or auxiliary tools

### Examples

```bash
# Feature
git commit -m "feat(courses): add category-based filtering"

# Bug fix with body
git commit -m "fix(auth): resolve JWT token expiration issue

The token was expiring too quickly due to incorrect time calculation.
Changed from seconds to milliseconds to match library expectations.

Fixes #123"

# Documentation
git commit -m "docs(readme): update installation instructions"

# Breaking change
git commit -m "feat(api): change course search endpoint format

BREAKING CHANGE: Course search now returns pagination cursor instead of page numbers.
Clients must update to use cursor-based pagination."
```

### Rules

- Use present tense ("add feature" not "added feature")
- Use imperative mood ("move cursor to..." not "moves cursor to...")
- Don't capitalize first letter
- No period at the end
- Reference issues: `Fixes #123`, `Closes #456`, `Refs #789`
- Keep first line under 72 characters
- Add body for context (optional)
- Add footer for breaking changes (mandatory)

---

## Pull Request Process

### Before Creating PR

1. **Ensure all tests pass**
   ```bash
   pytest
   ```

2. **Update documentation**
   - README if user-facing changes
   - API docs if endpoint changes
   - Docstrings for new functions

3. **Add changelog entry** (if significant)
   ```markdown
   ### Added
   - New course recommendation algorithm based on user preferences
   ```

4. **Squash/clean up commits** (if needed)
   ```bash
   git rebase -i main
   ```

### Creating the PR

1. **Use the PR template**
   - Describe what changed
   - Explain why it changed
   - Link related issues
   - Add screenshots for UI changes

2. **Title format:** Same as commit messages
   ```
   feat(courses): add category-based filtering
   ```

3. **Labels:** Add appropriate labels
   - `bug`, `enhancement`, `documentation`
   - `frontend`, `backend`, `infrastructure`
   - `needs-review`, `work-in-progress`

### PR Template

```markdown
## Description
Brief description of what this PR does.

## Related Issue
Fixes #123

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
- [ ] My code follows the style guidelines
- [ ] I have performed a self-review
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally
- [ ] Any dependent changes have been merged and published

## Screenshots (if applicable)
[Add screenshots here]
```

### Review Process

1. **Automated checks:** CI/CD must pass
2. **Code review:** At least one approval required
3. **Changes requested:** Address all feedback
4. **Approval:** Maintainer approves PR
5. **Merge:** Maintainer merges (squash merge preferred)

### After Merge

- Delete your branch (GitHub can do this automatically)
- Close related issues (if not auto-closed)
- Celebrate! 🎉

---

## Community

### Communication Channels

- **GitHub Issues:** Bug reports, feature requests
- **GitHub Discussions:** Questions, ideas, showcase
- **Email:** rasanti2008@gmail.com for private matters

### Getting Help

**Stuck on something?**
1. Check the [Quick Start Guide](documentation/quickstart.md)
2. Search existing issues
3. Ask in GitHub Discussions
4. Email the maintainer

**Response Time:**
- Issues: Within 48 hours
- PRs: Within 72 hours
- Discussions: Within 1 week

### Recognition

Contributors will be:
- Listed in README acknowledgments
- Mentioned in release notes
- Given credit in commits
- Invited to maintainer team (after consistent contributions)

---

## Questions?

If you have any questions about contributing, please:

1. Check this guide first
2. Search existing issues/discussions
3. Create a new discussion
4. Email rasanti2008@gmail.com

---

**Thank you for making MenTora better! Every contribution helps democratize AI education for learners worldwide.** 🎓💙

---

**Last Updated:** December 17, 2024  
**Maintainer:** Santiago (THEDIFY)
