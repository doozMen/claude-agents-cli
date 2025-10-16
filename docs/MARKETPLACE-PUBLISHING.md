# Claude Code Marketplace Publishing Guide

Complete guide for publishing swift-agents-plugin to Claude Code marketplaces.

## Current Status ✅

Your plugin is **submission-ready** with complete infrastructure:

- ✅ `.claude-plugin/plugin.json` - Plugin manifest with all 43 agents
- ✅ `.claude-plugin/marketplace.json` - Official marketplace submission metadata (v1.5.0)
- ✅ Icon: `assets/icon.png` (1024x1024px)
- ✅ Screenshots: 3 professional terminal captures
- ✅ All assets hosted on GitHub with correct URLs
- ✅ Release v1.5.0 published

## Publishing Options

### Option 1: Official Claude Code Marketplace (Recommended)

**Best for**: Maximum visibility, official listing, verified badge potential

#### Submission Process

1. **Submit via Official Portal**:
   - Visit: https://claudecodecommands.directory/submit
   - Provide repository URL: `https://github.com/doozMen/swift-agents-plugin`
   - Contact email: `stijn@dooz.be`
   - Plugin name: `Swift Agents Plugin`
   - Category: `development-tools`

2. **Review Criteria**:
   - Valid `plugin.json` and `marketplace.json`
   - Working installation workflow
   - Asset quality (icon, screenshots)
   - Documentation completeness
   - No malicious code

3. **Timeline**: 1-7 days for community review

#### Pre-Submission Checklist

```bash
# Validate plugin structure
claude plugin validate .

# Test installation locally
git clone https://github.com/doozMen/swift-agents-plugin.git /tmp/test-plugin
cd /tmp/test-plugin
swift package experimental-install --product claude-agents
claude-agents install --all --global

# Verify assets accessible
curl -I https://raw.githubusercontent.com/doozMen/swift-agents-plugin/main/assets/icon.png
curl -I https://raw.githubusercontent.com/doozMen/swift-agents-plugin/main/assets/screenshot-list.png
curl -I https://raw.githubusercontent.com/doozMen/swift-agents-plugin/main/assets/screenshot-install.png
curl -I https://raw.githubusercontent.com/doozMen/swift-agents-plugin/main/assets/screenshot-mcp.png
```

---

### Option 2: GitHub Marketplace (Self-Hosted)

**Best for**: Team distribution, beta testing, immediate availability

**Status**: ✅ **Already available!** Users can install now.

#### Installation for Users

**Installation for Users:**
```bash
# Install the swift-agents-plugin plugin
/plugin marketplace add doozMen/swift-agents-plugin && /plugin install swift-agents-plugin@doozMen
```

#### Plugin Ecosystem

**swift-agents-plugin** (Claude Code Plugin):
- 45 production-ready AI agents
- Specialized expertise (Swift, testing, docs, CI/CD)
- Works standalone
- Core agent management

**edgeprompt MCP Server** (Optional Enhancement):
- Local LLM via MCP for privacy-preserving analysis
- Intelligent agent routing with on-device processing
- Prompt optimization and semantic analysis
- Enhances task-router agent with local LLM capabilities
- No cloud roundtrips for sensitive operations

**How to Configure edgeprompt MCP:**
```bash
# Install edgeprompt MCP server
git clone https://github.com/doozMen/edgeprompt.git
cd edgeprompt
swift package experimental-install --product edgeprompt

# Configure in ~/.claude/claude_mcp_settings.json
```

**Why Use edgeprompt MCP?**
- Provides local LLM backend that 5 agents use (task-router, crashlytics-analyzer, etc.)
- Privacy-preserving operations stay on your device
- Faster routing decisions without API calls
- Enhanced agent coordination and delegation
- Best-in-class Claude Code agent experience

#### Marketplace URL
`github.com/doozMen/swift-agents-plugin`

#### Benefits
- Immediate availability (no approval needed)
- Full control over releases
- Perfect for team/organization distribution
- Beta testing before official submission
- Enhanced capabilities with edgeprompt MCP (when configured)

---

### Option 3: Community Marketplaces

**Best for**: Additional visibility, community engagement

#### Popular Community Hubs

1. **jeremylongshore/claude-code-plugins** (226+ plugins)
   - Repository: https://github.com/jeremylongshore/claude-code-plugins
   - Process: Submit PR with plugin entry

2. **ananddtyagi/claude-code-marketplace**
   - Repository: https://github.com/ananddtyagi/claude-code-marketplace
   - Process: Submit PR to marketplace catalog

3. **EveryInc/every-marketplace**
   - Repository: https://github.com/EveryInc/every-marketplace
   - Focus: Every-Env ecosystem plugins

#### Submission Process

1. Fork the community marketplace repository
2. Add your plugin entry to their `marketplace.json` or catalog
3. Submit pull request with:
   - Plugin name: `swift-agents-plugin`
   - Source: `github.com/doozMen/swift-agents-plugin`
   - Description: "43 production-ready AI agents for Claude Code"
   - Category: `development-tools`
4. Wait for maintainer approval

---

## MCP Server for Marketplace Operations

### Current Status

❌ **No official MCP server exists** for Claude Code marketplace operations

**Missing Capabilities**:
- `/plugin marketplace add` automation
- Plugin validation via MCP
- Marketplace submission automation
- Plugin search/discovery tools

### Workaround: GitHub MCP

Use GitHub MCP for repository operations:

```json
{
  "mcpServers": {
    "github": {
      "command": "mcp-server-github",
      "args": [],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

**Enables**:
- Creating marketplace repositories
- Managing plugin.json updates
- Publishing releases
- Handling pull requests

### Future Opportunity

**Build a Claude Code Marketplace MCP Server!**
- Could be agent #45 or #46
- Use `claude-code-plugin-builder` agent to create it
- Tools needed: Plugin validation, marketplace submission, search/discovery
- Huge value for the community

---

## Recommended Action Plan

### Immediate Actions (Today)

```bash
# 1. Validate plugin locally
claude plugin validate .

# 2. Test complete installation
/plugin marketplace add doozMen/swift-agents-plugin
/plugin install swift-agents-plugin@doozMen

# 3. Verify plugin installed
/plugin list

# 4. Test agent functionality
claude-agents list
claude-agents install task-router --global
```

### This Week

1. ✅ Submit to https://claudecodecommands.directory/submit
2. ✅ Add marketplace installation section to README
3. ✅ Create PRs to community plugin hubs
4. ✅ Share on social media (#ClaudeCode)

### This Month

1. Monitor GitHub Issues for user feedback
2. Update screenshots for any new features
3. Engage with community discussions
4. Consider building Marketplace MCP server

### Future Releases

When releasing new versions (e.g., v1.6.0):

1. **Update Version**:
   ```bash
   # Main.swift
   version: "1.6.0"

   # marketplace.json
   "version": "1.6.0"
   ```

2. **Refresh Assets** (if needed):
   - Regenerate screenshots for new features
   - Update asset README status
   - Verify all URLs still work

3. **Update CHANGELOG**:
   - Move Unreleased → [1.6.0]
   - Add version comparison link

4. **Create GitHub Release**:
   ```bash
   gh release create v1.6.0 \
     --title "v1.6.0 - [Feature Name]" \
     --notes-file release-notes.md
   ```

5. **Update Marketplaces**:
   - Official marketplace auto-syncs from GitHub
   - GitHub marketplace updates automatically
   - Submit version update PRs to community hubs

---

## Pro Tips

### Asset Management
- **Keep screenshots current**: Update when UI/features change significantly
- **Optimize images**: Compress PNGs before committing (use ImageOptim, TinyPNG)
- **Test on both themes**: Verify icon/screenshots work in light and dark modes
- **Use descriptive captions**: Help users understand each screenshot

### Version Management
- **Semantic versioning**: MAJOR.MINOR.PATCH (1.5.0 → 1.6.0)
- **Breaking changes**: Bump MAJOR version (2.0.0)
- **New features**: Bump MINOR version (1.6.0)
- **Bug fixes**: Bump PATCH version (1.5.1)

### Community Engagement
- **Respond quickly**: Answer GitHub Issues within 24-48 hours
- **Accept contributions**: Review PRs from community members
- **Share updates**: Post release notes on Claude Code discussions
- **Thank contributors**: Acknowledge in CHANGELOG and releases

### Documentation
- **Keep README current**: Update agent count, features, installation
- **Document breaking changes**: Clear migration guides in CHANGELOG
- **Provide examples**: Show real-world usage patterns
- **Link to docs**: Direct users to comprehensive documentation

### Marketing
- **Social media**: Share releases on Twitter/X with #ClaudeCode
- **Blog posts**: Write about interesting use cases
- **Video demos**: Record terminal sessions showing agents in action
- **Conference talks**: Present at developer meetups

---

## Troubleshooting

### Plugin Not Found

**Symptom**: `/plugin install swift-agents-plugin@doozMen` fails

**Solutions**:
1. Verify marketplace added: `/plugin marketplace list`
2. Check repository public: Visit github.com/doozMen/swift-agents-plugin
3. Validate plugin.json: `claude plugin validate .`
4. Check branch: Ensure `main` branch is default

### Assets Not Loading

**Symptom**: Icon or screenshots show broken image

**Solutions**:
1. Verify URLs accessible:
   ```bash
   curl -I https://raw.githubusercontent.com/doozMen/swift-agents-plugin/main/assets/icon.png
   ```
2. Check file committed: `git log --all -- assets/icon.png`
3. Verify GitHub raw content URL format
4. Test in browser (should download/display file)

### Installation Fails

**Symptom**: `swift package experimental-install` fails

**Solutions**:
1. Check Swift version: `swift --version` (need 6.1+)
2. Verify Package.swift valid: `swift package dump-package`
3. Clean build folder: `rm -rf .build`
4. Check Xcode: `xcode-select --print-path`
5. Install dependencies: System has required tools

### Validation Errors

**Symptom**: `claude plugin validate .` shows errors

**Common Issues**:
- Missing required fields in plugin.json
- Invalid JSON syntax (trailing commas, quotes)
- Asset URLs return 404
- Duplicate agent names

**Fix**:
1. Check JSON validity: `cat .claude-plugin/plugin.json | jq .`
2. Verify all required fields present
3. Test asset URLs: `curl -I <asset-url>`
4. Remove duplicates from agents list

---

## Support Resources

### Official Documentation
- **Plugin Marketplaces**: https://docs.claude.com/en/docs/claude-code/plugin-marketplaces
- **Plugin Development**: https://docs.claude.com/en/docs/claude-code/plugins
- **Claude Code Docs**: https://docs.claude.com/en/docs/claude-code

### Community Resources
- **Claude Code Marketplace**: https://claudecodecommands.directory
- **GitHub Discussions**: https://github.com/anthropics/claude-code/discussions
- **Community Plugins Hub**: https://github.com/jeremylongshore/claude-code-plugins

### Project Resources
- **GitHub Issues**: https://github.com/doozMen/swift-agents-plugin/issues
- **Discussions**: https://github.com/doozMen/swift-agents-plugin/discussions
- **Email Support**: stijn@dooz.be

---

## Success Metrics

Track these metrics post-publication:

### Installation Metrics
- Daily/weekly/monthly installs
- Unique users vs total installs
- Retention rate (7-day, 30-day)

### Engagement Metrics
- GitHub stars, forks, watchers
- Issue activity (opened, closed, response time)
- Pull requests (submitted, merged)

### Quality Metrics
- User satisfaction (survey, feedback)
- Bug report frequency
- Feature request patterns

### Growth Metrics
- Organic vs promoted installs
- Geographic distribution
- User segments (individual, team, enterprise)

---

## Next Steps

**Your plugin is production-ready for immediate use!** 🎉

1. **Today**: Test GitHub marketplace installation
2. **This Week**: Submit to official marketplace
3. **This Month**: Engage with community and gather feedback
4. **Future**: Build Marketplace MCP server as next evolution

**Questions?** Open an issue or discussion on GitHub!
