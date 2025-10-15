import Foundation

/// Information about an installed agent
public struct InstallationInfo: Sendable, Codable, Equatable {
  /// File path where the agent is installed
  public let location: URL

  /// Installation scope (global or project)
  public let scope: InstallationScope

  /// When the agent was installed (file modification date)
  public let installedAt: Date

  /// Size of the installed file in bytes
  public let fileSize: Int64

  /// Version parsed from frontmatter (if available)
  public let version: String?

  /// The agent's name from frontmatter
  public let agentName: String

  public init(
    location: URL,
    scope: InstallationScope,
    installedAt: Date,
    fileSize: Int64,
    version: String? = nil,
    agentName: String
  ) {
    self.location = location
    self.scope = scope
    self.installedAt = installedAt
    self.fileSize = fileSize
    self.version = version
    self.agentName = agentName
  }

  /// Create InstallationInfo from a file URL
  /// - Parameters:
  ///   - url: The URL of the installed agent file
  ///   - scope: The installation scope
  /// - Returns: InstallationInfo if the file exists and is valid
  public static func from(url: URL, scope: InstallationScope) throws -> InstallationInfo? {
    let fileManager = FileManager.default

    guard fileManager.fileExists(atPath: url.path) else {
      return nil
    }

    let attributes = try fileManager.attributesOfItem(atPath: url.path)
    guard let fileSize = attributes[.size] as? Int64,
      let modificationDate = attributes[.modificationDate] as? Date
    else {
      throw AgentError.invalidFileFormat("Could not read file attributes: \(url.path)")
    }

    // Parse the agent to get metadata
    let agent = try Agent.parse(from: url)

    return InstallationInfo(
      location: url,
      scope: scope,
      installedAt: modificationDate,
      fileSize: fileSize,
      version: extractVersion(from: agent),
      agentName: agent.name
    )
  }

  /// Extract version from agent if available
  private static func extractVersion(from agent: Agent) -> String? {
    // For now, we don't have a version field in the frontmatter
    // This could be extended later if we add versioning
    return nil
  }
}