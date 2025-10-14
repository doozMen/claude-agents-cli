# Secrets Management Extension - Summary

## Overview

Extend the existing secrets management system to support:
- **Azure DevOps** (PAT-based authentication)
- **GitLab** (token-based MCP server)
- **Google Cloud** (gcloud application default credentials)
- **Fix timeout issue** with `--force` flag

---

## Architecture Pattern

```
┌─────────────────────────────────────────────────────────────┐
│                    KnownSecret Enum                         │
│  (Models/Secret.swift)                                      │
│                                                             │
│  • displayName         → "Azure DevOps PAT"                 │
│  • keychainService     → "claude-agents-cli.azure-devops"   │
│  • keychainAccount     → "pat"                              │
│  • onePasswordReference → "op://Employee/CompanyA/..."        │
│  • environmentVariable  → "AZURE_DEVOPS_PAT"                │
│  • defaultValue        → nil (or default if applicable)     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   SecretsService Actor                      │
│  (Services/SecretsService.swift)                            │
│                                                             │
│  • fetchFromOnePassword(reference:)                         │
│  • fetchFromKeychain(service:account:)                      │
│  • storeInKeychain(service:account:secret:)                 │
│  • updateMCPConfigWithSecrets([KnownSecret: String])        │
│  • hasGcloudCredentials() -> Bool                           │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              SetupSecretsCommand                            │
│  (Commands/SetupSecretsCommand.swift)                       │
│                                                             │
│  • checkStatus()      → Show Azure/GitLab/gcloud status     │
│  • setupWith1Password() → Fetch from 1Password (timeout fix)│
│  • setupWithKeychain()  → Interactive prompts for new creds │
│  • updateMCPConfig()   → Update from existing Keychain      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│            ~/.config/claude/mcp.json                        │
│                                                             │
│  {                                                          │
│    "mcpServers": {                                          │
│      "azure-devops": { ... },                               │
│      "gitlab": { ... },                                     │
│      "google-cloud": { ... }                                │
│    }                                                        │
│  }                                                          │
└─────────────────────────────────────────────────────────────┘
```

---

## New KnownSecret Cases

| Secret | Keychain Service | Keychain Account | 1Password Reference | Environment Variable |
|--------|-----------------|------------------|---------------------|---------------------|
| **Azure DevOps** | | | | |
| azureDevOpsOrgUrl | claude-agents-cli.azure-devops | org-url | nil (manual) | AZURE_DEVOPS_ORG_URL |
| azureDevOpsPat | claude-agents-cli.azure-devops | pat | `op://.../gitlab private access token api` | AZURE_DEVOPS_PAT |
| azureDevOpsDefaultProject | claude-agents-cli.azure-devops | default-project | nil (manual) | AZURE_DEVOPS_DEFAULT_PROJECT |
| **GitLab** | | | | |
| gitlabPersonalAccessToken | claude-agents-cli.gitlab | personal-access-token | `op://.../gitlab mcp full access...` | GITLAB_PERSONAL_ACCESS_TOKEN |
| gitlabApiUrl | claude-agents-cli.gitlab | api-url | nil (default) | GITLAB_API_URL |
| **Google Cloud** | | | | |
| gcloudCredentialsPath | claude-agents-cli.gcloud | credentials-path | nil (gcloud default) | GOOGLE_APPLICATION_CREDENTIALS |

---

## MCP Server Configurations

### Azure DevOps

```json
{
  "azure-devops": {
    "command": "npx",
    "args": ["-y", "@azure-devops/mcp-server"],
    "env": {
      "AZURE_DEVOPS_ORG_URL": "https://dev.azure.com/companya",
      "AZURE_DEVOPS_PAT": "<from-keychain>",
      "AZURE_DEVOPS_DEFAULT_PROJECT": "ProjectName"
    },
    "description": "Azure DevOps MCP server for work items and repos"
  }
}
```

**Usage**:
- Work item queries
- Repository browsing
- Build/pipeline information

### GitLab

```json
{
  "gitlab": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-gitlab"],
    "env": {
      "GITLAB_PERSONAL_ACCESS_TOKEN": "<from-keychain>",
      "GITLAB_API_URL": "https://gitlab.com/api/v4"
    },
    "description": "GitLab MCP server for project management and CI/CD"
  }
}
```

**Usage**:
- Project management
- Issue tracking
- Merge request operations
- CI/CD pipeline access

### Google Cloud

```json
{
  "google-cloud": {
    "command": "npx",
    "args": ["-y", "@google-cloud/mcp-server"],
    "env": {
      "GOOGLE_APPLICATION_CREDENTIALS": "/Users/username/.config/gcloud/application_default_credentials.json"
    },
    "description": "Google Cloud MCP server for GCP resource management"
  }
}
```

**Usage**:
- Resource management
- Cloud Storage operations
- Compute Engine queries
- IAM operations

---

## Timeout Issue Solution

### Problem

`claude-agents setup secrets --one-password --force` times out after 2 minutes.

### Root Cause

1. Confirmation prompt at line 226 blocks despite `--force` flag
2. 1Password `op read` operations may take time (authentication, network)
3. No progress feedback for user

### Solution (3-part approach)

#### 1. Fix Confirmation Logic

```swift
// Before (WRONG)
print("Continue? (y/n): ", terminator: "")
guard let response = readLine()?.lowercased(),
  response == "y" || response == "yes"
else {
  print("Setup cancelled")
  return
}

// After (CORRECT)
if !force {
  print("Continue? (y/n): ", terminator: "")
  guard let response = readLine()?.lowercased(),
    response == "y" || response == "yes"
  else {
    print("Setup cancelled")
    return
  }
}
```

#### 2. Add Timeout Wrapper

```swift
public func fetchFromOnePasswordWithTimeout(
  reference: String,
  timeout: TimeInterval = 30
) async throws -> String {
  return try await withThrowingTaskGroup(of: String.self) { group in
    group.addTask {
      return try await self.fetchFromOnePassword(reference: reference)
    }
    
    group.addTask {
      try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
      throw SecretsError.operationTimeout(reference)
    }
    
    guard let result = try await group.next() else {
      throw SecretsError.operationTimeout(reference)
    }
    
    group.cancelAll()
    return result
  }
}
```

#### 3. Add Progress Indicators

```swift
print("Fetching secrets from 1Password...")

for (index, knownSecret) in secretsToFetch.enumerated() {
  print("  [\(index + 1)/\(secretsToFetch.count)] \(knownSecret.displayName)...", terminator: " ")
  
  do {
    let value = try await service.fetchFromOnePasswordWithTimeout(reference: opReference)
    print("✅")
  } catch {
    print("❌")
  }
}
```

---

## Implementation Phases

### Phase 1: Models (1-2 hours)
- Add 6 new `KnownSecret` enum cases
- Implement all required properties
- Add `defaultValue` property for optional defaults

### Phase 2: Services (1 hour)
- Update `updateMCPConfigWithSecrets()` with 3 new service blocks
- Add `hasGcloudCredentials()` helper

### Phase 3: Commands (2-3 hours)
- Update `checkStatus()` with 3 new service checks
- Add interactive prompts for Azure/GitLab/gcloud
- Add input validation

### Phase 4: Timeout Fix (1 hour)
- Fix confirmation prompt logic
- Add timeout wrapper
- Add progress indicators

### Phase 5: Documentation (1 hour)
- Update SECRETS_MANAGEMENT.md
- Add troubleshooting guides
- Update examples

### Phase 6: Testing & Polish (2-3 hours)
- Test all new services (manual + 1Password)
- Test backward compatibility
- Format code
- Create release

**Total**: 8-11 hours

---

## Testing Checklist

### Manual Tests

- [ ] `claude-agents setup secrets --check` shows new services
- [ ] `claude-agents setup secrets --keychain` prompts for Azure/GitLab/gcloud
- [ ] Azure DevOps URL validation works
- [ ] GitLab token validation works
- [ ] gcloud credentials auto-detected
- [ ] `claude-agents setup secrets --one-password` fetches new secrets
- [ ] `claude-agents setup secrets --one-password --force` doesn't timeout
- [ ] MCP config updated correctly
- [ ] Restart Claude Code, verify MCP servers load
- [ ] Existing Ghost/Firebase config not broken

### Edge Cases

- [ ] Missing 1Password references (graceful failure)
- [ ] Invalid Azure DevOps URL (validation error)
- [ ] Invalid GitLab token (validation error)
- [ ] Missing gcloud credentials (prompt user)
- [ ] Partial secrets (some services configured, others not)
- [ ] Empty Keychain (fresh install)

---

## Command Reference

### Check Status (with new services)

```bash
claude-agents setup secrets --check

# Output:
# ================================================================
#   Secrets Status
# ================================================================
# 
# 1Password CLI:
#   ✅ Installed
#   ✅ Authenticated
# 
# Keychain Secrets:
#   ✅ Ghost URL
#   ✅ Ghost Admin API Key
#   ✅ Firebase Token
#   ✅ Azure DevOps Personal Access Token
#   ✅ GitLab Personal Access Token
#   ✅ Google Cloud Credentials Path
# 
# MCP Configuration:
#   ✅ Config file exists: /Users/username/.config/claude/mcp.json
#   ✅ Firebase server configured
#   ✅ Ghost server configured
#   ✅ Azure DevOps server configured
#   ✅ GitLab server configured
#   ✅ Google Cloud server configured
# 
# Google Cloud Authentication:
#   ✅ Application default credentials found
```

### Setup with 1Password

```bash
claude-agents setup secrets --one-password --force

# Output:
# ================================================================
#   Setup Secrets with 1Password
# ================================================================
# 
# ✅ 1Password CLI is ready
# 
# Fetching secrets from 1Password...
#   [1/8] Fetching Ghost URL... ✅
#   [2/8] Fetching Ghost Admin API Key... ✅
#   [3/8] Fetching Ghost Content API Key... ✅
#   [4/8] Fetching Azure DevOps Personal Access Token... ✅
#   [5/8] Fetching GitLab Personal Access Token... ✅
#   [6/8] Fetching Firebase Token... ❌
#     Warning: Secret not found in 1Password
#   [7/8] Fetching Azure DevOps Organization URL... (skipped - manual input)
#   [8/8] Fetching GitLab API URL... (skipped - uses default)
# 
# Successfully fetched 5 secret(s)
# 
# Updating MCP configuration...
# ✅ Successfully updated /Users/username/.config/claude/mcp.json
# 
# ================================================================
#   Setup Complete
# ================================================================
```

### Setup with Keychain (interactive)

```bash
claude-agents setup secrets --keychain

# Prompts:
# 1. Configure Ghost CMS? (y/n)
# 2. Configure Firebase? (y/n)
# 3. Configure Azure DevOps? (y/n)
#    - Organization URL: https://dev.azure.com/companya
#    - Personal Access Token: ************
#    - Default Project (optional): MyProject
# 4. Configure GitLab? (y/n)
#    - Personal Access Token: ************
#    - API URL (default: https://gitlab.com/api/v4): [Enter]
# 5. Configure Google Cloud? (y/n)
#    - Detects gcloud default credentials automatically
#    - Or prompts for service account JSON path
```

---

## Backward Compatibility

All changes are **backward compatible**:

- Existing `KnownSecret` cases unchanged
- Existing Keychain entries preserved
- Existing MCP config entries preserved
- New secrets are opt-in (no breaking changes)
- `--check`, `--update-only`, `--one-password`, `--keychain` flags work as before

---

## Success Criteria

### Functional
- All 3 new services configurable via 1Password and manual input
- MCP config updated correctly
- Secrets stored in Keychain
- `--force` flag doesn't timeout

### Non-Functional
- Clear progress indicators
- User-friendly error messages
- No timeout (< 2 minutes for all operations)
- Backward compatible with existing setup

### User Experience
- Interactive prompts are helpful
- Default values reduce manual input
- Validation catches mistakes
- Status checks provide actionable info

---

## Files Modified

1. **Sources/claude-agents-cli/Models/Secret.swift**
   - Add 6 new `KnownSecret` cases
   - Add `defaultValue` property

2. **Sources/claude-agents-cli/Services/SecretsService.swift**
   - Update `updateMCPConfigWithSecrets()` with 3 new service blocks
   - Add `hasGcloudCredentials()` helper
   - Add `fetchFromOnePasswordWithTimeout()` method

3. **Sources/claude-agents-cli/Commands/SetupSecretsCommand.swift**
   - Update `checkStatus()` with new service checks
   - Add interactive prompts for Azure/GitLab/gcloud
   - Fix confirmation prompt in `setupWith1Password()`
   - Add progress indicators

4. **Sources/claude-agents-cli/Models/Errors.swift**
   - Add `SecretsError.operationTimeout` case

5. **docs/SECRETS_MANAGEMENT.md**
   - Add Azure DevOps, GitLab, Google Cloud sections
   - Update examples and troubleshooting

---

## Quick Start (After Implementation)

### 1. Install Latest Version

```bash
cd ~/Developer/claude-agents-cli
rm -f ~/.swiftpm/bin/claude-agents
swift package experimental-install --product claude-agents
```

### 2. Setup Azure DevOps

```bash
claude-agents setup secrets --keychain
# Follow prompts for Azure DevOps configuration
```

### 3. Setup GitLab

```bash
claude-agents setup secrets --one-password --force
# Automatically fetches GitLab token from 1Password
```

### 4. Verify Configuration

```bash
claude-agents setup secrets --check
# Should show all services configured
```

### 5. Restart Claude Code

Restart Claude Code to load new MCP configuration.

---

## Future Enhancements (Out of Scope)

- SSH key management for GitLab
- Multiple account support (multiple Azure orgs, GitLab instances)
- Secret rotation workflows
- Team sharing via 1Password shared vaults
- Additional MCP servers (GitHub, Jira, AWS, etc.)

---

## Questions?

For detailed implementation steps, see **IMPLEMENTATION_PLAN.md**.

For current documentation, see **docs/SECRETS_MANAGEMENT.md**.
