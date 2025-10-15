#!/bin/bash
#
# Automatic SwiftLens Index Rebuild Hook
#
# This script triggers SwiftLens index rebuilding when .swift files are modified.
# It implements a 900-second (15-minute) cooldown to prevent excessive rebuilds.
#
# Usage: Called automatically by Claude Code hooks after Write/Edit operations.
#

set -euo pipefail

# Configuration
COOLDOWN_SECONDS=900  # 15 minutes
LOCKFILE="/tmp/swiftlens-rebuild-lock"
TIMESTAMP_FILE="/tmp/swiftlens-rebuild-timestamp"

# Read JSON input from Claude Code hook
INPUT=$(cat)

# Extract file path from JSON input (using jq if available, otherwise fallback)
if command -v jq &> /dev/null; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.file_path // empty')
else
    # Fallback: Simple grep extraction (less reliable)
    FILE_PATH=$(echo "$INPUT" | grep -o '"file_path":"[^"]*"' | cut -d'"' -f4 || echo "")
fi

# Check if the modified file is a .swift file
if [[ ! "$FILE_PATH" =~ \.swift$ ]]; then
    # Not a Swift file, exit without action
    echo '{"decision": "allow"}'
    exit 0
fi

# Check cooldown period
CURRENT_TIME=$(date +%s)

if [[ -f "$TIMESTAMP_FILE" ]]; then
    LAST_REBUILD=$(cat "$TIMESTAMP_FILE")
    TIME_ELAPSED=$((CURRENT_TIME - LAST_REBUILD))

    if [[ $TIME_ELAPSED -lt $COOLDOWN_SECONDS ]]; then
        # Still in cooldown period
        TIME_REMAINING=$((COOLDOWN_SECONDS - TIME_ELAPSED))
        echo "SwiftLens index rebuild skipped (cooldown: ${TIME_REMAINING}s remaining)" >&2
        echo '{"decision": "allow"}'
        exit 0
    fi
fi

# Check if rebuild is already in progress
if [[ -f "$LOCKFILE" ]]; then
    echo "SwiftLens index rebuild already in progress" >&2
    echo '{"decision": "allow"}'
    exit 0
fi

# Create lock file
touch "$LOCKFILE"
trap "rm -f $LOCKFILE" EXIT

# Trigger index rebuild
echo "SwiftLens index rebuild triggered (Swift file modified: $FILE_PATH)" >&2

# Update timestamp
echo "$CURRENT_TIME" > "$TIMESTAMP_FILE"

# Notify Claude Code to suggest running swift_build_index
# Note: This is informational only - actual tool execution requires user approval
cat <<EOF
{
  "decision": "allow",
  "message": "Swift file modified. Consider running swift_build_index tool to update SourceKit-LSP index for optimal SwiftLens performance. (Auto-rebuild triggered with 15min cooldown)"
}
EOF

# Clean up lock file
rm -f "$LOCKFILE"
