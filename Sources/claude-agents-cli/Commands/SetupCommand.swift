import ArgumentParser
import Foundation

public struct SetupCommand: AsyncParsableCommand {
  public static let configuration = CommandConfiguration(
    commandName: "setup",
    abstract: "Configure claude-agents CLI and related services",
    subcommands: [
      SetupSecretsCommand.self
    ],
    defaultSubcommand: SetupCLAUDEMdCommand.self
  )

  public init() {}
}

public struct SetupCLAUDEMdCommand: AsyncParsableCommand {
  public static let configuration = CommandConfiguration(
    commandName: "claudemd",
    abstract: "Configure claude-agents CLI integration with your global CLAUDE.md file"
  )

  @Flag(name: .long, help: "Skip confirmation prompt and add section automatically")
  var force = false

  @Flag(name: .long, help: "Check if CLAUDE.md is already configured")
  var check = false

  public init() {}

  public func run() async throws {
    let service = ClaudeMdService()

    // Check mode - just report status
    if check {
      let exists = await service.claudeMdExists()
      let hasSection = try await service.containsAgentSection()

      if !exists {
        print("Status: ~/.claude/CLAUDE.md does not exist")
        print("Run 'claude-agents setup' to create it with agent information")
      } else if hasSection {
        print("Status: ~/.claude/CLAUDE.md already contains agent CLI information")
      } else {
        print("Status: ~/.claude/CLAUDE.md exists but does not contain agent CLI information")
        print("Run 'claude-agents setup' to add it")
      }
      return
    }

    // Check if section already exists
    let alreadyHasSection = try await service.containsAgentSection()

    if alreadyHasSection {
      print("Your ~/.claude/CLAUDE.md already contains agent CLI information.")
      print("No changes needed.")
      return
    }

    // Determine if we should add the section
    let shouldAdd: Bool
    if force {
      shouldAdd = true
    } else {
      shouldAdd = try await service.promptToAddSection()
    }

    guard shouldAdd else {
      print("Setup cancelled. You can run 'claude-agents setup' later to add agent information.")
      return
    }

    // Add the section
    print("\nAdding agent CLI section to ~/.claude/CLAUDE.md...")

    do {
      try await service.addAgentSection()

      let exists = await service.claudeMdExists()
      if exists {
        print("✅ Successfully updated ~/.claude/CLAUDE.md")
      } else {
        print("✅ Successfully created ~/.claude/CLAUDE.md with agent information")
      }

      print("\nClaude Code will now have access to:")
      print("  - Complete list of available agents")
      print("  - Agent categories and use cases")
      print("  - Installation and usage examples")
      print("  - Quick reference for when to use which agent")

      print("\n💡 Tip: Run 'claude-agents list --verbose' to browse all available agents")
    } catch {
      print("❌ Failed to update CLAUDE.md: \(error.localizedDescription)")
      throw error
    }
  }
}
