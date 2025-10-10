import ArgumentParser
import Foundation

public struct InstallCommand: AsyncParsableCommand {
  public static let configuration = CommandConfiguration(
    commandName: "install",
    abstract: "Install agent markdown files to ~/.claude/agents/ or ./.claude/agents/"
  )

  @Flag(name: .shortAndLong, help: "Install to global location (~/.claude/agents/)")
  var global = false

  @Flag(name: .shortAndLong, help: "Install to local location (./.claude/agents/)")
  var local = false

  @Flag(name: .shortAndLong, help: "Install all available agents")
  var all = false

  @Flag(name: .shortAndLong, help: "Force overwrite if agent already exists")
  var force = false

  @Argument(help: "Names of agents to install (e.g., swift-architect testing-specialist)")
  var agentNames: [String] = []

  public init() {}

  public func run() async throws {
    // Determine target location
    let target: InstallTarget
    if global && local {
      throw ValidationError("Cannot specify both --global and --local")
    } else if global {
      target = .global
    } else if local {
      target = .local
    } else {
      // Default to global
      target = .global
    }

    let parser = AgentParser()
    let installService = InstallService()

    // Determine which agents to install
    let agentsToInstall: [Agent]

    if all {
      agentsToInstall = try await parser.loadAgents()
      if agentsToInstall.isEmpty {
        print("No agents available to install")
        return
      }
    } else if agentNames.isEmpty {
      // Interactive mode - show available agents
      let availableAgents = try await parser.loadAgents()
      guard !availableAgents.isEmpty else {
        print("No agents available to install")
        return
      }

      print("Available agents:")
      for (index, agent) in availableAgents.enumerated() {
        print("  \(index + 1). \(agent.name)")
      }
      print("\nEnter agent numbers to install (comma-separated), or 'all': ", terminator: "")

      guard let input = readLine()?.trimmingCharacters(in: .whitespaces),
        !input.isEmpty
      else {
        print("Installation cancelled")
        return
      }

      if input.lowercased() == "all" {
        agentsToInstall = availableAgents
      } else {
        let indices = input.split(separator: ",")
          .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
          .filter { $0 > 0 && $0 <= availableAgents.count }
          .map { $0 - 1 }

        agentsToInstall = indices.map { availableAgents[$0] }
      }
    } else {
      // Install specified agents
      var agents: [Agent] = []
      for name in agentNames {
        if let agent = try await parser.findAgent(byIdentifier: name) {
          agents.append(agent)
        } else {
          print("Warning: Agent '\(name)' not found, skipping...")
        }
      }
      agentsToInstall = agents
    }

    guard !agentsToInstall.isEmpty else {
      print("No agents to install")
      return
    }

    // Install agents
    print("\nInstalling \(agentsToInstall.count) agent(s) to \(target.displayName) location...")
    print("Target: \(target.path().path)\n")

    let results = await installService.install(
      agents: agentsToInstall,
      target: target,
      overwrite: force,
      interactive: !force && agentNames.isEmpty
    )

    // Report results
    var installed = 0
    var skipped = 0
    var overwritten = 0
    var failed = 0

    for result in results {
      switch result.status {
      case .installed:
        print("✅ \(result.agent.name)")
        installed += 1
      case .overwritten:
        print("✅ \(result.agent.name) (overwritten)")
        overwritten += 1
      case .skipped(let reason):
        print("⏭️  \(result.agent.name) - \(reason)")
        skipped += 1
      case .failed(let error):
        print("❌ \(result.agent.name) - \(error.localizedDescription)")
        failed += 1
      }
    }

    // Summary
    print("\n📊 Summary:")
    if installed > 0 {
      print("  Installed: \(installed)")
    }
    if overwritten > 0 {
      print("  Overwritten: \(overwritten)")
    }
    if skipped > 0 {
      print("  Skipped: \(skipped)")
    }
    if failed > 0 {
      print("  Failed: \(failed)")
    }
  }
}
