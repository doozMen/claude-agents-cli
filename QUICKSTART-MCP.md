# MCP Integration - Quick Start Guide

This is a quick reference for the MCP integration in the `experiment/mcp` branch.

## Setup Status ✅

All components are installed and configured:

- ✅ SwiftLens MCP server (tools/swiftlens/)
- ✅ Context7 MCP server (via npx)
- ✅ MCP configuration (.mcp.json)
- ✅ Automation hook (tools/auto-rebuild-swift-index.sh)
- ✅ Documentation (docs/MCP-SETUP.md)

## Quick Commands

### Start Using MCP Servers

MCP servers are configured in `.mcp.json` and will be automatically loaded by agents that specify them in their frontmatter:

```yaml
---
name: swift-developer
mcp: swiftlens, context7
---
```

### Build SwiftLens Index

Before using SwiftLens cross-file analysis:

```bash
# Option 1: Via Claude
"run swift_build_index tool"

# Option 2: Manually
swift build -Xswiftc -index-store-path -Xswiftc .build/index/store
```

### Enable Automation Hook

Add to `~/.claude/settings.json`:

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

## MCP Server Capabilities

### SwiftLens (15 tools)

**Single-file analysis** (no index needed):
- `swift_analyze_file` - Analyze structure and symbols
- `swift_summarize_file` - Get symbol counts
- `swift_validate_file` - Syntax validation
- `swift_check_environment` - Verify setup
- `swift_build_index` - Build index store

**Cross-file analysis** (requires index):
- `swift_find_symbol_references` - Find all references
- `swift_get_symbol_definition` - Jump to definition
- `swift_get_hover_info` - Type info and docs

**Code modification**:
- `swift_replace_symbol_body` - Replace function/type body

### Context7 (2 tools)

- `resolve-library-id` - Convert library names to Context7 IDs
- `get-library-docs` - Retrieve version-specific documentation

## Usage Examples

### SwiftLens

```
"Analyze UserManager.swift and show me its structure"
"Find all references to the login() method"
"Show me where the User type is defined"
"Replace the authenticate function body with <new code>"
```

### Context7

```
"Use context7 to get SwiftUI documentation"
"Show me examples of using Swift Concurrency"
"Get the latest Combine framework documentation"
```

## File Structure

```
worktrees/mcp/
├── .mcp.json                          # MCP server configuration
├── tools/
│   ├── swiftlens/                     # SwiftLens git repo (ignored)
│   └── auto-rebuild-swift-index.sh    # Automation hook (executable)
├── docs/
│   └── MCP-SETUP.md                   # Full documentation
└── QUICKSTART-MCP.md                  # This file
```

## Troubleshooting

### SwiftLens: Symbol not found
```bash
swift build -Xswiftc -index-store-path -Xswiftc .build/index/store
```

### SwiftLens: SourceKit-LSP not found
```bash
xcode-select -p
sudo xcode-select -s /Applications/Xcode.app
xcrun sourcekit-lsp --help
```

### Context7: npx not found
```bash
nvm install 18
nvm use 18
```

## Deployment Patterns

### Agent-Local (Current)
- MCP servers start/stop with agent
- Configuration in agent frontmatter
- Isolated per agent

### Project-Local (Alternative)
- MCP servers shared across agents in project
- Copy .mcp.json to project root
- Adjust paths to be relative

## Verification Commands

```bash
# Validate configuration
cat .mcp.json | python3 -m json.tool

# Check dependencies
~/.local/bin/uvx --version  # Should show 0.9.2
npx --version               # Should show 10.9.0
xcrun sourcekit-lsp --help  # Should show help

# Test hook script
echo '{"file_path":"Test.swift"}' | ./tools/auto-rebuild-swift-index.sh
```

## Next Steps

1. **Enable hooks** in `~/.claude/settings.json` (optional)
2. **Build index** for your Swift project: `"run swift_build_index tool"`
3. **Test SwiftLens**: `"analyze Sources/main.swift"`
4. **Test Context7**: `"use context7 to get Swift documentation"`

## Resources

- Full Documentation: [docs/MCP-SETUP.md](docs/MCP-SETUP.md)
- SwiftLens: https://github.com/swiftlens/swiftlens
- Context7: https://github.com/upstash/context7
- MCP Protocol: https://modelcontextprotocol.io/

---

**Branch**: `experiment/mcp`
**Version**: 1.0.0
**Last Updated**: 2025-10-15
