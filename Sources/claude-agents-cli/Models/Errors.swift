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
