# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2025-10-14

### Added
- **New Swift Development Agents** (2 new agents):
  - `swift-cli-tool-builder`: Expert in building Swift CLI tools with ArgumentParser, Swift Package Manager, and experimental-install distribution
    - Comprehensive CLI architecture patterns (Models/Services/Commands)
    - ArgumentParser command structures, options, flags, validation
    - Actor-based concurrency for thread-safe service layers
    - Resource embedding for bundled content (templates, agents)
    - Distribution via experimental-install to ~/.swiftpm/bin
    - User experience patterns: interactive prompts, progress indicators, error messages
    - Real-world example: claude-agents-cli architecture documentation
  - `swift-server`: Server-side Swift development expert with Vapor, Hummingbird, and SwiftNIO
    - Framework expertise: Vapor 4.x, Hummingbird, SwiftNIO event-driven architecture
    - API design patterns: RESTful APIs, GraphQL, gRPC, WebSocket real-time communication
    - Database integration: Fluent ORM, PostgreSQL, MongoDB, Redis caching
    - Authentication & security: JWT, OAuth2, middleware patterns, CORS
    - Deployment strategies: Docker containerization, Kubernetes, AWS/GCP deployment
    - Performance optimization: async/await patterns, connection pooling
- **Agent Library**: 35 total agents (34 production-ready + 1 private timestory-builder)

### Changed
- Updated agent library from 33 to 35 agents (+2 new agents)
- Enhanced Swift development capabilities with CLI tool and server-side development experts

## [1.1.1] - 2025-10-13

### Fixed
- Fixed agent directory structure - moved 4 agents from Sources/AgentsCLI/ to Sources/claude-agents-cli/Resources/agents/
- CLI now properly embeds all 33 agents (was only embedding 29)
- Agents affected: technical-documentation-reviewer, crashlytics-cross-app-analyzer, crashlytics-architecture-correlator, crashlytics-multiclone-analyzer

## [1.1.0] - 2025-10-13

### Added
- **New General-Purpose Agents** (4 new agents):
  - `technical-documentation-reviewer`: Orchestrator for comprehensive technical documentation reviews
    - Coordinates multi-agent reviews across swift-architect, documentation-verifier, and crashlytics specialists
    - 6-phase systematic review framework (Discovery → Accuracy → Consistency → Completeness → Style → Synthesis)
    - Cross-domain validation (architecture, KMM, SPM, multi-clone, crashlytics)
    - Generates actionable reports with priority categorization
  - `crashlytics-cross-app-analyzer`: Multi-app crash pattern detection
    - Discovers Firebase projects from CLAUDE.md/docs (no hardcoded data)
    - Systemic/Regional/Isolated crash classification
    - Priority scoring: (apps affected × occurrences × severity)
    - Weekly ecosystem triage reports with BigQuery integration
  - `crashlytics-architecture-correlator`: Architecture-crash rate correlation analysis
    - Reads architecture levels from project docs (L1/L2/L3 or custom)
    - Correlates crash rates with architecture maturity
    - Technical debt impact analysis (debt % → crash rate)
    - Modernization ROI prediction (L1→L2→L3 improvement curves)
  - `crashlytics-multiclone-analyzer`: Multi-clone/white-label systemic issue detection
    - Reads clone structure from project docs (no hardcoded clones)
    - Systemic issue detection (crashes in 5+ clones → CRITICAL)
    - Configuration drift analysis
    - Fix impact ROI calculator (1 fix → N clones, 6-10x multipliers)
- **Agent Library**: 33 total agents (32 production-ready + 1 private timestory-builder)

### Changed
- Updated agent library from 29 to 33 agents (+4 new agents)
- Enhanced crashlytics analysis capabilities with three specialized agents
- Improved documentation review workflows with orchestrator agent

### Architecture
- **General Workflows + Project Data Separation Pattern**:
  - General agents contain workflows only, NO hardcoded project data
  - Project data stored in user's CLAUDE.md and project docs
  - Context discovery: Agents read CLAUDE.md and docs/ to discover project context
  - Benefits: Reusable across ANY multi-app ecosystem, shareable agent library

### Deprecated
- `firebase-companya-ecosystem-analyzer`: Replaced by 3 modular crashlytics agents (cross-app, architecture-correlator, multiclone)

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

[1.1.1]: https://github.com/doozMen/claude-agents-cli/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/doozMen/claude-agents-cli/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/doozMen/claude-agents-cli/compare/v0.0.1...v1.0.0
[0.0.1]: https://github.com/doozMen/claude-agents-cli/releases/tag/v0.0.1
