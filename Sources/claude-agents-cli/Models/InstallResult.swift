import Foundation
import ClaudeAgents

/// Represents the result of an agent installation operation
public struct InstallResult: Sendable {
  public enum Status: Sendable {
    case installed
    case skipped(reason: String)
    case overwritten
    case failed(error: Error)
  }

  public let agent: Agent
  public let target: InstallTarget
  public let destinationPath: URL
  public let status: Status

  public init(agent: Agent, target: InstallTarget, destinationPath: URL, status: Status) {
    self.agent = agent
    self.target = target
    self.destinationPath = destinationPath
    self.status = status
  }
}

extension InstallResult.Status: CustomStringConvertible {
  public var description: String {
    switch self {
    case .installed:
      return "installed"
    case .skipped(let reason):
      return "skipped (\(reason))"
    case .overwritten:
      return "overwritten"
    case .failed(let error):
      return "failed: \(error.localizedDescription)"
    }
  }
}
