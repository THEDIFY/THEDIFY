# Axolotl Testing Guide

**Phase 7.4 - Full App Test Suite & Verification**

## Quick Start

### Run All Tests
```bash
# Make script executable (first time only)
chmod +x scripts/verify_all.sh

# Run full verification suite
./scripts/verify_all.sh
```

### Run Specific Test Suites
```bash
# Unit tests only
pytest tests/unit/ -v

# Integration tests only
pytest tests/integration/ -v -m integration

# E2E tests only
pytest tests/e2e/ -v -m e2e

# UI tests only
pytest tests/ui/ -v

# Exclude slow tests
pytest -m "not slow"
```

## Installation

### Backend Testing Dependencies
```bash
# Install Python test dependencies
pip install pytest pytest-asyncio pytest-cov pytest-timeout pytest-mock
pip install playwright  # For UI tests
pip install websocket-client socketio-client  # For WebSocket tests
pip install faker  # For test data generation

# Install Playwright browsers
playwright install chromium
```

### Frontend Testing Dependencies
```bash
cd app/frontend
npm install --save-dev \
  vitest \
  @testing-library/react \
  @testing-library/jest-dom \
  @testing-library/user-event \
  @vitest/ui
```

## Test Organization

### Directory Structure
```
tests/
├── unit/                          # Unit tests (isolated)
│   ├── test_api_endpoints.py     # API endpoint tests
│   ├── test_indexer.py           # Indexer tests
│   └── test_pairing_service.py   # Pairing service tests
├── integration/                   # Integration tests
│   ├── test_live_streaming.py    # Live streaming tests
│   └── test_pairing_and_mode_switch.py  # Pairing flow tests
├── e2e/                          # End-to-end tests
│   ├── test_full_e2e.py          # Full pipeline E2E
│   └── test_full_pipeline.py     # Existing E2E tests
├── ui/                           # UI/Frontend tests
│   └── test_visual_smoke.py      # Playwright smoke tests
├── data/                         # Test data
│   ├── sample_frames/            # Sample video frames
│   ├── sample_sessions/          # Sample sessions
│   └── mocks/                    # Mock data
└── frontend/                     # Frontend component tests
    └── ui_design.test.tsx        # Vitest component tests
```

## Test Categories

### 1. Unit Tests

**Purpose**: Test individual functions/classes in isolation

**Characteristics**:
- Fast (< 5s per test)
- No external dependencies
- Mocked I/O operations
- High coverage (>95% for critical modules)

**Example**:
```python
# tests/unit/test_pairing_service.py
def test_token_generation():
    service = PairingService()
    session = service.create_session(user_id='test', mode='3d')
    assert session['pairing_token'] is not None
    assert len(session['pairing_token']) > 20
```

**Run**:
```bash
pytest tests/unit/ -v --cov=app.backend --cov-report=html
```

### 2. Integration Tests

**Purpose**: Test interactions between components

**Characteristics**:
- Moderate speed (< 30s per test)
- May use test databases/services
- Tests component integration
- Requires setup/teardown

**Example**:
```python
# tests/integration/test_live_streaming.py
def test_three_device_streaming():
    # Start Flask app
    # Simulate 3 WebSocket clients
    # Upload frames
    # Assert 3D reconstruction
```

**Run**:
```bash
pytest tests/integration/ -v -m integration
```

### 3. E2E Tests

**Purpose**: Test complete user workflows

**Characteristics**:
- Slow (< 5 minutes per test)
- Uses full stack (backend + frontend)
- May require docker-compose
- Tests realistic scenarios

**Example**:
```python
# tests/e2e/test_full_e2e.py
def test_complete_pipeline():
    # Upload 3-camera session
    # Process: detect -> track -> triangulate
    # Index with FAISS
    # Generate feedback
    # Assert complete results
```

**Run**:
```bash
pytest tests/e2e/ -v -m e2e --timeout=300
```

### 4. UI Tests

**Purpose**: Test frontend functionality and visual regression

**Characteristics**:
- Moderate speed (< 30s per test)
- Uses headless browser (Playwright)
- Tests user interactions
- Can capture screenshots

**Example**:
```python
# tests/ui/test_visual_smoke.py
def test_dashboard_loads(page):
    page.goto('http://localhost:8080')
    expect(page.locator('h1')).to_contain_text('Dashboard')
```

**Run**:
```bash
pytest tests/ui/ -v --headed  # With browser visible
pytest tests/ui/ -v           # Headless
```

## Writing Tests

### Best Practices

1. **Use Descriptive Names**
   ```python
   # Good
   def test_token_expires_after_ttl():
       pass
   
   # Bad
   def test_token():
       pass
   ```

2. **Follow AAA Pattern** (Arrange-Act-Assert)
   ```python
   def test_session_creation():
       # Arrange
       service = PairingService()
       user_id = 'test-user'
       
       # Act
       session = service.create_session(user_id, mode='3d')
       
       # Assert
       assert session['user_id'] == user_id
       assert session['mode'] == '3d'
   ```

3. **Use Fixtures for Setup**
   ```python
   @pytest.fixture
   def app():
       app = create_app()
       app.config['TESTING'] = True
       return app
   
   def test_health_endpoint(app):
       client = app.test_client()
       response = client.get('/health')
       assert response.status_code == 200
   ```

4. **Mock External Services**
   ```python
   @patch('app.backend.services.feedback_engine.AzureOpenAIClient')
   def test_feedback_generation(mock_client):
       mock_client.return_value.generate.return_value = {
           'feedback_text': 'Great job!'
       }
       # Test code here
   ```

5. **Use Markers for Test Organization**
   ```python
   @pytest.mark.slow
   @pytest.mark.e2e
   def test_full_pipeline():
       pass
   ```

### Common Patterns

#### Testing API Endpoints
```python
def test_endpoint_with_valid_input(client):
    response = client.post('/api/endpoint', json={
        'param': 'value'
    })
    assert response.status_code == 200
    data = response.get_json()
    assert 'result' in data

def test_endpoint_with_invalid_input(client):
    response = client.post('/api/endpoint', json={})
    assert response.status_code == 400
```

#### Testing WebSocket Connections
```python
def test_websocket_connection():
    sio = socketio.Client()
    sio.connect('http://localhost:8080')
    
    # Send event
    sio.emit('test_event', {'data': 'test'})
    
    # Wait for response
    time.sleep(1)
    
    sio.disconnect()
```

#### Testing Async Functions
```python
@pytest.mark.asyncio
async def test_async_function():
    result = await async_function()
    assert result == expected_value
```

## Test Data

### Using Sample Data
```python
from pathlib import Path

TEST_DATA_DIR = Path(__file__).parent.parent / 'data'
SAMPLE_FRAMES = TEST_DATA_DIR / 'sample_frames'
SAMPLE_SESSIONS = TEST_DATA_DIR / 'sample_sessions'

def test_with_sample_video():
    video_path = SAMPLE_SESSIONS / '3cam_session' / 'cam0.mp4'
    assert video_path.exists()
    # Process video
```

### Generating Mock Data
```python
import numpy as np

def create_mock_embedding():
    return np.random.rand(1536).tolist()

def create_mock_frame():
    return np.zeros((480, 640, 3), dtype=np.uint8)
```

## CI/CD Integration

### GitHub Actions

The verification suite runs automatically on:
- Push to `main` or `develop`
- Pull requests
- Manual trigger

**Workflow**: `.github/workflows/ci.yml`

### Local CI Simulation
```bash
# Run exactly what CI runs
./scripts/verify_all.sh

# Check report
cat reports/verify_report.json | python -m json.tool
```

## Reports

### Verification Report

After running `./scripts/verify_all.sh`, check:
- **Report**: `reports/verify_report.json`
- **Coverage**: `reports/coverage.xml`
- **Logs**: `reports/logs/` (on failure)

### Coverage Report
```bash
# Generate HTML coverage report
pytest tests/unit/ --cov=app.backend --cov-report=html

# Open in browser
open htmlcov/index.html
```

### Test Results
```bash
# Generate JUnit XML report
pytest tests/ --junitxml=reports/junit.xml

# Generate HTML report
pytest tests/ --html=reports/report.html --self-contained-html
```

## Troubleshooting

### Common Issues

#### 1. Import Errors
```bash
# Ensure project root is in PYTHONPATH
export PYTHONPATH=/path/to/axolotl:$PYTHONPATH
pytest tests/
```

#### 2. WebSocket Connection Fails
```bash
# Check if backend is running
curl http://localhost:8080/health

# Start backend
cd app/backend && python app.py
```

#### 3. Playwright Not Installed
```bash
# Install Playwright browsers
playwright install chromium
```

#### 4. FAISS Not Available
```bash
# Install FAISS
pip install faiss-cpu  # or faiss-gpu
```

#### 5. Tests Timeout
```bash
# Increase timeout
pytest tests/ --timeout=300
```

### Debug Mode

Run tests with debug output:
```bash
# Verbose mode
pytest tests/ -vv

# Show print statements
pytest tests/ -s

# Show local variables on failure
pytest tests/ -l

# Drop into debugger on failure
pytest tests/ --pdb
```

## Environment Variables

### Testing Configuration

Create `.env.test`:
```bash
# Backend
FLASK_ENV=testing
SECRET_KEY=test-secret-key

# Azure (for integration tests)
AZURE_OPENAI_ENDPOINT=https://test.openai.azure.com
AZURE_OPENAI_KEY=test-key

# Local Edge
LOCAL_HOST=localhost
LOCAL_PORT=8080

# Pairing
PAIRING_SECRET=test-pairing-secret
PAIRING_TOKEN_EXPIRY=600
```

Load in tests:
```python
from dotenv import load_dotenv
load_dotenv('.env.test')
```

## Performance Testing

### Load Testing (Optional)
```bash
# Install locust
pip install locust

# Run load test
locust -f tests/performance/test_load.py --host=http://localhost:8080
```

## Continuous Integration

### Pre-commit Checks
```bash
# Install pre-commit hooks
pip install pre-commit
pre-commit install

# Run manually
pre-commit run --all-files
```

### Merge Requirements
Before merging:
- ✅ All tests pass
- ✅ Coverage >= 95% for critical modules
- ✅ No linting errors
- ✅ UI smoke tests pass
- ✅ Verification report status = "pass"

## Additional Resources

- **pytest docs**: https://docs.pytest.org/
- **Playwright Python**: https://playwright.dev/python/
- **Flask Testing**: https://flask.palletsprojects.com/en/latest/testing/
- **Vitest**: https://vitest.dev/

## Support

For issues or questions:
1. Check `docs/TESTING_INFRASTRUCTURE.md` for architecture details
2. Review test examples in `tests/`
3. Check CI logs in GitHub Actions
4. Consult verification report: `reports/verify_report.json`
