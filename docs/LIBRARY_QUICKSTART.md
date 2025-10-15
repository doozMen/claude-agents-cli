# ClaudeAgents Library - Quick Start

5-minute guide to using the ClaudeAgents library in your Swift project.

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/doozMen/swift-agents-plugin.git", from: "1.5.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "ClaudeAgents", package: "swift-agents-plugin")
        ]
    )
]
```

## Basic Usage

```swift
import ClaudeAgents

// Create repository
let repository = AgentRepository()

// Load all agents
let agents = try await repository.loadAgents()
print("Found \(agents.count) agents")

// Get specific agent
if let agent = try await repository.getAgent(named: "swift-architect") {
    print(agent.name)           // "swift-architect"
    print(agent.description)    // Brief description
    print(agent.tools)          // ["Read", "Edit", "Bash", ...]
    print(agent.model)          // "opus"
    print(agent.content)        // Full markdown content
}
```

## Common Operations

### Search Agents

```swift
// By keyword
let swiftAgents = try await repository.search("swift")

// By tool
let bashAgents = try await repository.getAgents(byTool: "Bash")

// By model
let haikuAgents = try await repository.getAgents(byModel: "haiku")

// By MCP server
let githubAgents = try await repository.getAgents(byMCPServer: "github")
```

### Agent Properties

```swift
struct Agent {
    let id: String              // Unique identifier
    let name: String            // "swift-architect"
    let description: String     // Brief description
    let tools: [String]         // ["Read", "Edit", "Bash"]
    let mcp: [String]           // ["github", "gitlab"]
    let model: String?          // "opus", "sonnet", "haiku"
    let dependencies: [String]  // Other agent dependencies
    let content: String         // Full markdown content
    let fileName: String        // "swift-architect.md"
}
```

## Use Cases

### MCP Server: Serve Agents as Resources

```swift
import ClaudeAgents
import MCP

@main
struct AgentMCPServer {
    static func main() async throws {
        let repository = AgentRepository()
        let server = MCPServer()
        
        // Register all agents as resources
        for agent in try await repository.loadAgents() {
            server.registerResource(
                uri: "agents://\(agent.name)",
                name: agent.name,
                mimeType: "text/markdown",
                content: agent.content
            )
        }
        
        try await server.run()
    }
}
```

### CLI Tool: Agent Selector

```swift
import ClaudeAgents

@main
struct AgentSelector {
    static func main() async throws {
        let repository = AgentRepository()
        
        print("Search agents:")
        guard let query = readLine() else { return }
        
        let results = try await repository.search(query)
        
        for agent in results {
            print("\(agent.name): \(agent.description)")
        }
    }
}
```

### Documentation Generator

```swift
import ClaudeAgents

func generateAgentDocs() async throws -> String {
    let repository = AgentRepository()
    let agents = try await repository.loadAgents()
    
    var markdown = "# Available Agents\n\n"
    
    for agent in agents {
        markdown += "## \(agent.name)\n"
        markdown += "\(agent.description)\n\n"
        markdown += "**Tools:** \(agent.tools.joined(separator: ", "))\n\n"
        if let model = agent.model {
            markdown += "**Model:** \(model)\n\n"
        }
    }
    
    return markdown
}
```

### Agent Router

```swift
import ClaudeAgents

func selectBestAgent(for task: String) async throws -> Agent? {
    let repository = AgentRepository()
    
    // Simple keyword matching
    let keywords = task.lowercased().components(separatedBy: .whitespaces)
    
    for keyword in keywords {
        let matches = try await repository.search(keyword)
        if let best = matches.first {
            return best
        }
    }
    
    return nil
}
```

## API Reference

### AgentRepository (Actor)

All methods are async and thread-safe:

| Method | Description |
|--------|-------------|
| `loadAgents()` | Get all 45 agents |
| `getAgent(named:)` | Get specific agent by name |
| `search(_:)` | Search by keyword |
| `getAgents(byTool:)` | Filter by tool |
| `getAgents(byModel:)` | Filter by model |
| `getAgents(byMCPServer:)` | Filter by MCP requirement |
| `getAllTools()` | Get all unique tools |
| `getAllModels()` | Get all unique models |
| `getAllMCPServers()` | Get all MCP servers |
| `clearCache()` | Clear internal cache |

## Available Tools

- `Read` - File reading
- `Edit` - File editing
- `Glob` - Pattern matching
- `Grep` - Content search
- `Bash` - Shell commands
- `MultiEdit` - Batch editing
- `Write` - File writing
- `WebSearch` - Web searching

## Available Models

- `opus` - Complex reasoning (1 agent)
- `sonnet` - Balanced (30 agents)
- `haiku` - Fast, efficient (12 agents)

## Common MCP Servers

- `github` - GitHub integration
- `gitlab` - GitLab integration
- `azure` - Azure DevOps
- `postgres` - PostgreSQL
- `sqlite` - SQLite

## Error Handling

```swift
do {
    let agents = try await repository.loadAgents()
    // Use agents
} catch let error as AgentError {
    switch error {
    case .invalidFileFormat(let msg):
        print("Format error: \(msg)")
    case .invalidFrontmatter(let path):
        print("Invalid frontmatter: \(path)")
    case .missingRequiredField(let field):
        print("Missing field: \(field)")
    }
} catch {
    print("Unknown error: \(error)")
}
```

## Performance

- **First load:** ~10-20ms (parses from bundle)
- **Cached loads:** <1ms (returns cached data)
- **Memory:** ~2-3 MB for all 45 agents
- **Thread-safe:** Actor-based, safe concurrent access

## Testing

```swift
import Testing
import ClaudeAgents

@Test
func testAgentLoading() async throws {
    let repository = AgentRepository()
    let agents = try await repository.loadAgents()
    
    #expect(agents.count > 0)
    #expect(agents.allSatisfy { !$0.name.isEmpty })
}

@Test
func testSpecificAgent() async throws {
    let repository = AgentRepository()
    let agent = try await repository.getAgent(named: "swift-architect")
    
    #expect(agent != nil)
    #expect(agent?.tools.contains("Read") == true)
}
```

## Migration from CLI Subprocess

**Before:**
```swift
let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/local/bin/claude-agents")
process.arguments = ["list"]
// ... setup pipes, parse output
```

**After:**
```swift
let repository = AgentRepository()
let agents = try await repository.loadAgents()
```

## Complete Example

```swift
import ClaudeAgents
import Foundation

@main
struct AgentExplorer {
    static func main() async throws {
        let repository = AgentRepository()
        
        // Load and display all agents
        print("Loading agents...")
        let agents = try await repository.loadAgents()
        print("Found \(agents.count) agents\n")
        
        // Show agents by model
        let models = try await repository.getAllModels()
        for model in models.sorted() {
            let modelAgents = try await repository.getAgents(byModel: model)
            print("\(model.uppercased()): \(modelAgents.count) agents")
            for agent in modelAgents.prefix(3) {
                print("  - \(agent.name)")
            }
        }
        
        // Search example
        print("\nSearch for 'swift':")
        let swiftAgents = try await repository.search("swift")
        for agent in swiftAgents.prefix(5) {
            print("  \(agent.name): \(agent.description)")
        }
        
        // Get specific agent
        if let architect = try await repository.getAgent(named: "swift-architect") {
            print("\nSwift Architect Details:")
            print("  Description: \(architect.description)")
            print("  Tools: \(architect.tools.joined(separator: ", "))")
            print("  Content preview: \(architect.content.prefix(200))...")
        }
    }
}
```

## Next Steps

- **Full Documentation:** [LIBRARY_USAGE.md](LIBRARY_USAGE.md)
- **Agent Catalog:** [AGENTS.md](AGENTS.md)
- **CLI Tool:** [README.md](../README.md)

## Requirements

- Swift 6.1+
- macOS 13.0+
- No external dependencies (library is self-contained)

## Support

- **GitHub Issues:** https://github.com/doozMen/swift-agents-plugin/issues
- **Full Docs:** https://github.com/doozMen/swift-agents-plugin/tree/main/docs
