# Stack Routing — Decision Tables for Phases 3-7

Use these tables to select the right tooling for the detected stack. Phase 0 discovery determines the stack; these tables determine execution.

## Phase 3: Boundary Test — Import Parser & Pattern

| Stack | Import Pattern | Parser Approach | Test File |
|-------|---------------|-----------------|-----------|
| JS/TS | `import ... from '...'` | Regex or AST (ts-morph, babel) | `tests/architecture/boundary.test.ts` |
| Python | `import ...` / `from ... import` | AST (stdlib `ast` module) | `tests/architecture/test_boundary.py` |
| Go | `import "..."` | `go/parser` stdlib or regex | `tests/architecture/boundary_test.go` |
| Rust | `use ...` / `mod ...` | Regex or `syn` crate (heavier) | `tests/architecture/boundary_test.rs` |
| Java/Kotlin | `import ...` | Regex or ArchUnit | `tests/architecture/BoundaryTest.java` |

**Error format (all stacks):**
`VIOLATION: {file}:{line} imports {target} — {layer} cannot import {target_layer}. See docs/architecture/LAYERS.md`

## Phase 4: Linter Import Restriction Rules

| Stack | Linter | Rule | Config Location |
|-------|--------|------|-----------------|
| JS/TS (ESLint) | eslint | `no-restricted-imports` / `import/no-restricted-paths` | `.eslintrc` or `eslint.config.js` |
| Python (Ruff) | ruff | `banned-api` (flake8-tidy-imports) | `pyproject.toml [tool.ruff]` |
| Python (Flake8) | flake8 | `flake8-import-restrictions` | `.flake8` or `setup.cfg` |
| Go | golangci-lint | `depguard` | `.golangci.yml` |
| Rust | clippy | `pub(crate)` visibility + workspace deps | `Cargo.toml` + module structure |
| Java | ArchUnit | `ArchRuleDefinition.noClasses()` | Test file (ArchUnit is test-based) |

**Key rule:** Every linter error MUST include remediation text. Error output IS agent context.

## Phase 5: CI Job Matrix

| Stack | Lint | Typecheck | Test | Build |
|-------|------|-----------|------|-------|
| JS/TS | `eslint .` | `tsc --noEmit` | `jest` / `vitest` | `next build` / `tsc` |
| Python | `ruff check .` | `mypy .` (if typed) | `pytest` | `python -m build` (if packaged) |
| Go | `golangci-lint run` | (included in build) | `go test ./...` | `go build ./...` |
| Rust | `cargo clippy` | (included in build) | `cargo test` | `cargo build --release` |
| Java/Kotlin | `checkstyle` / `ktlint` | (compiled language) | `./gradlew test` | `./gradlew build` |

**Not every stack needs all 4 jobs.** Go and Rust combine typecheck with build. Python may skip build if not a published package. Read `references/ci-templates.md` for starter YAML.

## Phase 6: Garbage Collection Tooling

| Stack | Import Scanner | Doc Drift Check | GC Runner | Config |
|-------|---------------|-----------------|-----------|--------|
| JS/TS | `ts-morph` or regex on `import` statements | Compare `docs/` mtime vs `src/` via `git log` | `npm run gc` or `npx tsx scripts/gc/run.ts` | `package.json` scripts |
| Python | stdlib `ast` module | Compare `docs/` mtime vs `src/` via `git log` | `python scripts/gc/run_all.py` or `make gc` | `pyproject.toml` or Makefile |
| Go | `go/parser` stdlib | Compare `docs/` mtime vs source via `git log` | `go run scripts/gc/main.go` or `make gc` | Makefile |
| Rust | regex on `use`/`mod` statements | Compare `docs/` mtime vs `src/` via `git log` | `cargo run --bin gc` or `make gc` | `Cargo.toml` [[bin]] or Makefile |
| Java/Kotlin | regex on `import` statements | Compare `docs/` mtime vs `src/` via `git log` | `./gradlew gc` or `make gc` | `build.gradle` custom task or Makefile |

**Minimum viable GC:** architecture violation scan + doc-code drift check. Additional scans (file size, TODO count, unused imports) are optional enhancements.

## Phase 7: Pre-commit Framework

| Stack | Framework | Config File | Key Hooks |
|-------|-----------|-------------|-----------|
| JS/TS | husky + lint-staged | `.husky/`, `package.json` | `lint-staged: { "*.ts": ["eslint --fix", "prettier --write"] }` |
| Python | pre-commit | `.pre-commit-config.yaml` | `ruff`, `mypy`, `black` |
| Go | golangci-lint (no framework needed) | `.golangci.yml` | Run as `pre-commit` git hook or Makefile target |
| Rust | cargo-husky or custom | `.cargo-husky/` | `cargo fmt --check`, `cargo clippy` |
| Java/Kotlin | Gradle spotless or pre-commit | `build.gradle` | `spotlessApply`, `ktlintFormat` |

**Phase 7 is optional.** Only add if the team wants local enforcement. CI (Phase 5) is the authoritative gate.
