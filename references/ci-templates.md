# CI Templates

Starter templates for Phase 5. Adapt commands from `references/stack-routing.md` Phase 5 table.

## Command Validation

Before substituting discovered commands into CI YAML `run:` fields (and any embedded script strings), validate them:
- **Allow:** known build/test/lint tools (`npm`, `npx`, `eslint`, `prettier`, `jest`, `vitest`, `tsc`, `ruff`, `pytest`, `mypy`, `go`, `golangci-lint`, `cargo`, `clippy`, `gradle`)
- **Allow chaining:** `&&` between known-safe commands is fine (e.g., `cd subdir && npm test`)
- **Reject:** `|` (pipe), `;`, `$()`, `` ` ``, `>>`, `curl`, `wget`, `eval`, `exec` — these indicate potential injection
- **Stop and ask** if a discovered command looks suspicious or doesn't match expected patterns

## GitHub Actions (.github/workflows/ci.yml)

~~~yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
      - uses: {setup-action}          # SHA-pin like checkout — see Action Pinning below
      - run: {install_command}
      - run: {lint_command}

  typecheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
      - uses: {setup-action}
      - run: {install_command}
      - run: {typecheck_command}

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
      - uses: {setup-action}
      - run: {install_command}
      - run: {test_command}

  build:
    runs-on: ubuntu-latest
    needs: [lint, typecheck, test]
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
      - uses: {setup-action}
      - run: {install_command}
      - run: {build_command}
~~~

**Notes:** Remove `typecheck` job if the stack doesn't have a separate typecheck step (Go, Rust). Remove `build` job if not a packaged/deployed artifact.

### Action Pinning

All `uses:` references MUST be SHA-pinned with a tag comment for auditability. Never use bare tag references (`@v4`) — tags are mutable and vulnerable to supply-chain attacks.

Common setup actions (pin to latest at time of use):
- `actions/setup-node@49933ea5288caeca8642d1e84afbd3f7d6820020 # v4.4.0`
- `actions/setup-python@a26af69be951a213d495a4c3e4e4022e16d87065 # v5.6.0`
- `actions/setup-go@d35c59abb061a4a6fb18e82ac0862c26744d6ab5 # v5.5.0`
- `actions/setup-java@c5195efecf7bdfc987ee8bae7a71cb8b11521c00 # v4.7.1`

## GitLab CI (.gitlab-ci.yml)

~~~yaml
default:
  image: {runtime-image}  # e.g., node:20, python:3.12, golang:1.22

stages: [lint, typecheck, test, build]

lint:
  stage: lint
  script:
    - {install_command}
    - {lint_command}

typecheck:
  stage: typecheck
  script:
    - {install_command}
    - {typecheck_command}

test:
  stage: test
  script:
    - {install_command}
    - {test_command}

build:
  stage: build
  script:
    - {install_command}
    - {build_command}
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
~~~

**Notes:** Remove `typecheck` stage if the stack doesn't have a separate typecheck step (Go, Rust).

## Makefile Fallback (no CI platform)

If the repo doesn't use GitHub/GitLab, provide a Makefile so `make ci` runs all checks locally:

~~~makefile
.PHONY: lint typecheck test build gc ci

lint:
	{lint_command}

typecheck:
	{typecheck_command}

test:
	{test_command}

build:
	{build_command}

gc:
	{gc_command}

ci: lint typecheck test build
~~~

## GC Workflow (.github/workflows/gc.yml)

~~~yaml
name: Garbage Collection
on:
  schedule:
    - cron: '0 9 * * 1'  # Monday 9am UTC
  workflow_dispatch:       # Allow manual trigger

permissions:
  contents: read
  issues: write

jobs:
  gc:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
      - uses: {setup-action}
      - run: {install_command}
      - run: {gc_command}
      - name: Create issue on failure
        if: failure()
        uses: actions/github-script@60a0d83039c74a4aee543508d2ffcb1c3799cdea # v7.0.1
        with:
          script: |
            const title = `GC scan found issues — ${new Date().toISOString().slice(0, 10)}`;
            const { data: existing } = await github.rest.issues.listForRepo({
              owner: context.repo.owner,
              repo: context.repo.repo,
              labels: 'garbage-collection',
              state: 'open',
            });
            if (existing.some(i => i.title === title)) {
              return; // Already reported today
            }
            await github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title,
              labels: ['garbage-collection'],
              body: 'Weekly GC scan detected entropy. Run the GC command from your Makefile or package.json locally for details.'
            });
~~~

**Notes:** GC workflow is report-only — never auto-fixes. The `workflow_dispatch` trigger allows manual runs. Create the `garbage-collection` label in your repo.
