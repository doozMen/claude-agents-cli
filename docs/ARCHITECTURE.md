# Architecture Guide

Technical architecture of the Swift Agents Plugin.

## System Design

### Overview

```
claude-agents (CLI executable)
         │
         ├── Commands Layer (ArgumentParser)
         │   ├── ListCommand
         │   ├── InstallCommand
         │   ├── UninstallCommand
         │   └── UpdateCommand
         │
         ├── Services Layer (Actors)
         │   ├── AgentParser
         │   ├── InstallService
         │   └── GitService
         │
         ├── Models Layer (Sendable)
         │   ├── Agent
         │   ├── InstallTarget
         │   ├── InstallResult
         │   └── Errors
         │
         └── Resources
             └── agents/*.md (40 embedded)
```

## Core Components

### Entry Point

**Main.swift** uses `@main` attribute with AsyncParsableCommand:
```swift
@main
struct ClaudeAgentsCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "claude-agents",
        abstract: "Manage Claude agent markdown files",
        version: "1.4.0",
        subcommands: [ListCommand.self, InstallCommand.self, UninstallCommand.self, UpdateCommand.self],
        defaultSubcommand: ListCommand.self
    )
}
```

### Concurrency Model

All services are **actors** for thread-safe operations:
```swift
actor AgentParser {
    private var cachedAgents: [Agent]?

    func loadAgents() async throws -> [Agent] {
        // Thread-safe agent loading
    }
}
```

All models conform to **Sendable**:
```swift
struct Agent: Sendable {
    let name: String
    let description: String
    let tools: [String]
    let model: String?
}
```

### Resource Management

Agents are embedded using Bundle.module:
```swift
// Package.swift
.target(
    name: "swift-agents-plugin",
    dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser")
    ],
    resources: [
        .copy("Resources/agents")
    ]
)
```

### Agent Parsing

Custom YAML frontmatter parser without external dependencies:
```swift
private func parseFrontmatter(from content: String) -> (metadata: [String: String], content: String)? {
    let lines = content.split(separator: "\n", omittingEmptySubsequences: false)

    guard lines.first?.trimmingCharacters(in: .whitespaces) == "---" else {
        return nil
    }

    // Extract metadata between --- markers
    // Parse key-value pairs
    // Return metadata and remaining content
}
```

## Installation Flow

### Global Installation (`~/.claude/agents/`)

```
1. User runs: claude-agents install agent-name --global
2. InstallCommand validates agent exists
3. InstallService creates directory if needed
4. Copies agent.md from bundle to ~/.claude/agents/
5. Returns success/failure result
```

### Local Installation (`./.claude/agents/`)

```
1. User runs: claude-agents install agent-name --local
2. InstallCommand validates agent exists
3. InstallService creates ./.claude/agents/ in current directory
4. Copies agent.md from bundle
5. Local agents override global ones in Claude Code
```

## Data Flow

### List Command

```
User Request → ListCommand
    ↓
AgentParser.loadAgents()
    ↓
Bundle.module.resourceURL
    ↓
Parse all .md files
    ↓
Filter by tool (optional)
    ↓
Display results
```

### Install Command

```
User Request → InstallCommand
    ↓
Validate agent names
    ↓
InstallService.install()
    ↓
Create directories
    ↓
Copy files
    ↓
Handle overwrites
    ↓
Return results
```

## Error Handling

### Error Types

```swift
enum AgentError: Error, CustomStringConvertible {
    case agentNotFound(String)
    case installationFailed(String)
    case directoryCreationFailed(String)

    var description: String {
        // User-friendly error messages
    }
}
```

### Error Propagation

- Commands catch and display errors
- Services throw typed errors
- Models validate on initialization

## Performance Considerations

### Caching

AgentParser caches parsed agents:
```swift
actor AgentParser {
    private var cachedAgents: [Agent]?

    func loadAgents() async throws -> [Agent] {
        if let cached = cachedAgents {
            return cached
        }
        // Load and cache agents
    }
}
```

### Resource Loading

- Agents loaded once per session
- Bundle.module provides fast access
- No network requests required

## Testing Strategy

### Framework

Swift Testing with `@Test` macros:
```swift
import Testing

@Test
func testAgentParsing() async throws {
    let parser = AgentParser()
    let agents = try await parser.loadAgents()
    #expect(agents.count == 40)
}
```

### Test Coverage Areas

- Agent parsing
- Installation logic
- Error handling
- Command validation

## Security

### File Operations

- Validates paths before operations
- No arbitrary file writes
- Respects user permissions
- No network access

### Agent Validation

- Validates YAML frontmatter
- Sanitizes agent names
- Checks for required fields

## Future Enhancements

### Planned Features

1. **Git-based Updates**
   - Pull latest agents from repository
   - Version management
   - Change tracking

2. **Agent Dependencies**
   - Define agent relationships
   - Auto-install dependencies
   - Conflict resolution

3. **Remote Repositories**
   - Custom agent sources
   - Private repositories
   - Authentication support

4. **OWL Intelligence Integration**
   - Local LLM routing
   - Agent discovery
   - Semantic matching

## Build System

### Swift Package Manager

```swift
// Package.swift
let package = Package(
    name: "swift-agents-plugin",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "claude-agents", targets: ["swift-agents-plugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0")
    ],
    targets: [
        .executableTarget(
            name: "swift-agents-plugin",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            resources: [.copy("Resources/agents")]
        )
    ]
)
```

### Build Commands

```bash
# Development build
swift build

# Release build
swift build -c release

# Install
swift package experimental-install --product claude-agents

# Clean
rm -rf .build
```

## Deployment

### Distribution

- Executable installed to `~/.swiftpm/bin/`
- Agents embedded in binary
- No external dependencies
- Single file distribution

### Platform Support

- macOS 13.0+ only
- Swift 6.1+ required
- No Linux support (macOS-specific paths)

## Monitoring

### Logging

Currently minimal logging. Future enhancement:
- Debug mode flag
- Verbose output option
- Error tracking

### Metrics

Track in future versions:
- Installation success rate
- Most popular agents
- Error frequency

## Conclusion

The architecture prioritizes:
- **Simplicity**: Single executable, no dependencies
- **Safety**: Actor isolation, Sendable types
- **Performance**: Cached parsing, embedded resources
- **Extensibility**: Clean separation of concerns