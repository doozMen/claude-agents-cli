# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **ClaudeAgents Library Target** (Issue #7):
  - New library product `ClaudeAgents` for programmatic agent access
  - `AgentRepository` actor with thread-safe caching and filtering
  - Public API for downstream integration (edgeprompt, IDE plugins, tooling)
  - Zero dependencies - standalone library
  - Resources: All 46 agent definitions bundled via `.copy("Resources/agents")`
  - Performance: First load ~10-20ms, cached <1ms
  - Documentation: `docs/LIBRARY_USAGE.md` (13,000+ words), `docs/LIBRARY_QUICKSTART.md`
  - Core API:
    - `loadAgents()` - Load all agent definitions
    - `getAgent(named:)` - Get specific agent by name
    - `getAgents(byTool:)` - Filter agents by tool
    - `getAgents(byModel:)` - Filter agents by model
    - `getAgents(byMCPServer:)` - Filter agents by MCP server
    - `search(_:)` - Search agents by query
  - Metadata API: `getAllTools()`, `getAllModels()`, `getAllMCPServers()`
- **Installation Status API** (Issue #10):
  - `InstallationScope` enum: global (~/.claude/agents/), project (./.claude/agents/), all
  - `InstallationInfo` struct with metadata (location, date, size, name)
  - `AgentRepository` extensions:
    - `isInstalled(agentID:scope:)` - Check if agent is installed
    - `installationInfo(for:scope:)` - Get installation metadata
    - `installedAgents(scope:)` - Get all installed agents
    - `notInstalledAgents(scope:)` - Get agents defined but not installed
  - 5-minute cache TTL for filesystem operations
  - Graceful handling of missing directories
  - Enables intelligent agent routing based on actual availability
- **github-specialist Agent** (Issue #11):
  - Expert in GitHub workflows, pull requests, issues, and Actions using GitHub MCP
  - Comprehensive GitHub MCP setup documentation with PAT configuration
  - Prerequisites section with required scopes (repo, workflow, read:org, read:user)
  - Error handling guidance with clear detection patterns and user prompts
  - Automatic fallback to `gh` CLI with explanation when MCP fails
  - Tool coverage: PRs, Issues, Actions, Repository management
  - Dependencies: github MCP server, gh CLI (backup)
- **Markdown Distribution Enhancement**: 46 agents (45 → 46 with github-specialist)
- **Marketplace Distribution Documentation**:
  - `docs/MARKETPLACE-PUBLISHING.md`: Comprehensive marketplace publishing guide (384 lines)
    - 3 distribution options: GitHub self-hosted, official marketplace, community hubs
    - Pre-submission checklist and validation commands
    - Azure DevOps and corporate marketplace setup
    - Staged distribution strategy (Day 1 → Week 1 → Week 2)
    - Troubleshooting guide and support resources
- **New Automation Agents** (2 agents):
  - `release-manager` (Sonnet): Automate complete release workflow
    - 7-phase workflow: validation, version bump, assets, marketplace updates, git cleanup, release creation, verification
    - Asset management with silicon screenshots
    - CHANGELOG automation and GitHub/GitLab release creation
    - Post-release verification
  - `generic-assistant` (Haiku): Fast, cost-effective helper for common tasks
    - 93% cost savings vs Sonnet ($1/M vs $15/M tokens)
    - File operations, text processing, git checks, command execution
    - Quick information gathering and data extraction
- **GitHub Issues for Marketplace Distribution**:
  - Issue #5: Add `/marketplace` slash command for simplified installation
  - Issue #6: Submit plugin to community marketplaces (jeremylongshore, ananddtyagi, EveryInc)

### Changed
- **azure-devops Agent Markdown-First Formatting Strategy** (Issue #12):
  - Changed default from HTML to Markdown for work item descriptions
  - Added pre-submission validation function (`validate_work_item_content()`)
  - Implemented 3-tier retry logic: Markdown → Plain text → Summary only
  - Token limit management for 25k token limit (safe limit: 10,000 tokens)
  - Three strategies for large content: Summary + Attachments, Parent + Child items, Collapsible sections
  - Formatting best practices section with ✅ good and ❌ bad examples
  - Fix for 5 common HTML issues: escaped tags, broken checkboxes, malformed lists, code blocks, formatting
  - **Impact**: Reduces work item formatting failures from 10.5% to <1%
- **azure-devops and git-pr-specialist File Attachment Support** (Issue #13):
  - Added Azure DevOps file attachment workflow documentation
  - Local path detection patterns for macOS, Windows, Linux paths
  - User prompting for attachment uploads vs local path references
  - Complete workflow: Upload file → Get URL → Link to work item → Reference in description
  - API reference for Azure DevOps attachments with authentication
  - Best practices for file naming, security (PAT permissions), size limits (60-130MB)
  - **Impact**: Enables team collaboration by replacing broken local paths with proper attachments
- **claude-code-plugin-builder Agent Enhancement** (345 lines added, 70% increase):
  - **Phase 3.5: Asset Preparation**: Icon, screenshots, GitHub raw URL hosting
  - **Manifest Validation**: `claude plugin validate` commands with error fixes
  - **marketplace.json Formats Clarified**:
    - Format 1: Marketplace Catalog (self-hosting on GitHub/GitLab/Azure DevOps)
    - Format 2: Submission Metadata (official marketplace submission)
  - **Distribution Options**: Comprehensive guide for 3 distribution methods
  - **Enterprise & Corporate Distribution**: Azure DevOps, GitLab, GitHub Enterprise setup
  - **Staged Distribution Strategy**: Day 1 (GitHub) → Week 1 (Official) → Week 2 (Community)
  - **"When to Use" Updated**: 5 new marketplace-specific use cases
- **marketplace.json Restructure**:
  - Converted from submission metadata to marketplace catalog format
  - Changed name to kebab-case: `claude-agents-marketplace`
  - Added `owner`, `metadata.description`, `plugins` array
  - Now passes validation: ✔ `claude plugin validate .claude-plugin/marketplace.json`
  - Original rich metadata preserved in `.claude-plugin/submission-metadata.json`
- **plugin.json Validation Fixes**:
  - Updated version: 1.4.0 → 1.5.0
  - Fixed author field: string → object format with name, email, url
  - Updated repository URLs: stijnwillems → doozMen
  - Now passes validation: ✔ `claude plugin validate .claude-plugin/plugin.json`

### Fixed
- **Azure DevOps Private Marketplace Investigation**:
  - Created Task #43607 under work item #43272 (CORE - iOS - Integration IA)
  - Documented that Azure Marketplace does NOT support Claude Code plugins
  - Confirmed Azure DevOps Git repos CAN host private marketplaces
  - Assigned to stijn.willems@rossel.be for corporate distribution research

## [1.5.0] - 2025-10-15

### Added
- **Claude Code Plugin Builder Agent**:
  - `claude-code-plugin-builder`: Expert in creating Claude Code plugins with commands, agents, hooks, and MCP servers (Sonnet model)
    - Complete plugin lifecycle from development to marketplace distribution
    - Plugin manifest creation (plugin.json) with schema validation
    - Marketplace manifest creation (marketplace.json) for plugin catalogs
    - Custom slash command development (markdown with frontmatter)
    - Subagent creation (specialized agent markdown files)
    - Hook configuration (event handlers for automation)
    - MCP server integration (external tool connections with ${CLAUDE_PLUGIN_ROOT})
    - Local testing workflows with development marketplaces
    - Distribution strategies (GitHub, GitLab, local)
    - Team plugin workflows and repository-level configuration
    - Comprehensive debugging and validation guidance
- **Agent Library**: 43 total agents (+1 from previous 42)

- **Plugin Infrastructure for Marketplace Distribution**:
  - `.claude-plugin/plugin.json`: Complete plugin manifest with all 43 agents
    - Categorized agents: swift-development (15), testing-quality (7), xcode-build (3), documentation (5), devops-cicd (2), firebase-analytics (5), content-publishing (4), specialized-tools (6), architecture (2)
    - Installation scripts with pre/post hooks for automated setup
    - Features metadata: Smart routing, MCP integration, cost optimization
    - Requirements: macOS 13.0+, Swift 6.1+, Claude Code 1.0+
  - `.claude-plugin/marketplace.json`: Official marketplace submission metadata
    - Comprehensive long description detailing all 43 agents by category
    - 8 feature highlights with icons and descriptions
    - Installation workflow (5 steps + quick install command)
    - Screenshots placeholders for marketplace listing
    - Metadata: 43 agents, 97.2% test coverage, 3-80x performance
    - Tags and categories for discoverability
  - Development marketplace setup at `~/claude-marketplaces/dev-marketplace/`
    - `catalog.json`: Local plugin catalog for testing
    - README with setup instructions and testing workflow
    - Enables local plugin testing before distribution
  - `assets/`: Directory for marketplace images (icon, screenshots)
    - README with design guidelines and requirements
    - Placeholder structure for icon.png and 3 screenshots

### Changed
- **Model Distribution**: 1 Opus, 31 Sonnet, 11 Haiku agents
- **Git Configuration**: Updated `.gitignore` to track plugin manifests
  - `.claude/` remains ignored (user settings)
  - `!.claude-plugin/` exception added (plugin manifests tracked)
  - Ensures plugin infrastructure is version controlled

## [1.4.0 + MCP Integration] - experiment/mcp merged to main

### Added
- **MCP Server Integration** (SwiftLens + Context7):
  - SwiftLens MCP server for semantic-level Swift code analysis using SourceKit-LSP
    - 15 tools: Single-file analysis, cross-file navigation, symbol references, code modification
    - Integration with Apple's SourceKit-LSP for compiler-grade accuracy
    - Token-optimized output for efficient AI interactions
    - Installed via `uvx swiftlens` in tools/swiftlens/
  - Context7 MCP server for up-to-date API documentation and code examples
    - Version-specific documentation from official sources
    - 2 tools: Library ID resolution and documentation retrieval
    - Installed via `npx -y @upstash/context7-mcp`
  - Agent-local MCP deployment pattern with `.mcp.json` configuration
  - Automation hook (`tools/auto-rebuild-swift-index.sh`) for SwiftLens index rebuilding
    - 15-minute cooldown mechanism to prevent excessive builds
    - Lock file pattern for concurrent execution prevention
    - Automatic triggering on .swift file Write/Edit operations
  - Comprehensive documentation:
    - `docs/MCP-SETUP.md`: Full setup guide (352 lines)
    - `QUICKSTART-MCP.md`: Quick reference (184 lines)
    - Troubleshooting section for common issues
    - Deployment pattern comparison (agent-local vs project-local vs global)
- **Agent Model Enhancement**:
  - Added `mcp` field to Agent model for MCP server metadata
  - Parses comma-separated MCP server lists from agent frontmatter
  - 15 agents now reference MCP servers (swiftlens, context7, github, gitlab, azure-devops, owl-intelligence)
- **WARP.md Symlink**: Added symlink to CLAUDE.md for Warp terminal compatibility

### Changed
- Updated `.gitignore` to exclude MCP server installations and temporary files
  - `tools/swiftlens/` directory (git clone)
  - `/tmp/swiftlens-rebuild-*` temporary files
- Enhanced Agent.swift with MCP server parsing (maintains Swift 6 Sendable conformance)

### Architecture
- **Agent-Local MCP Deployment Pattern**:
  - MCP servers scoped to specific agents via frontmatter (`mcp: swiftlens, context7`)
  - Isolated per agent - each agent has independent MCP server instances
  - Alternative project-local pattern documented for shared usage
  - Configuration via `.mcp.json` in worktree root
- **Automation Hook Design**:
  - PostToolUse hook pattern for SwiftLens index rebuilding
  - Bash-based implementation with graceful error handling
  - Opt-in activation via `~/.claude/settings.json`
  - No automatic tool execution (notification-only, respects user approval)

### Infrastructure
- **Dependencies**:
  - Python 3.10+ with `uv` package manager (installed to `~/.local/bin/uvx`)
  - Node.js 18+ with `npx` (via nvm)
  - Xcode with SourceKit-LSP (required for SwiftLens)
  - jq for JSON parsing in automation hooks (with fallback)
- **Verification**: All tooling verified production-ready by swift-mcp-server-writer agent
- **Architecture Review**: Approved by swift-architect agent with recommendations implemented

### Technical Details
- **SwiftLens Index Building**: Requires `swift build -Xswiftc -index-store-path -Xswiftc .build/index/store`
- **MCP Server Tools**: 17 total tools (15 SwiftLens + 2 Context7)
- **Path Configuration**: Absolute paths to uvx/npx with environment PATH configuration
- **Cooldown Strategy**: 900 seconds (15 minutes) between automatic index rebuilds

## [1.4.0] - 2025-10-14

### Added
- **Generic Cross-Language Agents** (3 new agents):
  - Agent routing now handled directly via edgeprompt MCP (83% accuracy, 80% cost reduction)
    - Direct MCP calls more efficient than agent wrappers
    - On-device LLM analysis for intelligent task routing
    - Zero API cost using local Apple Foundation models
    - Semantic matching for agent selection
  - `architect`: System architecture and design patterns expert (Opus model)
    - Language-agnostic architecture decisions and system design
    - Distributed systems, microservices, event-driven architectures
    - Domain-driven design, SOLID principles, design patterns
    - Technology selection and migration strategies
  - `test-builder`: Creates comprehensive test suites efficiently (Haiku model)
    - Support for all major testing frameworks across languages
    - Unit, integration, E2E, performance, and property-based testing
    - Coverage strategies and test documentation
    - Test maintenance and refactoring patterns
  - `code-reviewer`: Thorough code reviews with actionable feedback (Sonnet model)
    - Multi-language support with language-specific patterns
    - Security, performance, and code quality analysis
    - Prioritized feedback levels (Critical/Important/Suggestion)
    - Constructive feedback with specific examples

- **Swift CLI Development Agents** (2 new agents):
  - `swift-cli-installer`: Automate Swift CLI tool build and installation (Haiku model)
    - Handles experimental-install workflow and PATH setup
    - Common build issues and validation flag patterns
    - Cross-compilation support for Linux builds on macOS
    - Package.swift configurations for CLI tools
  - `swift-build-runner`: Efficiently execute Swift builds and tests (Haiku model)
    - Fast compilation feedback and test execution
    - Build system optimization and caching strategies
    - Error parsing and actionable feedback
    - CI/CD integration patterns

- **Swift Code Quality Agent**:
  - `swift-format-specialist`: Swift 6 native code formatting (Haiku model)
    - Uses built-in `swift format` tool (no external dependencies)
    - Lint mode for checking formatting issues
    - Auto-fix mode for correcting formatting
    - Project-wide formatting consistency

- **Documentation Infrastructure**:
  - Restructured documentation into `docs/` folder for better organization
  - `docs/AGENTS.md`: Comprehensive catalog of all 42 agents
  - `docs/ARCHITECTURE.md`: Technical architecture and design details
  - `docs/CONTRIBUTING.md`: Contribution guidelines and agent standards
  - Moved `CLAUDE_CODE_GUIDE.md` and `SECRETS.md` to docs/

### Changed
- **Agent Library Growth**: Expanded from 35 to 42 agents (+7 new agents)
- **Model Distribution**: Strategic optimization with 1 Opus, 30 Sonnet, 11 Haiku agents
- **README.md**: Complete redesign with developer-friendly quick start
  - Immediate quick start commands at the top
  - Featured agents section highlighting new additions
  - Popular agent combinations for common use cases
  - Reduced to essential information with links to detailed docs
- **CLAUDE.md**: Streamlined for AI assistance
  - Concise project context and architecture overview
  - Quick reference tables for key files and commands
  - Recent changes tracking for context awareness
  - Removed verbose explanations in favor of actionable information
- **Renamed Agents**:
  - `documentation-writer` → `swift-docc` for clarity on Swift DocC specialization

### Architecture
- **OWL Intelligence Integration** (Implemented):
  - Local LLM-based agent routing using Apple's Foundation models
  - MCP server for semantic agent matching with 79% average relevance
  - 6-9x faster routing decisions (<150ms vs 2-5s)
  - Privacy-preserving with zero API costs
  - 42/42 agents discovered with 100% agent injection accuracy

### Fixed
- Removed duplicate agents from global installation directory
- Cleaned up old renamed agents (documentation-writer, ghost-blogger, etc.)
- Verified exactly 42 unique agents in library

## [1.3.0] - 2025-10-14

### Changed
- **Agent Library Optimization**: Reduced from 37 to 35 agents with improved consistency
  - Merged `ghost-blogger` + `ghost-publisher` → `ghost-specialist` for unified Ghost CMS workflow
  - Renamed `testing-specialist` → `swift-testing-specialist` for naming consistency
  - Renamed `azure-devops-specialist-template` → `azure-devops` for simpler, clearer naming
  - Deleted `firebase-companya-ecosystem-analyzer` (100% duplicate of firebase-ecosystem-analyzer)
  - **Cost Optimization**: Migrated 6 agents to Haiku model (93% cost reduction: $15/M → $1/M tokens)
    - `deckset-presenter`: Template-based presentation generation
    - `xib-storyboard-specialist`: Interface Builder operations
    - `secrets-manager`: Deterministic secrets operations
    - `spm-specialist`: Package.swift manipulation
    - `xcode-configuration-specialist`: Build settings operations
    - `conference-specialist`: Conference data retrieval

### Added
- **ghost-specialist**: Comprehensive Ghost CMS agent combining content creation and technical publishing
  - Content creation workflows from ghost-blogger (conference posts, reviews, Belgian writing style)
  - Technical publishing mechanics from ghost-publisher (HTML conversion, duplicate detection, validation)
  - Critical markdown-to-HTML conversion workflow using `npx marked`
  - Complete Ghost MCP integration with create, update, search, and validation tools
  - Belgian direct writing style guidelines and content quality standards
  - Tag management strategy and excerpt writing best practices

### Removed
- **ghost-blogger**: Merged into ghost-specialist
- **ghost-publisher**: Merged into ghost-specialist
- **firebase-companya-ecosystem-analyzer**: Removed duplicate agent
- **testing-specialist**: Renamed to swift-testing-specialist

### Fixed
- **azure-devops-specialist-template**: Added file upload workflow instructions
  - Step-by-step workflow: Upload files → Link to work item → Add comment with references
  - Complete working examples using `az rest` for file uploads
  - Basic auth pattern with base64 encoding for Azure DevOps REST API
  - Best practices for file attachment workflow integration

## [1.2.2] - 2025-10-14

### Fixed
- **azure-devops-specialist-template**: Fixed critical markdown escaping bug in work item comments
  - **Root Cause**: Azure CLI `--discussion` parameter triple-escapes markdown characters (e.g., `\#` → `\\\#`), rendering comments as broken raw text in Azure DevOps UI
  - **Impact**: Comments would display as `\\## Header` instead of formatted headers
  - **Solution**: Use `az devops invoke` with JSON files instead of `--discussion` parameter to bypass escaping bug
  - **Reference**: Azure CLI GitHub issue #1462 (Microsoft confirmed bug)
  - Added comprehensive "Work Item Comment Escaping Bug" section with working patterns
  - Added helper function pattern for reusable markdown comments
  - Added debugging guide and migration path for when Microsoft fixes the bug
  - Updated all examples to avoid broken `--discussion` parameter with markdown
  - Added critical tool restrictions: NEVER use curl (except file attachments), ONLY use `az` CLI

### Changed
- **azure-devops-specialist-template**: Enhanced agent documentation and guidelines
  - Updated agent description to emphasize proper markdown formatting
  - Added "Critical Tool Restrictions" section mandating Azure CLI (`az`) usage
  - Updated "Working Azure CLI Examples" to remove broken patterns
  - Updated "Quick Reference" with correct approach using `az devops invoke`
  - Updated "Critical Rules" and "Markdown Usage" guidelines with escaping workarounds
- **git-pr-specialist**: Minor refinements to draft MR workflow documentation
  - Clarified `--ready` and `--draft` flag usage for both numbered and current branch MRs
  - Added shorthand `-r` flag documentation
  - Added draft MR status checking commands
  - Improved draft MR use case descriptions

## [1.2.1] - 2025-10-14

### Added
- **Automatic Dependency Installation Prompts**: InstallCommand now checks for missing CLI dependencies after successful agent installation
  - Automatically detects missing CLI tools required by installed agents
  - Interactive prompt: "Would you like to install missing dependencies now? (y/n)"
  - Installs via Homebrew using existing DependencyService
  - Special handling for Azure CLI with post-install authentication tip: "Run 'az login' to authenticate with Azure DevOps"
  - Respects --force flag: skips interactive prompts and shows tip to use `claude-agents doctor --install` instead
- **Azure CLI Dependency Support**: Added azure-cli to predefined CLIDependency list
  - Dependency ID: `azure-cli`
  - Check command: `which az`
  - Homebrew formula: `azure-cli`
  - Used by: `azure-devops-specialist-template` agent
- **Agent Dependency Metadata**: Added `dependencies: azure-cli` to azure-devops-specialist-template.md frontmatter

### Changed
- Enhanced InstallCommand to provide seamless dependency installation workflow
- Improved user experience: install agents and their required CLI tools in one flow
- Version bumped to 1.2.1

### Behavior
- **Default Behavior**: After installing agents with dependencies, CLI checks for missing tools and prompts to install
- **With --force**: Skips interactive prompts, shows tip to use `claude-agents doctor --install`
- **No Dependencies**: Agents without dependencies don't trigger any prompts

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
    - Real-world example: swift-agents-plugin architecture documentation
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
- Initial release of swift-agents-plugin
- DoctorCommand for checking CLI tool dependencies
- Basic agent management (list, install, uninstall)
- 22 initial embedded agents
- Global and local installation targets
- Interactive prompts for safe operations

[1.5.0]: https://github.com/doozMen/swift-agents-plugin/compare/v1.4.0...v1.5.0
[1.4.0]: https://github.com/doozMen/swift-agents-plugin/compare/v1.3.0...v1.4.0
[1.3.0]: https://github.com/doozMen/swift-agents-plugin/compare/v1.2.2...v1.3.0
[1.2.2]: https://github.com/doozMen/swift-agents-plugin/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/doozMen/swift-agents-plugin/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/doozMen/swift-agents-plugin/compare/v1.1.1...v1.2.0
[1.1.1]: https://github.com/doozMen/swift-agents-plugin/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/doozMen/swift-agents-plugin/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/doozMen/swift-agents-plugin/compare/v0.0.1...v1.0.0
[0.0.1]: https://github.com/doozMen/swift-agents-plugin/releases/tag/v0.0.1
