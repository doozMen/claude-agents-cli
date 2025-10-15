# Swift Agents Plugin - Agent Catalog

**Version**: 1.5.1
**Last Updated**: 2025-10-15
**Total Agents**: 44

## Overview

This catalog documents all 44 production-ready agents available through the swift-agents-plugin. Each agent is a specialized markdown file designed to work with Claude Code, providing focused expertise across Swift development, testing, documentation, DevOps, Firebase, content publishing, and specialized tools.

## Model Distribution

- **Opus (2)**: Complex architectural decisions and system design
- **Sonnet (30)**: Feature implementation, code writing, and most development tasks
- **Haiku (12)**: Fast mechanical operations (formatting, builds, installation)

## Agent Categories

1. [Swift Development](#swift-development) - 16 agents
2. [Testing & Quality](#testing--quality) - 7 agents
3. [Xcode & Build Configuration](#xcode--build-configuration) - 2 agents
4. [Documentation](#documentation) - 5 agents
5. [Git & DevOps](#git--devops) - 2 agents
6. [Firebase & Analytics](#firebase--analytics) - 5 agents
7. [Content & Publishing](#content--publishing) - 3 agents
8. [Specialized Tools](#specialized-tools) - 4 agents
9. [Agent Orchestration](#agent-orchestration) - 1 agent

---

## Quick Reference Table

| Agent Name | Model | Primary Focus |
|-----------|-------|---------------|
| swift-architect | Opus | Architecture patterns, async/await, actors |
| swift-developer | Sonnet | Feature implementation, code writing |
| swift-modernizer | Sonnet | Swift 6.0 migration, concurrency patterns |
| swift-cli-tool-builder | Sonnet | Building CLI tools with ArgumentParser |
| swift-server | Sonnet | Server-side Swift (Vapor, Hummingbird) |
| swiftui-specialist | Sonnet | SwiftUI development, state management |
| kmm-specialist | Sonnet | Kotlin Multiplatform Mobile integration |
| spm-specialist | Haiku | Swift Package Manager configuration |
| hummingbird-developer | Sonnet | Lightweight HTTP services |
| swift-grpc-temporal-developer | Sonnet | gRPC v2 streaming, Temporal workflows |
| grdb-sqlite-specialist | Sonnet | Type-safe SQLite with GRDB |
| swift-mcp-server-writer | Sonnet | MCP server development |
| swift-state-machine-specialist | Sonnet | Enum-based, noncopyable typestates |
| swift-testing-xcode-specialist | Sonnet | Swift Testing + Xcode integration |
| xib-storyboard-specialist | Haiku | Interface Builder, xib/storyboard |
| testing-specialist | Sonnet | Test strategy, Swift Testing framework |
| swift-build-runner | Haiku | Build execution, test running |
| swift-format-specialist | Haiku | Code formatting with `swift format` |
| test-builder | Haiku | Rapid test suite creation |
| code-reviewer | Sonnet | Comprehensive code review |
| technical-debt-eliminator | Sonnet | Refactoring, code quality |
| documentation-verifier | Sonnet | Documentation quality assurance |
| xcode-configuration-specialist | Sonnet | Xcode projects, build settings |
| swift-docc | Sonnet | Swift DocC documentation |
| technical-documentation-reviewer | Sonnet | Technical doc review |
| deckset-presenter | Sonnet | Deckset presentation creation |
| git-pr-specialist | Sonnet | PR workflows, GitLab/GitHub |
| azure-devops | Sonnet | Azure DevOps integration |
| firebase-ecosystem-analyzer | Sonnet | Firebase service analysis |
| crashlytics-analyzer | Sonnet | Crashlytics crash analysis |
| crashlytics-cross-app-analyzer | Sonnet | Multi-app crash patterns |
| crashlytics-architecture-correlator | Sonnet | Architecture impact analysis |
| crashlytics-multiclone-analyzer | Sonnet | Multi-clone app crash correlation |
| blog-content-writer | Sonnet | Technical blog posts |
| ghost-specialist | Sonnet | Ghost CMS publishing |
| conference-specialist | Sonnet | Conference talks, proposals |
| agent-writer | Sonnet | Create new agent markdown files |
| secrets-manager | Sonnet | macOS Keychain integration |
| timestory-builder | Sonnet | TimeStory timeline creation |
| swift-cli-installer | Haiku | CLI installation automation |
| claude-code-plugin-builder | Sonnet | Build Claude Code plugins |
| generic-assistant | Sonnet | General-purpose assistant |
| release-manager | Sonnet | Release management workflow |
| architect | Opus | System architecture (advanced) |

---

## Swift Development

### 1. swift-architect
- **Model**: Opus
- **Description**: Specialized in Swift 6.0 architecture patterns, async/await, actors, and modern iOS development
- **Tools**: Read, Edit, Glob, Grep, Bash, MultiEdit
- **Expertise**:
  - Swift 6.0 concurrency (async/await, actors, Sendable)
  - Architecture patterns (MVVM, Clean Architecture)
  - Performance optimization
  - SwiftUI & UIKit integration
  - Dependency injection (@Entry macro)
  - Type-safe design systems (W3C Design Tokens)
  - CommonInjector DI pattern
- **Use When**: Designing system architecture, choosing design patterns, async/await strategies

### 2. swift-developer
- **Model**: Sonnet
- **Description**: Expert Swift developer for implementing features, writing code, and building iOS functionality
- **Tools**: Read, Edit, Glob, Grep, Bash, MultiEdit
- **Dependencies**: swift-format
- **Expertise**:
  - Feature implementation
  - Swift 6.0 development
  - UIKit & SwiftUI mixed development
  - Networking & data persistence
  - Actor isolation
  - Type-safe design systems
- **Use When**: Implementing features, writing production code, integrating APIs

### 3. swift-modernizer
- **Model**: Sonnet
- **Description**: Focused on migrating legacy code to Swift 6.0 and adopting modern iOS development practices
- **Tools**: Read, Edit, Glob, Grep, Bash, MultiEdit, WebSearch
- **Expertise**:
  - Swift 6.0 migration
  - Concurrency migration (callbacks → async/await)
  - API modernization
  - Incremental refactoring
  - RxSwift → async/await
  - Alamofire → URLSession
- **Use When**: Modernizing legacy codebases, adopting Swift 6.0 features, refactoring old patterns

### 4. swift-cli-tool-builder
- **Model**: Sonnet
- **Description**: Expert in creating Swift CLI tools with ArgumentParser, Subprocess, resource embedding, and SPM experimental-install distribution
- **Tools**: Read, Edit, Glob, Grep, Bash, MultiEdit, WebSearch
- **Expertise**:
  - Swift Argument Parser
  - Subprocess command execution
  - Resource embedding
  - experimental-install distribution
  - Actor-based concurrency
  - @main entry point pattern
- **Use When**: Building CLI tools, agent distribution systems, developer utilities

### 5. swift-server
- **Model**: Sonnet
- **Description**: Server-side Swift development expert leveraging tech-conf-mcp for learning guidance and best practices
- **Tools**: Read, Edit, Grep, Glob, Bash, WebSearch
- **MCP**: tech-conf-mcp
- **Expertise**:
  - Vapor 4.x framework
  - Hummingbird lightweight services
  - SwiftNIO event-driven architecture
  - RESTful APIs, GraphQL, gRPC
  - Database integration (Fluent ORM, PostgreSQL, MongoDB, Redis)
  - Docker deployment, Kubernetes
- **Use When**: Building server-side Swift applications, RESTful APIs, microservices

### 6. swiftui-specialist
- **Model**: Sonnet
- **Description**: Expert in SwiftUI app development, state management, and modern iOS UI patterns
- **Tools**: Read, Edit, Glob, Grep, Bash, MultiEdit
- **Dependencies**: swift-format
- **Expertise**:
  - Declarative UI with SwiftUI
  - State management (@State, @Binding, @Observable)
  - NavigationStack patterns
  - Performance optimization
  - Accessibility (VoiceOver, Dynamic Type)
  - Animations and transitions
- **Use When**: Building SwiftUI views, implementing MVVM patterns, optimizing UI performance

### 7. kmm-specialist
- **Model**: Sonnet
- **Description**: Expert in Kotlin Multiplatform Mobile and iOS-Kotlin integration patterns
- **Tools**: Read, Edit, Glob, Grep, Bash, MultiEdit
- **Expertise**:
  - KMM minimal implementation pattern
  - Swift-Kotlin interoperability
  - CommonInjector DI bridge
  - Kodein DI integration
  - GitLab private dependencies
- **Use When**: Integrating KMM with iOS, troubleshooting syncFramework, bridging Kotlin services

### 8. spm-specialist
- **Model**: Haiku
- **Description**: Expert in Swift Package Manager for iOS, dependency management, Package.swift authoring, and SPM build optimization
- **Tools**: Read, Edit, Glob, Grep, Bash
- **Expertise**:
  - Package.swift authoring
  - Dependency resolution
  - CocoaPods → SPM migration
  - Binary framework integration
  - Build optimization
- **Use When**: Configuring Package.swift, resolving dependency conflicts, migrating from CocoaPods

### 9. hummingbird-developer
- **Model**: Sonnet
- **Description**: Lightweight Swift HTTP server expert using Hummingbird framework for modern APIs
- **Tools**: Read, Edit, Glob, Grep, Bash, MultiEdit, WebSearch
- **Expertise**:
  - Hummingbird 2.x framework
  - Async/await first-class support
  - Middleware patterns
  - RESTful API design
  - JSON handling with Codable
- **Use When**: Building lightweight microservices, high-performance HTTP APIs, minimal-dependency services

### 10. swift-grpc-temporal-developer
- **Model**: Sonnet
- **Description**: Expert in Swift gRPC v2 streaming and Temporal workflows for production services
- **Tools**: Read, Edit, Glob, Grep, Bash, MultiEdit, WebSearch
- **Expertise**:
  - Swift gRPC v2 bidirectional streaming
  - Protocol Buffers schema design
  - Temporal workflow orchestration
  - TLS/SSL configuration
  - Connection management
- **Use When**: Implementing gRPC services, bidirectional streaming, workflow orchestration

### 11. grdb-sqlite-specialist
- **Model**: Sonnet
- **Description**: Expert in type-safe SQLite with GRDB for Swift actor-based persistence
- **Tools**: Read, Edit, Glob, Grep, Bash, MultiEdit
- **Expertise**:
  - GRDB.swift library mastery
  - Actor-based database access
  - Type-safe query builders
  - Database migrations
  - Performance optimization (indexing, query optimization)
- **Use When**: Implementing local persistence, database migrations, optimizing queries

### 12. swift-mcp-server-writer
- **Model**: Sonnet
- **Description**: Expert in creating MCP servers using Swift 6.0+ and official MCP Swift SDK for time tracking ecosystem
- **Tools**: Read, Edit, Glob, Grep, Bash, MultiEdit
- **Expertise**:
  - MCP Protocol 2024-11-05
  - Swift 6.0+ actor concurrency
  - MCP Swift SDK
  - AsyncHTTPClient for RESTful APIs
  - Database integration (GRDB)
- **Use When**: Building MCP servers, integrating APIs into Claude ecosystem, time tracking tools

### 13. swift-state-machine-specialist
- **Model**: Sonnet
- **Description**: Expert in Swift state machines using enums, non-copyable types, and typestate patterns for compile-time safety
- **Tools**: Read, Edit, Glob, Grep, Bash, MultiEdit, WebSearch
- **Expertise**:
  - Enum-based state machines
  - Non-copyable types (~Copyable)
  - Typestate pattern
  - Move semantics
  - Consuming/borrowing functions
- **Use When**: Implementing workflows with state transitions, preventing invalid states, one-time operations

### 14. swift-testing-xcode-specialist
- **Model**: Sonnet
- **Description**: Expert in Swift Testing framework integration with Xcode projects and SPM packages
- **Tools**: Read, Edit, Glob, Grep, Bash, MultiEdit
- **Expertise**:
  - Swift Testing framework (@Test, @Suite)
  - Xcode integration
  - SPM package testing
  - Xcode Test Plans
  - CI/CD integration (GitHub Actions, Bitrise)
- **Use When**: Configuring Swift Testing in Xcode, setting up test plans, CI integration

### 15. xib-storyboard-specialist
- **Model**: Haiku
- **Description**: Expert in iOS Interface Builder, xib/storyboard editing, and programmatic UI bridging
- **Tools**: Read, Edit, Bash, Glob, Grep
- **Expertise**:
  - Interface Builder fundamentals
  - Auto Layout configuration
  - Programmatic loading (UIStoryboard, Bundle.loadNibNamed)
  - IBDesignable/IBInspectable
  - Migration to SwiftUI
- **Use When**: Working with legacy Interface Builder files, troubleshooting xib/storyboard loading, migrating to SwiftUI

### 16. swift-state-machine-specialist
- **Model**: Sonnet
- **Description**: Specialized in Swift state machines using advanced enum patterns, noncopyable types, and compile-time safety
- **Tools**: Read, Edit, Glob, Grep, Bash, MultiEdit, WebSearch
- **Use When**: Building complex state machines, ensuring compile-time state validity

---

## Testing & Quality

### 17. testing-specialist
- **Model**: Sonnet
- **Description**: Master of Swift Testing framework, test strategy, and modern iOS testing patterns
- **Tools**: Read, Edit, Glob, Grep, Bash, MultiEdit
- **Use When**: Designing test architecture, writing comprehensive test suites

### 18. swift-build-runner
- **Model**: Haiku
- **Description**: Efficiently executes Swift builds and tests using Haiku for fast compilation
- **Tools**: Bash, Read, Grep
- **MCP**: owl-intelligence
- **Use When**: Running builds and tests quickly, CI pipeline execution

### 19. swift-format-specialist
- **Model**: Haiku
- **Description**: Swift 6 code formatting and style enforcement using built-in `swift format` tool
- **Tools**: Bash, Read, Edit, Glob, Grep
- **Use When**: Enforcing code style, pre-commit formatting, CI formatting checks

### 20. test-builder
- **Model**: Haiku
- **Description**: Creates comprehensive test suites in any language efficiently
- **Tools**: Read, Edit, Glob, Grep, MultiEdit
- **Use When**: Rapidly creating test suites, improving test coverage

### 21. code-reviewer
- **Model**: Sonnet
- **Description**: Comprehensive code review with actionable feedback across all languages
- **Tools**: Read, Grep, Glob, WebSearch
- **Use When**: Performing code reviews, identifying security issues, suggesting improvements

### 22. technical-debt-eliminator
- **Model**: Sonnet
- **Description**: Focused on refactoring, code quality improvement, and reducing technical debt
- **Tools**: Read, Edit, Glob, Grep, Bash, MultiEdit
- **Use When**: Refactoring legacy code, improving code quality, reducing complexity

### 23. documentation-verifier
- **Model**: Sonnet
- **Description**: Documentation quality assurance and style validation expert
- **Tools**: Read, Grep, Glob
- **Use When**: Validating documentation quality, checking for broken links, ensuring consistency

---

## Xcode & Build Configuration

### 24. xcode-configuration-specialist
- **Model**: Sonnet
- **Description**: Expert in Xcode projects, build settings, multi-target configuration, and SDK integration
- **Tools**: Read, Edit, Bash, Glob, Grep
- **Use When**: Configuring Xcode build settings, multi-target projects, SDK integration

### 25. xib-storyboard-specialist
- **Model**: Haiku
- **Description**: Interface Builder expert for xib/storyboard files and programmatic UI bridging
- **Tools**: Read, Edit, Bash, Glob, Grep
- **Use When**: Working with Interface Builder files, Auto Layout configuration

---

## Documentation

### 26. swift-docc
- **Model**: Sonnet
- **Description**: Swift DocC expert for API documentation and iOS architecture documentation
- **Tools**: Read, Edit, Glob, Grep, Bash, WebSearch
- **Use When**: Creating API documentation, building DocC sites, documenting architecture

### 27. documentation-verifier
- **Model**: Sonnet
- **Description**: Documentation quality assurance and consistency validation
- **Tools**: Read, Grep, Glob
- **Use When**: Validating documentation, checking for completeness, ensuring style consistency

### 28. technical-documentation-reviewer
- **Model**: Sonnet
- **Description**: Technical documentation review and quality feedback specialist
- **Tools**: Read, Grep, Glob
- **Use When**: Reviewing technical docs, improving clarity, ensuring accuracy

### 29. deckset-presenter
- **Model**: Sonnet
- **Description**: Transform documentation into Deckset presentations
- **Tools**: Read, Edit, Glob, Grep
- **Use When**: Creating presentations from docs, conference talks, internal demos

### 30. agent-writer
- **Model**: Sonnet
- **Description**: Create new Claude agent markdown files with proper structure
- **Tools**: Read, Edit, Glob, Grep, Bash
- **Use When**: Creating new agents, documenting agent patterns

---

## Git & DevOps

### 31. git-pr-specialist
- **Model**: Sonnet
- **Description**: Expert in PR/MR workflows for GitLab, GitHub, and Azure DevOps
- **Tools**: Read, Grep, Bash, WebSearch
- **MCP**: gitlab, github, azure-devops
- **Use When**: Creating PRs, managing GitLab/GitHub workflows, code review processes

### 32. azure-devops
- **Model**: Sonnet
- **Description**: Azure DevOps integration specialist
- **Tools**: Read, Grep, Bash, WebSearch
- **MCP**: azure-devops
- **Use When**: Working with Azure DevOps pipelines, work items, repositories

---

## Firebase & Analytics

### 33. firebase-ecosystem-analyzer
- **Model**: Sonnet
- **Description**: Firebase service analysis and integration expert
- **Tools**: Read, Grep, Glob, WebSearch
- **Use When**: Analyzing Firebase integration, optimizing Firebase usage

### 34. crashlytics-analyzer
- **Model**: Sonnet
- **Description**: Crashlytics crash analysis and debugging specialist (OWL-enhanced)
- **Tools**: Read, Grep, Glob
- **MCP**: owl-intelligence
- **Use When**: Analyzing crash reports, identifying crash patterns

### 35. crashlytics-cross-app-analyzer
- **Model**: Sonnet
- **Description**: Multi-app Crashlytics pattern analysis
- **Tools**: Read, Grep, Glob
- **Use When**: Analyzing crashes across multiple apps, identifying shared issues

### 36. crashlytics-architecture-correlator
- **Model**: Sonnet
- **Description**: Architecture impact analysis for crashes
- **Tools**: Read, Grep, Glob
- **Use When**: Correlating crashes with architectural decisions

### 37. crashlytics-multiclone-analyzer
- **Model**: Sonnet
- **Description**: Multi-clone app crash correlation specialist
- **Tools**: Read, Grep, Glob
- **Use When**: Analyzing crashes in multi-clone app architectures

---

## Content & Publishing

### 38. blog-content-writer
- **Model**: Sonnet
- **Description**: Technical blog post and article writer
- **Tools**: Read, Edit, WebSearch
- **Use When**: Writing technical blog posts, creating tutorials, documentation articles

### 39. ghost-specialist
- **Model**: Sonnet
- **Description**: Ghost CMS publishing workflow expert
- **Tools**: Read, Edit, Bash, WebSearch
- **Use When**: Publishing to Ghost CMS, managing blog content

### 40. conference-specialist
- **Model**: Sonnet
- **Description**: Conference talks, proposals, and speaking engagement specialist
- **Tools**: Read, Edit, WebSearch
- **Use When**: Creating conference proposals, preparing talks, speaking guidance

---

## Specialized Tools

### 41. secrets-manager
- **Model**: Sonnet
- **Description**: Secure secrets management with macOS Keychain integration
- **Tools**: Read, Edit, Bash
- **Use When**: Managing secrets, Keychain integration, secure credential storage

### 42. timestory-builder
- **Model**: Sonnet
- **Description**: TimeStory timeline creation and management
- **Tools**: Read, Edit, Bash
- **Use When**: Creating timelines, project planning, visualizing chronologies

### 43. swift-cli-installer
- **Model**: Haiku
- **Description**: Automate Swift CLI installation workflows
- **Tools**: Bash, Read
- **Use When**: Installing CLI tools, automating setup, distribution scripts

### 44. claude-code-plugin-builder
- **Model**: Sonnet
- **Description**: Build Claude Code plugins with proper structure
- **Tools**: Read, Edit, Glob, Grep, Bash, MultiEdit
- **Use When**: Creating Claude Code plugins, plugin.json configuration

---

## Agent Orchestration

### 45. architect
- **Model**: Opus
- **Description**: System architecture expert with advanced reasoning (high-level design)
- **Tools**: Read, Edit, Glob, Grep, Bash, WebSearch
- **Use When**: Complex architectural decisions, system design, technical strategy

---

## Installation by Category

### Swift Development Stack
```bash
claude-agents install \
  swift-architect \
  swift-developer \
  swift-modernizer \
  swift-cli-tool-builder \
  swift-server \
  swiftui-specialist \
  spm-specialist \
  --global
```

### Testing & Quality
```bash
claude-agents install \
  testing-specialist \
  swift-build-runner \
  swift-format-specialist \
  test-builder \
  code-reviewer \
  technical-debt-eliminator \
  --global
```

### Documentation
```bash
claude-agents install \
  swift-docc \
  documentation-verifier \
  technical-documentation-reviewer \
  deckset-presenter \
  --global
```

### Firebase & Analytics
```bash
claude-agents install \
  firebase-ecosystem-analyzer \
  crashlytics-analyzer \
  crashlytics-cross-app-analyzer \
  crashlytics-architecture-correlator \
  crashlytics-multiclone-analyzer \
  --global
```

### Full Installation
```bash
claude-agents install --all --global
```

---

## Usage Patterns

### For iOS Development
1. **swift-architect**: Design system architecture
2. **swift-developer**: Implement features
3. **swiftui-specialist**: Build UI components
4. **testing-specialist**: Write comprehensive tests
5. **swift-build-runner**: Execute builds and tests

### For Server-Side Swift
1. **swift-server**: Build REST APIs
2. **hummingbird-developer**: Lightweight microservices
3. **grdb-sqlite-specialist**: Database persistence
4. **swift-grpc-temporal-developer**: gRPC services
5. **testing-specialist**: Test server endpoints

### For Legacy Modernization
1. **swift-modernizer**: Migrate to Swift 6.0
2. **technical-debt-eliminator**: Refactor code
3. **testing-specialist**: Add test coverage
4. **code-reviewer**: Review changes
5. **swift-format-specialist**: Enforce style

### For CLI Tool Development
1. **swift-cli-tool-builder**: Build CLI structure
2. **spm-specialist**: Configure Package.swift
3. **swift-developer**: Implement commands
4. **testing-specialist**: Write tests
5. **swift-cli-installer**: Automate installation

---

## Agent Discovery

### List All Agents
```bash
claude-agents list --verbose
```

### Filter by Tool
```bash
claude-agents list --tool Bash
claude-agents list --tool WebSearch
```

### Check Installed Agents
```bash
claude-agents list --installed
claude-agents list --installed --target local
```

---

## Contributing

To add a new agent to the catalog:

1. Create agent markdown in `Sources/claude-agents-cli/Resources/agents/`
2. Include required YAML frontmatter (name, description, tools, model)
3. Follow existing agent patterns
4. Update this catalog
5. Rebuild and reinstall CLI

---

## Resources

- **CLI Repository**: [swift-agents-plugin](https://github.com/username/swift-agents-plugin)
- **Documentation**: [docs/](.)
- **Architecture Guide**: [ARCHITECTURE.md](ARCHITECTURE.md)
- **Contributing Guide**: [CONTRIBUTING.md](CONTRIBUTING.md)
- **Best Practices**: [CLAUDE_CODE_GUIDE.md](CLAUDE_CODE_GUIDE.md)

---

**Generated**: 2025-10-15
**CLI Version**: 1.4.0
**Total Agents**: 44
