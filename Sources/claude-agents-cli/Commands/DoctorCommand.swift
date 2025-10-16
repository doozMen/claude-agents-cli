import ArgumentParser
import ClaudeAgents
import Foundation

public struct DoctorCommand: AsyncParsableCommand {
  public static let configuration = CommandConfiguration(
    commandName: "doctor",
    abstract: "Check CLI tool dependencies required by agents"
  )

  @Flag(name: .long, help: "Install missing dependencies via Homebrew")
  var install = false

  @Option(name: .long, help: "Check dependencies for specific agent only")
  var agent: String?

  public init() {}

  public func run() async throws {
    print("🔍 Checking CLI tool dependencies...\n")

    let parser = AgentRepository()
    let dependencyService = DependencyService()

    // Load agents
    let allAgents = try await parser.loadAgents()

    // Filter by specific agent if requested
    let agentsToCheck: [Agent]
    if let agentName = agent {
      if let foundAgent = allAgents.first(where: { $0.name == agentName || $0.id == agentName }) {
        agentsToCheck = [foundAgent]
        print("Checking dependencies for agent: \(foundAgent.name)\n")
      } else {
        print("❌ Agent '\(agentName)' not found")
        return
      }
    } else {
      agentsToCheck = allAgents
    }

    // Detect dependencies
    let dependencies = await dependencyService.detectAgentDependencies(agentsToCheck)

    guard !dependencies.isEmpty else {
      print("✅ No CLI dependencies required by selected agents")
      return
    }

    // Check installation status
    var results: [(CLIDependency, Bool)] = []
    for dependency in dependencies {
      let isInstalled = await dependencyService.checkInstallation(dependency)
      results.append((dependency, isInstalled))
    }

    // Display results
    let installed = results.filter { $0.1 }
    let missing = results.filter { !$0.1 }

    if !installed.isEmpty {
      print("✅ Installed Tools:")
      for (dep, _) in installed {
        print("   \(dep.name)")
      }
      print()
    }

    if !missing.isEmpty {
      print("❌ Missing Tools:")
      for (dep, _) in missing {
        print("   \(dep.name)")
        print("      Used by: \(dep.usedByAgents.joined(separator: ", "))")

        // Show installation instructions
        if let installCmd = dep.installCommand {
          print("      Install: \(installCmd)")
        } else if let formula = dep.homebrewFormula {
          print("      Install: brew install \(formula)")
        }
        print()
      }

      // Install if requested
      if install {
        print("📥 Installing missing dependencies...\n")

        for (dep, isInstalled) in results where !isInstalled {
          print("Installing \(dep.name)...", terminator: " ")

          do {
            if let installCmd = dep.installCommand {
              // Use custom install command
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
            } else if dep.homebrewFormula != nil {
              // Install via Homebrew
              try await dependencyService.installViaBrew(dep)
              print("✅")
            } else {
              print("⏭️  No automatic installation available")
            }
          } catch {
            print("❌ \(error)")
          }
        }

        print("\n✅ Installation complete!")
      } else {
        print("💡 Tip: Run 'claude-agents doctor --install' to install missing dependencies")
      }
    } else {
      print("✅ All required CLI tools are installed!")
    }

    // Summary
    print("\n📊 Summary:")
    print("   Installed: \(installed.count)")
    print("   Missing: \(missing.count)")
    print("   Total: \(dependencies.count)")
  }
}
