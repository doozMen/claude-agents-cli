# Secrets Management with claude-agents-cli

The `claude-agents setup secrets` command provides secure secrets management for MCP (Model Context Protocol) servers using either 1Password or macOS Keychain.

## Overview

This feature replaces the bash scripts (`setup-secrets.sh`, `load-secrets.sh`, `update-mcp-config.sh`) with a native Swift implementation that:

- Fetches secrets from 1Password vault
- Stores secrets securely in macOS Keychain
- Updates Claude MCP configuration automatically
- Supports interactive and non-interactive modes

## Quick Start

### Check Current Status

```bash
claude-agents setup secrets --check
```

This shows:
- 1Password CLI installation and authentication status
- Secrets stored in Keychain
- MCP server configuration status

### Setup with 1Password (Recommended)

```bash
claude-agents setup secrets --one-password
```

This will:
1. Verify 1Password CLI is installed and authenticated
2. Fetch secrets from your 1Password vault:
   - Ghost URL: `op://Employee/Ghost/my site`
   - Ghost Admin API Key: `op://Employee/Ghost/Saved on account.ghost.org/admin api key`
   - Ghost Content API Key: `op://Employee/Ghost/Saved on account.ghost.org/content api key`
3. Store secrets in macOS Keychain
4. Update `~/.config/claude/mcp.json` with the secrets

### Setup with Manual Input

```bash
claude-agents setup secrets --keychain
```

Prompts you to enter:
- Ghost URL
- Ghost Admin API Key
- Firebase Token

Then stores them in Keychain and updates MCP config.

### Interactive Mode

```bash
claude-agents setup secrets
```

Presents a menu to choose between 1Password and manual input.

### Update MCP Config Only

```bash
claude-agents setup secrets --update-only
```

Loads existing secrets from Keychain and updates MCP configuration without prompting for new credentials.

## Command Reference

### Flags

- `--one-password`: Use 1Password for all secrets (requires 1Password CLI)
- `--keychain`: Use macOS Keychain with manual input
- `--update-only`: Only update MCP config from existing Keychain secrets
- `--check`: Check current secrets status
- `--force`: Skip confirmation prompts

## 1Password Integration

### Requirements

1. **1Password CLI**: Install via Homebrew
   ```bash
   brew install --cask 1password-cli
   ```

2. **Authentication**: Sign in to 1Password
   ```bash
   eval $(op signin)
   ```

   Or configure Touch ID for biometric unlock:
   https://developer.1password.com/docs/cli/about-biometric-unlock

### Secret References

The tool uses the following 1Password references:

| Secret | 1Password Reference |
|--------|---------------------|
| Ghost URL | `op://Employee/Ghost/my site` |
| Ghost Admin API Key | `op://Employee/Ghost/Saved on account.ghost.org/admin api key` |
| Ghost Content API Key | `op://Employee/Ghost/Saved on account.ghost.org/content api key` |

Modify these in `Sources/claude-agents-cli/Models/Secret.swift` if your vault structure is different.

## macOS Keychain Integration

### Storage Format

Secrets are stored in macOS Keychain with the following service/account identifiers:

| Secret | Service | Account |
|--------|---------|---------|
| Ghost URL | `claude-agents-cli.ghost` | `url` |
| Ghost Admin API Key | `claude-agents-cli.ghost` | `api-key` |
| Ghost Content API Key | `claude-agents-cli.ghost` | `content-api-key` |
| Firebase Token | `claude-agents-cli.firebase` | `token` |

### Manual Access

View secrets using Keychain Access.app or `security` command:

```bash
# View Ghost URL
security find-generic-password -a url -s claude-agents-cli.ghost -w

# View Ghost Admin API Key
security find-generic-password -a api-key -s claude-agents-cli.ghost -w

# View Firebase Token
security find-generic-password -a token -s claude-agents-cli.firebase -w
```

## MCP Configuration

### Configuration File

Location: `~/.config/claude/mcp.json`

### Backup

A backup is automatically created at `~/.config/claude/mcp.json.backup` before any modifications.

### Supported MCP Servers

#### Firebase MCP Server

```json
{
  "mcpServers": {
    "firebase": {
      "command": "firebase",
      "args": ["experimental:mcp"],
      "env": {
        "FIREBASE_TOKEN": "<from-keychain>"
      },
      "description": "Firebase MCP server for Crashlytics analysis"
    }
  }
}
```

#### Ghost CMS MCP Server

```json
{
  "mcpServers": {
    "ghost": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-ghost"],
      "env": {
        "GHOST_URL": "<from-keychain>",
        "GHOST_ADMIN_API_KEY": "<from-keychain>"
      },
      "description": "Ghost CMS MCP server for blog publishing"
    }
  }
}
```

## Workflow Examples

### Initial Setup with 1Password

```bash
# 1. Check prerequisites
claude-agents setup secrets --check

# 2. Setup secrets
claude-agents setup secrets --one-password

# 3. Restart Claude Code
# (to load new MCP configuration)

# 4. Verify
claude-agents setup secrets --check
```

### Update Existing Secrets

```bash
# Fetch latest from 1Password and update everything
claude-agents setup secrets --one-password --force

# Or just update MCP config from existing Keychain secrets
claude-agents setup secrets --update-only
```

### Manual Configuration

```bash
# Interactive setup
claude-agents setup secrets --keychain

# Non-interactive (skip prompts)
claude-agents setup secrets --keychain --force
```

## Architecture

### Components

**Models** (`Sources/claude-agents-cli/Models/`)
- `Secret.swift`: Secret data models
- `KnownSecret`: Enum of supported secrets with 1Password references
- `MCPConfiguration`: MCP config file structure

**Services** (`Sources/claude-agents-cli/Services/`)
- `SecretsService.swift`: Actor for thread-safe secrets operations
  - 1Password CLI integration
  - macOS Keychain operations
  - MCP configuration read/write

**Commands** (`Sources/claude-agents-cli/Commands/`)
- `SetupSecretsCommand.swift`: CLI command implementation
  - Interactive mode
  - Status checking
  - 1Password and Keychain workflows

### Concurrency Model

- `SecretsService` is an **actor** for thread-safe operations
- All secrets operations use async/await
- Follows Swift 6.0 concurrency best practices

## Migration from Bash Scripts

### Old Workflow

```bash
# Setup
./scripts/setup-secrets.sh

# Load into environment
source scripts/load-secrets.sh

# Update MCP config
./scripts/update-mcp-config.sh
```

### New Workflow

```bash
# All-in-one command
claude-agents setup secrets --one-password
```

The new Swift implementation:
- ✅ Integrates with 1Password directly
- ✅ Eliminates need to source environment variables
- ✅ Updates MCP config automatically
- ✅ Provides status checking and validation
- ✅ Thread-safe with Swift actors
- ✅ Better error handling and user feedback

### Backward Compatibility

The bash scripts remain functional and can coexist with the Swift implementation. Both use the same Keychain service/account identifiers.

## Troubleshooting

### 1Password CLI Not Found

```
❌ 1Password CLI is not installed
Install it via Homebrew: brew install --cask 1password-cli
```

**Solution**: Install 1Password CLI as shown.

### Not Authenticated with 1Password

```
❌ Not authenticated with 1Password
Run: eval $(op signin)
```

**Solution**: Sign in to 1Password or configure Touch ID unlock.

### Secret Not Found in 1Password

```
Secret not found in 1Password: op://Employee/Ghost/my site
```

**Solution**: Verify the secret reference matches your 1Password vault structure. Update `KnownSecret.onePasswordReference` in `Secret.swift` if needed.

### Keychain Access Denied

```
Failed to access Keychain for 'claude-agents-cli.ghost:url'
```

**Solution**: Grant access when macOS prompts for Keychain authorization.

### MCP Config Invalid

```
Invalid MCP configuration: The data couldn't be read because it isn't in the correct format.
```

**Solution**: Check `~/.config/claude/mcp.json` syntax. Restore from backup if needed:
```bash
cp ~/.config/claude/mcp.json.backup ~/.config/claude/mcp.json
```

## Security Considerations

### Keychain Security

- Secrets stored in macOS Keychain are encrypted
- Access requires user authentication (via macOS security)
- Secrets never written to disk in plaintext

### 1Password Security

- Requires authenticated 1Password CLI session
- Touch ID support for biometric unlock
- No secrets cached outside 1Password vault

### MCP Configuration

- `mcp.json` contains plaintext secrets
- File permissions: `0600` (user read/write only)
- Located in user-specific `~/.config/claude/` directory
- **Note**: Claude Code requires plaintext secrets in `mcp.json` for MCP servers

## Future Enhancements

Potential improvements:

- [ ] Support for additional MCP servers (GitHub, GitLab, etc.)
- [ ] Custom secret sources (HashiCorp Vault, AWS Secrets Manager)
- [ ] Encrypted MCP configuration (if Claude Code adds support)
- [ ] Secret rotation workflows
- [ ] Team secret sharing via 1Password shared vaults

## Related Documentation

- [1Password CLI Documentation](https://developer.1password.com/docs/cli)
- [Model Context Protocol](https://modelcontextprotocol.io)
- [Ghost CMS MCP Server](https://github.com/modelcontextprotocol/servers/tree/main/src/ghost)
- [Firebase MCP Integration](https://firebase.google.com)

---

For questions or issues, open an issue at https://github.com/yourusername/claude-agents-cli/issues
