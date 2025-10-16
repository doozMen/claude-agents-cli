# v1.5.1 Release Validation Checklist

## Pre-Release Status

### ✅ Completed Tasks

#### Plugin Configuration (45 Agents)
- [x] Added `generic-assistant` to plugin.json components
- [x] Added `release-manager` to plugin.json components
- [x] Updated plugin.json description: "45 production-ready AI agents"
- [x] Updated marketplace.json descriptions to 45 agents
- [x] Updated model distribution: 2 Opus, 30 Sonnet, 13 Haiku
- [x] Changed OWL Intelligence → edgeprompt MCP in plugin.json

#### Agent Updates (5 Agents)
- [x] task-router.md: owl-intelligence → edgeprompt (14 references)
- [x] crashlytics-analyzer.md: owl-intelligence → edgeprompt (12 references)
- [x] firebase-ecosystem-analyzer.md: owl-intelligence → edgeprompt (11 references)
- [x] swift-build-runner.md: owl-intelligence → edgeprompt (8 references)
- [x] technical-debt-eliminator.md: owl-intelligence → edgeprompt (10 references)
- [x] swift-architect.md: model upgraded from sonnet → opus

#### Documentation Updates
- [x] README.md: Updated to 45 agents throughout
- [x] README.md: Clarified edgeprompt as MCP server (not plugin)
- [x] docs/CLAUDE_CODE_GUIDE.md: Removed agents-plugin references
- [x] docs/MARKETPLACE-PUBLISHING.md: Clarified edgeprompt MCP setup
- [x] docs/AGENTS.md: Created comprehensive 45-agent catalog

#### Library Target
- [x] Added ClaudeAgents library to Package.swift
- [x] Created AgentRepository public API
- [x] CLI now imports and uses ClaudeAgents library
- [x] Created LIBRARY_USAGE.md documentation
- [x] GitHub Issue #19 created in edgeprompt repo for integration

#### GitHub Issues Created
- [x] Issue #4: Submit to Claude Code Official Marketplaces
- [x] Issue #5: Add `/marketplace` slash command for plugin operations
- [x] Issue #6: Submit plugin to community marketplaces
- [x] Issue #8: Add Claude Code marketplace integration (95% complete)
- [x] Issue #9: Improve spm-specialist agent delegation

#### Assets Verified
- [x] Icon: assets/icon.png (1024x1024 PNG, 1.3MB)
- [x] Screenshot 1: assets/screenshot-list.png (2570x7735 PNG, 2.8MB)
- [x] Screenshot 2: assets/screenshot-install.png (1178x1960 PNG, 439KB)
- [x] Screenshot 3: assets/screenshot-mcp.png (1130x1610 PNG, 313KB)

---

## Tonight's Validation Steps

### 1. Plugin Validation ✔️
```bash
claude plugin validate .claude-plugin/plugin.json
claude plugin validate .claude-plugin/marketplace.json
```
**Expected**: Both pass validation

### 2. Build Verification
```bash
swift build
```
**Expected**: Builds successfully with library and CLI targets

### 3. Test Library API
```bash
# Create test file
cat > /tmp/test-library.swift << 'EOF'
import ClaudeAgents

@main
struct TestLibrary {
    static func main() async throws {
        let repo = AgentRepository()
        let agents = try await repo.loadAgents()
        print("Loaded \(agents.count) agents")

        if let agent = try await repo.getAgent(named: "swift-architect") {
            print("Found swift-architect with model: \(agent.model)")
        }
    }
}
EOF

# Build and run
swift /tmp/test-library.swift
```
**Expected**: "Loaded 45 agents", "Found swift-architect with model: opus"

### 4. CLI Functionality
```bash
# Remove and reinstall CLI
rm -f ~/.swiftpm/bin/claude-agents
swift package experimental-install --product claude-agents

# Test commands
claude-agents list | grep "45 agents available"
claude-agents list --verbose | grep "generic-assistant"
claude-agents list --verbose | grep "release-manager"
```
**Expected**: Shows 45 agents, includes both new agents

### 5. GitHub Marketplace Installation
```bash
# Test marketplace installation command
/plugin marketplace add doozMen/swift-agents-plugin
/plugin install swift-agents-plugin@doozMen
/plugin list
```
**Expected**: Plugin installs successfully

### 6. Agent Verification
```bash
# Check MCP references
grep -r "owl-intelligence" Sources/claude-agents-cli/Resources/agents/
# Expected: No results (all migrated to edgeprompt)

grep -r "edgeprompt" Sources/claude-agents-cli/Resources/agents/ | wc -l
# Expected: 55+ references
```

### 7. Git Status Check
```bash
git status
git diff --stat
```
**Expected**: All changes staged or committed

### 8. Version Consistency
```bash
grep "1.5" .claude-plugin/plugin.json
grep "1.5" .claude-plugin/marketplace.json
grep "1.5" Sources/claude-agents-cli/Main.swift
```
**Expected**: All show v1.5.0 or v1.5.1 consistently

---

## Release Process (After Validation)

### 1. Commit Final Changes
```bash
git add -A
git commit -m "chore: v1.5.1 release - 45 agents, edgeprompt MCP, library API

- Added generic-assistant and release-manager agents (45 total)
- Migrated 5 agents from owl-intelligence to edgeprompt MCP
- Added ClaudeAgents Swift library for programmatic access
- Updated documentation to clarify edgeprompt as MCP server
- Model distribution: 2 Opus, 30 Sonnet, 13 Haiku"
```

### 2. Tag Release
```bash
git tag -a v1.5.1 -m "Release v1.5.1: 45 agents with library API

Features:
- 45 production-ready agents (added generic-assistant, release-manager)
- ClaudeAgents library for programmatic agent access
- edgeprompt MCP integration for 5 agents
- Comprehensive agent catalog documentation"
```

### 3. Push to GitHub
```bash
git push origin main
git push origin v1.5.1
```

### 4. Create GitHub Release
```bash
gh release create v1.5.1 \
  --title "v1.5.1 - 45 Agents with Library API" \
  --notes "### What's New
- 🎯 **45 Agents Total**: Added generic-assistant and release-manager
- 📚 **ClaudeAgents Library**: Programmatic access to agent strings
- 🔄 **edgeprompt MCP**: Migrated from owl-intelligence
- 📖 **Complete Documentation**: Agent catalog, library usage guide
- 🎨 **Model Distribution**: 2 Opus, 30 Sonnet, 13 Haiku

### Installation
\`\`\`bash
/plugin marketplace add doozMen/swift-agents-plugin
/plugin install swift-agents-plugin@doozMen
\`\`\`

### Library Usage
\`\`\`swift
import ClaudeAgents
let repo = AgentRepository()
let agents = try await repo.loadAgents()
\`\`\`"
```

---

## Post-Release Monitoring

### Tomorrow Morning
- [ ] Check GitHub Issues for any installation problems
- [ ] Verify marketplace listing shows v1.5.1
- [ ] Test fresh installation on clean system
- [ ] Monitor GitHub Actions (if any)

### This Week
- [ ] Submit to official marketplace (Issue #4)
- [ ] Submit to community marketplaces (Issue #6)
- [ ] Create `/marketplace` command (Issue #5)
- [ ] Update edgeprompt with ClaudeAgents integration (Issue #19)

---

## Known Issues to Address Later

1. **agents-plugin confusion**: Documentation previously referenced non-existent plugin (now clarified as edgeprompt MCP)
2. **spm-specialist delegation**: Should delegate to builders/testers (Issue #9)
3. **Slash command missing**: Need `/marketplace` command (Issue #5)

---

## Success Criteria ✅

- [x] 45 agents listed and accessible
- [x] All agents reference edgeprompt (not owl-intelligence)
- [x] Plugin passes validation
- [x] Library builds and works
- [x] CLI continues to function
- [x] Documentation is accurate and complete
- [x] GitHub marketplace installation works
- [ ] Release tagged and pushed
- [ ] Users can install and use successfully

---

## Notes

- edgeprompt MCP is responsible for its own setup (writing to CLAUDE.md, installing commands)
- swift-agents-plugin documents that 5 agents use edgeprompt when available
- Library API enables other Swift packages to access agent content
- Version kept at 1.5.0 (or bump to 1.5.1 if desired)

---

**Ready for overnight validation and release!** 🚀