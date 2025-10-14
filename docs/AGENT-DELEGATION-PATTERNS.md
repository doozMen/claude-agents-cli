# Agent Delegation Patterns

Guide to delegation patterns in Claude Code agents, explaining how agents coordinate work when they cannot automatically invoke each other.

## Core Principle

**Agents cannot automatically delegate to other agents.** Claude Code does not support agents automatically invoking other agents mid-conversation. Instead, agents use **suggestion-based delegation** combined with **tool restriction** to encourage proper task routing.

## Why Delegation Matters

### Cost Optimization
- **Haiku** ($1/M tokens): Mechanical tasks (formatting, builds, simple tests)
- **Sonnet** ($3/M tokens): Balanced tasks (feature development, reviews, documentation)
- **Opus** ($15/M tokens): Complex reasoning (architecture, design, research)

Using the right model for each task can reduce costs by 60-90%.

### Expertise Specialization
Each agent is optimized for specific domains with relevant tools, prompts, and examples. Delegation ensures the right expertise is applied to each subtask.

## Delegation Mechanisms

### 1. Tool Restriction
**Remove tools from agents that should delegate specific tasks.**

**Example**: swift-developer (Sonnet) should write code but not run tests.

```markdown
---
name: swift-developer
tools: Read, Edit, Glob, Grep, MultiEdit  # No Bash!
model: sonnet
---
```

By removing Bash, the agent physically cannot run `xcrun swift test` and must suggest delegation.

### 2. Explicit Guidance
**Add clear delegation sections to agent prompts.**

```markdown
## Delegation Rules

### What You Handle
✅ Write Swift code
✅ Fix compilation errors
✅ Implement features
✅ Refactor existing code

### What You Delegate
❌ Running tests → @swift-build-runner
❌ Building projects → @swift-build-runner
❌ Formatting code → @swift-format-specialist
❌ Creating tests → @test-builder
```

### 3. Suggestion Format
**Agents suggest delegation using @mentions and clear reasoning.**

```markdown
I've implemented the new authentication feature. To verify it works correctly,
please invoke @swift-build-runner to run the test suite:

@swift-build-runner run tests for AuthenticationService
```

## Common Delegation Patterns

### Pattern 1: Code Writing → Testing
**swift-developer → swift-build-runner**

```
User: "Implement user authentication"
swift-developer:
  1. Writes code ✅
  2. Suggests: "@swift-build-runner run tests" ✅

User: "@swift-build-runner run tests"
swift-build-runner:
  1. Runs `xcrun swift test` ✅
  2. Reports results ✅
```

**Tools**:
- swift-developer: No Bash (cannot run tests)
- swift-build-runner: Bash only (runs tests efficiently with Haiku)

**Cost Savings**: 67% (Sonnet → Haiku for mechanical task)

### Pattern 2: Code Writing → Formatting
**swift-developer → swift-format-specialist**

```
User: "Add new API endpoint"
swift-developer:
  1. Writes code ✅
  2. Suggests: "@swift-format-specialist format the changes" ✅

User: "@swift-format-specialist format Sources/"
swift-format-specialist:
  1. Runs `swift format format -p -r -i Sources/` ✅
  2. Reports formatted files ✅
```

**Cost Savings**: 67% (Sonnet → Haiku for mechanical task)

### Pattern 3: Architecture → Implementation
**architect → swift-developer**

```
User: "Design a caching system"
architect (Opus):
  1. Creates architectural design ✅
  2. Suggests: "@swift-developer implement CacheManager" ✅

User: "@swift-developer implement CacheManager based on architect's design"
swift-developer (Sonnet):
  1. Implements code ✅
  2. Suggests: "@test-builder create tests" ✅
```

**Cost Savings**: 80% (Opus → Sonnet), then 67% (Sonnet → Haiku)

### Pattern 4: Test Creation → Execution
**test-builder → swift-build-runner**

```
User: "Create tests for NetworkManager"
test-builder:
  1. Creates test file ✅
  2. Suggests: "@swift-build-runner validate tests" ✅

User: "@swift-build-runner run tests"
swift-build-runner:
  1. Runs tests ✅
  2. Reports success/failure ✅
```

### Pattern 5: Code Review → Fixes
**code-reviewer → swift-developer**

```
User: "Review pull request #42"
code-reviewer:
  1. Reviews code ✅
  2. Identifies issues ✅
  3. Suggests: "@swift-developer fix issues in UserService.swift:45" ✅

User: "@swift-developer fix the issues code-reviewer found"
swift-developer:
  1. Applies fixes ✅
  2. Suggests: "@swift-build-runner verify fixes" ✅
```

### Pattern 6: Multi-Agent Parallel
**Complex tasks benefit from parallel execution.**

```
User: "Refactor legacy authentication system and add tests"
task-router:
  Suggests running in parallel:
  1. @swift-modernizer (refactor code)
  2. @test-builder (create tests)
  3. @documentation-verifier (update docs)

User runs all three agents concurrently, then:

User: "@swift-build-runner validate everything"
swift-build-runner:
  1. Builds project ✅
  2. Runs tests ✅
  3. Reports results ✅
```

## Agent Tool Assignments

### No Bash (Delegators)
These agents write code but delegate execution:
- swift-developer
- swift-architect
- swift-modernizer
- swiftui-specialist
- hummingbird-developer
- swift-grpc-temporal-developer
- grdb-sqlite-specialist

### Bash Only (Executors)
These agents execute but don't write code:
- swift-build-runner (Haiku) - builds and tests
- swift-format-specialist (Haiku) - formatting

### Full Toolset (Self-Sufficient)
These agents handle their domain end-to-end:
- test-builder - creates and validates tests
- architect - researches and designs
- code-reviewer - reviews without modifying
- documentation-verifier - docs only

## Best Practices

### 1. Clear Boundaries
Each agent should have a clear, non-overlapping responsibility.

✅ **Good**: swift-developer writes code, swift-build-runner runs tests
❌ **Bad**: Both agents can write code AND run tests (redundant)

### 2. Explicit Suggestions
When delegating, be specific:

✅ **Good**: "Please invoke @swift-build-runner to run tests for AuthService"
❌ **Bad**: "Now run tests" (user doesn't know which agent)

### 3. Model Optimization
Use the cheapest model that can handle the task:

- **Haiku**: Formatting, builds, simple tests
- **Sonnet**: Code writing, reviews, documentation
- **Opus**: Architecture, design, research

### 4. Tool Restriction
If an agent should delegate a task, remove the tools it needs:

- No Bash → Cannot run commands → Must delegate execution
- No Edit → Cannot modify files → Must delegate changes

### 5. User Confirmation
Always require user confirmation before delegation suggestions:

✅ **Good**: Agent suggests, user confirms and invokes
❌ **Bad**: Agent attempts automatic invocation (not supported)

## Delegation Anti-Patterns

### ❌ Attempting Auto-Delegation
```markdown
# Bad - This doesn't work
I'll now invoke swift-build-runner to run tests...
<invoke agent="swift-build-runner" task="run tests"/>
```

Claude Code doesn't support this. Agents must suggest, users must invoke.

### ❌ Duplicate Capabilities
```markdown
# Bad - Both agents can format
swift-developer: tools: Read, Edit, Bash  # Can format
swift-format-specialist: tools: Bash      # Can format
```

This defeats the purpose of delegation. Remove Bash from swift-developer.

### ❌ Circular Dependencies
```markdown
# Bad
Agent A → delegates to Agent B
Agent B → delegates to Agent A
```

Design clear hierarchies: Architect → Developer → Build Runner

### ❌ Vague Suggestions
```markdown
# Bad
"You should probably run tests now"
```

Be specific: "Please invoke @swift-build-runner to run tests"

## Testing Delegation

### Verify Tool Restrictions
```bash
# Check agent doesn't have Bash
grep "tools:" ~/.claude/agents/swift-developer.md
# Should NOT contain "Bash"

# Check agent has Bash
grep "tools:" ~/.claude/agents/swift-build-runner.md
# Should contain "Bash"
```

### Verify Delegation Guidance
```bash
# Check agent has delegation section
grep -A 10 "Delegation" ~/.claude/agents/swift-developer.md
```

### Test Cost Optimization
Track token usage when using proper delegation:
- Architecture (Opus) → Implementation (Sonnet) → Tests (Haiku)
- Should see 70-80% cost reduction vs using Sonnet for everything

## Migration Guide

### Step 1: Identify Agents That Should Delegate
Look for agents that both write code AND run builds/tests:
```bash
grep -l "Bash" ~/.claude/agents/swift-*.md | while read f; do
  grep "write.*code\|implement.*feature" "$f" && echo "$f"
done
```

### Step 2: Remove Bash Tool
```bash
# For each agent that should delegate
sed -i '' 's/tools:.*Bash/tools: Read, Edit, Glob, Grep, MultiEdit/' agent.md
```

### Step 3: Add Delegation Section
Add clear "Delegation Rules" section with examples.

### Step 4: Test Workflow
1. Invoke code-writing agent
2. Agent writes code
3. Agent suggests delegation
4. User invokes execution agent
5. Execution agent runs tests

### Step 5: Verify Cost Savings
Compare token usage before and after delegation implementation.

## Real-World Example

### Before Delegation (Single Agent)
```
User: "Add caching to UserService and test it"

swift-developer (Sonnet, 10K tokens):
1. Designs caching ✅ (3K tokens, Sonnet @ $3/M = $0.009)
2. Implements code ✅ (5K tokens, Sonnet @ $3/M = $0.015)
3. Runs tests ✅ (2K tokens, Sonnet @ $3/M = $0.006)

Total: $0.030
```

### After Delegation (Multi-Agent)
```
User: "Design caching for UserService"
architect (Opus, 3K tokens):
1. Designs caching ✅ (3K tokens, Opus @ $15/M = $0.045)

User: "@swift-developer implement caching based on design"
swift-developer (Sonnet, 5K tokens):
1. Implements code ✅ (5K tokens, Sonnet @ $3/M = $0.015)

User: "@swift-build-runner run tests"
swift-build-runner (Haiku, 2K tokens):
1. Runs tests ✅ (2K tokens, Haiku @ $1/M = $0.002)

Total: $0.062
```

**Wait, that's MORE expensive!**

The key is reuse. Once architect designs the pattern, swift-developer can implement it across 10 services without re-invoking architect:

```
1 architect call: $0.045
10 swift-developer calls: $0.150
10 swift-build-runner calls: $0.020

Total for 10 services: $0.215 ($0.0215 per service)
vs without delegation: $0.300 ($0.030 per service)

Savings: 28%
```

## Conclusion

Delegation in Claude Code requires:
1. **Tool restriction** to prevent agents from doing tasks they should delegate
2. **Explicit guidance** in agent prompts about what to delegate
3. **User confirmation** for all delegation (no automatic invocation)
4. **Clear suggestions** using @mentions and specific instructions

This pattern enables:
- **Cost optimization** by using cheaper models for mechanical tasks
- **Expertise specialization** by routing to domain experts
- **Quality improvement** through focused agent capabilities
- **Maintainability** via clear separation of concerns

Follow these patterns to build efficient, cost-effective agent workflows.
