import Foundation

/// Represents a Claude agent with its metadata and content
public struct Agent: Sendable, Identifiable, Hashable {
  public let id: String
  public let name: String
  public let description: String
  public let tools: [String]
  public let mcp: [String]
  public let model: String?
  public let dependencies: [String]
  public let content: String
  public let fileName: String

  public init(
    id: String,
    name: String,
    description: String,
    tools: [String],
    mcp: [String],
    model: String?,
    dependencies: [String],
    content: String,
    fileName: String
  ) {
    self.id = id
    self.name = name
    self.description = description
    self.tools = tools
    self.mcp = mcp
    self.model = model
    self.dependencies = dependencies
    self.content = content
    self.fileName = fileName
  }

  /// Parse an agent from a markdown file
  public static func parse(from url: URL) throws -> Agent {
    let content = try String(contentsOf: url, encoding: .utf8)
    let fileName = url.lastPathComponent

    // Extract frontmatter
    guard let frontmatter = extractFrontmatter(from: content) else {
      throw AgentError.invalidFrontmatter(url.path)
    }

    // Parse required fields
    guard let name = frontmatter["name"] else {
      throw AgentError.missingRequiredField("name")
    }

    guard let description = frontmatter["description"] else {
      throw AgentError.missingRequiredField("description")
    }

    // Parse tools (comma-separated list)
    let toolsString = frontmatter["tools"] ?? ""
    let tools = toolsString.split(separator: ",")
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .filter { !$0.isEmpty }

    // Parse MCP servers (comma-separated list, optional)
    let mcpString = frontmatter["mcp"] ?? ""
    let mcp = mcpString.split(separator: ",")
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .filter { !$0.isEmpty }

    let model = frontmatter["model"]

    // Parse dependencies (comma-separated list, optional)
    let dependenciesString = frontmatter["dependencies"] ?? ""
    let dependencies = dependenciesString.split(separator: ",")
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .filter { !$0.isEmpty }

    // Use name as ID (can be customized if needed)
    let id = name

    return Agent(
      id: id,
      name: name,
      description: description,
      tools: tools,
      mcp: mcp,
      model: model,
      dependencies: dependencies,
      content: content,
      fileName: fileName
    )
  }

  /// Extract YAML frontmatter from markdown content
  private static func extractFrontmatter(from content: String) -> [String: String]? {
    let lines = content.components(separatedBy: .newlines)

    // Check for frontmatter delimiters (---)
    guard lines.count > 2,
      lines[0].trimmingCharacters(in: .whitespaces) == "---"
    else {
      return nil
    }

    // Find closing delimiter
    guard
      let endIndex = lines.dropFirst().firstIndex(where: {
        $0.trimmingCharacters(in: .whitespaces) == "---"
      })
    else {
      return nil
    }

    // Parse key-value pairs
    var metadata: [String: String] = [:]
    for line in lines[1..<endIndex] {
      let trimmed = line.trimmingCharacters(in: .whitespaces)
      guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else { continue }

      // Split on first colon
      if let colonIndex = trimmed.firstIndex(of: ":") {
        let key = String(trimmed[..<colonIndex]).trimmingCharacters(in: .whitespaces)
        let value = String(trimmed[trimmed.index(after: colonIndex)...])
          .trimmingCharacters(in: .whitespaces)

        // Skip empty values
        guard !value.isEmpty else { continue }

        metadata[key] = value
      }
    }

    return metadata.isEmpty ? nil : metadata
  }
}
