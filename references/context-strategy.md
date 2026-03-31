# Context Strategy: Static vs Dynamic

## Static Context (lives in repo, always available)

| Artifact | File | Role |
|----------|------|------|
| Orientation map | `AGENTS.md` | Agent entry point, ~100 lines index |
| Layer rules | `docs/architecture/LAYERS.md` | Authoritative dependency hierarchy |
| Canonical patterns | `docs/golden-principles/*.md` | DO/DON'T, 30-60 lines each |
| Dev guides | `docs/guides/*.md` | setup, testing, deployment |
| ExecPlan standard | `docs/exec-plans/` or `PLANS.md` | Template for complex features |
| Constraints | Linter rules + boundary tests | Mechanical enforcement, not markdown |

## Dynamic Context (probed at each session start)

| Signal | Source | Role |
|--------|--------|------|
| Work progress | `git status` + `git log --oneline -10` | What's in flight, where we stopped |
| Code health | LSP diagnostics / linter output | Issues to address first |
| CI status | `gh run list --limit 3` (if available) | Is main branch healthy? |
| Unfinished tasks | Session state directory or project task tracker | Resume from last session |
| Architecture compliance | Run boundary test (if exists) | New layer violations? |
| Documentation drift | Compare docs/ timestamps to src/ | Stale documentation? |
| App observability | Application logs, metrics, tracing (if available) | Runtime errors, performance issues |

## The Distinction

- **Static** = "what are the rules" → answers don't change between sessions
- **Dynamic** = "what is the current state" → must be freshly probed each time

Both required. Static provides the map, dynamic provides the terrain.

## Graceful Degradation

Not all dynamic signals are always available. Handle missing tools:

| Signal | If unavailable | Fallback |
|--------|---------------|----------|
| LSP diagnostics | No LSP server running | Run linter CLI instead |
| CI status | No `gh` CLI / not GitHub | Check for CI config, skip |
| Session state | No `.omc/state/` | Skip, note fresh session |
| Boundary test | Not yet created | Note: will be created in Phase 3 |
| App observability | No log/metrics access | Skip, note unavailable |
