# Implementation Plan: Extend Secrets Management

## Executive Summary

This document outlines the implementation plan for extending the secrets management system in `swift-agents-plugin` to support:
1. Azure DevOps (PAT-based authentication)
2. GitLab (token-based and OAuth support)
3. Google Cloud (gcloud application default credentials)

Additionally, we'll address the timeout issue with the `--force` flag when using 1Password.

---

## 1. Current Architecture Analysis

### Current State

**Models** (`Sources/claude-agents-cli/Models/Secret.swift`):
- `KnownSecret` enum with 4 cases: `ghostUrl`, `ghostAdminApiKey`, `ghostContentApiKey`, `firebaseToken`
- Each secret has: `displayName`, `keychainService`, `keychainAccount`, `onePasswordReference`, `environmentVariable`

**Services** (`Sources/claude-agents-cli/Services/SecretsService.swift`):
- Actor-based for thread-safe operations
- Methods: `fetchFromOnePassword()`, `fetchFromKeychain()`, `storeInKeychain()`, `updateMCPConfigWithSecrets()`
- Supports Firebase and Ghost MCP server configuration

**Commands** (`Sources/claude-agents-cli/Commands/SetupSecretsCommand.swift`):
- Modes: `--check`, `--update-only`, `--one-password`, `--keychain`, `--force`
- Interactive prompts for Ghost and Firebase configuration

### Architecture Strengths

- Clean separation of concerns (Model-Service-Command)
- Actor-based concurrency for thread safety
- Extensible enum-based secret definitions
- Automatic MCP config backup before modifications
- Support for both 1Password and manual Keychain input

### Identified Issues

**Timeout Problem**:
- `--force` mode with 1Password times out after 2 minutes
- Likely caused by: synchronous `readLine()` calls blocking during async 1Password operations
- Location: `SetupSecretsCommand.swift:226-232` (confirmation prompt in setupWith1Password)

---

## 2. Credential Requirements Analysis

### Azure DevOps MCP Server

**Required Credentials**:
- `AZURE_DEVOPS_ORG_URL`: Organization URL (e.g., `https://dev.azure.com/companya`)
- `AZURE_DEVOPS_PAT`: Personal Access Token
- `AZURE_DEVOPS_DEFAULT_PROJECT`: Default project name (optional)

**Available 1Password References**:
- `op://Employee/CompanyA Azure - Gitlab/gitlab private access token api` (likely shared GitLab/Azure token)
- Alternative: Use dedicated Azure DevOps field in 1Password

**Keychain Storage Strategy**:
- Service: `swift-agents-plugin.azure-devops`
- Accounts: `org-url`, `pat`, `default-project`

**MCP Configuration**:
```json
{
  "azure-devops": {
    "command": "npx",
    "args": ["-y", "@azure-devops/mcp-server"],
    "env": {
      "AZURE_DEVOPS_ORG_URL": "<from-keychain>",
      "AZURE_DEVOPS_PAT": "<from-keychain>",
      "AZURE_DEVOPS_DEFAULT_PROJECT": "<from-keychain-optional>"
    },
    "description": "Azure DevOps MCP server for work items and repos"
  }
}
```

### GitLab MCP Server

**Required Credentials**:
- **Token-based** (community @modelcontextprotocol/server-gitlab):
  - `GITLAB_PERSONAL_ACCESS_TOKEN`: Personal access token
  - `GITLAB_API_URL`: GitLab instance URL (default: `https://gitlab.com/api/v4`)
- **OAuth-based** (official GitLab MCP): No environment variables needed (browser OAuth flow)

**Available 1Password References**:
- `op://Employee/CompanyA/gitlab mcp full access sauf ai and kubernetes`
- `op://Employee/CompanyA Azure - Gitlab/gitlab private access token api`
- `op://Employee/CompanyA Azure - Gitlab/private key` (SSH key for git operations)

**Keychain Storage Strategy**:
- Service: `swift-agents-plugin.gitlab`
- Accounts: `personal-access-token`, `api-url`, `ssh-private-key` (optional)

**MCP Configuration**:
```json
{
  "gitlab": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-gitlab"],
    "env": {
      "GITLAB_PERSONAL_ACCESS_TOKEN": "<from-keychain>",
      "GITLAB_API_URL": "<from-keychain>"
    },
    "description": "GitLab MCP server for project management and CI/CD"
  }
}
```

### Google Cloud (gcloud)

**Required Credentials**:
- `GOOGLE_APPLICATION_CREDENTIALS`: Path to service account JSON file
- Alternative: Use `gcloud auth application-default login` (stores credentials at `~/.config/gcloud/application_default_credentials.json`)

**Available 1Password References**:
- Not currently available in provided references
- Would need: `op://Employee/Google Cloud/service account json` (if exists)

**Keychain Storage Strategy**:
- Option 1: Store path to credentials file
  - Service: `swift-agents-plugin.gcloud`
  - Account: `credentials-path`
- Option 2: Store entire JSON content (not recommended due to size)

**MCP Configuration**:
```json
{
  "google-cloud": {
    "command": "npx",
    "args": ["-y", "@google-cloud/mcp-server"],
    "env": {
      "GOOGLE_APPLICATION_CREDENTIALS": "<from-keychain-or-default>"
    },
    "description": "Google Cloud MCP server for GCP resource management"
  }
}
```

**Special Handling**:
- If no custom credentials, default to `~/.config/gcloud/application_default_credentials.json`
- Check if file exists before setting environment variable
- Prompt user to run `gcloud auth application-default login` if not authenticated

---

## 3. Implementation Plan

### Phase 1: Model Extensions

**File**: `Sources/claude-agents-cli/Models/Secret.swift`

**Changes**:
1. Add new `KnownSecret` enum cases:
   - `azureDevOpsOrgUrl`
   - `azureDevOpsPat`
   - `azureDevOpsDefaultProject`
   - `gitlabPersonalAccessToken`
   - `gitlabApiUrl`
   - `gcloudCredentialsPath`

2. Update enum properties for each case:
   - `displayName`: User-friendly name
   - `keychainService`: Keychain service identifier
   - `keychainAccount`: Keychain account identifier
   - `onePasswordReference`: 1Password secret reference (if available)
   - `environmentVariable`: MCP environment variable name

**Example**:
```swift
public enum KnownSecret: String, Sendable, CaseIterable {
  // Existing cases...
  case firebaseToken = "firebase-token"
  
  // Azure DevOps
  case azureDevOpsOrgUrl = "azure-devops-org-url"
  case azureDevOpsPat = "azure-devops-pat"
  case azureDevOpsDefaultProject = "azure-devops-default-project"
  
  // GitLab
  case gitlabPersonalAccessToken = "gitlab-personal-access-token"
  case gitlabApiUrl = "gitlab-api-url"
  
  // Google Cloud
  case gcloudCredentialsPath = "gcloud-credentials-path"
  
  public var displayName: String {
    switch self {
    // ... existing cases
    case .azureDevOpsOrgUrl: return "Azure DevOps Organization URL"
    case .azureDevOpsPat: return "Azure DevOps Personal Access Token"
    case .azureDevOpsDefaultProject: return "Azure DevOps Default Project"
    case .gitlabPersonalAccessToken: return "GitLab Personal Access Token"
    case .gitlabApiUrl: return "GitLab API URL"
    case .gcloudCredentialsPath: return "Google Cloud Credentials Path"
    }
  }
  
  public var keychainService: String {
    switch self {
    // ... existing cases
    case .azureDevOpsOrgUrl, .azureDevOpsPat, .azureDevOpsDefaultProject:
      return "swift-agents-plugin.azure-devops"
    case .gitlabPersonalAccessToken, .gitlabApiUrl:
      return "swift-agents-plugin.gitlab"
    case .gcloudCredentialsPath:
      return "swift-agents-plugin.gcloud"
    }
  }
  
  public var keychainAccount: String {
    switch self {
    // ... existing cases
    case .azureDevOpsOrgUrl: return "org-url"
    case .azureDevOpsPat: return "pat"
    case .azureDevOpsDefaultProject: return "default-project"
    case .gitlabPersonalAccessToken: return "personal-access-token"
    case .gitlabApiUrl: return "api-url"
    case .gcloudCredentialsPath: return "credentials-path"
    }
  }
  
  public var onePasswordReference: String? {
    switch self {
    // ... existing cases
    case .azureDevOpsOrgUrl:
      return nil  // Manual input required
    case .azureDevOpsPat:
      return "op://Employee/CompanyA Azure - Gitlab/gitlab private access token api"
    case .azureDevOpsDefaultProject:
      return nil  // Manual input required
    case .gitlabPersonalAccessToken:
      return "op://Employee/CompanyA/gitlab mcp full access sauf ai and kubernetes"
    case .gitlabApiUrl:
      return nil  // Default: https://gitlab.com/api/v4
    case .gcloudCredentialsPath:
      return nil  // Use gcloud auth application-default
    }
  }
  
  public var environmentVariable: String {
    switch self {
    // ... existing cases
    case .azureDevOpsOrgUrl: return "AZURE_DEVOPS_ORG_URL"
    case .azureDevOpsPat: return "AZURE_DEVOPS_PAT"
    case .azureDevOpsDefaultProject: return "AZURE_DEVOPS_DEFAULT_PROJECT"
    case .gitlabPersonalAccessToken: return "GITLAB_PERSONAL_ACCESS_TOKEN"
    case .gitlabApiUrl: return "GITLAB_API_URL"
    case .gcloudCredentialsPath: return "GOOGLE_APPLICATION_CREDENTIALS"
    }
  }
  
  // NEW: Add optional property for default values
  public var defaultValue: String? {
    switch self {
    case .gitlabApiUrl:
      return "https://gitlab.com/api/v4"
    case .gcloudCredentialsPath:
      return FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".config/gcloud/application_default_credentials.json")
        .path
    default:
      return nil
    }
  }
}
```

### Phase 2: Service Extensions

**File**: `Sources/claude-agents-cli/Services/SecretsService.swift`

**Changes**:

1. **Update `updateMCPConfigWithSecrets()` method**:
   Add configuration blocks for Azure DevOps, GitLab, and Google Cloud.

```swift
public func updateMCPConfigWithSecrets(
  _ secrets: [KnownSecret: String]
) async throws {
  var config = try await readMCPConfig()

  // ... existing Firebase and Ghost configuration

  // Update Azure DevOps configuration
  if let orgUrl = secrets[.azureDevOpsOrgUrl],
     let pat = secrets[.azureDevOpsPat] {
    var azureConfig = config.mcpServers["azure-devops"]
      ?? MCPServerConfig(
        command: "npx",
        args: ["-y", "@azure-devops/mcp-server"],
        env: [:],
        description: "Azure DevOps MCP server for work items and repos"
      )
    azureConfig.env["AZURE_DEVOPS_ORG_URL"] = orgUrl
    azureConfig.env["AZURE_DEVOPS_PAT"] = pat
    if let project = secrets[.azureDevOpsDefaultProject] {
      azureConfig.env["AZURE_DEVOPS_DEFAULT_PROJECT"] = project
    }
    config.mcpServers["azure-devops"] = azureConfig
  }

  // Update GitLab configuration
  if let token = secrets[.gitlabPersonalAccessToken] {
    var gitlabConfig = config.mcpServers["gitlab"]
      ?? MCPServerConfig(
        command: "npx",
        args: ["-y", "@modelcontextprotocol/server-gitlab"],
        env: [:],
        description: "GitLab MCP server for project management and CI/CD"
      )
    gitlabConfig.env["GITLAB_PERSONAL_ACCESS_TOKEN"] = token
    gitlabConfig.env["GITLAB_API_URL"] = secrets[.gitlabApiUrl] 
      ?? "https://gitlab.com/api/v4"
    config.mcpServers["gitlab"] = gitlabConfig
  }

  // Update Google Cloud configuration
  if let credentialsPath = secrets[.gcloudCredentialsPath] {
    // Verify file exists
    if fileManager.fileExists(atPath: credentialsPath) {
      var gcloudConfig = config.mcpServers["google-cloud"]
        ?? MCPServerConfig(
          command: "npx",
          args: ["-y", "@google-cloud/mcp-server"],
          env: [:],
          description: "Google Cloud MCP server for GCP resource management"
        )
      gcloudConfig.env["GOOGLE_APPLICATION_CREDENTIALS"] = credentialsPath
      config.mcpServers["google-cloud"] = gcloudConfig
    }
  }

  try await writeMCPConfig(config)
}
```

2. **Add helper method for gcloud authentication check**:

```swift
/// Check if gcloud application default credentials exist
public func hasGcloudCredentials() async -> Bool {
  let defaultPath = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent(".config/gcloud/application_default_credentials.json")
  return fileManager.fileExists(atPath: defaultPath.path)
}
```

### Phase 3: Command Extensions

**File**: `Sources/claude-agents-cli/Commands/SetupSecretsCommand.swift`

**Changes**:

1. **Update `checkStatus()` method**:
   Add status checks for Azure DevOps, GitLab, and Google Cloud.

```swift
private func checkStatus(service: SecretsService) async throws {
  // ... existing checks for 1Password, Keychain

  // Check MCP config
  print("MCP Configuration:")
  let configPath = service.mcpConfigPath()
  let fileManager = FileManager.default

  if fileManager.fileExists(atPath: configPath.path) {
    print("  ✅ Config file exists: \(configPath.path)")

    do {
      let config = try await service.readMCPConfig()

      // ... existing Firebase and Ghost checks

      // Check Azure DevOps
      if let azureConfig = config.mcpServers["azure-devops"] {
        let hasOrgUrl = !(azureConfig.env["AZURE_DEVOPS_ORG_URL"]?.isEmpty ?? true)
        let hasPat = !(azureConfig.env["AZURE_DEVOPS_PAT"]?.isEmpty ?? true)
        print("  \(hasOrgUrl && hasPat ? "✅" : "❌") Azure DevOps server configured")
      } else {
        print("  ❌ Azure DevOps server not configured")
      }

      // Check GitLab
      if let gitlabConfig = config.mcpServers["gitlab"] {
        let hasToken = !(gitlabConfig.env["GITLAB_PERSONAL_ACCESS_TOKEN"]?.isEmpty ?? true)
        print("  \(hasToken ? "✅" : "❌") GitLab server configured")
      } else {
        print("  ❌ GitLab server not configured")
      }

      // Check Google Cloud
      if let gcloudConfig = config.mcpServers["google-cloud"] {
        let hasCredentials = !(gcloudConfig.env["GOOGLE_APPLICATION_CREDENTIALS"]?.isEmpty ?? true)
        print("  \(hasCredentials ? "✅" : "❌") Google Cloud server configured")
      } else {
        print("  ❌ Google Cloud server not configured")
      }
    } catch {
      print("  ⚠️  Failed to read config: \(error)")
    }
  } else {
    print("  ❌ Config file not found: \(configPath.path)")
  }

  // Check gcloud authentication
  print("")
  print("Google Cloud Authentication:")
  if await service.hasGcloudCredentials() {
    print("  ✅ Application default credentials found")
  } else {
    print("  ❌ No application default credentials")
    print("     Run: gcloud auth application-default login")
  }

  print("")
}
```

2. **Update `setupWithKeychain()` method**:
   Add interactive prompts for Azure DevOps, GitLab, and Google Cloud.

```swift
private func setupWithKeychain(service: SecretsService) async throws {
  // ... existing Ghost and Firebase configuration

  // Azure DevOps
  print("")
  print("────────────────────────────────────────────────────────────")
  print("  Azure DevOps Configuration")
  print("────────────────────────────────────────────────────────────")
  print("")

  let configureAzure: Bool
  if force {
    configureAzure = true
  } else {
    print("Configure Azure DevOps? (y/n): ", terminator: "")
    if let response = readLine()?.lowercased(),
       response == "y" || response == "yes" {
      configureAzure = true
    } else {
      print("Skipped Azure DevOps configuration")
      print("")
      configureAzure = false
    }
  }

  if configureAzure {
    // Organization URL
    var orgUrl = ""
    while true {
      print("Azure DevOps Organization URL (e.g., https://dev.azure.com/companya): ", terminator: "")
      guard let input = readLine()?.trimmingCharacters(in: .whitespaces),
            !input.isEmpty else {
        print("URL cannot be empty")
        continue
      }

      if input.hasPrefix("https://dev.azure.com/") {
        orgUrl = input.hasSuffix("/") ? String(input.dropLast()) : input
        break
      } else {
        print("❌ Invalid URL format. Must start with https://dev.azure.com/")
      }
    }
    secrets[.azureDevOpsOrgUrl] = orgUrl

    // Personal Access Token
    print("")
    print("Get your Azure DevOps PAT from:")
    print("  \(orgUrl)/_usersSettings/tokens")
    print("")
    print("Required permissions: Work Items (read/write), Code (read)")
    print("")
    print("Azure DevOps Personal Access Token: ", terminator: "")
    if let pat = readLine()?.trimmingCharacters(in: .whitespaces),
       !pat.isEmpty {
      secrets[.azureDevOpsPat] = pat
    }

    // Default Project (optional)
    print("")
    print("Default Project (optional, press Enter to skip): ", terminator: "")
    if let project = readLine()?.trimmingCharacters(in: .whitespaces),
       !project.isEmpty {
      secrets[.azureDevOpsDefaultProject] = project
    }
  }

  // GitLab
  print("")
  print("────────────────────────────────────────────────────────────")
  print("  GitLab Configuration")
  print("────────────────────────────────────────────────────────────")
  print("")

  let configureGitLab: Bool
  if force {
    configureGitLab = true
  } else {
    print("Configure GitLab? (y/n): ", terminator: "")
    if let response = readLine()?.lowercased(),
       response == "y" || response == "yes" {
      configureGitLab = true
    } else {
      print("Skipped GitLab configuration")
      print("")
      configureGitLab = false
    }
  }

  if configureGitLab {
    // Personal Access Token
    print("Get your GitLab Personal Access Token from:")
    print("  https://gitlab.com/-/user_settings/personal_access_tokens")
    print("")
    print("Required scopes: api, read_repository, write_repository")
    print("")
    print("GitLab Personal Access Token: ", terminator: "")
    if let token = readLine()?.trimmingCharacters(in: .whitespaces),
       !token.isEmpty {
      secrets[.gitlabPersonalAccessToken] = token
    }

    // API URL (optional, default to gitlab.com)
    print("")
    print("GitLab API URL (press Enter for default: https://gitlab.com/api/v4): ", terminator: "")
    if let apiUrl = readLine()?.trimmingCharacters(in: .whitespaces),
       !apiUrl.isEmpty {
      secrets[.gitlabApiUrl] = apiUrl
    } else {
      secrets[.gitlabApiUrl] = "https://gitlab.com/api/v4"
    }
  }

  // Google Cloud
  print("")
  print("────────────────────────────────────────────────────────────")
  print("  Google Cloud Configuration")
  print("────────────────────────────────────────────────────────────")
  print("")

  let configureGcloud: Bool
  if force {
    configureGcloud = true
  } else {
    print("Configure Google Cloud? (y/n): ", terminator: "")
    if let response = readLine()?.lowercased(),
       response == "y" || response == "yes" {
      configureGcloud = true
    } else {
      print("Skipped Google Cloud configuration")
      print("")
      configureGcloud = false
    }
  }

  if configureGcloud {
    let defaultPath = FileManager.default.homeDirectoryForCurrentUser
      .appendingPathComponent(".config/gcloud/application_default_credentials.json")

    if FileManager.default.fileExists(atPath: defaultPath.path) {
      print("✅ Found application default credentials")
      print("   Path: \(defaultPath.path)")
      secrets[.gcloudCredentialsPath] = defaultPath.path
    } else {
      print("❌ Application default credentials not found")
      print("")
      print("Run the following command to authenticate:")
      print("  gcloud auth application-default login")
      print("")
      print("Or provide a custom service account JSON path:")
      print("Service Account JSON Path (press Enter to skip): ", terminator: "")
      if let customPath = readLine()?.trimmingCharacters(in: .whitespaces),
         !customPath.isEmpty {
        if FileManager.default.fileExists(atPath: customPath) {
          secrets[.gcloudCredentialsPath] = customPath
        } else {
          print("⚠️  File not found at \(customPath), skipping")
        }
      }
    }
  }

  // ... existing code to store secrets and update MCP config
}
```

3. **Update `setupWith1Password()` method**:
   No significant changes needed - the method already iterates through `KnownSecret.allCases` and fetches available secrets.

### Phase 4: Fix Timeout Issue

**Problem**: The `--force` flag with 1Password times out because the confirmation prompt on line 226 still blocks despite `--force` being set.

**Root Cause**: The code path in `setupWith1Password()` (lines 224-233) prompts for confirmation even when `--force` is true, but the prompt is skipped. However, the async operation to fetch from 1Password might be blocking on authentication.

**Solution 1: Skip confirmation properly**:

```swift
// In setupWith1Password() method
// Confirm
if !force {
  print("Continue? (y/n): ", terminator: "")
  guard let response = readLine()?.lowercased(),
    response == "y" || response == "yes"
  else {
    print("Setup cancelled")
    return
  }
  print("")  // Move this outside the if block
}

print("")  // Add this line
print("Fetching secrets from 1Password...")
```

**Solution 2: Add timeout to 1Password operations**:

Add a timeout wrapper for async operations:

```swift
// In SecretsService.swift
/// Fetch a secret from 1Password with timeout
public func fetchFromOnePassword(reference: String, timeout: TimeInterval = 30) async throws -> String {
  return try await withThrowingTaskGroup(of: String.self) { group in
    // Add fetch task
    group.addTask {
      return try await self._fetchFromOnePasswordInternal(reference: reference)
    }
    
    // Add timeout task
    group.addTask {
      try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
      throw SecretsError.operationTimeout(reference)
    }
    
    // Return first result (either success or timeout)
    guard let result = try await group.next() else {
      throw SecretsError.operationTimeout(reference)
    }
    
    group.cancelAll()
    return result
  }
}

// Rename existing method
private func _fetchFromOnePasswordInternal(reference: String) async throws -> String {
  // ... existing implementation
}
```

**Solution 3: Add progress indicators**:

Show progress during 1Password sync to give user feedback:

```swift
// In setupWith1Password() method
print("")
print("Fetching secrets from 1Password...")

// Sync from 1Password with progress
let secretsToFetch = KnownSecret.allCases.filter { $0.onePasswordReference != nil }
var fetched = 0

for knownSecret in secretsToFetch {
  guard let opReference = knownSecret.onePasswordReference else {
    continue
  }
  
  print("  [\(fetched + 1)/\(secretsToFetch.count)] Fetching \(knownSecret.displayName)...", terminator: " ")
  
  do {
    let value = try await service.fetchFromOnePassword(reference: opReference, timeout: 30)
    secrets[knownSecret] = value
    
    // Store in Keychain
    try await service.storeInKeychain(
      service: knownSecret.keychainService,
      account: knownSecret.keychainAccount,
      secret: value
    )
    print("✅")
    fetched += 1
  } catch {
    print("❌")
    print("    Warning: \(error)")
  }
}
```

**Recommended Approach**: Implement all three solutions:
1. Fix the confirmation prompt logic (quick fix)
2. Add timeout to 1Password operations (safety net)
3. Add progress indicators (better UX)

### Phase 5: Documentation Updates

**File**: `docs/SECRETS_MANAGEMENT.md`

**Updates**:
1. Add sections for Azure DevOps, GitLab, and Google Cloud configuration
2. Update supported services table
3. Add troubleshooting sections for new services
4. Update Keychain storage table
5. Add examples for each new service

---

## 4. Priority Order & Implementation Checklist

### Priority 1: Core Model & Service Extensions (1-2 hours)
- [ ] Add new `KnownSecret` enum cases to `Secret.swift`
- [ ] Implement `displayName`, `keychainService`, `keychainAccount` for new secrets
- [ ] Add `onePasswordReference` mappings (use available references)
- [ ] Add `environmentVariable` mappings
- [ ] Add `defaultValue` property for optional defaults
- [ ] Update `SecretsService.updateMCPConfigWithSecrets()` for Azure DevOps
- [ ] Update `SecretsService.updateMCPConfigWithSecrets()` for GitLab
- [ ] Update `SecretsService.updateMCPConfigWithSecrets()` for Google Cloud
- [ ] Add `hasGcloudCredentials()` helper method

### Priority 2: Command Extensions (2-3 hours)
- [ ] Update `checkStatus()` to check Azure DevOps MCP config
- [ ] Update `checkStatus()` to check GitLab MCP config
- [ ] Update `checkStatus()` to check Google Cloud MCP config
- [ ] Update `checkStatus()` to check gcloud authentication
- [ ] Add Azure DevOps prompts to `setupWithKeychain()`
- [ ] Add GitLab prompts to `setupWithKeychain()`
- [ ] Add Google Cloud prompts to `setupWithKeychain()`
- [ ] Add input validation for Azure DevOps URLs and tokens
- [ ] Add input validation for GitLab URLs and tokens
- [ ] Handle gcloud default credentials path detection

### Priority 3: Timeout Fix (1 hour)
- [ ] Fix confirmation prompt in `setupWith1Password()` (skip properly with `--force`)
- [ ] Add timeout wrapper to `fetchFromOnePassword()` method
- [ ] Add `SecretsError.operationTimeout` case to `Errors.swift`
- [ ] Add progress indicators during 1Password sync
- [ ] Test timeout behavior with slow/failing 1Password operations

### Priority 4: Testing (2-3 hours)
- [ ] Test Azure DevOps configuration with manual Keychain input
- [ ] Test Azure DevOps configuration with 1Password
- [ ] Test GitLab configuration with manual Keychain input
- [ ] Test GitLab configuration with 1Password
- [ ] Test Google Cloud configuration with gcloud default credentials
- [ ] Test Google Cloud configuration with custom service account JSON
- [ ] Test `--check` command with new services
- [ ] Test `--update-only` command with new secrets
- [ ] Test `--force` flag (verify no timeout)
- [ ] Test backward compatibility with existing Ghost/Firebase config
- [ ] Test error handling for missing 1Password references
- [ ] Test error handling for invalid credentials

### Priority 5: Documentation (1 hour)
- [ ] Update `docs/SECRETS_MANAGEMENT.md` with new services
- [ ] Add Azure DevOps setup instructions
- [ ] Add GitLab setup instructions
- [ ] Add Google Cloud setup instructions
- [ ] Update Keychain storage table
- [ ] Update MCP configuration examples
- [ ] Add troubleshooting sections for new services
- [ ] Update CHANGELOG.md with new features

### Priority 6: Polish & Release (1 hour)
- [ ] Run `swift format format -p -r -i Sources` for formatting
- [ ] Run `swift format lint -s -p -r Sources` to verify
- [ ] Test clean install on fresh system
- [ ] Update version in `Main.swift` CommandConfiguration
- [ ] Create git commit with detailed message
- [ ] Tag release version (e.g., v1.3.0)

**Estimated Total Time**: 8-11 hours

---

## 5. Code Snippets for Key Changes

### Secret.swift Extension

```swift
// Add after existing cases in KnownSecret enum
case azureDevOpsOrgUrl = "azure-devops-org-url"
case azureDevOpsPat = "azure-devops-pat"
case azureDevOpsDefaultProject = "azure-devops-default-project"
case gitlabPersonalAccessToken = "gitlab-personal-access-token"
case gitlabApiUrl = "gitlab-api-url"
case gcloudCredentialsPath = "gcloud-credentials-path"

// Add to displayName property
case .azureDevOpsOrgUrl: return "Azure DevOps Organization URL"
case .azureDevOpsPat: return "Azure DevOps Personal Access Token"
case .azureDevOpsDefaultProject: return "Azure DevOps Default Project"
case .gitlabPersonalAccessToken: return "GitLab Personal Access Token"
case .gitlabApiUrl: return "GitLab API URL"
case .gcloudCredentialsPath: return "Google Cloud Credentials Path"

// Add to keychainService property
case .azureDevOpsOrgUrl, .azureDevOpsPat, .azureDevOpsDefaultProject:
  return "swift-agents-plugin.azure-devops"
case .gitlabPersonalAccessToken, .gitlabApiUrl:
  return "swift-agents-plugin.gitlab"
case .gcloudCredentialsPath:
  return "swift-agents-plugin.gcloud"

// Add to keychainAccount property
case .azureDevOpsOrgUrl: return "org-url"
case .azureDevOpsPat: return "pat"
case .azureDevOpsDefaultProject: return "default-project"
case .gitlabPersonalAccessToken: return "personal-access-token"
case .gitlabApiUrl: return "api-url"
case .gcloudCredentialsPath: return "credentials-path"

// Add to onePasswordReference property
case .azureDevOpsOrgUrl:
  return nil  // Manual input
case .azureDevOpsPat:
  return "op://Employee/CompanyA Azure - Gitlab/gitlab private access token api"
case .azureDevOpsDefaultProject:
  return nil  // Manual input
case .gitlabPersonalAccessToken:
  return "op://Employee/CompanyA/gitlab mcp full access sauf ai and kubernetes"
case .gitlabApiUrl:
  return nil  // Default value
case .gcloudCredentialsPath:
  return nil  // Use gcloud default

// Add to environmentVariable property
case .azureDevOpsOrgUrl: return "AZURE_DEVOPS_ORG_URL"
case .azureDevOpsPat: return "AZURE_DEVOPS_PAT"
case .azureDevOpsDefaultProject: return "AZURE_DEVOPS_DEFAULT_PROJECT"
case .gitlabPersonalAccessToken: return "GITLAB_PERSONAL_ACCESS_TOKEN"
case .gitlabApiUrl: return "GITLAB_API_URL"
case .gcloudCredentialsPath: return "GOOGLE_APPLICATION_CREDENTIALS"

// Add new property for default values
public var defaultValue: String? {
  switch self {
  case .gitlabApiUrl:
    return "https://gitlab.com/api/v4"
  case .gcloudCredentialsPath:
    let defaultPath = FileManager.default.homeDirectoryForCurrentUser
      .appendingPathComponent(".config/gcloud/application_default_credentials.json")
    return FileManager.default.fileExists(atPath: defaultPath.path) ? defaultPath.path : nil
  default:
    return nil
  }
}
```

### SecretsService.swift - MCP Config Update

```swift
// Add to updateMCPConfigWithSecrets() method after Ghost config

// Update Azure DevOps configuration
if let orgUrl = secrets[.azureDevOpsOrgUrl],
   let pat = secrets[.azureDevOpsPat] {
  var azureConfig = config.mcpServers["azure-devops"]
    ?? MCPServerConfig(
      command: "npx",
      args: ["-y", "@azure-devops/mcp-server"],
      env: [:],
      description: "Azure DevOps MCP server for work items and repos"
    )
  azureConfig.env["AZURE_DEVOPS_ORG_URL"] = orgUrl
  azureConfig.env["AZURE_DEVOPS_PAT"] = pat
  if let project = secrets[.azureDevOpsDefaultProject] {
    azureConfig.env["AZURE_DEVOPS_DEFAULT_PROJECT"] = project
  }
  config.mcpServers["azure-devops"] = azureConfig
}

// Update GitLab configuration
if let token = secrets[.gitlabPersonalAccessToken] {
  var gitlabConfig = config.mcpServers["gitlab"]
    ?? MCPServerConfig(
      command: "npx",
      args: ["-y", "@modelcontextprotocol/server-gitlab"],
      env: [:],
      description: "GitLab MCP server for project management and CI/CD"
    )
  gitlabConfig.env["GITLAB_PERSONAL_ACCESS_TOKEN"] = token
  gitlabConfig.env["GITLAB_API_URL"] = secrets[.gitlabApiUrl] 
    ?? KnownSecret.gitlabApiUrl.defaultValue 
    ?? "https://gitlab.com/api/v4"
  config.mcpServers["gitlab"] = gitlabConfig
}

// Update Google Cloud configuration
if let credentialsPath = secrets[.gcloudCredentialsPath] {
  if fileManager.fileExists(atPath: credentialsPath) {
    var gcloudConfig = config.mcpServers["google-cloud"]
      ?? MCPServerConfig(
        command: "npx",
        args: ["-y", "@google-cloud/mcp-server"],
        env: [:],
        description: "Google Cloud MCP server for GCP resource management"
      )
    gcloudConfig.env["GOOGLE_APPLICATION_CREDENTIALS"] = credentialsPath
    config.mcpServers["google-cloud"] = gcloudConfig
  }
}
```

### Errors.swift - Add Timeout Error

```swift
// Add to SecretsError enum
case operationTimeout(String)

// Add to description property
case .operationTimeout(let operation):
  return "Operation timed out: \(operation)"
```

### SecretsService.swift - Timeout Wrapper

```swift
// Add after existing fetchFromOnePassword method
/// Fetch a secret from 1Password with timeout (30 seconds default)
public func fetchFromOnePasswordWithTimeout(
  reference: String,
  timeout: TimeInterval = 30
) async throws -> String {
  return try await withThrowingTaskGroup(of: String.self) { group in
    // Add fetch task
    group.addTask {
      return try await self.fetchFromOnePassword(reference: reference)
    }
    
    // Add timeout task
    group.addTask {
      try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
      throw SecretsError.operationTimeout(reference)
    }
    
    // Return first result
    guard let result = try await group.next() else {
      throw SecretsError.operationTimeout(reference)
    }
    
    group.cancelAll()
    return result
  }
}
```

---

## 6. Testing Strategy

### Unit Testing Approach

**Mock Services**:
- Create mock `SecretsService` for testing command logic
- Mock 1Password CLI responses
- Mock Keychain operations
- Mock file system for gcloud credentials

**Test Cases**:

1. **Model Tests**:
   - Verify all `KnownSecret` cases have required properties
   - Test `defaultValue` returns correct defaults
   - Verify 1Password references are valid format

2. **Service Tests**:
   - Test MCP config generation for each service
   - Test backward compatibility (existing config not corrupted)
   - Test partial configuration (only some services)
   - Test gcloud credentials path detection

3. **Command Tests**:
   - Test `--check` output for each service
   - Test interactive prompts (mock `readLine()`)
   - Test `--force` flag behavior
   - Test timeout handling

4. **Integration Tests**:
   - Test full workflow: 1Password -> Keychain -> MCP config
   - Test full workflow: Manual input -> Keychain -> MCP config
   - Test `--update-only` with pre-existing secrets
   - Test error recovery (partial failures)

### Manual Testing Checklist

- [ ] Install CLI with new code: `swift package experimental-install`
- [ ] Run `claude-agents setup secrets --check` (should show new services)
- [ ] Run `claude-agents setup secrets --keychain` (test interactive prompts)
- [ ] Verify MCP config has correct structure
- [ ] Verify secrets stored in Keychain
- [ ] Run `claude-agents setup secrets --one-password --force` (test timeout fix)
- [ ] Verify 1Password sync works without hanging
- [ ] Test with missing gcloud credentials
- [ ] Test with invalid Azure DevOps URL
- [ ] Test with invalid GitLab token
- [ ] Restart Claude Code and verify MCP servers load

---

## 7. Risk Assessment & Mitigations

### Risks

1. **Breaking Changes**:
   - Risk: New code breaks existing Ghost/Firebase configuration
   - Mitigation: Thorough testing of backward compatibility, backup config before modifications

2. **1Password References Invalid**:
   - Risk: Mapped 1Password references don't match actual vault structure
   - Mitigation: Allow manual override, graceful failure with clear error messages

3. **Timeout Issues Persist**:
   - Risk: Timeout fix doesn't resolve the issue
   - Mitigation: Add detailed logging, implement multiple timeout strategies

4. **MCP Server Package Names Wrong**:
   - Risk: `npx` package names for Azure DevOps/GitLab don't exist
   - Mitigation: Research actual package names, make command configurable

5. **Google Cloud Credentials Complex**:
   - Risk: Service account JSON handling more complex than anticipated
   - Mitigation: Start with gcloud default credentials only, add custom path later

### Mitigations Summary

- Maintain backward compatibility (test with existing config)
- Graceful degradation (missing 1Password references fallback to manual)
- Clear error messages with recovery instructions
- Comprehensive logging for debugging
- Incremental rollout (one service at a time)

---

## 8. Success Criteria

### Functional Requirements

- [ ] Azure DevOps secrets can be configured via 1Password
- [ ] Azure DevOps secrets can be configured via manual input
- [ ] GitLab secrets can be configured via 1Password
- [ ] GitLab secrets can be configured via manual input
- [ ] Google Cloud credentials detected automatically (gcloud default)
- [ ] Google Cloud credentials can use custom service account path
- [ ] All secrets stored in macOS Keychain
- [ ] MCP configuration updated correctly for all services
- [ ] `--check` command shows status of all services
- [ ] `--force` flag works without timeout
- [ ] Backward compatibility maintained for existing Ghost/Firebase

### Non-Functional Requirements

- [ ] No timeout issues with 1Password (< 2 minutes for all operations)
- [ ] Clear progress indicators during slow operations
- [ ] User-friendly error messages with recovery steps
- [ ] Documentation updated and accurate
- [ ] Code follows Swift 6.0 concurrency best practices
- [ ] Code formatted per project standards (`swift format`)

### User Experience

- [ ] Interactive prompts are clear and helpful
- [ ] Default values reduce manual input
- [ ] Validation catches common mistakes (invalid URLs, etc.)
- [ ] Status checks provide actionable information
- [ ] Setup completes in < 5 minutes for all services

---

## 9. Future Enhancements

**Out of scope for this implementation, but worth considering**:

1. **SSH Key Management**:
   - Store GitLab SSH keys in Keychain
   - Configure SSH agent for git operations
   - Reference: `op://Employee/CompanyA Azure - Gitlab/private key`

2. **Multiple Accounts**:
   - Support multiple Azure DevOps organizations
   - Support multiple GitLab instances
   - Support multiple Google Cloud projects

3. **Secret Rotation**:
   - Automated secret expiration checks
   - One-command secret rotation workflow
   - Integration with 1Password secret rotation

4. **Team Sharing**:
   - Shared secrets via 1Password team vaults
   - Per-project secret profiles
   - Export/import secret configurations

5. **Additional MCP Servers**:
   - GitHub (already have Azure DevOps, add GitHub)
   - Jira/Linear (project management)
   - Slack/Discord (notifications)
   - AWS (similar to GCP)

---

## 10. Implementation Timeline

**Day 1 (4-5 hours)**:
- Priority 1: Model & Service extensions
- Priority 3: Timeout fix
- Initial testing

**Day 2 (4-5 hours)**:
- Priority 2: Command extensions
- Priority 4: Comprehensive testing
- Bug fixes

**Day 3 (1-2 hours)**:
- Priority 5: Documentation
- Priority 6: Polish & release
- Final validation

**Total**: 3 days (~10-12 hours)

---

## Conclusion

This implementation plan provides a structured approach to extending the secrets management system with Azure DevOps, GitLab, and Google Cloud support. The architecture follows existing patterns, maintains backward compatibility, and addresses the timeout issue with 1Password.

Key benefits:
- Consistent architecture (Model-Service-Command)
- Actor-based concurrency for thread safety
- Graceful degradation (1Password optional)
- Comprehensive error handling
- Clear user experience

The phased approach allows for incremental implementation and testing, reducing risk and ensuring quality.
