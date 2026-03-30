# CI Templates

Starter templates for Phase 5. Adapt commands from `references/stack-routing.md` Phase 5 table.

## GitHub Actions (.github/workflows/ci.yml)

~~~yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: {setup-action}          # actions/setup-node, actions/setup-python, etc.
      - run: {install_command}
      - run: {lint_command}

  typecheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: {setup-action}
      - run: {install_command}
      - run: {typecheck_command}

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: {setup-action}
      - run: {install_command}
      - run: {test_command}

  build:
    runs-on: ubuntu-latest
    needs: [lint, typecheck, test]
    steps:
      - uses: actions/checkout@v4
      - uses: {setup-action}
      - run: {install_command}
      - run: {build_command}
~~~

**Notes:** Remove `typecheck` job if the stack doesn't have a separate typecheck step (Go, Rust). Remove `build` job if not a packaged/deployed artifact.

## GitLab CI (.gitlab-ci.yml)

~~~yaml
stages: [lint, test, build]

lint:
  stage: lint
  script:
    - {install_command}
    - {lint_command}

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
  only: [main]
~~~

**Note:** Add a `typecheck` stage if applicable (e.g., `mypy` for Python, `tsc --noEmit` for TypeScript).

## Makefile Fallback (no CI platform)

If the repo doesn't use GitHub/GitLab, provide a Makefile so `make ci` runs all checks locally:

~~~makefile
.PHONY: lint typecheck test build ci

lint:
	{lint_command}

typecheck:
	{typecheck_command}

test:
	{test_command}

build:
	{build_command}

ci: lint typecheck test build
~~~
