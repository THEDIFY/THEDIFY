# EDIFY Production Deployment Guide

## 🚀 Quick Production Setup

### 1. Environment Configuration

Create a `.env.production` file with real credentials:

```bash
# Database Configuration
AZURE_COSMOS_DATABASE_NAME=edify-prod
AZURE_COSMOS_CONTAINER_NAME=users
AZURE_COSMOS_ENDPOINT=https://your-cosmos-db.documents.azure.com:443/
AZURE_COSMOS_KEY=your-cosmos-key

# Stripe Configuration (Production)
STRIPE_PUBLISHABLE_KEY=pk_live_your_live_publishable_key
STRIPE_SECRET_KEY=sk_live_your_live_secret_key

# Google OAuth Configuration
GOOGLE_CLIENT_ID=your-google-client-id.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-google-client-secret

# Security
SECRET_KEY=your-super-secret-session-key
DEVELOPMENT_MODE=false

# Azure Services (if using)
AZURE_OPENAI_SERVICE=your-openai-service
AZURE_SEARCH_SERVICE=your-search-service
```

### 2. Stripe Setup

1. Create a Stripe account at https://stripe.com
2. Get your API keys from the Stripe Dashboard
3. Set up webhook endpoints for payment confirmation
4. Configure product pricing in Stripe Dashboard

### 3. Google OAuth Setup

1. Go to Google Cloud Console
2. Create a new project or select existing
3. Enable Google+ API
4. Create OAuth 2.0 credentials
5. Add authorized redirect URIs

### 4. Database Setup

```python
# Run this script to initialize Cosmos DB
python scripts/setup_cosmos_db.py
```

### 5. Deployment Commands

```bash
# Install dependencies
pip install -r requirements.txt

# Set environment to production
export ENVIRONMENT=production

# Run database migrations
python scripts/migrate_db.py

# Start production server
python main_prod.py
```

### 6. Nginx Configuration (Optional)

```nginx
server {
    listen 80;
    server_name yourdomain.com;
    
    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 7. Testing Checklist

- [ ] User registration works
- [ ] Login redirects to payment page
- [ ] Payment processing completes
- [ ] Google Sign-In authentication
- [ ] Subject data flows to backend
- [ ] All error cases handled gracefully

## 🔧 Development vs Production

| Feature | Development | Production |
|---------|-------------|------------|
| Database | Mock/Disabled | Cosmos DB |
| Payments | Test Mode | Live Mode |
| OAuth | Simulation | Real Google Auth |
| HTTPS | Optional | Required |
| Logging | Console | Cloud Logging |

## 📞 Support

For deployment assistance, check the Azure documentation or contact the development team.

---
*Generated on June 6, 2025*
