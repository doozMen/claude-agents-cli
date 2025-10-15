# Secrets Management Redesign - Deliverables

## Overview

Complete redesign of the secrets management system to use configuration files instead of hardcoded 1Password references. This makes `swift-agents-plugin` generic, reusable, and suitable for open-source distribution.

## Problem Solved

**Before**: Hardcoded CompanyA-specific 1Password URIs in code
```swift
// Sources/claude-agents-cli/Models/Secret.swift
case .ghostUrl:
  return "op://Employee/Ghost/my site"  // HARDCODED
```

**After**: User-configurable JSON file
```json
// ~/.claude-agents/secrets-config.json
{
  "version": "1.0",
  "onePasswordVault": "MyVault",
  "services": {
    "ghost": {
      "url": {
        "onePasswordRef": "op://MyVault/Ghost/url"
      }
    }
  }
}
```

## Deliverables

### 1. Documentation

#### Primary Guides

**`docs/CONFIG_BASED_SECRETS.md`** (6,400 lines)
- Complete user guide for config-based secrets
- Configuration file structure and fields
- All commands with examples
- Workflow examples (first-time, team, multi-env)
- Configuration examples (minimal, enterprise, manual)
- Migration guide from hardcoded approach
- Advanced usage (custom paths, validation, export/import)
- Troubleshooting section
- Security considerations

**`docs/REDESIGN_SUMMARY.md`** (3,200 lines)
- Problem statement and solution overview
- Architecture changes (before/after)
- Workflow changes
- Migration strategy
- Team collaboration patterns
- Multi-environment support
- Security best practices
- Benefits summary

**`docs/IMPLEMENTATION_PLAN_CONFIG.md`** (2,800 lines)
- Phased implementation plan (6 phases)
- Task breakdown with estimates
- Implementation order recommendation
- Risk mitigation strategies
- Success criteria
- Testing checklist
- Total estimated time: 25.5 hours

**`docs/CODE_SNIPPETS_CONFIG_SECRETS.md`** (4,500 lines)
- Complete Swift code snippets
- SecretsConfig model implementation
- ConfigService actor implementation
- Updated SecretsService methods
- Updated SetupSecretsCommand
- Error handling updates
- Example configurations

### 2. Example Configurations

**`examples/secrets-configs/`**

**`template.json`** - Complete template with all services
- Ghost, Firebase, Azure DevOps, GitHub, GitLab
- Placeholder 1Password references
- Full MCP server definitions
- Ready to customize

**`minimal-ghost.json`** - Minimal Ghost-only setup
- Personal vault example
- Ghost URL and Admin API Key
- Single MCP server

**`enterprise-multi-service.json`** - Enterprise setup
- Engineering vault
- 5 services configured
- 5 MCP servers
- Production-ready structure

**`manual-only.json`** - No 1Password integration
- All secrets set to manual input
- Keychain-only storage
- Suitable for users without 1Password

**`README.md`** - Examples documentation
- Usage instructions
- Customization guide
- Validation steps
- Best practices

### 3. Updated Project Documentation

**`IMPLEMENTATION_SUMMARY.md`** (Updated)
- Added "Configuration-Based Architecture" section
- Design goals
- Config file location
- Config file structure
- New commands reference
- Updated future enhancements

### 4. Code Architecture

#### New Models

**`SecretsConfig`** - Root configuration structure
```swift
public struct SecretsConfig: Sendable, Codable {
  public let version: String
  public let onePasswordVault: String?
  public let services: [String: ServiceConfig]
  public let mcpServers: [String: MCPServerDefinition]?
}
```

**`ServiceConfig`** - Service-level configuration
```swift
public struct ServiceConfig: Sendable, Codable {
  public let secrets: [String: SecretConfig]
}
```

**`SecretConfig`** - Individual secret configuration
```swift
public struct SecretConfig: Sendable, Codable {
  public let onePasswordRef: String?
  public let keychainAccount: String
  public let keychainService: String
  public let envVar: String?
  public let prompt: String?
  public let validator: String?
}
```

**`MCPServerDefinition`** - MCP server configuration
```swift
public struct MCPServerDefinition: Sendable, Codable {
  public let command: String
  public let args: [String]
  public let description: String?
  public let requiredSecrets: [String]
}
```

**`SecretPath`** - Secret path parsing (e.g., "ghost.url")
```swift
public struct SecretPath: Sendable, Hashable {
  public let service: String
  public let key: String
  
  public init?(path: String)
}
```

#### New Services

**`ConfigService`** - Actor for config management
- `findConfigPath()` - Locate config file (project > user)
- `loadConfig()` - Load and decode JSON
- `saveConfig()` - Encode and save JSON
- `validateConfig()` - Validate structure and references
- `exportTemplate()` - Generate template with placeholders

#### Updated Services

**`SecretsService`** - Extended with config methods
- `fetchSecretsWithConfig()` - Fetch using config
- `updateMCPConfigWithConfig()` - Update MCP using config

#### Updated Commands

**`SetupSecretsCommand`** - New flags and methods
- `--init` - Initialize config interactively
- `--configure` - Edit 1Password references
- `--use-config` - Use config file (new default)
- `--show-config` - Display current config
- `--config <path>` - Custom config path

#### Error Types

**New `SecretsError` cases:**
- `configNotFound(URL)`
- `invalidConfigFormat(String)`
- `invalidSecretPath(String)`
- `configValidationFailed(String)`
- `duplicateKeychainIdentifier(String)`

## Key Features

### 1. Generic Configuration

No hardcoded organization-specific values:
- User defines 1Password vault
- User defines item references
- User defines keychain identifiers
- User defines environment variables

### 2. Multi-Location Support

**Config file locations (priority order):**
1. Project: `./.claude-agents-secrets.json`
2. User: `~/.claude-agents/secrets-config.json`
3. Custom: `--config /path/to/config.json`

**Benefits:**
- Team-shared configs (project)
- Personal overrides (user)
- Multi-environment (custom)

### 3. Team Collaboration

**Template sharing:**
```bash
# Maintainer
claude-agents setup secrets --init
claude-agents setup secrets --export-template > config.template.json
git add config.template.json

# Team member
cp config.template.json .claude-agents-secrets.json
# Edit with personal vault references
claude-agents setup secrets --use-config
```

### 4. Multi-Environment

```bash
# Development
claude-agents setup secrets --config ~/.claude-agents/dev.json

# Staging
claude-agents setup secrets --config ~/.claude-agents/staging.json

# Production
claude-agents setup secrets --config ~/.claude-agents/prod.json
```

### 5. Backward Compatibility

**Deprecated but functional:**
- `--one-password` flag still works (with warning)
- Existing manual input workflow unchanged
- No breaking changes for existing users

### 6. Migration Support

**Automatic detection:**
```bash
claude-agents setup secrets --init
# Detects existing Keychain secrets
# Offers to create config from them
```

**Manual migration:**
1. Check status
2. Initialize config
3. Update references
4. Test

## Workflow Comparison

### Before (Hardcoded)

```bash
# Only option: use hardcoded references
claude-agents setup secrets --one-password
# Uses: op://Employee/Ghost/my site (hardcoded)
```

### After (Config-Based)

```bash
# 1. First-time setup
claude-agents setup secrets --init
# Interactive prompts for config creation

# 2. Regular use
claude-agents setup secrets --use-config
# Reads from ~/.claude-agents/secrets-config.json

# 3. View config
claude-agents setup secrets --show-config

# 4. Edit config
claude-agents setup secrets --configure

# 5. Custom config
claude-agents setup secrets --config /path/to/custom.json

# 6. Manual input (no config)
claude-agents setup secrets --keychain
```

## Security Model

### Safe to Commit

**Config files with references (safe):**
```json
{
  "onePasswordRef": "op://Vault/Item/Field"
}
```

**Why safe:**
- References are not secrets
- Requires 1Password authentication
- Points to secure vault

### Not Safe to Commit

**Config files with actual values (not safe):**
```json
{
  "secret": "sk-1234567890abcdef"
}
```

**Why not safe:**
- Plaintext secrets
- No encryption
- Direct access

### Best Practices

1. Commit templates with `YOUR_VAULT` placeholders
2. Add `.claude-agents-secrets.json` to `.gitignore`
3. Use 1Password references, not actual secrets
4. Set proper file permissions (0644 for config, 0600 for MCP)
5. Share templates, not actual configs

## Implementation Phases

### Phase 1: Models and Services (7.5 hours)
- Create SecretsConfig models
- Update error types
- Create ConfigService
- Update SecretsService

### Phase 2: Commands (4.5 hours)
- Update SetupSecretsCommand
- Add new flags and methods
- Deprecate hardcoded approach

### Phase 3: Documentation (5 hours)
- Create comprehensive guides
- Create example configs
- Update existing docs

### Phase 4: Testing (4 hours)
- Manual testing
- Build and install testing
- Integration testing

### Phase 5: Migration (3 hours)
- Automatic migration support
- Migration guide

### Phase 6: Release (1.5 hours)
- Version bump to 1.2.0
- Release notes

**Total: ~25.5 hours**

## Success Criteria

- [ ] Config file can be created with `--init`
- [ ] Config file can be used with `--use-config`
- [ ] No hardcoded organization-specific values
- [ ] Backward compatible with existing workflows
- [ ] All documentation complete and accurate
- [ ] No compiler warnings or errors
- [ ] CLI builds and installs successfully
- [ ] MCP config updates correctly
- [ ] Claude Code integration works
- [ ] Example configs provided and tested

## Testing Checklist

### Configuration
- [ ] Create config with `--init` (user directory)
- [ ] Create config with `--init` (project directory)
- [ ] Load config from user directory
- [ ] Load config from project directory
- [ ] Load config from custom path
- [ ] Validate config structure
- [ ] Handle missing config file
- [ ] Handle invalid JSON
- [ ] Handle invalid secret paths

### Secrets Fetching
- [ ] Fetch with 1Password (all secrets)
- [ ] Fetch with 1Password (some secrets)
- [ ] Fetch without 1Password (Keychain only)
- [ ] Handle missing 1Password CLI
- [ ] Handle 1Password not authenticated
- [ ] Handle secret not found in 1Password
- [ ] Handle secret not found in Keychain

### MCP Configuration
- [ ] Update MCP config from secrets
- [ ] Create MCP servers from config
- [ ] Preserve existing MCP servers
- [ ] Handle missing MCP config file
- [ ] Backup existing MCP config

### Commands
- [ ] `--init` creates valid config
- [ ] `--show-config` displays correctly
- [ ] `--use-config` fetches and updates
- [ ] `--configure` allows editing
- [ ] `--check` shows config status
- [ ] `--keychain` still works (manual)
- [ ] `--one-password` shows deprecation warning

## Related Files

### Documentation
- `/Users/stijnwillems/Developer/swift-agents-plugin/docs/CONFIG_BASED_SECRETS.md`
- `/Users/stijnwillems/Developer/swift-agents-plugin/docs/REDESIGN_SUMMARY.md`
- `/Users/stijnwillems/Developer/swift-agents-plugin/docs/IMPLEMENTATION_PLAN_CONFIG.md`
- `/Users/stijnwillems/Developer/swift-agents-plugin/docs/CODE_SNIPPETS_CONFIG_SECRETS.md`

### Examples
- `/Users/stijnwillems/Developer/swift-agents-plugin/examples/secrets-configs/template.json`
- `/Users/stijnwillems/Developer/swift-agents-plugin/examples/secrets-configs/minimal-ghost.json`
- `/Users/stijnwillems/Developer/swift-agents-plugin/examples/secrets-configs/enterprise-multi-service.json`
- `/Users/stijnwillems/Developer/swift-agents-plugin/examples/secrets-configs/manual-only.json`
- `/Users/stijnwillems/Developer/swift-agents-plugin/examples/secrets-configs/README.md`

### Updated Files
- `/Users/stijnwillems/Developer/swift-agents-plugin/IMPLEMENTATION_SUMMARY.md`

## Next Steps

1. **Review Documentation**
   - Read through all guides
   - Verify examples are correct
   - Check for inconsistencies

2. **Implementation**
   - Follow phased plan in IMPLEMENTATION_PLAN_CONFIG.md
   - Use code snippets from CODE_SNIPPETS_CONFIG_SECRETS.md
   - Test incrementally

3. **Testing**
   - Create test configs
   - Test all workflows
   - Verify MCP integration

4. **Release**
   - Update version to 1.2.0
   - Update CHANGELOG.md
   - Create release notes

## Questions & Considerations

### For Implementation

1. Should `--init` support service discovery (detect installed MCP servers)?
2. Should config validation run automatically on load?
3. Should there be a `--dry-run` mode for testing configs?
4. Should config support environment variable substitution?
5. Should there be a web UI for config generation?

### For Documentation

1. Should we create video tutorials?
2. Should we add more examples (e.g., GitLab-specific)?
3. Should we document common 1Password vault structures?
4. Should we create troubleshooting flowcharts?

### For Future

1. Support for additional secret sources (AWS Secrets Manager)?
2. Integration with team password managers (LastPass, Dashlane)?
3. Encrypted config files?
4. Cloud-based config sharing?
5. Config profiles (dev/staging/prod) management?

## Conclusion

This redesign transforms `swift-agents-plugin` from a tool with hardcoded, organization-specific references to a **generic, configurable, and reusable** secrets management system.

**Key Achievements:**
- Generic architecture (no hardcoded values)
- User-controlled configuration
- Team collaboration support
- Multi-environment support
- Backward compatibility
- Comprehensive documentation
- Clear migration path

**Impact:**
- Suitable for open-source distribution
- Works for any organization
- Reduces maintenance burden
- Improves user experience
- Enables team adoption

---

**Prepared**: 2025-10-14
**Target Version**: 1.2.0
**Status**: Design Complete, Ready for Implementation
**Estimated Effort**: 25.5 hours (3 days)
