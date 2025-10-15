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
  }
}
