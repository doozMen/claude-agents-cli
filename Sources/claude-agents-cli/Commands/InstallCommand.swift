import ArgumentParser
import ClaudeAgents
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

    let repository = AgentRepository()
    let installService = InstallService()

    // Determine which agents to install
    let agentsToInstall: [Agent]

    if all {
      agentsToInstall = try await repository.loadAgents()
      if agentsToInstall.isEmpty {
        print("No agents available to install")
        return
      }
    } else if agentNames.isEmpty {
      // Interactive mode - show available agents
      let availableAgents = try await repository.loadAgents()
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
        do {
          if let agent = try await repository.getAgent(named: name) {
            agents.append(agent)
          } else {
            print("Warning: Agent '\(name)' not found, skipping...")
          }
        } catch {
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

    // Check dependencies for successfully installed agents
    if installed > 0 || overwritten > 0 {
      let successfullyInstalled = results.filter {
        switch $0.status {
        case .installed, .overwritten: return true
        default: return false
        }
      }.map { $0.agent }

      await checkAndOfferDependencyInstallation(for: successfullyInstalled, force: force)

      // Suggest setup if CLAUDE.md doesn't have agent info
      let claudeMdService = ClaudeMdService()
      let hasSection = try? await claudeMdService.containsAgentSection()

      if hasSection == false {
        print("\n💡 Tip: Run 'claude-agents setup' to add agent info to ~/.claude/CLAUDE.md")
      }
    }
  }

  /// Check dependencies for installed agents and offer to install missing ones
  private func checkAndOfferDependencyInstallation(for agents: [Agent], force: Bool) async {
    let dependencyService = DependencyService()

    // Detect dependencies from installed agents
    let dependencies = await dependencyService.detectAgentDependencies(agents)

    guard !dependencies.isEmpty else {
      return
    }

    // Check which dependencies are missing
    var missing: [CLIDependency] = []
    for dependency in dependencies {
      let isInstalled = await dependencyService.checkInstallation(dependency)
      if !isInstalled {
        missing.append(dependency)
      }
    }

    guard !missing.isEmpty else {
      return
    }

    print("\n🔍 Dependency Check:")
    for dep in missing {
      print("   ❌ \(dep.name) - required by: \(dep.usedByAgents.joined(separator: ", "))")
    }

    // If --force flag is used, skip prompts and show info only
    if force {
      print("\n💡 Tip: Run 'claude-agents doctor --install' to install missing dependencies")
      return
    }

    // Interactive prompt to install dependencies
    print("\nWould you like to install missing dependencies now? (y/n): ", terminator: "")

    guard let response = readLine()?.lowercased(),
      response == "y" || response == "yes"
    else {
      print("\n💡 Tip: Run 'claude-agents doctor --install' to install dependencies later")
      return
    }

    // Install missing dependencies
    print("\n📥 Installing dependencies...\n")

    for dep in missing {
      print("Installing \(dep.name)...", terminator: " ")

      do {
        if dep.homebrewFormula != nil {
          try await dependencyService.installViaBrew(dep)
          print("✅")

          // Special handling for Azure CLI - suggest authentication
          if dep.id == "azure-cli" {
            print("\n   💡 Next step: Run 'az login' to authenticate with Azure DevOps")
          }
        } else if let installCmd = dep.installCommand {
          let process = Process()
          process.executableURL = URL(fileURLWithPath: "/bin/sh")
          process.arguments = ["-c", installCmd]

          try process.run()
          process.waitUntilExit()

          if process.terminationStatus == 0 {
            print("✅")
          } else {
            print("❌ Failed")
          }
        } else {
          print("⏭️  No automatic installation available")
        }
      } catch {
        print("❌ \(error)")
      }
    }

    print("\n✅ Dependency installation complete!")
  }
}
