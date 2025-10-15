# MCP Integration Setup for Swift Agents Plugin

This document describes the Model Context Protocol (MCP) integration for the swift-agents-plugin project, specifically covering SwiftLens and Context7 MCP servers for enhanced Swift development capabilities.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Installation](#installation)
- [Configuration](#configuration)
- [Automation](#automation)
- [Deployment Patterns](#deployment-patterns)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)

## Overview

This MCP setup integrates two powerful tools for AI-assisted Swift development:

### SwiftLens MCP Server

- **Purpose**: Semantic-level Swift code analysis using SourceKit-LSP
- **Features**: Cross-file navigation, symbol references, type information, code modification
- **Requires**: macOS, Python 3.10+, Xcode, SourceKit-LSP index

### Context7 MCP Server

- **Purpose**: Up-to-date API documentation and code examples
- **Features**: Version-specific documentation, code examples from official sources
- **Requires**: Node.js 18+

## Architecture

```
Claude Agent
    ↓
MCP Protocol
    ↓
┌─────────────────┬──────────────────┐
│   SwiftLens     │    Context7      │
│                 │                  │
│  SourceKit-LSP  │  Documentation   │
│  Index Store    │  API Examples    │
└─────────────────┴──────────────────┘
    ↓                    ↓
Swift Codebase     Library Docs
```

## Installation

### Prerequisites

1. **Python 3.10+** with `uv` package manager:
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

2. **Node.js 18+** (via nvm recommended):
   ```bash
   nvm install 18
   nvm use 18
   ```

3. **Xcode** (full installation, not just Command Line Tools):
   ```bash
   xcode-select -p  # Should show Xcode.app path
   xcrun sourcekit-lsp --help  # Should work
   ```

### MCP Servers Setup

The MCP servers are already configured in this worktree:

```bash
# SwiftLens - installed in tools/swiftlens/
ls tools/swiftlens/

# Context7 - uses npx (no local installation needed)
```

## Configuration

### MCP Configuration File

The `.mcp.json` file in the project root contains the MCP server configuration:

```json
{
  "mcpServers": {
    "swiftlens": {
      "command": "/Users/stijnwillems/.local/bin/uvx",
      "args": ["swiftlens"],
      "env": {
        "PATH": "/Users/stijnwillems/.local/bin:/usr/local/bin:/usr/bin:/bin"
      }
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

### Agent Configuration

For agent-specific MCP configuration, agents can reference this configuration via:

1. **Agent frontmatter** (in `.md` files):
   ```yaml
   ---
   name: swift-developer
   mcp: swiftlens, context7
   ---
   ```

2. **Runtime loading**: Claude Code automatically loads MCP servers specified in agent frontmatter

## Automation

### Automatic SwiftLens Index Rebuilding

SwiftLens requires an up-to-date SourceKit-LSP index for optimal performance. This worktree includes an automation hook that triggers index rebuilding when Swift files are modified.

#### Hook Script

Located at `tools/auto-rebuild-swift-index.sh`:

- **Trigger**: After Write/Edit operations on `.swift` files
- **Cooldown**: 900 seconds (15 minutes) between rebuilds
- **Mechanism**: Uses lock files and timestamps to prevent excessive rebuilding

#### Enabling the Hook

To enable automatic index rebuilding, add to your `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "./tools/auto-rebuild-swift-index.sh"
          }
        ]
      }
    ]
  }
}
```

#### Manual Index Building

You can always trigger index building manually:

```bash
# Via SwiftLens MCP tool
# Ask Claude: "run swift_build_index tool"

# Or manually:
swift build -Xswiftc -index-store-path -Xswiftc .build/index/store
```

## Deployment Patterns

### Agent-Local Deployment

**Current configuration**: MCP servers are scoped to specific agents.

**Characteristics**:
- MCP servers start/stop with the agent
- Configuration in agent frontmatter (`mcp: swiftlens, context7`)
- Isolated per agent - each agent has its own MCP server instances
- Best for specialized agents with specific tool requirements

**Example**: The `swift-developer` agent automatically loads SwiftLens for semantic analysis.

### Project-Local Deployment

**Alternative pattern**: MCP servers scoped to the project, shared across agents.

**Setup**:
1. Copy `.mcp.json` to project root
2. Adjust paths to be relative to project
3. All agents in the project share the same MCP server instances

**Example configuration** (project-local):
```json
{
  "mcpServers": {
    "swiftlens": {
      "command": "uvx",
      "args": ["swiftlens"],
      "workingDirectory": "."
    }
  }
}
```

### Global Deployment

**Not recommended**: MCP servers available globally to all agents and projects.

**Why avoid**:
- Less isolation between projects
- Potential version conflicts
- Difficult to manage dependencies
- Security implications

## Usage

### Using SwiftLens

SwiftLens provides 15 tools for Swift code analysis:

#### Single-File Analysis (No Index Required)
```
"Analyze the UserManager.swift file structure"
"Get a summary of symbols in AuthService.swift"
"Validate the syntax of PaymentHandler.swift"
```

#### Cross-File Analysis (Requires Index)
```
"Find all references to the login() method"
"Show me where the User type is defined"
"Get type information for this symbol"
```

#### Code Modification
```
"Replace the body of the authenticate function with <new implementation>"
```

### Using Context7

Context7 provides up-to-date documentation:

```
"Use context7 to get the latest SwiftUI documentation"
"Show me examples of using Combine framework"
"Get documentation for Swift 6 concurrency features"
```

## Troubleshooting

### SwiftLens: "Symbol not found"

**Cause**: SourceKit-LSP index is out of date or not built.

**Solution**:
```bash
# Rebuild the index
swift build -Xswiftc -index-store-path -Xswiftc .build/index/store

# Or ask Claude
"run swift_build_index tool"
```

### SwiftLens: "SourceKit-LSP not found"

**Cause**: Xcode not properly installed or selected.

**Solution**:
```bash
# Check Xcode installation
xcode-select -p

# If needed, select Xcode
sudo xcode-select -s /Applications/Xcode.app

# Verify SourceKit-LSP
xcrun sourcekit-lsp --help
```

### Context7: "Command not found: npx"

**Cause**: Node.js not installed or not in PATH.

**Solution**:
```bash
# Install Node.js via nvm
nvm install 18
nvm use 18

# Verify npx
npx --version
```

### Hook Script: Not Triggering

**Cause**: Hook not enabled in Claude Code settings.

**Solution**:
1. Check `~/.claude/settings.json` includes hook configuration
2. Verify script is executable: `chmod +x tools/auto-rebuild-swift-index.sh`
3. Test manually: `echo '{"file_path":"Test.swift"}' | ./tools/auto-rebuild-swift-index.sh`

### MCP Servers: Not Starting

**Cause**: Configuration path issues or missing dependencies.

**Solution**:
1. Verify `.mcp.json` paths are correct for your system
2. Check `uvx` is in PATH: `which uvx` (should show `~/.local/bin/uvx`)
3. Check `npx` is in PATH: `which npx`
4. Review Claude Code logs for MCP startup errors

## Directory Structure

```
swift-agents-plugin/worktrees/mcp/
├── .mcp.json                          # MCP server configuration
├── tools/
│   ├── swiftlens/                     # SwiftLens MCP server (git clone)
│   └── auto-rebuild-swift-index.sh    # Automation hook script
├── docs/
│   └── MCP-SETUP.md                   # This documentation
└── .gitignore                         # Excludes tools/swiftlens/ and temp files
```

## References

- [SwiftLens GitHub](https://github.com/swiftlens/swiftlens)
- [Context7 GitHub](https://github.com/upstash/context7)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [Claude Code Documentation](https://docs.claude.com/en/docs/claude-code)
- [SourceKit-LSP](https://github.com/swiftlang/sourcekit-lsp)

## Contributing

When adding new MCP servers to this configuration:

1. Install the server in `tools/` directory
2. Update `.mcp.json` with server configuration
3. Update `.gitignore` if needed
4. Document usage in this file
5. Test with relevant agents

## License

This MCP configuration is part of the swift-agents-plugin project and follows the same license.

---

**Last Updated**: 2025-10-15
**Version**: 1.0.0
**Maintainer**: Stijn Willems
