# Claude Code Best Practices Guide

A comprehensive guide for developers new to Claude Code and agent-based development workflows.

## Table of Contents

1. [Introduction](#introduction)
2. [Getting Started with Claude Code](#getting-started-with-claude-code)
3. [Understanding Agents](#understanding-agents)
4. [Agent Best Practices](#agent-best-practices)
5. [Common Workflows](#common-workflows)
6. [Tips for Developers](#tips-for-developers)
7. [Resources](#resources)

---

## Introduction

### What is Claude Code?

Claude Code is an AI-powered development assistant that helps you write, review, refactor, and maintain code. Unlike traditional code completion tools, Claude Code can understand complex requirements, make architectural decisions, and execute multi-step workflows.

**Key Features:**
- Multi-file code editing and refactoring
- Shell command execution
- File system navigation and search
- Code analysis and review
- Documentation generation
- Test creation and execution

### What are Claude Agents?

Agents are specialized AI assistants with focused expertise in specific domains. Each agent is defined by a markdown file containing:
- **Domain expertise**: Specific technical knowledge (Swift, Xcode, testing, etc.)
- **Tool access**: Capabilities like file editing, bash commands, searches
- **Contextual awareness**: Project-specific patterns and conventions
- **Best practices**: Guidelines and constraints for the domain

### Why Use Agents?

**Specialization**: Instead of one generalist AI, you get focused experts for each task.

**Consistency**: Agents follow established patterns and project conventions.

**Efficiency**: Agents know the right tools and workflows for their domain.

**Example**: Instead of asking Claude to "help with Swift", you invoke:
- `@swift-architect` for architectural decisions
- `@swift-developer` for feature implementation
- `@swift-modernizer` for upgrading legacy code
- `@testing-specialist` for test strategies

---

## Getting Started with Claude Code

### Installation

Claude Code is available as a desktop application or CLI tool.

**Desktop Application:**
1. Download from [claude.ai/code](https://claude.ai/code)
2. Install and authenticate with your Anthropic account
3. Open a project directory

**Install Swift Agents Plugin Plugin:**

Complete installation with enhanced capabilities (recommended):
```bash
# Install the swift-agents-plugin plugin
/plugin marketplace add doozMen/swift-agents-plugin && /plugin install swift-agents-plugin@doozMen
```

This installs:
- **swift-agents-plugin**: 45 specialized AI agents for development tasks

**Enhanced Capabilities with edgeprompt MCP Server:**

For local LLM capabilities and privacy-preserving routing, also install edgeprompt MCP:

```bash
# Install edgeprompt MCP server
git clone https://github.com/doozMen/edgeprompt.git
cd edgeprompt
swift package experimental-install --product edgeprompt

# Configure in ~/.claude/claude_mcp_settings.json
```

**CLI (if available):**
```bash
# Installation method varies by platform
npm install -g @anthropic-ai/claude-code
# or
brew install claude-code
```

### Basic Usage

**Starting a Conversation:**
```
Open Claude Code in your project directory. The AI has access to:
- Your entire codebase (via Read, Glob, Grep tools)
- Shell commands (via Bash tool)
- File editing capabilities (via Edit tool)
```

**Simple Request:**
```
"Add a new validation function to UserInput.swift that checks email format"
```

**Agent Invocation:**
```
"@swift-developer add email validation to UserInput.swift"
```

### Agent Invocation Syntax

**Basic Invocation:**
```
@agent-name task description
```

**Examples:**
```
@swift-architect design a caching layer for network responses

@testing-specialist create tests for the LoginViewModel

@documentation-writer document the UserService API

@git-pr-specialist create a PR for these changes
```

**Multiple Agents (Sequential):**
```
First @swift-architect to design the feature, 
then @swift-developer to implement it, 
then @testing-specialist to create tests
```

---

## Understanding Agents

### Agent Anatomy

Every agent is a markdown file with structured frontmatter:

```markdown
---
name: swift-developer              # Agent identifier (kebab-case)
description: Feature implementation # 60-100 char summary
tools: Read, Edit, Glob, Grep, Bash # Available capabilities
model: sonnet                       # Claude model to use
---

# Swift Developer

You are a Swift developer specializing in iOS feature implementation...

## Core Expertise
- SwiftUI and UIKit development
- Async/await concurrency patterns
- Protocol-oriented design

## Project Context
This project uses:
- Swift 6.0 with strict concurrency
- SwiftUI for all new UI
- Combine for reactive patterns

## Guidelines
- Always use async/await over completion handlers
- Follow existing naming conventions
- Write unit tests for business logic
```

### Available Tools

**Read**: Read file contents
```swift
// Agent uses Read to examine existing code
Read("Sources/Models/User.swift")
```

**Edit**: Modify file contents
```swift
// Agent uses Edit to update code
Edit("Sources/Models/User.swift", oldCode, newCode)
```

**Glob**: Find files by pattern
```bash
# Agent uses Glob to discover files
Glob("**/*.swift")
Glob("Tests/**/*Tests.swift")
```

**Grep**: Search file contents
```bash
# Agent uses Grep to find patterns
Grep("class.*ViewModel", glob="**/*.swift")
```

**Bash**: Execute shell commands
```bash
# Agent uses Bash for builds, tests, git
Bash("swift test")
Bash("git status")
```

**MultiEdit**: Edit multiple files atomically
```swift
// Agent uses MultiEdit for refactors across files
MultiEdit([
  ("File1.swift", old1, new1),
  ("File2.swift", old2, new2)
])
```

**WebSearch**: Search the web for information
```
// Agent uses WebSearch for latest documentation
WebSearch("Swift 6.0 sendable protocol")
```

### When to Use Specific Agents

**Architecture & Design:**
- `@swift-architect`: System design, architectural patterns, module boundaries
- Use when: Planning new features, refactoring architecture, making design decisions

**Implementation:**
- `@swift-developer`: Writing features, implementing UI, business logic
- Use when: Building new functionality, fixing bugs, adding capabilities

**Modernization:**
- `@swift-modernizer`: Upgrading to Swift 6, concurrency migration, deprecated API updates
- Use when: Migrating legacy code, adopting new Swift features, technical upgrades

**Testing:**
- `@testing-specialist`: Test strategies, test implementation, coverage analysis
- Use when: Writing tests, improving coverage, test architecture decisions

**Configuration:**
- `@xcode-configuration-specialist`: Build settings, targets, schemes, project structure
- Use when: Configuring Xcode projects, managing targets, build optimization

**Package Management:**
- `@spm-specialist`: Swift Package Manager, dependencies, package structure
- Use when: Adding dependencies, creating packages, managing SPM configurations

**Version Control:**
- `@git-pr-specialist`: Git workflows, pull requests, code review processes
- Use when: Creating PRs, managing branches, code review tasks

**Documentation:**
- `@documentation-writer`: DocC, API documentation, guides, architecture docs
- Use when: Writing documentation, creating guides, API references

**Cross-Platform:**
- `@kmm-specialist`: Kotlin Multiplatform Mobile integration
- Use when: Working with shared KMM code, Swift-Kotlin bridges

### Agent Collaboration Patterns

**Sequential Workflow:**
```
1. @swift-architect designs the feature
2. @swift-developer implements the design
3. @testing-specialist creates tests
4. @documentation-writer documents the API
5. @git-pr-specialist creates the PR
```

**Parallel Workflow:**
```
@swift-developer implement feature A
(separately)
@testing-specialist create tests for feature B
```

**Iterative Workflow:**
```
1. @swift-developer creates initial implementation
2. Review and feedback
3. @swift-developer refines based on feedback
4. @testing-specialist validates with tests
```

**Escalation Pattern:**
```
@swift-developer encounters architectural question
  → Suggests "@swift-architect should review this design decision"
  → You invoke @swift-architect
  → Return to @swift-developer with architectural guidance
```

---

## Agent Best Practices

### Choosing the Right Agent

**Ask yourself:**
1. What is the primary task? (Design, implement, test, document, configure)
2. What domain expertise is needed? (Swift, Xcode, Git, testing)
3. What is the scope? (Single file, multi-file, architectural)

**Examples:**

| Task | Right Agent | Wrong Agent |
|------|-------------|-------------|
| Design a new caching system | `@swift-architect` | `@swift-developer` (too implementation-focused) |
| Implement a login form | `@swift-developer` | `@swift-architect` (too high-level) |
| Upgrade async/await | `@swift-modernizer` | `@swift-developer` (lacks migration expertise) |
| Configure build phases | `@xcode-configuration-specialist` | `@swift-developer` (wrong domain) |
| Write API docs | `@documentation-writer` | `@swift-developer` (not documentation-focused) |

### Providing Context to Agents

**Good Request (Specific):**
```
@swift-developer add email validation to the UserRegistrationForm.
Use the existing ValidationRule pattern from FormValidation.swift.
The email field should show an error inline below the text field.
```

**Poor Request (Vague):**
```
@swift-developer add validation
```

**Provide:**
- Specific file names when relevant
- Existing patterns to follow
- Constraints or requirements
- Expected behavior
- Related code locations

**Example with Context:**
```
@swift-architect design a network caching layer.

Requirements:
- Cache should support TTL (time-to-live)
- Must work with existing APIClient in Services/Network/
- Should integrate with the DI system (see DI.swift)
- Need to support both memory and disk caching
- Follow the repository pattern used in UserRepository.swift
```

### Working with Agent Responses

**Review Agent Actions:**
Agents will show you what they plan to do:
- Files they'll read
- Edits they'll make
- Commands they'll run

**Provide Feedback:**
```
Good: "The approach looks good, but use @Published instead of CurrentValueSubject"
Better: "Let's use the actor pattern instead of locks for thread safety"
```

**Iterate:**
Agents can refine their work based on your feedback. Don't expect perfection on the first try.

**Chain Agents:**
```
You: "@swift-architect design the caching layer"
Agent: [provides design]
You: "Good. Now @swift-developer implement this design"
Agent: [implements]
You: "@testing-specialist create tests for this implementation"
Agent: [creates tests]
```

### Agent Configuration

**Global Agents** (`~/.claude/agents/`):
Available across all projects. Use for general-purpose agents.

**Local Agents** (`./.claude/agents/`):
Project-specific agents. Use for project-unique patterns.

**Installation:**
```bash
# Install agent globally
claude-agents install swift-architect --global

# Install agent locally (project-specific)
claude-agents install custom-project-agent --local

# List installed agents
claude-agents list --installed
```

---

## Common Workflows

### Code Review Workflow

**1. Analyze Changes:**
```
@swift-architect review the changes in src/ViewModels/ for 
architectural issues and suggest improvements
```

**2. Check Code Quality:**
```
@swift-developer review UserViewModel.swift for:
- Error handling
- Edge cases
- Code clarity
- Swift 6 compliance
```

**3. Verify Tests:**
```
@testing-specialist review test coverage for UserViewModel 
and identify missing test cases
```

### Feature Implementation Workflow

**1. Design Phase:**
```
@swift-architect design a feature for offline-first data sync:
- Users should be able to work offline
- Data syncs when connectivity returns
- Conflicts should be resolved automatically where possible
- Follow existing repository pattern
```

**2. Implementation Phase:**
```
@swift-developer implement the offline sync design from @swift-architect:
- Start with DataSyncService.swift
- Integrate with existing repositories
- Use the NetworkMonitor for connectivity detection
```

**3. Testing Phase:**
```
@testing-specialist create comprehensive tests for offline sync:
- Test offline operations
- Test sync on reconnect
- Test conflict resolution
- Test edge cases (partial sync, network interruption)
```

**4. Documentation Phase:**
```
@documentation-writer document the offline sync feature:
- Add DocC comments to DataSyncService
- Create a usage guide in docs/
- Update ARCHITECTURE.md with sync design
```

**5. PR Creation:**
```
@git-pr-specialist create a PR for the offline sync feature:
- Title: "Add offline-first data synchronization"
- Include design decisions, implementation notes, testing strategy
```

### Documentation Workflow

**1. API Documentation:**
```
@documentation-writer add DocC documentation to UserService.swift:
- Document all public methods
- Include usage examples
- Add parameter descriptions
- Document error cases
```

**2. Architecture Documentation:**
```
@documentation-writer create an architecture decision record (ADR) 
for choosing Combine over async sequences in the networking layer
```

**3. Migration Guide:**
```
@documentation-writer create a migration guide for upgrading from 
UIKit to SwiftUI in our legacy views
```

### Testing Workflow

**1. Test Creation:**
```
@testing-specialist create tests for LoginViewModel:
- Test successful login
- Test invalid credentials
- Test network errors
- Test loading states
- Test form validation
```

**2. Test Refactoring:**
```
@testing-specialist refactor LoginViewModelTests to use the new 
Swift Testing framework instead of XCTest
```

**3. Coverage Analysis:**
```
@testing-specialist analyze test coverage for the Authentication module 
and identify critical untested paths
```

### Build Configuration Workflow

**1. Target Configuration:**
```
@xcode-configuration-specialist configure a new "Staging" build configuration:
- Separate bundle ID
- Different API endpoint
- Custom app icon
- Debug logging enabled
```

**2. Dependency Management:**
```
@spm-specialist add the Alamofire dependency to our package:
- Use version 5.8.1
- Add to both main target and tests
- Update Package.resolved
```

**3. Build Optimization:**
```
@xcode-configuration-specialist optimize build times:
- Analyze compilation bottlenecks
- Suggest build setting improvements
- Recommend module organization changes
```

---

## Tips for Developers

### Agent Discovery

**List Available Agents:**
```bash
# See all agents
claude-agents list

# See agents with descriptions
claude-agents list --verbose

# Find agents with specific tools
claude-agents list --tool MultiEdit
```

**Check Agent Capabilities:**
Read the agent file to understand:
- What the agent specializes in
- What tools it has access to
- What guidelines it follows
- What constraints it respects

**Location:**
- Global: `~/.claude/agents/`
- Local: `./.claude/agents/`

### Custom Agent Creation

**When to Create a Custom Agent:**
- You have a specialized domain not covered by existing agents
- Your project has unique patterns that need dedicated expertise
- You frequently perform a specific type of task

**How to Create:**
```bash
# Use the agent-writer to create new agents
@agent-writer create a new agent for [domain]
```

**Example Request:**
```
@agent-writer create a new agent specialized in UIKit-to-SwiftUI migration:
- Focus on incremental migration strategies
- Include common UIKit patterns and SwiftUI equivalents
- Provide examples from our codebase
- Know about our custom UIKit components
```

**Agent Template:**
```markdown
---
name: my-custom-agent
description: Specialized in [domain expertise]
tools: Read, Edit, Glob, Grep, Bash
model: sonnet
---

# My Custom Agent

You are [role] specializing in [domain]...

## Core Expertise
- [Expertise area 1]
- [Expertise area 2]

## Project Context
[Project-specific information]

## Guidelines
- [Guideline 1]
- [Guideline 2]

## Constraints
- [Constraint 1]
- [Constraint 2]
```

### Efficient Agent Usage

**Do:**
- Invoke specific agents for focused tasks
- Provide context and constraints upfront
- Review agent actions before confirming
- Chain agents for multi-phase workflows
- Give feedback to refine results

**Don't:**
- Use generic requests when specific agents exist
- Assume the agent knows your unstated requirements
- Accept first-pass results without review
- Mix multiple domains in one agent invocation
- Forget to specify relevant files and patterns

### Performance Tips

**Be Specific with File Paths:**
```
Good: "@swift-developer update UserViewModel.swift"
Better: "@swift-developer update Sources/ViewModels/UserViewModel.swift"
```

**Scope Searches:**
```
Good: "Find all ViewModels"
Better: "Find all ViewModels in Sources/ViewModels/"
```

**Batch Related Changes:**
```
Good: "@swift-developer add email validation"
Better: "@swift-developer add email, phone, and postal code validation to RegistrationForm"
```

**Use Appropriate Agents:**
```
Slow: Ask generic Claude to refactor architecture
Fast: "@swift-architect refactor the networking layer"
```

### Troubleshooting

**Agent Not Available:**
```bash
# Check if agent is installed
claude-agents list --installed

# Install missing agent
claude-agents install agent-name --global
```

**Agent Doesn't Have Context:**
```
Problem: "@swift-developer update the view model"
Solution: "@swift-developer update UserViewModel.swift to add email validation using the ValidationRule pattern"
```

**Agent Makes Incorrect Assumptions:**
```
Provide more context:
"@swift-developer implement login, but use our existing APIClient 
in Services/Network/, not URLSession directly"
```

**Multiple Agent Coordination:**
```
Be explicit about sequencing:
"First @swift-architect to design, then @swift-developer to implement"

Or invoke separately:
1. "@swift-architect design the feature"
2. Review design
3. "@swift-developer implement the approved design"
```

### Integration with Development Workflow

**Daily Development:**
```
Morning:
- "@git-pr-specialist show my open PRs"
- "@swift-developer review today's tasks"

Feature Work:
- "@swift-architect design [feature]"
- "@swift-developer implement [feature]"
- "@testing-specialist test [feature]"

Code Review:
- "@swift-architect review architecture changes"
- "@swift-developer review implementation quality"

End of Day:
- "@documentation-writer update CHANGELOG"
- "@git-pr-specialist create PR"
```

**Testing Workflow:**
```
TDD Approach:
1. "@testing-specialist design tests for [feature]"
2. "@swift-developer implement to pass tests"
3. "@testing-specialist verify coverage"
```

**Refactoring:**
```
1. "@swift-architect assess current architecture"
2. "@swift-architect propose refactoring strategy"
3. "@swift-modernizer execute migration"
4. "@testing-specialist verify tests still pass"
```

### Best Practices Summary

1. **Match Agent to Task**: Use specialized agents for their domains
2. **Provide Context**: Specific file paths, patterns to follow, constraints
3. **Review Actions**: Understand what the agent will do before confirming
4. **Iterate**: Refine results through feedback
5. **Chain Workflows**: Use multiple agents for complex tasks
6. **Stay Organized**: Keep agents in appropriate locations (global vs. local)
7. **Document Custom Agents**: If you create custom agents, document their purpose
8. **Learn Patterns**: Study how agents work to write better requests

---

## Resources

### Official Documentation

- **Claude Code Overview**: [docs.claude.com/claude-code](https://docs.claude.com/en/docs/claude-code)
- **Agent Documentation**: [docs.claude.com/claude-code/agents](https://docs.claude.com/en/docs/claude-code/agents)
- **Getting Started**: [docs.claude.com/claude-code/getting-started](https://docs.claude.com/en/docs/claude-code/getting-started)
- **Common Workflows**: [docs.claude.com/claude-code/common-workflows](https://docs.claude.com/en/docs/claude-code/common-workflows)

### Community Resources

- **Anthropic Discord**: [anthropic.com/discord](https://www.anthropic.com/discord)
- **Claude Code Support**: [support.claude.com](https://support.claude.com)
- **API Documentation**: [docs.claude.com/api](https://docs.claude.com/en/api/messages)

### Agent Management

**Swift Agents Plugin** (this project):
```bash
# List available agents
claude-agents list

# Install agents
claude-agents install swift-architect --global

# Uninstall agents
claude-agents uninstall agent-name

# Filter by capability
claude-agents list --tool Bash
```

**Agent Locations:**
- Global agents: `~/.claude/agents/`
- Local agents: `./.claude/agents/`
- Templates: `~/.claude/agents/templates/`

### Learning Path

**Beginner:**
1. Start with simple requests to existing agents
2. Learn agent invocation syntax (`@agent-name task`)
3. Understand agent specializations
4. Practice providing context in requests

**Intermediate:**
1. Chain multiple agents for workflows
2. Create custom project-specific agents
3. Optimize requests for performance
4. Learn to review and refine agent outputs

**Advanced:**
1. Design agent ecosystems for projects
2. Create specialized domain agents
3. Integrate agents with CI/CD
4. Contribute agents back to the community

### Example Projects

Study how agents are used in real projects:
- Browse `~/.claude/agents/` for real agent examples
- Read agent frontmatter to understand capabilities
- Examine agent guidelines to learn best practices
- Study project context sections for integration patterns

### Getting Help

**Check Agent Capabilities:**
```bash
# See what tools an agent has
cat ~/.claude/agents/swift-architect.md | grep "^tools:"
```

**Review Agent Guidelines:**
```bash
# Read agent instructions
cat ~/.claude/agents/swift-developer.md
```

**Community Support:**
- Anthropic Discord: Ask questions, share tips
- GitHub Issues: Report bugs, request features
- Documentation: Read official guides and references

### Quick Reference Card

```
COMMON AGENT INVOCATIONS
────────────────────────────────────────────────────────────
@swift-architect        - Design & architecture decisions
@swift-developer        - Feature implementation
@swift-modernizer       - Swift 6 migration & upgrades
@testing-specialist     - Test strategies & implementation
@xcode-configuration-specialist - Build configuration
@spm-specialist         - Package management
@git-pr-specialist      - Version control & PRs
@documentation-writer   - Documentation & guides

COMMON PATTERNS
────────────────────────────────────────────────────────────
Design → Implement → Test → Document → PR

@swift-architect design [feature]
@swift-developer implement [feature]
@testing-specialist test [feature]
@documentation-writer document [feature]
@git-pr-specialist create PR

AGENT MANAGEMENT
────────────────────────────────────────────────────────────
claude-agents list                    # List available
claude-agents list --installed        # List installed
claude-agents install <name> --global # Install globally
claude-agents install <name> --local  # Install locally
claude-agents uninstall <name>        # Remove agent

TIPS
────────────────────────────────────────────────────────────
✓ Be specific with file paths
✓ Provide context and constraints
✓ Review actions before confirming
✓ Chain agents for complex workflows
✓ Give feedback to refine results

✗ Don't use vague requests
✗ Don't assume unstated context
✗ Don't mix multiple domains
✗ Don't skip review of agent actions
```

---

## Conclusion

Claude Code agents provide specialized expertise for development workflows. By understanding agent capabilities, providing clear context, and following best practices, you can significantly enhance your development efficiency.

**Key Takeaways:**
- Agents are specialized AI assistants with focused domains
- Match the agent to the task for best results
- Provide specific context and constraints
- Chain agents for multi-phase workflows
- Review and iterate on agent outputs
- Create custom agents for project-specific needs

**Next Steps:**
1. Install agents relevant to your work: `claude-agents list`
2. Try simple requests with agent invocation: `@agent-name task`
3. Study existing agents to understand patterns
4. Gradually incorporate agents into daily workflows
5. Create custom agents as needs arise

Happy coding with Claude Code!
