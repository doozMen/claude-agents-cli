#!/bin/bash
#
# update-mcp-config.sh
# Update Claude MCP configuration to use environment variables
#
# Usage: ./scripts/update-mcp-config.sh
#

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

CONFIG_FILE="$HOME/.config/claude/mcp.json"
BACKUP_FILE="${CONFIG_FILE}.backup"

print_info() {
    echo -e "${BLUE}ℹ${NC}  $1"
}

print_success() {
    echo -e "${GREEN}✓${NC}  $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC}  $1"
}

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Update MCP Configuration"
echo "════════════════════════════════════════════════════════════"
echo ""

# Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    print_warning "MCP config not found at: $CONFIG_FILE"
    print_info "Creating new configuration..."
    mkdir -p "$(dirname "$CONFIG_FILE")"
    echo '{"mcpServers":{}}' > "$CONFIG_FILE"
fi

# Backup existing config
cp "$CONFIG_FILE" "$BACKUP_FILE"
print_success "Backed up existing config to: $BACKUP_FILE"

# Load secrets to check what's available
source scripts/load-secrets.sh >/dev/null 2>&1 || true

# Create updated configuration
cat > "$CONFIG_FILE" << 'EOF'
{
  "mcpServers": {
    "firebase": {
      "command": "firebase",
      "args": ["experimental:mcp"],
      "env": {
        "FIREBASE_TOKEN": ""
      },
      "description": "Firebase MCP server for Crashlytics analysis"
    },
    "tech-conf": {
      "command": "/Users/stijnwillems/.swiftpm/bin/tech-conf-mcp",
      "args": ["server", "--log-level", "info"],
      "env": {
        "PATH": "/Users/stijnwillems/.swiftpm/bin:/usr/local/bin:/usr/bin:/bin"
      },
      "description": "Tech Conference MCP Server"
    },
    "ghost": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-ghost"],
      "env": {
        "GHOST_URL": "",
        "GHOST_ADMIN_API_KEY": ""
      },
      "description": "Ghost CMS MCP server for blog publishing"
    }
  }
}
EOF

# Update with actual values if available
if [[ -n "${FIREBASE_TOKEN:-}" ]]; then
    sed -i '' "s|\"FIREBASE_TOKEN\": \"\"|\"FIREBASE_TOKEN\": \"$FIREBASE_TOKEN\"|" "$CONFIG_FILE"
fi

if [[ -n "${GHOST_URL:-}" ]]; then
    sed -i '' "s|\"GHOST_URL\": \"\"|\"GHOST_URL\": \"$GHOST_URL\"|" "$CONFIG_FILE"
fi

if [[ -n "${GHOST_ADMIN_API_KEY:-}" ]]; then
    sed -i '' "s|\"GHOST_ADMIN_API_KEY\": \"\"|\"GHOST_ADMIN_API_KEY\": \"$GHOST_ADMIN_API_KEY\"|" "$CONFIG_FILE"
fi

print_success "Updated MCP configuration"
echo ""
print_info "Configuration file: $CONFIG_FILE"
print_info "Backup file: $BACKUP_FILE"
echo ""
print_warning "⚠  Restart Claude Code to load the new configuration"
echo ""
