# Secrets Management

This document describes how to securely manage secrets and credentials for the Claude Agents CLI project.

## Overview

The project uses **macOS Keychain** for secure credential storage. This prevents secrets from being:
- Committed to version control
- Exposed in plain text configuration files
- Accidentally shared in screenshots or logs

## Quick Start

### Initial Setup

```bash
# 1. Run the interactive setup script
./scripts/setup-secrets.sh

# 2. Load secrets into your shell
source scripts/load-secrets.sh

# 3. Update MCP configuration
./scripts/update-mcp-config.sh

# 4. Restart Claude Code
```

## Required Secrets

### Ghost CMS

**Purpose**: Publish blog posts to Ghost CMS via MCP

**Required Values**:
- `GHOST_URL`: Your Ghost site URL (e.g., `https://yoursite.ghost.io`)
- `GHOST_ADMIN_API_KEY`: Admin API key (format: `id:secret`)

**How to Get**:
1. Log into Ghost Admin: `https://yoursite.ghost.io/ghost/`
2. Navigate to: Settings → Integrations → Custom Integrations
3. Create a new integration or use existing
4. Copy the Admin API Key (long hex string with colon separator)

**Example**:
```bash
GHOST_URL=https://doozmen-stijn-willems.ghost.io
GHOST_ADMIN_API_KEY=68e52dc931b35d0001eadcd5:f630615eb59b6f41bc75f46361d7f2661a9cf4c587d78d95f8e0102d568eaa3
```

### Firebase

**Purpose**: Access Firebase Crashlytics for crash analysis via MCP

**Required Values**:
- `FIREBASE_TOKEN`: OAuth token for Firebase CLI

**How to Get**:
```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login and generate token
firebase login:ci
```

Copy the token printed at the end of the login process.

## Scripts

### `setup-secrets.sh`

Interactive script to store secrets in Keychain.

```bash
./scripts/setup-secrets.sh
```

**Features**:
- Validates secret formats before storing
- Prevents accidental overwriting (prompts for confirmation)
- Supports Ghost, Firebase, and custom MCP servers
- Uses macOS Keychain for secure storage

**Storage Location**: macOS Keychain (login keychain)
**Service Names**: `claude-agents-cli.{ghost|firebase|custom}`

### `load-secrets.sh`

Load secrets from Keychain into environment variables.

```bash
# Source the script to export variables
source scripts/load-secrets.sh

# Verify variables are loaded
echo $GHOST_URL
echo $FIREBASE_TOKEN
```

**Exports**:
- `GHOST_URL`
- `GHOST_ADMIN_API_KEY`
- `FIREBASE_TOKEN`

### `list-secrets.sh`

View all stored secrets (names only, not values).

```bash
./scripts/list-secrets.sh
```

**Output Example**:
```
════════════════════════════════════════════════════════════
  Stored Secrets in Keychain
════════════════════════════════════════════════════════════

  claude-agents-cli.ghost → url
  claude-agents-cli.ghost → api-key
  claude-agents-cli.firebase → token
```

### `update-mcp-config.sh`

Update Claude MCP configuration with secrets from Keychain.

```bash
./scripts/update-mcp-config.sh
```

**What it does**:
1. Backs up existing `~/.config/claude/mcp.json`
2. Loads secrets from Keychain
3. Updates MCP server configurations with actual values
4. Preserves other MCP server configs (tech-conf, etc.)

**Note**: Restart Claude Code after running this script.

## Security Best Practices

### ✅ Do

- **Use Keychain**: Always store secrets via `setup-secrets.sh`
- **Rotate regularly**: Update secrets every 90 days
- **Limit scope**: Use read-only tokens when possible
- **Check .gitignore**: Verify sensitive files are excluded
- **Use different tokens**: Don't share tokens across projects

### ❌ Don't

- **Commit secrets**: Never commit `.env` or raw tokens
- **Share tokens**: Don't send tokens via chat/email
- **Hardcode secrets**: Avoid putting secrets directly in code
- **Use root tokens**: Use least-privilege credentials
- **Skip validation**: Always validate secret formats

## Secret Rotation

### When to Rotate

- Every 90 days (scheduled)
- After team member departure
- If secret is compromised or exposed
- After major security updates

### How to Rotate

#### Ghost CMS API Key

```bash
# 1. Generate new key in Ghost Admin
# Go to: Settings → Integrations → Regenerate Key

# 2. Update in Keychain
./scripts/setup-secrets.sh
# Choose "Update it?" when prompted

# 3. Update MCP config
./scripts/update-mcp-config.sh

# 4. Restart Claude Code
```

#### Firebase Token

```bash
# 1. Logout and login to generate new token
firebase logout
firebase login:ci

# 2. Update in Keychain
./scripts/setup-secrets.sh

# 3. Update MCP config
./scripts/update-mcp-config.sh

# 4. Restart Claude Code
```

## Troubleshooting

### Secret Not Found

**Problem**: `load-secrets.sh` reports no secrets found

**Solution**:
```bash
# Run setup to store secrets
./scripts/setup-secrets.sh

# Verify secrets are stored
./scripts/list-secrets.sh
```

### Invalid API Key Format

**Problem**: Ghost API key validation fails

**Expected Format**: `hexid:hexsecret`
**Example**: `68e52dc931b35d0001eadcd5:f630615eb59b6f41bc75f46361d7f2661a9cf4c587d78d95f8e0102d568eaa3`

**Solution**:
- Ensure you're copying the **Admin API Key** (not Content API Key)
- Check for extra spaces or line breaks
- Verify the colon separator is present

### Keychain Access Denied

**Problem**: `security` command prompts for password repeatedly

**Solution**:
```bash
# Unlock keychain
security unlock-keychain login.keychain

# Or allow the terminal app in Keychain Access preferences
# System Settings → Privacy & Security → Full Disk Access
```

### MCP Server Not Loading

**Problem**: Ghost MCP doesn't work after configuration

**Solution**:
1. Verify secrets are loaded: `source scripts/load-secrets.sh`
2. Check MCP config: `cat ~/.config/claude/mcp.json`
3. Restart Claude Code completely (Cmd+Q, then reopen)
4. Check Claude logs for MCP connection errors

## Manual Secret Management

### View Secret Value

```bash
# View specific secret
security find-generic-password \
  -a "url" \
  -s "claude-agents-cli.ghost" \
  -w

# View with details
security find-generic-password \
  -a "api-key" \
  -s "claude-agents-cli.ghost"
```

### Delete Secret

```bash
# Delete specific secret
security delete-generic-password \
  -a "url" \
  -s "claude-agents-cli.ghost"
```

### Update Secret Manually

```bash
# Delete old secret
security delete-generic-password \
  -a "api-key" \
  -s "claude-agents-cli.ghost"

# Add new secret
security add-generic-password \
  -a "api-key" \
  -s "claude-agents-cli.ghost" \
  -w "new_secret_value"
```

## Adding New MCP Servers

To add secrets for a new MCP server:

### 1. Store Secrets

```bash
./scripts/setup-secrets.sh
# Choose "Add custom MCP server credentials"
# Enter MCP server name and credentials
```

### 2. Update load-secrets.sh

Add export statements:

```bash
# Load Custom MCP credentials
export CUSTOM_MCP_TOKEN=$(get_secret "claude-agents-cli.custom-mcp" "token")
```

### 3. Update update-mcp-config.sh

Add MCP server configuration:

```json
{
  "custom-mcp": {
    "command": "custom-mcp-command",
    "args": ["--token"],
    "env": {
      "CUSTOM_MCP_TOKEN": ""
    }
  }
}
```

Update the sed substitution logic to inject the token.

### 4. Document in README

Update project documentation with new MCP server requirements.

## Environment Variables Reference

| Variable | Purpose | Format | Example |
|----------|---------|--------|---------|
| `GHOST_URL` | Ghost site URL | `https://site.ghost.io` | `https://doozmen-stijn-willems.ghost.io` |
| `GHOST_ADMIN_API_KEY` | Ghost Admin API key | `id:secret` (hex) | `68e52...eaa3` |
| `FIREBASE_TOKEN` | Firebase CLI token | OAuth token string | `1//09kGZ...FMvo` |

## Files and Locations

| File/Directory | Purpose | Committed to Git? |
|----------------|---------|-------------------|
| `scripts/setup-secrets.sh` | Interactive secret setup | ✅ Yes |
| `scripts/load-secrets.sh` | Load secrets into env vars | ✅ Yes |
| `scripts/list-secrets.sh` | List stored secrets | ✅ Yes |
| `scripts/update-mcp-config.sh` | Update MCP config | ✅ Yes |
| `.env.template` | Template for env vars | ✅ Yes |
| `.env` | Actual environment variables | ❌ No (in .gitignore) |
| `~/.config/claude/mcp.json` | Claude MCP configuration | ❌ No (user-specific) |
| macOS Keychain | Actual secret storage | ❌ No (system-managed) |

## Support

For issues or questions:
1. Check this documentation
2. Review script comments
3. Open an issue on GitHub
4. Check Claude Code documentation

## Related Documentation

- [Claude Code MCP Documentation](https://docs.claude.com/en/docs/claude-code/model-context-protocol)
- [Ghost Admin API](https://ghost.org/docs/admin-api/)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
- [macOS Keychain Documentation](https://support.apple.com/guide/keychain-access/)
