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
      - uses: {setup-action}          # actions/setup-node, actions/setup-python, etc.
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

## GitLab CI (.gitlab-ci.yml)

~~~yaml
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
            await github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `GC scan found issues — ${new Date().toISOString().slice(0, 10)}`,
              labels: ['garbage-collection'],
              body: 'Weekly GC scan detected entropy. Run the GC command from your Makefile or package.json locally for details.'
            });
~~~

**Notes:** GC workflow is report-only — never auto-fixes. The `workflow_dispatch` trigger allows manual runs. Create the `garbage-collection` label in your repo.
