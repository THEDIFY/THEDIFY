# 🔧 MenTora Troubleshooting Guide

This guide helps you diagnose and resolve common issues with MenTora. If you can't find your issue here, please [open a GitHub issue](https://github.com/THEDIFY/THEDIFY/issues).

---

## Table of Contents

- [Installation Issues](#installation-issues)
- [Backend Issues](#backend-issues)
- [Database Issues](#database-issues)
- [Authentication Issues](#authentication-issues)
- [API Issues](#api-issues)
- [Performance Issues](#performance-issues)
- [Payment Issues](#payment-issues)
- [Deployment Issues](#deployment-issues)
- [Getting Help](#getting-help)

---

## Installation Issues

### Issue: `pip install` fails with dependency conflicts

**Symptoms:**
```
ERROR: Cannot install package-a and package-b because these package versions have conflicting dependencies.
```

**Solutions:**

1. **Use a virtual environment:**
   ```bash
   python -m venv venv
   source venv/bin/activate  # Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

2. **Upgrade pip:**
   ```bash
   pip install --upgrade pip setuptools wheel
   pip install -r requirements.txt
   ```

3. **Install specific versions:**
   ```bash
   pip install fastapi==0.109.0 uvicorn==0.27.0
   ```

---

### Issue: `ModuleNotFoundError: No module named 'X'`

**Symptoms:**
```
ModuleNotFoundError: No module named 'fastapi'
```

**Solutions:**

1. **Ensure virtual environment is activated:**
   ```bash
   which python  # Should point to venv/bin/python
   pip list      # Should show installed packages
   ```

2. **Reinstall requirements:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Check Python version:**
   ```bash
   python --version  # Should be 3.11+
   ```

---

### Issue: Wrong Python version

**Symptoms:**
```
Python 3.8 is required, but you have Python 3.7
```

**Solutions:**

1. **Install Python 3.11:**
   - **Windows:** Download from [python.org](https://www.python.org/downloads/)
   - **macOS:** `brew install python@3.11`
   - **Linux:** `sudo apt install python3.11`

2. **Use specific Python version:**
   ```bash
   python3.11 -m venv venv
   source venv/bin/activate
   ```

---

## Backend Issues

### Issue: `uvicorn` command not found

**Symptoms:**
```bash
$ uvicorn main:app
command not found: uvicorn
```

**Solutions:**

1. **Install uvicorn:**
   ```bash
   pip install uvicorn[standard]
   ```

2. **Run as module:**
   ```bash
   python -m uvicorn main:app --reload
   ```

3. **Check PATH:**
   ```bash
   which uvicorn  # Should show venv/bin/uvicorn
   ```

---

### Issue: Server starts but returns 404 for all endpoints

**Symptoms:**
```bash
$ curl http://localhost:8000/health
404 Not Found
```

**Solutions:**

1. **Check main file structure:**
   ```python
   # main.py should have:
   from fastapi import FastAPI
   app = FastAPI()
   
   @app.get("/health")
   async def health():
       return {"status": "healthy"}
   ```

2. **Check console output:**
   ```
   INFO:     Application startup complete.
   INFO:     Uvicorn running on http://127.0.0.1:8000
   ```

3. **Verify correct port:**
   ```bash
   curl http://localhost:8000/docs  # Should show Swagger UI
   ```

---

### Issue: ModuleNotFoundError with relative imports

**Symptoms:**
```
ModuleNotFoundError: No module named 'app.models'
```

**Solutions:**

1. **Run from project root:**
   ```bash
   cd /path/to/MenTora/code
   uvicorn main:app --reload
   ```

2. **Add `__init__.py` files:**
   ```bash
   touch app/__init__.py
   touch app/models/__init__.py
   touch app/routes/__init__.py
   ```

3. **Set PYTHONPATH:**
   ```bash
   export PYTHONPATH="${PYTHONPATH}:$(pwd)"
   uvicorn main:app --reload
   ```

---

## Database Issues

### Issue: Cannot connect to Cosmos DB

**Symptoms:**
```
ERROR: Failed to connect to Cosmos DB
azure.cosmos.exceptions.CosmosHttpResponseError: (Unauthorized) The input authorization token can't serve the request.
```

**Solutions:**

1. **Verify credentials:**
   ```bash
   # Check .env file
   cat .env | grep COSMOS_DB
   
   # Should show:
   COSMOS_DB_ENDPOINT=https://your-account.documents.azure.com:443/
   COSMOS_DB_KEY=your-primary-key
   ```

2. **Test connection manually:**
   ```python
   from azure.cosmos import CosmosClient
   
   endpoint = "https://your-account.documents.azure.com:443/"
   key = "your-key"
   
   client = CosmosClient(endpoint, key)
   print("Connected successfully!")
   ```

3. **Check firewall rules:**
   - Go to Azure Portal → Cosmos DB → Firewall and virtual networks
   - Add your IP address or enable "Allow access from Azure Portal"

4. **Verify endpoint format:**
   - Must include `:443/` at the end
   - Must start with `https://`

---

### Issue: High RU consumption

**Symptoms:**
```
WARNING: Query consumed 50 RUs
```

**Solutions:**

1. **Add composite indexes:**
   ```json
   {
     "compositeIndexes": [
       [
         {"path": "/category", "order": "ascending"},
         {"path": "/difficulty", "order": "ascending"}
       ]
     ]
   }
   ```

2. **Use pagination:**
   ```python
   # Bad: Fetch all items
   items = list(container.read_all_items())
   
   # Good: Use pagination
   items = container.query_items(
       query="SELECT * FROM c",
       max_item_count=20
   )
   ```

3. **Optimize queries:**
   ```python
   # Bad: Fetch all, filter in Python
   all_courses = container.read_all_items()
   ai_courses = [c for c in all_courses if c["category"] == "AI"]
   
   # Good: Filter in query
   ai_courses = container.query_items(
       query="SELECT * FROM c WHERE c.category = 'AI'"
   )
   ```

---

### Issue: Database items not found

**Symptoms:**
```
ERROR: Item not found with id: course_001
```

**Solutions:**

1. **Verify partition key:**
   ```python
   # If partition key is /id:
   item = container.read_item(
       item="course_001",
       partition_key="course_001"  # Must match item ID
   )
   ```

2. **Check database and container names:**
   ```python
   database = client.get_database_client("mentora-prod")
   container = database.get_container_client("courses")
   ```

3. **Verify data exists:**
   ```python
   # List all items
   items = list(container.read_all_items())
   print(f"Found {len(items)} items")
   ```

---

## Authentication Issues

### Issue: JWT token invalid or expired

**Symptoms:**
```
401 Unauthorized: Token has expired
```

**Solutions:**

1. **Get a new token:**
   ```bash
   curl -X POST http://localhost:8000/api/v1/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email":"user@example.com","password":"password"}'
   ```

2. **Check token expiration:**
   ```python
   from jose import jwt
   import os
   
   token = "your-token-here"
   secret = os.getenv("JWT_SECRET_KEY")
   
   try:
       payload = jwt.decode(token, secret, algorithms=["HS256"])
       print(f"Token valid until: {payload['exp']}")
   except jwt.ExpiredSignatureError:
       print("Token expired")
   except jwt.JWTError as e:
       print(f"Invalid token: {e}")
   ```

3. **Verify JWT_SECRET_KEY:**
   ```bash
   # .env file must have:
   JWT_SECRET_KEY=your-secret-key-here
   
   # Should be at least 32 characters
   ```

---

### Issue: Google OAuth fails

**Symptoms:**
```
ERROR: Invalid Google OAuth token
```

**Solutions:**

1. **Verify Google credentials:**
   ```bash
   # Check .env
   GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
   GOOGLE_CLIENT_SECRET=your-client-secret
   ```

2. **Check redirect URI:**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - APIs & Services → Credentials
   - Add `http://localhost:8000/auth/google/callback` to authorized redirect URIs

3. **Test OAuth flow:**
   ```bash
   # Should redirect to Google login
   curl -L http://localhost:8000/auth/google
   ```

---

### Issue: Password validation fails

**Symptoms:**
```
422 Unprocessable Entity: Password must be at least 8 characters
```

**Solutions:**

1. **Meet password requirements:**
   - Minimum 8 characters
   - At least one uppercase letter
   - At least one lowercase letter
   - At least one number
   - Special characters recommended

2. **Example valid passwords:**
   ```
   ValidPass1!
   SecureP@ssw0rd
   MyP@ssw0rd2024
   ```

---

## API Issues

### Issue: CORS errors in browser

**Symptoms:**
```
Access to fetch at 'http://localhost:8000/api/v1/courses' from origin 'http://localhost:3000' has been blocked by CORS policy
```

**Solutions:**

1. **Configure CORS in FastAPI:**
   ```python
   from fastapi.middleware.cors import CORSMiddleware
   
   app.add_middleware(
       CORSMiddleware,
       allow_origins=["http://localhost:3000", "http://localhost:5173"],
       allow_credentials=True,
       allow_methods=["*"],
       allow_headers=["*"],
   )
   ```

2. **Set in environment:**
   ```bash
   ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173
   ```

3. **Verify middleware is added:**
   ```bash
   # Check server logs on startup
   INFO:     CORS middleware configured with origins: ['http://localhost:3000']
   ```

---

### Issue: 422 Unprocessable Entity errors

**Symptoms:**
```json
{
  "detail": [
    {
      "loc": ["body", "email"],
      "msg": "value is not a valid email address",
      "type": "value_error.email"
    }
  ]
}
```

**Solutions:**

1. **Check request format:**
   ```bash
   # Bad: Missing required fields
   curl -X POST http://localhost:8000/api/v1/auth/register \
     -H "Content-Type: application/json" \
     -d '{"email":"test@example.com"}'
   
   # Good: All required fields
   curl -X POST http://localhost:8000/api/v1/auth/register \
     -H "Content-Type: application/json" \
     -d '{"email":"test@example.com","password":"SecureP@ss1","name":"Test User","agree_to_terms":true}'
   ```

2. **Verify data types:**
   ```json
   {
     "enrollment_count": 5,      // ✅ Number
     "enrollment_count": "5"     // ❌ String (should be number)
   }
   ```

3. **Check enum values:**
   ```json
   {
     "difficulty": "Beginner"    // ✅ Valid enum
     "difficulty": "Easy"        // ❌ Invalid enum value
   }
   ```

---

### Issue: Rate limit exceeded

**Symptoms:**
```
429 Too Many Requests: Rate limit exceeded. Try again in 45 seconds.
```

**Solutions:**

1. **Wait for reset:**
   ```bash
   # Check X-RateLimit-Reset header
   curl -I http://localhost:8000/api/v1/courses
   
   # X-RateLimit-Reset: 1702819200  (Unix timestamp)
   ```

2. **Reduce request frequency:**
   ```javascript
   // Add debouncing to search
   const debouncedSearch = debounce(searchCourses, 300);
   ```

3. **Use batch endpoints:**
   ```bash
   # Bad: Multiple requests
   curl http://localhost:8000/api/v1/courses/1
   curl http://localhost:8000/api/v1/courses/2
   curl http://localhost:8000/api/v1/courses/3
   
   # Good: Single batch request
   curl http://localhost:8000/api/v1/courses/batch?ids=1,2,3
   ```

---

## Performance Issues

### Issue: Slow API responses

**Symptoms:**
- Requests take > 2 seconds
- Timeout errors

**Solutions:**

1. **Check database queries:**
   ```python
   import time
   
   start = time.time()
   items = container.query_items(query="SELECT * FROM c")
   items_list = list(items)  # Force execution
   elapsed = time.time() - start
   print(f"Query took {elapsed:.2f}s")
   ```

2. **Add database indexes:**
   - See [Database Issues](#database-issues) → High RU consumption

3. **Use caching:**
   ```python
   from functools import lru_cache
   
   @lru_cache(maxsize=100)
   def get_course(course_id: str):
       return container.read_item(course_id, course_id)
   ```

4. **Enable Redis caching:**
   ```bash
   # .env
   REDIS_URL=redis://localhost:6379
   ```

---

### Issue: Memory errors

**Symptoms:**
```
MemoryError: Unable to allocate array
```

**Solutions:**

1. **Use pagination:**
   ```python
   # Bad: Load all items
   all_items = list(container.read_all_items())
   
   # Good: Use pagination
   page_iterator = container.query_items(
       query="SELECT * FROM c",
       max_item_count=20
   )
   for page in page_iterator.by_page():
       for item in page:
           process(item)
   ```

2. **Increase container memory:**
   ```bash
   # Docker
   docker run --memory=4g mentora-backend
   
   # Azure Container Instances
   az container create --memory 4
   ```

---

## Payment Issues

### Issue: Stripe payment fails

**Symptoms:**
```
ERROR: Payment failed: Card declined
```

**Solutions:**

1. **Use test cards:**
   - Success: `4242 4242 4242 4242`
   - Decline: `4000 0000 0000 0002`
   - See [Stripe test cards](https://stripe.com/docs/testing)

2. **Verify webhook signature:**
   ```python
   import stripe
   
   endpoint_secret = os.getenv("STRIPE_WEBHOOK_SECRET")
   
   try:
       event = stripe.Webhook.construct_event(
           payload, sig_header, endpoint_secret
       )
   except ValueError:
       print("Invalid payload")
   except stripe.error.SignatureVerificationError:
       print("Invalid signature")
   ```

3. **Check Stripe keys:**
   ```bash
   # Test mode
   STRIPE_SECRET_KEY=sk_test_...
   STRIPE_PUBLISHABLE_KEY=pk_test_...
   
   # Production mode
   STRIPE_SECRET_KEY=sk_live_...
   STRIPE_PUBLISHABLE_KEY=pk_live_...
   ```

---

### Issue: Webhook not receiving events

**Symptoms:**
- Payments succeed but subscriptions not activated
- No webhook logs in Stripe dashboard

**Solutions:**

1. **Test webhook locally:**
   ```bash
   # Install Stripe CLI
   stripe listen --forward-to localhost:8000/webhooks/stripe
   
   # Trigger test event
   stripe trigger checkout.session.completed
   ```

2. **Verify webhook endpoint:**
   ```bash
   # Should return 200 OK
   curl -X POST http://localhost:8000/webhooks/stripe \
     -H "Content-Type: application/json" \
     -d '{"type":"checkout.session.completed"}'
   ```

3. **Check Stripe dashboard:**
   - Go to Developers → Webhooks
   - Verify endpoint URL is correct
   - Check Recent events for errors

---

## Deployment Issues

### Issue: Container fails to start

**Symptoms:**
```
ERROR: Container exited with code 1
```

**Solutions:**

1. **Check container logs:**
   ```bash
   # Docker
   docker logs mentora-backend
   
   # Azure
   az container logs --name mentora-api --resource-group mentora-prod-rg
   ```

2. **Verify environment variables:**
   ```bash
   # List environment variables
   docker exec mentora-backend env
   ```

3. **Test locally:**
   ```bash
   docker run -it --entrypoint /bin/bash mentora-backend
   # Inside container:
   python -c "import sys; print(sys.version)"
   uvicorn main:app --host 0.0.0.0 --port 8000
   ```

---

### Issue: SSL certificate errors

**Symptoms:**
```
SSL: CERTIFICATE_VERIFY_FAILED
```

**Solutions:**

1. **Update certificates:**
   ```bash
   # Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install ca-certificates
   
   # macOS
   /Applications/Python\ 3.11/Install\ Certificates.command
   ```

2. **Disable SSL verification (DEVELOPMENT ONLY):**
   ```python
   import ssl
   ssl._create_default_https_context = ssl._create_unverified_context
   ```

---

## Getting Help

### Before Asking for Help

1. **Check this guide** for your specific issue
2. **Search existing issues** on GitHub
3. **Review logs** for error messages
4. **Try in a clean environment** (new virtual environment)

### How to Ask for Help

When creating an issue, include:

1. **Environment information:**
   ```bash
   python --version
   pip list
   uname -a  # Linux/macOS
   systeminfo  # Windows
   ```

2. **Error messages:**
   - Copy full error output
   - Include stack traces
   - Attach relevant logs

3. **Steps to reproduce:**
   - Minimal example that causes the issue
   - What you expected vs what happened

4. **What you've tried:**
   - Solutions from this guide
   - Other troubleshooting steps

### Contact Options

- **GitHub Issues:** [Create issue](https://github.com/THEDIFY/THEDIFY/issues/new)
- **Email:** rasanti2008@gmail.com
- **Documentation:** See `/documentation` folder

---

## Still Stuck?

If none of these solutions work:

1. **Enable debug logging:**
   ```bash
   # .env
   LOG_LEVEL=DEBUG
   ```

2. **Collect diagnostics:**
   ```bash
   # System info
   python --version
   pip list > packages.txt
   
   # Application logs
   docker logs mentora-backend > app.log 2>&1
   
   # Database status
   python -c "from azure.cosmos import CosmosClient; print('DB OK')"
   ```

3. **Create GitHub issue** with:
   - Environment details
   - Full error output
   - Steps to reproduce
   - Diagnostic files

---

**Last Updated:** December 17, 2024  
**For more help:** rasanti2008@gmail.com
