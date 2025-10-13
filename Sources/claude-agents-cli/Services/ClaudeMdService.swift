import Foundation

/// Actor responsible for managing the global CLAUDE.md file
public actor ClaudeMdService {
  private let fileManager = FileManager.default

  public init() {}

  /// Get the path to the global CLAUDE.md file
  public func claudeMdPath() -> URL {
    return fileManager.homeDirectoryForCurrentUser
      .appendingPathComponent(".claude/CLAUDE.md")
  }

  /// Check if CLAUDE.md file exists
  public func claudeMdExists() -> Bool {
    let path = claudeMdPath()
    return fileManager.fileExists(atPath: path.path)
  }

  /// Check if CLAUDE.md already contains the agent CLI section
  public func containsAgentSection() async throws -> Bool {
    let path = claudeMdPath()

    guard fileManager.fileExists(atPath: path.path) else {
      return false
    }

    let content = try String(contentsOf: path, encoding: .utf8)

    // Look for the section header
    return content.contains("## Claude Agents CLI")
  }

  /// Get the agent CLI section content
  private func getAgentSectionContent() -> String {
    return """

      ## Claude Agents CLI

      The `claude-agents` CLI is a Swift command-line tool for managing specialized AI agent markdown files. It provides a curated library of production-ready agents for Claude Code, eliminating the need to write agent markdown from scratch.

      ### Installation

      ```bash
      cd ~/Developer/claude-agents-cli
      swift package experimental-install --product claude-agents
      ```

      Ensure `~/.swiftpm/bin` is in your PATH:
      ```bash
      export PATH="$HOME/.swiftpm/bin:$PATH"
      ```

      ### Core Commands

      **List available agents:**
      ```bash
      claude-agents list                          # Show all available agents
      claude-agents list --verbose                # Include descriptions
      claude-agents list --tool Bash              # Filter by tool
      ```

      **List installed agents:**
      ```bash
      claude-agents list --installed              # Global (~/.claude/agents/)
      claude-agents list --installed --target local  # Local (./.claude/agents/)
      ```

      **Install agents:**
      ```bash
      claude-agents install swift-architect --global         # Install to global
      claude-agents install testing-specialist --local       # Install to local
      claude-agents install --all --global                   # Install all agents
      claude-agents install swift-architect --global --force # Overwrite existing
      ```

      **Uninstall agents:**
      ```bash
      claude-agents uninstall swift-architect             # From global
      claude-agents uninstall swift-architect --target local  # From local
      ```

      ### Agent Categories & Use Cases

      **Swift Development (iOS/macOS):**
      - `swift-architect` - Swift 6.0 architecture patterns, actors, async/await, design systems
      - `swift-developer` - Feature implementation, iOS code writing, SwiftUI/UIKit
      - `swift-modernizer` - Legacy code migration to Swift 6.0, concurrency modernization
      - `swiftui-specialist` - SwiftUI best practices, view architecture, custom components
      - `kmm-specialist` - Kotlin Multiplatform Mobile integration with Swift
      - `spm-specialist` - Swift Package Manager, dependency management
      - `hummingbird-developer` - Hummingbird server-side Swift framework
      - `swift-grpc-temporal-developer` - gRPC and Temporal workflow integration
      - `grdb-sqlite-specialist` - GRDB.swift SQLite database patterns
      - `swift-mcp-server-writer` - Model Context Protocol server development

      **Testing & Quality:**
      - `testing-specialist` - Swift Testing framework, XCTest migration
      - `swift-testing-xcode-specialist` - Xcode test configuration and automation
      - `technical-debt-eliminator` - Code quality, refactoring, technical debt reduction

      **Xcode & Build Configuration:**
      - `xcode-configuration-specialist` - Xcode projects, build settings, multi-target configuration
      - `xib-storyboard-specialist` - Interface Builder, XIB, Storyboard patterns

      **Documentation:**
      - `documentation-writer` - Swift DocC, API docs, architecture documentation
      - `documentation-verifier` - Documentation quality assurance and style validation
      - `deckset-presenter` - Transform docs into Deckset presentations

      **Git & Version Control:**
      - `git-pr-specialist` - PR/MR workflows, GitLab/GitHub/Azure DevOps, branch strategies

      **Content & Publishing:**
      - `blog-content-writer` - Technical blog posts and articles
      - `ghost-publisher` - Ghost CMS publishing workflows
      - `ghost-blogger` - Ghost CMS blog management
      - `conference-specialist` - Conference talks, proposals, speaking engagements

      **Firebase & Analytics:**
      - `firebase-ecosystem-analyzer` - Firebase service analysis and integration
      - `firebase-companya-ecosystem-analyzer` - CompanyA-specific Firebase patterns
      - `crashlytics-analyzer` - Crashlytics crash analysis and debugging

      **Specialized Tools:**
      - `agent-writer` - Create new Claude agent markdown files
      - `secrets-manager` - Secure secrets management with macOS Keychain
      - `timestory-builder` - TimeStory timeline creation and management

      ### Installation Targets

      - **Global (`~/.claude/agents/`)**: Available across all projects (recommended for general-purpose agents)
      - **Local (`./.claude/agents/`)**: Project-specific agents or customized versions

      ### When to Use Which Agent

      **Starting a new Swift project:**
      ```bash
      claude-agents install swift-architect swift-developer testing-specialist spm-specialist --global
      ```

      **Working on iOS app development:**
      ```bash
      claude-agents install swift-developer swiftui-specialist xcode-configuration-specialist --global
      ```

      **Migrating legacy code:**
      ```bash
      claude-agents install swift-modernizer technical-debt-eliminator --global
      ```

      **Writing documentation:**
      ```bash
      claude-agents install documentation-writer documentation-verifier --global
      ```

      **Managing Git workflows:**
      ```bash
      claude-agents install git-pr-specialist --global
      ```

      **Working with specific technologies:**
      - KMM integration: `kmm-specialist`
      - Server-side Swift: `hummingbird-developer`
      - Database work: `grdb-sqlite-specialist`
      - Firebase: `firebase-ecosystem-analyzer`
      - Testing: `testing-specialist`

      ### Agent Discovery Tips

      - Use `claude-agents list --verbose` to browse all agents with descriptions
      - Filter by tool: `claude-agents list --tool Bash` to find agents with specific capabilities
      - Check installed agents: `claude-agents list --installed` to see what's already available
      - Reference project CLAUDE.md: Each agent's markdown file includes detailed expertise and use cases

      ### Updating Agents

      To update all agents to the latest version:
      ```bash
      claude-agents install --all --force --global
      ```

      ### Notes

      - Agents are markdown files with YAML frontmatter (name, description, tools, model)
      - Each agent is specialized for specific tasks to maximize Claude Code effectiveness
      - Global agents are available to all Claude Code sessions
      - Local agents override global ones when both exist
      - Project-specific customizations should be installed locally
      - The CLI is maintained at `~/Developer/claude-agents-cli`
      """
  }

  /// Add the agent CLI section to CLAUDE.md
  public func addAgentSection() async throws {
    let path = claudeMdPath()
    let sectionContent = getAgentSectionContent()

    if fileManager.fileExists(atPath: path.path) {
      // Append to existing file
      let existingContent = try String(contentsOf: path, encoding: .utf8)
      let updatedContent = existingContent + sectionContent
      try updatedContent.write(to: path, atomically: true, encoding: .utf8)
    } else {
      // Create new file with just the section
      let claudeDir = path.deletingLastPathComponent()

      // Create .claude directory if needed
      if !fileManager.fileExists(atPath: claudeDir.path) {
        try fileManager.createDirectory(
          at: claudeDir,
          withIntermediateDirectories: true,
          attributes: nil
        )
      }

      // Write content (start with development guidelines header)
      let content = "# Development Guidelines\n" + sectionContent
      try content.write(to: path, atomically: true, encoding: .utf8)
    }
  }

  /// Prompt user to add agent section
  public func promptToAddSection() async throws -> Bool {
    print("\nWould you like to add Claude agent information to your ~/.claude/CLAUDE.md file?")
    print("This helps Claude Code instances understand available agents and when to use them.")
    print("")
    print("Enter your choice (y/n): ", terminator: "")

    guard let input = readLine()?.trimmingCharacters(in: .whitespaces).lowercased() else {
      return false
    }

    return input == "y" || input == "yes"
  }
}
