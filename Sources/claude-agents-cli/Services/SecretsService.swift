import Foundation
import ClaudeAgents

/// Azure CLI authentication information
public struct AzureAuthInfo: Sendable {
  public let isAuthenticated: Bool
  public let userEmail: String?
  public let subscriptionName: String?
  public let version: String?

  public init(
    isAuthenticated: Bool, userEmail: String? = nil, subscriptionName: String? = nil,
    version: String? = nil
  ) {
    self.isAuthenticated = isAuthenticated
    self.userEmail = userEmail
    self.subscriptionName = subscriptionName
    self.version = version
  }
}

/// Actor responsible for managing secrets from 1Password and macOS Keychain
public actor SecretsService {
  private let fileManager = FileManager.default

  public init() {}

  // MARK: - Azure CLI Operations

  /// Check if Azure CLI is installed
  public func isAzureCLIInstalled() async -> Bool {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
    process.arguments = ["az"]

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe

    do {
      try process.run()
      process.waitUntilExit()
      return process.terminationStatus == 0
    } catch {
      return false
    }
  }

  /// Verify Azure DevOps authentication with PAT
  public func verifyAzureDevOpsAuth(pat: String) async -> Bool {
    // Check if Azure CLI is installed
    guard await isAzureCLIInstalled() else {
      return false
    }

    // Test PAT by listing projects
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["az", "devops", "project", "list", "--output", "json"]

    // Set AZURE_DEVOPS_EXT_PAT environment variable
    var env = ProcessInfo.processInfo.environment
    env["AZURE_DEVOPS_EXT_PAT"] = pat
    process.environment = env

    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = errorPipe

    do {
      try process.run()
      process.waitUntilExit()

      return process.terminationStatus == 0
    } catch {
      return false
    }
  }

  /// Get Azure DevOps authentication status
  public func getAzureDevOpsAuthStatus() async -> (isAuthenticated: Bool, projectCount: Int?) {
    // Try to load PAT from Keychain
    guard
      let pat = try? await fetchFromKeychain(
        service: KnownSecret.azureDevopsPat.keychainService,
        account: KnownSecret.azureDevopsPat.keychainAccount
      )
    else {
      return (false, nil)
    }

    // Verify authentication by listing projects
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["az", "devops", "project", "list", "--output", "json"]

    // Set AZURE_DEVOPS_EXT_PAT environment variable
    var env = ProcessInfo.processInfo.environment
    env["AZURE_DEVOPS_EXT_PAT"] = pat
    process.environment = env

    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = errorPipe

    do {
      try process.run()
      process.waitUntilExit()

      guard process.terminationStatus == 0 else {
        return (false, nil)
      }

      // Try to count projects
      let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
      if let json = try? JSONSerialization.jsonObject(with: outputData) as? [String: Any],
        let value = json["value"] as? [[String: Any]]
      {
        return (true, value.count)
      }

      return (true, nil)
    } catch {
      return (false, nil)
    }
  }

  /// Get Azure CLI version
  public func getAzureCLIVersion() async -> String? {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["az", "version", "--output", "json"]

    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = errorPipe

    do {
      try process.run()
      process.waitUntilExit()

      guard process.terminationStatus == 0 else {
        return nil
      }

      let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
      guard let json = try? JSONSerialization.jsonObject(with: outputData) as? [String: Any],
        let azureCli = json["azure-cli"] as? String
      else {
        return nil
      }

      return azureCli
    } catch {
      return nil
    }
  }

  /// Get Azure CLI authentication information
  public func getAzureAuthInfo() async -> AzureAuthInfo {
    // Check if installed first
    guard await isAzureCLIInstalled() else {
      return AzureAuthInfo(isAuthenticated: false)
    }

    // Get version
    let version = await getAzureCLIVersion()

    // Check authentication with `az account show`
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["az", "account", "show", "--output", "json"]

    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = errorPipe

    do {
      try process.run()
      process.waitUntilExit()

      guard process.terminationStatus == 0 else {
        return AzureAuthInfo(isAuthenticated: false, version: version)
      }

      let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
      guard let json = try? JSONSerialization.jsonObject(with: outputData) as? [String: Any] else {
        return AzureAuthInfo(isAuthenticated: false, version: version)
      }

      let userEmail = (json["user"] as? [String: Any])?["name"] as? String
      let subscriptionName = json["name"] as? String

      return AzureAuthInfo(
        isAuthenticated: true,
        userEmail: userEmail,
        subscriptionName: subscriptionName,
        version: version
      )
    } catch {
      return AzureAuthInfo(isAuthenticated: false, version: version)
    }
  }

  // MARK: - 1Password Operations

  /// Check if 1Password CLI is installed
  public func isOnePasswordInstalled() async -> Bool {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
    process.arguments = ["op"]

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe

    do {
      try process.run()
      process.waitUntilExit()
      return process.terminationStatus == 0
    } catch {
      return false
    }
  }

  /// Check if authenticated with 1Password
  public func isOnePasswordAuthenticated() async -> Bool {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["op", "account", "list"]

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe

    do {
      try process.run()
      process.waitUntilExit()
      return process.terminationStatus == 0
    } catch {
      return false
    }
  }

  /// Fetch a secret from 1Password using a reference
  public func fetchFromOnePassword(reference: String) async throws -> String {
    // Verify 1Password is installed
    guard await isOnePasswordInstalled() else {
      throw SecretsError.onePasswordNotInstalled
    }

    // Verify authenticated
    guard await isOnePasswordAuthenticated() else {
      throw SecretsError.onePasswordNotAuthenticated
    }

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["op", "read", reference]

    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = errorPipe

    do {
      try process.run()
      process.waitUntilExit()

      guard process.terminationStatus == 0 else {
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
        throw SecretsError.secretNotFound("\(reference) - \(errorMessage)")
      }

      let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
      guard
        let secret = String(data: outputData, encoding: .utf8)?
          .trimmingCharacters(in: .whitespacesAndNewlines),
        !secret.isEmpty
      else {
        throw SecretsError.secretNotFound(reference)
      }

      return secret
    } catch let error as SecretsError {
      throw error
    } catch {
      throw SecretsError.secretNotFound("\(reference): \(error.localizedDescription)")
    }
  }

  // MARK: - macOS Keychain Operations

  /// Store a secret in macOS Keychain
  public func storeInKeychain(
    service: String, account: String, secret: String
  ) async throws {
    // Check if secret already exists
    if (try? await fetchFromKeychain(service: service, account: account)) != nil {
      // Delete existing secret
      try await deleteFromKeychain(service: service, account: account)
    }

    // Add new secret
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/security")
    process.arguments = [
      "add-generic-password",
      "-a", account,
      "-s", service,
      "-w", secret,
      "-U",  // Update if exists
    ]

    let errorPipe = Pipe()
    process.standardError = errorPipe

    do {
      try process.run()
      process.waitUntilExit()

      guard process.terminationStatus == 0 else {
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
        throw SecretsError.keychainAccessFailed(
          "\(service):\(account)",
          NSError(
            domain: "SecretsService", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        )
      }
    } catch let error as SecretsError {
      throw error
    } catch {
      throw SecretsError.keychainAccessFailed("\(service):\(account)", error)
    }
  }

  /// Fetch a secret from macOS Keychain
  public func fetchFromKeychain(service: String, account: String) async throws -> String {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/security")
    process.arguments = [
      "find-generic-password",
      "-a", account,
      "-s", service,
      "-w",
    ]

    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = errorPipe

    do {
      try process.run()
      process.waitUntilExit()

      guard process.terminationStatus == 0 else {
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let errorMessage = String(data: errorData, encoding: .utf8) ?? "Not found"
        throw SecretsError.keychainAccessFailed(
          "\(service):\(account)",
          NSError(
            domain: "SecretsService", code: 2, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        )
      }

      let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
      guard
        let secret = String(data: outputData, encoding: .utf8)?
          .trimmingCharacters(in: .whitespacesAndNewlines),
        !secret.isEmpty
      else {
        throw SecretsError.keychainAccessFailed(
          "\(service):\(account)",
          NSError(
            domain: "SecretsService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Empty secret"]
          )
        )
      }

      return secret
    } catch let error as SecretsError {
      throw error
    } catch {
      throw SecretsError.keychainAccessFailed("\(service):\(account)", error)
    }
  }

  /// Delete a secret from macOS Keychain
  public func deleteFromKeychain(service: String, account: String) async throws {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/security")
    process.arguments = [
      "delete-generic-password",
      "-a", account,
      "-s", service,
    ]

    let errorPipe = Pipe()
    process.standardError = errorPipe

    do {
      try process.run()
      process.waitUntilExit()

      // Exit code 44 means "not found", which is OK for deletion
      if process.terminationStatus != 0 && process.terminationStatus != 44 {
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
        throw SecretsError.keychainAccessFailed(
          "\(service):\(account)",
          NSError(
            domain: "SecretsService", code: 4, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        )
      }
    } catch let error as SecretsError {
      throw error
    } catch {
      throw SecretsError.keychainAccessFailed("\(service):\(account)", error)
    }
  }

  // MARK: - MCP Configuration Operations

  /// Get the path to the MCP configuration file
  public nonisolated func mcpConfigPath() -> URL {
    FileManager.default.homeDirectoryForCurrentUser
      .appendingPathComponent(".config/claude/mcp.json")
  }

  /// Read MCP configuration from disk
  public func readMCPConfig() async throws -> MCPConfiguration {
    let configPath = mcpConfigPath()

    guard fileManager.fileExists(atPath: configPath.path) else {
      // Return empty config if file doesn't exist
      return MCPConfiguration()
    }

    do {
      let data = try Data(contentsOf: configPath)
      let decoder = JSONDecoder()
      return try decoder.decode(MCPConfiguration.self, from: data)
    } catch {
      throw SecretsError.invalidMCPConfig(error.localizedDescription)
    }
  }

  /// Write MCP configuration to disk
  public func writeMCPConfig(_ config: MCPConfiguration) async throws {
    let configPath = mcpConfigPath()

    // Create directory if needed
    let configDir = configPath.deletingLastPathComponent()
    if !fileManager.fileExists(atPath: configDir.path) {
      try fileManager.createDirectory(
        at: configDir, withIntermediateDirectories: true, attributes: nil)
    }

    // Backup existing config
    if fileManager.fileExists(atPath: configPath.path) {
      let backupPath = URL(
        fileURLWithPath: configPath.path + ".backup")
      do {
        if fileManager.fileExists(atPath: backupPath.path) {
          try fileManager.removeItem(at: backupPath)
        }
        try fileManager.copyItem(at: configPath, to: backupPath)
      } catch {
        throw SecretsError.configBackupFailed(backupPath, error)
      }
    }

    // Write new config
    do {
      let encoder = JSONEncoder()
      encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
      let data = try encoder.encode(config)
      try data.write(to: configPath, options: .atomic)
    } catch {
      throw SecretsError.invalidMCPConfig("Failed to write config: \(error.localizedDescription)")
    }
  }

  /// Update MCP configuration with secrets
  public func updateMCPConfigWithSecrets(
    _ secrets: [KnownSecret: String]
  ) async throws {
    var config = try await readMCPConfig()

    // Update Firebase configuration
    if let firebaseToken = secrets[.firebaseToken] {
      var firebaseConfig =
        config.mcpServers["firebase"]
        ?? MCPServerConfig(
          command: "firebase",
          args: ["experimental:mcp"],
          env: [:],
          description: "Firebase MCP server for Crashlytics analysis"
        )
      firebaseConfig.env["FIREBASE_TOKEN"] = firebaseToken
      config.mcpServers["firebase"] = firebaseConfig
    }

    // Update Ghost configuration
    if let ghostUrl = secrets[.ghostUrl],
      let ghostAdminKey = secrets[.ghostAdminApiKey]
    {
      var ghostConfig =
        config.mcpServers["ghost"]
        ?? MCPServerConfig(
          command: "npx",
          args: ["-y", "@modelcontextprotocol/server-ghost"],
          env: [:],
          description: "Ghost CMS MCP server for blog publishing"
        )
      ghostConfig.env["GHOST_URL"] = ghostUrl
      ghostConfig.env["GHOST_ADMIN_API_KEY"] = ghostAdminKey
      config.mcpServers["ghost"] = ghostConfig
    }

    // Update Azure DevOps configuration
    if let azureDevopsPat = secrets[.azureDevopsPat] {
      var azureDevopsConfig =
        config.mcpServers["azure-devops"]
        ?? MCPServerConfig(
          command: "azure-devops-mcp",
          args: [],
          env: [:],
          description: "Azure DevOps MCP server for work item and PR management"
        )
      azureDevopsConfig.env["AZURE_DEVOPS_EXT_PAT"] = azureDevopsPat

      // Ensure PATH is set for azure-devops-mcp
      if azureDevopsConfig.env["PATH"] == nil {
        azureDevopsConfig.env["PATH"] =
          "\(fileManager.homeDirectoryForCurrentUser.path)/.swiftpm/bin:/usr/local/bin:/usr/bin:/bin"
      }

      config.mcpServers["azure-devops"] = azureDevopsConfig
    }

    // Ensure tech-conf has proper PATH
    if var techConfConfig = config.mcpServers["tech-conf"] {
      if techConfConfig.env["PATH"] == nil {
        techConfConfig.env["PATH"] =
          "\(fileManager.homeDirectoryForCurrentUser.path)/.swiftpm/bin:/usr/local/bin:/usr/bin:/bin"
        config.mcpServers["tech-conf"] = techConfConfig
      }
    }

    try await writeMCPConfig(config)
  }

  // MARK: - High-Level Operations

  /// Fetch all known secrets from 1Password and store in Keychain
  public func syncFromOnePassword() async throws -> [KnownSecret: String] {
    var secrets: [KnownSecret: String] = [:]

    for knownSecret in KnownSecret.allCases {
      guard let opReference = knownSecret.onePasswordReference else {
        continue
      }

      do {
        let value = try await fetchFromOnePassword(reference: opReference)
        secrets[knownSecret] = value

        // Store in Keychain
        try await storeInKeychain(
          service: knownSecret.keychainService,
          account: knownSecret.keychainAccount,
          secret: value
        )
      } catch {
        print(
          "Warning: Failed to fetch \(knownSecret.displayName) from 1Password: \(error)")
      }
    }

    return secrets
  }

  /// Load secrets from Keychain
  public func loadFromKeychain() async throws -> [KnownSecret: String] {
    var secrets: [KnownSecret: String] = [:]

    for knownSecret in KnownSecret.allCases {
      do {
        let value = try await fetchFromKeychain(
          service: knownSecret.keychainService,
          account: knownSecret.keychainAccount
        )
        secrets[knownSecret] = value
      } catch {
        // Silently skip missing secrets
        continue
      }
    }

    return secrets
  }
}
