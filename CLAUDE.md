# CLAUDE.md

AI assistance guide for the Swift Agents Plugin codebase.

## Project Context

**What**: Swift CLI tool managing 42 specialized Claude agent markdown files
**Purpose**: Simplify agent installation/management for Claude Code users
**Language**: Swift 6.1 with strict concurrency (actors, Sendable, async/await)

## Quick Commands

```bash
# Build
swift build

# Install CLI (remove old first - experimental-install can't overwrite)
rm -f ~/.swiftpm/bin/claude-agents
swift package experimental-install --product claude-agents

# Format code
swift format format -p -r -i Sources Package.swift

# Run without installing
swift run claude-agents <command>
```

## Architecture Overview

```
Entry: Main.swift (@main AsyncParsableCommand)
  ↓
Commands/ (ArgumentParser commands)
  ↓
Services/ (Business logic - all actors)
  ├── AgentParser: Parse YAML frontmatter from .md files
  ├── InstallService: Copy agents to ~/.claude/agents/
  └── GitService: Future updates (placeholder)
  ↓
Models/ (Data types - all Sendable)
  └── Agent, InstallTarget, InstallResult, Errors
```

## Key Files

| File | Purpose | Key Details |
|------|---------|-------------|
| Main.swift:4 | Entry point | `@main` attribute, not main.swift |
| Agent.swift | Agent model | Parses YAML frontmatter without external libs |
| AgentParser.swift | Resource loader | Uses Bundle.module for embedded .md files |
| InstallService.swift | File operations | Handles global/local installation |
| agents/*.md | 42 agents | Production-ready agent markdown files |

## Agent Format

```markdown
---
name: agent-name          # Required: identifier
description: Brief desc    # Required: 60-100 chars
tools: Read, Edit, Bash   # Required: comma-separated
model: sonnet             # Optional: opus/sonnet/haiku
mcp: github, azure        # Optional: MCP servers
---

# Agent Name

Agent instructions...
```

## Recent Changes (v1.4.0)

- Added 3 generic agents: architect, test-builder, code-reviewer
- Renamed: documentation-writer → swift-docc
- Added swift-format-specialist (Haiku) for mechanical formatting
- Model distribution: 2 Opus, 30 Sonnet, 12 Haiku
- Removed task-router (redundant with direct edgeprompt MCP calls)

## Testing

- Framework: Swift Testing (`@Test` macros)
- **DO NOT** use XCTest or add as dependency
- No test files currently exist

## Common Tasks

### Add New Agent
1. Create .md file in `Sources/claude-agents-cli/Resources/agents/`
2. Include required frontmatter (name, description, tools)
3. Rebuild and reinstall CLI

### Update All Agents
```bash
claude-agents install --all --force --global
```

### Debug Agent Loading
Check `AgentParser.swift` - caches parsed agents from Bundle.module

## Error Patterns

- "no such file": Use absolute paths or verify pwd
- "experimental-install failed": Remove existing executable first
- "agent not found": Check Bundle.module resource copying

## Documentation

- **User Guide**: [README.md](README.md) - Installation and usage
- **Architecture**: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - Technical design
- **Agent Catalog**: [docs/AGENTS.md](docs/AGENTS.md) - All 42 agents detailed
- **Best Practices**: [docs/CLAUDE_CODE_GUIDE.md](docs/CLAUDE_CODE_GUIDE.md) - Claude Code patterns
- **Contributing**: [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) - Adding agents

## Important Notes

- Swift 6.1+ required for strict concurrency
- macOS 13.0+ only (no Linux support)
- Resources copied to .build during build (Package.swift:21-23)
- Uses @main instead of main.swift for async/await
- All services are actors for thread safety
- All models conform to Sendable
