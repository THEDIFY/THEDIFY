# Contributing to EDIFY

Thank you for your interest in contributing to EDIFY! We're building the future of personalized AI education, and we welcome contributions from developers, educators, researchers, and students worldwide.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Pull Request Process](#pull-request-process)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)

---

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

### Our Standards

**Positive behaviors include:**
- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

**Unacceptable behaviors include:**
- Trolling, insulting/derogatory comments, and personal or political attacks
- Public or private harassment
- Publishing others' private information without explicit permission
- Other conduct which could reasonably be considered inappropriate

### Enforcement

Instances of abusive, harassing, or otherwise unacceptable behavior may be reported by contacting the project team at rasanti2008@gmail.com. All complaints will be reviewed and investigated promptly and fairly.

---

## How Can I Contribute?

### Reporting Bugs

**Before submitting a bug report:**
- Check the [FAQ](documentation/FAQ.md) and [Troubleshooting Guide](documentation/TROUBLESHOOTING.md)
- Search existing [GitHub Issues](../../issues) to avoid duplicates
- Collect information about the bug (steps to reproduce, expected vs actual behavior)

**Submitting a bug report:**

1. Use the bug report template
2. Provide a clear, descriptive title
3. Include detailed steps to reproduce
4. Describe the expected behavior
5. Include error messages, logs, and screenshots
6. Specify your environment (OS, Python version, browser)

**Example:**

```markdown
**Bug:** RAG response latency exceeds 5 seconds for complex queries

**Steps to Reproduce:**
1. Send a multi-part question: "Explain gradient descent and how it differs from Newton's method"
2. Observe response time in browser DevTools

**Expected:** <2s response time
**Actual:** 5.2s response time

**Environment:**
- OS: macOS 14.1
- Python: 3.11.5
- Browser: Chrome 120.0
- EDIFY Version: 1.2.0
```

### Suggesting Enhancements

We love new ideas! To suggest an enhancement:

1. **Check existing feature requests** in [GitHub Discussions](../../discussions)
2. **Provide a clear use case:** Who benefits? What problem does it solve?
3. **Describe the solution:** How should it work?
4. **Consider alternatives:** What other approaches did you consider?

**Example:**

```markdown
**Feature:** Real-time collaborative study sessions

**Use Case:** Students studying together remotely want to ask questions simultaneously and see each other's answers.

**Proposed Solution:**
- WebSocket-based real-time updates
- Shared conversation context
- Multiple users in same chat session
- Color-coded messages per user

**Alternatives Considered:**
- Polling-based updates (too slow)
- Separate sessions with manual sharing (poor UX)
```

### Contributing Code

Areas where we especially welcome contributions:

- 🧠 **AI/ML:** RAG algorithm improvements, new embedding models, fine-tuning
- 🎨 **Frontend:** UI/UX enhancements, accessibility (WCAG compliance)
- 📚 **Content:** Educational materials, course templates, documentation
- 🔧 **Infrastructure:** Performance optimization, monitoring, caching
- 🌍 **Localization:** Translations, i18n improvements
- 🧪 **Testing:** Test coverage, integration tests, benchmarks
- 🐛 **Bug Fixes:** Issue resolution, edge cases

---

## Development Setup

### Prerequisites

- Python 3.11 or higher
- Node.js 18+ (for frontend, if working on UI)
- Docker and Docker Compose
- Git
- Azure account (or use mock mode)

### Initial Setup

```bash
# 1. Fork the repository on GitHub
# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/THEDIFY.git
cd THEDIFY/projects/EDIFY

# 3. Add upstream remote
git remote add upstream https://github.com/THEDIFY/THEDIFY.git

# 4. Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 5. Install dependencies
cd code
pip install -r requirements.txt
pip install -r requirements-dev.txt

# 6. Install pre-commit hooks
pre-commit install

# 7. Copy environment file
cp .env.example .env
# Edit .env with your configuration (or use USE_MOCK_DATA=true)

# 8. Run tests to verify setup
pytest tests/ -v
```

### Development Workflow

```bash
# 1. Sync your fork with upstream
git checkout main
git fetch upstream
git merge upstream/main

# 2. Create a feature branch
git checkout -b feature/my-awesome-feature

# 3. Make your changes
# Edit code, add tests, update documentation

# 4. Run tests
pytest tests/ -v
pytest --cov=app tests/ --cov-report=html

# 5. Run linters and formatters
black app/
ruff check app/
mypy app/

# 6. Commit your changes (see commit guidelines below)
git add .
git commit -m "feat: add personalized difficulty adjustment"

# 7. Push to your fork
git push origin feature/my-awesome-feature

# 8. Create Pull Request on GitHub
```

### Running Locally

```bash
# Development server with auto-reload
cd code
uvicorn app.main:app --reload --port 8000

# Access API at http://localhost:8000
# API docs at http://localhost:8000/docs

# Run with Docker
docker-compose up -d

# View logs
docker-compose logs -f api
```

---

## Coding Standards

### Python

Follow **PEP 8** with these specifics:

- **Line length:** 100 characters (not 79)
- **Imports:** Use `isort` for automatic sorting
- **Type hints:** Required for all functions
- **Docstrings:** Google style for all public functions/classes

**Example:**

```python
from typing import Optional, List
from pydantic import BaseModel


def calculate_relevance_score(
    query_embedding: List[float],
    chunk_embedding: List[float],
    learner_level: int
) -> float:
    """
    Calculate relevance score for a content chunk.
    
    Args:
        query_embedding: 384-dim query vector
        chunk_embedding: 384-dim chunk vector
        learner_level: Student skill level (1-5)
        
    Returns:
        Relevance score between 0.0 and 1.0
        
    Example:
        >>> score = calculate_relevance_score(query, chunk, level=3)
        >>> print(f"Relevance: {score:.2f}")
        Relevance: 0.87
    """
    semantic_score = cosine_similarity(query_embedding, chunk_embedding)
    difficulty_penalty = abs(chunk.difficulty - learner_level) * 0.1
    return max(0.0, semantic_score - difficulty_penalty)
```

### TypeScript

For frontend code:

- **ESLint:** Airbnb config with TypeScript
- **Prettier:** Default configuration
- **Strict mode:** Always enabled
- **Type safety:** No `any` types without justification

**Example:**

```typescript
interface LearningProfile {
  userId: string;
  subjects: string[];
  skillLevel: Record<string, 'beginner' | 'intermediate' | 'advanced'>;
  learningGoals: string[];
}

async function fetchLearningProfile(userId: string): Promise<LearningProfile> {
  const response = await fetch(`/api/users/${userId}/profile`);
  if (!response.ok) {
    throw new Error(`Failed to fetch profile: ${response.statusText}`);
  }
  return response.json();
}
```

### Code Quality Tools

**Automated checks (run before committing):**

```bash
# Format code
black app/
prettier --write frontend/

# Lint code
ruff check app/
eslint frontend/src

# Type checking
mypy app/
tsc --noEmit

# Security scanning
bandit -r app/
npm audit
```

All these checks run automatically via pre-commit hooks and CI/CD.

---

## Commit Message Guidelines

We follow **Conventional Commits** specification:

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat:** New feature
- **fix:** Bug fix
- **docs:** Documentation changes
- **style:** Code style changes (formatting, no logic change)
- **refactor:** Code refactoring (no feature or bug fix)
- **perf:** Performance improvement
- **test:** Adding or updating tests
- **chore:** Build process or auxiliary tool changes
- **ci:** CI/CD configuration changes

### Examples

```bash
# Feature
git commit -m "feat(rag): add learner-aware reranking algorithm"

# Bug fix
git commit -m "fix(auth): resolve JWT token expiration issue"

# Documentation
git commit -m "docs(api): add examples for chat endpoint"

# Performance
git commit -m "perf(cache): implement two-tier caching strategy"

# Multi-line with body
git commit -m "feat(learning): add progress prediction model

Implements time-to-mastery estimation using linear regression
on historical learning velocity data. Includes confidence intervals
and bottleneck identification.

Closes #123"
```

### Rules

- Use imperative mood ("add" not "added")
- Don't capitalize first letter of subject
- No period at end of subject
- Limit subject line to 72 characters
- Separate subject from body with blank line
- Wrap body at 100 characters
- Reference issues/PRs in footer

---

## Pull Request Process

### Before Submitting

✅ **Checklist:**
- [ ] Tests pass locally (`pytest tests/ -v`)
- [ ] Code is formatted (`black app/`)
- [ ] Linter passes (`ruff check app/`)
- [ ] Type checking passes (`mypy app/`)
- [ ] Documentation updated (if needed)
- [ ] CHANGELOG.md updated (for user-facing changes)
- [ ] Commits follow conventional commits format
- [ ] No merge conflicts with main branch

### Creating Pull Request

1. **Push to your fork**
   ```bash
   git push origin feature/my-feature
   ```

2. **Open PR on GitHub**
   - Use the Pull Request template
   - Provide clear title and description
   - Link related issues (e.g., "Closes #123")
   - Add screenshots for UI changes
   - Check "Allow edits from maintainers"

3. **PR Title Format**
   ```
   feat: add personalized difficulty adjustment
   fix: resolve citation extraction bug
   docs: update API documentation with examples
   ```

### PR Template

```markdown
## Description
[Describe what this PR does and why]

## Type of Change
- [ ] Bug fix (non-breaking change fixing an issue)
- [ ] New feature (non-breaking change adding functionality)
- [ ] Breaking change (fix or feature causing existing functionality to change)
- [ ] Documentation update

## How Has This Been Tested?
[Describe the tests you ran]

## Checklist
- [ ] Tests pass locally
- [ ] Code follows project style guidelines
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Added tests for new functionality

## Screenshots (if applicable)
[Add screenshots for UI changes]

## Related Issues
Closes #123
```

### Review Process

1. **Automated checks** run via GitHub Actions
2. **Code review** by 1-2 maintainers
3. **Feedback addressed** by contributor
4. **Approval** from at least 1 maintainer
5. **Merge** by maintainer (squash and merge)

**Review timeline:**
- Initial response: Within 48 hours
- Full review: Within 1 week
- We appreciate your patience!

---

## Testing Guidelines

### Test Structure

```
tests/
├── unit/                 # Unit tests (fast, isolated)
│   ├── test_rag_engine.py
│   ├── test_learning_engine.py
│   └── test_utils.py
├── integration/          # Integration tests (slower)
│   ├── test_api_endpoints.py
│   ├── test_database.py
│   └── test_cache.py
├── e2e/                  # End-to-end tests (slowest)
│   └── test_chat_flow.py
└── conftest.py           # Shared fixtures
```

### Writing Tests

**Unit Test Example:**

```python
import pytest
from app.services.rag_engine import calculate_relevance_score


def test_relevance_score_high_similarity():
    """Test that identical embeddings return score of 1.0"""
    embedding = [0.1, 0.2, 0.3, 0.4]
    score = calculate_relevance_score(embedding, embedding, learner_level=3)
    assert score == pytest.approx(1.0, abs=0.01)


def test_relevance_score_difficulty_penalty():
    """Test that difficulty mismatch reduces score"""
    query_emb = [0.1, 0.2, 0.3, 0.4]
    chunk_emb = [0.1, 0.2, 0.3, 0.4]  # Same, so semantic_score = 1.0
    
    # Learner level 1, chunk difficulty 5 → penalty = 0.4
    score = calculate_relevance_score(query_emb, chunk_emb, learner_level=1, chunk_difficulty=5)
    assert score == pytest.approx(0.6, abs=0.01)
```

**Integration Test Example:**

```python
import pytest
from fastapi.testclient import TestClient
from app.main import app


client = TestClient(app)


def test_chat_endpoint_returns_citations(auth_headers):
    """Test that chat endpoint returns response with citations"""
    response = client.post(
        "/api/chat",
        json={
            "query": "Explain gradient descent",
            "user_id": "test_user_123",
            "include_citations": True
        },
        headers=auth_headers
    )
    
    assert response.status_code == 200
    data = response.json()
    assert "response" in data
    assert "citations" in data["response"]
    assert len(data["response"]["citations"]) > 0
```

### Running Tests

```bash
# Run all tests
pytest tests/ -v

# Run specific test file
pytest tests/unit/test_rag_engine.py -v

# Run tests matching pattern
pytest tests/ -k "test_relevance" -v

# Run with coverage
pytest --cov=app tests/ --cov-report=html

# Run only fast tests (skip slow integration tests)
pytest tests/unit/ -v

# Run with debugging
pytest tests/ -v -s --pdb
```

### Test Coverage

**Minimum requirements:**
- New features: 90% coverage
- Bug fixes: Test for the specific bug
- Critical paths (RAG, auth): 95%+ coverage

**Check coverage:**
```bash
pytest --cov=app tests/ --cov-report=term-missing
# Opens coverage report in browser
open htmlcov/index.html
```

---

## Documentation

### When to Update Documentation

Update documentation when you:
- Add a new feature
- Change existing behavior
- Add/modify API endpoints
- Update configuration options
- Fix bugs that affect usage

### Documentation Types

**1. Code Documentation (Docstrings)**
```python
def rerank_chunks(chunks: List[Chunk], profile: LearnerProfile) -> List[Chunk]:
    """
    Rerank retrieved chunks based on learner profile.
    
    This function adjusts relevance scores by considering the learner's
    skill level, learning goals, and past interactions.
    
    Args:
        chunks: List of candidate chunks from retrieval
        profile: Learner profile with preferences and history
        
    Returns:
        Chunks sorted by personalized relevance score (descending)
        
    Example:
        >>> chunks = retrieve_chunks(query, top_k=20)
        >>> profile = load_learner_profile(user_id)
        >>> ranked = rerank_chunks(chunks, profile)
        >>> print(f"Top chunk score: {ranked[0].score:.2f}")
        Top chunk score: 0.95
    """
```

**2. API Documentation (API.md)**
- Update when adding/changing endpoints
- Include request/response examples
- Document error cases

**3. User Guide (USER_GUIDE.md)**
- Update for user-facing features
- Include screenshots/GIFs
- Write for non-technical users

**4. Architecture Documentation (ARCHITECTURE.md)**
- Update for major architectural changes
- Include diagrams (Mermaid)
- Explain design decisions

### Documentation Style

- **Clear and concise:** Short sentences, simple words
- **Examples:** Show, don't just tell
- **Screenshots:** Include visuals for UI features
- **Code snippets:** Use syntax highlighting
- **Links:** Cross-reference related docs

---

## Recognition

Contributors are recognized in several ways:

- **Contributors List:** Added to README.md
- **Release Notes:** Credited in CHANGELOG.md
- **Special Thanks:** Mentioned for significant contributions
- **Co-authorship:** Major contributions get commit co-authorship

---

## Questions?

- **General questions:** [GitHub Discussions](../../discussions)
- **Bug reports:** [GitHub Issues](../../issues)
- **Security issues:** Email rasanti2008@gmail.com (private)
- **Chat:** [Join our community](#) (link TBD)

---

## License

By contributing to EDIFY, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to democratize AI education! 🎓**

*Every contribution, no matter how small, makes a difference in providing equal educational opportunities to learners worldwide.*
