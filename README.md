# harness-init

Bootstrap any repository with [OpenAI's harness engineering](https://openai.com/index/harness-engineering/) scaffolding for agent-first development.

> **Scope:** This is the **repo initialization subset** of harness engineering. Runtime feedback loops, agent review loops, and observability integration are out of scope.

## What It Does

Transforms a repository into an agent-ready environment through 7 phases:

| Phase | What |
|-------|------|
| 0. Discovery | Detect stack, map architecture, identify layers, inject dynamic context |
| 1. AGENTS.md | ~100-line orientation map (index, not encyclopedia) |
| 2. docs/ | System of record: `architecture/LAYERS.md` + `golden-principles/` + `guides/` |
| 3. Testing | Architecture boundary test with ratchet mechanism |
| 4. Linting | Import restriction rules with remediation in error messages |
| 5. CI | Parallel lint + typecheck + test + build pipeline |
| 6. GC | Garbage collection scripts + scheduled weekly scan |
| 7. Hooks | Pre-commit enforcement |

## Core Principles (from OpenAI)

1. Engineers become environment designers
2. Give agents a map, not an encyclopedia
3. If agents can't see it, it doesn't exist
4. Enforce architecture mechanically, not via markdown
5. Boring technology wins
6. Entropy management is garbage collection
7. Throughput changes merge philosophy
8. Agent-to-agent code review

## Installation

### Claude Code (with oh-my-claudecode)

```bash
# Copy to user-level skills (available across all projects)
mkdir -p ~/.claude/skills/omc-learned/harness-init
curl -fsSL https://raw.githubusercontent.com/Gizele1/harness-init/main/SKILL.md \
  -o ~/.claude/skills/omc-learned/harness-init/SKILL.md
```

### Claude Code (native)

```bash
# Copy to project-level skills
mkdir -p .claude/skills/harness-init
curl -fsSL https://raw.githubusercontent.com/Gizele1/harness-init/main/SKILL.md \
  -o .claude/skills/harness-init/SKILL.md
```

### OpenAI Codex

```bash
# Copy to Codex skills directory
mkdir -p .agents/skills/harness-init
curl -fsSL https://raw.githubusercontent.com/Gizele1/harness-init/main/SKILL.md \
  -o .agents/skills/harness-init/SKILL.md
```

### Cursor

Copy the content of `SKILL.md` into your `.cursor/rules/harness-init.md` or `.cursorrules` file.

### Manual

Just read `SKILL.md` and follow the phases manually in any AI coding assistant.

## Usage

In Claude Code:

```
/harness-init          # Full setup, all phases
/harness-init 2        # Specific phase only
```

Or simply say:

- "harness init this repo"
- "make this repo agent-ready"
- "set up architecture boundaries"

## What Gets Created

```
project-root/
├── AGENTS.md                          # ~100 lines, orientation map
├── .agent/
│   └── PLANS.md                       # ExecPlan standard
├── docs/
│   ├── architecture/
│   │   └── LAYERS.md                  # Layer hierarchy + dependency rules
│   ├── guides/
│   │   ├── setup.md
│   │   ├── testing.md
│   │   └── deployment.md
│   └── golden-principles/             # 30-60 lines each, DO/DON'T
│       ├── IMPORTS.md
│       ├── NAMING.md
│       ├── ERROR_HANDLING.md
│       └── TESTING.md
├── scripts/gc/                        # Garbage collection scripts
├── tests/architecture/
│   └── boundary.test.*                # Mechanical layer enforcement
└── .github/workflows/
    ├── ci.yml                         # lint + typecheck + test + build
    └── gc.yml                         # Weekly entropy scan
```

## Context Strategy

The skill distinguishes between two types of context:

**Static context** (lives in repo, always available):
- `AGENTS.md` — agent entry point, ~100 lines
- `docs/architecture/LAYERS.md` — authoritative dependency hierarchy
- `docs/golden-principles/*.md` — canonical patterns
- Linter rules + boundary tests — mechanical enforcement

**Dynamic context** (probed at each session start):
- `git status` + `git log` — work progress
- LSP diagnostics — code health
- CI/CD status — pipeline health
- Architecture boundary test — compliance check

## Supported Stacks

Works with any stack. Layer templates provided for:

- Web Frontend (React / Vue / Svelte)
- Backend API (Express / FastAPI / Rails)
- Full-Stack (Next.js / Nuxt / SvelteKit)
- Monorepo (Turborepo / Nx)

The skill reads actual import patterns to discover the real dependency graph rather than assuming a structure.

## Limitations

This skill implements the **repo scaffolding** part of OpenAI's harness engineering methodology. It does **not** cover:

- Runtime legibility (starting apps, browser/CDP verification)
- Observability integration (logs, metrics, traces queryable by agents)
- Agent review loops (agent-to-agent PR review)
- Automatic regression verification
- PR feedback iteration loops
- Quality scoring and tracking
- Design docs and product specs versioning

These capabilities require runtime infrastructure beyond what a skill file can provide.

## References

- [Harness engineering: leveraging Codex in an agent-first world | OpenAI](https://openai.com/index/harness-engineering/)
- [Custom instructions with AGENTS.md | OpenAI Developers](https://developers.openai.com/codex/guides/agents-md)
- [Using PLANS.md for multi-hour problem solving | OpenAI Cookbook](https://developers.openai.com/cookbook/articles/codex_exec_plans)
- [Best practices | Codex](https://developers.openai.com/codex/learn/best-practices)
- [Harness Engineering | Martin Fowler](https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html)

## License

MIT
