# ExecPlan Standard (.agent/PLANS.md)

Source: OpenAI Cookbook — "Using PLANS.md for multi-hour problem solving"

For complex features or significant refactors. Not needed for small changes.

## Core Requirements

- **Fully self-contained** — newcomer can implement without prior knowledge
- **Living document** — updated with progress, surprises, decisions
- **Restartable** — can resume from only the ExecPlan, no other state

## Required Sections

```markdown
# <Short action-oriented description>

This ExecPlan is a living document.

## Purpose / Big Picture
What the user gets, how to see it working.

## Progress
- [x] (YYYY-MM-DD HH:MMZ) Completed step
- [ ] Pending step

## Surprises & Discoveries
- Observation: ...
  Evidence: ...

## Decision Log
- Decision: ...
  Rationale: ...
  Date/Author: ...

## Outcomes & Retrospective
Summary of results, gaps, and lessons learned.

## Context and Orientation
Current state, assume reader knows nothing.

## Plan of Work
Edit and addition sequence, name specific files.

## Concrete Steps
Exact commands with working directory, include expected output.

## Validation and Acceptance
How to start/use the system. Observable behavior, not internal properties.

## Idempotence and Recovery
Are steps repeatable? Rollback path.

## Artifacts and Notes
Key output examples, keep concise.

## Interfaces and Dependencies
Libraries, modules, function signatures to use.
```

## When to Use

- Complex features requiring multiple files/modules
- Significant refactors touching architecture
- Multi-hour implementation tasks

## When NOT to Use

- Bug fixes
- Small feature additions
- Configuration changes
