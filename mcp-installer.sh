#!/bin/bash

# Brainstorm MCP Server - One-Click Installer
# Usage: curl https://brainstorm-backend-gk4th.ondigitalocean.app/install | bash

echo "🚀 Installing Brainstorm MCP Server for Claude Code..."
echo ""

# Get parameters from query string (passed by WordPress)
SITE_URL="${SITE_URL:-}"
API_KEY="${API_KEY:-}"
SITE_NAME="${SITE_NAME:-My WordPress Site}"

if [ -z "$SITE_URL" ] || [ -z "$API_KEY" ]; then
    echo "❌ Error: Missing site URL or API key"
    echo ""
    echo "This script should be run from your WordPress admin panel."
    echo "Please click the 'Setup Claude Code' button in your plugin."
    exit 1
fi

echo "📝 Configuration:"
echo "   Site: $SITE_NAME"
echo "   URL: $SITE_URL"
echo ""

# Detect Claude Code config location
if [ -f "$HOME/.claude/config.json" ]; then
    CONFIG_FILE="$HOME/.claude/config.json"
elif [ -f "$HOME/Library/Application Support/Claude/claude_desktop_config.json" ]; then
    CONFIG_FILE="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
else
    # Create default location
    mkdir -p "$HOME/.claude"
    CONFIG_FILE="$HOME/.claude/config.json"
fi

echo "📁 Config file: $CONFIG_FILE"

# Create backup
if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "${CONFIG_FILE}.backup.$(date +%s)"
    echo "✅ Backed up existing config"
fi

# Generate safe site key (remove special chars)
SITE_KEY=$(echo "$SITE_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')

# Create/update MCP config
if [ -f "$CONFIG_FILE" ]; then
    # Parse existing config and add new server
    python3 << PYTHON
import json
import sys

config_file = "$CONFIG_FILE"
site_key = "$SITE_KEY"
site_url = "$SITE_URL"
api_key = "$API_KEY"

try:
    with open(config_file, 'r') as f:
        config = json.load(f)
except:
    config = {}

if 'mcpServers' not in config:
    config['mcpServers'] = {}

config['mcpServers'][site_key] = {
    "command": "npx",
    "args": ["-y", "@brainstorm/wordpress-mcp"],
    "env": {
        "WORDPRESS_URL": site_url,
        "WORDPRESS_API_KEY": api_key
    }
}

with open(config_file, 'w') as f:
    json.dump(config, f, indent=2)

print(f"✅ Added '{site_key}' to Claude Code config")
PYTHON
else
    # Create new config
    cat > "$CONFIG_FILE" << EOF
{
  "mcpServers": {
    "$SITE_KEY": {
      "command": "npx",
      "args": ["-y", "@brainstorm/wordpress-mcp"],
      "env": {
        "WORDPRESS_URL": "$SITE_URL",
        "WORDPRESS_API_KEY": "$API_KEY"
      }
    }
  }
}
EOF
    echo "✅ Created new Claude Code config"
fi

echo ""
echo "🎉 Installation Complete!"
echo ""
echo "Next steps:"
echo "  1. Restart Claude Code (if running)"
echo "  2. Open Claude Code"
echo "  3. Your WordPress site '$SITE_NAME' is ready to edit!"
echo ""
echo "Try asking Claude:"
echo '  "Show me my WordPress site info"'
echo '  "List my recent posts"'
echo '  "Create a new page called About Us"'
echo ""
