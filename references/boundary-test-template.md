# Boundary Test Template

Reference for Phase 3. Provides the KNOWN_VIOLATIONS format, ratchet logic, and test skeletons.

## KNOWN_VIOLATIONS Format

File: `tests/architecture/known-violations.json`

```json
[
  {
    "file": "src/components/UserCard.tsx",
    "line": 5,
    "imports": "src/services/userService",
    "from_layer": "components",
    "to_layer": "services",
    "reason": "Legacy coupling — tracked for removal in Q2"
  }
]
```

**Rules:**
- One entry per violation. Each entry uniquely identified by `file` + `imports`.
- Entries can only be **removed** (fixed), never **added** after baseline is set.
- The ratchet test fails if a new violation appears that is not in the list.
- When a violation is fixed, delete its entry. The count must only shrink.

## Layer Definition

Define allowed imports per layer in the test file or a config file:

```json
{
  "types": [],
  "lib": ["types"],
  "services": ["lib", "types"],
  "components": ["lib", "types"],
  "pages": ["components", "services", "lib", "types"]
}
```

Each key is a layer. Its value lists which layers it may import from. Any import outside this set is a violation.

## Test Skeleton: TypeScript (Jest/Vitest)

```typescript
import { readdirSync, readFileSync } from 'fs';
import { join, relative } from 'path';
import knownViolations from './known-violations.json';

const LAYER_RULES: Record<string, string[]> = {
  types: [],
  lib: ['types'],
  services: ['lib', 'types'],
  components: ['lib', 'types'],
  pages: ['components', 'services', 'lib', 'types'],
};

// Matches `from '...'` on any line — handles single-line and multi-line imports,
// plus re-exports (`export { x } from '...'`).
// NOTE: This is a simplified scanner. For full accuracy (dynamic imports, require()),
// use ts-morph or @babel/parser AST parsing (see references/stack-routing.md).
const FROM_RE = /\bfrom\s+['"]([^'"]+)['"]/;

function getLayer(filePath: string): string | null {
  // Adapt 'src' to your project's source root
  const match = filePath.match(/^src\/([^/]+)\//);
  if (match && match[1] in LAYER_RULES) return match[1];
  return null;
}

function resolveTargetLayer(importPath: string): string | null {
  // Strip common path aliases (@/, ~/, #/)
  const normalized = importPath.replace(/^[@~#]\//, '');
  const segments = normalized.split('/');
  for (const layer of Object.keys(LAYER_RULES)) {
    if (segments.includes(layer)) return layer;
  }
  return null;
}

function scanFile(filePath: string): Array<{ file: string; line: number; imports: string; from_layer: string; to_layer: string }> {
  const violations: Array<{ file: string; line: number; imports: string; from_layer: string; to_layer: string }> = [];
  const content = readFileSync(filePath, 'utf-8');
  const lines = content.split('\n');
  const fromLayer = getLayer(relative(process.cwd(), filePath));
  if (!fromLayer) return violations;

  let inTypeImport = false;
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    // Track type-only imports (erased at compile time, not runtime dependencies)
    if (/^\s*import\s+type\s/.test(line)) inTypeImport = true;

    const match = line.match(FROM_RE);
    if (match && !inTypeImport) {
      const targetLayer = resolveTargetLayer(match[1]);
      if (targetLayer && !LAYER_RULES[fromLayer].includes(targetLayer) && targetLayer !== fromLayer) {
        violations.push({
          file: relative(process.cwd(), filePath),
          line: i + 1,
          imports: match[1],
          from_layer: fromLayer,
          to_layer: targetLayer,
        });
      }
    }

    // Reset type-import tracking when the from-clause ends the statement
    if (inTypeImport && FROM_RE.test(line)) inTypeImport = false;
  }
  return violations;
}

// Collect all source files recursively
function collectFiles(dir: string, ext: string[]): string[] {
  const results: string[] = [];
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const fullPath = join(dir, entry.name);
    if (entry.isDirectory()) {
      results.push(...collectFiles(fullPath, ext));
    } else if (ext.some(e => entry.name.endsWith(e))) {
      results.push(fullPath);
    }
  }
  return results;
}

describe('Architecture Boundary Test', () => {
  // Adapt 'src' to your project's source root
  const files = collectFiles('src', ['.ts', '.tsx']);
  const allViolations = files.flatMap(scanFile);

  test('no new architecture violations', () => {
    const knownSet = new Set(knownViolations.map(v => `${v.file}:${v.imports}`));
    const newViolations = allViolations.filter(v => !knownSet.has(`${v.file}:${v.imports}`));

    if (newViolations.length > 0) {
      const msg = newViolations
        .map(v => `VIOLATION: ${v.file}:${v.line} imports ${v.imports} — ${v.from_layer} cannot import ${v.to_layer}. See docs/architecture/LAYERS.md`)
        .join('\n');
      throw new Error(`New architecture violations found:\n${msg}`);
    }
  });

  test('violation count only shrinks (ratchet)', () => {
    expect(allViolations.length).toBeLessThanOrEqual(knownViolations.length);
  });
});
```

## Test Skeleton: Python (pytest)

```python
import ast
import json
from pathlib import Path

LAYER_RULES = {
    "models": [],
    "config": ["models"],
    "db": ["config", "models"],
    "services": ["db", "config", "models"],
    "middleware": ["services", "config", "models"],
    "routes": ["services", "middleware", "models"],
}

KNOWN_VIOLATIONS_PATH = Path("tests/architecture/known-violations.json")


def get_layer(file_path: Path) -> str | None:
    # Adapt 'src' to your project's source root (e.g., package name, 'app/')
    parts = file_path.parts
    if len(parts) >= 2 and parts[0] == "src" and parts[1] in LAYER_RULES:
        return parts[1]
    return None


def scan_imports(file_path: Path) -> list[dict]:
    violations = []
    source = file_path.read_text()
    try:
        tree = ast.parse(source)
    except SyntaxError:
        return violations  # Skip unparseable files
    from_layer = get_layer(file_path)
    if not from_layer:
        return violations

    def _check_target(target: str, node: ast.AST) -> None:
        for layer in LAYER_RULES:
            if layer in target.split("."):
                if layer != from_layer and layer not in LAYER_RULES[from_layer]:
                    violations.append({
                        "file": str(file_path),
                        "line": node.lineno,
                        "imports": target,
                        "from_layer": from_layer,
                        "to_layer": layer,
                    })
                break  # Only match the first (shallowest) layer

    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            for alias in node.names:
                _check_target(alias.name, node)
        elif isinstance(node, ast.ImportFrom) and node.module:
            _check_target(node.module, node)

    return violations


def test_no_new_violations():
    known = json.loads(KNOWN_VIOLATIONS_PATH.read_text()) if KNOWN_VIOLATIONS_PATH.exists() else []
    known_set = {(v["file"], v["imports"]) for v in known}

    # Adapt 'src' to your project's source root (e.g., package name, 'app/')
    all_violations = []
    for py_file in Path("src").rglob("*.py"):
        all_violations.extend(scan_imports(py_file))

    new_violations = [v for v in all_violations if (v["file"], v["imports"]) not in known_set]
    assert not new_violations, "\n".join(
        f"VIOLATION: {v['file']}:{v['line']} imports {v['imports']} — "
        f"{v['from_layer']} cannot import {v['to_layer']}. See docs/architecture/LAYERS.md"
        for v in new_violations
    )


def test_ratchet_only_shrinks():
    known = json.loads(KNOWN_VIOLATIONS_PATH.read_text()) if KNOWN_VIOLATIONS_PATH.exists() else []

    # Adapt 'src' to your project's source root (e.g., package name, 'app/')
    all_violations = []
    for py_file in Path("src").rglob("*.py"):
        all_violations.extend(scan_imports(py_file))

    assert len(all_violations) <= len(known), (
        f"Violation count increased: {len(all_violations)} > baseline {len(known)}. "
        "Fix violations to reduce the count — never add new ones."
    )
```

## Establishing Baseline for Existing Repos

1. Run the boundary test without `known-violations.json` — it will report all current violations
2. Capture output into `known-violations.json` as the initial baseline
3. Commit the baseline — this is the ratchet starting point
4. From now on, the count can only decrease
