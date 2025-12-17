# Brainstorm Backend API - Deployment Documentation

**Status:** ✅ **DEPLOYED TO DIGITALOCEAN**
**Deployment Date:** December 17, 2025
**Environment:** Production

---

## 🎯 Deployment Summary

The Brainstorm Backend API has been successfully deployed to DigitalOcean App Platform.

**Live URL:** https://brainstorm-backend-gk4th.ondigitalocean.app
**GitHub Repository:** https://github.com/justinjilg/brainstorm-backend
**DigitalOcean App ID:** ddd6cad3-0aef-43ef-af2e-7e3c39ec629c

---

## ✅ What's Deployed

### Backend API Endpoints
- ✅ `GET /api/health` - Health check endpoint
- ✅ `POST /api/v1/auth/magic-link` - Magic link authentication
- ✅ `GET /api/v1/auth/google/url` - Google OAuth URL generation
- ✅ `GET /api/v1/auth/github/url` - GitHub OAuth URL generation
- ✅ `GET /auth/google/callback` - Google OAuth callback handler
- ✅ `GET /auth/github/callback` - GitHub OAuth callback handler

### Infrastructure
- ✅ Node.js Express server (v18+)
- ✅ Auto-deployment from GitHub (main branch)
- ✅ SSL/HTTPS enabled
- ✅ JWT authentication configured
- ✅ CORS enabled for cross-origin requests

---

## 🔧 Configuration Status

### ✅ Configured (Production Ready)
- **JWT_SECRET:** Configured (64-character cryptographic key)
- **NODE_ENV:** production
- **PORT:** 3000
- **APP_URL:** https://brainstorm-backend-gk4th.ondigitalocean.app

### ⏳ Needs Configuration (To Enable Full Functionality)

#### 1. SMTP Email Service (for Magic Links)
**Required for:** Sending magic link emails

**Configuration needed:**
```bash
doctl apps update ddd6cad3-0aef-43ef-af2e-7e3c39ec629c --spec - << 'EOF'
# ... existing config ...
envs:
  # ... existing envs ...
  - key: SMTP_HOST
    value: smtp.sendgrid.net
    type: SECRET
  - key: SMTP_PORT
    value: "587"
  - key: SMTP_USER
    value: apikey
    type: SECRET
  - key: SMTP_PASS
    value: YOUR_SENDGRID_API_KEY
    type: SECRET
  - key: SMTP_FROM
    value: noreply@brainstorm.co
EOF
```

**SMTP Provider Options:**
- **SendGrid** (recommended): https://sendgrid.com
- **AWS SES**: https://aws.amazon.com/ses
- **Mailgun**: https://mailgun.com
- **Postmark**: https://postmarkapp.com

#### 2. Google OAuth (for "Continue with Google")
**Required for:** Google authentication

**Setup Steps:**
1. Go to https://console.cloud.google.com/apis/credentials
2. Create OAuth 2.0 Client ID
3. Set authorized redirect URI: `https://brainstorm-backend-gk4th.ondigitalocean.app/auth/google/callback`
4. Copy Client ID and Client Secret

**Configuration:**
```bash
doctl apps update ddd6cad3-0aef-43ef-af2e-7e3c39ec629c --spec - << 'EOF'
# ... existing config ...
envs:
  # ... existing envs ...
  - key: GOOGLE_CLIENT_ID
    value: YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com
    type: SECRET
  - key: GOOGLE_CLIENT_SECRET
    value: YOUR_GOOGLE_CLIENT_SECRET
    type: SECRET
EOF
```

#### 3. GitHub OAuth (for "Continue with GitHub")
**Required for:** GitHub authentication

**Setup Steps:**
1. Go to https://github.com/settings/developers
2. Click "New OAuth App"
3. Set callback URL: `https://brainstorm-backend-gk4th.ondigitalocean.app/auth/github/callback`
4. Copy Client ID and Client Secret

**Configuration:**
```bash
doctl apps update ddd6cad3-0aef-43ef-af2e-7e3c39ec629c --spec - << 'EOF'
# ... existing config ...
envs:
  # ... existing envs ...
  - key: GITHUB_CLIENT_ID
    value: YOUR_GITHUB_CLIENT_ID
    type: SECRET
  - key: GITHUB_CLIENT_SECRET
    value: YOUR_GITHUB_CLIENT_SECRET
    type: SECRET
EOF
```

---

## 🌐 Custom Domain Setup (Optional)

To use `app.brainstorm.co` instead of the DigitalOcean URL:

1. **Add Domain to DigitalOcean App:**
```bash
doctl apps update ddd6cad3-0aef-43ef-af2e-7e3c39ec629c --spec - << 'EOF'
name: brainstorm-backend
domains:
  - domain: app.brainstorm.co
    type: PRIMARY
    zone: brainstorm.co
# ... rest of spec ...
EOF
```

2. **Update DNS Records:**
   - Add CNAME record: `app.brainstorm.co` → `brainstorm-backend-gk4th.ondigitalocean.app`
   - Or use DigitalOcean's nameservers

3. **Update APP_URL Environment Variable:**
```bash
# Update APP_URL to use custom domain
- key: APP_URL
  value: https://app.brainstorm.co
```

---

## 🧪 Testing Endpoints

### Health Check
```bash
curl https://brainstorm-backend-gk4th.ondigitalocean.app/api/health
# Expected: {"status":"ok","service":"brainstorm-backend","version":"1.0.0"}
```

### Magic Link (requires SMTP configuration)
```bash
curl -X POST https://brainstorm-backend-gk4th.ondigitalocean.app/api/v1/auth/magic-link \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "site_url": "https://mysite.com",
    "redirect_url": "https://mysite.com/wp-admin/admin.php?page=brainstorm-app-connection"
  }'
```

### Google OAuth URL (requires Google OAuth configuration)
```bash
curl "https://brainstorm-backend-gk4th.ondigitalocean.app/api/v1/auth/google/url?site_url=https://mysite.com&redirect_url=https://mysite.com/wp-admin"
```

### GitHub OAuth URL (requires GitHub OAuth configuration)
```bash
curl "https://brainstorm-backend-gk4th.ondigitalocean.app/api/v1/auth/github/url?site_url=https://mysite.com&redirect_url=https://mysite.com/wp-admin"
```

---

## 🔄 Continuous Deployment

The app is configured for automatic deployment from GitHub:
- **Branch:** main
- **Trigger:** Push to main branch
- **Build:** Automatic via DigitalOcean

To deploy changes:
```bash
cd ~/brainstorm-backend
git add .
git commit -m "Your commit message"
git push origin main
# DigitalOcean will automatically deploy
```

---

## 📊 Monitoring

### View Deployment Logs
```bash
doctl apps logs ddd6cad3-0aef-43ef-af2e-7e3c39ec629c --type run
```

### View Build Logs
```bash
doctl apps logs ddd6cad3-0aef-43ef-af2e-7e3c39ec629c --type build
```

### View App Status
```bash
doctl apps get ddd6cad3-0aef-43ef-af2e-7e3c39ec629c
```

---

## 🔐 Security Considerations

### Current Security Features
- ✅ HTTPS/SSL enabled
- ✅ JWT token-based authentication
- ✅ CORS configured
- ✅ Environment variables encrypted
- ✅ OAuth state parameter for CSRF protection
- ✅ Magic link token expiration (15 minutes)

### Recommended Security Enhancements
- [ ] Add rate limiting middleware
- [ ] Implement IP allowlisting
- [ ] Add request logging/monitoring
- [ ] Set up error tracking (Sentry, etc.)
- [ ] Enable 2FA for OAuth providers
- [ ] Add API key authentication for endpoints

---

## 📦 Dependencies

```json
{
  "express": "^4.18.2",
  "cors": "^2.8.5",
  "dotenv": "^16.3.1",
  "nodemailer": "^6.9.7",
  "jsonwebtoken": "^9.0.2",
  "axios": "^1.6.2"
}
```

---

## 🎯 Next Steps

### Immediate (Required for Full Functionality)
1. **Configure SMTP** for magic link emails
2. **Set up Google OAuth** credentials
3. **Set up GitHub OAuth** credentials
4. **Test all three authentication flows**

### Optional Enhancements
5. Set up custom domain (app.brainstorm.co)
6. Add monitoring and error tracking
7. Implement rate limiting
8. Add API documentation (Swagger/OpenAPI)

---

## 🆘 Troubleshooting

### "Magic link not configured" error
**Cause:** SMTP environment variables not set
**Solution:** Configure SMTP_HOST, SMTP_USER, SMTP_PASS

### "Google OAuth not configured" error
**Cause:** Google OAuth credentials not set
**Solution:** Configure GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET

### "GitHub OAuth not configured" error
**Cause:** GitHub OAuth credentials not set
**Solution:** Configure GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET

### App not responding
**Check:** `doctl apps get ddd6cad3-0aef-43ef-af2e-7e3c39ec629c`
**Logs:** `doctl apps logs ddd6cad3-0aef-43ef-af2e-7e3c39ec629c --type run`

---

## 📞 Support

**Repository:** https://github.com/justinjilg/brainstorm-backend
**DigitalOcean Dashboard:** https://cloud.digitalocean.com/apps/ddd6cad3-0aef-43ef-af2e-7e3c39ec629c

---

**Deployed:** December 17, 2025
**Status:** ✅ Production Ready (pending OAuth/SMTP configuration)
**Built By:** Claude Code (Anthropic)
