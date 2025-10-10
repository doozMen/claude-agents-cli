import Foundation

/// Actor responsible for parsing and managing agent markdown files
public actor AgentParser {
  private var cachedAgents: [Agent]?

  public init() {}

  /// Load all agents from the bundle resources
  public func loadAgents() throws -> [Agent] {
    if let cached = cachedAgents {
      return cached
    }

    guard let agentsURL = Bundle.module.resourceURL?.appendingPathComponent("agents") else {
      throw AgentError.invalidFileFormat("Could not locate agents resource directory")
    }

    let fileManager = FileManager.default
    guard fileManager.fileExists(atPath: agentsURL.path) else {
      // Return empty array if no agents directory exists yet
      cachedAgents = []
      return []
    }

    let files = try fileManager.contentsOfDirectory(
      at: agentsURL,
      includingPropertiesForKeys: nil,
      options: [.skipsHiddenFiles]
    )

    let markdownFiles = files.filter { $0.pathExtension == "md" }

    var agents: [Agent] = []
    for file in markdownFiles {
      do {
        let agent = try Agent.parse(from: file)
        agents.append(agent)
      } catch {
        // Skip invalid agents but continue processing
        print("Warning: Failed to parse agent at \(file.path): \(error)")
      }
    }

    cachedAgents = agents.sorted { $0.name < $1.name }
    return cachedAgents!
  }

  /// Find an agent by its identifier (name or filename)
  public func findAgent(byIdentifier identifier: String) async throws -> Agent? {
    let agents = try loadAgents()

    // Try exact name match first
    if let agent = agents.first(where: { $0.name == identifier }) {
      return agent
    }

    // Try filename match (with or without .md extension)
    let normalizedIdentifier = identifier.hasSuffix(".md") ? identifier : "\(identifier).md"
    return agents.first(where: { $0.fileName == normalizedIdentifier })
  }

  /// Clear the agent cache (useful for testing)
  public func clearCache() {
    cachedAgents = nil
  }
}
