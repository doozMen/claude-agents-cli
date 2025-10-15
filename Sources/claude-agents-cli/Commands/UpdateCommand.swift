import ArgumentParser
import ClaudeAgents
import Foundation

public struct UpdateCommand: AsyncParsableCommand {
  public static let configuration = CommandConfiguration(
    commandName: "update",
    abstract: "Update installed agents to the latest version (placeholder)"
  )

  @Option(
    name: .shortAndLong, help: "Target location to update (global or local, defaults to global)")
  var target: TargetOption = .global

  public init() {}

  public func run() async throws {
    let installTarget = target.toInstallTarget()
    let gitService = GitService()

    try await gitService.updateAgents(to: installTarget)
  }
}
