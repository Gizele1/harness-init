# ExecPlan Standard (docs/exec-plans/)

Two complementary sources:
- **OpenAI Harness article** — `docs/exec-plans/` directory with lifecycle (active → completed)
- **OpenAI Cookbook PLANS.md** — single-file ExecPlan format (self-contained living document)

For complex features or significant refactors. Not needed for small changes.

## Directory Structure (from Harness article)

```
docs/exec-plans/
├── active/                # In-progress plans
│   └── {feature-name}.md  # One plan per feature/refactor
├── completed/             # Finished plans with retrospectives
│   └── {feature-name}.md  # Preserved for downstream agent context
└── tech-debt-tracker.md   # Known debt, prioritized (optional)
```

Active plans move to `completed/` when done. Downstream agents can reason about prior decisions without human context.

## Single-File Alternative

For simpler projects, a single `PLANS.md` at repo root or `.agent/PLANS.md` works. The directory structure is preferred for repos with multiple concurrent features.

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
