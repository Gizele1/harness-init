# Garbage Collection Patterns

Entropy management — recurring scans that catch drift, not just style violations.

## Safety Rules

- GC scripts MUST be **read-only**: scan and report, never auto-fix or delete
- Any auto-fix capability MUST require an explicit `--fix` flag and user confirmation
- Scheduled CI runs (cron) MUST be report-only (exit code + issue creation)
- GC scripts MUST NOT modify source files, delete files, or alter git history
- GC workflow permissions: `contents: read`, `issues: write` — nothing more

## Two Categories

### Style Scans (basic, noisy)
- Raw console/print statements (should use logger)
- Default exports (JS/TS — should use named)
- Large files (>300 lines warn, >500 error)
- TODO/FIXME/HACK comments
- Missing type annotations
- Unused imports

### Entropy Scans (high-value, what OpenAI actually cares about)
- **Doc-code drift:** Do docs/ descriptions match current code behavior?
- **Architecture violations:** New imports that violate LAYERS.md?
- **Pattern deviation:** Code that doesn't match golden-principles/?
- **Dependency audit:** Circular or unnecessary dependencies?
- **Knowledge freshness:** Are docs older than N days while src/ changed?
- **Quality ratchet:** Has KNOWN_VIOLATIONS grown?

**Prioritize entropy scans over style scans.** Style is linter territory.

## GC Runner

Single command runs all checks:
```bash
npm run gc        # or
python scripts/gc_run_all.py  # or
make gc
```

Each script: scan → find violation → report file:line → exit 0/1.

## Scheduled Execution

GitHub Actions cron `0 9 * * 1` (Monday 9am UTC).
Results posted as GitHub issue with label `garbage-collection`.

## Migration Strategy for Existing Repos

1. **Establish baseline:** Run all scans, record current count
2. **Warn-only phase:** New violations warn, don't fail CI
3. **Ratchet phase:** Lock baseline count, fail on increase
4. **Convergence:** Gradually reduce baseline via targeted cleanup PRs
