# 🚀 Quick Credentials Setup Guide

I've opened three tabs in your browser. Follow these steps to get all your credentials.

---

## ✅ Step 1: SendGrid (Tab 1)

**URL:** https://signup.sendgrid.com/

### What to do:
1. ✅ Create free account
2. ✅ Verify your email
3. ✅ Enable 2FA (SMS or Authy) - **required by SendGrid**
4. ✅ Go to **Settings → API Keys**
5. ✅ Click **"Create API Key"**
6. ✅ Name it: `brainstorm-backend`
7. ✅ Select **"Full Access"**
8. ✅ Click **"Create & View"**
9. ✅ **COPY THE KEY NOW** (you won't see it again!)

**You'll get:** A 69-character API key like `SG.abc123...`

**Save it as:** `SENDGRID_API_KEY`

---

## ✅ Step 2: Google OAuth (Tab 2)

**URL:** https://console.cloud.google.com/apis/credentials

### What to do:
1. ✅ Create new project (or select existing one)
2. ✅ Click **"Create Credentials" → "OAuth client ID"**
3. ✅ If prompted, configure **OAuth consent screen**:
   - User Type: **External**
   - App name: **Brainstorm**
   - User support email: **your email**
   - Developer email: **your email**
   - Click **"Save and Continue"** (skip optional fields)
4. ✅ Back to credentials, create **OAuth client ID**:
   - Application type: **Web application**
   - Name: **Brainstorm Backend**
   - Authorized redirect URIs - click **"Add URI"**:
     ```
     https://brainstorm-backend-gk4th.ondigitalocean.app/auth/google/callback
     ```
5. ✅ Click **"Create"**
6. ✅ **COPY both Client ID and Client Secret**

**You'll get:**
- Client ID: `xxx.apps.googleusercontent.com`
- Client Secret: `GOCSPX-xxx`

**Save them as:** `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`

---

## ✅ Step 3: GitHub OAuth (Tab 3)

**URL:** https://github.com/settings/developers

### What to do:
1. ✅ Click **"New OAuth App"** (or "OAuth Apps" → "New OAuth App")
2. ✅ Fill in the form:
   - Application name: **Brainstorm Backend**
   - Homepage URL: **https://brainstorm.co**
   - Application description: **Authentication for Brainstorm WordPress plugin**
   - Authorization callback URL:
     ```
     https://brainstorm-backend-gk4th.ondigitalocean.app/auth/github/callback
     ```
3. ✅ Click **"Register application"**
4. ✅ **COPY the Client ID**
5. ✅ Click **"Generate a new client secret"**
6. ✅ **COPY the Client Secret** (you won't see it again!)

**You'll get:**
- Client ID: `Iv1.xxx` (or similar)
- Client Secret: `xxx` (long string)

**Save them as:** `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET`

---

## 🔧 Step 4: Deploy to DigitalOcean

Once you have all the credentials above, run this command:

```bash
cd ~/brainstorm-backend

doctl apps update ddd6cad3-0aef-43ef-af2e-7e3c39ec629c --spec - << 'EOF'
name: brainstorm-backend
region: nyc
services:
  - name: api
    github:
      repo: justinjilg/brainstorm-backend
      branch: main
      deploy_on_push: true
    source_dir: /
    environment_slug: node-js
    instance_count: 1
    instance_size_slug: basic-xxs
    http_port: 3000
    routes:
      - path: /
    envs:
      - key: NODE_ENV
        value: production
      - key: PORT
        value: "3000"
      - key: APP_URL
        value: https://brainstorm-backend-gk4th.ondigitalocean.app
      - key: JWT_SECRET
        value: 97cb08bb2379ac24f12e0ee2393c4884844fdfdee99a84e87567f6000d77150f
        type: SECRET
      - key: SMTP_HOST
        value: smtp.sendgrid.net
        type: SECRET
      - key: SMTP_PORT
        value: "587"
      - key: SMTP_USER
        value: apikey
        type: SECRET
      - key: SMTP_PASS
        value: YOUR_SENDGRID_API_KEY_HERE
        type: SECRET
      - key: SMTP_FROM
        value: noreply@brainstorm.co
      - key: GOOGLE_CLIENT_ID
        value: YOUR_GOOGLE_CLIENT_ID_HERE
        type: SECRET
      - key: GOOGLE_CLIENT_SECRET
        value: YOUR_GOOGLE_CLIENT_SECRET_HERE
        type: SECRET
      - key: GITHUB_CLIENT_ID
        value: YOUR_GITHUB_CLIENT_ID_HERE
        type: SECRET
      - key: GITHUB_CLIENT_SECRET
        value: YOUR_GITHUB_CLIENT_SECRET_HERE
        type: SECRET
EOF
```

**Replace:**
- `YOUR_SENDGRID_API_KEY_HERE` → Your SendGrid API key
- `YOUR_GOOGLE_CLIENT_ID_HERE` → Your Google Client ID
- `YOUR_GOOGLE_CLIENT_SECRET_HERE` → Your Google Client Secret
- `YOUR_GITHUB_CLIENT_ID_HERE` → Your GitHub Client ID
- `YOUR_GITHUB_CLIENT_SECRET_HERE` → Your GitHub Client Secret

---

## ✅ Step 5: Verify Deployment

Wait 2-3 minutes for deployment, then test:

```bash
# Check deployment status
doctl apps get ddd6cad3-0aef-43ef-af2e-7e3c39ec629c

# Test health endpoint
curl https://brainstorm-backend-gk4th.ondigitalocean.app/api/health

# Test magic link (should work if SMTP configured)
curl -X POST https://brainstorm-backend-gk4th.ondigitalocean.app/api/v1/auth/magic-link \
  -H "Content-Type: application/json" \
  -d '{"email":"your-email@example.com","site_url":"https://test.com","redirect_url":"https://test.com"}'

# Test Google OAuth (should work if Google configured)
curl "https://brainstorm-backend-gk4th.ondigitalocean.app/api/v1/auth/google/url?site_url=https://test.com&redirect_url=https://test.com"

# Test GitHub OAuth (should work if GitHub configured)
curl "https://brainstorm-backend-gk4th.ondigitalocean.app/api/v1/auth/github/url?site_url=https://test.com&redirect_url=https://test.com"
```

---

## 🎯 What Each Service Costs

- **SendGrid:** FREE (100 emails/day for 60 days, then upgrade or switch)
- **Google OAuth:** FREE
- **GitHub OAuth:** FREE
- **DigitalOcean:** ~$5/month (basic-xxs app)

---

## 📞 Need Help?

**SendGrid Issues:**
- Verification email not received? Check spam folder
- 2FA required? Use SMS or download Authy app
- API key not showing? It only shows once - create a new one if lost

**Google OAuth Issues:**
- "OAuth consent screen required"? Configure it in step 3 above
- Can't find credentials page? Make sure you've created/selected a project

**GitHub OAuth Issues:**
- Can't find OAuth Apps? Go to Settings → Developer settings → OAuth Apps

---

## 🚀 Quick Reference

| Service | What You Need | Where to Get It |
|---------|--------------|-----------------|
| SendGrid | API Key (69 chars) | Settings → API Keys |
| Google | Client ID + Secret | Cloud Console → Credentials |
| GitHub | Client ID + Secret | Settings → Developer settings → OAuth Apps |

---

**Estimated time:** 15 minutes total

**You're doing:** Steps 1-3 (getting credentials)
**I already did:** Backend deployment, JWT configuration, documentation
**Next:** Copy credentials into the doctl command above and run it

---

Good luck! The three browser tabs should be open and ready for you. 🚀
