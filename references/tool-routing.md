# Tool Routing by Platform

Harness-init delegates work by **intent**, not by specific tool calls. Map each intent to your platform's delegation mechanism.

## Intent → Platform Mapping

| Intent | Model Tier | Claude Code + OMC | Claude Code (native) | Codex | Cursor |
|--------|-----------|-------------------|---------------------|-------|--------|
| **Explore** | Lightweight | `Agent(subagent_type="oh-my-claudecode:explore", model="haiku")` | `Agent(subagent_type="Explore")` | `codex exec "explore ..."` or inline file search | Inline (use @codebase) |
| **Architect** | Heavyweight | `Agent(subagent_type="oh-my-claudecode:architect", model="opus")` | `Agent(subagent_type="Plan")` | `codex exec "analyze ..."` or inline | Inline (analyze in chat) |
| **Write** | Lightweight | `Agent(subagent_type="oh-my-claudecode:writer", model="haiku")` | `Agent(model="haiku")` | Inline (write directly) | Inline (write directly) |
| **Execute** | Standard | `Agent(subagent_type="oh-my-claudecode:executor", model="sonnet")` | `Agent(model="sonnet")` | `codex exec "implement ..."` | Inline (execute directly) |
| **Verify** | Standard | `Agent(subagent_type="oh-my-claudecode:verifier", model="sonnet")` | `Agent(model="sonnet")` | `codex exec "verify ..."` | Inline (verify directly) |

## Model Tiers

| Tier | Purpose | Examples |
|------|---------|----------|
| Lightweight | Fast, low-cost tasks (file listing, doc generation) | Haiku, GPT-4o-mini |
| Standard | Implementation and verification | Sonnet, GPT-4o |
| Heavyweight | Architecture decisions, deep analysis | Opus, o3 |

## Fallback

If your platform doesn't support delegation (no Agent tool, no sub-agents):
- Perform all intents inline in the main conversation
- Use the model tier as a guide for which tasks to spend more reasoning on
- The skill works without delegation — it just runs sequentially instead of in parallel
