import Foundation

/// Public repository for accessing Claude agent markdown files
///
/// This is the main entry point for consuming the ClaudeAgents library.
/// Use this to load, query, and access agent content programmatically.
///
/// Example:
/// ```swift
/// import ClaudeAgents
///
/// let repository = AgentRepository()
/// let agents = try await repository.loadAgents()
/// let swiftArchitect = try await repository.getAgent(named: "swift-architect")
/// print(swiftArchitect.content)
/// ```
public actor AgentRepository {
  private let parser: AgentParser
  private var installationCache: [InstallationScope: [String: InstallationInfo]] = [:]
  private var cacheTimestamp: Date?
  private let cacheInvalidationInterval: TimeInterval = 300  // 5 minutes

  /// Initialize a new agent repository
  public init() {
    self.parser = AgentParser()
  }

  /// Load all available agents from the embedded resources
  ///
  /// - Returns: Array of all agents, sorted by name
  /// - Throws: `AgentError` if resource loading fails
  public func loadAgents() async throws -> [Agent] {
    try await parser.loadAgents()
  }

  /// Get a specific agent by name
  ///
  /// - Parameter name: The agent name (e.g., "swift-architect")
  /// - Returns: The agent if found, nil otherwise
  /// - Throws: `AgentError` if resource loading fails
  public func getAgent(named name: String) async throws -> Agent? {
    try await parser.findAgent(byIdentifier: name)
  }

  /// Get agents filtered by tool
  ///
  /// - Parameter tool: The tool name to filter by (e.g., "Bash", "Read", "Edit")
  /// - Returns: Array of agents that use the specified tool
  /// - Throws: `AgentError` if resource loading fails
  public func getAgents(byTool tool: String) async throws -> [Agent] {
    try await parser.loadAgents().filter { $0.tools.contains(tool) }
  }

  /// Get agents filtered by model
  ///
  /// - Parameter model: The model name to filter by (e.g., "opus", "sonnet", "haiku")
  /// - Returns: Array of agents that use the specified model
  /// - Throws: `AgentError` if resource loading fails
  public func getAgents(byModel model: String) async throws -> [Agent] {
    try await parser.loadAgents().filter { $0.model?.lowercased() == model.lowercased() }
  }

  /// Get agents filtered by MCP server requirement
  ///
  /// - Parameter mcpServer: The MCP server name to filter by (e.g., "github", "gitlab")
  /// - Returns: Array of agents that require the specified MCP server
  /// - Throws: `AgentError` if resource loading fails
  public func getAgents(byMCPServer mcpServer: String) async throws -> [Agent] {
    try await parser.loadAgents().filter { $0.mcp.contains(mcpServer) }
  }

  /// Search agents by name or description
  ///
  /// - Parameter query: Search query string (case-insensitive)
  /// - Returns: Array of agents matching the query
  /// - Throws: `AgentError` if resource loading fails
  public func search(_ query: String) async throws -> [Agent] {
    let lowercaseQuery = query.lowercased()
    return try await parser.loadAgents().filter {
      $0.name.lowercased().contains(lowercaseQuery)
        || $0.description.lowercased().contains(lowercaseQuery)
    }
  }

  /// Get all unique tool names across all agents
  ///
  /// - Returns: Set of tool names
  /// - Throws: `AgentError` if resource loading fails
  public func getAllTools() async throws -> Set<String> {
    Set(try await parser.loadAgents().flatMap { $0.tools })
  }

  /// Get all unique model names across all agents
  ///
  /// - Returns: Set of model names (excluding nil values)
  /// - Throws: `AgentError` if resource loading fails
  public func getAllModels() async throws -> Set<String> {
    Set(try await parser.loadAgents().compactMap { $0.model })
  }

  /// Get all unique MCP server names across all agents
  ///
  /// - Returns: Set of MCP server names
  /// - Throws: `AgentError` if resource loading fails
  public func getAllMCPServers() async throws -> Set<String> {
    Set(try await parser.loadAgents().flatMap { $0.mcp })
  }

  /// Clear the internal cache (mainly useful for testing)
  public func clearCache() async {
    await parser.clearCache()
    installationCache.removeAll()
    cacheTimestamp = nil
  }

  // MARK: - Installation Status API

  /// Check if a specific agent is installed
  ///
  /// - Parameters:
  ///   - agentID: The agent identifier (name)
  ///   - scope: Installation scope to check (defaults to .all)
  /// - Returns: true if the agent is installed in the specified scope
  /// - Throws: `AgentError` if file system access fails
  public func isInstalled(agentID: String, scope: InstallationScope = .all) async throws -> Bool {
    let info = try await installationInfo(for: agentID, scope: scope)
    return info != nil
  }

  /// Get installation information for an agent
  ///
  /// - Parameters:
  ///   - agentID: The agent identifier (name)
  ///   - scope: Installation scope to check (defaults to .all)
  /// - Returns: Installation info if the agent is installed, nil otherwise
  /// - Throws: `AgentError` if file system access fails
  public func installationInfo(for agentID: String, scope: InstallationScope = .all) async throws
    -> InstallationInfo?
  {
    try refreshCacheIfNeeded()

    // Check each scope
    for checkScope in scope.directoryURLs() {
      if let scopeType = scopeTypeForURL(checkScope) {
        if let info = installationCache[scopeType]?[agentID] {
          return info
        }
      }
    }

    return nil
  }

  /// Get all installed agents
  ///
  /// - Parameter scope: Installation scope to check (defaults to .all)
  /// - Returns: Array of installed agents
  /// - Throws: `AgentError` if file system access fails
  public func installedAgents(scope: InstallationScope = .all) async throws -> [Agent] {
    try refreshCacheIfNeeded()

    var installedAgentNames = Set<String>()

    // Collect installed agent names from cache
    switch scope {
    case .global:
      if let keys = installationCache[.global]?.keys {
        installedAgentNames.formUnion(keys)
      }
    case .project:
      if let keys = installationCache[.project]?.keys {
        installedAgentNames.formUnion(keys)
      }
    case .all:
      if let keys = installationCache[.global]?.keys {
        installedAgentNames.formUnion(keys)
      }
      if let keys = installationCache[.project]?.keys {
        installedAgentNames.formUnion(keys)
      }
    }

    // Load all defined agents and filter by installed names
    let allAgents = try await loadAgents()
    return allAgents.filter { installedAgentNames.contains($0.name) }
  }

  /// Get agents that are defined but NOT installed
  ///
  /// - Parameter scope: Installation scope to check (defaults to .all)
  /// - Returns: Array of agents that are not installed
  /// - Throws: `AgentError` if file system access fails
  public func notInstalledAgents(scope: InstallationScope = .all) async throws -> [Agent] {
    try refreshCacheIfNeeded()

    var installedAgentNames = Set<String>()

    // Collect installed agent names from cache
    switch scope {
    case .global:
      if let keys = installationCache[.global]?.keys {
        installedAgentNames.formUnion(keys)
      }
    case .project:
      if let keys = installationCache[.project]?.keys {
        installedAgentNames.formUnion(keys)
      }
    case .all:
      if let keys = installationCache[.global]?.keys {
        installedAgentNames.formUnion(keys)
      }
      if let keys = installationCache[.project]?.keys {
        installedAgentNames.formUnion(keys)
      }
    }

    // Load all defined agents and filter out installed ones
    let allAgents = try await loadAgents()
    return allAgents.filter { !installedAgentNames.contains($0.name) }
  }

  // MARK: - Private Installation Helpers

  /// Refresh the installation cache if needed
  private func refreshCacheIfNeeded() throws {
    let now = Date()

    // Check if cache is still valid
    if let timestamp = cacheTimestamp,
      now.timeIntervalSince(timestamp) < cacheInvalidationInterval
    {
      return  // Cache is still valid
    }

    // Rebuild cache
    installationCache = [:]

    // Scan global directory
    if let globalDir = InstallationScope.global.directoryURL() {
      let globalAgents = try scanDirectory(globalDir, scope: .global)
      installationCache[.global] = globalAgents
    }

    // Scan project directory
    if let projectDir = InstallationScope.project.directoryURL() {
      let projectAgents = try scanDirectory(projectDir, scope: .project)
      installationCache[.project] = projectAgents
    }

    cacheTimestamp = now
  }

  /// Scan a directory for installed agents
  private func scanDirectory(_ directory: URL, scope: InstallationScope) throws -> [String:
    InstallationInfo]
  {
    let fileManager = FileManager.default

    // Check if directory exists
    guard fileManager.fileExists(atPath: directory.path) else {
      return [:]  // Directory doesn't exist, not an error
    }

    var installedAgents: [String: InstallationInfo] = [:]

    do {
      let files = try fileManager.contentsOfDirectory(
        at: directory,
        includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey],
        options: [.skipsHiddenFiles]
      )

      for file in files where file.pathExtension == "md" {
        do {
          if let info = try InstallationInfo.from(url: file, scope: scope) {
            installedAgents[info.agentName] = info
          }
        } catch {
          // Skip invalid agent files but continue scanning
          // This allows for non-agent markdown files in the directory
          continue
        }
      }
    } catch {
      // If we can't read the directory, return empty (permissions issue, etc.)
      return [:]
    }

    return installedAgents
  }

  /// Determine the scope type for a given URL
  private func scopeTypeForURL(_ url: URL) -> InstallationScope? {
    if url == InstallationScope.global.directoryURL() {
      return .global
    } else if url == InstallationScope.project.directoryURL() {
      return .project
    }
    return nil
  }
}
