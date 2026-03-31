---
name: harness-init
description: Use when initializing a new project, making a repo agent-ready, or adding architectural layer boundaries — produces AGENTS.md, docs/ system of record, boundary tests, linter rules, CI pipeline, and GC scripts
triggers:
  - harness
  - harness-init
  - harness engineering
  - agent-ready
  - architecture boundaries
  - layer enforcement
argument-hint: "[phase|full]"
---

# Harness Init

<Purpose>
Bootstrap a repository with OpenAI's harness engineering scaffolding: AGENTS.md orientation map, docs/ system of record, architectural layer enforcement, golden principles, garbage collection, and static/dynamic context strategy.

This is the **repo initialization subset** of harness engineering. Runtime feedback loops, agent review loops, and observability stack setup are out of scope. If the repo already has observability (logs, metrics, tracing), this skill reads it as dynamic context but does not build it.

Source: OpenAI "Harness engineering: leveraging Codex in an agent-first world" (2026-02-11)
</Purpose>

<Why_This_Exists>
AI agents can only work with what they can see. Without structured documentation, mechanical constraints, and clear layer boundaries, agents make inconsistent architectural decisions, introduce import violations, and produce code that drifts from conventions. This skill front-loads the environment design so every subsequent agent session starts with a map, not a blank slate.
</Why_This_Exists>

<Use_When>
- Creating a new project from scratch
- Making an existing repo agent-ready for the first time
- Adding architectural layer boundaries to a codebase
- User says "harness", "init harness", "make this agent-ready", "set up architecture"
- Before any major feature work in a repo that lacks AGENTS.md + docs/
</Use_When>

<Do_Not_Use_When>
- Repo already has AGENTS.md + docs/architecture/LAYERS.md + boundary tests — use existing harness
- User wants hierarchical AGENTS.md per directory — use a per-directory init tool instead
- User wants runtime observability / agent review loops — out of scope for this skill
- Quick bug fix or small feature — just do the work directly
- User wants to explore ideas or brainstorm — this skill is for structured scaffolding, not ideation
</Do_Not_Use_When>

<Principles>
1. **Give agents a map, not an encyclopedia** — AGENTS.md ~100 lines, progressive disclosure
2. **If agents can't see it, it doesn't exist** — all knowledge machine-readable in repo
3. **Enforce architecture mechanically** — linters and tests, not markdown instructions
4. **Every error message is agent context** — remediation instructions in error output
5. **Boring technology wins** — composable, stable, well-trained-on APIs
6. **Architecture test is a ratchet** — KNOWN_VIOLATIONS can only shrink, never grow
</Principles>

<Execution_Policy>
- Phase 0 (Discovery) is MANDATORY — never skip, never assume the stack
- **Argument parsing:** `full` = all phases (default). `N` = single phase. `N-M` = phase range. No argument = ask user. Phase 0 always runs regardless of argument.
- Read before you write — match existing code style and patterns
- Use `git mv` for doc restructuring to preserve history
- New lint rules warn first if pre-existing violations exist — don't break the build
- Delegate phases in parallel where independent (e.g., Phase 5 CI + Phase 7 hooks)
- Run long operations (npm install, test suites) in background
- Use a feature branch (`feat/harness-engineering`) if the repo has existing work
- **Phase checkpoints:** After each phase, verify output exists (file created + test/lint passes where applicable). Log completed phases so work can resume if interrupted.
- **Failure handling:** If a phase fails, skip it, report what failed and why, and continue to the next independent phase. Do not halt the entire run for a single phase failure.
- **Verification evidence:** "Phase complete" = output file exists AND relevant test/lint passes. File existence alone is not sufficient.
</Execution_Policy>

<Steps>
1. **Phase 0 — Discovery** (NEVER SKIP)
   a. Detect stack: language, framework, package manager, build tool, test runner, linter
   b. Map directory structure (maxdepth 3, exclude node_modules/.git)
   c. Check for existing docs: AGENTS.md, CLAUDE.md, docs/, CI workflows, tests, lint config
   d. Identify architecture layers by reading actual import patterns — `Read references/layer-templates.md` for common models
   e. Inject dynamic context: git status, diagnostics, CI status — `Read references/context-strategy.md` for the full signal table
   f. Ask clarifying questions: layer mapping, special imports, testing preference, full vs partial setup

2. **Phase 1 — AGENTS.md** (~100 lines, orientation map)
   - `Read references/agents-md-template.md` for the template
   - Fill in from Phase 0 discovery — don't invent, reflect what exists
   - Point to docs/ for details, don't inline them

3. **Phase 2 — docs/ system of record**
   Required:
   - Create: `ARCHITECTURE.md` at repo root (top-level domain map, ~30 lines, points to LAYERS.md)
   - Create: `docs/architecture/LAYERS.md` (definitive layer hierarchy + remediation guide)
   - Create: `docs/golden-principles/` — `Read references/golden-principles-guide.md` for how to write these
   - Create: `docs/SECURITY.md` (auth flows, secrets management, threat model)
   Recommended:
   - Create: `docs/guides/` (setup, testing, deployment — only what's relevant)
   - Create: `docs/exec-plans/` — `Read references/exec-plan-template.md` for the standard (active/ + completed/ subdirs)
   - Create: `docs/design-docs/` with `index.md` (ADR index) and `core-beliefs.md` (non-negotiable decisions)
   - Create: `docs/references/` (external library docs reformatted for LLM consumption, e.g. `{library}-llms.txt`)
   - Create: `docs/DESIGN.md`, `docs/PLANS.md`, `docs/QUALITY_SCORE.md`
   Conditional (by project type):
   - `docs/RELIABILITY.md` — for services (SLA, error budgets, resilience patterns)
   - `docs/STACK.md` — stack-specific conventions (replaces OpenAI's FRONTEND.md)
   - `docs/product-specs/` — for product-driven projects
   - `docs/generated/` — auto-generated docs (db-schema.md, api-spec.md)

4. **Phase 3 — Architecture boundary test**
   - `Read references/stack-routing.md` for import parser and test file path per stack
   - Scan all source files, parse imports, validate against layer rules
   - Error format: `VIOLATION: {file}:{line} imports {target} — {layer} cannot import {target_layer}. See docs/architecture/LAYERS.md`
   - Ratchet: `KNOWN_VIOLATIONS` list, can only shrink
   - For existing repos: establish baseline first, then ratchet

5. **Phase 4 — Linter boundary enforcement**
   - `Read references/stack-routing.md` for linter rule name and config location per stack
   - Use linter's native import restriction rules
   - Every error message MUST include remediation — error output IS agent context

6. **Phase 5 — CI pipeline**
   - `Read references/ci-templates.md` for starter YAML templates
   - `Read references/stack-routing.md` for CI job matrix per stack
   - Adapt to stack — not every stack needs all 4 jobs (lint, typecheck, test, build)

7. **Phase 6 — Garbage collection**
   - `Read references/gc-patterns.md` for scan types and migration strategy
   - Prioritize entropy scans (doc drift, architecture violations) over style scans
   - Single `gc` command + scheduled GitHub Action (weekly cron)

8. **Phase 7 — Pre-commit hooks** (optional)
   - `Read references/stack-routing.md` for framework and config per stack
   - Phase 7 is optional — CI (Phase 5) is the authoritative gate
</Steps>

<Tool_Usage>
Delegate by intent — platform routes the call. `Read references/tool-routing.md` for platform-specific mappings.

- **Explore** (lightweight model) — directory mapping, file discovery in Phase 0
- **Architect** (heavyweight model) — architecture analysis, layer identification in Phase 0
- **Write** (lightweight model) — AGENTS.md + docs generation in Phases 1-2
- **Execute** (standard model) — boundary test, linter config, CI, GC scripts in Phases 3-7
- **Verify** (standard model) — final checklist validation
- Read `references/*.md` files on demand per phase — don't load all at once
</Tool_Usage>

<Examples>
<Good>
User: "harness-init this new Next.js project"
Agent: Runs Phase 0 discovery -> detects Next.js + TypeScript + ESLint -> identifies full-stack layer pattern -> asks "Full setup or specific phases?" -> proceeds through all phases.
Why good: Discovery first, confirms with user, adapts to actual stack.
</Good>

<Good>
User: "add architecture boundaries to this existing Python repo"
Agent: Runs Phase 0 -> discovers 200+ existing import violations -> establishes KNOWN_VIOLATIONS baseline -> sets lint rules to warn-only -> creates ratchet test -> asks user about convergence timeline.
Why good: Doesn't break existing build, uses ratchet for gradual convergence.
</Good>

<Good>
User: "harness-init 3-4"
Agent: Runs Phase 0 (always) -> detects Go + golangci-lint -> reads stack-routing.md -> creates boundary test with `go/parser` + depguard config -> skips Phases 1-2, 5-7.
Why good: Respects phase argument, still runs discovery, uses decision tables for tooling.
</Good>

<Good>
User: "harness-init this turborepo monorepo"
Agent: Runs Phase 0 -> detects packages/ structure -> reads layer-templates.md monorepo model -> maps cross-package dependencies -> creates per-package boundary tests + shared CI matrix.
Why good: Adapts to monorepo structure instead of forcing single-app patterns.
</Good>

<Bad>
User: "harness-init"
Agent: Immediately creates AGENTS.md with React/TypeScript template without reading the repo.
Why bad: Skipped Phase 0 discovery. Assumed stack instead of detecting it.
</Bad>

<Bad>
User: "make this agent-ready" (repo has 500 lint violations)
Agent: Adds strict lint rules that fail CI immediately on all 500 violations.
Why bad: Didn't establish baseline. Broke the build. Should warn-only first, then ratchet.
</Bad>
</Examples>

<Escalation_And_Stop_Conditions>
- **Stop and ask** if stack detection is ambiguous (multiple package managers, unclear framework)
- **Stop and ask** if no clear directory structure exists (flat repo with no src/ or lib/)
- **Stop and ask** if existing AGENTS.md or docs/ conflict with harness structure
- **Stop and report** if linter/test runner cannot be installed (permissions, incompatible versions)
- **Graceful degradation** if `gh` CLI, LSP, or session state unavailable — skip those dynamic context signals, note what was skipped
- **Never force** a layer structure that doesn't fit the actual codebase
</Escalation_And_Stop_Conditions>

<Final_Checklist>
- [ ] Phase 0 discovery completed (stack detected, layers identified, user confirmed)
- [ ] AGENTS.md exists at repo root (~100 lines, index not encyclopedia)
- [ ] docs/architecture/LAYERS.md exists with layer diagram + remediation guide
- [ ] At least 2-3 golden principles docs exist with DO/DON'T examples
- [ ] Architecture boundary test exists and passes (with KNOWN_VIOLATIONS if existing repo)
- [ ] Linter rules enforce import boundaries with remediation in error messages
- [ ] CI pipeline runs lint + test (at minimum)
- [ ] GC runner command exists (`npm run gc` / `make gc` / equivalent)
- [ ] All new files committed on feature branch
- [ ] Test suite, linter, and GC scripts verified to run successfully
</Final_Checklist>

<Advanced>
## Target File Structure

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
│   ├── RELIABILITY.md                 # SLA, error budgets (services)       [Conditional]
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

## Reference Files

Detailed templates and guides are in `references/` — read on demand per phase:
- `references/layer-templates.md` — 4 tech stack layer models
- `references/agents-md-template.md` — AGENTS.md template
- `references/context-strategy.md` — Static vs dynamic context tables
- `references/exec-plan-template.md` — ExecPlan (docs/exec-plans/) standard
- `references/golden-principles-guide.md` — How to write golden principles
- `references/gc-patterns.md` — GC scan types + migration strategy for existing repos
- `references/tool-routing.md` — Platform-specific tool delegation mappings
- `references/stack-routing.md` — Stack → tooling decision tables for Phases 3-7
- `references/ci-templates.md` — Starter CI YAML for GitHub Actions, GitLab, Makefile
</Advanced>
