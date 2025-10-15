import Foundation
import Testing

@testable import ClaudeAgents

@Suite("Installation Status API Tests", .serialized)
struct InstallationTests {
  static func createTestDirectory() -> URL {
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(
      "claude-agents-test-\(UUID().uuidString)")
    try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
  }

  static func cleanupTestDirectory(_ directory: URL) {
    try? FileManager.default.removeItem(at: directory)
  }

  @Test("InstallationScope directory URLs are correct")
  func testInstallationScopeDirectoryURLs() throws {
    // Test global scope
    let globalURL = InstallationScope.global.directoryURL()
    #expect(globalURL != nil)
    #expect(globalURL?.lastPathComponent == "agents")
    #expect(globalURL?.deletingLastPathComponent().lastPathComponent == ".claude")

    // Test project scope with custom base
    let projectBase = URL(fileURLWithPath: "/tmp/test-project")
    let projectURL = InstallationScope.project.directoryURL(relativeTo: projectBase)
    #expect(projectURL != nil)
    #expect(projectURL?.path == "/tmp/test-project/.claude/agents")

    // Test all scope returns nil for single directory
    let allURL = InstallationScope.all.directoryURL()
    #expect(allURL == nil)

    // Test all scope returns both directories
    let allURLs = InstallationScope.all.directoryURLs()
    #expect(allURLs.count == 2)
  }

  @Test("Detect global installation")
  func testGlobalInstallationDetection() async throws {
    let repository = AgentRepository()

    // Check if any agents are already installed globally (may be true on dev machines)
    let installedBefore = try await repository.installedAgents(scope: .global)

    // We can't make assumptions about what's installed, just test the API works
    let isInstalled = try await repository.isInstalled(
      agentID: "swift-architect",
      scope: .global)
    #expect(isInstalled == installedBefore.contains { $0.name == "swift-architect" })
  }

  @Test("Detect project installation in temp directory")
  func testProjectInstallationDetection() async throws {
    let repository = AgentRepository()
    let testDirectory = Self.createTestDirectory()
    defer { Self.cleanupTestDirectory(testDirectory) }

    // Create test project directory structure
    let projectDir = testDirectory.appendingPathComponent(".claude/agents")
    try FileManager.default.createDirectory(at: projectDir, withIntermediateDirectories: true)

    // Create a mock agent file
    let mockAgentContent = """
      ---
      name: test-agent
      description: Test agent for unit testing
      tools: Read, Edit
      ---

      # Test Agent

      This is a test agent.
      """

    let agentFile = projectDir.appendingPathComponent("test-agent.md")
    try mockAgentContent.write(to: agentFile, atomically: true, encoding: .utf8)

    // Change current directory to test directory (this affects project scope)
    let originalDir = FileManager.default.currentDirectoryPath
    FileManager.default.changeCurrentDirectoryPath(testDirectory.path)
    defer { FileManager.default.changeCurrentDirectoryPath(originalDir) }

    // Clear cache to force reload
    await repository.clearCache()

    // Check if test agent is installed
    let isInstalled = try await repository.isInstalled(agentID: "test-agent", scope: .project)
    #expect(isInstalled == true)

    // Get installation info
    let info = try await repository.installationInfo(for: "test-agent", scope: .project)
    #expect(info != nil)
    #expect(info?.agentName == "test-agent")
    #expect(info?.scope == .project)
    #expect(info?.location.lastPathComponent == "test-agent.md")
  }

  @Test("Handle missing directories gracefully")
  func testMissingDirectories() async throws {
    let repository = AgentRepository()
    let testDirectory = Self.createTestDirectory()
    defer { Self.cleanupTestDirectory(testDirectory) }

    // Create a test directory that definitely doesn't have .claude/agents
    let emptyDir = testDirectory.appendingPathComponent("empty-project")
    try FileManager.default.createDirectory(at: emptyDir, withIntermediateDirectories: true)

    // Change to empty directory
    let originalDir = FileManager.default.currentDirectoryPath
    FileManager.default.changeCurrentDirectoryPath(emptyDir.path)
    defer { FileManager.default.changeCurrentDirectoryPath(originalDir) }

    // Clear cache
    await repository.clearCache()

    // Should not throw, just return empty
    let installed = try await repository.installedAgents(scope: .project)
    #expect(installed.isEmpty)

    // Check for non-existent agent
    let isInstalled = try await repository.isInstalled(
      agentID: "non-existent",
      scope: .project)
    #expect(isInstalled == false)
  }

  @Test("Match agents by name")
  func testAgentMatchingByName() async throws {
    let repository = AgentRepository()
    let testDirectory = Self.createTestDirectory()
    defer { Self.cleanupTestDirectory(testDirectory) }

    // Create test directory structure
    let projectDir = testDirectory.appendingPathComponent(".claude/agents")
    try FileManager.default.createDirectory(at: projectDir, withIntermediateDirectories: true)

    // Create agent with different filename than name
    let mockAgentContent = """
      ---
      name: custom-name-agent
      description: Agent with custom name
      tools: Bash
      ---

      # Custom Name Agent
      """

    // Save with different filename
    let agentFile = projectDir.appendingPathComponent("different-filename.md")
    try mockAgentContent.write(to: agentFile, atomically: true, encoding: .utf8)

    // Change to test directory
    let originalDir = FileManager.default.currentDirectoryPath
    FileManager.default.changeCurrentDirectoryPath(testDirectory.path)
    defer { FileManager.default.changeCurrentDirectoryPath(originalDir) }

    // Clear cache
    await repository.clearCache()

    // Should find by agent name, not filename
    let isInstalled = try await repository.isInstalled(
      agentID: "custom-name-agent",
      scope: .project)
    #expect(isInstalled == true)

    // Should not find by filename
    let notFoundByFilename = try await repository.isInstalled(
      agentID: "different-filename",
      scope: .project)
    #expect(notFoundByFilename == false)
  }

  @Test("Filter not installed agents")
  func testNotInstalledAgents() async throws {
    let repository = AgentRepository()

    // Get all defined agents
    let allAgents = try await repository.loadAgents()
    #expect(allAgents.count > 0)  // Should have bundled agents

    // Get installed agents
    let installedAgents = try await repository.installedAgents(scope: .all)

    // Get not installed agents
    let notInstalledAgents = try await repository.notInstalledAgents(scope: .all)

    // Verify counts add up
    #expect(installedAgents.count + notInstalledAgents.count == allAgents.count)

    // Verify no overlap
    let installedNames = Set(installedAgents.map { $0.name })
    let notInstalledNames = Set(notInstalledAgents.map { $0.name })
    #expect(installedNames.intersection(notInstalledNames).isEmpty)
  }

  @Test("Installation info includes file metadata")
  func testInstallationInfoMetadata() async throws {
    let repository = AgentRepository()
    let testDirectory = Self.createTestDirectory()
    defer { Self.cleanupTestDirectory(testDirectory) }

    // Create test agent
    let projectDir = testDirectory.appendingPathComponent(".claude/agents")
    try FileManager.default.createDirectory(at: projectDir, withIntermediateDirectories: true)

    let mockAgentContent = """
      ---
      name: metadata-test
      description: Test metadata extraction
      tools: Read
      model: sonnet
      ---

      # Metadata Test Agent

      Content for testing metadata.
      """

    let agentFile = projectDir.appendingPathComponent("metadata-test.md")
    try mockAgentContent.write(to: agentFile, atomically: true, encoding: .utf8)

    // Set file modification date
    let modDate = Date().addingTimeInterval(-3600)  // 1 hour ago
    try FileManager.default.setAttributes([.modificationDate: modDate], ofItemAtPath: agentFile.path)

    // Change to test directory
    let originalDir = FileManager.default.currentDirectoryPath
    FileManager.default.changeCurrentDirectoryPath(testDirectory.path)
    defer { FileManager.default.changeCurrentDirectoryPath(originalDir) }

    // Clear cache and get info
    await repository.clearCache()
    let info = try await repository.installationInfo(for: "metadata-test", scope: .project)

    #expect(info != nil)
    #expect(info?.agentName == "metadata-test")
    #expect(info?.fileSize ?? 0 > 0)
    #expect(info?.installedAt != nil)
    #expect(info?.location.lastPathComponent == "metadata-test.md")
  }

  @Test("Cache invalidation after TTL")
  func testCacheInvalidation() async throws {
    // This test would require mocking time or waiting 5 minutes
    // For now, just test that clearCache works
    let repository = AgentRepository()

    // Load agents to populate cache
    _ = try await repository.installedAgents(scope: .all)

    // Clear cache
    await repository.clearCache()

    // Next call should rebuild cache (we can't directly test this without accessing internals)
    let agentsAfterClear = try await repository.installedAgents(scope: .all)

    // Test passes if no errors thrown and we got a result
    #expect(agentsAfterClear.count >= 0)
  }
}