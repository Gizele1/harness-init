# harness-init

> Agent orientation map. Read this first when entering this repo.

## What this is

A Claude Code plugin that scaffolds agent-ready repos using OpenAI's harness engineering methodology. It produces `AGENTS.md`, `docs/`, boundary tests, linter rules, CI pipelines, and GC scripts for target repos through 8 phases (Phase 0-7).

## Stack

| Layer     | Tech              |
|-----------|-------------------|
| Language  | Markdown + JSON   |
| Platform  | Claude Code Plugin|
| License   | MIT               |

## Directory structure

```
.
├── AGENTS.md                          # You are here
├── ARCHITECTURE.md                    # Layer definitions and file relationships
├── CLAUDE.md                          # Agent development instructions
├── INSTALL.md                         # Machine-readable install instructions
├── README.md                          # User-facing docs (English)
├── README_CN.md                       # User-facing docs (Chinese) — must mirror README.md
├── .claude-plugin/
│   ├── marketplace.json               # Marketplace registration (required for plugin install)
│   └── plugin.json                    # Plugin metadata (name, version, skills path)
├── docs/
│   ├── architecture/
│   │   └── LAYERS.md                  # Layer rules, dependency constraints
│   ├── golden-principles/
│   │   ├── SKILL_AUTHORING.md         # Skill file DO/DON'T patterns
│   │   ├── DOCUMENTATION.md           # Doc consistency patterns
│   │   └── REFERENCES.md              # Reference template patterns
│   └── SECURITY.md                    # Secrets, exclusion rules
├── skills/
│   └── harness-init/
│       ├── SKILL.md                   # The skill itself — 8-phase execution logic
│       └── references/                # Templates loaded on-demand by SKILL.md
│           ├── agents-md-template.md
│           ├── boundary-test-template.md
│           ├── ci-templates.md
│           ├── context-strategy.md
│           ├── exec-plan-template.md
│           ├── gc-patterns.md
│           ├── golden-principles-guide.md
│           ├── layer-templates.md
│           ├── security-template.md
│           ├── stack-routing.md
│           └── tool-routing.md
├── scripts/
│   ├── check-docs.sh                 # Doc consistency checker (CI + local)
│   └── gc/
│       └── check-consistency.sh       # GC consistency checker (CI + local)
└── .github/workflows/
    ├── ci.yml                         # Plugin validation + doc consistency
    └── gc.yml                         # Weekly entropy scan
```

## Key constraints

1. **README_CN.md must mirror README.md** — same sections, same order, same data. Update both or neither.
2. **Reference files are loaded on-demand** — SKILL.md contains `Read references/*.md` directives. Every reference file must exist, and every `Read` directive must point to a real file.
3. **Version must be consistent** — `plugin.json`, `marketplace.json`, and `SKILL.md` frontmatter all declare version. Keep them in sync.
4. **SKILL.md is the source of truth** — README describes what the skill does; SKILL.md defines how it works. If they conflict, fix README.
5. **References must be independent** — no cross-references between reference files (exceptions: `stack-routing.md`, `ci-templates.md`).

## How to modify

- **Changing skill behavior**: Edit `skills/harness-init/SKILL.md`
- **Changing templates**: Edit the relevant `skills/harness-init/references/*.md`
- **Adding a reference file**: Add file, then add a `Read references/new-file.md` directive in SKILL.md
- **Updating version**: Change in `plugin.json`, `marketplace.json`, and `SKILL.md` frontmatter

## How to test

```bash
claude plugin validate .              # Validate plugin structure
bash scripts/check-docs.sh            # Check doc consistency
bash scripts/gc/check-consistency.sh  # Run GC consistency checks
```

## Where to Look First

| Task                        | Start here                              |
|-----------------------------|-----------------------------------------|
| Understand the project      | README.md or README_CN.md               |
| Architecture overview       | ARCHITECTURE.md (root)                  |
| Layer rules                 | docs/architecture/LAYERS.md             |
| Modify the skill            | skills/harness-init/SKILL.md            |
| Add/edit a reference        | skills/harness-init/references/         |
| Plugin config               | .claude-plugin/plugin.json              |
| Install instructions        | INSTALL.md                              |
| DO/DON'T patterns           | docs/golden-principles/                 |

## See also

- [ARCHITECTURE.md](ARCHITECTURE.md) — layer definitions
- [CLAUDE.md](CLAUDE.md) — development instructions
- [INSTALL.md](INSTALL.md) — installation methods
