#!/bin/bash
#
# setup-secrets.sh
# Interactive script to securely store project secrets in macOS Keychain
#
# Usage: ./scripts/setup-secrets.sh
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Keychain service name prefix
SERVICE_PREFIX="claude-agents-cli"

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ${NC}  $1"
}

print_success() {
    echo -e "${GREEN}✓${NC}  $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC}  $1"
}

print_error() {
    echo -e "${RED}✗${NC}  $1"
}

# Function to store secret in Keychain
store_secret() {
    local service="$1"
    local account="$2"
    local secret="$3"
    local description="$4"

    # Check if secret already exists
    if security find-generic-password -a "$account" -s "$service" &>/dev/null; then
        print_warning "Secret already exists: $description"
        read -p "Update it? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Skipped: $description"
            return 0
        fi
        # Delete existing secret
        security delete-generic-password -a "$account" -s "$service" &>/dev/null || true
    fi

    # Add new secret
    if security add-generic-password -a "$account" -s "$service" -w "$secret" -U; then
        print_success "Stored: $description"
        return 0
    else
        print_error "Failed to store: $description"
        return 1
    fi
}

# Function to validate URL format
validate_url() {
    local url="$1"
    if [[ $url =~ ^https?:// ]]; then
        return 0
    else
        return 1
    fi
}

# Function to validate Ghost API key format
validate_ghost_api_key() {
    local key="$1"
    # Format: hexid:hexsecret
    if [[ $key =~ ^[a-f0-9]+:[a-f0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Main setup function
main() {
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "  Claude Agents CLI - Secrets Setup"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    print_info "This script will store secrets securely in macOS Keychain"
    echo ""

    # Check if running on macOS
    if [[ $(uname) != "Darwin" ]]; then
        print_error "This script requires macOS (uses Keychain)"
        exit 1
    fi

    # Ghost CMS Credentials
    echo ""
    echo "────────────────────────────────────────────────────────────"
    echo "  Ghost CMS Configuration"
    echo "────────────────────────────────────────────────────────────"
    echo ""

    read -p "Configure Ghost CMS? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Ghost URL
        while true; do
            read -p "Ghost URL (e.g., https://yoursite.ghost.io): " ghost_url
            if validate_url "$ghost_url"; then
                # Remove trailing slash
                ghost_url="${ghost_url%/}"
                store_secret "${SERVICE_PREFIX}.ghost" "url" "$ghost_url" "Ghost URL"
                break
            else
                print_error "Invalid URL format. Must start with http:// or https://"
            fi
        done

        # Ghost Admin API Key
        while true; do
            echo ""
            print_info "Get your Ghost Admin API Key from:"
            print_info "  $ghost_url/ghost/#/settings/integrations"
            echo ""
            read -sp "Ghost Admin API Key (format: id:secret): " ghost_api_key
            echo ""
            if validate_ghost_api_key "$ghost_api_key"; then
                store_secret "${SERVICE_PREFIX}.ghost" "api-key" "$ghost_api_key" "Ghost Admin API Key"
                break
            else
                print_error "Invalid API key format. Expected format: hexid:hexsecret"
                print_info "Example: 68e52dc931b35d0001eadcd5:f630615eb59b6f41bc75f46361d7f2661a9cf4c587d78d95f8e0102d568eaa3"
            fi
        done
    fi

    # Firebase Token
    echo ""
    echo "────────────────────────────────────────────────────────────"
    echo "  Firebase Configuration"
    echo "────────────────────────────────────────────────────────────"
    echo ""

    read -p "Configure Firebase? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        print_info "Get your Firebase token by running:"
        print_info "  firebase login:ci"
        echo ""
        read -sp "Firebase Token: " firebase_token
        echo ""
        if [[ -n "$firebase_token" ]]; then
            store_secret "${SERVICE_PREFIX}.firebase" "token" "$firebase_token" "Firebase Token"
        else
            print_warning "Empty token, skipping Firebase configuration"
        fi
    fi

    # Additional MCP Servers
    echo ""
    echo "────────────────────────────────────────────────────────────"
    echo "  Additional MCP Servers"
    echo "────────────────────────────────────────────────────────────"
    echo ""

    read -p "Add custom MCP server credentials? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        while true; do
            echo ""
            read -p "MCP Server name (e.g., github, gitlab): " mcp_name
            if [[ -z "$mcp_name" ]]; then
                break
            fi

            read -p "Secret key name (e.g., api-token, access-key): " secret_key
            read -sp "Secret value: " secret_value
            echo ""

            if [[ -n "$secret_value" ]]; then
                store_secret "${SERVICE_PREFIX}.${mcp_name}" "$secret_key" "$secret_value" "${mcp_name} ${secret_key}"
            fi

            echo ""
            read -p "Add another secret? (y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                break
            fi
        done
    fi

    # Summary
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "  Setup Complete"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    print_success "Secrets stored securely in macOS Keychain"
    echo ""
    print_info "Next steps:"
    echo "  1. Run: source scripts/load-secrets.sh"
    echo "  2. Run: ./scripts/update-mcp-config.sh"
    echo "  3. Restart Claude Code to load new configuration"
    echo ""
    print_info "To view stored secrets:"
    echo "  ./scripts/list-secrets.sh"
    echo ""
    print_info "To update secrets:"
    echo "  ./scripts/setup-secrets.sh (re-run this script)"
    echo ""
}

main "$@"
