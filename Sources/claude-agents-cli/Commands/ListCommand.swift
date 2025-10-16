import ArgumentParser
import ClaudeAgents
import Foundation

public struct ListCommand: AsyncParsableCommand {
  public static let configuration = CommandConfiguration(
    commandName: "list",
    abstract: "List available or installed agents"
  )

  @Flag(name: .shortAndLong, help: "Show installed agents instead of available agents")
  var installed = false

  @Flag(name: .shortAndLong, help: "Show detailed information including descriptions")
  var verbose = false

  @Option(name: .long, help: "Filter agents by tool name")
  var tool: String?

  @Option(name: .shortAndLong, help: "Target location for installed agents (global or local)")
  var target: TargetOption?

  public init() {}

  public func run() async throws {
    if installed {
      try await listInstalled()
    } else {
      try await listAvailable()
    }
  }

  private func listAvailable() async throws {
    let repository = AgentRepository()
    let agents = try await repository.loadAgents()

    // Filter by tool if specified
    let filteredAgents =
      if let toolFilter = tool {
        agents.filter { agent in
          agent.tools.contains { $0.localizedCaseInsensitiveContains(toolFilter) }
        }
      } else {
        agents
      }

    if filteredAgents.isEmpty {
      if let toolFilter = tool {
        print("No agents found using tool '\(toolFilter)'")
      } else {
        print("No agents available")
      }
      return
    }

    print("Available agents (\(filteredAgents.count)):\n")

    for agent in filteredAgents {
      if verbose {
        print("  \(agent.name)")
        print("    Description: \(agent.description)")
        print("    Tools: \(agent.tools.joined(separator: ", "))")
        if let model = agent.model {
          print("    Model: \(model)")
        }
        print()
      } else {
        print("  \(agent.name)")
      }
    }
  }

  private func listInstalled() async throws {
    let service = InstallService()
    let targetToUse = target?.toInstallTarget() ?? .global

    let installedAgents = await service.listInstalled(at: targetToUse)

    if installedAgents.isEmpty {
      print("No agents installed at \(targetToUse.displayName) location")
      print("Location: \(targetToUse.path().path)")
      return
    }

    print("Installed agents at \(targetToUse.displayName) location (\(installedAgents.count)):")
    print("Location: \(targetToUse.path().path)\n")

    for agentName in installedAgents {
      print("  \(agentName)")
    }
  }
}
