# ClaudeAgents Library Usage Guide

The `ClaudeAgents` library provides programmatic access to all 45+ Claude agent markdown files without subprocess calls or file system access.

## Installation

Add the library as a dependency in your `Package.swift`:

```swift
// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "YourPackage",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/stijnwillems/swift-agents-plugin.git", from: "1.5.0")
    ],
    targets: [
        .executableTarget(
            name: "YourTarget",
            dependencies: [
                .product(name: "ClaudeAgents", package: "swift-agents-plugin")
            ]
        )
    ]
)
```

## Quick Start

```swift
import ClaudeAgents
import Foundation

@main
struct Example {
    static func main() async throws {
        let repository = AgentRepository()
        
        // Load all agents
        let agents = try await repository.loadAgents()
        print("Found \(agents.count) agents")
        
        // Get specific agent by name
        if let architect = try await repository.getAgent(named: "swift-architect") {
            print("Agent: \(architect.name)")
            print("Description: \(architect.description)")
            print("Full content:\n\(architect.content)")
        }
    }
}
```

## API Reference

### AgentRepository

The main entry point for accessing agents. All methods are `async` since the repository is an actor.

#### Initialize

```swift
let repository = AgentRepository()
```

#### Load All Agents

```swift
func loadAgents() async throws -> [Agent]
```

Returns all available agents, sorted by name. Results are cached internally.

**Example:**
```swift
let agents = try await repository.loadAgents()
for agent in agents {
    print(agent.name)
}
```

#### Get Agent by Name

```swift
func getAgent(named name: String) async throws -> Agent?
```

Retrieves a specific agent by name or filename.

**Example:**
```swift
if let agent = try await repository.getAgent(named: "swift-architect") {
    print(agent.content)
}
```

#### Filter by Tool

```swift
func getAgents(byTool tool: String) async throws -> [Agent]
```

Returns all agents that use the specified tool (case-insensitive).

**Example:**
```swift
let bashAgents = try await repository.getAgents(byTool: "Bash")
print("Found \(bashAgents.count) agents using Bash")
```

Available tools: `Read`, `Edit`, `Glob`, `Grep`, `Bash`, `MultiEdit`, `Write`, `WebSearch`

#### Filter by Model

```swift
func getAgents(byModel model: String) async throws -> [Agent]
```

Returns all agents that use the specified Claude model (case-insensitive).

**Example:**
```swift
let haikuAgents = try await repository.getAgents(byModel: "haiku")
for agent in haikuAgents {
    print("\(agent.name) - \(agent.description)")
}
```

Available models: `opus`, `sonnet`, `haiku`

#### Filter by MCP Server

```swift
func getAgents(byMCPServer mcpServer: String) async throws -> [Agent]
```

Returns all agents that require the specified MCP server.

**Example:**
```swift
let githubAgents = try await repository.getAgents(byMCPServer: "github")
```

Common MCP servers: `github`, `gitlab`, `azure`, `postgres`, `sqlite`

#### Search

```swift
func search(_ query: String) async throws -> [Agent]
```

Searches agent names and descriptions for the query string (case-insensitive).

**Example:**
```swift
let results = try await repository.search("swift")
for agent in results {
    print("\(agent.name): \(agent.description)")
}
```

#### Get All Tools

```swift
func getAllTools() async throws -> Set<String>
```

Returns all unique tool names used across all agents.

**Example:**
```swift
let tools = try await repository.getAllTools()
print("Available tools: \(tools.sorted().joined(separator: ", "))")
```

#### Get All Models

```swift
func getAllModels() async throws -> Set<String>
```

Returns all unique model names used across all agents.

**Example:**
```swift
let models = try await repository.getAllModels()
print("Available models: \(models.sorted().joined(separator: ", "))")
```

#### Get All MCP Servers

```swift
func getAllMCPServers() async throws -> Set<String>
```

Returns all unique MCP server names required across all agents.

**Example:**
```swift
let servers = try await repository.getAllMCPServers()
print("MCP servers: \(servers.sorted().joined(separator: ", "))")
```

#### Clear Cache

```swift
func clearCache() async
```

Clears the internal agent cache. Mainly useful for testing or dynamic reloading.

**Example:**
```swift
await repository.clearCache()
let freshAgents = try await repository.loadAgents()
```

### Installation Status API

The library can detect which agents are installed on the system versus which are only defined in the bundle resources.

#### Check Installation Status

```swift
func isInstalled(agentID: String, scope: InstallationScope = .all) async throws -> Bool
```

Checks if an agent is installed in the specified scope.

**Example:**
```swift
let isInstalled = try await repository.isInstalled(
    agentID: "swift-architect",
    scope: .global
)
if isInstalled {
    print("swift-architect is installed globally")
}
```

#### Get Installation Information

```swift
func installationInfo(for agentID: String, scope: InstallationScope = .all) async throws -> InstallationInfo?
```

Returns detailed information about an installed agent.

**Example:**
```swift
if let info = try await repository.installationInfo(for: "swift-architect") {
    print("Installed at: \(info.location)")
    print("Scope: \(info.scope)")
    print("Installed: \(info.installedAt)")
    print("Size: \(info.fileSize) bytes")
}
```

#### Get Installed Agents

```swift
func installedAgents(scope: InstallationScope = .all) async throws -> [Agent]
```

Returns all agents that are currently installed.

**Example:**
```swift
let installed = try await repository.installedAgents(scope: .global)
print("\(installed.count) agents installed globally:")
for agent in installed {
    print("  - \(agent.name): \(agent.description)")
}
```

#### Get Not Installed Agents

```swift
func notInstalledAgents(scope: InstallationScope = .all) async throws -> [Agent]
```

Returns agents that are defined but not yet installed.

**Example:**
```swift
let notInstalled = try await repository.notInstalledAgents()
if !notInstalled.isEmpty {
    print("Agents available for installation:")
    for agent in notInstalled {
        print("  - \(agent.name)")
    }

    let names = notInstalled.map { $0.name }.joined(separator: " ")
    print("\nInstall all: claude-agents install \(names) --global")
}
```

### InstallationScope

Represents where agents can be installed:

```swift
public enum InstallationScope: String, Sendable, CaseIterable {
    case global   // ~/.claude/agents/
    case project  // ./.claude/agents/ (relative to current directory)
    case all      // Both global and project
}
```

**Example:**
```swift
// Check different scopes
let globalDir = InstallationScope.global.directoryURL()
let projectDir = InstallationScope.project.directoryURL()

// Get all installation directories
let allDirs = InstallationScope.all.directoryURLs()
```

### InstallationInfo

Detailed information about an installed agent:

```swift
public struct InstallationInfo: Sendable, Codable {
    public let location: URL          // File path
    public let scope: InstallationScope
    public let installedAt: Date      // File modification date
    public let fileSize: Int64        // Bytes
    public let version: String?       // If available in frontmatter
    public let agentName: String
}
```

### Agent Model

The `Agent` struct represents a parsed agent markdown file:

```swift
public struct Agent: Sendable, Identifiable, Hashable {
    public let id: String           // Unique identifier (same as name)
    public let name: String          // Agent name (e.g., "swift-architect")
    public let description: String   // Brief description
    public let tools: [String]       // Required tools
    public let mcp: [String]         // Required MCP servers
    public let model: String?        // Preferred Claude model
    public let dependencies: [String] // Agent dependencies
    public let content: String       // Full markdown content
    public let fileName: String      // Original filename
}
```

#### Parse from File

```swift
static func parse(from url: URL) throws -> Agent
```

Parses an agent from a markdown file. Useful if you need to load agents from custom locations.

**Example:**
```swift
let url = URL(fileURLWithPath: "/path/to/custom-agent.md")
let agent = try Agent.parse(from: url)
```

### Error Handling

The library throws `AgentError` for various failure scenarios:

```swift
public enum AgentError: Error, Sendable {
    case invalidFileFormat(String)
    case invalidFrontmatter(String)
    case missingRequiredField(String)
}
```

**Example:**
```swift
do {
    let agents = try await repository.loadAgents()
} catch let error as AgentError {
    print("Agent error: \(error)")
} catch {
    print("Unknown error: \(error)")
}
```

## Complete Example: Installation Status Checker

```swift
import ClaudeAgents
import Foundation

@main
struct InstallationChecker {
    static func main() async throws {
        let repository = AgentRepository()

        print("🔍 Claude Agents Installation Status")
        print("=====================================\n")

        // Check global installations
        let globalInstalled = try await repository.installedAgents(scope: .global)
        print("📂 Global (~/.claude/agents/):")
        print("  Installed: \(globalInstalled.count) agents")

        // Check project installations
        let projectInstalled = try await repository.installedAgents(scope: .project)
        print("\n📂 Project (./.claude/agents/):")
        print("  Installed: \(projectInstalled.count) agents")

        // Show not installed agents
        let notInstalled = try await repository.notInstalledAgents(scope: .all)
        print("\n⚠️  Available but not installed:")
        print("  \(notInstalled.count) agents")

        if !notInstalled.isEmpty {
            print("\n📦 To install missing agents:")
            let names = notInstalled.prefix(5).map { $0.name }.joined(separator: " ")
            print("  claude-agents install \(names) --global")

            if notInstalled.count > 5 {
                print("  ... and \(notInstalled.count - 5) more")
            }
        }

        // Show detailed info for a specific agent
        if let info = try await repository.installationInfo(for: "swift-architect") {
            print("\n📋 swift-architect details:")
            print("  Location: \(info.location.path)")
            print("  Scope: \(info.scope)")
            print("  Installed: \(info.installedAt)")
            print("  Size: \(info.fileSize) bytes")
        }
    }
}
```

## Complete Example: Agent Selector Tool

```swift
import ClaudeAgents
import Foundation

@main
struct AgentSelector {
    static func main() async throws {
        let repository = AgentRepository()

        print("🤖 Claude Agent Selector")
        print("=======================\n")
        
        // Get user's task category
        print("What are you working on?")
        print("1. Swift development")
        print("2. Testing")
        print("3. Documentation")
        print("4. Git/PR workflows")
        print("5. Firebase/Analytics")
        
        guard let choice = readLine(), let option = Int(choice) else {
            print("Invalid choice")
            return
        }
        
        // Find relevant agents based on choice
        let relevantAgents: [Agent]
        switch option {
        case 1:
            relevantAgents = try await repository.search("swift")
        case 2:
            relevantAgents = try await repository.search("test")
        case 3:
            relevantAgents = try await repository.search("documentation")
        case 4:
            relevantAgents = try await repository.search("git")
        case 5:
            relevantAgents = try await repository.search("firebase")
        default:
            print("Invalid option")
            return
        }
        
        // Display results
        print("\nRelevant agents (\(relevantAgents.count)):")
        print("------------------------------------------")
        for agent in relevantAgents {
            print("\n[\(agent.name)]")
            print("  \(agent.description)")
            print("  Tools: \(agent.tools.joined(separator: ", "))")
            if let model = agent.model {
                print("  Model: \(model)")
            }
        }
        
        // Show installation command
        if !relevantAgents.isEmpty {
            let agentNames = relevantAgents.map { $0.name }.joined(separator: " ")
            print("\n💡 Install these agents:")
            print("claude-agents install \(agentNames) --global")
        }
    }
}
```

## Advanced Use Cases

### Building Agent Routing Logic

```swift
func selectAgentForTask(_ task: String) async throws -> Agent? {
    let repository = AgentRepository()
    
    // Use local LLM to analyze task and route to best agent
    let keywords = extractKeywords(from: task)
    
    for keyword in keywords {
        let matches = try await repository.search(keyword)
        if !matches.isEmpty {
            return matches.first
        }
    }
    
    return nil
}
```

### Dependency Resolution

```swift
func resolveAgentDependencies(_ agentName: String) async throws -> [Agent] {
    let repository = AgentRepository()
    
    guard let agent = try await repository.getAgent(named: agentName) else {
        throw AgentError.invalidFileFormat("Agent not found: \(agentName)")
    }
    
    var resolved: [Agent] = [agent]
    
    for dependency in agent.dependencies {
        if let depAgent = try await repository.getAgent(named: dependency) {
            resolved.append(depAgent)
        }
    }
    
    return resolved
}
```

### MCP Server Validation

```swift
func validateMCPRequirements(_ agentName: String, available: Set<String>) async throws -> Bool {
    let repository = AgentRepository()
    
    guard let agent = try await repository.getAgent(named: agentName) else {
        return false
    }
    
    let required = Set(agent.mcp)
    return required.isSubset(of: available)
}
```

### Content Generation

```swift
func generateAgentInstallationScript(_ agentNames: [String]) async throws -> String {
    let repository = AgentRepository()
    var script = "#!/bin/bash\n\n"
    
    for name in agentNames {
        if let agent = try await repository.getAgent(named: name) {
            script += "# \(agent.description)\n"
            script += "claude-agents install \(agent.name) --global\n\n"
        }
    }
    
    return script
}
```

## Thread Safety

`AgentRepository` is an actor, making it thread-safe by default. All async methods are automatically serialized:

```swift
let repository = AgentRepository()

// These calls are safe to run concurrently
async let agents1 = repository.loadAgents()
async let agents2 = repository.loadAgents()  // Will use cached result
async let architect = repository.getAgent(named: "swift-architect")

let results = try await (agents1, agents2, architect)
```

## Performance Considerations

### Caching

The repository caches loaded agents after the first `loadAgents()` call. Subsequent calls return cached results instantly:

```swift
// First call: reads from disk
let agents1 = try await repository.loadAgents()  // ~10-20ms

// Subsequent calls: returns cached data
let agents2 = try await repository.loadAgents()  // <1ms
```

### Resource Bundling

All agent markdown files are embedded in the compiled binary as Bundle resources. No file system access or network requests are required at runtime.

## Testing

The library is designed for easy testing:

```swift
import Testing
import ClaudeAgents

@Test
func testAgentLoading() async throws {
    let repository = AgentRepository()
    let agents = try await repository.loadAgents()
    
    #expect(agents.count > 0)
    #expect(agents.allSatisfy { !$0.name.isEmpty })
    #expect(agents.allSatisfy { !$0.description.isEmpty })
}

@Test
func testAgentRetrieval() async throws {
    let repository = AgentRepository()
    
    let architect = try await repository.getAgent(named: "swift-architect")
    #expect(architect != nil)
    #expect(architect?.name == "swift-architect")
    #expect(architect?.tools.contains("Read") == true)
}

@Test
func testFiltering() async throws {
    let repository = AgentRepository()
    
    let bashAgents = try await repository.getAgents(byTool: "Bash")
    #expect(bashAgents.allSatisfy { $0.tools.contains("Bash") })
    
    let haikuAgents = try await repository.getAgents(byModel: "haiku")
    #expect(haikuAgents.allSatisfy { $0.model?.lowercased() == "haiku" })
}
```

## Migration from CLI Subprocess

### Before (subprocess approach):

```swift
let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/local/bin/claude-agents")
process.arguments = ["list", "--verbose"]

let pipe = Pipe()
process.standardOutput = pipe

try process.run()
process.waitUntilExit()

let data = pipe.fileHandleForReading.readDataToEndOfFile()
let output = String(data: data, encoding: .utf8)
// Parse output...
```

### After (library approach):

```swift
let repository = AgentRepository()
let agents = try await repository.loadAgents()

for agent in agents {
    print("\(agent.name): \(agent.description)")
}
```

## Troubleshooting

### "Could not locate agents resource directory"

This error means the Bundle resources aren't properly configured. Ensure:

1. You're using Swift 6.1+ with proper resource bundling
2. The `ClaudeAgents` target includes resources: `.copy("Resources/agents")`
3. You've run `swift build` to generate the resource bundle

### Empty agent list

If `loadAgents()` returns an empty array, verify:

1. The library is properly installed
2. Resources are bundled correctly
3. Check `Bundle.module.resourceURL` path

### Agent not found

When `getAgent(named:)` returns `nil`:

1. Verify the agent name is correct (use `loadAgents()` to see all names)
2. Agent names are case-sensitive
3. Omit the `.md` extension when searching by name

## Contributing

To add new agents to the library:

1. Create `.md` file in `Sources/ClaudeAgents/Resources/agents/`
2. Include required frontmatter: `name`, `description`, `tools`
3. Rebuild the library: `swift build`
4. New agent is automatically available

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## Version Compatibility

| Library Version | Swift Version | macOS Version |
|----------------|---------------|---------------|
| 1.5.0+         | 6.1+          | 13.0+         |

## Support

- **Issues**: https://github.com/stijnwillems/swift-agents-plugin/issues
- **Documentation**: https://github.com/stijnwillems/swift-agents-plugin/tree/main/docs
- **CLI Tool**: https://github.com/stijnwillems/swift-agents-plugin

## License

MIT License - See LICENSE file for details
