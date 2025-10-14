# Configuration-Based Secrets Management

## Overview

The `claude-agents setup secrets` command now uses a **configuration file** to define 1Password references, making it generic and reusable across different organizations and team structures.

**Key Benefits:**
- No hardcoded organization-specific values
- User-defined 1Password references
- Team-shareable config templates
- Multi-environment support (dev, staging, prod)
- Backward compatible with manual input

## Configuration File

### Location

The tool looks for configuration in the following order:

1. **Project-specific**: `./.claude-agents-secrets.json` (current directory)
2. **User-specific**: `~/.claude-agents/secrets-config.json` (home directory)

Project-specific configs override user-specific configs. This allows:
- Team-shared config templates (checked into git)
- Personal customizations (in home directory)

### File Format

```json
{
  "version": "1.0",
  "onePasswordVault": "Employee",
  "services": {
    "ghost": {
      "url": {
        "onePasswordRef": "op://Employee/Ghost/my site",
        "keychainAccount": "ghost-url",
        "keychainService": "claude-agents-cli.ghost",
        "envVar": "GHOST_URL",
        "prompt": "Ghost site URL (e.g., https://yoursite.ghost.io)",
        "validator": "url"
      },
      "adminApiKey": {
        "onePasswordRef": "op://Employee/Ghost/admin api key",
        "keychainAccount": "ghost-admin-api-key",
        "keychainService": "claude-agents-cli.ghost",
        "envVar": "GHOST_ADMIN_API_KEY",
        "prompt": "Ghost Admin API Key (format: id:secret)"
      }
    },
    "firebase": {
      "token": {
        "onePasswordRef": null,
        "keychainAccount": "firebase-token",
        "keychainService": "claude-agents-cli.firebase",
        "envVar": "FIREBASE_TOKEN",
        "prompt": "Firebase CI token (run: firebase login:ci)"
      }
    },
    "azure-devops": {
      "orgUrl": {
        "onePasswordRef": "op://Employee/Azure/org url",
        "keychainAccount": "azure-devops-org-url",
        "keychainService": "claude-agents-cli.azure",
        "envVar": "AZURE_DEVOPS_ORG_URL",
        "prompt": "Azure DevOps Organization URL",
        "validator": "url"
      },
      "pat": {
        "onePasswordRef": "op://Employee/Azure/pat",
        "keychainAccount": "azure-devops-pat",
        "keychainService": "claude-agents-cli.azure",
        "envVar": "AZURE_DEVOPS_PAT",
        "prompt": "Azure DevOps Personal Access Token"
      }
    }
  },
  "mcpServers": {
    "ghost": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-ghost"],
      "description": "Ghost CMS MCP server for blog publishing",
      "requiredSecrets": ["ghost.url", "ghost.adminApiKey"]
    },
    "firebase": {
      "command": "firebase",
      "args": ["experimental:mcp"],
      "description": "Firebase MCP server for Crashlytics analysis",
      "requiredSecrets": ["firebase.token"]
    }
  }
}
```

### Field Descriptions

#### Top-Level Fields

- `version`: Config file format version (current: "1.0")
- `onePasswordVault`: Default 1Password vault name
- `services`: Dictionary of service configurations
- `mcpServers`: MCP server configurations with secret mappings

#### Secret Configuration Fields

- `onePasswordRef`: 1Password URI (e.g., `op://Vault/Item/Field`) - can be `null`
- `keychainAccount`: Keychain account name
- `keychainService`: Keychain service name
- `envVar`: Environment variable name for MCP config
- `prompt`: User prompt for manual input
- `validator`: Optional validation type (`url`, `email`, `token`)

#### MCP Server Fields

- `command`: Executable command
- `args`: Command arguments
- `description`: Human-readable description
- `requiredSecrets`: Array of secret paths (e.g., `["ghost.url", "ghost.adminApiKey"]`)

## Commands

### Initialize Configuration

Create a new configuration file interactively:

```bash
claude-agents setup secrets --init
```

This will:
1. Prompt for 1Password vault name
2. Ask which services to configure (Ghost, Firebase, Azure DevOps, etc.)
3. For each service:
   - Prompt for 1Password references
   - Generate keychain identifiers
   - Configure MCP server mappings
4. Save to `~/.claude-agents/secrets-config.json`

### Configure 1Password References

Update existing configuration interactively:

```bash
claude-agents setup secrets --configure
```

Allows editing:
- 1Password references
- Service selection
- MCP server configuration

### Show Current Configuration

Display the active configuration:

```bash
claude-agents setup secrets --show-config
```

Shows:
- Config file location
- Configured services
- 1Password references
- Keychain mappings
- MCP server configurations

### Use Configuration

Fetch secrets using the configuration:

```bash
# Use config file (replaces --one-password)
claude-agents setup secrets --use-config

# Or shorter
claude-agents setup secrets
```

This will:
1. Load config from file
2. Fetch secrets from 1Password (if references defined)
3. Store in Keychain
4. Update MCP configuration

### Manual Input

Bypass configuration and use manual input:

```bash
claude-agents setup secrets --keychain
```

Prompts for values without needing a config file.

## Workflows

### First-Time Setup

```bash
# 1. Initialize configuration
claude-agents setup secrets --init

# Follow prompts to configure services and 1Password references

# 2. Fetch secrets
claude-agents setup secrets --use-config

# 3. Verify
claude-agents setup secrets --check

# 4. Restart Claude Code
```

### Team Setup (Shared Config)

**Project maintainer:**

```bash
# 1. Create project-specific config
claude-agents setup secrets --init

# Save to project directory
# Prompts: "Save to current directory? (y/n)"

# 2. Customize for team
# Edit .claude-agents-secrets.json

# 3. Add to .gitignore (if contains sensitive info)
echo ".claude-agents-secrets.json" >> .gitignore

# 4. Commit template
git add .claude-agents-secrets.json.template
git commit -m "Add secrets config template"
```

**Team member:**

```bash
# 1. Copy template
cp .claude-agents-secrets.json.template .claude-agents-secrets.json

# 2. Update 1Password references for your vault
# Edit .claude-agents-secrets.json

# 3. Fetch secrets
claude-agents setup secrets --use-config
```

### Multi-Environment Setup

```bash
# Development
claude-agents setup secrets --config ~/.claude-agents/secrets-dev.json

# Staging
claude-agents setup secrets --config ~/.claude-agents/secrets-staging.json

# Production
claude-agents setup secrets --config ~/.claude-agents/secrets-prod.json
```

## Configuration Examples

### Example 1: Minimal Ghost Setup

```json
{
  "version": "1.0",
  "onePasswordVault": "Personal",
  "services": {
    "ghost": {
      "url": {
        "onePasswordRef": "op://Personal/Ghost Blog/url",
        "keychainAccount": "ghost-url",
        "keychainService": "claude-agents-cli.ghost",
        "envVar": "GHOST_URL",
        "prompt": "Ghost URL"
      },
      "adminApiKey": {
        "onePasswordRef": "op://Personal/Ghost Blog/admin api key",
        "keychainAccount": "ghost-admin-api-key",
        "keychainService": "claude-agents-cli.ghost",
        "envVar": "GHOST_ADMIN_API_KEY",
        "prompt": "Ghost Admin API Key"
      }
    }
  },
  "mcpServers": {
    "ghost": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-ghost"],
      "description": "Ghost CMS",
      "requiredSecrets": ["ghost.url", "ghost.adminApiKey"]
    }
  }
}
```

### Example 2: Enterprise Setup (Multiple Services)

```json
{
  "version": "1.0",
  "onePasswordVault": "Engineering",
  "services": {
    "ghost": {
      "url": {
        "onePasswordRef": "op://Engineering/Company Blog/url",
        "keychainAccount": "ghost-url",
        "keychainService": "claude-agents-cli.ghost",
        "envVar": "GHOST_URL"
      },
      "adminApiKey": {
        "onePasswordRef": "op://Engineering/Company Blog/admin key",
        "keychainAccount": "ghost-admin-api-key",
        "keychainService": "claude-agents-cli.ghost",
        "envVar": "GHOST_ADMIN_API_KEY"
      }
    },
    "azure-devops": {
      "orgUrl": {
        "onePasswordRef": "op://Engineering/Azure DevOps/org url",
        "keychainAccount": "azure-devops-org-url",
        "keychainService": "claude-agents-cli.azure",
        "envVar": "AZURE_DEVOPS_ORG_URL"
      },
      "pat": {
        "onePasswordRef": "op://Engineering/Azure DevOps/pat",
        "keychainAccount": "azure-devops-pat",
        "keychainService": "claude-agents-cli.azure",
        "envVar": "AZURE_DEVOPS_PAT"
      }
    },
    "github": {
      "token": {
        "onePasswordRef": "op://Engineering/GitHub/mcp token",
        "keychainAccount": "github-token",
        "keychainService": "claude-agents-cli.github",
        "envVar": "GITHUB_TOKEN"
      }
    }
  },
  "mcpServers": {
    "ghost": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-ghost"],
      "description": "Company blog",
      "requiredSecrets": ["ghost.url", "ghost.adminApiKey"]
    },
    "azure-devops": {
      "command": "azure-devops-mcp",
      "args": [],
      "description": "Azure DevOps integration",
      "requiredSecrets": ["azure-devops.orgUrl", "azure-devops.pat"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "description": "GitHub integration",
      "requiredSecrets": ["github.token"]
    }
  }
}
```

### Example 3: No 1Password (Manual Only)

```json
{
  "version": "1.0",
  "services": {
    "ghost": {
      "url": {
        "onePasswordRef": null,
        "keychainAccount": "ghost-url",
        "keychainService": "claude-agents-cli.ghost",
        "envVar": "GHOST_URL",
        "prompt": "Ghost URL"
      },
      "adminApiKey": {
        "onePasswordRef": null,
        "keychainAccount": "ghost-admin-api-key",
        "keychainService": "claude-agents-cli.ghost",
        "envVar": "GHOST_ADMIN_API_KEY",
        "prompt": "Ghost Admin API Key"
      }
    }
  },
  "mcpServers": {
    "ghost": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-ghost"],
      "description": "Ghost CMS",
      "requiredSecrets": ["ghost.url", "ghost.adminApiKey"]
    }
  }
}
```

## Migration from Hardcoded Approach

### Automatic Migration

The tool detects existing Keychain secrets and offers to create a config:

```bash
claude-agents setup secrets --init

# Output:
# Found existing secrets in Keychain:
#   - Ghost URL
#   - Ghost Admin API Key
#   - Firebase Token
#
# Create configuration from existing secrets? (y/n)
```

### Manual Migration Steps

1. **Check existing secrets:**
   ```bash
   claude-agents setup secrets --check
   ```

2. **Initialize config:**
   ```bash
   claude-agents setup secrets --init
   ```

3. **Update 1Password references:**
   ```bash
   claude-agents setup secrets --configure
   ```

4. **Test:**
   ```bash
   claude-agents setup secrets --use-config
   claude-agents setup secrets --check
   ```

## Advanced Usage

### Custom Config Path

```bash
# Use specific config file
claude-agents setup secrets --config /path/to/config.json

# Environment variable
export CLAUDE_AGENTS_SECRETS_CONFIG=/path/to/config.json
claude-agents setup secrets
```

### Config Validation

```bash
# Validate config file syntax
claude-agents setup secrets --validate-config

# Test 1Password references
claude-agents setup secrets --test-one-password
```

### Export/Import

```bash
# Export config template (removes sensitive values)
claude-agents setup secrets --export-template > config-template.json

# Import config
claude-agents setup secrets --import config.json
```

## Troubleshooting

### Config File Not Found

```
Config file not found at ~/.claude-agents/secrets-config.json
Run: claude-agents setup secrets --init
```

**Solution**: Initialize configuration.

### Invalid Config Format

```
Invalid configuration: Unknown field 'invalidField'
```

**Solution**: Validate against schema or regenerate with `--init`.

### 1Password Reference Not Found

```
Secret not found: op://Employee/Ghost/my site
```

**Solution**: Update config with correct reference using `--configure`.

## Security Considerations

### Config File Security

- Config files contain 1Password **references**, not actual secrets
- References are safe to commit to git
- Actual secrets remain in 1Password and Keychain

### Recommended Practices

- Use project-specific configs for team settings
- Use user-specific configs for personal 1Password vaults
- Add `.claude-agents-secrets.json` to `.gitignore` if it contains any sensitive info
- Share config templates (`.json.template`) with placeholders

### File Permissions

The tool automatically sets secure permissions:
- Config files: `0644` (readable by owner and group)
- MCP config: `0600` (readable/writable by owner only)

## Related Documentation

- [Secrets Management Guide](./SECRETS_MANAGEMENT.md)
- [1Password CLI Documentation](https://developer.1password.com/docs/cli)
- [Model Context Protocol](https://modelcontextprotocol.io)

---

**Implementation Version**: 1.2.0
**Last Updated**: 2025-10-14
