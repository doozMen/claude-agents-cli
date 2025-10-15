# Secrets Configuration Examples

This directory contains example configuration files for the `claude-agents setup secrets` command.

## Files

### template.json
Complete template with placeholders for all supported services. Use this as a starting point.

**Usage:**
```bash
cp template.json ~/.claude-agents/secrets-config.json
# Edit with your 1Password references
claude-agents setup secrets --use-config
```

### minimal-ghost.json
Minimal configuration for Ghost CMS only.

**Use case:** Personal blog publishing with Ghost

### manual-only.json
Configuration without 1Password integration (manual input only).

**Use case:** Users without 1Password who want to use manual input

### enterprise-multi-service.json
Comprehensive configuration for enterprise setup with multiple services.

**Use case:** Development teams using Ghost, Firebase, Azure DevOps, GitHub, and GitLab

## Configuration Structure

Each configuration file follows this structure:

```json
{
  "version": "1.0",
  "onePasswordVault": "VaultName",
  "services": {
    "service-name": {
      "secret-key": {
        "onePasswordRef": "op://Vault/Item/Field",
        "keychainAccount": "keychain-account",
        "keychainService": "keychain-service",
        "envVar": "ENVIRONMENT_VARIABLE",
        "prompt": "User prompt for manual input",
        "validator": "validation-type"
      }
    }
  },
  "mcpServers": {
    "server-name": {
      "command": "executable",
      "args": ["arg1", "arg2"],
      "description": "Server description",
      "requiredSecrets": ["service.key"]
    }
  }
}
```

## Customization Guide

### Adding a New Service

1. Add service entry to `services`:
```json
"my-service": {
  "api-key": {
    "onePasswordRef": "op://MyVault/MyService/api key",
    "keychainAccount": "my-service-api-key",
    "keychainService": "swift-agents-plugin.my-service",
    "envVar": "MY_SERVICE_API_KEY",
    "prompt": "My Service API Key"
  }
}
```

2. Add MCP server configuration:
```json
"my-service-mcp": {
  "command": "my-service-mcp-server",
  "args": [],
  "description": "My Service integration",
  "requiredSecrets": ["my-service.api-key"]
}
```

### Using Custom 1Password Vaults

Change the `onePasswordVault` field and update references:

```json
{
  "version": "1.0",
  "onePasswordVault": "MyCustomVault",
  "services": {
    "ghost": {
      "url": {
        "onePasswordRef": "op://MyCustomVault/Ghost/url",
        ...
      }
    }
  }
}
```

### Disabling 1Password for Specific Secrets

Set `onePasswordRef` to `null`:

```json
"firebase": {
  "token": {
    "onePasswordRef": null,
    "keychainAccount": "firebase-token",
    "keychainService": "swift-agents-plugin.firebase",
    "envVar": "FIREBASE_TOKEN",
    "prompt": "Firebase CI token"
  }
}
```

## Validation

Validate your configuration before using:

```bash
claude-agents setup secrets --validate-config
```

## Best Practices

1. **Version Control**: Commit template files, not actual configs with sensitive references
2. **File Location**: 
   - User-specific: `~/.claude-agents/secrets-config.json`
   - Project-specific: `./.claude-agents-secrets.json`
3. **Keychain Naming**: Use consistent service/account naming (e.g., `swift-agents-plugin.service`)
4. **Environment Variables**: Use uppercase with underscores (e.g., `GHOST_ADMIN_API_KEY`)
5. **Secret Paths**: Use dot notation (e.g., `ghost.adminApiKey`)

## Security Notes

- Configuration files contain 1Password **references**, not actual secrets
- References are safe to share within teams
- Actual secrets remain in 1Password and Keychain
- Add `.claude-agents-secrets.json` to `.gitignore` if needed

## Related Documentation

- [Configuration-Based Secrets Guide](../../docs/CONFIG_BASED_SECRETS.md)
- [Secrets Management Guide](../../docs/SECRETS_MANAGEMENT.md)
- [Code Snippets](../../docs/CODE_SNIPPETS_CONFIG_SECRETS.md)

---

**Last Updated**: 2025-10-14
**Version**: 1.2.0
