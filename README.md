# Brainstorm Backend API

Authentication backend for Brainstorm WordPress plugin, supporting magic link, Google OAuth, and GitHub OAuth authentication.

**Live URL:** https://brainstorm-backend-gk4th.ondigitalocean.app

---

## 🚀 Quick Start

### Health Check
```bash
curl https://brainstorm-backend-gk4th.ondigitalocean.app/api/health
```

### Authentication Endpoints
- `POST /api/v1/auth/magic-link` - Send magic link to email
- `GET /api/v1/auth/google/url` - Get Google OAuth URL
- `GET /api/v1/auth/github/url` - Get GitHub OAuth URL
- `GET /auth/google/callback` - Google OAuth callback
- `GET /auth/github/callback` - GitHub OAuth callback

---

## 📦 Features

- **Magic Link Authentication**: Passwordless login via email
- **Google OAuth**: "Continue with Google" integration
- **GitHub OAuth**: "Continue with GitHub" integration
- **JWT Tokens**: Secure session management
- **CORS Enabled**: Cross-origin WordPress integration
- **Auto-Deploy**: Push to main branch → automatic deployment

---

## 🔧 Local Development

```bash
# Clone repository
git clone https://github.com/justinjilg/brainstorm-backend.git
cd brainstorm-backend

# Install dependencies
npm install

# Configure environment variables
cp .env.example .env
# Edit .env with your credentials

# Start development server
npm start
```

---

## 📖 Documentation

- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Complete deployment guide
- **[.env.example](.env.example)** - Environment variables template

---

## 🌐 Production Deployment

**Platform:** DigitalOcean App Platform
**App ID:** ddd6cad3-0aef-43ef-af2e-7e3c39ec629c
**Region:** NYC

See [DEPLOYMENT.md](DEPLOYMENT.md) for full deployment documentation.

---

## 🔐 Environment Variables

### Required for Magic Links
- `SMTP_HOST` - SMTP server hostname
- `SMTP_PORT` - SMTP server port (587)
- `SMTP_USER` - SMTP username
- `SMTP_PASS` - SMTP password
- `SMTP_FROM` - From email address

### Required for Google OAuth
- `GOOGLE_CLIENT_ID` - Google OAuth client ID
- `GOOGLE_CLIENT_SECRET` - Google OAuth client secret

### Required for GitHub OAuth
- `GITHUB_CLIENT_ID` - GitHub OAuth client ID
- `GITHUB_CLIENT_SECRET` - GitHub OAuth client secret

### System
- `JWT_SECRET` - JWT signing key (✅ configured)
- `APP_URL` - Backend URL (✅ configured)
- `NODE_ENV` - Environment (✅ production)
- `PORT` - Server port (✅ 3000)

---

## 🧪 Testing

```bash
# Health check
curl https://brainstorm-backend-gk4th.ondigitalocean.app/api/health

# Magic link (requires SMTP)
curl -X POST https://brainstorm-backend-gk4th.ondigitalocean.app/api/v1/auth/magic-link \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","site_url":"https://mysite.com","redirect_url":"https://mysite.com/wp-admin"}'

# Google OAuth URL (requires Google OAuth)
curl "https://brainstorm-backend-gk4th.ondigitalocean.app/api/v1/auth/google/url?site_url=https://mysite.com&redirect_url=https://mysite.com/wp-admin"

# GitHub OAuth URL (requires GitHub OAuth)
curl "https://brainstorm-backend-gk4th.ondigitalocean.app/api/v1/auth/github/url?site_url=https://mysite.com&redirect_url=https://mysite.com/wp-admin"
```

---

## 📊 Stack

- **Runtime:** Node.js 18+
- **Framework:** Express.js 4.x
- **Authentication:** JWT (jsonwebtoken)
- **Email:** Nodemailer
- **HTTP Client:** Axios

---

## 🔄 Continuous Deployment

Push to `main` branch triggers automatic deployment:

```bash
git add .
git commit -m "Your changes"
git push origin main
```

---

## 📞 Support

**Repository:** https://github.com/justinjilg/brainstorm-backend
**Issues:** https://github.com/justinjilg/brainstorm-backend/issues

---

**Status:** ✅ Deployed and operational
**Version:** 1.0.0
**Last Updated:** December 17, 2025
