# Secrets Management Redesign Summary

## Problem Statement

The current secrets management implementation hardcodes CompanyA-specific 1Password URIs like `op://Employee/CompanyA/gitlab mcp...` directly in the code. This makes the tool organization-specific and not reusable by other teams or individuals.

**Issues:**
1. Hardcoded 1Password references in `Secret.swift`
2. Organization-specific naming (CompanyA, Employee vault)
3. Not shareable across different organizations
4. Requires code changes for different 1Password structures
5. Not suitable for open-source distribution

## Solution: Configuration-Based Architecture

Replace hardcoded 1Password references with a **user-managed configuration file** that defines:
- 1Password vault and item references
- Keychain service/account identifiers
- Environment variable mappings
- MCP server configurations

## Key Design Changes

### Before (Hardcoded)

**Location**: `Sources/claude-agents-cli/Models/Secret.swift`

```swift
public enum KnownSecret: String, Sendable, CaseIterable {
  case ghostUrl = "ghost-url"
  
  public var onePasswordReference: String? {
    switch self {
    case .ghostUrl:
      return "op://Employee/Ghost/my site"  // HARDCODED
    }
  }
}
```

**Problems:**
- Organization-specific reference
- Requires code change to customize
- Not shareable

### After (Config-Based)

**Location**: `~/.claude-agents/secrets-config.json` (user home)

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
        "prompt": "Ghost URL"
      }
    }
  }
}
```

**Benefits:**
- User-configurable
- No code changes needed
- Shareable within teams
- Supports multiple environments

## Architecture Overview

### New Components

#### 1. Configuration Models

**File**: `Sources/claude-agents-cli/Models/SecretsConfig.swift`

```swift
public struct SecretsConfig: Sendable, Codable {
  public let version: String
  public let onePasswordVault: String?
  public let services: [String: ServiceConfig]
  public let mcpServers: [String: MCPServerDefinition]?
}

public struct SecretConfig: Sendable, Codable {
  public let onePasswordRef: String?
  public let keychainAccount: String
  public let keychainService: String
  public let envVar: String?
  public let prompt: String?
  public let validator: String?
}
```

#### 2. Config Service

**File**: `Sources/claude-agents-cli/Services/ConfigService.swift`

```swift
public actor ConfigService {
  // Find and load config
  public func findConfigPath() async -> URL?
  public func loadConfig(from path: URL?) async throws -> SecretsConfig
  
  // Save and validate
  public func saveConfig(_ config: SecretsConfig, to path: URL?) async throws
  public func validateConfig(_ config: SecretsConfig) async throws
  
  // Template management
  public func exportTemplate(_ config: SecretsConfig) async throws -> SecretsConfig
}
```

#### 3. Updated Commands

**File**: `Sources/claude-agents-cli/Commands/SetupSecretsCommand.swift`

New flags:
- `--init`: Initialize config file interactively
- `--configure`: Edit 1Password references
- `--use-config`: Use config file (replaces `--one-password`)
- `--show-config`: Display current config
- `--config <path>`: Use custom config path

### Config File Locations

**Priority order:**
1. Project-specific: `./.claude-agents-secrets.json`
2. User-specific: `~/.claude-agents/secrets-config.json`

Project configs override user configs, allowing:
- Team-shared templates (in git)
- Personal customizations (in home)

## Workflow Changes

### Before (Hardcoded)

```bash
# Setup with hardcoded references
claude-agents setup secrets --one-password

# References are in code:
# op://Employee/Ghost/my site
```

### After (Config-Based)

```bash
# 1. Initialize config (one-time)
claude-agents setup secrets --init
# Prompts for:
# - 1Password vault
# - Services to configure
# - 1Password references for each secret

# 2. Use config
claude-agents setup secrets --use-config
# Reads from ~/.claude-agents/secrets-config.json

# 3. View config
claude-agents setup secrets --show-config

# 4. Edit config
claude-agents setup secrets --configure
```

## Migration Strategy

### Automatic Migration

Tool detects existing secrets and offers migration:

```bash
claude-agents setup secrets --init

# Output:
# Found existing secrets in Keychain:
#   - Ghost URL
#   - Ghost Admin API Key
# 
# Create configuration from existing secrets? (y/n): y
# 
# Enter 1Password reference for Ghost URL
# (or leave empty for manual input): op://MyVault/Ghost/url
# 
# Config saved to ~/.claude-agents/secrets-config.json
```

### Manual Migration

1. Check existing secrets:
   ```bash
   claude-agents setup secrets --check
   ```

2. Initialize config:
   ```bash
   claude-agents setup secrets --init
   ```

3. Update 1Password references:
   ```bash
   claude-agents setup secrets --configure
   ```

4. Test:
   ```bash
   claude-agents setup secrets --use-config
   ```

## Backward Compatibility

### Deprecated but Functional

The `--one-password` flag remains functional with deprecation warning:

```bash
claude-agents setup secrets --one-password

# Output:
# Warning: --one-password is deprecated. Use --use-config instead.
# Run 'claude-agents setup secrets --init' to create a config file.
# 
# Continuing with hardcoded references...
```

### Manual Input Still Works

Users without 1Password can still use manual input:

```bash
claude-agents setup secrets --keychain
# Prompts for values, no config needed
```

## Team Collaboration

### Sharing Config Templates

**Project maintainer:**

```bash
# 1. Create project config
claude-agents setup secrets --init
# Save to: Current directory

# 2. Export as template
claude-agents setup secrets --export-template > .claude-agents-secrets.template.json

# 3. Commit template
git add .claude-agents-secrets.template.json
echo ".claude-agents-secrets.json" >> .gitignore
git commit -m "Add secrets config template"
```

**Team member:**

```bash
# 1. Copy template
cp .claude-agents-secrets.template.json .claude-agents-secrets.json

# 2. Update with your 1Password vault
# Edit .claude-agents-secrets.json
# Change: "YOUR_VAULT" to "MyVault"

# 3. Fetch secrets
claude-agents setup secrets --use-config
```

## Multi-Environment Support

```bash
# Development
export CLAUDE_AGENTS_SECRETS_CONFIG=~/.claude-agents/secrets-dev.json
claude-agents setup secrets --use-config

# Staging
export CLAUDE_AGENTS_SECRETS_CONFIG=~/.claude-agents/secrets-staging.json
claude-agents setup secrets --use-config

# Production
export CLAUDE_AGENTS_SECRETS_CONFIG=~/.claude-agents/secrets-prod.json
claude-agents setup secrets --use-config
```

## Example Configurations

### Minimal Ghost

```json
{
  "version": "1.0",
  "onePasswordVault": "Personal",
  "services": {
    "ghost": {
      "url": {
        "onePasswordRef": "op://Personal/Ghost/url",
        "keychainAccount": "ghost-url",
        "keychainService": "claude-agents-cli.ghost",
        "envVar": "GHOST_URL"
      }
    }
  }
}
```

### Enterprise Multi-Service

```json
{
  "version": "1.0",
  "onePasswordVault": "Engineering",
  "services": {
    "ghost": { ... },
    "firebase": { ... },
    "azure-devops": { ... },
    "github": { ... },
    "gitlab": { ... }
  },
  "mcpServers": {
    "ghost": { ... },
    "firebase": { ... },
    "azure-devops": { ... }
  }
}
```

### Manual Only (No 1Password)

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
      }
    }
  }
}
```

## Security Considerations

### What's Safe to Commit

**Safe (1Password references only):**
```json
{
  "onePasswordRef": "op://Employee/Ghost/url"
}
```

**NOT safe (actual secrets):**
```json
{
  "secret": "actual-api-key-value"
}
```

### File Permissions

- Config files: `0644` (readable by owner and group)
- MCP config: `0600` (readable/writable by owner only)
- Automatically set by tool

### Recommended Practices

1. **Commit templates with placeholders**
2. **Add `.claude-agents-secrets.json` to `.gitignore`**
3. **Use project configs for team sharing**
4. **Use user configs for personal vaults**
5. **Never commit actual secrets**

## Implementation Files

### Created Files

1. `Sources/claude-agents-cli/Models/SecretsConfig.swift` - Config models
2. `Sources/claude-agents-cli/Services/ConfigService.swift` - Config operations
3. `docs/CONFIG_BASED_SECRETS.md` - User guide
4. `docs/CODE_SNIPPETS_CONFIG_SECRETS.md` - Implementation examples
5. `docs/IMPLEMENTATION_PLAN_CONFIG.md` - Development plan
6. `examples/secrets-configs/template.json` - Template config
7. `examples/secrets-configs/minimal-ghost.json` - Minimal example
8. `examples/secrets-configs/enterprise-multi-service.json` - Full example
9. `examples/secrets-configs/manual-only.json` - No 1Password example
10. `examples/secrets-configs/README.md` - Examples documentation

### Modified Files

1. `Sources/claude-agents-cli/Models/Errors.swift` - Add config errors
2. `Sources/claude-agents-cli/Services/SecretsService.swift` - Add config methods
3. `Sources/claude-agents-cli/Commands/SetupSecretsCommand.swift` - Add config flags
4. `IMPLEMENTATION_SUMMARY.md` - Update architecture overview

## Benefits Summary

### For Users

- No code changes needed for different 1Password structures
- Share config templates within teams
- Support multiple environments (dev/staging/prod)
- Still works without 1Password (manual input)
- Clear separation of config and code

### For Developers

- Generic, reusable implementation
- No organization-specific code
- Testable configuration
- Extensible for future secret sources
- Type-safe with Swift Codable

### For Open Source

- Suitable for public distribution
- No hardcoded credentials or references
- User-configurable out of the box
- Team collaboration support
- Clear documentation

## Next Steps

1. Implement models (SecretsConfig.swift)
2. Implement ConfigService
3. Update SecretsService with config methods
4. Update SetupSecretsCommand with new flags
5. Test with multiple configurations
6. Update documentation
7. Release as v1.2.0

## Related Documentation

- [Implementation Plan](./IMPLEMENTATION_PLAN_CONFIG.md)
- [Config-Based Secrets Guide](./CONFIG_BASED_SECRETS.md)
- [Code Snippets](./CODE_SNIPPETS_CONFIG_SECRETS.md)
- [Examples](../examples/secrets-configs/README.md)

---

**Date**: 2025-10-14
**Version**: 1.2.0 (proposed)
**Status**: Design Complete, Implementation Pending
