import Foundation

/// Actor responsible for Git operations (placeholder for future implementation)
public actor GitService {
  public init() {}

  /// Update agents from Git repository
  /// Currently a placeholder - users should use `install --force --all` instead
  public func updateAgents(to target: InstallTarget) async throws {
    print("Git update not yet implemented.")
    print("To update all agents, use: claude-agents install --all --force --\(target.displayName)")
  }
}
