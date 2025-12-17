# ⚡️ START HERE - 5-Minute Setup

I've opened everything you need. Follow these 3 steps:

---

## 📋 Quick Steps

### 1️⃣ Get SendGrid API Key (2 min)
**Tab already open:** SendGrid API Keys

- Click **"Create API Key"**
- Name: `brainstorm-backend`
- Access: **"Full Access"**
- Click **"Create & View"**
- **Copy the 69-character key**

### 2️⃣ Get Google OAuth Credentials (2 min)
**Tab already open:** Google Cloud Console

- Click **"Create Credentials" → "OAuth client ID"**
- Type: **Web application**
- Name: **Brainstorm Backend**
- Redirect URI: `https://brainstorm-backend-gk4th.ondigitalocean.app/auth/google/callback`
- Click **"Create"**
- **Copy Client ID and Client Secret**

### 3️⃣ Get GitHub OAuth Credentials (1 min)
**Tab already open:** GitHub Developer Settings

- Click **"New OAuth App"**
- Name: **Brainstorm Backend**
- Homepage: `https://brainstorm.co`
- Callback: `https://brainstorm-backend-gk4th.ondigitalocean.app/auth/github/callback`
- Click **"Register application"**
- **Copy Client ID**
- Click **"Generate a new client secret"**
- **Copy Client Secret**

---

## 🚀 Deploy

**TextEdit is open** with `paste-and-deploy.sh`

1. **Paste your 5 credentials** into the script (replace the PASTE_YOUR_... placeholders)
2. **Save the file** (Cmd+S)
3. **Run in terminal:**
   ```bash
   ~/brainstorm-backend/paste-and-deploy.sh
   ```

Done! Your backend deploys in 2-3 minutes.

---

## ✅ Test When Ready

```bash
# Health check
curl https://brainstorm-backend-gk4th.ondigitalocean.app/api/health

# Magic link
curl -X POST https://brainstorm-backend-gk4th.ondigitalocean.app/api/v1/auth/magic-link \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","site_url":"https://test.com","redirect_url":"https://test.com"}'

# Google OAuth
curl "https://brainstorm-backend-gk4th.ondigitalocean.app/api/v1/auth/google/url?site_url=https://test.com&redirect_url=https://test.com"

# GitHub OAuth
curl "https://brainstorm-backend-gk4th.ondigitalocean.app/api/v1/auth/github/url?site_url=https://test.com&redirect_url=https://test.com"
```

---

**Total time:** 5 minutes
**Total cost:** FREE (SendGrid, Google, GitHub all free)

The browser tabs and TextEdit are ready for you! 🎉
