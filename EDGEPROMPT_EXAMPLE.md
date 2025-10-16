# Using ClaudeAgents in EdgePrompt MCP Server

This example shows how to integrate the ClaudeAgents library into the edgeprompt MCP server to serve agent markdown files as prompts.

## Package.swift

```swift
// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "edgeprompt",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/doozMen/swift-agents-plugin.git", from: "1.5.0"),
        .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", from: "0.1.0")
    ],
    targets: [
        .executableTarget(
            name: "edgeprompt",
            dependencies: [
                .product(name: "ClaudeAgents", package: "swift-agents-plugin"),
                .product(name: "MCP", package: "swift-sdk")
            ]
        )
    ]
)
```

## PromptsService.swift

```swift
import ClaudeAgents
import Foundation

/// Service for managing and serving agent prompts
actor PromptsService {
    private let repository = AgentRepository()
    
    /// Get all available prompts
    func listPrompts() async throws -> [PromptInfo] {
        let agents = try await repository.loadAgents()
        return agents.map { agent in
            PromptInfo(
                name: agent.name,
                description: agent.description,
                arguments: []  // Agents don't take arguments
            )
        }
    }
    
    /// Get a specific prompt by name
    func getPrompt(named name: String) async throws -> String? {
        guard let agent = try await repository.getAgent(named: name) else {
            return nil
        }
        return agent.content
    }
    
    /// Search prompts by query
    func searchPrompts(_ query: String) async throws -> [PromptInfo] {
        let agents = try await repository.search(query)
        return agents.map { agent in
            PromptInfo(
                name: agent.name,
                description: agent.description,
                arguments: []
            )
        }
    }
    
    /// Get prompts by tool capability
    func getPromptsByTool(_ tool: String) async throws -> [PromptInfo] {
        let agents = try await repository.getAgents(byTool: tool)
        return agents.map { agent in
            PromptInfo(
                name: agent.name,
                description: agent.description,
                arguments: []
            )
        }
    }
    
    /// Get prompts by model
    func getPromptsByModel(_ model: String) async throws -> [PromptInfo] {
        let agents = try await repository.getAgents(byModel: model)
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

## MCP Server Implementation

```swift
import ClaudeAgents
import MCP

@main
struct EdgePromptServer {
    static func main() async throws {
        let service = PromptsService()
        let server = MCPServer(name: "edgeprompt", version: "1.0.0")
        
        // Register prompts/list handler
        server.addPromptsListHandler { _ in
            try await service.listPrompts()
        }
        
        // Register prompts/get handler
        server.addPromptsGetHandler { request in
            guard let content = try await service.getPrompt(named: request.name) else {
                throw MCPError.promptNotFound(request.name)
            }
            
            return PromptResponse(
                messages: [
                    PromptMessage(
                        role: .user,
                        content: .text(content)
                    )
                ]
            )
        }
        
        // Start server
        try await server.start()
    }
}
```

## Example MCP Session

```json
// Request: prompts/list
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "prompts/list",
  "params": {}
}

// Response
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "prompts": [
      {
        "name": "swift-architect",
        "description": "Specialized in Swift 6.0 architecture patterns, async/await, actors, and modern iOS development"
      },
      {
        "name": "swift-developer",
        "description": "Expert iOS developer specializing in Swift, UIKit, SwiftUI, and modern app architecture"
      },
      // ... 43 more agents
    ]
  }
}

// Request: prompts/get
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "prompts/get",
  "params": {
    "name": "swift-architect"
  }
}

// Response
{
  "jsonrpc": "2.0",
  "id": 2,
  "result": {
    "messages": [
      {
        "role": "user",
        "content": {
          "type": "text",
          "text": "---\nname: swift-architect\ndescription: Specialized in Swift 6.0 architecture patterns...\n---\n\n# Swift Architect\n\n..."
        }
      }
    ]
  }
}
```

## Benefits

1. **No File I/O**: Agents embedded in library, no need to read files
2. **Type Safety**: Swift types for all agent metadata
3. **Caching**: Built-in caching for performance
4. **Query Support**: Filter by tools, models, search by keywords
5. **Thread Safe**: Actor-based repository safe for concurrent access
6. **Version Control**: Pin library version for stable agent content

## Advanced Features

### Recommend Agents by Project Type

```swift
func recommendAgents(for projectType: String) async throws -> [PromptInfo] {
    let agents = try await repository.search(projectType)
    return agents
        .sorted { $0.name < $1.name }
        .map { agent in
            PromptInfo(
                name: agent.name,
                description: agent.description,
                arguments: []
            )
        }
}
```

### Get Agent Dependencies

```swift
func checkAgentDependencies(for agentName: String) async throws -> [String] {
    guard let agent = try await repository.getAgent(named: agentName) else {
        return []
    }
    return agent.dependencies
}
```

### Filter by Multiple Criteria

```swift
func getSwiftAgentsUsingBash() async throws -> [Agent] {
    let agents = try await repository.loadAgents()
    return agents.filter { agent in
        agent.name.lowercased().contains("swift") &&
        agent.tools.contains("Bash")
    }
}
```

## Testing

```swift
import Testing
import ClaudeAgents

@Test func testPromptsService() async throws {
    let service = PromptsService()
    
    // Test listing prompts
    let prompts = try await service.listPrompts()
    #expect(prompts.count == 45)
    
    // Test getting specific prompt
    let content = try await service.getPrompt(named: "swift-architect")
    #expect(content != nil)
    #expect(content!.contains("swift-architect"))
    
    // Test search
    let swiftPrompts = try await service.searchPrompts("Swift")
    #expect(swiftPrompts.count > 0)
}
```

## Deployment

```bash
# Build release binary
swift build -c release

# Install MCP server
cp .build/release/edgeprompt ~/.local/bin/

# Configure in Claude Desktop
# ~/.config/claude/mcp.json
{
  "mcpServers": {
    "edgeprompt": {
      "command": "edgeprompt",
      "env": {
        "PATH": "/usr/local/bin:/usr/bin:/bin"
      }
    }
  }
}
```

## Performance

- **Startup**: <100ms (agents cached on first load)
- **List**: <1ms (returns cached data)
- **Get**: <1ms (returns cached data)
- **Memory**: ~500KB for all 45 agents

## Updates

To update agents:
1. Update swift-agents-plugin dependency version in Package.swift
2. Rebuild: `swift build`
3. Restart MCP server

```swift
.package(url: "https://github.com/doozMen/swift-agents-plugin.git", from: "1.6.0")
```

New agents automatically available after restart!
