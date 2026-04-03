# Security

## Scope

harness-init is a documentation-only Claude Code plugin. It contains no application code, no authentication flows, no secrets, and no network access.

## What This Plugin Does NOT Do

- Does not execute arbitrary code
- Does not access external APIs or services
- Does not store or transmit credentials
- Does not require elevated permissions

## What It Generates

When users run harness-init on their projects, it generates:

- Documentation files (Markdown)
- CI configuration (YAML)
- Test files and lint configuration
- Shell scripts (GC checks)

**All generated content is human-readable and auditable before commit.**

## Supply Chain

- **No runtime dependencies** — pure Markdown + JSON, no `package.json` or installed packages
- **CI actions are SHA-pinned** — generated CI templates use commit SHA references, not mutable tags
- **Plugin distribution** — via Git clone or Claude Code marketplace; users can inspect all files before installing

## Contributor Guidelines

- Never commit actual secrets, API keys, or tokens to this repo
- Generated templates must use placeholder descriptions, not real credential names
- `docs/SECURITY.md` template (in `references/security-template.md`) has exclusion rules — follow them
- Review all changes to `.claude-plugin/` carefully — this controls plugin metadata
