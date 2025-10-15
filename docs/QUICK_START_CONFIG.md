# Quick Start: Configuration-Based Secrets

## TL;DR

**Problem**: Hardcoded 1Password references in code
**Solution**: User-managed JSON config file
**Benefit**: Generic, reusable, team-friendly

## Quick Commands

```bash
# 1. Create config
claude-agents setup secrets --init

# 2. Use config
claude-agents setup secrets --use-config

# 3. View config
claude-agents setup secrets --show-config
```

## 5-Minute Setup

### Step 1: Initialize Config (2 min)

```bash
claude-agents setup secrets --init
```

Answer prompts:
- Save to: `User directory` (or project)
- 1Password vault: `Your-Vault-Name`
- Services: `Ghost, Firebase` (or others)
- For each service, provide 1Password references

### Step 2: Fetch Secrets (1 min)

```bash
claude-agents setup secrets --use-config
```

This will:
1. Load config
2. Fetch from 1Password
3. Store in Keychain
4. Update MCP config

### Step 3: Verify (1 min)

```bash
claude-agents setup secrets --check
```

Check:
- Config file exists
- Secrets in Keychain
- MCP servers configured

### Step 4: Restart Claude Code (1 min)

Restart to load new MCP configuration.

## Config File Structure

### Minimal Example

```json
{
  "version": "1.0",
  "onePasswordVault": "Personal",
  "services": {
    "ghost": {
      "url": {
        "onePasswordRef": "op://Personal/Ghost/url",
        "keychainAccount": "ghost-url",
        "keychainService": "swift-agents-plugin.ghost",
        "envVar": "GHOST_URL"
      }
    }
  }
}
```

### Location

- User: `~/.claude-agents/secrets-config.json`
- Project: `./.claude-agents-secrets.json`

## Common Tasks

### Update Secrets

```bash
claude-agents setup secrets --use-config
```

### Edit Config

```bash
# Option 1: Interactive
claude-agents setup secrets --configure

# Option 2: Manual
nano ~/.claude-agents/secrets-config.json
```

### Share with Team

```bash
# Export template
claude-agents setup secrets --export-template > config-template.json

# Team member uses template
cp config-template.json ~/.claude-agents/secrets-config.json
# Edit with personal vault references
```

### Use Different Config

```bash
claude-agents setup secrets --config /path/to/custom.json
```

## Migration from Hardcoded

```bash
# Old way (deprecated)
claude-agents setup secrets --one-password
# Warning: --one-password is deprecated. Use --use-config instead.

# New way
claude-agents setup secrets --init  # One-time
claude-agents setup secrets --use-config  # Regular use
```

## Troubleshooting

### Config not found

```bash
claude-agents setup secrets --init
```

### Invalid config

```bash
claude-agents setup secrets --validate-config
```

### 1Password issues

```bash
# Check installation
which op

# Check authentication
op account list

# Sign in
eval $(op signin)
```

## Examples

See `/Users/stijnwillems/Developer/swift-agents-plugin/examples/secrets-configs/`

- `template.json` - Complete template
- `minimal-ghost.json` - Ghost only
- `enterprise-multi-service.json` - Full setup
- `manual-only.json` - No 1Password

## Full Documentation

- [Configuration Guide](./docs/CONFIG_BASED_SECRETS.md)
- [Redesign Summary](./docs/REDESIGN_SUMMARY.md)
- [Implementation Plan](./docs/IMPLEMENTATION_PLAN_CONFIG.md)
- [Code Snippets](./docs/CODE_SNIPPETS_CONFIG_SECRETS.md)

---

**Version**: 1.2.0
**Last Updated**: 2025-10-14
