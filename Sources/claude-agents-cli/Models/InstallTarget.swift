import Foundation

/// Represents the installation target location for agents
public enum InstallTarget: Sendable, Equatable {
  case global  // ~/.claude/agents/
  case local  // ./.claude/agents/

  /// Returns the URL for this installation target
  public func path() -> URL {
    switch self {
    case .global:
      return FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".claude")
        .appendingPathComponent("agents")
    case .local:
      return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .appendingPathComponent(".claude")
        .appendingPathComponent("agents")
    }
  }

  /// Returns a human-readable name for this target
  public var displayName: String {
    switch self {
    case .global:
      return "global"
    case .local:
      return "local"
    }
  }
}
