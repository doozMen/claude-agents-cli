import ArgumentParser
import Foundation

@main
struct ClaudeAgentsCLI: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "claude-agents",
    abstract: "Install and manage Claude agent markdown files",
    version: "1.0.0",
    subcommands: [
      ListCommand.self,
      InstallCommand.self,
      UninstallCommand.self,
      UpdateCommand.self,
    ],
    defaultSubcommand: ListCommand.self
  )
}
