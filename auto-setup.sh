#!/bin/bash

# Brainstorm Backend - Fully Automated Credential Setup
# This script will collect credentials and deploy automatically

set -e  # Exit on error

echo "🚀 Brainstorm Backend - Automated Setup"
echo "========================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

APP_ID="ddd6cad3-0aef-43ef-af2e-7e3c39ec629c"
JWT_SECRET="97cb08bb2379ac24f12e0ee2393c4884844fdfdee99a84e87567f6000d77150f"

echo -e "${BLUE}I'll help you set up all credentials automatically.${NC}"
echo ""
echo "I'll open the necessary pages in your browser."
echo "Just copy the credentials when ready."
echo ""
read -p "Press Enter to start..."

# Function to prompt for credential with dialog
prompt_credential() {
    local title="$1"
    local message="$2"
    local result=$(osascript -e "display dialog \"$message\" default answer \"\" with title \"$title\" buttons {\"OK\"} default button 1" -e "text returned of result" 2>/dev/null || echo "")
    echo "$result"
}

echo ""
echo -e "${YELLOW}📧 Step 1/3: SendGrid API Key${NC}"
echo "Opening SendGrid..."
open "https://app.sendgrid.com/settings/api_keys"
sleep 2

echo ""
echo "Instructions:"
echo "1. Click 'Create API Key'"
echo "2. Name: brainstorm-backend"
echo "3. Select 'Full Access'"
echo "4. Click 'Create & View'"
echo "5. Copy the API key"
echo ""

SENDGRID_KEY=$(prompt_credential "SendGrid API Key" "Paste your SendGrid API key (or leave blank to skip):")

if [ -n "$SENDGRID_KEY" ]; then
    echo -e "${GREEN}✅ SendGrid API key received${NC}"
    SMTP_HOST="smtp.sendgrid.net"
    SMTP_PORT="587"
    SMTP_USER="apikey"
    SMTP_PASS="$SENDGRID_KEY"
    SMTP_FROM="noreply@brainstorm.co"
else
    echo -e "${YELLOW}⏭️  Skipping SendGrid${NC}"
    SMTP_HOST=""
    SMTP_PORT="587"
    SMTP_USER=""
    SMTP_PASS=""
    SMTP_FROM="noreply@brainstorm.co"
fi

echo ""
echo -e "${YELLOW}🔐 Step 2/3: Google OAuth${NC}"
echo "Opening Google Cloud Console..."
open "https://console.cloud.google.com/apis/credentials"
sleep 2

echo ""
echo "Instructions:"
echo "1. Create Credentials → OAuth client ID"
echo "2. Web application"
echo "3. Redirect URI: https://brainstorm-backend-gk4th.ondigitalocean.app/auth/google/callback"
echo "4. Copy Client ID and Client Secret"
echo ""

GOOGLE_CLIENT_ID=$(prompt_credential "Google OAuth Client ID" "Paste your Google Client ID (or leave blank to skip):")

if [ -n "$GOOGLE_CLIENT_ID" ]; then
    GOOGLE_CLIENT_SECRET=$(prompt_credential "Google OAuth Client Secret" "Paste your Google Client Secret:")
    echo -e "${GREEN}✅ Google OAuth credentials received${NC}"
else
    echo -e "${YELLOW}⏭️  Skipping Google OAuth${NC}"
    GOOGLE_CLIENT_SECRET=""
fi

echo ""
echo -e "${YELLOW}🐙 Step 3/3: GitHub OAuth${NC}"
echo "Opening GitHub Developer Settings..."
open "https://github.com/settings/developers"
sleep 2

echo ""
echo "Instructions:"
echo "1. New OAuth App"
echo "2. Name: Brainstorm Backend"
echo "3. Homepage: https://brainstorm.co"
echo "4. Callback: https://brainstorm-backend-gk4th.ondigitalocean.app/auth/github/callback"
echo "5. Copy Client ID and generate Client Secret"
echo ""

GITHUB_CLIENT_ID=$(prompt_credential "GitHub OAuth Client ID" "Paste your GitHub Client ID (or leave blank to skip):")

if [ -n "$GITHUB_CLIENT_ID" ]; then
    GITHUB_CLIENT_SECRET=$(prompt_credential "GitHub OAuth Client Secret" "Paste your GitHub Client Secret:")
    echo -e "${GREEN}✅ GitHub OAuth credentials received${NC}"
else
    echo -e "${YELLOW}⏭️  Skipping GitHub OAuth${NC}"
    GITHUB_CLIENT_SECRET=""
fi

echo ""
echo -e "${BLUE}📊 Summary${NC}"
echo "========================================"
if [ -n "$SMTP_PASS" ]; then
    echo -e "SendGrid:     ${GREEN}✅ Configured${NC}"
else
    echo -e "SendGrid:     ${YELLOW}⏭️  Skipped${NC}"
fi

if [ -n "$GOOGLE_CLIENT_ID" ]; then
    echo -e "Google OAuth: ${GREEN}✅ Configured${NC}"
else
    echo -e "Google OAuth: ${YELLOW}⏭️  Skipped${NC}"
fi

if [ -n "$GITHUB_CLIENT_ID" ]; then
    echo -e "GitHub OAuth: ${GREEN}✅ Configured${NC}"
else
    echo -e "GitHub OAuth: ${YELLOW}⏭️  Skipped${NC}"
fi
echo ""

read -p "Deploy to DigitalOcean? (y/n): " deploy

if [ "$deploy" != "y" ] && [ "$deploy" != "Y" ]; then
    echo -e "${YELLOW}Deployment cancelled${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}🚀 Deploying to DigitalOcean...${NC}"

# Create the app spec with credentials
doctl apps update $APP_ID --spec - << EOF
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
        value: $JWT_SECRET
        type: SECRET
      - key: SMTP_HOST
        value: $SMTP_HOST
        type: SECRET
      - key: SMTP_PORT
        value: "$SMTP_PORT"
      - key: SMTP_USER
        value: $SMTP_USER
        type: SECRET
      - key: SMTP_PASS
        value: $SMTP_PASS
        type: SECRET
      - key: SMTP_FROM
        value: $SMTP_FROM
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

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Deployment started!${NC}"
    echo ""
    echo "Your backend is deploying now (takes 2-3 minutes)."
    echo ""
    echo "Monitor deployment:"
    echo "  doctl apps get $APP_ID"
    echo ""
    echo "View logs:"
    echo "  doctl apps logs $APP_ID --type run"
    echo ""
    echo "Test when ready:"
    echo "  curl https://brainstorm-backend-gk4th.ondigitalocean.app/api/health"
    echo ""
    echo -e "${GREEN}🎉 Setup complete!${NC}"
else
    echo -e "${RED}❌ Deployment failed${NC}"
    exit 1
fi
