# AGENTS.md Template

~100 lines. Index, not encyclopedia. They killed the 800-line version because agents couldn't find what they needed.

~~~markdown
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

{Layer diagram discovered from actual import patterns}

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
ARCHITECTURE.md                       Top-level domain map (root)
docs/
├── architecture/                     Layer rules, dependency graph
├── golden-principles/                Canonical patterns (DO/DON'T examples)
├── SECURITY.md                       Auth, secrets, threat model
├── guides/                           Setup, testing, deployment how-tos
├── exec-plans/                       Feature implementation plans
├── design-docs/                      Architecture decision records
└── references/                       External library docs (LLM-friendly)
```

## Where to Look First

| Task              | Start here                    |
|-------------------|-------------------------------|
| Architecture overview | ARCHITECTURE.md (root)    |
| Layer rules       | docs/architecture/LAYERS.md   |
| {common task 1}   | {directory/file}              |
| {common task 2}   | {directory/file}              |
| {common task 3}   | {directory/file}              |

## Constraints (Machine-Readable)

- MUST: {hard rule with pointer to enforcement}
- MUST NOT: {prohibition with pointer to LAYERS.md}
- PREFER: {soft preference}
- VERIFY: {verification command before PR}
~~~
