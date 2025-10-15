import Foundation

/// Errors that can occur during agent parsing operations
public enum AgentError: Error, Sendable, CustomStringConvertible {
  case invalidFrontmatter(String)
  case missingRequiredField(String)
  case fileNotFound(URL)
  case invalidFileFormat(String)

  public var description: String {
    switch self {
    case .invalidFrontmatter(let path):
      return "Invalid YAML frontmatter in agent file: \(path)"
    case .missingRequiredField(let field):
      return "Missing required field in agent: \(field)"
    case .fileNotFound(let url):
      return "Agent file not found: \(url.path)"
    case .invalidFileFormat(let reason):
      return "Invalid agent file format: \(reason)"
    }
  }
}

/// Errors that can occur during agent installation operations
public enum InstallError: Error, Sendable, CustomStringConvertible {
  case permissionDenied(URL)
  case alreadyExists(String, URL)
  case directoryCreationFailed(URL, Error)
  case copyFailed(String, Error)
  case targetNotFound(URL)

  public var description: String {
    switch self {
    case .permissionDenied(let url):
      return "Permission denied: Cannot write to \(url.path)"
    case .alreadyExists(let name, let url):
      return "Agent '\(name)' already exists at \(url.path)"
    case .directoryCreationFailed(let url, let error):
      return "Failed to create directory at \(url.path): \(error.localizedDescription)"
    case .copyFailed(let name, let error):
      return "Failed to copy agent '\(name)': \(error.localizedDescription)"
    case .targetNotFound(let url):
      return "Target directory not found: \(url.path)"
    }
  }
}

/// Errors that can occur during secrets management operations
public enum SecretsError: Error, Sendable, CustomStringConvertible {
  case onePasswordNotInstalled
  case onePasswordNotAuthenticated
  case secretNotFound(String)
  case keychainAccessFailed(String, Error)
  case invalidMCPConfig(String)
  case configFileNotFound(URL)
  case configBackupFailed(URL, Error)
  case invalidSecretFormat(String)
  case missingEnvironmentVariable(String)

  public var description: String {
    switch self {
    case .onePasswordNotInstalled:
      return """
        1Password CLI is not installed.
        Install it via Homebrew: brew install --cask 1password-cli
        Documentation: https://developer.1password.com/docs/cli
        """
    case .onePasswordNotAuthenticated:
      return """
        Not authenticated with 1Password.
        Run: eval $(op signin)
        Or configure Touch ID: https://developer.1password.com/docs/cli/about-biometric-unlock
        """
    case .secretNotFound(let reference):
      return "Secret not found in 1Password: \(reference)"
    case .keychainAccessFailed(let key, let error):
      return "Failed to access Keychain for '\(key)': \(error.localizedDescription)"
    case .invalidMCPConfig(let reason):
      return "Invalid MCP configuration: \(reason)"
    case .configFileNotFound(let url):
      return "MCP configuration file not found: \(url.path)"
    case .configBackupFailed(let url, let error):
      return "Failed to backup config at \(url.path): \(error.localizedDescription)"
    case .invalidSecretFormat(let details):
      return "Invalid secret format: \(details)"
    case .missingEnvironmentVariable(let name):
      return "Missing environment variable: \(name)"
    }
  }
}
