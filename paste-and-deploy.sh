#!/bin/bash

# Brainstorm Backend - Simple Paste & Deploy
# Just paste your credentials below and run this script

# ============================================
# PASTE YOUR CREDENTIALS HERE:
# ============================================

# SendGrid (get from: https://app.sendgrid.com/settings/api_keys)
SENDGRID_API_KEY="PASTE_YOUR_SENDGRID_KEY_HERE"

# Google OAuth (get from: https://console.cloud.google.com/apis/credentials)
GOOGLE_CLIENT_ID="PASTE_YOUR_GOOGLE_CLIENT_ID_HERE"
GOOGLE_CLIENT_SECRET="PASTE_YOUR_GOOGLE_CLIENT_SECRET_HERE"

# GitHub OAuth (get from: https://github.com/settings/developers)
GITHUB_CLIENT_ID="PASTE_YOUR_GITHUB_CLIENT_ID_HERE"
GITHUB_CLIENT_SECRET="PASTE_YOUR_GITHUB_CLIENT_SECRET_HERE"

# ============================================
# NO NEED TO EDIT BELOW THIS LINE
# ============================================

echo "🚀 Deploying Brainstorm Backend..."

doctl apps update ddd6cad3-0aef-43ef-af2e-7e3c39ec629c --spec - << EOF
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
        value: $SENDGRID_API_KEY
        type: SECRET
      - key: SMTP_FROM
        value: noreply@brainstorm.co
      - key: GOOGLE_CLIENT_ID
        value: $GOOGLE_CLIENT_ID
        type: SECRET
      - key: GOOGLE_CLIENT_SECRET
        value: $GOOGLE_CLIENT_SECRET
        type: SECRET
      - key: GITHUB_CLIENT_ID
        value: $GITHUB_CLIENT_ID
        type: SECRET
      - key: GITHUB_CLIENT_SECRET
        value: $GITHUB_CLIENT_SECRET
        type: SECRET
EOF

echo ""
echo "✅ Deployed! Backend will be ready in 2-3 minutes."
echo ""
echo "Test: curl https://brainstorm-backend-gk4th.ondigitalocean.app/api/health"
