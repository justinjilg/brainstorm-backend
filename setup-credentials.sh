#!/bin/bash

# Brainstorm Backend - Credentials Setup Script
# This script will help you configure all required credentials

echo "🔐 Brainstorm Backend Credentials Setup"
echo "========================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

APP_ID="ddd6cad3-0aef-43ef-af2e-7e3c39ec629c"

# Function to update app with all credentials
update_app_credentials() {
    echo -e "${BLUE}Updating DigitalOcean app with credentials...${NC}"

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
        echo -e "${GREEN}✅ Credentials updated successfully!${NC}"
        echo -e "${YELLOW}App is redeploying with new credentials...${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to update credentials${NC}"
        return 1
    fi
}

# Check if doctl is authenticated
if ! doctl auth list &> /dev/null; then
    echo -e "${RED}❌ doctl is not authenticated${NC}"
    echo "Please run: doctl auth init"
    exit 1
fi

echo -e "${GREEN}✅ doctl is authenticated${NC}"
echo ""

# 1. SMTP Setup
echo -e "${YELLOW}1️⃣  SMTP Configuration (SendGrid)${NC}"
echo "--------------------------------------"
echo ""
echo "📧 You need a SendGrid account to send magic link emails."
echo ""
echo -e "${BLUE}Options:${NC}"
echo "  a) I already have SendGrid API key"
echo "  b) Help me create a SendGrid account"
echo "  c) Skip SMTP for now"
echo ""
read -p "Choose (a/b/c): " smtp_choice

case $smtp_choice in
    a)
        echo ""
        read -p "Enter SendGrid API key: " SMTP_PASS
        SMTP_HOST="smtp.sendgrid.net"
        SMTP_PORT="587"
        SMTP_USER="apikey"
        read -p "Enter 'From' email (e.g., noreply@brainstorm.co): " SMTP_FROM
        echo -e "${GREEN}✅ SMTP configured${NC}"
        ;;
    b)
        echo ""
        echo -e "${BLUE}Opening SendGrid signup page...${NC}"
        open "https://signup.sendgrid.com/"
        echo ""
        echo "📝 Setup Steps:"
        echo "  1. Create free account at SendGrid"
        echo "  2. Verify your email"
        echo "  3. Enable 2FA (required by SendGrid)"
        echo "  4. Go to Settings → API Keys"
        echo "  5. Create API Key with 'Full Access'"
        echo "  6. Copy the API key (it won't be shown again!)"
        echo ""
        read -p "Press Enter when you have your API key..."
        read -p "Paste SendGrid API key: " SMTP_PASS
        SMTP_HOST="smtp.sendgrid.net"
        SMTP_PORT="587"
        SMTP_USER="apikey"
        read -p "Enter 'From' email (e.g., noreply@brainstorm.co): " SMTP_FROM
        echo -e "${GREEN}✅ SMTP configured${NC}"
        ;;
    c)
        echo -e "${YELLOW}⏭️  Skipping SMTP${NC}"
        SMTP_HOST=""
        SMTP_PORT="587"
        SMTP_USER=""
        SMTP_PASS=""
        SMTP_FROM="noreply@brainstorm.co"
        ;;
esac

echo ""
echo ""

# 2. Google OAuth Setup
echo -e "${YELLOW}2️⃣  Google OAuth Configuration${NC}"
echo "--------------------------------------"
echo ""
echo "🔐 You need a Google OAuth app for 'Continue with Google'."
echo ""
echo -e "${BLUE}Options:${NC}"
echo "  a) I already have Google OAuth credentials"
echo "  b) Help me create a Google OAuth app"
echo "  c) Skip Google OAuth for now"
echo ""
read -p "Choose (a/b/c): " google_choice

case $google_choice in
    a)
        echo ""
        read -p "Enter Google Client ID: " GOOGLE_CLIENT_ID
        read -p "Enter Google Client Secret: " GOOGLE_CLIENT_SECRET
        echo -e "${GREEN}✅ Google OAuth configured${NC}"
        ;;
    b)
        echo ""
        echo -e "${BLUE}Opening Google Cloud Console...${NC}"
        open "https://console.cloud.google.com/apis/credentials"
        echo ""
        echo "📝 Setup Steps:"
        echo "  1. Create new project (or select existing)"
        echo "  2. Click 'Create Credentials' → 'OAuth client ID'"
        echo "  3. Configure consent screen if prompted"
        echo "  4. Application type: 'Web application'"
        echo "  5. Add authorized redirect URI:"
        echo "     https://brainstorm-backend-gk4th.ondigitalocean.app/auth/google/callback"
        echo "  6. Click 'Create'"
        echo "  7. Copy Client ID and Client Secret"
        echo ""
        read -p "Press Enter when you have your credentials..."
        read -p "Paste Google Client ID: " GOOGLE_CLIENT_ID
        read -p "Paste Google Client Secret: " GOOGLE_CLIENT_SECRET
        echo -e "${GREEN}✅ Google OAuth configured${NC}"
        ;;
    c)
        echo -e "${YELLOW}⏭️  Skipping Google OAuth${NC}"
        GOOGLE_CLIENT_ID=""
        GOOGLE_CLIENT_SECRET=""
        ;;
esac

echo ""
echo ""

# 3. GitHub OAuth Setup
echo -e "${YELLOW}3️⃣  GitHub OAuth Configuration${NC}"
echo "--------------------------------------"
echo ""
echo "🔐 You need a GitHub OAuth app for 'Continue with GitHub'."
echo ""
echo -e "${BLUE}Options:${NC}"
echo "  a) I already have GitHub OAuth credentials"
echo "  b) Help me create a GitHub OAuth app"
echo "  c) Skip GitHub OAuth for now"
echo ""
read -p "Choose (a/b/c): " github_choice

case $github_choice in
    a)
        echo ""
        read -p "Enter GitHub Client ID: " GITHUB_CLIENT_ID
        read -p "Enter GitHub Client Secret: " GITHUB_CLIENT_SECRET
        echo -e "${GREEN}✅ GitHub OAuth configured${NC}"
        ;;
    b)
        echo ""
        echo -e "${BLUE}Opening GitHub OAuth Apps page...${NC}"
        open "https://github.com/settings/developers"
        echo ""
        echo "📝 Setup Steps:"
        echo "  1. Click 'New OAuth App'"
        echo "  2. Application name: 'Brainstorm Backend'"
        echo "  3. Homepage URL: https://brainstorm.co"
        echo "  4. Authorization callback URL:"
        echo "     https://brainstorm-backend-gk4th.ondigitalocean.app/auth/github/callback"
        echo "  5. Click 'Register application'"
        echo "  6. Copy Client ID"
        echo "  7. Click 'Generate a new client secret' and copy it"
        echo ""
        read -p "Press Enter when you have your credentials..."
        read -p "Paste GitHub Client ID: " GITHUB_CLIENT_ID
        read -p "Paste GitHub Client Secret: " GITHUB_CLIENT_SECRET
        echo -e "${GREEN}✅ GitHub OAuth configured${NC}"
        ;;
    c)
        echo -e "${YELLOW}⏭️  Skipping GitHub OAuth${NC}"
        GITHUB_CLIENT_ID=""
        GITHUB_CLIENT_SECRET=""
        ;;
esac

echo ""
echo ""

# JWT Secret (already configured, but show it)
JWT_SECRET="97cb08bb2379ac24f12e0ee2393c4884844fdfdee99a84e87567f6000d77150f"

# Summary
echo -e "${BLUE}📊 Configuration Summary${NC}"
echo "========================================"
echo ""
echo "SMTP (Magic Links):"
if [ -n "$SMTP_PASS" ]; then
    echo -e "  ${GREEN}✅ Configured${NC} (Host: $SMTP_HOST)"
else
    echo -e "  ${YELLOW}⏭️  Skipped${NC}"
fi
echo ""
echo "Google OAuth:"
if [ -n "$GOOGLE_CLIENT_ID" ]; then
    echo -e "  ${GREEN}✅ Configured${NC}"
else
    echo -e "  ${YELLOW}⏭️  Skipped${NC}"
fi
echo ""
echo "GitHub OAuth:"
if [ -n "$GITHUB_CLIENT_ID" ]; then
    echo -e "  ${GREEN}✅ Configured${NC}"
else
    echo -e "  ${YELLOW}⏭️  Skipped${NC}"
fi
echo ""
echo "JWT Secret:"
echo -e "  ${GREEN}✅ Configured${NC}"
echo ""
echo ""

# Ask to deploy
read -p "Deploy these credentials to DigitalOcean? (y/n): " deploy_choice

if [ "$deploy_choice" = "y" ] || [ "$deploy_choice" = "Y" ]; then
    update_app_credentials

    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}🎉 All done!${NC}"
        echo ""
        echo "Your backend is deploying with the new credentials."
        echo "This will take about 2-3 minutes."
        echo ""
        echo "Monitor deployment:"
        echo "  doctl apps get $APP_ID"
        echo ""
        echo "View logs:"
        echo "  doctl apps logs $APP_ID --type run"
    fi
else
    echo -e "${YELLOW}Deployment cancelled.${NC}"
    echo ""
    echo "You can deploy manually with:"
    echo "  doctl apps update $APP_ID --spec .do/app.yaml"
fi
