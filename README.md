# Claude Agents CLI

**38 production-ready AI agents for Claude Code** - Install specialized agents for Swift, testing, documentation, CI/CD, and more.

[![Swift 6.1](https://img.shields.io/badge/Swift-6.1-orange.svg)](https://swift.org)
[![macOS 13.0+](https://img.shields.io/badge/macOS-13.0+-blue.svg)](https://www.apple.com/macos)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Quick Start

```bash
# Install the CLI
cd claude-agents-cli
swift package experimental-install --product claude-agents

# List available agents
claude-agents list

# Install essential agents globally
claude-agents install swift-architect test-builder code-reviewer --global

# Install all 38 agents
claude-agents install --all --global
```

That's it! Your agents are ready to use in Claude Code.

## What is This?

Claude Agents CLI provides a curated library of specialized AI agents that extend Claude Code's capabilities. Instead of writing agent markdown from scratch, choose from 38 production-ready agents covering:

- **Swift & iOS Development** - Architecture, SwiftUI, testing, modernization
- **Cross-Platform** - Generic agents for any language (architect, test-builder, code-reviewer)
- **Documentation** - API docs, technical writing, blog posts
- **CI/CD & DevOps** - Azure DevOps, GitLab, GitHub automation
- **Specialized Tools** - Firebase analytics, crash reporting, MCP servers

## Popular Agent Combinations

```bash
# iOS Development
claude-agents install swift-architect swift-developer swiftui-specialist --global

# Full-Stack Development
claude-agents install architect test-builder code-reviewer --global

# Documentation & Content
claude-agents install swift-docc blog-content-writer documentation-verifier --global

# CI/CD Pipeline
claude-agents install azure-devops git-pr-specialist --global
```

## Key Features

- **🚀 38 Embedded Agents** - Production-ready, no configuration needed
- **🧠 Smart Routing** - New task-router agent uses local LLM for intelligent delegation
- **💰 Cost Optimized** - Mixed model strategy (Opus for complex, Haiku for simple tasks)
- **🔧 Zero Config** - Agents work immediately after installation
- **📁 Flexible Installation** - Global (all projects) or local (project-specific)
- **🔍 Easy Discovery** - Filter by tools, view descriptions, find the right agent

## Installation

Ensure `~/.swiftpm/bin` is in your PATH:
```bash
export PATH="$HOME/.swiftpm/bin:$PATH"
```

Then install:
```bash
git clone https://github.com/yourusername/claude-agents-cli.git
cd claude-agents-cli
swift package experimental-install --product claude-agents
```

## Core Commands

### Discover Agents
```bash
claude-agents list                    # List all 38 available agents
claude-agents list --verbose           # Include descriptions
claude-agents list --tool Bash         # Filter by tool capability
claude-agents list --installed         # Show what's installed
```

### Install Agents
```bash
claude-agents install <agent-name> --global   # Install globally
claude-agents install <agent-name> --local    # Install to current project
claude-agents install --all --global          # Install everything
claude-agents install --all --force --global  # Update all agents
```

### Remove Agents
```bash
claude-agents uninstall <agent-name>          # From global
claude-agents uninstall <agent-name> --target local  # From project
```

## Featured Agents

### 🆕 New Generic Agents (v1.4.0)

| Agent | Model | Purpose |
|-------|-------|---------|
| **task-router** | Haiku | Routes requests to best agents using local LLM |
| **architect** | Opus | System design and architecture across all languages |
| **test-builder** | Haiku | Creates comprehensive test suites efficiently |
| **code-reviewer** | Sonnet | Thorough code reviews with actionable feedback |

### Swift & iOS Development

| Agent | Purpose |
|-------|---------|
| **swift-architect** | Swift 6.0 patterns, actors, async/await |
| **swift-developer** | Feature implementation, iOS development |
| **swiftui-specialist** | SwiftUI best practices and components |
| **swift-modernizer** | Migrate legacy code to Swift 6.0 |
| **swift-testing-specialist** | Swift Testing framework expertise |

### Documentation & Content

| Agent | Purpose |
|-------|---------|
| **swift-docc** | Swift DocC and API documentation |
| **documentation-verifier** | Review and improve documentation |
| **blog-content-writer** | Technical blog posts and articles |

### DevOps & CI/CD

| Agent | Purpose |
|-------|---------|
| **azure-devops** | Azure DevOps pipelines and automation |
| **git-pr-specialist** | PR/MR workflows across platforms |
| **github-specialist** | GitHub Actions and workflows |
| **gitlab-specialist** | GitLab CI/CD pipelines |

[View all 38 agents →](docs/AGENTS.md)

## Why Use This Instead of Official Claude CLI?

The official `claude-code` CLI includes basic agent management. This tool provides:

- **Curated Library**: 38 production-ready agents vs. starting from scratch
- **Smart Discovery**: Filter by tools, batch operations, descriptions
- **Model Optimization**: Strategic use of Opus/Sonnet/Haiku for cost/performance
- **OWL Intelligence Integration**: Local LLM routing (coming soon)

## Project Structure

```
claude-agents-cli/
├── Sources/claude-agents-cli/
│   ├── Commands/              # CLI commands
│   ├── Models/                 # Data models
│   ├── Services/              # Business logic
│   └── Resources/agents/      # 38 embedded agents
└── docs/                      # Detailed documentation
```

## Requirements

- macOS 13.0+
- Swift 6.1+
- Claude Code Desktop App

## Documentation

- [Agent Catalog](docs/AGENTS.md) - Detailed descriptions of all 38 agents
- [Architecture Guide](docs/ARCHITECTURE.md) - Technical details and design
- [Claude Code Guide](docs/CLAUDE_CODE_GUIDE.md) - Best practices for Claude Code
- [Secrets Management](docs/SECRETS.md) - Credential setup for MCP servers
- [Contributing](docs/CONTRIBUTING.md) - How to add new agents

## Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/claude-agents-cli/issues)
- **Docs**: [Official Claude Code Docs](https://docs.claude.com/en/docs/claude-code)

## License

MIT - See [LICENSE](LICENSE) file

---

Made with ❤️ for the Claude Code community