import Foundation

/// Represents a secret credential
public struct Secret: Sendable, Identifiable, Hashable {
  public let id: String
  public let name: String
  public let value: String
  public let service: String
  public let account: String

  public init(id: String, name: String, value: String, service: String, account: String) {
    self.id = id
    self.name = name
    self.value = value
    self.service = service
    self.account = account
  }
}

/// Source for secrets (1Password or macOS Keychain)
public enum SecretSource: Sendable, Hashable {
  case onePassword(reference: String)
  case keychain(service: String, account: String)
  case manual(value: String)
}

/// MCP Server configuration
public struct MCPServerConfig: Sendable, Codable, Hashable {
  public var command: String
  public var args: [String]
  public var env: [String: String]
  public var description: String?

  public init(command: String, args: [String], env: [String: String], description: String? = nil) {
    self.command = command
    self.args = args
    self.env = env
    self.description = description
  }
}

/// Complete MCP configuration file structure
public struct MCPConfiguration: Sendable, Codable {
  public var mcpServers: [String: MCPServerConfig]

  public init(mcpServers: [String: MCPServerConfig] = [:]) {
    self.mcpServers = mcpServers
  }
}

/// Predefined secret configurations for known services
public enum KnownSecret: String, Sendable, CaseIterable {
  case ghostUrl = "ghost-url"
  case ghostAdminApiKey = "ghost-admin-api-key"
  case ghostContentApiKey = "ghost-content-api-key"
  case firebaseToken = "firebase-token"
  case azureDevopsPat = "azure-devops-pat"

  public var displayName: String {
    switch self {
    case .ghostUrl: return "Ghost URL"
    case .ghostAdminApiKey: return "Ghost Admin API Key"
    case .ghostContentApiKey: return "Ghost Content API Key"
    case .firebaseToken: return "Firebase Token"
    case .azureDevopsPat: return "Azure DevOps PAT"
    }
  }

  public var keychainService: String {
    switch self {
    case .ghostUrl, .ghostAdminApiKey, .ghostContentApiKey:
      return "claude-agents-cli.ghost"
    case .firebaseToken:
      return "claude-agents-cli.firebase"
    case .azureDevopsPat:
      return "claude-agents-cli.azure-devops"
    }
  }

  public var keychainAccount: String {
    switch self {
    case .ghostUrl: return "url"
    case .ghostAdminApiKey: return "api-key"
    case .ghostContentApiKey: return "content-api-key"
    case .firebaseToken: return "token"
    case .azureDevopsPat: return "pat"
    }
  }

  public var onePasswordReference: String? {
    switch self {
    case .ghostUrl:
      return "op://Employee/Ghost/my site"
    case .ghostAdminApiKey:
      return "op://Employee/Ghost/Saved on account.ghost.org/admin api key"
    case .ghostContentApiKey:
      return "op://Employee/Ghost/Saved on account.ghost.org/content api key"
    case .firebaseToken:
      return nil  // Not in 1Password by default
    case .azureDevopsPat:
      return nil  // Configure via manual input - store PAT in 1Password if needed
    }
  }

  public var environmentVariable: String {
    switch self {
    case .ghostUrl: return "GHOST_URL"
    case .ghostAdminApiKey: return "GHOST_ADMIN_API_KEY"
    case .ghostContentApiKey: return "GHOST_CONTENT_API_KEY"
    case .firebaseToken: return "FIREBASE_TOKEN"
    case .azureDevopsPat: return "AZURE_DEVOPS_EXT_PAT"
    }
  }
}
