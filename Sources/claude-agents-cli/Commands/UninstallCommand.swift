import ArgumentParser
import Foundation

public struct UninstallCommand: AsyncParsableCommand {
  public static let configuration = CommandConfiguration(
    commandName: "uninstall",
    abstract: "Uninstall agent markdown files from ~/.claude/agents/ or ./.claude/agents/"
  )

  @Option(
    name: .shortAndLong,
    help: "Target location to uninstall from (global or local, defaults to global)")
  var target: TargetOption = .global

  @Argument(help: "Names of agents to uninstall")
  var agentNames: [String]

  public init() {}

  public func run() async throws {
    guard !agentNames.isEmpty else {
      throw ValidationError("Please specify at least one agent name to uninstall")
    }

    let installTarget = target.toInstallTarget()
    let service = InstallService()

    print("Uninstalling \(agentNames.count) agent(s) from \(installTarget.displayName) location...")
    print("Target: \(installTarget.path().path)\n")

    let results = await service.uninstall(agentNames: agentNames, target: installTarget)

    var successful = 0
    var failed = 0

    for (name, success) in results {
      if success {
        print("✅ \(name)")
        successful += 1
      } else {
        print("❌ \(name)")
        failed += 1
      }
    }

    print("\n📊 Summary:")
    if successful > 0 {
      print("  Uninstalled: \(successful)")
    }
    if failed > 0 {
      print("  Failed: \(failed)")
    }
  }
}
