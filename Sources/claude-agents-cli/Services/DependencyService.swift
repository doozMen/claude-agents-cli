import ClaudeAgents
import Foundation

/// Actor responsible for managing CLI tool dependencies
public actor DependencyService {
  public init() {}

  /// Detect all dependencies required by the given agents
  public func detectAgentDependencies(_ agents: [Agent]) async -> [CLIDependency] {
    var dependencyMap: [String: [String]] = [:]

    // Collect all dependencies and which agents use them
    for agent in agents {
      for dependencyId in agent.dependencies {
        if dependencyMap[dependencyId] == nil {
          dependencyMap[dependencyId] = []
        }
        dependencyMap[dependencyId]?.append(agent.name)
      }
    }

    // Convert to CLIDependency objects
    var dependencies: [CLIDependency] = []
    for (dependencyId, agentNames) in dependencyMap {
      if let predefined = CLIDependency.find(byId: dependencyId) {
        // Update with actual agents using it
        let updated = CLIDependency(
          id: predefined.id,
          name: predefined.name,
          checkCommand: predefined.checkCommand,
          installCommand: predefined.installCommand,
          homebrewFormula: predefined.homebrewFormula,
          usedByAgents: agentNames.sorted(),
          optional: predefined.optional
        )
        dependencies.append(updated)
      }
    }

    return dependencies.sorted { $0.name < $1.name }
  }

  /// Check if a dependency is installed
  public func checkInstallation(_ dependency: CLIDependency) async -> Bool {
    do {
      let process = Process()
      process.executableURL = URL(fileURLWithPath: "/bin/sh")
      process.arguments = ["-c", dependency.checkCommand]

      let pipe = Pipe()
      process.standardOutput = pipe
      process.standardError = pipe

      try process.run()
      process.waitUntilExit()

      return process.terminationStatus == 0
    } catch {
      return false
    }
  }

  /// Install a dependency via Homebrew
  public func installViaBrew(_ dependency: CLIDependency) async throws {
    // First check if Homebrew is installed
    let brewInstalled = await checkBrewInstallation()
    guard brewInstalled else {
      throw DependencyError.brewNotInstalled
    }

    guard let formula = dependency.homebrewFormula else {
      throw DependencyError.noBrewFormula(dependency.name)
    }

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/local/bin/brew")
    process.arguments = ["install", formula]

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe

    try process.run()
    process.waitUntilExit()

    guard process.terminationStatus == 0 else {
      throw DependencyError.installationFailed(dependency.name)
    }
  }

  /// Generate a report of dependencies and their installation status
  public func generateReport(_ dependencies: [(CLIDependency, Bool)]) -> String {
    var report = ""

    let installed = dependencies.filter { $0.1 }
    let missing = dependencies.filter { !$0.1 }

    if !installed.isEmpty {
      report += "Installed Tools:\n"
      for (dep, _) in installed {
        report += "  ✅ \(dep.name)\n"
      }
    }

    if !missing.isEmpty {
      report += "\nMissing Tools:\n"
      for (dep, _) in missing {
        report += "  ❌ \(dep.name)\n"
        report += "     Used by: \(dep.usedByAgents.joined(separator: ", "))\n"
      }
    }

    return report
  }

  /// Check if Homebrew is installed
  private func checkBrewInstallation() async -> Bool {
    do {
      let process = Process()
      process.executableURL = URL(fileURLWithPath: "/usr/local/bin/brew")
      process.arguments = ["--version"]

      let pipe = Pipe()
      process.standardOutput = pipe
      process.standardError = pipe

      try process.run()
      process.waitUntilExit()

      return process.terminationStatus == 0
    } catch {
      return false
    }
  }
}

/// Errors that can occur during dependency operations
public enum DependencyError: Error, Sendable, CustomStringConvertible {
  case brewNotInstalled
  case noBrewFormula(String)
  case installationFailed(String)

  public var description: String {
    switch self {
    case .brewNotInstalled:
      return "Homebrew is not installed. Install from https://brew.sh"
    case .noBrewFormula(let name):
      return "No Homebrew formula available for \(name)"
    case .installationFailed(let name):
      return "Failed to install \(name) via Homebrew"
    }
  }
}
