# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-13

### Added
- **SetupCommand**: New `claude-agents setup` command for managing ~/.claude/CLAUDE.md configuration
  - Adds comprehensive agent information to global CLAUDE.md file
  - Interactive prompts with `--force` flag for automation
  - Check mode (`--check`) to verify current configuration status
- **ClaudeMdService**: New actor for thread-safe CLAUDE.md file management
  - Handles reading, writing, and updating CLAUDE.md files
  - Smart section detection to prevent duplicate entries
  - Interactive user prompts for safe operations
- **Comprehensive Secrets Management System**:
  - macOS Keychain integration for secure credential storage
  - Setup script (`scripts/setup-secrets.sh`) for interactive credential configuration
  - Load script (`scripts/load-secrets.sh`) for environment variable export
  - MCP config updater (`scripts/update-mcp-config.sh`) for automatic configuration
  - Detailed documentation in `docs/SECRETS.md`
- **New Swift Specialist Agents** (6 new agents):
  - `grdb-sqlite-specialist`: SQLite database management with GRDB
  - `hummingbird-developer`: Hummingbird web framework development
  - `swift-grpc-temporal-developer`: gRPC and Temporal workflow integration
  - `swift-testing-xcode-specialist`: Swift Testing framework expertise
  - `swiftui-specialist`: SwiftUI development patterns
  - `xib-storyboard-specialist`: Interface Builder and Storyboard management
- **Installation Integration**: Post-install tip suggesting setup command if CLAUDE.md not configured
- **Agent Library**: 29 total agents (28 production-ready + 1 private timestory-builder)

### Changed
- Updated README.md with comparison to official Claude CLI
- Enhanced agent count documentation (28 embedded agents)
- Improved crashlytics-analyzer agent for generic public sharing
- Modernized swift-architect agent with latest architecture insights
- Updated swift-modernizer agent with enhanced patterns

### Documentation
- Added comprehensive secrets management guide (`docs/SECRETS.md`)
- Created Claude Code best practices guide (`CLAUDE_CODE_GUIDE.md`)
- Enhanced README with "Why Not Use Official Claude CLI?" section
- Added secrets management workflow documentation
- Included credential rotation and troubleshooting guides

### Fixed
- Agent parser now correctly handles all 29 agents
- Improved error handling in ClaudeMdService
- Enhanced interactive prompts for better user experience

## [0.0.1] - 2025-10-10

### Added
- Initial release of claude-agents-cli
- DoctorCommand for checking CLI tool dependencies
- Basic agent management (list, install, uninstall)
- 22 initial embedded agents
- Global and local installation targets
- Interactive prompts for safe operations

[1.0.0]: https://github.com/doozMen/claude-agents-cli/compare/v0.0.1...v1.0.0
[0.0.1]: https://github.com/doozMen/claude-agents-cli/releases/tag/v0.0.1
