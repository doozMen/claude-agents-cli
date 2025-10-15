# Contributing to Swift Agents Plugin

Thank you for contributing to the Swift Agents Plugin project!

## Adding New Agents

### Quick Steps

1. Create agent markdown file in `Sources/claude-agents-cli/Resources/agents/`
2. Add required YAML frontmatter
3. Write agent instructions
4. Rebuild and test
5. Submit PR

### Agent Format

```markdown
---
name: agent-name              # Required: kebab-case identifier
description: Brief description # Required: 60-100 characters
tools: Read, Edit, Bash       # Required: comma-separated list
model: sonnet                 # Optional: opus/sonnet/haiku
mcp: github, azure            # Optional: MCP servers
---

# Agent Name

I am a specialized agent that helps with...

## Core Capabilities

- Capability 1
- Capability 2

## Methodology

Describe the approach...
```

### Naming Conventions

- **Generic agents**: Simple names (architect, test-builder)
- **Language-specific**: Prefix with language (swift-developer, python-analyst)
- **Tool-specific**: Include tool name (azure-devops, github-specialist)
- **No "specialist" suffix**: Unless it adds clarity

### Model Selection

Choose based on task complexity:

| Model | Cost | Use For |
|-------|------|---------|
| **opus** | $15/M tokens | Complex reasoning, architecture, design |
| **sonnet** | $3/M tokens | Balanced tasks, code review, development |
| **haiku** | $1/M tokens | Simple tasks, formatting, installation |

### Tool Requirements

Only include tools the agent actually needs:

- **Read**: Reading files
- **Edit**: Modifying existing files
- **Write**: Creating new files
- **Bash**: Shell commands
- **Glob**: File pattern matching
- **Grep**: Content searching
- **MultiEdit**: Batch file modifications
- **WebSearch**: Internet searches
- **Task**: Delegating to other agents

## Code Contributions

### Development Setup

```bash
# Clone repository
git clone https://github.com/yourusername/swift-agents-plugin.git
cd swift-agents-plugin

# Build project
swift build

# Run tests
swift test

# Format code
swift format format -p -r -i Sources Package.swift
```

### Code Style

- Swift 6.1 with strict concurrency
- Actors for services
- Sendable for models
- async/await throughout
- No force unwrapping

### Testing

Use Swift Testing framework:
```swift
import Testing

@Test
func testAgentParsing() async throws {
    // Test implementation
}
```

**DO NOT** use XCTest.

### Commit Messages

Format:
```
type: brief description

Detailed explanation if needed

- Bullet points for changes
```

Types:
- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation
- **refactor**: Code refactoring
- **test**: Tests
- **chore**: Maintenance

## Documentation

### Updating Documentation

When adding agents, update:
1. `docs/AGENTS.md` - Add to catalog
2. `README.md` - Update agent count
3. `CHANGELOG.md` - Note in unreleased section

### Writing Style

- Direct and factual
- No unnecessary superlatives
- Clear examples
- Practical focus

## Pull Request Process

### Before Submitting

1. **Test locally**:
   ```bash
   swift build -c release
   rm -f ~/.swiftpm/bin/claude-agents
   swift package experimental-install --product claude-agents
   claude-agents list
   ```

2. **Verify agent loads**:
   ```bash
   claude-agents install your-agent --global
   ```

3. **Format code**:
   ```bash
   swift format format -p -r -i Sources Package.swift
   ```

4. **Update tests** if applicable

### PR Template

```markdown
## Summary
Brief description of changes

## Type of Change
- [ ] New agent
- [ ] Bug fix
- [ ] Documentation
- [ ] Feature
- [ ] Refactoring

## Agent Details (if applicable)
- **Name**: agent-name
- **Model**: sonnet/haiku/opus
- **Purpose**: What it does

## Testing
- [ ] Built successfully
- [ ] Installed and verified locally
- [ ] Updated documentation

## Checklist
- [ ] Code follows Swift style
- [ ] Agent has proper frontmatter
- [ ] Description is 60-100 chars
- [ ] Updated AGENTS.md catalog
```

### Review Process

1. Automated checks run
2. Maintainer reviews code
3. Test agent functionality
4. Merge when approved

## Agent Quality Standards

### Required Sections

Every agent should include:
1. **Introduction**: What the agent does
2. **Core Capabilities**: Bullet list of skills
3. **Methodology**: How it approaches tasks
4. **Best Practices**: Guidelines for usage
5. **Examples**: Practical code samples

### Quality Checklist

- [ ] Clear, specific purpose
- [ ] Appropriate model selection
- [ ] Minimal tool requirements
- [ ] Practical examples
- [ ] Error handling guidance
- [ ] No duplicate functionality

## Maintenance

### Updating Existing Agents

1. Keep changes backward compatible
2. Document breaking changes
3. Update version in CHANGELOG
4. Test with existing projects

### Deprecating Agents

1. Mark as deprecated in frontmatter
2. Add migration guide
3. Maintain for 2 versions
4. Remove in major release

## Community

### Getting Help

- Open an issue for questions
- Check existing issues first
- Join discussions
- Read documentation

### Code of Conduct

- Be respectful
- Welcome newcomers
- Focus on constructive feedback
- Assume positive intent

## Release Process

### Version Numbering

Semantic versioning: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes
- **MINOR**: New features, agents
- **PATCH**: Bug fixes

### Release Checklist

1. Update CHANGELOG.md
2. Update version in Package.swift
3. Create git tag
4. Build release binary
5. Create GitHub release
6. Announce in discussions

## Legal

### License

MIT License - contributions are licensed the same

### Attribution

Contributors are listed in:
- Git history
- GitHub contributors page
- CHANGELOG.md for significant contributions

## Questions?

- Open an issue
- Start a discussion
- Review existing documentation

Thank you for improving Swift Agents Plugin!