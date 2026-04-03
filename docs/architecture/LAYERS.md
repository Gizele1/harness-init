# Architecture Layers

## Layer Hierarchy

```
┌─────────────────────────────────────────────┐
│  Root Docs                                  │  README.md, README_CN.md, INSTALL.md
│  May reference: Skill, References, Config   │
├─────────────────────────────────────────────┤
│  Commands                                   │  .claude/commands/harness-init.md
│  May reference: Skill                       │
├─────────────────────────────────────────────┤
│  Skill                                      │  skills/harness-init/SKILL.md
│  May reference: References                  │
├─────────────────────────────────────────────┤
│  References                                 │  skills/harness-init/references/*.md
│  May reference: nothing (standalone)        │
├─────────────────────────────────────────────┤
│  Plugin Config                              │  .claude-plugin/plugin.json, marketplace.json
│  May reference: nothing (standalone)        │
└─────────────────────────────────────────────┘
```

Dependency flows **downward only**.

## Layer Rules

| Layer         | Path                                  | Allowed Dependencies          |
|---------------|---------------------------------------|-------------------------------|
| Root Docs     | `*.md` (root)                         | Skill, References, Config     |
| Commands      | `.claude/commands/`                   | Skill                         |
| Skill         | `skills/harness-init/SKILL.md`        | References only               |
| References    | `skills/harness-init/references/`     | None — standalone templates   |
| Plugin Config | `.claude-plugin/`                     | None — standalone metadata    |

## What Counts as a Dependency

In this documentation-only project, "dependency" means:

- **File reference**: `Read references/foo.md` in SKILL.md → Skill depends on References
- **Content sync**: README describes SKILL.md phases → Root Docs depends on Skill
- **Path reference**: plugin.json `"skills": "./skills/"` → Config references Skill directory

## Violations

A violation occurs when:

1. SKILL.md references a file in `references/` that does not exist
2. A reference file references another reference file (cross-dependency)
3. README/README_CN describes a phase or feature not present in SKILL.md
4. plugin.json `skills` path does not resolve to a valid directory

## Remediation

| Violation | Fix |
|-----------|-----|
| SKILL.md references missing file | Create the referenced file in `references/`, or remove the reference |
| Reference cross-dependency | Inline the shared content, or extract to a new reference both can use independently |
| README drift from SKILL.md | Update README to match current SKILL.md phases |
| Invalid plugin.json path | Fix the `skills` field to point to `./skills/` |

## Enforcement

- **Automated**: `scripts/gc/check-consistency.sh` validates all rules above
- **CI**: `.github/workflows/ci.yml` runs consistency checks on every push/PR
- **GC**: `.github/workflows/gc.yml` runs weekly entropy scan
