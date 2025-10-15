import Foundation

/// Represents the scope of agent installation
public enum InstallationScope: String, Sendable, CaseIterable, Codable {
  /// Global installation in ~/.claude/agents/
  case global

  /// Project-specific installation in ./.claude/agents/
  case project

  /// Both global and project installations
  case all

  /// Get the directory URL for this scope
  /// - Parameter relativeTo: Base URL for project scope (defaults to current directory)
  /// - Returns: URL to the installation directory, or nil if scope is .all
  public func directoryURL(relativeTo projectRoot: URL? = nil) -> URL? {
    switch self {
    case .global:
      return FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".claude")
        .appendingPathComponent("agents")

    case .project:
      let base = projectRoot ?? URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
      return base
        .appendingPathComponent(".claude")
        .appendingPathComponent("agents")

    case .all:
      return nil  // No single directory for "all"
    }
  }

  /// Get all directory URLs for this scope
  /// - Parameter relativeTo: Base URL for project scope
  /// - Returns: Array of directory URLs
  public func directoryURLs(relativeTo projectRoot: URL? = nil) -> [URL] {
    switch self {
    case .global:
      return [directoryURL(relativeTo: projectRoot)].compactMap { $0 }
    case .project:
      return [directoryURL(relativeTo: projectRoot)].compactMap { $0 }
    case .all:
      return [
        InstallationScope.global.directoryURL(relativeTo: projectRoot),
        InstallationScope.project.directoryURL(relativeTo: projectRoot)
      ].compactMap { $0 }
    }
  }
}