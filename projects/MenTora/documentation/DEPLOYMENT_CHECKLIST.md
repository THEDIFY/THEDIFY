# Deployment Checklist

## Pre-Deployment Checklist

### Code Quality
- [ ] All tests pass (`npm test` in frontend, `pytest` in backend)
- [ ] No linting errors (`npm run lint` in frontend, `ruff check .` in backend)
- [ ] TypeScript builds without errors (`npm run build`)
- [ ] No security vulnerabilities (`npm audit`, `pip-audit`)

### Environment Configuration
- [ ] All required environment variables are set
  - [ ] `JWT_SECRET` - Secure random string
  - [ ] `STRIPE_SECRET_KEY` - Stripe API key
  - [ ] `STRIPE_WEBHOOK_SECRET` - Stripe webhook secret
  - [ ] `AZURE_COSMOS_ENDPOINT` - Database endpoint
  - [ ] `AZURE_COSMOS_KEY` - Database key
  - [ ] `FRONTEND_URL` - Production frontend URL
  - [ ] `BACKEND_URL` - Production backend URL
- [ ] Secrets are stored in Azure Key Vault (not in code or env files)
- [ ] CORS origins configured for production domains

### Database
- [ ] Cosmos DB containers created (courses, users, progress)
- [ ] Composite indexes configured for search queries
- [ ] Backup/restore procedures documented
- [ ] Connection pooling configured

### Security
- [ ] HTTPS enabled with valid SSL certificate
- [ ] Rate limiting enabled
- [ ] JWT expiration configured appropriately
- [ ] Admin credentials changed from defaults
- [ ] Security headers configured (CSP, X-Frame-Options, etc.)

### Performance
- [ ] Lighthouse score > 90 for Performance
- [ ] Lighthouse score > 90 for Accessibility
- [ ] Bundle size < 500KB gzipped
- [ ] API response times < 500ms (p95)
- [ ] CDN configured for static assets

## Deployment Steps

### 1. Build Frontend
```bash
cd frontend
npm install
npm run build
```

### 2. Build Backend
```bash
cd backend
pip install -r requirements.txt
```

### 3. Deploy to Azure Container Instances
```bash
# Build container images
docker build -t mentora-backend ./backend
docker build -t mentora-frontend ./frontend

# Push to Azure Container Registry
az acr login --name <registry>
docker tag mentora-backend <registry>.azurecr.io/mentora-backend:latest
docker tag mentora-frontend <registry>.azurecr.io/mentora-frontend:latest
docker push <registry>.azurecr.io/mentora-backend:latest
docker push <registry>.azurecr.io/mentora-frontend:latest

# Deploy containers
az container create --resource-group <rg> --file deploy.yaml
```

### 4. Configure Azure CDN
- Set up CDN profile for static assets
- Configure caching rules
- Set up custom domain with SSL

### 5. Configure Monitoring
- Enable Application Insights
- Configure log aggregation
- Set up alerts for errors and performance issues

## Post-Deployment Checklist

### Smoke Tests
- [ ] Homepage loads correctly
- [ ] User can sign in with Google OAuth
- [ ] User can browse courses
- [ ] User can enroll in a course
- [ ] User can complete a lesson
- [ ] Progress is saved and displayed
- [ ] Admin can create a course with DSL
- [ ] Theme switching works
- [ ] PWA installs correctly on mobile

### Monitoring
- [ ] Error rates are normal
- [ ] Response times are within SLA
- [ ] Database connection is stable
- [ ] No memory leaks observed

### Documentation
- [ ] Deployment documentation updated
- [ ] Runbook for common issues created
- [ ] Contact information for support added

## Rollback Procedure

If issues are detected after deployment:

1. **Immediate Rollback**
   ```bash
   az container update --resource-group <rg> --name mentora \
     --image <registry>.azurecr.io/mentora-backend:previous
   ```

2. **Database Rollback**
   - Restore from latest backup
   - Use point-in-time recovery

3. **Investigation**
   - Review Application Insights logs
   - Check container logs
   - Analyze error patterns

## Maintenance Schedule

### Daily
- Monitor error rates and response times
- Review security alerts

### Weekly
- Review performance metrics
- Check disk usage and quotas
- Analyze user feedback

### Monthly
- Apply security patches
- Review and rotate secrets
- Performance optimization review

## Contact Information

- **Technical Lead**: [Name] - [email]
- **DevOps**: [Name] - [email]
- **On-Call**: [Rotation schedule]
