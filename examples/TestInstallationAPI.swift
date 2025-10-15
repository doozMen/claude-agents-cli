import ClaudeAgents
import Foundation

@main
struct TestInstallationAPI {
  static func main() async throws {
    let repository = AgentRepository()

    print("Testing Installation Status API")
    print("===================================\n")

    // Test loading all agents
    let allAgents = try await repository.loadAgents()
    print("✓ Found \(allAgents.count) defined agents in bundle")

    // Test checking global installations
    let globalInstalled = try await repository.installedAgents(scope: .global)
    print("✓ Found \(globalInstalled.count) agents installed globally (~/.claude/agents/)")

    // Test checking project installations
    let projectInstalled = try await repository.installedAgents(scope: .project)
    print("✓ Found \(projectInstalled.count) agents installed locally (./.claude/agents/)")

    // Test not installed
    let notInstalled = try await repository.notInstalledAgents()
    print("✓ Found \(notInstalled.count) agents not installed")

    // Verify counts add up
    let totalInstalled = try await repository.installedAgents(scope: .all)
    assert(totalInstalled.count + notInstalled.count == allAgents.count)
    print("✓ Installation counts verified (installed + not installed = total)")

    // Test specific agent check
    if allAgents.first(where: { $0.name == "swift-architect" }) != nil {
      let isInstalled = try await repository.isInstalled(agentID: "swift-architect")
      print("\nswift-architect status:")
      print("  - Installed: \(isInstalled)")

      // Test installation info
      if let info = try await repository.installationInfo(for: "swift-architect") {
        print("  - Location: \(info.location.path)")
        print("  - Scope: \(info.scope)")
        print("  - Size: \(info.fileSize) bytes")
        print("  - Modified: \(info.installedAt)")
      }
    }

    // Show sample of not installed agents
    if !notInstalled.isEmpty {
      print("\nSample of agents not installed:")
      for agent in notInstalled.prefix(5) {
        print("  - \(agent.name): \(agent.description)")
      }

      if notInstalled.count > 5 {
        print("  ... and \(notInstalled.count - 5) more")
      }

      let names = notInstalled.prefix(3).map { $0.name }.joined(separator: " ")
      print("\nTo install: claude-agents install \(names) --global")
    }

    print("\n✅ Installation Status API working correctly!")
  }
}
