# ⚡️ Add Credentials in DigitalOcean Dashboard (Easiest Way)

Since you already have the credentials, here's the fastest way to add them:

## 🌐 Open DigitalOcean Dashboard

```bash
open "https://cloud.digitalocean.com/apps/ddd6cad3-0aef-43ef-af2e-7e3c39ec629c/settings"
```

## 📝 Add Environment Variables

1. Go to **Settings** tab
2. Scroll to **Environment Variables**
3. Click **Edit**
4. Add these variables:

### SendGrid
- **Key:** `SMTP_PASS`
- **Value:** Your SendGrid API key (SG.xxx...)
- **Encrypt:** ✅ Yes

### Google OAuth
- **Key:** `GOOGLE_CLIENT_ID`
- **Value:** Your Google Client ID
- **Encrypt:** ✅ Yes

- **Key:** `GOOGLE_CLIENT_SECRET`
- **Value:** Your Google Client Secret
- **Encrypt:** ✅ Yes

### GitHub OAuth
- **Key:** `GITHUB_CLIENT_ID`
- **Value:** Your GitHub Client ID
- **Encrypt:** ✅ Yes

- **Key:** `GITHUB_CLIENT_SECRET`
- **Value:** Your GitHub Client Secret
- **Encrypt:** ✅ Yes

## ✅ Save and Deploy

Click **Save** → App will automatically redeploy with new credentials (2-3 min)

---

**That's it!** No command line needed. Just paste your credentials in the web UI.
