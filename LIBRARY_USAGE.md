# ClaudeAgents Library

The `ClaudeAgents` library provides programmatic access to all 45 Claude agent markdown files included in the swift-agents-plugin package. This allows Swift applications to dynamically load, query, and access agent content at runtime.

## Installation

Add the package dependency to your `Package.swift`:

```swift
// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "YourProject",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/stijnwillems/swift-agents-plugin.git", from: "1.5.0")
    ],
    targets: [
        .executableTarget(
            name: "YourProject",
            dependencies: [
                .product(name: "ClaudeAgents", package: "swift-agents-plugin")
            ]
        )
    ]
)
```

Or for local development:

```swift
.package(path: "/path/to/swift-agents-plugin")
```

## Usage

### Basic Usage

```swift
import ClaudeAgents

let repository = AgentRepository()

// Load all agents
let agents = try await repository.loadAgents()
print("Found \(agents.count) agents")

// Get specific agent
if let agent = try await repository.getAgent(named: "swift-architect") {
    print(agent.name)
    print(agent.description)
    print(agent.content)  // Full markdown content
}
```

### Agent Model

Each `Agent` contains:

```swift
public struct Agent: Sendable, Identifiable, Hashable {
    public let id: String              // Unique identifier (same as name)
    public let name: String             // Agent name (e.g., "swift-architect")
    public let description: String      // Brief description
    public let tools: [String]          // Required tools (Read, Edit, Bash, etc.)
    public let mcp: [String]            // MCP servers (github, gitlab, etc.)
    public let model: String?           // Claude model (opus, sonnet, haiku)
    public let dependencies: [String]   // CLI dependencies (glab, gh, etc.)
    public let content: String          // Full markdown content
    public let fileName: String         // Original filename
}
```

### Query Operations

#### Filter by Tool

```swift
// Find all agents that use the Bash tool
let bashAgents = try await repository.getAgents(byTool: "Bash")
```

#### Filter by Model

```swift
// Find all Haiku-powered agents (lightweight, fast operations)
let haikuAgents = try await repository.getAgents(byModel: "haiku")

// Find all Opus-powered agents (advanced reasoning)
let opusAgents = try await repository.getAgents(byModel: "opus")
```

#### Filter by MCP Server

```swift
// Find agents that require GitHub MCP server
let githubAgents = try await repository.getAgents(byMCPServer: "github")
```

#### Search by Name or Description

```swift
// Search for Swift-related agents
let swiftAgents = try await repository.search("Swift")

// Search for testing agents
let testingAgents = try await repository.search("testing")
```

### Metadata Queries

```swift
// Get all unique tools used across agents
let tools = try await repository.getAllTools()
// Returns: Set(["Read", "Edit", "Bash", "Glob", "Grep", ...])

// Get all models used
let models = try await repository.getAllModels()
// Returns: Set(["opus", "sonnet", "haiku"])

// Get all MCP servers referenced
let mcpServers = try await repository.getAllMCPServers()
// Returns: Set(["github", "gitlab", "azure", ...])
```

## Use Cases

### 1. MCP Server Implementation

The `edgeprompt` MCP server uses this library to serve agent prompts dynamically:

```swift
import ClaudeAgents

actor PromptsService {
    private let repository = AgentRepository()
    
    func getPrompt(named name: String) async throws -> String? {
        guard let agent = try await repository.getAgent(named: name) else {
            return nil
        }
        return agent.content
    }
    
    func listPrompts() async throws -> [PromptInfo] {
        let agents = try await repository.loadAgents()
        return agents.map { agent in
            PromptInfo(
                name: agent.name,
                description: agent.description,
                arguments: []
            )
        }
    }
}
```

### 2. Agent Selection Tool

Build a CLI tool that recommends agents based on project context:

```swift
import ClaudeAgents

func recommendAgents(for technologies: [String]) async throws -> [Agent] {
    let repository = AgentRepository()
    let allAgents = try await repository.loadAgents()
    
    return allAgents.filter { agent in
        technologies.contains { tech in
            agent.name.lowercased().contains(tech.lowercased()) ||
            agent.description.lowercased().contains(tech.lowercased())
        }
    }
}

// Usage
let swiftAgents = try await recommendAgents(for: ["Swift", "iOS"])
for agent in swiftAgents {
    print("- \(agent.name): \(agent.description)")
}
```

### 3. Documentation Generator

Generate agent catalog documentation:

```swift
import ClaudeAgents

func generateAgentCatalog() async throws -> String {
    let repository = AgentRepository()
    let agents = try await repository.loadAgents()
    
    var markdown = "# Agent Catalog\n\n"
    
    for agent in agents {
        markdown += "## \(agent.name)\n\n"
        markdown += "\(agent.description)\n\n"
        markdown += "- **Tools**: \(agent.tools.joined(separator: ", "))\n"
        if let model = agent.model {
            markdown += "- **Model**: \(model)\n"
        }
        markdown += "\n---\n\n"
    }
    
    return markdown
}
```

### 4. Agent Dependency Checker

Validate that required CLI tools are installed:

```swift
import ClaudeAgents
import Foundation

func checkAgentDependencies(agentName: String) async throws {
    let repository = AgentRepository()
    
    guard let agent = try await repository.getAgent(named: agentName) else {
        print("Agent not found")
        return
    }
    
    print("Checking dependencies for \(agent.name)...")
    
    for dependency in agent.dependencies {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = [dependency]
        
        do {
            try process.run()
            process.waitUntilExit()
            
            if process.terminationStatus == 0 {
                print("✅ \(dependency) installed")
            } else {
                print("❌ \(dependency) not found")
            }
        } catch {
            print("❌ \(dependency) not found")
        }
    }
}
```

## API Reference

### AgentRepository

Thread-safe actor for accessing agent data.

#### Methods

```swift
// Load all agents
func loadAgents() async throws -> [Agent]

// Get specific agent
func getAgent(named name: String) async throws -> Agent?

// Filter by tool
func getAgents(byTool tool: String) async throws -> [Agent]

// Filter by model
func getAgents(byModel model: String) async throws -> [Agent]

// Filter by MCP server
func getAgents(byMCPServer mcpServer: String) async throws -> [Agent]

// Search by query
func search(_ query: String) async throws -> [Agent]

// Get unique tools
func getAllTools() async throws -> Set<String>

// Get unique models
func getAllModels() async throws -> Set<String>

// Get unique MCP servers
func getAllMCPServers() async throws -> Set<String>

// Clear cache (mainly for testing)
func clearCache() async
```

### Agent

Immutable struct representing an agent. Conforms to `Sendable`, `Identifiable`, and `Hashable`.

### AgentError

```swift
public enum AgentError: Error {
    case invalidFrontmatter(String)
    case missingRequiredField(String)
    case fileNotFound(URL)
    case invalidFileFormat(String)
}
```

## Performance Considerations

- **Caching**: Agent data is cached after first load for performance
- **Thread Safety**: `AgentRepository` is an actor, safe for concurrent access
- **Memory**: All 45 agents loaded into memory (~500KB total)
- **Async/Await**: All operations are async to avoid blocking

## Example Project

See `/tmp/test-claude-agents/` for a complete working example.

## Requirements

- Swift 6.1+
- macOS 13.0+
- Xcode 15.0+

## Related

- **CLI Tool**: Use `claude-agents` CLI for agent installation and management
- **Agent Files**: 45 production-ready agents included in Resources
- **Agent Format**: YAML frontmatter + Markdown content

## Contributing

To add new agents:
1. Create `.md` file in `Sources/ClaudeAgents/Resources/agents/`
2. Include required frontmatter (name, description, tools)
3. Rebuild package
4. New agents automatically available via library

## License

Same as swift-agents-plugin package.
