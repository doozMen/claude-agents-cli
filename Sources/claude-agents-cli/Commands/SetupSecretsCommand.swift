import ArgumentParser
import Foundation

public struct SetupSecretsCommand: AsyncParsableCommand {
  public static let configuration = CommandConfiguration(
    commandName: "secrets",
    abstract: "Configure secrets for MCP servers using 1Password or manual input"
  )

  @Flag(name: .long, help: "Use 1Password for all secrets (requires 1Password CLI)")
  var onePassword = false

  @Flag(name: .long, help: "Use macOS Keychain with manual input")
  var keychain = false

  @Flag(name: .long, help: "Only update MCP config from existing Keychain secrets")
  var updateOnly = false

  @Flag(name: .long, help: "Check current secrets status")
  var check = false

  @Flag(name: .long, help: "Skip confirmation prompts")
  var force = false

  public init() {}

  public func run() async throws {
    let service = SecretsService()

    // Check mode - just report status
    if check {
      try await checkStatus(service: service)
      return
    }

    // Update only mode - load from Keychain and update MCP config
    if updateOnly {
      try await updateMCPConfig(service: service)
      return
    }

    // Determine which mode to use
    let use1Password: Bool
    if onePassword {
      use1Password = true
    } else if keychain {
      use1Password = false
    } else {
      // Interactive mode - ask user
      use1Password = await promptForMode(service: service)
    }

    if use1Password {
      try await setupWith1Password(service: service)
    } else {
      try await setupWithKeychain(service: service)
    }
  }

  // MARK: - Check Status

  private func checkStatus(service: SecretsService) async throws {
    print("")
    print("================================================================")
    print("  Secrets Status")
    print("================================================================")
    print("")

    // Check 1Password
    let opInstalled = await service.isOnePasswordInstalled()
    let opAuthenticated: Bool
    if opInstalled {
      opAuthenticated = await service.isOnePasswordAuthenticated()
    } else {
      opAuthenticated = false
    }

    print("1Password CLI:")
    if opInstalled {
      print("  ✅ Installed")
      if opAuthenticated {
        print("  ✅ Authenticated")
      } else {
        print("  ❌ Not authenticated")
        print("     Run: eval $(op signin)")
      }
    } else {
      print("  ❌ Not installed")
      print("     Install: brew install --cask 1password-cli")
    }
    print("")

    // Check Azure CLI
    let azureInfo = await service.getAzureAuthInfo()
    print("Azure CLI:")
    if azureInfo.version != nil {
      if let version = azureInfo.version {
        print("  ✅ Installed (version \(version))")
      } else {
        print("  ✅ Installed")
      }

      if azureInfo.isAuthenticated {
        print("  ✅ Authenticated")
        if let email = azureInfo.userEmail {
          print("     User: \(email)")
        }
        if let subscription = azureInfo.subscriptionName {
          print("     Subscription: \(subscription)")
        }
      } else {
        print("  ❌ Not authenticated")
        print("     Run: az login")
      }
    } else {
      print("  ❌ Not installed")
      print("     Install: brew install azure-cli")
    }
    print("")

    // Check Azure DevOps authentication
    let azureDevopsStatus = await service.getAzureDevOpsAuthStatus()
    print("Azure DevOps:")
    if azureDevopsStatus.isAuthenticated {
      print("  ✅ Authenticated with PAT")
      if let projectCount = azureDevopsStatus.projectCount {
        print("     Projects accessible: \(projectCount)")
      }
    } else {
      print("  ❌ Not authenticated")
      print("     Configure PAT: claude-agents setup secrets")
    }
    print("")

    // Check Keychain secrets
    print("Keychain Secrets:")
    let keychainSecrets = try await service.loadFromKeychain()

    if keychainSecrets.isEmpty {
      print("  No secrets found in Keychain")
    } else {
      for knownSecret in KnownSecret.allCases {
        if keychainSecrets[knownSecret] != nil {
          print("  ✅ \(knownSecret.displayName)")
        }
      }
    }
    print("")

    // Check MCP config
    print("MCP Configuration:")
    let configPath = service.mcpConfigPath()
    let fileManager = FileManager.default

    if fileManager.fileExists(atPath: configPath.path) {
      print("  ✅ Config file exists: \(configPath.path)")

      do {
        let config = try await service.readMCPConfig()

        // Check Firebase
        if let firebaseConfig = config.mcpServers["firebase"] {
          let hasToken = !(firebaseConfig.env["FIREBASE_TOKEN"]?.isEmpty ?? true)
          print("  \(hasToken ? "✅" : "❌") Firebase server configured")
        } else {
          print("  ❌ Firebase server not configured")
        }

        // Check Ghost
        if let ghostConfig = config.mcpServers["ghost"] {
          let hasUrl = !(ghostConfig.env["GHOST_URL"]?.isEmpty ?? true)
          let hasKey = !(ghostConfig.env["GHOST_ADMIN_API_KEY"]?.isEmpty ?? true)
          print("  \(hasUrl && hasKey ? "✅" : "❌") Ghost server configured")
        } else {
          print("  ❌ Ghost server not configured")
        }

        // Check Azure DevOps
        if let azureDevopsConfig = config.mcpServers["azure-devops"] {
          let hasPat = !(azureDevopsConfig.env["AZURE_DEVOPS_EXT_PAT"]?.isEmpty ?? true)
          print("  \(hasPat ? "✅" : "❌") Azure DevOps server configured")
        } else {
          print("  ❌ Azure DevOps server not configured")
        }
      } catch {
        print("  ⚠️  Failed to read config: \(error)")
      }
    } else {
      print("  ❌ Config file not found: \(configPath.path)")
    }

    print("")
  }

  // MARK: - Update MCP Config

  private func updateMCPConfig(service: SecretsService) async throws {
    print("")
    print("================================================================")
    print("  Update MCP Configuration")
    print("================================================================")
    print("")

    print("Loading secrets from Keychain...")
    let secrets = try await service.loadFromKeychain()

    guard !secrets.isEmpty else {
      print("❌ No secrets found in Keychain")
      print("")
      print("Run 'claude-agents setup secrets' to configure secrets first")
      return
    }

    print("Found \(secrets.count) secret(s)")
    for (knownSecret, _) in secrets {
      print("  ✅ \(knownSecret.displayName)")
    }
    print("")

    print("Updating MCP configuration...")
    try await service.updateMCPConfigWithSecrets(secrets)

    print("✅ Successfully updated \(service.mcpConfigPath().path)")
    print("")
    print("⚠️  Restart Claude Code to load the new configuration")
    print("")
  }

  // MARK: - 1Password Setup

  private func setupWith1Password(service: SecretsService) async throws {
    print("")
    print("================================================================")
    print("  Setup Secrets with 1Password")
    print("================================================================")
    print("")

    // Verify 1Password CLI is installed
    guard await service.isOnePasswordInstalled() else {
      print("❌ 1Password CLI is not installed")
      print("")
      print("Install it via Homebrew:")
      print("  brew install --cask 1password-cli")
      print("")
      print("Documentation: https://developer.1password.com/docs/cli")
      throw ExitCode.failure
    }

    // Verify authenticated
    guard await service.isOnePasswordAuthenticated() else {
      print("❌ Not authenticated with 1Password")
      print("")
      print("Sign in with:")
      print("  eval $(op signin)")
      print("")
      print("Or configure Touch ID:")
      print("  https://developer.1password.com/docs/cli/about-biometric-unlock")
      throw ExitCode.failure
    }

    print("✅ 1Password CLI is ready")
    print("")

    // Show what will be fetched
    print("Will fetch the following secrets from 1Password:")
    for knownSecret in KnownSecret.allCases {
      if let reference = knownSecret.onePasswordReference {
        print("  - \(knownSecret.displayName)")
        print("    \(reference)")
      }
    }
    print("")

    // Confirm
    if !force {
      print("Continue? (y/n): ", terminator: "")
      guard let response = readLine()?.lowercased(),
        response == "y" || response == "yes"
      else {
        print("Setup cancelled")
        return
      }
    }

    print("")
    print("Fetching secrets from 1Password...")

    // Sync from 1Password
    let secrets = try await service.syncFromOnePassword()

    if secrets.isEmpty {
      print("⚠️  No secrets were successfully fetched")
      return
    }

    print("")
    print("Successfully fetched \(secrets.count) secret(s):")
    for (knownSecret, _) in secrets {
      print("  ✅ \(knownSecret.displayName)")
    }
    print("")

    // Update MCP config
    print("Updating MCP configuration...")
    try await service.updateMCPConfigWithSecrets(secrets)

    print("✅ Successfully updated \(service.mcpConfigPath().path)")
    print("")
    print("================================================================")
    print("  Setup Complete")
    print("================================================================")
    print("")
    print("Next steps:")
    print("  1. Restart Claude Code to load the new configuration")
    print("  2. Verify with: claude-agents setup secrets --check")
    print("")
  }

  // MARK: - Keychain Setup

  private func setupWithKeychain(service: SecretsService) async throws {
    print("")
    print("================================================================")
    print("  Setup Secrets with macOS Keychain")
    print("================================================================")
    print("")

    var secrets: [KnownSecret: String] = [:]

    // Ghost CMS
    print("────────────────────────────────────────────────────────────")
    print("  Ghost CMS Configuration")
    print("────────────────────────────────────────────────────────────")
    print("")

    let configureGhost: Bool
    if force {
      configureGhost = true
    } else {
      print("Configure Ghost CMS? (y/n): ", terminator: "")
      if let response = readLine()?.lowercased(),
        response == "y" || response == "yes"
      {
        configureGhost = true
      } else {
        print("Skipped Ghost configuration")
        print("")
        configureGhost = false
      }
    }

    if configureGhost {
      // Ghost URL
      var ghostUrl = ""
      while true {
        print("Ghost URL (e.g., https://yoursite.ghost.io): ", terminator: "")
        guard let input = readLine()?.trimmingCharacters(in: .whitespaces),
          !input.isEmpty
        else {
          print("URL cannot be empty")
          continue
        }

        if input.hasPrefix("http://") || input.hasPrefix("https://") {
          ghostUrl = input.hasSuffix("/") ? String(input.dropLast()) : input
          break
        } else {
          print("❌ Invalid URL format. Must start with http:// or https://")
        }
      }
      secrets[.ghostUrl] = ghostUrl

      // Ghost Admin API Key
      var ghostApiKey = ""
      while true {
        print("")
        print("Get your Ghost Admin API Key from:")
        print("  \(ghostUrl)/ghost/#/settings/integrations")
        print("")
        print("Ghost Admin API Key (format: id:secret): ", terminator: "")
        guard let input = readLine()?.trimmingCharacters(in: .whitespaces),
          !input.isEmpty
        else {
          print("API key cannot be empty")
          continue
        }

        // Validate format: hexid:hexsecret
        let pattern = "^[a-f0-9]+:[a-f0-9]+$"
        if let regex = try? NSRegularExpression(pattern: pattern, options: []),
          regex.firstMatch(in: input, options: [], range: NSRange(location: 0, length: input.count))
            != nil
        {
          ghostApiKey = input
          break
        } else {
          print("❌ Invalid API key format. Expected format: hexid:hexsecret")
          print(
            "   Example: 68e52dc931b35d0001eadcd5:f630615eb59b6f41bc75f46361d7f2661a9cf4c587d78d95f8e0102d568eaa3"
          )
        }
      }
      secrets[.ghostAdminApiKey] = ghostApiKey
    }

    // Firebase
    print("")
    print("────────────────────────────────────────────────────────────")
    print("  Firebase Configuration")
    print("────────────────────────────────────────────────────────────")
    print("")

    let configureFirebase: Bool
    if force {
      configureFirebase = true
    } else {
      print("Configure Firebase? (y/n): ", terminator: "")
      if let response = readLine()?.lowercased(),
        response == "y" || response == "yes"
      {
        configureFirebase = true
      } else {
        print("Skipped Firebase configuration")
        print("")
        configureFirebase = false
      }
    }

    if configureFirebase {
      print("")
      print("Get your Firebase token by running:")
      print("  firebase login:ci")
      print("")
      print("Firebase Token: ", terminator: "")

      if let token = readLine()?.trimmingCharacters(in: .whitespaces),
        !token.isEmpty
      {
        secrets[.firebaseToken] = token
      } else {
        print("⚠️  Empty token, skipping Firebase configuration")
      }
    }

    // Azure DevOps
    print("")
    print("────────────────────────────────────────────────────────────")
    print("  Azure DevOps Configuration")
    print("────────────────────────────────────────────────────────────")
    print("")

    let configureAzureDevops: Bool
    if force {
      configureAzureDevops = true
    } else {
      print("Configure Azure DevOps? (y/n): ", terminator: "")
      if let response = readLine()?.lowercased(),
        response == "y" || response == "yes"
      {
        configureAzureDevops = true
      } else {
        print("Skipped Azure DevOps configuration")
        print("")
        configureAzureDevops = false
      }
    }

    if configureAzureDevops {
      print("")
      print("Azure DevOps Personal Access Token (PAT):")
      print("  Create a PAT at: https://dev.azure.com/[organization]/_usersSettings/tokens")
      print("  Required scopes: Work Items (Read), Code (Read), Build (Read)")
      print("")
      print("PAT: ", terminator: "")

      if let pat = readLine()?.trimmingCharacters(in: .whitespaces),
        !pat.isEmpty
      {
        // Verify PAT works
        print("")
        print("Verifying PAT...")
        if await service.verifyAzureDevOpsAuth(pat: pat) {
          print("✅ PAT verified successfully")
          secrets[.azureDevopsPat] = pat
        } else {
          print("❌ PAT verification failed")
          print("   The PAT may be invalid or lack required permissions")
          print("   Continuing without Azure DevOps configuration")
        }
      } else {
        print("⚠️  Empty PAT, skipping Azure DevOps configuration")
      }
    }

    // Store in Keychain
    if !secrets.isEmpty {
      print("")
      print("Storing secrets in macOS Keychain...")

      for (knownSecret, value) in secrets {
        do {
          try await service.storeInKeychain(
            service: knownSecret.keychainService,
            account: knownSecret.keychainAccount,
            secret: value
          )
          print("  ✅ \(knownSecret.displayName)")
        } catch {
          print("  ❌ \(knownSecret.displayName): \(error)")
        }
      }

      print("")
      print("Updating MCP configuration...")
      try await service.updateMCPConfigWithSecrets(secrets)

      print("✅ Successfully updated \(service.mcpConfigPath().path)")
      print("")
      print("================================================================")
      print("  Setup Complete")
      print("================================================================")
      print("")
      print("Next steps:")
      print("  1. Restart Claude Code to load the new configuration")
      print("  2. Verify with: claude-agents setup secrets --check")
      print("")
    } else {
      print("No secrets configured")
    }
  }

  // MARK: - Interactive Mode Selection

  private func promptForMode(service: SecretsService) async -> Bool {
    print("")
    print("================================================================")
    print("  Secrets Setup")
    print("================================================================")
    print("")

    let opInstalled = await service.isOnePasswordInstalled()
    let opAuthenticated: Bool
    if opInstalled {
      opAuthenticated = await service.isOnePasswordAuthenticated()
    } else {
      opAuthenticated = false
    }

    print("Choose a method to configure secrets:")
    print("")

    if opAuthenticated {
      print("  1. Use 1Password (recommended)")
      print("     Fetch secrets directly from your 1Password vault")
      print("")
    } else if opInstalled {
      print("  1. Use 1Password (not authenticated)")
      print("     Run 'eval $(op signin)' first")
      print("")
    }

    print("  2. Manual input with macOS Keychain")
    print("     Enter secrets manually and store in Keychain")
    print("")

    while true {
      print("Enter choice (1 or 2): ", terminator: "")
      guard let choice = readLine()?.trimmingCharacters(in: .whitespaces) else {
        continue
      }

      if choice == "1" {
        if !opInstalled {
          print("❌ 1Password CLI is not installed")
          print("   Install: brew install --cask 1password-cli")
          print("")
          continue
        }
        if !opAuthenticated {
          print("❌ Not authenticated with 1Password")
          print("   Run: eval $(op signin)")
          print("")
          continue
        }
        return true
      } else if choice == "2" {
        return false
      } else {
        print("Invalid choice. Enter 1 or 2")
      }
    }
  }
}
