#!/bin/bash
#
# list-secrets.sh
# List all stored secrets (names only, not values)
#
# Usage: ./scripts/list-secrets.sh
#

set -euo pipefail

SERVICE_PREFIX="claude-agents-cli"

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Stored Secrets in Keychain"
echo "════════════════════════════════════════════════════════════"
echo ""

# List all secrets matching our service prefix
security dump-keychain | grep -A 5 "\"svce\"<blob>=\"${SERVICE_PREFIX}" | \
    grep -E "(svce|acct)" | \
    sed 's/.*<blob>="\(.*\)"/  \1/' | \
    paste - - | \
    sed 's/\t/ → /' || echo "No secrets found"

echo ""
echo "To view a secret value:"
echo "  security find-generic-password -a ACCOUNT -s SERVICE -w"
echo ""
echo "Example:"
echo "  security find-generic-password -a url -s ${SERVICE_PREFIX}.ghost -w"
echo ""
