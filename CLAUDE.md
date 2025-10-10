# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Claude Agents CLI is a Swift command-line tool for managing Claude agent markdown files. It allows installing, uninstalling, and managing specialized AI agents for development projects.

## Build & Development Commands

### Building
```bash
swift build
```

### Installing the CLI
```bash
# Remove existing executable first (experimental-install doesn't support overwriting)
rm -f ~/.swiftpm/bin/claude-agents
swift package experimental-install --product claude-agents
```

### Running Without Installing
```bash
swift run claude-agents <command>
```

### Testing
The project uses Swift's built-in Testing framework (NOT XCTest). Currently, there are no test files in the repository.

### Code Formatting
```bash
# Lint the project
swift format lint -s -p -r Sources Package.swift

# Auto-fix formatting issues
swift format format -p -r -i Sources Package.swift
```

## Architecture

### Swift 6.0 Concurrency Model

The project uses Swift 6.0's strict concurrency features:

- **Actor Isolation**: All services (`AgentParser`, `InstallService`, `GitService`) are actors for thread-safe operations
- **Sendable Conformance**: All models (`Agent`, `InstallTarget`, `InstallResult`) conform to `Sendable`
- **Async/Await**: Commands and services use modern async patterns throughout

### Project Structure

```
claude-agents-cli/
├── Package.swift
└── Sources/claude-agents-cli/
    ├── Main.swift                    # Entry point using @main
    ├── Commands/                     # ArgumentParser command implementations
    │   ├── ListCommand.swift         # List available/installed agents
    │   ├── InstallCommand.swift      # Install agents to global/local
    │   ├── UninstallCommand.swift    # Remove installed agents
    │   ├── UpdateCommand.swift       # Placeholder for future updates
    │   └── SharedTypes.swift         # Shared command types
    ├── Models/                       # Data models (all Sendable)
    │   ├── Agent.swift               # Agent representation with frontmatter parsing
    │   ├── InstallTarget.swift       # Global vs local installation targets
    │   ├── InstallResult.swift       # Installation operation results
    │   └── Errors.swift              # Custom error types
    ├── Services/                     # Business logic (all actors)
    │   ├── AgentParser.swift         # Parse agent markdown with YAML frontmatter
    │   ├── InstallService.swift      # File operations for install/uninstall
    │   └── GitService.swift          # Future Git-based updates
    └── Resources/
        └── agents/                   # Embedded agent markdown files
            ├── swift-architect.md
            ├── swift-developer.md
            ├── testing-specialist.md
            └── ... (20+ agent files)
```

### Key Components

**Main.swift** (Sources/claude-agents-cli/Main.swift:4)
- Uses `@main` attribute with `AsyncParsableCommand` for async/await compatibility
- Configures ArgumentParser with subcommands
- Default command is `ListCommand`

**Agent Model** (Sources/claude-agents-cli/Models/Agent.swift)
- Parses YAML frontmatter from markdown files
- Required fields: `name`, `description`
- Optional fields: `tools`, `model`
- Frontmatter extraction uses custom parser (not external YAML library)

**AgentParser Actor** (Sources/claude-agents-cli/Services/AgentParser.swift)
- Loads agents from `Bundle.module.resourceURL`
- Caches parsed agents for performance
- Uses `Bundle.module` for embedded resources (set in Package.swift:21-23)

**InstallService Actor** (Sources/claude-agents-cli/Services/InstallService.swift)
- Handles file copying to global (`~/.claude/agents/`) or local (`./.claude/agents/`)
- Supports overwrite protection with `--force` flag
- Interactive mode prompts user for confirmation

### Installation Targets

**Global** (`~/.claude/agents/`)
- Available across all projects
- Default installation location

**Local** (`./.claude/agents/`)
- Project-specific agents
- Use for custom or project-specific agent configurations

## Agent File Format

Agents are markdown files with YAML frontmatter:

```markdown
---
name: agent-name
description: Brief description (60-100 chars)
tools: Read, Edit, Glob, Grep, Bash, MultiEdit
model: sonnet
---

# Agent Content

Agent instructions and expertise...
```

### Adding New Agents

1. Create `.md` file in `Sources/claude-agents-cli/Resources/agents/`
2. Include required frontmatter: `name`, `description`, `tools`
3. Rebuild and reinstall the CLI
4. Tools are parsed as comma-separated list (whitespace trimmed)

## Command Reference

### List Command
```bash
# List available agents (embedded in CLI)
claude-agents list

# List with descriptions
claude-agents list --verbose

# Filter by tool
claude-agents list --tool Bash

# List installed agents
claude-agents list --installed          # Global
claude-agents list --installed --target local  # Local
```

### Install Command
```bash
# Install specific agents globally
claude-agents install swift-architect testing-specialist --global

# Install to local project directory
claude-agents install swift-architect --local

# Install all agents
claude-agents install --all --global

# Force overwrite existing
claude-agents install swift-architect --global --force
```

### Uninstall Command
```bash
# Uninstall from global
claude-agents uninstall swift-architect

# Uninstall from local
claude-agents uninstall swift-architect --target local
```

### Update Command
Currently a placeholder. Use `claude-agents install --all --force --global` to update.

## Design Patterns

**Dependency Injection**
- Services are independent actors injected into commands
- Enables testing and modularity

**Error Handling**
- Custom error types conform to `CustomStringConvertible`
- User-friendly error messages (see Models/Errors.swift)

**Resource Management**
- Uses `Bundle.module` for embedded agent files
- Resources copied to `.build` during build (Package.swift:21-23)

**Async/Await Throughout**
- Commands are `AsyncParsableCommand`
- Services use `async` methods
- No completion handlers or callbacks

## Important Notes

- **Entry Point**: Uses `@main` attribute (not `main.swift`) for async/await support
- **Installation**: Must remove existing executable before reinstalling with `experimental-install`
- **PATH Setup**: Ensure `~/.swiftpm/bin` is in PATH
- **Swift Version**: Requires Swift 6.1+ for strict concurrency
- **Platform**: macOS 13.0+ only
- **Testing Framework**: Use Swift Testing (NOT XCTest)
- **Formatting**: Swift 6 has built-in formatter (`swift format`)
