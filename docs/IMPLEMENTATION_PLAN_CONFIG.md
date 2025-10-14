# Implementation Plan: Configuration-Based Secrets Management

## Overview

This document outlines the implementation plan for transitioning from hardcoded 1Password references to a configuration-based approach for secrets management in `claude-agents-cli`.

**Goal**: Make the secrets management system generic, reusable, and configurable across different organizations and team structures.

## Design Principles

1. **Configuration over Convention**: All 1Password references in config files, not code
2. **Backward Compatible**: Existing manual input workflow still works
3. **Team-Friendly**: Share config templates within teams
4. **Multi-Environment**: Support dev, staging, prod configs
5. **Gradual Migration**: Existing users can migrate incrementally

## Phase 1: Core Models and Services

### Step 1.1: Create SecretsConfig Model

**File**: `Sources/claude-agents-cli/Models/SecretsConfig.swift`

**Tasks:**
- [ ] Create `SecretsConfig` struct (Sendable, Codable)
- [ ] Create `ServiceConfig` struct
- [ ] Create `SecretConfig` struct
- [ ] Create `MCPServerDefinition` struct
- [ ] Create `SecretPath` struct for path parsing
- [ ] Add comprehensive documentation

**Models:**
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

**Estimated Time**: 2 hours

### Step 1.2: Update Errors

**File**: `Sources/claude-agents-cli/Models/Errors.swift`

**Tasks:**
- [ ] Add `configNotFound` case
- [ ] Add `invalidConfigFormat` case
- [ ] Add `invalidSecretPath` case
- [ ] Add `configValidationFailed` case
- [ ] Add `duplicateKeychainIdentifier` case
- [ ] Update error descriptions

**Estimated Time**: 30 minutes

### Step 1.3: Create ConfigService

**File**: `Sources/claude-agents-cli/Services/ConfigService.swift`

**Tasks:**
- [ ] Create `ConfigService` actor
- [ ] Implement `userConfigPath()` method
- [ ] Implement `projectConfigPath()` method
- [ ] Implement `findConfigPath()` method
- [ ] Implement `loadConfig()` method with JSON decoding
- [ ] Implement `saveConfig()` method with JSON encoding
- [ ] Implement `validateConfig()` method
- [ ] Implement `exportTemplate()` method
- [ ] Add file permission setting (0644)
- [ ] Add comprehensive error handling

**Estimated Time**: 3 hours

### Step 1.4: Update SecretsService

**File**: `Sources/claude-agents-cli/Services/SecretsService.swift`

**Tasks:**
- [ ] Add `fetchSecretsWithConfig()` method
- [ ] Add `updateMCPConfigWithConfig()` method
- [ ] Implement config-based secret fetching
- [ ] Implement config-based MCP config update
- [ ] Handle missing secrets gracefully
- [ ] Add progress indicators

**Estimated Time**: 2 hours

## Phase 2: Command Updates

### Step 2.1: Update SetupSecretsCommand

**File**: `Sources/claude-agents-cli/Commands/SetupSecretsCommand.swift`

**Tasks:**
- [ ] Add `--init` flag for config initialization
- [ ] Add `--configure` flag for editing config
- [ ] Add `--use-config` flag (replaces `--one-password`)
- [ ] Add `--show-config` flag
- [ ] Add `--config` option for custom config path
- [ ] Implement `initializeConfig()` method (interactive)
- [ ] Implement `configureReferences()` method (interactive)
- [ ] Implement `displayConfig()` method
- [ ] Implement `setupWithConfig()` method
- [ ] Update help text and documentation

**Interactive Flow for `--init`:**
1. Prompt: "Save to user directory or project directory?"
2. Prompt: "1Password vault name (or leave empty for manual)"
3. Prompt: "Select services to configure: [Ghost, Firebase, Azure DevOps, GitHub, GitLab]"
4. For each service:
   - Prompt: "Configure [Service]? (y/n)"
   - For each secret:
     - Prompt: "1Password reference (or leave empty)"
     - Auto-generate keychain identifiers
     - Auto-generate environment variable names
5. Prompt: "Configure MCP servers? (y/n)"
6. Save config to file
7. Display summary

**Estimated Time**: 4 hours

### Step 2.2: Deprecate Hardcoded Approach

**Tasks:**
- [ ] Mark `--one-password` as deprecated
- [ ] Add deprecation warning
- [ ] Update help text to recommend `--use-config`
- [ ] Keep functionality for backward compatibility

**Estimated Time**: 30 minutes

## Phase 3: Documentation

### Step 3.1: Create Documentation Files

**Tasks:**
- [ ] Create `docs/CONFIG_BASED_SECRETS.md` (comprehensive guide)
- [ ] Create `docs/CODE_SNIPPETS_CONFIG_SECRETS.md` (implementation examples)
- [ ] Create example configs in `examples/secrets-configs/`
  - [ ] `template.json`
  - [ ] `minimal-ghost.json`
  - [ ] `manual-only.json`
  - [ ] `enterprise-multi-service.json`
- [ ] Create `examples/secrets-configs/README.md`

**Estimated Time**: 3 hours

### Step 3.2: Update Existing Documentation

**Files to Update:**
- `docs/SECRETS_MANAGEMENT.md`
- `CLAUDE.md`
- `README.md`
- `IMPLEMENTATION_SUMMARY.md`

**Tasks:**
- [ ] Update `SECRETS_MANAGEMENT.md` with config-based workflow
- [ ] Update `CLAUDE.md` command examples
- [ ] Update `README.md` with new workflow
- [ ] Update `IMPLEMENTATION_SUMMARY.md` with architecture changes

**Estimated Time**: 2 hours

## Phase 4: Testing

### Step 4.1: Manual Testing

**Test Cases:**
- [ ] Initialize config with `--init`
  - [ ] User directory
  - [ ] Project directory
  - [ ] With 1Password vault
  - [ ] Without 1Password vault
- [ ] Display config with `--show-config`
- [ ] Setup with config `--use-config`
  - [ ] With 1Password
  - [ ] Without 1Password (manual input)
  - [ ] Mixed (some secrets in 1Password, some manual)
- [ ] Custom config path `--config /path/to/config.json`
- [ ] Config validation
- [ ] Error handling
  - [ ] Missing config file
  - [ ] Invalid JSON
  - [ ] Invalid secret paths
  - [ ] Duplicate keychain identifiers

**Estimated Time**: 3 hours

### Step 4.2: Build and Install Testing

**Tasks:**
- [ ] Build with `swift build`
- [ ] Run formatter: `swift format format -p -r -i Sources`
- [ ] Fix any warnings
- [ ] Install with `swift package experimental-install`
- [ ] Test installed CLI
- [ ] Verify MCP config updates correctly
- [ ] Test with Claude Code integration

**Estimated Time**: 1 hour

## Phase 5: Migration Support

### Step 5.1: Automatic Migration

**Tasks:**
- [ ] Detect existing Keychain secrets
- [ ] Offer to create config from existing secrets
- [ ] Generate config with discovered secrets
- [ ] Prompt for 1Password references
- [ ] Save config

**Estimated Time**: 2 hours

### Step 5.2: Migration Guide

**Tasks:**
- [ ] Create `docs/MIGRATION_TO_CONFIG.md`
- [ ] Document step-by-step migration
- [ ] Provide rollback instructions
- [ ] Include troubleshooting section

**Estimated Time**: 1 hour

## Phase 6: Release

### Step 6.1: Version Bump

**Tasks:**
- [ ] Update version to 1.2.0 in `Main.swift`
- [ ] Update `CHANGELOG.md`
- [ ] Update version references in documentation

**Estimated Time**: 30 minutes

### Step 6.2: Release Notes

**Tasks:**
- [ ] Write release notes
- [ ] Document breaking changes (deprecations)
- [ ] Highlight new features
- [ ] Provide upgrade instructions

**Estimated Time**: 1 hour

## Total Estimated Time

- Phase 1: 7.5 hours
- Phase 2: 4.5 hours
- Phase 3: 5 hours
- Phase 4: 4 hours
- Phase 5: 3 hours
- Phase 6: 1.5 hours

**Total: ~25.5 hours**

## Implementation Order

### Recommended Sequence

1. **Day 1** (8 hours)
   - Create all models (1.1, 1.2)
   - Create ConfigService (1.3)
   - Update SecretsService (1.4)
   - Build and test compilation

2. **Day 2** (8 hours)
   - Update SetupSecretsCommand (2.1, 2.2)
   - Create documentation files (3.1)
   - Build and test basic functionality

3. **Day 3** (8 hours)
   - Update existing documentation (3.2)
   - Manual testing (4.1, 4.2)
   - Migration support (5.1, 5.2)
   - Release preparation (6.1, 6.2)

## Risk Mitigation

### Potential Issues

1. **Breaking Changes**: Existing users expect `--one-password`
   - **Mitigation**: Keep flag, add deprecation warning
   
2. **Config File Format**: JSON schema might need changes
   - **Mitigation**: Version field allows future format changes

3. **1Password Reference Complexity**: Different organizations have different structures
   - **Mitigation**: Fully configurable, no assumptions

4. **Testing Coverage**: No unit tests currently
   - **Mitigation**: Comprehensive manual testing, add tests in future

## Success Criteria

- [ ] Users can create config with `--init`
- [ ] Users can use config with `--use-config`
- [ ] Config files are generic (no hardcoded Rossel references)
- [ ] Backward compatible with manual input
- [ ] All documentation updated
- [ ] No compiler warnings or errors
- [ ] CLI installs and runs successfully
- [ ] MCP config updates correctly
- [ ] Claude Code integration works

## Future Enhancements (Post-1.2.0)

- [ ] Config validation command
- [ ] Config import/export
- [ ] Multiple config profiles (dev/staging/prod)
- [ ] Team config sharing via git
- [ ] Web UI for config generation
- [ ] Support for additional secret sources (AWS Secrets Manager, HashiCorp Vault)

## Related Files

- Implementation Summary: `IMPLEMENTATION_SUMMARY.md`
- Config Guide: `docs/CONFIG_BASED_SECRETS.md`
- Code Snippets: `docs/CODE_SNIPPETS_CONFIG_SECRETS.md`
- Examples: `examples/secrets-configs/`

---

**Created**: 2025-10-14
**Target Version**: 1.2.0
**Status**: Planning
