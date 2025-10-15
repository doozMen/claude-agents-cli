# Assets

Plugin marketplace assets for Swift Agents Plugin.

## Required Images

### Icon (icon.png)
- **Size**: 512x512px (minimum)
- **Format**: PNG with transparency
- **Design**: Modern terminal/CLI symbol with Anthropic orange (#E87643)
- **Style**: Minimalist, professional developer tool aesthetic
- **Usage**: Plugin marketplace listing, app icon

### Screenshots

#### screenshot-list.png
- **Content**: `claude-agents list --verbose` output showing all 43 agents
- **Highlight**: Filtering capabilities, agent descriptions, tool lists
- **Size**: 1280x800px or similar terminal window size
- **Format**: PNG

#### screenshot-install.png
- **Content**: Installation workflow showing:
  - `swift package experimental-install`
  - `claude-agents install --all --global`
  - Success message with agent count
- **Size**: 1280x800px
- **Format**: PNG

#### screenshot-mcp.png
- **Content**: MCP integration demonstration:
  - `.mcp.json` configuration with SwiftLens + Context7
  - `claude-agents list --verbose` showing agents with MCP field
  - Example of MCP server in action
- **Size**: 1280x800px
- **Format**: PNG

## Current Status

- [x] icon.png - ✅ Complete (1024x1024px, PNG format)
- [x] screenshot-list.png - ✅ Complete (2.8MB, shows all 43 agents with descriptions)
- [x] screenshot-install.png - ✅ Complete (439KB, installation workflow)
- [x] screenshot-mcp.png - ✅ Complete (313KB, MCP integration demo)

## Design Guidelines

**Color Palette**:
- Primary: Anthropic Orange (#E87643)
- Secondary: Deep Blue (#1E3A8A)
- Accent: Purple (#7C3AED)
- Background: Dark (#0A0E27) or Light (#F8FAFC)

**Terminal Theme** (for screenshots):
- Font: SF Mono, Monaco, or Menlo
- Size: 13-14pt
- Theme: Dark with syntax highlighting
- Shell: Bash with colored output

## Usage in Manifests

Images are referenced in:
- `.claude-plugin/marketplace.json`:
  - `icon`: Line 23
  - `screenshots`: Lines 24-36

URLs use GitHub raw content:
```
https://raw.githubusercontent.com/stijnwillems/swift-agents-plugin/main/assets/icon.png
```

## Notes

- All images should be optimized for web (compressed PNG)
- Screenshots should show actual terminal output, not mockups
- Maintain consistent branding across all assets
- Test visibility on both light and dark backgrounds
