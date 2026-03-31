# harness-init

Bootstrap any repository with [OpenAI's harness engineering](https://openai.com/index/harness-engineering/) scaffolding for agent-first development.

> **Scope:** This is the **repo initialization subset** of harness engineering. Runtime feedback loops, agent review loops, and observability integration are out of scope.

## What It Does

Transforms a repository into an agent-ready environment through 8 phases:

| Phase | What |
|-------|------|
| 0. Discovery | Detect stack, map architecture, identify layers, inject dynamic context |
| 1. AGENTS.md | ~100-line orientation map (index, not encyclopedia) |
| 2. docs/ | System of record: `architecture/LAYERS.md` + `golden-principles/` + `SECURITY.md` + `guides/` |
| 3. Testing | Architecture boundary test with ratchet mechanism |
| 4. Linting | Import restriction rules with remediation in error messages |
| 5. CI | Parallel lint + typecheck + test + build pipeline |
| 6. GC | Garbage collection scripts + scheduled weekly scan |
| 7. Hooks | Pre-commit enforcement |

## Core Principles (from OpenAI)

1. Engineers become environment designers — define constraints, not implementations
2. Give agents a map, not an encyclopedia — AGENTS.md ~100 lines, progressive disclosure
3. If agents can't see it, it doesn't exist — all knowledge machine-readable in repo
4. Enforce architecture mechanically, not via markdown — linters and tests, not prose
5. Boring technology wins — composable, stable, well-trained-on APIs
6. Entropy management is garbage collection — periodic scans catch drift
7. Throughput changes merge philosophy — minimal blocking gates
8. Agent-to-agent code review — humans intervene only for judgment calls

## Installation

### Claude Code (with oh-my-claudecode)

```bash
# Clone and copy to user-level skills (available across all projects)
rm -rf /tmp/harness-init 2>/dev/null; git clone --depth 1 https://github.com/Gizele1/harness-init.git /tmp/harness-init
mkdir -p ~/.claude/skills/omc-learned/harness-init/references
cp /tmp/harness-init/SKILL.md ~/.claude/skills/omc-learned/harness-init/
cp /tmp/harness-init/references/*.md ~/.claude/skills/omc-learned/harness-init/references/
rm -rf /tmp/harness-init
```

### Claude Code (native)

```bash
# Clone and copy to project-level skills
rm -rf /tmp/harness-init 2>/dev/null; git clone --depth 1 https://github.com/Gizele1/harness-init.git /tmp/harness-init
mkdir -p .claude/skills/harness-init/references
cp /tmp/harness-init/SKILL.md .claude/skills/harness-init/
cp /tmp/harness-init/references/*.md .claude/skills/harness-init/references/
rm -rf /tmp/harness-init
```

### OpenAI Codex

```bash
# Clone and copy to Codex skills directory
rm -rf /tmp/harness-init 2>/dev/null; git clone --depth 1 https://github.com/Gizele1/harness-init.git /tmp/harness-init
mkdir -p .agents/skills/harness-init/references
cp /tmp/harness-init/SKILL.md .agents/skills/harness-init/
cp /tmp/harness-init/references/*.md .agents/skills/harness-init/references/
rm -rf /tmp/harness-init
```

### Cursor

Copy the content of `SKILL.md` and the `references/` directory into your `.cursor/rules/harness-init/` directory, or inline the reference content into `.cursorrules`.

### Manual

Just read `SKILL.md` and follow the phases manually in any AI coding assistant.

## Usage

In Claude Code:

```
/harness-init          # Interactive — asks what to set up
/harness-init full     # Full setup, all phases
/harness-init 2        # Specific phase only
/harness-init 3-4      # Phase range
```

Or simply say:

- "harness init this repo"
- "make this repo agent-ready"
- "set up architecture boundaries"

## What Gets Created

```
project-root/
├── AGENTS.md                          # ~100 lines, orientation map          [Required]
├── ARCHITECTURE.md                    # Top-level domain map                 [Required]
├── docs/
│   ├── architecture/
│   │   └── LAYERS.md                  # Layer hierarchy + enforcement        [Required]
│   ├── golden-principles/             # DO/DON'T patterns, 30-60 lines each [Required]
│   ├── SECURITY.md                    # Auth, secrets, threat model          [Required]
│   ├── guides/                        # Setup, testing, deployment           [Recommended]
│   ├── exec-plans/                    # ExecPlan lifecycle                   [Recommended]
│   │   ├── active/
│   │   ├── completed/
│   │   └── tech-debt-tracker.md
│   ├── design-docs/                   # ADRs                                [Recommended]
│   │   ├── index.md
│   │   ├── core-beliefs.md
│   │   └── {NNNN-title}.md
│   ├── references/                    # External docs for LLMs              [Recommended]
│   │   └── {library}-llms.txt
│   ├── DESIGN.md                      # Design philosophy                   [Recommended]
│   ├── PLANS.md                       # Exec-plans overview                 [Recommended]
│   ├── QUALITY_SCORE.md               # Per-domain quality grades           [Recommended]
│   ├── RELIABILITY.md                 # SLA, error budgets (services only)  [Conditional]
│   ├── STACK.md                       # Stack conventions                   [Conditional]
│   ├── product-specs/                 # Product specs                       [Conditional]
│   └── generated/                     # Auto-generated docs                 [Conditional]
│       └── {db-schema,api-spec}.md
├── scripts/gc/                        # Garbage collection scripts
├── tests/architecture/
│   └── boundary.test.*                # Mechanical layer enforcement
└── .github/workflows/
    ├── ci.yml                         # lint + typecheck + test + build
    └── gc.yml                         # Weekly entropy scan
```

## File Structure Design

The file structure above is synthesized from multiple industry sources and designed with clear priority tiers.

### Priority Tiers

| Tier | Meaning | When to create |
|------|---------|---------------|
| **Required** | Core scaffolding every agent-ready repo needs | Always — Phase 0-2 |
| **Recommended** | High-value docs that most projects benefit from | Projects with >1 contributor or >3 months lifespan |
| **Conditional** | Context-dependent — only when the project type demands it | Phase 0 discovery determines applicability |

### Design Decisions and Sources

**AGENTS.md at repo root** — Industry standard adopted by 20,000+ repositories ([agents.md standard](https://agents-md.org/)). Serves as the single entry point for any AI agent. Kept to ~100 lines as an index, not an encyclopedia — following OpenAI's "give agents a map" principle.

**ARCHITECTURE.md at repo root** — Top-level domain map visible without navigating into docs/. Points to `docs/architecture/LAYERS.md` for details. Follows progressive disclosure: root-level files are summaries, docs/ has depth.

**docs/ as system of record** — Consolidates all project knowledge in one discoverable location. Agents scan `docs/` as their primary context source. This is directly from OpenAI's harness engineering: "if agents can't see it, it doesn't exist."

**docs/architecture/LAYERS.md** — The definitive layer hierarchy, mechanically enforced by boundary tests (Phase 3) and linter rules (Phase 4). Not just documentation — it's the source of truth that tooling reads.

**docs/golden-principles/** — 30-60 line DO/DON'T files per concern (imports, naming, error handling, testing). Short enough for agents to consume fully, specific enough to prevent drift. From OpenAI's "canonical patterns" concept.

**docs/exec-plans/ (active/completed/)** — Dual-source design: directory lifecycle from the [Harness article](https://openai.com/index/harness-engineering/) (active → completed with retrospectives), single-file alternative from [OpenAI Cookbook](https://developers.openai.com/cookbook/articles/codex_exec_plans). Active plans move to completed/ when done, preserving context for downstream agents.

**docs/design-docs/ with ADR format** — Architecture Decision Records following the `{NNNN-title}.md` convention ([ADR standard](https://adr.github.io/)). `core-beliefs.md` captures non-negotiable decisions that agents must never violate. `index.md` provides a navigable list.

**docs/SECURITY.md** — Auth flows, secrets management, and threat model in one place. Agents working on auth-adjacent code need this context to avoid introducing vulnerabilities.

**Conditional docs (RELIABILITY.md, STACK.md, product-specs/, generated/)** — Only created when Phase 0 discovery detects the relevant project type. RELIABILITY.md for services with SLAs. STACK.md replaces OpenAI's original FRONTEND.md with a stack-agnostic name. product-specs/ for product-driven projects. generated/ for auto-generated schemas.

**QUALITY_SCORE.md under docs/, not root** — Keeps the repo root clean. Only AGENTS.md and ARCHITECTURE.md live at root because they're universal entry points. Everything else lives in docs/ for organization.

### What Changed from OpenAI's Original

| OpenAI Original | harness-init | Why |
|----------------|-------------|-----|
| FRONTEND.md | docs/STACK.md | Stack-agnostic — works for backend, mobile, etc. |
| .agent/PLANS.md | docs/exec-plans/ or docs/PLANS.md | Directory lifecycle for multi-feature projects, single-file for simple ones |
| Flat docs/ | Tiered docs/ with priority levels | Agents know what's essential vs optional |
| No ADRs | docs/design-docs/ with ADR format | Captures architectural decisions for agent context |
| No security doc | docs/SECURITY.md as required | Security context is non-optional for agent safety |

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
- Quality scoring automation (template provided, scoring is manual)
- Design docs versioning workflows

These capabilities require runtime infrastructure beyond what a skill file can provide.

## References

- [Harness engineering: leveraging Codex in an agent-first world | OpenAI](https://openai.com/index/harness-engineering/)
- [Custom instructions with AGENTS.md | OpenAI Developers](https://developers.openai.com/codex/guides/agents-md)
- [Using PLANS.md for multi-hour problem solving | OpenAI Cookbook](https://developers.openai.com/cookbook/articles/codex_exec_plans)
- [Best practices | Codex](https://developers.openai.com/codex/learn/best-practices)
- [Harness Engineering | Martin Fowler](https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html)

## License

MIT
