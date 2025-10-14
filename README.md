# Claude Agents CLI

A Swift command-line tool for managing Claude agent markdown files. Install, uninstall, and manage specialized AI agents for your projects.

## New to Claude Code?

If you're new to Claude Code and agents, check out the [**Claude Code Best Practices Guide**](./CLAUDE_CODE_GUIDE.md) - a comprehensive introduction to agent-based development workflows.

## Why Not Use Official Claude CLI?

The official Claude CLI (`claude-code`) includes basic agent management. This tool provides:

**Key Differences:**
- **34 Embedded Agents**: Production-ready agents for Swift, iOS, documentation, testing, and CI/CD
- **Curated Library**: No need to write agent markdown from scratch
- **Discovery**: Filter agents by tool usage, list with descriptions
- **Batch Operations**: Install all agents with `--all` flag
- **Global & Local**: System-wide or project-specific installation

**Use Case**: This tool is for developers who want ready-to-use specialized agents. The official Claude CLI is better for creating custom agents from scratch.

## Features

- **List Agents**: Browse 34 embedded agents or view installed agents
- **Install**: Copy agents to global (~/.claude/agents/) or local (./.claude/agents/) directories
- **Uninstall**: Remove installed agents
- **Filter**: Find agents by tool usage
- **Interactive**: Smart prompts for safe operations
- **Embedded Library**: 34 production-ready agents covering Swift development, documentation, testing, and CI/CD

## Installation

### Using Swift Package Manager

```bash
cd claude-agents-cli
swift package experimental-install --product claude-agents
```

This installs the `claude-agents` executable to `~/.swiftpm/bin/`. Make sure this directory is in your PATH:

```bash
export PATH="$HOME/.swiftpm/bin:$PATH"
```

### From Source

```bash
git clone <repository-url>
cd claude-agents-cli
swift build -c release
cp .build/release/claude-agents /usr/local/bin/
```

## Secrets Management

Some agents require credentials (Ghost CMS, Firebase, etc.). Store them securely using macOS Keychain:

```bash
# Interactive setup - stores secrets in Keychain
./scripts/setup-secrets.sh

# Load secrets into environment
source scripts/load-secrets.sh

# Update Claude MCP configuration
./scripts/update-mcp-config.sh

# Restart Claude Code to apply changes
```

See [docs/SECRETS.md](docs/SECRETS.md) for detailed documentation on:
- Setting up Ghost CMS and Firebase credentials
- Rotating secrets
- Troubleshooting
- Adding new MCP servers

**Never commit secrets to version control.** The project uses `.env.template` as a reference. Actual secrets are stored in macOS Keychain.

## Usage

### List Available Agents

```bash
# List all available agents
claude-agents list

# List with descriptions
claude-agents list --verbose

# Filter by tool
claude-agents list --tool Bash
```

### List Installed Agents

```bash
# List globally installed agents
claude-agents list --installed

# List locally installed agents
claude-agents list --installed --target local
```

### Install Agents

```bash
# Install specific agents to global location
claude-agents install swift-architect testing-specialist --global

# Install to local project directory
claude-agents install swift-architect --local

# Install all available agents
claude-agents install --all --global

# Force overwrite existing agents
claude-agents install swift-architect --global --force
```

**Installation Targets:**
- `--global`: Installs to `~/.claude/agents/` (default)
- `--local`: Installs to `./.claude/agents/` (project-specific)

### Uninstall Agents

```bash
# Uninstall from global location
claude-agents uninstall swift-architect

# Uninstall from local location
claude-agents uninstall swift-architect --target local
```

### Update Agents

```bash
# Placeholder for future Git-based updates
claude-agents update
```

Currently, use `claude-agents install --all --force --global` to update all agents.

## Available Agents

The CLI includes these specialized agents:

- **swift-architect**: Swift 6.0 architecture patterns and modern iOS development
- **swift-developer**: Feature implementation and iOS code writing
- **swift-modernizer**: Legacy code migration to Swift 6.0
- **swift-cli-tool-builder**: Build professional CLI tools with ArgumentParser and SPM
- **swift-server**: Server-side Swift with Vapor, Hummingbird, and SwiftNIO
- **testing-specialist**: Swift Testing framework expertise
- **kmm-specialist**: Kotlin Multiplatform Mobile integration
- **spm-specialist**: Swift Package Manager expertise
- **xcode-configuration-specialist**: Xcode project configuration

## Agent Structure

Each agent is a markdown file with YAML frontmatter:

```markdown
---
name: swift-architect
description: Specialized in Swift 6.0 architecture patterns
tools: Read, Edit, Glob, Grep, Bash
model: sonnet
---

# Agent Content

Agent instructions and expertise...
```

## Adding Custom Agents

To add your own agents:

1. Create a `.md` file with YAML frontmatter
2. Place it in `Sources/claude-agents-cli/Resources/agents/`
3. Rebuild and reinstall the CLI

Required frontmatter fields:
- `name`: Agent identifier
- `description`: Brief description
- `tools`: Comma-separated list of available tools

Optional fields:
- `model`: Preferred AI model (e.g., "sonnet")

## Development

### Building

```bash
swift build
```

### Running Tests

```bash
swift test
```

### Project Structure

```
claude-agents-cli/
├── Package.swift
├── Sources/claude-agents-cli/
│   ├── Main.swift
│   ├── Commands/
│   │   ├── ListCommand.swift
│   │   ├── InstallCommand.swift
│   │   ├── UninstallCommand.swift
│   │   ├── UpdateCommand.swift
│   │   └── SharedTypes.swift
│   ├── Models/
│   │   ├── Agent.swift
│   │   ├── InstallTarget.swift
│   │   ├── Errors.swift
│   │   └── InstallResult.swift
│   ├── Services/
│   │   ├── AgentParser.swift
│   │   ├── InstallService.swift
│   │   └── GitService.swift
│   └── Resources/
│       └── agents/
│           ├── swift-architect.md
│           ├── swift-developer.md
│           └── ...
└── Tests/
    └── claude-agents-cliTests/
```

## Architecture

### Swift 6.0 Concurrency

- **Actor Isolation**: All services are actors for thread-safe operations
- **Sendable Conformance**: All models conform to Sendable
- **Async/Await**: Modern async patterns throughout

### Design Patterns

- **Dependency Injection**: Services are independent and testable
- **Error Handling**: CustomStringConvertible errors for user-friendly messages
- **Resource Management**: Bundle.module for embedded agent files

## Requirements

- macOS 13.0+
- Swift 6.1+
- Xcode 16.0+ (for building)

## License

MIT License - See LICENSE file for details

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add your changes with tests
4. Submit a pull request

## Roadmap

- [ ] Git-based agent updates
- [ ] Remote agent repositories
- [ ] Agent dependencies
- [ ] Version management
- [ ] Agent templates
- [ ] Bash completion scripts

## Support

For issues, questions, or contributions, please open an issue on GitHub.

## Documentation

- [Claude Code Best Practices Guide](./CLAUDE_CODE_GUIDE.md) - Comprehensive guide for developers new to Claude Code
- [Official Claude Code Docs](https://docs.claude.com/en/docs/claude-code) - Anthropic's official documentation
