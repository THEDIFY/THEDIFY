# Stripe Payment Integration Guide - Local Development & Production

## Overview
This guide explains how to test and deploy Stripe payments in EDIFY for both local development and Azure production environments.

---

## Table of Contents
- [Quick Start](#quick-start)
- [Local Development Setup](#local-development-setup)
- [Production Deployment](#production-deployment)
- [Payment Flow Explained](#payment-flow-explained)
- [Troubleshooting](#troubleshooting)

---

## Quick Start

### Local Development (Immediate Testing)
```bash
# 1. Start the app locally with Azure resources
cd "YC EDIFY/app"
./start-enhanced.ps1

# 2. Test payment flow
# - Go to http://localhost:8000
# - Sign up with a new user
# - Go to /payments
# - Click "Subscribe Now"
# - Use Stripe test card: 4242 4242 4242 4242
# - Complete checkout
# ✅ Subscription will be activated immediately!
```

**How It Works Locally:**
- The `/payment-success` page now **directly retrieves the Stripe session** and updates your subscription
- **No webhooks needed** for basic testing
- You'll be able to access `/principal` immediately after payment

### Production (Azure Deployment)
```bash
# Deploy to Azure
cd "YC EDIFY"
azd deploy

# Configure webhook in Stripe Dashboard
# 1. Go to: https://dashboard.stripe.com/test/webhooks
# 2. Add endpoint: https://your-app.azurewebsites.net/webhook
# 3. Select events: checkout.session.completed, invoice.payment_succeeded, etc.
# 4. Copy webhook signing secret
# 5. Set environment variable in Azure:
azd env set STRIPE_WEBHOOK_SECRET "whsec_your_secret_here"
azd deploy
```

---

## Local Development Setup

### Prerequisites
1. **Stripe Account** (Test Mode)
   - Sign up at https://dashboard.stripe.com
   - Get your test keys from: https://dashboard.stripe.com/test/apikeys

2. **Update Config** (already configured in `config.py`)
   ```python
   STRIPE_PUBLISHABLE_KEY = "pk_test_..." # Frontend key (safe to expose)
   STRIPE_SECRET_KEY = "sk_test_..."      # Backend key (keep secret)
   STRIPE_WEBHOOK_SECRET = "whsec_..."    # For webhook validation (optional for local)
   ```

### Testing Without Webhooks (Easiest Method)
**Current Implementation** (as of this fix):
- When user completes payment, Stripe redirects to: `/payment-success?session_id={CHECKOUT_SESSION_ID}`
- The `/payment-success` route **retrieves the Stripe session directly** and updates subscription status
- **No webhook listener needed** for basic local testing
- This is a **fallback mechanism** to ensure local development works smoothly

**Test Flow:**
```bash
# 1. Start app locally
cd "YC EDIFY/app"
./start-enhanced.ps1

# 2. Open browser: http://localhost:8000

# 3. Sign up with new user (e.g., test@example.com)

# 4. Navigate to /payments page

# 5. Select a plan and click "Subscribe Now"

# 6. Use Stripe test card:
#    Card Number: 4242 4242 4242 4242
#    Expiry: Any future date (e.g., 12/34)
#    CVC: Any 3 digits (e.g., 123)
#    ZIP: Any 5 digits (e.g., 12345)

# 7. Complete checkout

# 8. ✅ You'll be redirected to /sync and then /principal
#    Your subscription is now ACTIVE!
```

### Testing With Webhooks (Advanced - Optional)
For **full production-like testing** including webhook events, use Stripe CLI:

#### Install Stripe CLI
- **Windows:** Download from https://github.com/stripe/stripe-cli/releases
- **macOS:** `brew install stripe/stripe-cli/stripe`
- **Linux:** Download from releases page

#### Setup Webhook Forwarding
```bash
# 1. Login to Stripe CLI
stripe login

# 2. Forward webhooks to your local server
stripe listen --forward-to http://localhost:8000/webhook

# Output will show:
# > Ready! Your webhook signing secret is whsec_... (copy this)

# 3. Update your local environment with the webhook secret
# Edit: YC EDIFY/app/backend/config.py
STRIPE_WEBHOOK_SECRET = "whsec_..." # Use the secret from CLI output

# 4. Restart your app
./start-enhanced.ps1

# 5. In another terminal, keep the Stripe CLI running:
stripe listen --forward-to http://localhost:8000/webhook
```

#### Test Webhook Events
```bash
# Trigger a test checkout.session.completed event
stripe trigger checkout.session.completed

# Watch logs in both terminals:
# - Stripe CLI will show the event being sent
# - Your app logs will show: "📨 WEBHOOK RECEIVED: checkout.session.completed"
```

### Test Credit Cards
Use these Stripe test cards for different scenarios:

| Scenario | Card Number | Expiry | CVC | ZIP |
|----------|-------------|--------|-----|-----|
| **Success** | 4242 4242 4242 4242 | Any future date | Any 3 digits | Any 5 digits |
| **Declined** | 4000 0000 0000 0002 | Any future date | Any 3 digits | Any 5 digits |
| **Insufficient Funds** | 4000 0000 0000 9995 | Any future date | Any 3 digits | Any 5 digits |
| **Expired Card** | 4000 0000 0000 0069 | Any past date | Any 3 digits | Any 5 digits |
| **Processing Error** | 4000 0000 0000 0119 | Any future date | Any 3 digits | Any 5 digits |

Full list: https://stripe.com/docs/testing#cards

---

## Production Deployment

### 1. Set Environment Variables in Azure
```bash
cd "YC EDIFY"

# Set Stripe keys (use production keys for live mode)
azd env set STRIPE_PUBLISHABLE_KEY "pk_live_..." # Or pk_test_ for testing
azd env set STRIPE_SECRET_KEY "sk_live_..."      # Or sk_test_ for testing

# Deploy to Azure
azd deploy
```

### 2. Configure Stripe Webhook in Dashboard
**CRITICAL for production:**
1. Go to Stripe Dashboard: https://dashboard.stripe.com/webhooks
2. Click **"Add endpoint"**
3. **Endpoint URL:** `https://your-app.azurewebsites.net/webhook`
   - Example: `https://edify-app-h9x7j2k3.azurewebsites.net/webhook`
4. **Description:** "EDIFY Subscription Webhooks"
5. **Events to send:**
   - ✅ `checkout.session.completed` (Initial payment success)
   - ✅ `customer.subscription.created` (Subscription created)
   - ✅ `customer.subscription.deleted` (Subscription cancelled)
   - ✅ `invoice.payment_succeeded` (Recurring payment success)
   - ✅ `invoice.payment_failed` (Payment failed)
6. Click **"Add endpoint"**
7. **Copy the webhook signing secret:** `whsec_...`

### 3. Update Webhook Secret in Azure
```bash
# Set webhook secret
azd env set STRIPE_WEBHOOK_SECRET "whsec_your_actual_webhook_secret"

# Redeploy to apply
azd deploy
```

### 4. Test Production Webhook
```bash
# Send a test webhook from Stripe Dashboard
# 1. Go to: https://dashboard.stripe.com/test/webhooks
# 2. Click on your webhook endpoint
# 3. Click "Send test webhook"
# 4. Select "checkout.session.completed"
# 5. Click "Send test webhook"

# Check Azure App Service logs:
az webapp log tail --name <your-app-name> --resource-group <your-rg>

# You should see: "📨 WEBHOOK RECEIVED: checkout.session.completed"
```

### 5. Switch to Live Mode (Production)
**When ready for real payments:**

1. **Update Stripe keys to LIVE mode:**
   ```bash
   azd env set STRIPE_PUBLISHABLE_KEY "pk_live_..."
   azd env set STRIPE_SECRET_KEY "sk_live_..."
   azd deploy
   ```

2. **Configure LIVE webhook in Stripe:**
   - Switch Stripe Dashboard to **Live mode** (toggle in top right)
   - Add webhook endpoint: `https://your-app.azurewebsites.net/webhook`
   - Select same events as test mode
   - Copy LIVE webhook secret
   - Update Azure:
     ```bash
     azd env set STRIPE_WEBHOOK_SECRET "whsec_live_..."
     azd deploy
     ```

---

## Payment Flow Explained

### Complete User Journey

#### 1. User Signs Up
```
User visits /signup → Enters email/password → Creates account with "trial" status
```

#### 2. User Selects Plan
```
User visits /payments → Chooses plan (Pilot/Tutor, Monthly/Annual) → Clicks "Subscribe Now"
```

#### 3. Checkout Session Created
```
Frontend sends POST to /create-checkout-session
Backend creates Stripe checkout session with:
  - Customer email
  - Plan details (price, interval)
  - Promotional pricing (if new user + monthly plan)
  - Metadata (plan, billing_cycle, user_email, is_promotional)
Frontend redirects to Stripe Checkout hosted page
```

#### 4. User Completes Payment
```
User enters card details on Stripe Checkout page
Stripe processes payment
Stripe redirects to: /payment-success?session_id={CHECKOUT_SESSION_ID}
```

#### 5. Subscription Activated (Two Paths)

**Path A: Immediate Update (Fallback - Always Works)**
```
/payment-success route:
  1. Retrieves Stripe session by session_id
  2. Extracts customer_email and plan details from session
  3. Calls update_user_subscription_status(email, 'active', plan)
  4. Updates user document in Cosmos DB:
     - subscription_status = 'active'
     - planStatus = 'Pilot' or 'Tutor' (based on plan)
     - subscription_updated = timestamp
  5. Redirects to /sync
```

**Path B: Webhook Update (Production - Authoritative)**
```
Stripe sends webhook to /webhook:
  Event: checkout.session.completed
  Payload: {
    customer_email: "user@example.com",
    metadata: { plan: "lycee", billing_cycle: "monthly", ... }
  }
Backend /webhook route:
  1. Validates webhook signature (STRIPE_WEBHOOK_SECRET)
  2. Extracts customer_email and plan from event
  3. Calls update_user_subscription_status(email, 'active', plan)
  4. Updates user document in Cosmos DB (same as Path A)
  5. Returns 200 OK to Stripe
```

**Why Both Paths?**
- **Path A (Immediate):** Ensures local development works without webhooks, provides instant user feedback
- **Path B (Webhook):** Production-grade reliability, handles edge cases, validates payment authenticity

#### 6. User Accesses App
```
User navigates to /principal
Backend checks check_user_access(email):
  - Queries Cosmos DB for user
  - Checks subscription_status == 'active'
  - ✅ Grants access if active
  - ❌ Redirects to /payments if not active
User sees chatbot interface with plan-specific features
```

### Subscription Renewal (Monthly Billing)

#### Automatic Renewal Flow
```
Day 1: User subscribes (lycee_monthly_promo at 149 MXN)
Day 30: Stripe automatically charges 199 MXN (regular price)
  
Webhook: invoice.payment_succeeded
  Backend logs:
    "💳 AUTOMATIC PAYMENT SUCCEEDED"
    "🔍 Billing Reason: subscription_cycle"
    "🔄 THIS IS AN AUTOMATIC RENEWAL"
  Backend maintains subscription_status = 'active'
  User continues to have access (no action needed)
```

#### Failed Payment Flow
```
Stripe attempts to charge card → Payment fails

Webhook: invoice.payment_failed
  Backend updates:
    subscription_status = 'payment_failed'
  Backend logs:
    "💳 AUTOMATIC PAYMENT FAILED"
    "🔄 Attempt Count: 1"

User tries to access /principal:
  check_user_access() returns payment_required
  User redirected to /payments with notification
  
User updates payment method in Stripe customer portal
Stripe retries payment → Success
Webhook: invoice.payment_succeeded
  Backend updates subscription_status = 'active'
  User regains access
```

### Subscription Cancellation

#### User-Initiated Cancellation
```
User accesses Stripe customer portal (link in app)
User clicks "Cancel subscription"
Stripe schedules cancellation at period end

Webhook: customer.subscription.deleted
  Backend updates:
    subscription_status = 'cancelled'
  Backend logs:
    "❌ SUBSCRIPTION CANCELLED"
    
User continues to have access until period end
After period end:
  check_user_access() returns payment_required
  User redirected to /payments
```

---

## Troubleshooting

### Issue: User can't access /principal after payment

**Symptoms:**
- User completes Stripe checkout successfully
- Redirected to /payment-success
- Then redirected to /sync
- Trying to access /principal shows "payment_required"

**Diagnosis:**
```bash
# Check user subscription status in Cosmos DB
# Look for user document with matching email
# Check fields:
#   - subscription_status (should be "active")
#   - planStatus (should be "Pilot" or "Tutor")
#   - subscription_updated (should be recent timestamp)
```

**Solutions:**

1. **Local Development - No Webhooks:**
   - ✅ **Now Fixed:** The `/payment-success` route retrieves the session and updates status
   - Test: Complete payment and check logs for: "✅ SUBSCRIPTION ACTIVATED: email → plan (status: active)"

2. **Production - Webhook Not Configured:**
   - Configure webhook in Stripe Dashboard (see [Production Deployment](#production-deployment))
   - Set `STRIPE_WEBHOOK_SECRET` environment variable
   - Redeploy app

3. **Production - Webhook Failing:**
   ```bash
   # Check webhook status in Stripe Dashboard
   # Go to: https://dashboard.stripe.com/webhooks
   # Click on your endpoint
   # Check "Recent events" for errors
   
   # Check Azure App Service logs
   az webapp log tail --name <app-name> --resource-group <rg-name>
   # Look for: "📨 WEBHOOK RECEIVED" or errors
   ```

4. **Manual Fix (Emergency):**
   ```bash
   # Manually update user subscription in Cosmos DB
   # Use Azure Portal or script to set:
   {
     "email": "user@example.com",
     "subscription_status": "active",
     "planStatus": "Tutor", # or "Pilot"
     "subscription_updated": 1760059592 # current timestamp
   }
   ```

### Issue: Webhook signature verification fails

**Error Message:**
```
❌ Invalid signature: No signatures found matching the expected signature
```

**Solution:**
1. **Check webhook secret is correct:**
   ```bash
   # Get current value
   azd env get-values | Select-String "STRIPE_WEBHOOK_SECRET"
   
   # Update to correct value from Stripe Dashboard
   azd env set STRIPE_WEBHOOK_SECRET "whsec_correct_secret"
   azd deploy
   ```

2. **Verify webhook URL in Stripe Dashboard:**
   - URL must be: `https://your-app.azurewebsites.net/webhook` (no trailing slash)
   - Check endpoint is enabled

3. **For Local Development with Stripe CLI:**
   ```bash
   # Stop and restart Stripe CLI to get fresh secret
   stripe listen --forward-to http://localhost:8000/webhook
   # Copy new secret from output
   # Update config.py with new secret
   # Restart app
   ```

### Issue: Payment succeeds but webhook never arrives (local dev)

**This is Expected Behavior:**
- Stripe cannot send webhooks to `localhost` directly
- This is why we implemented the **fallback mechanism** in `/payment-success`
- Payment will still work, subscription will be activated

**To Test Webhooks Locally:**
Use Stripe CLI (see [Testing With Webhooks](#testing-with-webhooks-advanced---optional))

### Issue: Promotional pricing not transitioning to regular price

**Expected Flow:**
- Month 1: Charge 149 MXN (promotional)
- Month 2+: Charge 199 MXN (regular)

**Check Logs:**
```bash
# After first payment, look for:
"🎁 PROMOTIONAL SUBSCRIPTION SETUP:"
"   💰 Promotional Price (Month 1): 149.00 MXN"
"   💰 Regular Price (Month 2+): 199.00 MXN"
"   🔄 Auto-billing: ENABLED"

# After second payment, look for:
"💳 AUTOMATIC PAYMENT SUCCEEDED:"
"   🔍 Billing Reason: subscription_cycle"
"   💰 Amount Paid: 199.00 MXN"
```

**If Not Transitioning:**
1. Check Stripe subscription details in Dashboard
2. Verify `metadata` includes `regular_plan` key
3. Check `handle_promotional_subscription()` is called in webhook handler

### Issue: Test cards not working

**Common Mistakes:**
- Using production keys instead of test keys (keys must start with `pk_test_` and `sk_test_`)
- Using incorrect card format (must be `4242 4242 4242 4242`, not `4242424242424242`)
- Using past expiry date

**Solution:**
```bash
# Verify you're using test keys
# Check config.py:
STRIPE_PUBLISHABLE_KEY starts with "pk_test_"
STRIPE_SECRET_KEY starts with "sk_test_"

# Use correct test card:
Card: 4242 4242 4242 4242
Expiry: 12/34 (any future date)
CVC: 123 (any 3 digits)
ZIP: 12345 (any 5 digits)
```

### Issue: Subscription shows as active but user still blocked

**Check Trial Status:**
```bash
# User might be in trial that expired
# Check user document:
{
  "subscription_status": "active", # or "trial"
  "trial_active": false, # Should be false if subscription active
  "trial_start_date": "2024-01-01T00:00:00Z",
  # ...
}
```

**Solution:**
```python
# Trial should be deactivated when subscription activates
# Check update_user_subscription_status() includes:
user['trial_active'] = False # Add this if missing
```

---

## Environment Variables Reference

### Required for Production
```bash
# Stripe API Keys
STRIPE_PUBLISHABLE_KEY="pk_live_..." # Or pk_test_ for testing
STRIPE_SECRET_KEY="sk_live_..."      # Or sk_test_ for testing
STRIPE_WEBHOOK_SECRET="whsec_..."    # From Stripe webhook endpoint

# Set in Azure:
azd env set STRIPE_PUBLISHABLE_KEY "pk_live_..."
azd env set STRIPE_SECRET_KEY "sk_live_..."
azd env set STRIPE_WEBHOOK_SECRET "whsec_..."
azd deploy
```

### Optional (defaults in config.py)
```bash
# Development mode flag
DEVELOPMENT_MODE="true" # or "false" (default: false)
```

---

## Quick Reference: Payment Testing Checklist

### Local Development Testing
- [ ] Start app: `./start-enhanced.ps1`
- [ ] Sign up with new user
- [ ] Navigate to /payments
- [ ] Select plan and click "Subscribe Now"
- [ ] Use test card: `4242 4242 4242 4242`
- [ ] Complete checkout
- [ ] Verify redirect to /sync then /principal
- [ ] Confirm access to chatbot
- [ ] Check logs for: "✅ SUBSCRIPTION ACTIVATED"

### Production Testing (Azure)
- [ ] Deploy app: `azd deploy`
- [ ] Configure webhook in Stripe Dashboard
- [ ] Set `STRIPE_WEBHOOK_SECRET` in Azure
- [ ] Redeploy: `azd deploy`
- [ ] Test checkout with test card
- [ ] Check webhook received in Stripe Dashboard
- [ ] Check Azure App Service logs for webhook event
- [ ] Verify user can access /principal

### Go-Live Checklist
- [ ] Switch Stripe to Live mode
- [ ] Update `STRIPE_PUBLISHABLE_KEY` to `pk_live_...`
- [ ] Update `STRIPE_SECRET_KEY` to `sk_live_...`
- [ ] Configure LIVE webhook in Stripe Dashboard
- [ ] Update `STRIPE_WEBHOOK_SECRET` to live webhook secret
- [ ] Deploy to Azure
- [ ] Test with real card (small amount)
- [ ] Verify payment appears in Stripe Dashboard
- [ ] Verify user gets access
- [ ] Monitor webhook delivery in Stripe Dashboard
- [ ] Set up Stripe email receipts for customers

---

## Additional Resources

### Stripe Documentation
- [Stripe Testing](https://stripe.com/docs/testing)
- [Stripe Webhooks](https://stripe.com/docs/webhooks)
- [Stripe CLI](https://stripe.com/docs/stripe-cli)
- [Stripe Subscriptions](https://stripe.com/docs/billing/subscriptions/overview)

### Azure Resources
- [Azure App Service Environment Variables](https://learn.microsoft.com/en-us/azure/app-service/configure-common)
- [Azure Developer CLI](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/)

### Support
- **EDIFY Documentation:** See `/documentation/` folder
- **Stripe Support:** https://support.stripe.com
- **Azure Support:** https://azure.microsoft.com/en-us/support/

---

**Last Updated:** October 9, 2025
**Version:** 2.0 (with fallback payment success mechanism)
