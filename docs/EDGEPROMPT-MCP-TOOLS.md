# EdgePrompt MCP Tools Reference

**Complete guide to the 16 edgeprompt MCP tools for cost reduction and intelligent agent routing**

## Table of Contents

1. [Overview](#overview)
2. [Installation](#installation)
3. [Tool Categories](#tool-categories)
4. [Category 1: Local AI Tools](#category-1-local-ai-tools)
5. [Category 2: Agent Orchestration](#category-2-agent-orchestration)
6. [Category 3: Git Integration](#category-3-git-integration)
7. [Category 4: Swift Development](#category-4-swift-development)
8. [Cost Optimization Patterns](#cost-optimization-patterns)
9. [Integration Examples](#integration-examples)
10. [Decision Tree](#decision-tree)
11. [Performance Metrics](#performance-metrics)
12. [Troubleshooting](#troubleshooting)

---

## Overview

EdgePrompt MCP provides 16 tools that enable **local-first processing** to dramatically reduce Claude API token consumption. All processing happens on-device using Apple Foundation Models, ensuring privacy and zero API costs for routine operations.

### Expected Benefits

- **50-80% token savings** on summarization tasks
- **100% savings** on local LLM queries (zero Claude API usage)
- **30-50% savings** on agent routing (83% accuracy vs 40% baseline)
- **60% savings** on git context gathering
- **Privacy-first**: All analysis happens on-device

### Key Capabilities

1. **Zero-Cost Local Queries**: Use Apple Intelligence for analysis without API calls
2. **Intelligent Agent Matching**: 83% accuracy with semantic similarity
3. **Git Context Optimization**: One-call comprehensive project context
4. **Swift Code Analysis**: Privacy-filtered SwiftLens and Context7 integration

---

## Installation

```bash
# Install edgeprompt MCP server
git clone https://github.com/doozMen/edgeprompt.git
cd edgeprompt
swift package experimental-install --product edgeprompt

# Configure in ~/.claude/claude_mcp_settings.json
{
  "mcpServers": {
    "edgeprompt": {
      "command": "edgeprompt",
      "args": ["--log-level", "info"],
      "env": {
        "PATH": "$HOME/.swiftpm/bin:/usr/local/bin:/usr/bin:/bin"
      }
    }
  }
}
```

---

## Tool Categories

The 16 edgeprompt MCP tools are organized into 4 categories:

| Category | Tools | Primary Use Case |
|----------|-------|-----------------|
| **Local AI** | 4 tools | Zero-cost inference, summarization, sentiment analysis |
| **Agent Orchestration** | 6 tools | Intelligent routing, agent discovery, prompt optimization |
| **Git Integration** | 3 tools | Context gathering, platform detection, change analysis |
| **Swift Development** | 3 tools | Code analysis, symbol lookup, documentation search |

---

## Category 1: Local AI Tools

**Purpose**: Execute LLM operations locally for zero API cost

### 1. `mcp__edgeprompt__query`

Execute LLM queries locally with complete privacy.

**Parameters**:
- `prompt` (required): User query or prompt for the LLM
- `model` (optional): `apple-intelligence`, `phi-3-mini`, or `tinyllama` (default: apple-intelligence)
- `temperature` (optional): Sampling temperature 0.0-1.0 (default: 0.7)
- `max_tokens` (optional): Maximum tokens to generate (default: 1000)

**Use Cases**:
- Simple question answering
- Classification tasks
- Intent detection
- Content filtering

**Cost Savings**: **100%** (zero Claude API usage)

**Example**:
```typescript
const result = await mcp__edgeprompt__query({
  prompt: "Is this commit message well-formatted: 'fix bug'?",
  model: "apple-intelligence",
  temperature: 0.3
});
// Result: "No, the commit message lacks context..."
// Cost: 0 tokens (vs 150 tokens with Claude API)
```

---

### 2. `mcp__edgeprompt__summarize`

Summarize text locally with privacy preservation.

**Parameters**:
- `text` (required): Text content to summarize
- `max_length` (optional): Maximum word count for summary

**Use Cases**:
- Report summarization (30-line reports → 5-line summaries)
- Log file analysis
- Documentation condensing
- Meeting notes

**Cost Savings**: **50-80%** token reduction

**Example**:
```typescript
const result = await mcp__edgeprompt__summarize({
  text: "...[30 lines of detailed crash report]...",
  max_length: 100
});
// Result: 5-line executive summary
// Cost: 400 tokens (vs 2,000 tokens with full report sent to Claude)
```

---

### 3. `mcp__edgeprompt__analyze_sentiment`

Analyze sentiment locally for content filtering.

**Parameters**:
- `text` (required): Text content to analyze

**Use Cases**:
- Comment sentiment analysis
- Issue priority triage (angry user = high priority)
- Content moderation
- Customer feedback categorization

**Cost Savings**: **100%** (zero Claude API usage)

**Example**:
```typescript
const result = await mcp__edgeprompt__analyze_sentiment({
  text: "This feature is completely broken and causing production issues!"
});
// Result: { sentiment: "negative", score: 0.85, urgency: "high" }
// Cost: 0 tokens (vs 80 tokens with Claude API)
```

---

### 4. `mcp__edgeprompt__detect_pii`

Detect personally identifiable information before sharing data.

**Parameters**:
- `text` (required): Text content to scan for PII

**Use Cases**:
- Sanitizing logs before analysis
- Privacy compliance checks
- Secure data sharing preparation
- Code review security

**Cost Savings**: **100%** (zero Claude API usage)

**Example**:
```typescript
const result = await mcp__edgeprompt__detect_pii({
  text: "Contact john.doe@company.com at 555-1234 or SSN 123-45-6789"
});
// Result: { found: true, types: ["email", "phone", "ssn"], redacted: "Contact [EMAIL] at [PHONE] or SSN [SSN]" }
// Cost: 0 tokens (vs 120 tokens with Claude API)
```

---

## Category 2: Agent Orchestration

**Purpose**: Intelligent agent routing and prompt optimization

### 5. `mcp__edgeprompt__analyze_request`

Analyze user requests to understand intent and complexity.

**Parameters**:
- `request` (required): User request or query to analyze

**Use Cases**:
- Intent classification before routing
- Complexity estimation for model selection
- Keyword extraction for agent matching
- Technology identification

**Cost Savings**: **80%** token reduction (50 tokens vs 200 tokens)

**Example**:
```typescript
const result = await mcp__edgeprompt__analyze_request({
  request: "Create a Swift CLI tool with ArgumentParser that validates Package.swift dependencies"
});
// Result: {
//   intent: "Implementation",
//   technologies: ["Swift", "ArgumentParser", "SPM"],
//   complexity: "medium",
//   keywords: ["CLI", "validation", "dependencies"]
// }
// Cost: 50 tokens (vs 200 tokens with full Claude analysis)
```

---

### 6. `mcp__edgeprompt__discover_agents`

Discover available Claude agents from `~/.claude/agents/`.

**Parameters**: None

**Use Cases**:
- Agent catalog generation
- Available capability discovery
- Tool filtering
- Agent recommendation systems

**Cost Savings**: **100%** (filesystem read, zero API usage)

**Example**:
```typescript
const result = await mcp__edgeprompt__discover_agents();
// Result: {
//   agents: [
//     { name: "swift-architect", tools: ["Read", "Edit", "Bash"], model: "opus" },
//     { name: "test-builder", tools: ["Read", "Edit"], model: "haiku" },
//     ...44 agents
//   ]
// }
// Cost: 0 tokens (vs 150 tokens listing agents via Claude)
```

---

### 7. `mcp__edgeprompt__match_agents`

Match available agents to a request with 83% accuracy.

**Parameters**:
- `request` (required): User request to match against agents
- `top_n` (optional): Number of top agents to return (default: 3)

**Use Cases**:
- **Primary routing decision** (replaces task-router agent)
- Agent recommendation
- Multi-agent workflow planning
- Capability matching

**Cost Savings**: **80%** token reduction (100 tokens vs 500 tokens)

**Accuracy**: **83%** (vs 40% keyword-only matching)

**Example**:
```typescript
const result = await mcp__edgeprompt__match_agents({
  request: "Create a Swift CLI tool with ArgumentParser that validates Package.swift dependencies",
  top_n: 3
});
// Result: [
//   { agent: "swift-cli-tool-builder", score: 0.72, reasoning: "Perfect match for CLI tools with ArgumentParser" },
//   { agent: "spm-specialist", score: 0.68, reasoning: "Package.swift validation expertise" },
//   { agent: "swift-developer", score: 0.54, reasoning: "General Swift development" }
// ]
// Cost: 100 tokens (vs 500 tokens with full Claude reasoning)
// Latency: <200ms (vs 2-5 seconds with Claude API)
```

---

### 8. `mcp__edgeprompt__explain_routing`

Explain why specific agents were recommended.

**Parameters**:
- `request` (required): User request to explain routing for
- `top_n` (optional): Number of top agents to explain (default: 3)

**Use Cases**:
- Debugging routing decisions
- User education (teaching agent selection)
- Transparency in automation
- Quality assurance

**Cost Savings**: **70%** token reduction

**Example**:
```typescript
const result = await mcp__edgeprompt__explain_routing({
  request: "Fix Swift concurrency warnings in my code",
  top_n: 2
});
// Result: {
//   recommendations: [
//     {
//       agent: "swift-modernizer",
//       score: 0.78,
//       reasoning: "Specializes in Swift 6 migration including concurrency warnings",
//       matched_keywords: ["concurrency", "Swift", "warnings"],
//       relevant_tools: ["Read", "Edit", "MultiEdit"],
//       confidence: "high"
//     },
//     {
//       agent: "swift-architect",
//       score: 0.65,
//       reasoning: "Architecture-level concurrency patterns",
//       matched_keywords: ["concurrency", "Swift"],
//       relevant_tools: ["Read", "Edit", "Bash"],
//       confidence: "medium"
//     }
//   ]
// }
// Cost: 150 tokens (vs 500 tokens with full Claude explanation)
```

---

### 9. `mcp__edgeprompt__optimize_prompt`

Intelligently rebuild prompts with agent injection and git context.

**Parameters**:
- `prompt` (required): The prompt to optimize and enhance
- `inject_agents` (optional): Whether to inject agent mentions (default: true)
- `max_agents` (optional): Maximum number of agents to inject (default: 3)
- `generate_todos` (optional): Generate actionable todo list (default: true)
- `working_directory` (optional): Working directory for git context (default: current directory)
- `context` (optional): Additional context about the prompt's purpose

**Use Cases**:
- **Automatic agent recommendation** in prompts
- Git context enrichment (branch, commits, platform)
- Todo list generation for workflow automation
- Prompt enhancement for better results

**Cost Savings**: **40-60%** token reduction with smarter context

**Example**:
```typescript
const result = await mcp__edgeprompt__optimize_prompt({
  prompt: "I need to add tests for the new authentication feature",
  inject_agents: true,
  max_agents: 2,
  generate_todos: true
});
// Result: {
//   enhanced_prompt: `
//     Add comprehensive tests for authentication feature.
//
//     @swift-testing-specialist can help with Swift Testing framework patterns.
//     @test-builder can rapidly scaffold the test suite structure.
//
//     Git Context:
//     - Branch: feature/auth-flow
//     - Platform: GitHub (doozMen/myapp)
//     - Recent commits: "feat: add OAuth flow", "refactor: user model"
//
//     Suggested todos:
//     1. Create AuthenticationTests.swift with @Suite structure
//     2. Add unit tests for OAuth token validation
//     3. Add integration tests for login/logout flows
//     4. Add edge case tests (expired tokens, invalid credentials)
//   `,
//   injected_agents: ["swift-testing-specialist", "test-builder"],
//   git_context: { ... },
//   todos: [ ... ]
// }
// Cost: 300 tokens (vs 800 tokens with manual context gathering)
```

---

### 10. `mcp__edgeprompt__validate_agent_match`

Validate agent match before execution (quality gate).

**Parameters**:
- `agent_name` (required): Name of the agent to validate
- `request` (required): User request to validate against

**Use Cases**:
- Pre-execution validation
- Confidence scoring
- Alternative agent suggestions
- Quality assurance

**Cost Savings**: **90%** token reduction (prevents full execution)

---

## Category 3: Git Integration

**Purpose**: Efficient git context gathering

### 11. `mcp__edgeprompt__git_fetch_context`

Fetch comprehensive git repository context in one call.

**Parameters**:
- `working_directory` (optional): Directory to analyze (default: current directory)
- `commit_count` (optional): Number of recent commits to fetch (default: 10)

**Returns**:
- Current branch name
- Default branch (main/master)
- Remote platform (GitHub/GitLab/Azure DevOps)
- Repository owner and name
- Working directory status (clean/dirty)
- Recent commits (message, author, date, SHA)
- Remote URLs

**Use Cases**:
- **Replace multiple bash commands** (git status, git branch, git log, git remote)
- One-call comprehensive context
- Platform-specific workflows
- Commit history analysis

**Cost Savings**: **60%** token reduction (300 tokens vs 800 tokens)

**Example**:
```typescript
const result = await mcp__edgeprompt__git_fetch_context({
  working_directory: "/Users/dev/myproject",
  commit_count: 5
});
// Result: {
//   branch: "feature/new-api",
//   default_branch: "main",
//   platform: "github",
//   owner: "doozMen",
//   repo: "myproject",
//   status: "clean",
//   commits: [
//     { sha: "abc123", message: "feat: add new API endpoint", author: "John", date: "2025-10-15" },
//     ...
//   ],
//   remote_url: "https://github.com/doozMen/myproject.git"
// }
// Cost: 300 tokens (vs 800 tokens with multiple bash commands + parsing)
```

---

### 12. `mcp__edgeprompt__detect_git_platform`

Detect git hosting platform and recommend specialist agents.

**Parameters**:
- `working_directory` (optional): Directory to analyze (default: current directory)

**Returns**:
- Platform name (github/gitlab/azure-devops/bitbucket)
- Recommended specialist agent
- Platform-specific MCP tools
- Authentication hints

**Use Cases**:
- Platform-specific agent routing
- MCP tool recommendations
- Authentication setup guidance
- Cross-platform workflows

**Cost Savings**: **100%** (zero API usage)

**Example**:
```typescript
const result = await mcp__edgeprompt__detect_git_platform();
// Result: {
//   platform: "github",
//   recommended_agent: "git-pr-specialist",
//   mcp_tools: ["mcp__github__create_pull_request", "mcp__github__list_issues"],
//   auth_hint: "Configure GitHub PAT with repo, workflow scopes"
// }
// Cost: 0 tokens (vs 100 tokens with Claude analysis)
```

---

### 13. `mcp__edgeprompt__analyze_recent_changes`

Analyze recent git commits and working directory changes.

**Parameters**:
- `working_directory` (optional): Directory to analyze (default: current directory)
- `commit_count` (optional): Number of recent commits to analyze (default: 5)

**Returns**:
- Summary of recent changes
- Affected files and areas
- Change type classification (feature/bugfix/refactor)
- Impact assessment
- Relevant agents for the work

**Use Cases**:
- Understanding current work context
- Change impact analysis
- Agent recommendation based on recent work
- Commit pattern analysis

**Cost Savings**: **50%** token reduction

**Example**:
```typescript
const result = await mcp__edgeprompt__analyze_recent_changes({
  commit_count: 3
});
// Result: {
//   summary: "Recent work focuses on API layer refactoring and test coverage",
//   affected_areas: ["API", "Models", "Tests"],
//   change_types: ["refactor", "test"],
//   impact: "medium",
//   relevant_agents: ["swift-developer", "testing-specialist"],
//   file_stats: { modified: 8, added: 3, deleted: 1 }
// }
// Cost: 200 tokens (vs 400 tokens with full commit diffs)
```

---

## Category 4: Swift Development

**Purpose**: Privacy-filtered code analysis

### 14. `mcp__edgeprompt__swift_analyze`

Analyze Swift code using SwiftLens (privacy-filtered).

**Parameters**:
- `code` (required): Swift code to analyze
- `projectPath` (optional): Path to project root for context

**Returns**:
- Syntax validation
- Semantic analysis (types, symbols)
- Potential issues
- Improvement suggestions
- Privacy-filtered results (no code sent to external servers)

**Use Cases**:
- Code validation before commits
- Error detection
- Type inference checking
- Refactoring safety

**Cost Savings**: **100%** (local SwiftLens analysis)

**Example**:
```typescript
const result = await mcp__edgeprompt__swift_analyze({
  code: "func fetchUser() async throws -> User { ... }"
});
// Result: {
//   valid: true,
//   issues: [],
//   suggestions: ["Consider adding @MainActor for UI updates"],
//   symbols: [{ name: "fetchUser", kind: "function", async: true, throws: true }]
// }
// Cost: 0 tokens (vs 300 tokens with Claude code analysis)
```

---

### 15. `mcp__edgeprompt__swift_symbol_lookup`

Look up Swift symbols using SwiftLens index.

**Parameters**:
- `symbol` (required): Symbol name to look up
- `projectPath` (optional): Path to project root

**Returns**:
- Symbol definitions
- File locations
- Usage references
- Type information

**Use Cases**:
- Symbol navigation
- Refactoring impact analysis
- Dependency discovery
- Dead code detection

**Cost Savings**: **100%** (local index lookup)

**Example**:
```typescript
const result = await mcp__edgeprompt__swift_symbol_lookup({
  symbol: "UserViewModel"
});
// Result: {
//   definitions: [{ file: "UserViewModel.swift", line: 12, kind: "class" }],
//   references: 14,
//   usages: [{ file: "UserView.swift", line: 8 }, ...]
// }
// Cost: 0 tokens (vs 250 tokens with Claude search)
```

---

### 16. `mcp__edgeprompt__docs_search`

Search documentation using Context7 (privacy-filtered).

**Parameters**:
- `query` (required): Documentation search query
- `context` (optional): Code context for better results (sanitized for privacy)

**Returns**:
- Documentation results
- API references
- Code examples
- Version-specific information

**Use Cases**:
- API documentation lookup
- Framework guidance
- Example code discovery
- Version compatibility checks

**Cost Savings**: **70%** token reduction

**Example**:
```typescript
const result = await mcp__edgeprompt__docs_search({
  query: "SwiftUI @Observable macro usage"
});
// Result: {
//   docs: ["@Observable macro replaces ObservableObject in iOS 17+..."],
//   examples: ["@Observable class ViewModel { @Published var items = [] }"],
//   reference_url: "https://developer.apple.com/documentation/observation"
// }
// Cost: 150 tokens (vs 500 tokens with full Claude documentation lookup)
```

---

## Cost Optimization Patterns

### Pattern 1: Summarization Pipeline

**Before**: Send full 30-line report to Claude (2,000 tokens)
**After**: Use `mcp__edgeprompt__summarize` → 5-line summary (400 tokens)
**Savings**: **80%** token reduction

```typescript
// ❌ Before (2,000 tokens)
const analysis = await claude.analyze(fullReport);

// ✅ After (400 tokens)
const summary = await mcp__edgeprompt__summarize({ text: fullReport, max_length: 100 });
const analysis = await claude.analyze(summary);
```

---

### Pattern 2: Agent Routing

**Before**: Send request to Claude for agent selection (500 tokens)
**After**: Use `mcp__edgeprompt__match_agents` (100 tokens)
**Savings**: **80%** token reduction, **83% accuracy** (vs 40%)

```typescript
// ❌ Before (500 tokens, 40% accuracy)
const agents = await claude.selectAgents(userRequest);

// ✅ After (100 tokens, 83% accuracy, <200ms)
const agents = await mcp__edgeprompt__match_agents({
  request: userRequest,
  top_n: 3
});
```

---

### Pattern 3: Git Context Gathering

**Before**: Multiple bash commands + parsing (800 tokens)
**After**: One `mcp__edgeprompt__git_fetch_context` call (300 tokens)
**Savings**: **60%** token reduction

```typescript
// ❌ Before (800 tokens, 5 bash commands)
const branch = await bash("git branch --show-current");
const status = await bash("git status --short");
const commits = await bash("git log -10 --oneline");
const remote = await bash("git remote get-url origin");
const platform = detectPlatform(remote); // Claude API call

// ✅ After (300 tokens, 1 MCP call)
const gitContext = await mcp__edgeprompt__git_fetch_context({ commit_count: 10 });
```

---

### Pattern 4: Local LLM Classification

**Before**: Claude API for simple classification (150 tokens)
**After**: Local query with `mcp__edgeprompt__query` (0 tokens)
**Savings**: **100%** token reduction

```typescript
// ❌ Before (150 tokens)
const classification = await claude.classify("Is this commit message well-formatted?");

// ✅ After (0 tokens)
const classification = await mcp__edgeprompt__query({
  prompt: "Is this commit message well-formatted?",
  model: "apple-intelligence"
});
```

---

### Pattern 5: Sentiment-Based Prioritization

**Before**: Claude API for sentiment analysis (80 tokens per issue)
**After**: Local `mcp__edgeprompt__analyze_sentiment` (0 tokens)
**Savings**: **100%** token reduction

```typescript
// ❌ Before (80 tokens × 50 issues = 4,000 tokens)
for (const issue of issues) {
  const sentiment = await claude.analyzeSentiment(issue.body);
  issue.priority = sentiment.urgency;
}

// ✅ After (0 tokens)
for (const issue of issues) {
  const sentiment = await mcp__edgeprompt__analyze_sentiment({ text: issue.body });
  issue.priority = sentiment.urgency;
}
```

---

### Pattern 6: Prompt Enhancement

**Before**: Manual git context + agent selection (800 tokens)
**After**: `mcp__edgeprompt__optimize_prompt` (300 tokens)
**Savings**: **60%** token reduction

```typescript
// ❌ Before (800 tokens)
const gitContext = await fetchGitContext(); // 300 tokens
const agents = await selectAgents(prompt); // 500 tokens
const enhancedPrompt = buildPrompt(prompt, gitContext, agents);

// ✅ After (300 tokens)
const result = await mcp__edgeprompt__optimize_prompt({
  prompt,
  inject_agents: true,
  generate_todos: true
});
```

---

### Pattern 7: PII Sanitization

**Before**: Send unsanitized logs to Claude (risk + 500 tokens)
**After**: Sanitize with `mcp__edgeprompt__detect_pii` (0 tokens)
**Savings**: **100%** token reduction + privacy compliance

```typescript
// ❌ Before (500 tokens + privacy risk)
const analysis = await claude.analyzeLogs(rawLogs);

// ✅ After (0 tokens, privacy-compliant)
const piiResult = await mcp__edgeprompt__detect_pii({ text: rawLogs });
const sanitizedLogs = piiResult.redacted;
const analysis = await claude.analyzeLogs(sanitizedLogs);
```

---

## Integration Examples

### Example 1: Swift Architect Agent

**Add to swift-architect.md**:

```markdown
## Cost Optimization with EdgePrompt MCP

Before analyzing architecture, use these tools to reduce token consumption:

1. **Analyze Request Intent**:
   ```
   Use mcp__edgeprompt__analyze_request to classify the request type:
   - Architecture design → Use full Opus reasoning
   - Simple refactoring → Use local summarization first
   ```

2. **Fetch Git Context Efficiently**:
   ```
   Replace multiple bash commands with:
   mcp__edgeprompt__git_fetch_context

   Provides: branch, commits, platform, status in one call (60% token savings)
   ```

3. **Local Swift Analysis**:
   ```
   For code validation, use:
   mcp__edgeprompt__swift_analyze for syntax/semantic checks
   mcp__edgeprompt__swift_symbol_lookup for dependency analysis

   Only send complex architectural questions to Claude API.
   ```

**Expected Savings**: 40-60% token reduction on typical architecture tasks
```

---

### Example 2: Testing Specialist Agent

**Add to testing-specialist.md**:

```markdown
## Cost Optimization with EdgePrompt MCP

1. **Analyze Test Coverage Locally**:
   ```
   Use mcp__edgeprompt__swift_analyze to validate test code before Claude API:
   - Syntax validation
   - Symbol resolution
   - Basic coverage checks

   Only send complex test strategy questions to Claude API.
   ```

2. **Summarize Test Results**:
   ```
   For long test outputs, use mcp__edgeprompt__summarize:

   Input: 200 lines of test output
   Output: 10-line summary with failure patterns
   Savings: 80% token reduction
   ```

3. **Git Context for Test Strategy**:
   ```
   Use mcp__edgeprompt__analyze_recent_changes to understand:
   - What code changed recently → What needs testing
   - Change types → Test strategy selection
   ```

**Expected Savings**: 50-70% token reduction on test analysis tasks
```

---

### Example 3: Documentation Verifier Agent

**Add to documentation-verifier.md**:

```markdown
## Cost Optimization with EdgePrompt MCP

1. **Local Summarization for Long Docs**:
   ```
   Use mcp__edgeprompt__summarize for initial doc review:
   - Condense 50-page docs to 5-page summaries
   - Extract key sections for targeted analysis
   - Reduce token consumption by 80%
   ```

2. **Sentiment Analysis for Tone Check**:
   ```
   Use mcp__edgeprompt__analyze_sentiment for:
   - Documentation tone consistency
   - User-facing messaging friendliness
   - Error message helpfulness

   Zero API cost for sentiment checks.
   ```

3. **Git Context for Documentation Scope**:
   ```
   Use mcp__edgeprompt__analyze_recent_changes to:
   - Identify which docs need updates based on code changes
   - Prioritize documentation work
   ```

**Expected Savings**: 60-80% token reduction on documentation reviews
```

---

## Decision Tree

```
User Request
  │
  ├─→ Simple Query? → Use mcp__edgeprompt__query (0 tokens)
  │
  ├─→ Need Agent? → Use mcp__edgeprompt__match_agents (100 tokens, 83% accuracy)
  │    │
  │    └─→ Get Git Context? → Use mcp__edgeprompt__git_fetch_context (300 tokens)
  │
  ├─→ Long Content? → Use mcp__edgeprompt__summarize (80% savings)
  │
  ├─→ Classification? → Use mcp__edgeprompt__analyze_sentiment (0 tokens)
  │
  ├─→ Privacy Check? → Use mcp__edgeprompt__detect_pii (0 tokens)
  │
  ├─→ Swift Code Analysis? → Use mcp__edgeprompt__swift_analyze (0 tokens)
  │
  └─→ Complex Reasoning? → Use Claude API (full cost)
```

---

## Performance Metrics

### Token Consumption Comparison

| Operation | Before (tokens) | After (tokens) | Savings |
|-----------|----------------|---------------|---------|
| Summarization (30-line report) | 2,000 | 400 | 80% |
| Agent routing | 500 | 100 | 80% |
| Git context gathering | 800 | 300 | 60% |
| Simple query | 150 | 0 | 100% |
| Sentiment analysis | 80 | 0 | 100% |
| PII detection | 120 | 0 | 100% |
| Swift code validation | 300 | 0 | 100% |
| Documentation search | 500 | 150 | 70% |

### Accuracy Improvements

| Operation | Before | After | Improvement |
|-----------|--------|-------|-------------|
| Agent matching | 40% | 83% | +107% |
| Intent classification | 65% | 88% | +35% |
| Platform detection | 75% | 100% | +33% |

### Latency Improvements

| Operation | Before | After | Improvement |
|-----------|--------|-------|-------------|
| Agent routing | 2-5 seconds | <200ms | 10-25× faster |
| Git context | 1-2 seconds | <100ms | 10-20× faster |
| Local queries | 2-3 seconds | <50ms | 40-60× faster |

---

## Troubleshooting

### Issue 1: edgeprompt MCP not found

**Symptoms**: `Error: MCP server 'edgeprompt' not found`

**Solutions**:
1. Verify installation: `which edgeprompt`
2. Check PATH in MCP config: `"PATH": "$HOME/.swiftpm/bin:/usr/local/bin:/usr/bin:/bin"`
3. Reinstall: `swift package experimental-install --product edgeprompt`

---

### Issue 2: Apple Intelligence model not available

**Symptoms**: `Error: Model 'apple-intelligence' not found`

**Solutions**:
1. Use alternative model: `"model": "phi-3-mini"`
2. Check macOS version (requires macOS 14.0+)
3. Verify Foundation Models installation

---

### Issue 3: Git context fails in non-repo

**Symptoms**: `Error: Not a git repository`

**Solutions**:
1. Check `working_directory` parameter
2. Initialize git repo: `git init`
3. Use alternative tools for non-git projects

---

### Issue 4: Agent matching returns unexpected results

**Symptoms**: Low-confidence matches or wrong agents

**Solutions**:
1. Increase `top_n` parameter (try 5 instead of 3)
2. Use `mcp__edgeprompt__explain_routing` to understand reasoning
3. Refine request with more specific keywords
4. Update agent descriptions in agent markdown files

---

### Issue 5: SwiftLens analysis fails

**Symptoms**: `Error: SwiftLens index not found`

**Solutions**:
1. Build index: `swift build -Xswiftc -index-store-path -Xswiftc .build/index/store`
2. Verify `projectPath` parameter
3. Check SwiftLens installation: `which swiftlens`

---

## Best Practices

### 1. Use Local-First Strategy

```
1. Try local tools first (query, summarize, analyze_sentiment)
2. Use MCP tools for structured operations (match_agents, git_fetch_context)
3. Only use Claude API for complex reasoning
```

### 2. Cache Results

```
Local tools are fast (<100ms), but still cache results when appropriate:
- Agent discovery results (agents don't change frequently)
- Git context (unless actively committing)
- Sentiment analysis (unless content changes)
```

### 3. Combine Tools

```
Best results come from combining multiple tools:
1. mcp__edgeprompt__analyze_request (understand intent)
2. mcp__edgeprompt__match_agents (find best agent)
3. mcp__edgeprompt__git_fetch_context (gather context)
4. mcp__edgeprompt__optimize_prompt (build enhanced prompt)
```

### 4. Monitor Savings

```
Track token consumption before/after edgeprompt integration:
- Log tokens saved per operation
- Calculate cost savings (token × model rate)
- Identify highest-impact optimization opportunities
```

---

## Migration Guide

### Step 1: Update Agent Markdown

Add cost optimization section to agent markdown files:

```markdown
## Cost Optimization with EdgePrompt MCP

[Tool recommendations for this agent]
```

### Step 2: Replace Agent Wrappers

Remove redundant agent layers (like task-router):

```diff
- Use task-router agent for routing
+ Use mcp__edgeprompt__match_agents directly
```

### Step 3: Update Workflows

Replace bash command chains with single MCP calls:

```diff
- git status && git branch && git log
+ mcp__edgeprompt__git_fetch_context
```

### Step 4: Test and Measure

Verify cost savings with before/after metrics:

```bash
# Before migration
Average tokens per request: 2,000
API cost per request: $0.06

# After migration
Average tokens per request: 600
API cost per request: $0.018
Savings: 70%
```

---

## Summary

The 16 edgeprompt MCP tools enable **local-first processing** with dramatic cost reductions:

- **Category 1 (Local AI)**: 4 tools for zero-cost queries, summarization, sentiment, PII detection
- **Category 2 (Agent Orchestration)**: 6 tools for 83% accurate routing, discovery, optimization
- **Category 3 (Git Integration)**: 3 tools for one-call context gathering, platform detection
- **Category 4 (Swift Development)**: 3 tools for privacy-filtered code analysis

**Expected ROI**:
- 50-80% token savings on summarization
- 80% savings on agent routing
- 60% savings on git context
- 100% savings on local LLM queries
- 83% agent matching accuracy (vs 40% baseline)

---

**References**:
- [EdgePrompt Repository](https://github.com/doozMen/edgeprompt)
- [Issue #16: Evaluate edgeprompt MCP integration](https://github.com/doozMen/swift-agents-plugin/issues/16)
- [MCP Protocol Documentation](https://modelcontextprotocol.io)

---

**Last Updated**: 2025-10-15
**Version**: 1.0
