# Reference Templates

## Rule
Each reference file is a standalone template — self-contained, no cross-references, read on demand.

## DO

```markdown
<!-- Good: Reference contains everything needed for its phase -->
# Boundary Test Template

## KNOWN_VIOLATIONS Format
[complete format spec]

## Test Skeleton: TypeScript
[complete test code]

## Test Skeleton: Python
[complete test code]
```

## DON'T

```markdown
<!-- Bad: Reference requires reading another reference first -->
# Boundary Test Template

For import parser details, see references/stack-routing.md
For CI integration, see references/ci-templates.md
```

## DO

```markdown
<!-- Good: Reference is phase-scoped -->
# CI Templates                    → Phase 5 only
# GC Patterns                     → Phase 6 only
# Boundary Test Template          → Phase 3 only
```

## DON'T

```markdown
<!-- Bad: One giant reference covering multiple phases -->
# Everything You Need
[500 lines covering phases 3, 4, 5, 6, and 7]
```

## Exceptions
- `stack-routing.md` is intentionally cross-phase (provides per-stack decisions for Phases 3-7) — this is the routing table, not content duplication
