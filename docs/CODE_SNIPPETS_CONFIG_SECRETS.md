# Code Snippets: Configuration-Based Secrets Management

This document provides Swift code snippets for implementing the configuration-based secrets management system.

## Models

### SecretsConfig.swift

Location: `Sources/claude-agents-cli/Models/SecretsConfig.swift`

```swift
import Foundation

/// Configuration file for secrets management
public struct SecretsConfig: Sendable, Codable {
  public let version: String
  public let onePasswordVault: String?
  public let services: [String: ServiceConfig]
  public let mcpServers: [String: MCPServerDefinition]?
  
  public init(
    version: String = "1.0",
    onePasswordVault: String? = nil,
    services: [String: ServiceConfig] = [:],
    mcpServers: [String: MCPServerDefinition]? = nil
  ) {
    self.version = version
    self.onePasswordVault = onePasswordVault
    self.services = services
    self.mcpServers = mcpServers
  }
}

/// Configuration for a service (e.g., "ghost", "firebase")
public struct ServiceConfig: Sendable, Codable {
  public let secrets: [String: SecretConfig]
  
  // Custom coding to flatten structure
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.secrets = try container.decode([String: SecretConfig].self)
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(secrets)
  }
  
  public init(secrets: [String: SecretConfig]) {
    self.secrets = secrets
  }
}

/// Configuration for a single secret
public struct SecretConfig: Sendable, Codable {
  public let onePasswordRef: String?
  public let keychainAccount: String
  public let keychainService: String
  public let envVar: String?
  public let prompt: String?
  public let validator: String?
  
  public init(
    onePasswordRef: String? = nil,
    keychainAccount: String,
    keychainService: String,
    envVar: String? = nil,
    prompt: String? = nil,
    validator: String? = nil
  ) {
    self.onePasswordRef = onePasswordRef
    self.keychainAccount = keychainAccount
    self.keychainService = keychainService
    self.envVar = envVar
    self.prompt = prompt
    self.validator = validator
  }
}

/// MCP Server definition in config
public struct MCPServerDefinition: Sendable, Codable {
  public let command: String
  public let args: [String]
  public let description: String?
  public let requiredSecrets: [String]
  
  public init(
    command: String,
    args: [String],
    description: String? = nil,
    requiredSecrets: [String]
  ) {
    self.command = command
    self.args = args
    self.description = description
    self.requiredSecrets = requiredSecrets
  }
}

/// Secret path reference (e.g., "ghost.url")
public struct SecretPath: Sendable, Hashable, CustomStringConvertible {
  public let service: String
  public let key: String
  
  public init(service: String, key: String) {
    self.service = service
    self.key = key
  }
  
  public init?(path: String) {
    let components = path.split(separator: ".")
    guard components.count == 2 else { return nil }
    self.service = String(components[0])
    self.key = String(components[1])
  }
  
  public var description: String {
    "\(service).\(key)"
  }
}
```

### Update Errors.swift

Add to existing `Sources/claude-agents-cli/Models/Errors.swift`:

```swift
// Add to existing SecretsError enum

case configNotFound(URL)
case invalidConfigFormat(String)
case invalidSecretPath(String)
case configValidationFailed(String)
case duplicateKeychainIdentifier(String)

// Add to description
case .configNotFound(let url):
  return """
    Configuration file not found: \(url.path)
    Run: claude-agents setup secrets --init
    """
case .invalidConfigFormat(let reason):
  return "Invalid configuration format: \(reason)"
case .invalidSecretPath(let path):
  return """
    Invalid secret path: \(path)
    Expected format: service.key (e.g., ghost.url)
    """
case .configValidationFailed(let reason):
  return "Configuration validation failed: \(reason)"
case .duplicateKeychainIdentifier(let identifier):
  return """
    Duplicate keychain identifier: \(identifier)
    Each secret must have a unique service:account combination
    """
```

## Services

### ConfigService.swift

Location: `Sources/claude-agents-cli/Services/ConfigService.swift`

```swift
import Foundation

/// Actor responsible for managing secrets configuration
public actor ConfigService {
  private let fileManager = FileManager.default
  
  public init() {}
  
  // MARK: - Config File Locations
  
  /// Get the user-specific config path
  public nonisolated func userConfigPath() -> URL {
    fileManager.homeDirectoryForCurrentUser
      .appendingPathComponent(".claude-agents/secrets-config.json")
  }
  
  /// Get the project-specific config path
  public nonisolated func projectConfigPath() -> URL {
    URL(fileURLWithPath: fileManager.currentDirectoryPath)
      .appendingPathComponent(".claude-agents-secrets.json")
  }
  
  /// Find the active config file (project overrides user)
  public func findConfigPath() async -> URL? {
    let projectPath = projectConfigPath()
    let userPath = userConfigPath()
    
    if fileManager.fileExists(atPath: projectPath.path) {
      return projectPath
    }
    
    if fileManager.fileExists(atPath: userPath.path) {
      return userPath
    }
    
    return nil
  }
  
  // MARK: - Config File Operations
  
  /// Load configuration from file
  public func loadConfig(from path: URL? = nil) async throws -> SecretsConfig {
    let configPath: URL
    if let path = path {
      configPath = path
    } else if let foundPath = await findConfigPath() {
      configPath = foundPath
    } else {
      throw SecretsError.configNotFound(userConfigPath())
    }
    
    do {
      let data = try Data(contentsOf: configPath)
      let decoder = JSONDecoder()
      return try decoder.decode(SecretsConfig.self, from: data)
    } catch let error as DecodingError {
      throw SecretsError.invalidConfigFormat(error.localizedDescription)
    } catch {
      throw SecretsError.invalidConfigFormat(error.localizedDescription)
    }
  }
  
  /// Save configuration to file
  public func saveConfig(
    _ config: SecretsConfig,
    to path: URL? = nil
  ) async throws {
    let configPath = path ?? userConfigPath()
    
    // Create directory if needed
    let configDir = configPath.deletingLastPathComponent()
    if !fileManager.fileExists(atPath: configDir.path) {
      try fileManager.createDirectory(
        at: configDir,
        withIntermediateDirectories: true,
        attributes: nil
      )
    }
    
    // Encode and write
    do {
      let encoder = JSONEncoder()
      encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
      let data = try encoder.encode(config)
      try data.write(to: configPath, options: .atomic)
      
      // Set file permissions (readable by owner and group)
      try fileManager.setAttributes(
        [.posixPermissions: 0o644],
        ofItemAtPath: configPath.path
      )
    } catch {
      throw SecretsError.invalidConfigFormat(
        "Failed to write config: \(error.localizedDescription)"
      )
    }
  }
  
  /// Validate configuration
  public func validateConfig(_ config: SecretsConfig) async throws {
    // Check version
    guard config.version == "1.0" else {
      throw SecretsError.configValidationFailed(
        "Unsupported version: \(config.version)"
      )
    }
    
    // Check for duplicate keychain identifiers
    var keychainIds = Set<String>()
    for (serviceName, serviceConfig) in config.services {
      for (key, secretConfig) in serviceConfig.secrets {
        let id = "\(secretConfig.keychainService):\(secretConfig.keychainAccount)"
        
        if keychainIds.contains(id) {
          throw SecretsError.duplicateKeychainIdentifier(id)
        }
        keychainIds.insert(id)
      }
    }
    
    // Validate secret paths in MCP servers
    if let mcpServers = config.mcpServers {
      for (serverName, serverDef) in mcpServers {
        for secretPath in serverDef.requiredSecrets {
          guard let path = SecretPath(path: secretPath) else {
            throw SecretsError.invalidSecretPath(secretPath)
          }
          
          // Check if secret exists in config
          guard let serviceConfig = config.services[path.service],
                serviceConfig.secrets[path.key] != nil else {
            throw SecretsError.configValidationFailed(
              "MCP server '\(serverName)' requires undefined secret: \(secretPath)"
            )
          }
        }
      }
    }
  }
  
  /// Export config template (removes sensitive values)
  public func exportTemplate(_ config: SecretsConfig) async throws -> SecretsConfig {
    var template = config
    
    // Replace 1Password refs with placeholders
    var newServices: [String: ServiceConfig] = [:]
    for (serviceName, serviceConfig) in config.services {
      var newSecrets: [String: SecretConfig] = [:]
      
      for (key, secretConfig) in serviceConfig.secrets {
        let placeholder = secretConfig.onePasswordRef != nil
          ? "op://YOUR_VAULT/YOUR_ITEM/\(key)"
          : nil
        
        newSecrets[key] = SecretConfig(
          onePasswordRef: placeholder,
          keychainAccount: secretConfig.keychainAccount,
          keychainService: secretConfig.keychainService,
          envVar: secretConfig.envVar,
          prompt: secretConfig.prompt,
          validator: secretConfig.validator
        )
      }
      
      newServices[serviceName] = ServiceConfig(secrets: newSecrets)
    }
    
    return SecretsConfig(
      version: template.version,
      onePasswordVault: "YOUR_VAULT",
      services: newServices,
      mcpServers: template.mcpServers
    )
  }
  
  /// Create default config interactively
  public func createDefaultConfig() async -> SecretsConfig {
    // This would be implemented with interactive prompts
    // For now, return a basic template
    return SecretsConfig(
      version: "1.0",
      onePasswordVault: nil,
      services: [:],
      mcpServers: nil
    )
  }
}
```

### Updated SecretsService.swift

Add to existing `Sources/claude-agents-cli/Services/SecretsService.swift`:

```swift
// Add to existing SecretsService

/// Fetch secrets using configuration
public func fetchSecretsWithConfig(
  _ config: SecretsConfig,
  use1Password: Bool
) async throws -> [String: [String: String]] {
  var allSecrets: [String: [String: String]] = [:]
  
  for (serviceName, serviceConfig) in config.services {
    var serviceSecrets: [String: String] = [:]
    
    for (key, secretConfig) in serviceConfig.secrets {
      let value: String
      
      if use1Password, let opRef = secretConfig.onePasswordRef {
        // Fetch from 1Password
        do {
          value = try await fetchFromOnePassword(reference: opRef)
          
          // Store in Keychain
          try await storeInKeychain(
            service: secretConfig.keychainService,
            account: secretConfig.keychainAccount,
            secret: value
          )
        } catch {
          print("Warning: Failed to fetch \(serviceName).\(key): \(error)")
          continue
        }
      } else {
        // Try loading from Keychain
        do {
          value = try await fetchFromKeychain(
            service: secretConfig.keychainService,
            account: secretConfig.keychainAccount
          )
        } catch {
          print("Warning: Secret not found in Keychain: \(serviceName).\(key)")
          continue
        }
      }
      
      serviceSecrets[key] = value
    }
    
    if !serviceSecrets.isEmpty {
      allSecrets[serviceName] = serviceSecrets
    }
  }
  
  return allSecrets
}

/// Update MCP config using SecretsConfig
public func updateMCPConfigWithConfig(
  _ config: SecretsConfig,
  secrets: [String: [String: String]]
) async throws {
  var mcpConfig = try await readMCPConfig()
  
  // Update each MCP server defined in config
  if let mcpServers = config.mcpServers {
    for (serverName, serverDef) in mcpServers {
      var env: [String: String] = [:]
      
      // Collect required secrets
      for secretPathStr in serverDef.requiredSecrets {
        guard let secretPath = SecretPath(path: secretPathStr) else {
          print("Warning: Invalid secret path: \(secretPathStr)")
          continue
        }
        
        guard let serviceSecrets = secrets[secretPath.service],
              let secretValue = serviceSecrets[secretPath.key],
              let secretConfig = config.services[secretPath.service]?.secrets[secretPath.key],
              let envVar = secretConfig.envVar else {
          print("Warning: Secret not available: \(secretPathStr)")
          continue
        }
        
        env[envVar] = secretValue
      }
      
      // Skip if no secrets were found
      guard !env.isEmpty else {
        print("Warning: No secrets found for MCP server: \(serverName)")
        continue
      }
      
      // Create or update MCP server config
      var serverConfig = mcpConfig.mcpServers[serverName] ?? MCPServerConfig(
        command: serverDef.command,
        args: serverDef.args,
        env: [:],
        description: serverDef.description
      )
      
      // Merge environment variables
      for (key, value) in env {
        serverConfig.env[key] = value
      }
      
      mcpConfig.mcpServers[serverName] = serverConfig
    }
  }
  
  try await writeMCPConfig(mcpConfig)
}
```

## Commands

### Updated SetupSecretsCommand.swift

Add new flags and methods to existing command:

```swift
// Add new flags

@Flag(name: .long, help: "Initialize configuration file")
var initConfig = false

@Flag(name: .long, help: "Configure 1Password references")
var configure = false

@Flag(name: .long, help: "Use configuration file")
var useConfig = false

@Flag(name: .long, help: "Show current configuration")
var showConfig = false

@Option(name: .long, help: "Path to configuration file")
var configPath: String?

// Add to run() method

public func run() async throws {
  let service = SecretsService()
  let configService = ConfigService()
  
  // Handle config-specific commands
  if initConfig {
    try await initializeConfig(configService: configService)
    return
  }
  
  if configure {
    try await configureReferences(configService: configService)
    return
  }
  
  if showConfig {
    try await displayConfig(configService: configService)
    return
  }
  
  if useConfig {
    try await setupWithConfig(
      service: service,
      configService: configService
    )
    return
  }
  
  // ... existing check, updateOnly, etc.
}

// New methods

private func initializeConfig(
  configService: ConfigService
) async throws {
  print("")
  print("================================================================")
  print("  Initialize Secrets Configuration")
  print("================================================================")
  print("")
  
  // TODO: Implement interactive config creation
  // - Prompt for 1Password vault
  // - Select services to configure
  // - For each service, prompt for 1Password references
  // - Configure MCP servers
  // - Save to file
  
  print("Configuration initialization not yet implemented")
}

private func configureReferences(
  configService: ConfigService
) async throws {
  print("")
  print("================================================================")
  print("  Configure 1Password References")
  print("================================================================")
  print("")
  
  // Load existing config
  let config = try await configService.loadConfig()
  
  // TODO: Implement interactive editing
  // - Display current config
  // - Allow editing 1Password references
  // - Validate and save
  
  print("Configuration editing not yet implemented")
}

private func displayConfig(
  configService: ConfigService
) async throws {
  guard let configPath = await configService.findConfigPath() else {
    print("No configuration file found")
    print("")
    print("Run: claude-agents setup secrets --init")
    return
  }
  
  let config = try await configService.loadConfig()
  
  print("")
  print("================================================================")
  print("  Secrets Configuration")
  print("================================================================")
  print("")
  print("Config file: \(configPath.path)")
  print("Version: \(config.version)")
  if let vault = config.onePasswordVault {
    print("1Password Vault: \(vault)")
  }
  print("")
  
  print("Services:")
  for (serviceName, serviceConfig) in config.services.sorted(by: { $0.key < $1.key }) {
    print("  \(serviceName):")
    for (key, secretConfig) in serviceConfig.secrets.sorted(by: { $0.key < $1.key }) {
      print("    - \(key)")
      if let opRef = secretConfig.onePasswordRef {
        print("      1Password: \(opRef)")
      } else {
        print("      1Password: (manual input)")
      }
      print("      Keychain: \(secretConfig.keychainService):\(secretConfig.keychainAccount)")
      if let envVar = secretConfig.envVar {
        print("      Environment: \(envVar)")
      }
    }
  }
  
  if let mcpServers = config.mcpServers {
    print("")
    print("MCP Servers:")
    for (serverName, serverDef) in mcpServers.sorted(by: { $0.key < $1.key }) {
      print("  \(serverName):")
      print("    Command: \(serverDef.command) \(serverDef.args.joined(separator: " "))")
      print("    Required secrets: \(serverDef.requiredSecrets.joined(separator: ", "))")
    }
  }
  
  print("")
}

private func setupWithConfig(
  service: SecretsService,
  configService: ConfigService
) async throws {
  print("")
  print("================================================================")
  print("  Setup Secrets with Configuration")
  print("================================================================")
  print("")
  
  // Load config
  let configPath: URL?
  if let path = self.configPath {
    configPath = URL(fileURLWithPath: path)
  } else {
    configPath = await configService.findConfigPath()
  }
  
  guard let configPath = configPath else {
    print("No configuration file found")
    print("")
    print("Run: claude-agents setup secrets --init")
    throw ExitCode.failure
  }
  
  print("Using config: \(configPath.path)")
  let config = try await configService.loadConfig(from: configPath)
  
  // Validate config
  try await configService.validateConfig(config)
  print("Configuration validated successfully")
  print("")
  
  // Determine if using 1Password
  let use1Password = await service.isOnePasswordInstalled()
    && await service.isOnePasswordAuthenticated()
  
  if use1Password {
    print("Using 1Password for secrets")
  } else {
    print("Using Keychain for secrets (1Password not available)")
  }
  print("")
  
  // Fetch secrets
  let secrets = try await service.fetchSecretsWithConfig(
    config,
    use1Password: use1Password
  )
  
  print("Fetched \(secrets.values.map { $0.count }.reduce(0, +)) secret(s)")
  print("")
  
  // Update MCP config
  print("Updating MCP configuration...")
  try await service.updateMCPConfigWithConfig(
    config,
    secrets: secrets
  )
  
  print("Successfully updated MCP configuration")
  print("")
  print("================================================================")
  print("  Setup Complete")
  print("================================================================")
  print("")
  print("Next steps:")
  print("  1. Restart Claude Code")
  print("  2. Verify: claude-agents setup secrets --check")
  print("")
}
```

## Example Config Files

### config-template.json

```json
{
  "version": "1.0",
  "onePasswordVault": "YOUR_VAULT_NAME",
  "services": {
    "ghost": {
      "url": {
        "onePasswordRef": "op://YOUR_VAULT/Ghost/url",
        "keychainAccount": "ghost-url",
        "keychainService": "swift-agents-plugin.ghost",
        "envVar": "GHOST_URL",
        "prompt": "Ghost site URL (e.g., https://yoursite.ghost.io)",
        "validator": "url"
      },
      "adminApiKey": {
        "onePasswordRef": "op://YOUR_VAULT/Ghost/admin api key",
        "keychainAccount": "ghost-admin-api-key",
        "keychainService": "swift-agents-plugin.ghost",
        "envVar": "GHOST_ADMIN_API_KEY",
        "prompt": "Ghost Admin API Key (format: id:secret)"
      }
    },
    "firebase": {
      "token": {
        "onePasswordRef": null,
        "keychainAccount": "firebase-token",
        "keychainService": "swift-agents-plugin.firebase",
        "envVar": "FIREBASE_TOKEN",
        "prompt": "Firebase CI token (run: firebase login:ci)"
      }
    }
  },
  "mcpServers": {
    "ghost": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-ghost"],
      "description": "Ghost CMS MCP server",
      "requiredSecrets": ["ghost.url", "ghost.adminApiKey"]
    },
    "firebase": {
      "command": "firebase",
      "args": ["experimental:mcp"],
      "description": "Firebase MCP server",
      "requiredSecrets": ["firebase.token"]
    }
  }
}
```

---

**Implementation Guide**: Use these snippets as a starting point. Adapt to your specific needs and integrate with existing codebase patterns.
