# EDIFY Troubleshooting Guide

This guide covers common issues you may encounter when using or deploying EDIFY, along with solutions and workarounds.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Authentication Problems](#authentication-problems)
- [API & Performance Issues](#api--performance-issues)
- [RAG & AI Service Issues](#rag--ai-service-issues)
- [Database & Cache Issues](#database--cache-issues)
- [Deployment Issues](#deployment-issues)
- [Getting Help](#getting-help)

---

## Installation Issues

### Issue: `pip install` fails with dependency conflicts

**Symptoms:**
```bash
ERROR: Cannot install package due to conflicting dependencies
```

**Solution:**
```bash
# 1. Create fresh virtual environment
python -m venv venv_new
source venv_new/bin/activate

# 2. Upgrade pip
pip install --upgrade pip setuptools wheel

# 3. Install dependencies in order
pip install -r requirements.txt --no-cache-dir

# 4. If still failing, install problematic packages separately
pip install azure-identity==1.15.0
pip install azure-cosmos==4.5.1
pip install -r requirements.txt
```

### Issue: Python version incompatibility

**Symptoms:**
```
ERROR: Python 3.11+ required
```

**Solution:**
```bash
# Check Python version
python --version

# Install Python 3.11 (Ubuntu/Debian)
sudo apt update
sudo apt install python3.11 python3.11-venv

# Create venv with specific version
python3.11 -m venv venv
source venv/bin/activate
```

### Issue: Azure SDK authentication errors on Windows

**Symptoms:**
```
DefaultAzureCredential failed to retrieve a token
```

**Solution:**
```bash
# Install Azure CLI
winget install Microsoft.AzureCLI

# Login to Azure
az login

# Set subscription
az account set --subscription <subscription-id>

# Alternative: Use environment variable authentication
export AZURE_CLIENT_ID="your-client-id"
export AZURE_CLIENT_SECRET="your-client-secret"
export AZURE_TENANT_ID="your-tenant-id"
```

---

## Authentication Problems

### Issue: "Invalid token" or "Token expired" errors

**Symptoms:**
```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Invalid or expired token"
  }
}
```

**Solution:**

1. **Check token expiration:**
   ```bash
   # Decode JWT token (use jwt.io or command line)
   echo $TOKEN | cut -d'.' -f2 | base64 -d | jq .exp
   ```

2. **Refresh token:**
   ```bash
   curl -X POST https://edify.ai/auth/refresh \
     -H "Content-Type: application/json" \
     -d '{"refresh_token": "your_refresh_token"}'
   ```

3. **Re-authenticate:**
   ```bash
   # Clear old tokens
   rm ~/.edify/tokens

   # Login again
   curl -X POST https://edify.ai/auth/google/login \
     -d '{"credential": "new_google_token"}'
   ```

### Issue: Google OAuth "redirect_uri_mismatch"

**Symptoms:**
```
Error 400: redirect_uri_mismatch
```

**Solution:**

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to APIs & Services > Credentials
3. Edit your OAuth 2.0 Client ID
4. Add authorized redirect URIs:
   ```
   http://localhost:8000/auth/google/callback
   https://edify.ai/auth/google/callback
   https://your-domain.com/auth/google/callback
   ```
5. Save and wait 5 minutes for changes to propagate

### Issue: "Insufficient permissions" errors

**Symptoms:**
```json
{
  "error": {
    "code": "FORBIDDEN",
    "message": "Insufficient permissions"
  }
}
```

**Solution:**

Check user role:
```bash
curl https://edify.ai/api/users/me \
  -H "Authorization: Bearer $TOKEN" \
  | jq .role

# Expected: "student", "educator", or "admin"
```

Request role upgrade (contact support if needed):
```bash
# For educators, request upgrade
curl -X POST https://edify.ai/api/users/request-role-upgrade \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"requested_role": "educator", "justification": "I teach ML courses"}'
```

---

## API & Performance Issues

### Issue: Slow response times (>5 seconds)

**Symptoms:**
- API requests taking longer than expected
- Timeout errors

**Diagnosis:**

```bash
# Check response times
curl -w "\nTotal time: %{time_total}s\n" \
  -X POST https://edify.ai/api/chat \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"query": "test"}'

# Check service health
curl https://edify.ai/health | jq .
```

**Solutions:**

1. **Enable caching:**
   ```bash
   # Ensure Redis is running
   redis-cli ping
   # Expected: PONG

   # Check cache hit rate
   curl https://edify.ai/metrics | grep cache_hit_rate
   ```

2. **Reduce query complexity:**
   ```bash
   # Use shorter, more specific queries
   # Bad:  "Explain everything about machine learning"
   # Good: "Explain gradient descent"
   ```

3. **Use appropriate timeouts:**
   ```python
   import httpx

   async with httpx.AsyncClient(timeout=30.0) as client:
       response = await client.post("/api/chat", json=payload)
   ```

### Issue: Rate limit exceeded (429 errors)

**Symptoms:**
```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests",
    "retry_after": 42
  }
}
```

**Solution:**

1. **Implement exponential backoff:**
   ```python
   import time
   from tenacity import retry, wait_exponential, stop_after_attempt

   @retry(
       wait=wait_exponential(multiplier=1, min=1, max=60),
       stop=stop_after_attempt(5)
   )
   def make_request():
       return client.post("/api/chat", json=payload)
   ```

2. **Batch requests:**
   ```python
   # Instead of 10 separate requests
   # Group related questions in one conversation
   messages = [
       {"query": "Question 1"},
       {"query": "Question 2"},
       {"query": "Question 3"}
   ]
   ```

3. **Upgrade tier** (for higher limits):
   ```bash
   curl -X POST https://edify.ai/api/users/upgrade \
     -H "Authorization: Bearer $TOKEN" \
     -d '{"tier": "premium"}'
   ```

### Issue: CORS errors in browser

**Symptoms:**
```
Access to fetch at 'https://api.edify.ai' from origin 'http://localhost:3000'
has been blocked by CORS policy
```

**Solution:**

1. **For development:**
   ```bash
   # Add origin to CORS whitelist in .env
   CORS_ORIGINS=http://localhost:3000,http://localhost:8000
   ```

2. **For production:**
   ```bash
   # Ensure your domain is whitelisted
   CORS_ORIGINS=https://edify.ai,https://app.edify.ai
   ```

3. **Temporary workaround** (development only):
   ```bash
   # Use proxy in package.json (React)
   {
     "proxy": "http://localhost:8000"
   }
   ```

---

## RAG & AI Service Issues

### Issue: Poor quality or irrelevant responses

**Symptoms:**
- Responses don't answer the question
- Citations are irrelevant
- Generic answers without personalization

**Solutions:**

1. **Improve query specificity:**
   ```python
   # Bad query
   "machine learning"
   
   # Better query
   "Explain the difference between supervised and unsupervised machine learning with examples"
   ```

2. **Update learner profile:**
   ```bash
   curl -X PATCH https://edify.ai/api/users/me \
     -H "Authorization: Bearer $TOKEN" \
     -d '{
       "learning_profile": {
         "subjects": ["machine_learning"],
         "skill_level": {"machine_learning": "intermediate"},
         "learning_goals": ["Understand neural networks"]
       }
     }'
   ```

3. **Check content availability:**
   ```bash
   # Verify search index has relevant content
   curl https://edify.ai/api/content/search?q="gradient+descent" \
     -H "Authorization: Bearer $TOKEN"
   ```

### Issue: "No relevant content found" errors

**Symptoms:**
```json
{
  "response": {
    "answer": "I couldn't find relevant information...",
    "citations": []
  }
}
```

**Solutions:**

1. **Upload custom content:**
   ```bash
   curl -X POST https://edify.ai/api/content/upload \
     -H "Authorization: Bearer $TOKEN" \
     -F "file=@textbook.pdf" \
     -F 'metadata={"subject": "machine_learning", "title": "ML Textbook"}'
   ```

2. **Broaden search query:**
   ```python
   # Instead of very specific terms
   # Use more general concepts
   "gradient descent" → "optimization algorithms"
   ```

3. **Check index status:**
   ```bash
   curl https://edify.ai/api/content/status \
     -H "Authorization: Bearer $TOKEN"
   
   # Expected: {"indexed_documents": > 0}
   ```

### Issue: Azure OpenAI rate limits or quota errors

**Symptoms:**
```
RateLimitError: Requests to the Azure OpenAI API have exceeded rate limit
```

**Solutions:**

1. **Check quota usage:**
   ```bash
   az cognitiveservices account show \
     --name edify-openai \
     --resource-group edify-rg \
     --query properties.quotaLimit
   ```

2. **Increase quota:**
   ```bash
   # Request quota increase via Azure portal
   # Or scale to higher tier
   az cognitiveservices account update \
     --name edify-openai \
     --resource-group edify-rg \
     --sku S0
   ```

3. **Implement request queuing:**
   ```python
   from asyncio import Semaphore

   # Limit concurrent requests
   semaphore = Semaphore(10)

   async def make_openai_request():
       async with semaphore:
           return await openai_client.chat.completions.create(...)
   ```

---

## Database & Cache Issues

### Issue: Cosmos DB connection failures

**Symptoms:**
```
CosmosHttpResponseError: Failed to connect to Cosmos DB
```

**Solutions:**

1. **Verify credentials:**
   ```bash
   # Test connection
   az cosmosdb check-name-availability \
     --name edify-cosmos
   
   # Check firewall rules
   az cosmosdb network-rule list \
     --name edify-cosmos \
     --resource-group edify-rg
   ```

2. **Add IP to firewall:**
   ```bash
   # Get your IP
   MY_IP=$(curl -s ifconfig.me)
   
   # Add to firewall
   az cosmosdb network-rule add \
     --name edify-cosmos \
     --resource-group edify-rg \
     --ip-address $MY_IP
   ```

3. **Check connection string:**
   ```python
   from azure.cosmos import CosmosClient
   
   # Test connection
   client = CosmosClient(
       url=os.getenv("AZURE_COSMOS_ENDPOINT"),
       credential=os.getenv("AZURE_COSMOS_KEY")
   )
   
   # List databases
   databases = list(client.list_databases())
   print(f"Found {len(databases)} databases")
   ```

### Issue: Redis cache connection errors

**Symptoms:**
```
redis.exceptions.ConnectionError: Error connecting to Redis
```

**Solutions:**

1. **Check Redis status:**
   ```bash
   # Local Redis
   redis-cli ping
   # Expected: PONG
   
   # Azure Redis
   az redis show \
     --name edify-redis \
     --resource-group edify-rg \
     --query provisioningState
   ```

2. **Verify connection string:**
   ```bash
   # Test connection
   redis-cli -h edify-redis.redis.cache.windows.net \
     -p 6380 \
     -a $REDIS_PASSWORD \
     --tls
   
   # Expected: Connected
   ```

3. **Clear cache if corrupted:**
   ```bash
   redis-cli FLUSHALL
   # Warning: This deletes all cached data
   ```

### Issue: Database query timeouts

**Symptoms:**
```
RequestTimeout: The request has timed out
```

**Solutions:**

1. **Increase timeout:**
   ```python
   from azure.cosmos import CosmosClient
   
   client = CosmosClient(
       url=cosmos_url,
       credential=cosmos_key,
       connection_timeout=30,  # Increase from default
       request_timeout=30
   )
   ```

2. **Optimize queries:**
   ```python
   # Add partition key to queries
   container.query_items(
       query="SELECT * FROM c WHERE c.userId = @userId",
       parameters=[{"name": "@userId", "value": user_id}],
       partition_key=user_id  # Efficient query
   )
   ```

3. **Increase RU/s provisioning:**
   ```bash
   az cosmosdb sql container throughput update \
     --account-name edify-cosmos \
     --database-name edify-db \
     --name users \
     --resource-group edify-rg \
     --throughput 2000  # Increase from 1000
   ```

---

## Deployment Issues

### Issue: Docker container won't start

**Symptoms:**
```
Container exits immediately with code 1
```

**Solutions:**

1. **Check logs:**
   ```bash
   docker logs edify-api
   
   # Or for Docker Compose
   docker-compose logs api
   ```

2. **Verify environment variables:**
   ```bash
   docker exec edify-api env | grep AZURE
   
   # Ensure all required vars are set
   ```

3. **Test locally first:**
   ```bash
   # Run without Docker to identify issue
   cd code
   python -m uvicorn app.main:app
   ```

### Issue: Azure deployment fails

**Symptoms:**
```
ERROR: Deployment failed with status code 500
```

**Solutions:**

1. **Check deployment logs:**
   ```bash
   az webapp log tail \
     --name edify-app \
     --resource-group edify-rg
   ```

2. **Verify app settings:**
   ```bash
   az webapp config appsettings list \
     --name edify-app \
     --resource-group edify-rg
   
   # Ensure all required settings present
   ```

3. **Enable detailed logging:**
   ```bash
   az webapp log config \
     --name edify-app \
     --resource-group edify-rg \
     --application-logging filesystem \
     --level verbose
   ```

### Issue: SSL/TLS certificate errors

**Symptoms:**
```
SSL: CERTIFICATE_VERIFY_FAILED
```

**Solutions:**

1. **Update certificates:**
   ```bash
   pip install --upgrade certifi
   ```

2. **Disable verification (development only):**
   ```python
   import httpx
   
   # NOT for production
   client = httpx.AsyncClient(verify=False)
   ```

3. **Use custom CA bundle:**
   ```bash
   export REQUESTS_CA_BUNDLE=/path/to/ca-bundle.crt
   ```

---

## Getting Help

### Self-Service Resources

1. **Documentation:**
   - [User Guide](USER_GUIDE.md)
   - [API Documentation](API.md)
   - [Architecture Guide](ARCHITECTURE.md)
   - [FAQ](FAQ.md)

2. **Diagnostics:**
   ```bash
   # Run built-in diagnostics
   python scripts/diagnose.py
   
   # Expected output: Checks all services and reports status
   ```

3. **Community:**
   - [GitHub Discussions](https://github.com/THEDIFY/THEDIFY/discussions)
   - [Stack Overflow](https://stackoverflow.com/questions/tagged/edify) (tag: edify)

### Reporting Bugs

If you've found a bug:

1. **Check existing issues:** [GitHub Issues](https://github.com/THEDIFY/THEDIFY/issues)
2. **Gather information:**
   ```bash
   # Collect system info
   python --version
   pip list | grep -E "azure|fastapi|openai"
   cat .env | grep -v KEY  # Don't share secrets!
   ```
3. **Create detailed report:** Use bug report template
4. **Include logs:** Sanitize any sensitive data first

### Priority Support

**Free tier:**
- Community support via GitHub Discussions
- Response time: Best effort

**Premium tier:**
- Email support: support@edify.ai
- Response time: 24 hours

**Enterprise tier:**
- Dedicated support channel
- Response time: 4 hours
- Phone/video support available

---

## Debug Mode

Enable debug mode for detailed logging:

```bash
# Environment variable
export DEBUG=true
export LOG_LEVEL=DEBUG

# Run application
python -m uvicorn app.main:app --log-level debug

# Check debug logs
tail -f logs/edify-debug.log
```

**Warning:** Never enable debug mode in production (exposes sensitive data)

---

*Troubleshooting Guide Version: 1.2.0 | Last Updated: December 17, 2025*
