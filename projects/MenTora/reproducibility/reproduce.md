# MenTora - Reproducibility Guide

**Goal:** Validate MenTora's PWA functionality, authentication flow, course delivery, and payment integration.

**Estimated Time:** 30-45 minutes  
**Requirements:** Node.js 20+, Python 3.11+, Modern browser

---

## 📋 Prerequisites

### 1. System Requirements
- **OS:** Windows 10+, macOS, or Linux
- **Node.js:** 20 or higher
- **Python:** 3.11+
- **Browser:** Chrome, Firefox, or Edge (latest)

### 2. Optional Services
- **Stripe Account:** For payment testing (test mode)
- **PostgreSQL:** Database (or use SQLite for demo)

---

## 🚀 Step-by-Step Reproduction

### Step 1: Clone and Setup

```bash
# Clone repository
git clone https://github.com/THEDIFY/THEDIFY.git
cd THEDIFY/projects/MenTora
```

### Step 2: Backend Setup

```bash
# Navigate to backend
cd code/backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/macOS
# .\venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt

# Set up environment variables
cp .env.example .env
# Edit .env with database and Stripe test keys

# Run database migrations
alembic upgrade head

# Start backend server
uvicorn main:app --reload --port 8000
```

**Expected Output:**
```
INFO:     Uvicorn running on http://127.0.0.1:8000
INFO:     Application startup complete
```

### Step 3: Frontend Setup

```bash
# Open new terminal
cd code/frontend

# Install dependencies
npm install

# Set up environment
cp .env.example .env
# Edit .env with API endpoint (http://localhost:8000)

# Start development server
npm run dev
```

**Expected Output:**
```
VITE v5.0.0  ready in 500 ms
➜  Local:   http://localhost:5173/
➜  Network: use --host to expose
```

### Step 4: Test User Authentication

```bash
# In browser, navigate to http://localhost:5173

# Register new user
# - Email: test@mentora.app
# - Password: TestPassword123!

# Expected: Redirect to dashboard after registration
```

### Step 5: Test Course Access

```bash
# Navigate to course catalog
# Select "Introduction to AI" (or sample course)

# Expected:
# ✅ Course content loads
# ✅ Progress bar initializes at 0%
# ✅ Interactive code editor visible
```

### Step 6: Test Interactive Features

```python
# In the in-browser code editor, type:
import numpy as np

data = np.array([1, 2, 3, 4, 5])
print(f"Mean: {data.mean()}")

# Run code (Ctrl+Enter)

# Expected output:
# Mean: 3.0
```

### Step 7: Test PWA Installation

```bash
# In Chrome/Edge:
# 1. Click address bar install icon
# 2. Click "Install"
# 3. Launch MenTora from desktop/app drawer

# Expected:
# ✅ App opens in standalone window
# ✅ Offline mode works (disable network, reload)
```

### Step 8: Test Payment Flow (Stripe Test Mode)

```bash
# Navigate to premium course
# Click "Enroll Now"

# Use Stripe test card:
# Card: 4242 4242 4242 4242
# Exp: 12/34
# CVC: 123

# Expected:
# ✅ Payment processed successfully
# ✅ Course unlocked
# ✅ Receipt email sent (check logs)
```

---

## 📊 Expected Results

### Performance Metrics

| Metric | Expected | Validation |
|--------|----------|------------|
| **Lighthouse PWA Score** | 95+ | Run `npm run lighthouse` |
| **Auth Response Time** | <500ms | Check network tab |
| **Course Load Time** | <1s | Chrome DevTools |
| **Offline Capability** | Full PWA | Disable network |

### Functional Tests

```bash
# Run automated tests
cd code/backend
pytest tests/ -v

# Expected:
# ✅ test_user_registration
# ✅ test_login_flow
# ✅ test_course_access
# ✅ test_progress_tracking
# ✅ test_payment_webhook
```

---

## 🔬 Advanced Validation

### PWA Audit

```bash
# Install Lighthouse
npm install -g lighthouse

# Run PWA audit
cd code/frontend
npm run build
npx serve -s dist -l 3000

# In new terminal
lighthouse http://localhost:3000 \
    --only-categories=pwa \
    --view

# Expected PWA score: 95+
```

### Load Testing

```bash
# Install k6 or Artillery

# Run load test (100 concurrent users)
artillery quick --count 100 --num 10 http://localhost:8000/api/courses

# Expected:
# - P95 latency: <200ms
# - Error rate: <1%
```

### Docker Reproduction

```bash
# Build and run full stack
cd code
docker-compose up -d

# Access:
# Frontend: http://localhost:3000
# Backend: http://localhost:8000
# Database: localhost:5432

# Run tests in container
docker-compose exec backend pytest
```

---

## 🐛 Troubleshooting

### Issue: Frontend Not Connecting to Backend

**Solution:**
```bash
# Check CORS settings in backend/.env
ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000

# Restart backend
uvicorn main:app --reload
```

### Issue: Stripe Webhook Failing

**Solution:**
```bash
# Use Stripe CLI for local testing
stripe listen --forward-to localhost:8000/api/webhooks/stripe

# Update .env with webhook secret
STRIPE_WEBHOOK_SECRET=whsec_...
```

### Issue: PWA Not Installing

**Solution:**
- Ensure HTTPS (or localhost)
- Check service worker registration in DevTools
- Verify manifest.json is accessible

---

## 📞 Support

**Issues?** Open at [github.com/THEDIFY/THEDIFY/issues](https://github.com/THEDIFY/THEDIFY/issues)

**Contact:** rasanti2008@gmail.com

---

## 🔐 Reproducibility Checklist

- [ ] Node.js 20+ and Python 3.11+ installed
- [ ] Backend running (http://localhost:8000)
- [ ] Frontend running (http://localhost:5173)
- [ ] User registration working
- [ ] Course content loading
- [ ] Interactive code editor functional
- [ ] PWA installable
- [ ] Payment flow tested (test mode)
- [ ] Automated tests passing

---

**Last Updated:** December 17, 2025  
**Reproducibility Version:** 1.0
