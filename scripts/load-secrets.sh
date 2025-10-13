#!/bin/bash
#
# load-secrets.sh
# Load secrets from macOS Keychain and export as environment variables
#
# Usage: source scripts/load-secrets.sh
#

# Keychain service name prefix
SERVICE_PREFIX="claude-agents-cli"

# Function to retrieve secret from Keychain
get_secret() {
    local service="$1"
    local account="$2"
    security find-generic-password -a "$account" -s "$service" -w 2>/dev/null || echo ""
}

# Load Ghost CMS credentials
export GHOST_URL=$(get_secret "${SERVICE_PREFIX}.ghost" "url")
export GHOST_ADMIN_API_KEY=$(get_secret "${SERVICE_PREFIX}.ghost" "api-key")

# Load Firebase credentials
export FIREBASE_TOKEN=$(get_secret "${SERVICE_PREFIX}.firebase" "token")

# Print loaded secrets (masked)
if [[ -n "$GHOST_URL" ]]; then
    echo "✓ GHOST_URL loaded"
fi

if [[ -n "$GHOST_ADMIN_API_KEY" ]]; then
    echo "✓ GHOST_ADMIN_API_KEY loaded"
fi

if [[ -n "$FIREBASE_TOKEN" ]]; then
    echo "✓ FIREBASE_TOKEN loaded"
fi

# Verify at least one secret was loaded
if [[ -z "$GHOST_URL" && -z "$FIREBASE_TOKEN" ]]; then
    echo "⚠  No secrets found in Keychain"
    echo "   Run: ./scripts/setup-secrets.sh"
    return 1
fi
