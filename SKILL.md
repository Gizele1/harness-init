---
name: harness-init
description: Bootstrap a repository with OpenAI harness engineering scaffolding — AGENTS.md orientation map (~100 lines), docs/ system of record, architectural layer definition, golden principles, static/dynamic context strategy. This is the repo initialization subset of harness engineering, not the full methodology (runtime feedback loops, agent review loops, observability integration are out of scope).
triggers:
  - harness
  - harness-init
  - harness engineering
  - agent-ready
  - architecture boundaries
  - layer enforcement
argument-hint: "[phase|full]"
---

# Harness Engineering

Transform any repository into an agent-first engineering environment based on OpenAI's harness engineering methodology.

> Source: OpenAI "Harness engineering: leveraging Codex in an agent-first world"
> Reference implementation: charlesanim/harness-engineering

## Core Principles

1. **Engineers become environment designers** — define constraints, not implementations
2. **Give agents a map, not an encyclopedia** — AGENTS.md ~100 lines, progressive disclosure
3. **If agents can't see it, it doesn't exist** — all knowledge machine-readable in repo
4. **Enforce architecture mechanically** — linters and tests, not markdown instructions
5. **Boring technology wins** — composable, stable, well-trained-on APIs
6. **Entropy management is garbage collection** — recurring cleanup agents
7. **Throughput changes merge philosophy** — minimal blocking gates
8. **Agent-to-agent code review** — humans escalated only for judgment calls

## Target File Structure

```
project-root/
├── AGENTS.md                          # ~100 lines, orientation map (NOT encyclopedia)
├── CLAUDE.md                          # Claude Code specific instructions (optional)
├── .agent/
│   └── PLANS.md                       # ExecPlan standard for complex features
├── docs/
│   ├── architecture/
│   │   └── LAYERS.md                  # Definitive layer hierarchy + dependency rules
│   ├── guides/
│   │   ├── setup.md                   # Local dev environment
│   │   ├── testing.md                 # Testing conventions
│   │   └── deployment.md             # Deployment process
│   └── golden-principles/             # Canonical patterns, 30-60 lines each, DO/DON'T
│       ├── IMPORTS.md
│       ├── NAMING.md
│       ├── ERROR_HANDLING.md
│       └── TESTING.md
├── scripts/
│   └── gc/                            # Garbage collection scan scripts
├── tests/
│   └── architecture/
│       └── boundary.test.*            # Mechanical layer enforcement
└── .github/workflows/
    ├── ci.yml                         # lint + typecheck + test + build
    └── gc.yml                         # Weekly entropy scan
```

---

## Execution Workflow

### Phase 0: Discovery (NEVER SKIP)

Before generating anything, understand the repository.

#### 0a. Detect Stack

```bash
ls package.json pyproject.toml Cargo.toml go.mod Gemfile build.gradle pom.xml composer.json mix.exs 2>/dev/null
```

Identify: language, framework, package manager, build tool, test runner, linter.

#### 0b. Map Architecture

```bash
# Directory structure
find . -maxdepth 3 -type d | grep -v node_modules | grep -v .git | grep -v __pycache__ | sort

# Existing docs/config
ls AGENTS.md CLAUDE.md .cursorrules docs/ .github/workflows/*.yml 2>/dev/null

# Existing tests
find . -name "*.test.*" -o -name "*.spec.*" -o -name "test_*" | grep -v node_modules | head -20

# Existing lint config
ls .eslintrc* eslint.config* .pylintrc pyproject.toml .rubocop.yml .golangci.yml 2>/dev/null
```

#### 0c. Identify Layers

Every codebase has implicit layers. Make them explicit by reading actual import patterns.

**Web Frontend (React/Vue/Svelte):**
```
types/        -> No app imports (pure definitions)
utils/        -> No app imports (pure functions)
lib/          -> types/ only (clients, configs)
services/     -> lib/, types/ (business logic)
hooks/states/ -> lib/, services/, types/ (state management)
components/   -> hooks/, lib/, types/ (UI)
pages/routes/ -> components/, hooks/, lib/, types/ (entry points)
```

**Backend API (Express/FastAPI/Rails):**
```
types/models/ -> No app imports (data definitions)
config/       -> types/ only
db/repo/      -> config/, types/ (data access)
services/     -> db/, config/, types/ (business logic)
middleware/   -> services/, config/, types/ (request processing)
routes/       -> services/, middleware/, types/ (HTTP handlers)
```

**Full-Stack (Next.js/Nuxt/SvelteKit):**
```
types/        -> No app imports
lib/          -> types/ only (shared utilities)
db/           -> lib/, types/ (database)
services/     -> db/, lib/, types/ (business logic)
components/   -> lib/, types/ (UI primitives)
features/     -> components/, services/, lib/, types/ (feature modules)
app/pages/    -> features/, components/, lib/, types/ (routes)
```

**Monorepo (Turborepo/Nx):**
```
packages/types/   -> No internal imports
packages/config/  -> types/
packages/db/      -> config/, types/
packages/api/     -> db/, config/, types/
packages/ui/      -> types/ only
packages/web/     -> ui/, api/, types/
```

Adapt to the ACTUAL directory structure. Don't force a structure that doesn't fit.

#### 0d. Inject Dynamic Context

Collect current state for agent awareness:

| Signal | Command | Purpose |
|--------|---------|---------|
| Work progress | `git status` + `git log --oneline -10` | What's being done, where it stopped |
| Code health | `lsp_diagnostics` or linter output | Outstanding issues to address first |
| CI/CD status | `gh run list --limit 3` (if available) | Is main branch healthy? |
| Pending tasks | `.omc/state/` session files | Resume from last session |
| Architecture compliance | Run boundary test (if exists) | Any new layer violations? |
| Doc drift | Compare docs/ timestamps to src/ | Is documentation stale? |

#### 0e. Ask Clarifying Questions

Before proceeding, confirm:
- Which directories map to which layers?
- Special import relationships to preserve?
- Testing framework preference?
- Full setup or specific phases?

---

### Phase 1: AGENTS.md — The Orientation Map

Create `AGENTS.md` at repo root. **~100 lines. Index, not encyclopedia.**

They killed the 800-line version because agents couldn't find what they needed in a wall of context.

```markdown
# {Project Name} — Agent Orientation Map

> {One-line description}

## Stack

| Layer     | Tech       |
|-----------|------------|
| Language  | {version}  |
| Framework | {version}  |
| Database  | {type}     |

## Architecture Layers

Dependency flows **downward only**. Never import upward.

{Layer diagram from Phase 0c discovery}

## Key Conventions

- {Convention 1 — brief, pointer to docs/golden-principles/ for details}
- {Convention 2}
- {Convention 3}

## Commands

```sh
{build_command}
{test_command}
{lint_command}
{dev_command}
```

## Documentation Map

```
docs/
├── architecture/         Layer rules, dependency graph
├── guides/               Setup, testing, deployment how-tos
└── golden-principles/    Canonical patterns (DO/DON'T examples)
```

## Where to Look First

| Task              | Start here           |
|-------------------|---------------------|
| {common task 1}   | {directory/file}     |
| {common task 2}   | {directory/file}     |
| {common task 3}   | {directory/file}     |

## Constraints (Machine-Readable)

- MUST: {hard rule with pointer to enforcement}
- MUST: {hard rule}
- MUST NOT: {prohibition with pointer to LAYERS.md}
- PREFER: {soft preference}
- VERIFY: {verification command before PR}
```

---

### Phase 2: docs/ — System of Record

The structured docs/ directory is the single source of truth. AGENTS.md is just the index.

#### 2a. Create Structure

```bash
mkdir -p docs/architecture docs/guides docs/golden-principles
```

Only create subdirectories that make sense for the repo's scale. Consider also:
- `docs/features/` — feature specifications (if applicable)
- `docs/integrations/` — third-party service docs (if applicable)
- `docs/security/` — auth, access control (if applicable)

#### 2b. Create docs/architecture/LAYERS.md

The definitive reference for layer hierarchy. Must include:

1. **Layer diagram** — ASCII with allowed dependency directions
2. **Hard rules** — violations that cause CI failure
3. **What each layer contains** — responsibility and key files
4. **Remediation guide** — for each common violation, how to fix it

Every CI error message should point back to this file.

#### 2c. Create Golden Principles

3-5 docs in `docs/golden-principles/`, each 30-60 lines with DO and DON'T examples.

Common candidates (pick what fits the stack):
- **IMPORTS.md** — path aliases, import ordering, no deep relative imports
- **NAMING.md** — file naming, export conventions
- **ERROR_HANDLING.md** — how to handle and report errors
- **TESTING.md** — what to test, testing patterns
- **DATA_FETCHING.md** — data fetching and caching (frontend)
- **LOGGING.md** — logging conventions

**Read actual codebase patterns before writing these. Discover, don't guess.**

---

### Phase 3: Testing — Mechanical Enforcement

#### 3a. Architecture Boundary Test

This is the most critical test. It:

1. Scans all source files
2. Parses import/require statements
3. Determines layer membership per file
4. Validates imports respect layer rules
5. Fails with actionable error messages

Key design:
- Error format: `VIOLATION: {file} imports from {target} — {layer} cannot import from {target_layer}. See docs/architecture/LAYERS.md`
- **Ratchet mechanism**: `KNOWN_VIOLATIONS` list can only shrink, never grow without review
- Test passes if all violations are known; fails if new ones appear

#### 3b. Example Tests

Write 3-5 example tests demonstrating the codebase's testing patterns:
- Pure utility function test
- Configuration validation test
- Component/handler test (if applicable)
- The architecture boundary test

---

### Phase 4: Linting — Import Boundary Enforcement

Use linter's native capabilities. **Every error message MUST include remediation** — error output IS agent context.

**ESLint (JS/TS):**
```javascript
{
  files: ['src/lib/**/*.{ts,tsx}'],
  rules: {
    'no-restricted-imports': ['error', {
      patterns: [{
        group: ['@/services/*', '@/hooks/*', '@/components/*'],
        message: 'lib/ is Layer 3 — cannot import from higher layers. See docs/architecture/LAYERS.md'
      }]
    }]
  }
}
```

**Ruff (Python):** Use `banned-api` or `per-file-ignores`.
**Go:** Use `depguard` via golangci-lint.
**Rust:** Use `clippy` restrictions or workspace dependency rules.

---

### Phase 5: CI Pipeline

Create `.github/workflows/ci.yml` with parallel jobs: lint, typecheck, test, build.

Adapt jobs to stack. Not every stack needs all 4.

---

### Phase 6: Garbage Collection

#### 6a. GC Check Scripts

Simple scripts scanning for anti-patterns:
- Raw console/print statements (should use logger)
- Default exports (should use named exports, JS/TS)
- Large files (>300 lines warn, >500 error)
- TODO/FIXME/HACK comments (tech debt tracking)
- Missing type annotations
- Unused imports

Each script: scan, find violation, report with file:line, exit 0/1.

#### 6b. GC Runner

Single command runs all checks:
```bash
npm run gc        # or
python scripts/gc_run_all.py  # or
make gc
```

#### 6c. Scheduled GitHub Action

Cron `0 9 * * 1` (Monday 9am UTC). Results posted as GitHub issue with label `garbage-collection`.

---

### Phase 7: Pre-commit Hooks (Optional)

- **JS/TS:** husky + lint-staged
- **Python:** pre-commit framework with ruff, mypy, pytest hooks
- **Go:** golangci-lint as pre-commit hook

---

## Context Strategy: Static vs Dynamic

### Static Context (lives in repo, always available)

| Artifact | File | Role |
|----------|------|------|
| Orientation map | `AGENTS.md` | Agent entry point, ~100 lines index |
| Layer rules | `docs/architecture/LAYERS.md` | Authoritative dependency hierarchy |
| Canonical patterns | `docs/golden-principles/*.md` | DO/DON'T, 30-60 lines each |
| Dev guides | `docs/guides/*.md` | setup, testing, deployment |
| ExecPlan standard | `.agent/PLANS.md` | Template for complex features |
| Constraints | Linter rules + boundary tests | Mechanical enforcement, not markdown |

### Dynamic Context (probed at each session start)

| Signal | Source | Role |
|--------|--------|------|
| Work progress | `git status` + `git log` | What's in flight, where we stopped |
| Code health | LSP diagnostics / linter | Issues to address first |
| CI status | GitHub Actions / pipeline | Is main branch healthy? |
| Unfinished tasks | `.omc/state/` session | Resume from last session |
| Architecture compliance | Boundary test run | New layer violations? |
| Documentation drift | docs/ vs src/ timestamps | Stale documentation? |

**The distinction:** Static = "what are the rules". Dynamic = "what is the current state". Both required — static provides the map, dynamic provides the terrain.

---

## .agent/PLANS.md — ExecPlan Standard

For complex features or significant refactors. Core requirements:
- **Fully self-contained** — newcomer can implement without prior knowledge
- **Living document** — updated with progress, surprises, decisions
- **Restartable** — can resume from only the ExecPlan, no other state

Required sections:
1. Purpose / Big Picture
2. Progress (timestamped checkboxes)
3. Surprises & Discoveries
4. Decision Log
5. Outcomes & Retrospective
6. Context and Orientation
7. Plan of Work
8. Concrete Steps (exact commands + expected output)
9. Validation and Acceptance
10. Idempotence and Recovery

---

## Execution Order

When user says "harness" or "init harness":

1. **Phase 0** — Discovery (ALWAYS first, NEVER skip)
2. **Phase 1** — AGENTS.md orientation map
3. **Phase 2** — docs/ structure + LAYERS.md + golden principles
4. **Phase 3** — Architecture boundary test
5. **Phase 4** — Linter boundary enforcement
6. **Phase 5** — CI pipeline
7. **Phase 6** — Garbage collection scripts + workflow
8. **Phase 7** — Pre-commit hooks

Ask the user: "Full setup (all phases) or specific phases?"

Use a feature branch (`feat/harness-engineering`) in a git worktree if requested.

## Important Rules

1. **Never hardcode project-specific details.** Discover the stack, don't assume.
2. **Read before you write.** Match existing code style.
3. **Use git mv for doc restructuring.** Preserve history.
4. **Every error message is agent context.** Remediation in error output, not just in docs.
5. **Architecture test is a ratchet.** KNOWN_VIOLATIONS can only shrink.
6. **Don't break existing behavior.** New lint rules warn first if pre-existing violations exist.
7. **Test your work.** Run test suite, linter, and GC scripts after setup.

## Delegation

| Task | Agent | Model |
|------|-------|-------|
| Directory mapping | `explore` | haiku |
| Architecture analysis | `architect` | opus |
| AGENTS.md + docs | `writer` | haiku |
| Boundary test | `executor` | sonnet |
| Linter config | `executor` | sonnet |
| CI pipeline | `executor` | sonnet |
| GC scripts | `executor` | sonnet |
| Verification | `verifier` | sonnet |
