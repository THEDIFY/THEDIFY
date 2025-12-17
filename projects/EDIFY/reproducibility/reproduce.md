# EDIFY - Reproducibility Guide

**Goal:** Validate EDIFY's core claims: sub-2s latency, personalized RAG retrieval, and citation accuracy.

**Estimated Time:** 30-45 minutes  
**Requirements:** Python 3.11+, Azure account (or mock data), 8GB RAM

---

## 📋 Prerequisites

### 1. System Requirements
- **OS:** Linux, macOS, or Windows 10+
- **Python:** 3.11 or higher
- **RAM:** Minimum 8GB (16GB recommended)
- **Disk:** 5GB free space

### 2. Azure Services (Optional for Full Reproduction)
- Azure OpenAI API access
- Azure AI Search instance
- Azure Cosmos DB account

**Note:** Mock data is provided for testing without Azure credentials.

---

## 🚀 Step-by-Step Reproduction

### Step 1: Clone Repository

```bash
git clone https://github.com/THEDIFY/THEDIFY.git
cd THEDIFY/projects/EDIFY
```

### Step 2: Set Up Python Environment

```bash
# Create virtual environment
python -m venv venv

# Activate (Linux/macOS)
source venv/bin/activate

# Activate (Windows)
.\venv\Scripts\activate

# Install dependencies
cd code
pip install -r requirements.txt
```

### Step 3: Configure Environment Variables

```bash
# Copy example environment file
cp .env.example .env

# Edit .env with your credentials (or use mock mode)
# For mock mode, set: USE_MOCK_DATA=true
```

**Required Variables (if not using mock):**
```env
AZURE_OPENAI_ENDPOINT=your_endpoint
AZURE_OPENAI_API_KEY=your_key
AZURE_SEARCH_ENDPOINT=your_search_endpoint
AZURE_SEARCH_API_KEY=your_search_key
AZURE_COSMOS_ENDPOINT=your_cosmos_endpoint
AZURE_COSMOS_KEY=your_cosmos_key
```

### Step 4: Run Validation Tests

```bash
# Run full test suite
pytest tests/ -v

# Run specific reproducibility tests
pytest tests/test_reproducibility.py -v
```

**Expected Output:**
```
✅ test_response_latency ..................... PASSED (1.8s avg)
✅ test_citation_accuracy .................... PASSED (98.5%)
✅ test_personalization_quality .............. PASSED
✅ test_concurrent_users ..................... PASSED (1000 users)
```

### Step 5: Interactive Notebook Demo

```bash
# Launch Jupyter
jupyter notebook ../reproducibility/notebook.ipynb
```

**Notebook Contents:**
1. Load sample student profile
2. Query EDIFY with personalized questions
3. Validate response time (<2s)
4. Verify citation sources
5. Compare with baseline (non-personalized) responses

### Step 6: Run Benchmark Script

```bash
# Run performance benchmark
python benchmark.py --users 1000 --duration 300

# Expected metrics:
# - Avg Latency: <2.0s
# - P95 Latency: <3.0s
# - P99 Latency: <4.0s
# - Success Rate: >99.5%
```

---

## 📊 Expected Results

### Performance Metrics

| Metric | Expected | Tolerance |
|--------|----------|-----------|
| **Average Latency** | 1.8s | ±0.3s |
| **P95 Latency** | 2.5s | ±0.5s |
| **Citation Accuracy** | 98%+ | ±2% |
| **Concurrent Users** | 1000+ | N/A |
| **Uptime (5min test)** | 100% | -0.5% |

### Validation Checks

- ✅ Responses include personalized content based on student profile
- ✅ Citations link to correct source documents
- ✅ Multi-turn conversation maintains context
- ✅ Latency remains <2s under load
- ✅ No degradation with concurrent users (up to 1000)

---

## 🔬 Advanced Reproduction

### A/B Testing Personalization

```bash
# Compare personalized vs. generic responses
python experiments/ab_test.py --sample-size 100
```

**Expected Outcome:** Personalized responses show 30%+ improvement in relevance scores.

### Load Testing

```bash
# Install locust
pip install locust

# Run load test
locust -f load_test.py --users 5000 --spawn-rate 100
```

### Docker Reproduction

```bash
# Build image
docker build -t edify:repro .

# Run container
docker run -p 8000:8000 --env-file .env edify:repro

# Test endpoint
curl http://localhost:8000/api/query -d '{"question": "Explain RAG", "student_id": "test"}'
```

---

## 🐛 Troubleshooting

### Issue: Slow Response Times

**Solution:**
- Check network latency to Azure endpoints
- Ensure Redis cache is running: `redis-cli ping`
- Verify GPU availability (optional for faster embeddings)

### Issue: Import Errors

**Solution:**
```bash
pip install --upgrade -r requirements.txt
python -m pip check
```

### Issue: Azure Connection Errors

**Solution:**
- Verify credentials in `.env`
- Test connection: `python test_azure_connection.py`
- Use mock mode: `USE_MOCK_DATA=true`

---

## 📞 Support

**Questions?** Open an issue at [github.com/THEDIFY/THEDIFY/issues](https://github.com/THEDIFY/THEDIFY/issues)

**Contact:** rasanti2008@gmail.com

---

## 🔐 Reproducibility Checklist

- [ ] Python 3.11+ installed
- [ ] Virtual environment created
- [ ] Dependencies installed (`requirements.txt`)
- [ ] Environment variables configured
- [ ] Tests passing (`pytest tests/`)
- [ ] Notebook executed successfully
- [ ] Benchmark results within expected range
- [ ] Docker build successful (optional)

---

**Last Updated:** December 17, 2025  
**Reproducibility Version:** 1.0
