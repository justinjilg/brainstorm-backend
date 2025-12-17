#!/bin/bash

echo "🚀 Setting up Supabase for Brainstorm..."
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cat > .env << 'EOF'
# Supabase Configuration
SUPABASE_URL=<your-supabase-url>
SUPABASE_ANON_KEY=<your-supabase-anon-key>
SUPABASE_SERVICE_ROLE_KEY=<your-supabase-service-role-key>

# Existing config
PORT=3000
APP_URL=https://app.brainstorm.co
JWT_SECRET=your-secret-key-change-in-production
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASS=<your-sendgrid-api-key>
SMTP_FROM=noreply@brainstorm.co
GOOGLE_CLIENT_ID=<your-google-client-id>
GOOGLE_CLIENT_SECRET=<your-google-client-secret>
GITHUB_CLIENT_ID=<your-github-client-id>
GITHUB_CLIENT_SECRET=<your-github-client-secret>
EOF
    echo "✅ .env file created"
fi

# Install Supabase client
echo "📦 Installing Supabase client..."
npm install @supabase/supabase-js

echo ""
echo "✅ Supabase setup complete!"
echo ""
echo "Next steps:"
echo "  1. Go to https://supabase.com/dashboard/project/ldacavhywflwvtrbjftg"
echo "  2. Click 'SQL Editor' in the left sidebar"
echo "  3. Create a new query and paste the contents of supabase-schema.sql"
echo "  4. Run the query to create the tables"
echo "  5. Come back here and we'll update the backend code"
echo ""
