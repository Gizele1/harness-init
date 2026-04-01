#!/usr/bin/env bash
# Doc consistency checker for harness-init
# Run: bash scripts/check-docs.sh
# Exit code: 0 = pass, 1 = failures found

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ERRORS=0

error() {
  echo "FAIL: $1"
  ERRORS=$((ERRORS + 1))
}

pass() {
  echo "OK:   $1"
}

echo "=== harness-init doc consistency check ==="
echo ""

# 1. Check required files exist
echo "--- Required files ---"
for f in AGENTS.md ARCHITECTURE.md CLAUDE.md INSTALL.md README.md README_CN.md \
         .claude-plugin/plugin.json .claude-plugin/marketplace.json \
         skills/harness-init/SKILL.md; do
  if [ -f "$REPO_ROOT/$f" ]; then
    pass "$f exists"
  else
    error "$f is missing"
  fi
done
echo ""

# 2. Check all reference files referenced by SKILL.md exist
echo "--- Reference file integrity ---"
SKILL="$REPO_ROOT/skills/harness-init/SKILL.md"
REF_DIR="$REPO_ROOT/skills/harness-init/references"

if [ -f "$SKILL" ]; then
  # Extract Read references/*.md directives from SKILL.md
  REFERENCED=$(grep -oP 'Read references/\K[a-z0-9-]+\.md' "$SKILL" | sort -u)
  for ref in $REFERENCED; do
    if [ -f "$REF_DIR/$ref" ]; then
      pass "references/$ref exists (referenced by SKILL.md)"
    else
      error "references/$ref referenced in SKILL.md but file is missing"
    fi
  done

  # Check for orphan reference files not referenced by SKILL.md
  for ref_file in "$REF_DIR"/*.md; do
    ref_name=$(basename "$ref_file")
    if ! echo "$REFERENCED" | grep -qx "$ref_name"; then
      echo "WARN: references/$ref_name exists but is not referenced in SKILL.md"
    fi
  done
fi
echo ""

# 3. Version consistency
echo "--- Version consistency ---"
PLUGIN_VER=$(python3 -c "import json; print(json.load(open('$REPO_ROOT/.claude-plugin/plugin.json'))['version'])" 2>/dev/null || echo "PARSE_ERROR")
MARKET_VER=$(python3 -c "import json; print(json.load(open('$REPO_ROOT/.claude-plugin/marketplace.json'))['plugins'][0]['version'])" 2>/dev/null || echo "PARSE_ERROR")
SKILL_VER=$(grep -oP 'version:\s*"?\K[0-9]+\.[0-9]+\.[0-9]+' "$SKILL" 2>/dev/null | head -1 || echo "PARSE_ERROR")

if [ "$PLUGIN_VER" = "$MARKET_VER" ] && [ "$PLUGIN_VER" = "$SKILL_VER" ]; then
  pass "Version consistent across plugin.json, marketplace.json, SKILL.md ($PLUGIN_VER)"
else
  error "Version mismatch: plugin.json=$PLUGIN_VER marketplace.json=$MARKET_VER SKILL.md=$SKILL_VER"
fi
echo ""

# 4. JSON validity
echo "--- JSON validity ---"
for jf in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
  if python3 -c "import json; json.load(open('$REPO_ROOT/$jf'))" 2>/dev/null; then
    pass "$jf is valid JSON"
  else
    error "$jf is invalid JSON"
  fi
done
echo ""

# 5. README section parity (EN vs CN)
echo "--- README section parity ---"
EN_SECTIONS=$(grep -c '^## ' "$REPO_ROOT/README.md" 2>/dev/null || echo 0)
CN_SECTIONS=$(grep -c '^## ' "$REPO_ROOT/README_CN.md" 2>/dev/null || echo 0)

if [ "$EN_SECTIONS" = "$CN_SECTIONS" ]; then
  pass "README.md and README_CN.md have same number of ## sections ($EN_SECTIONS)"
else
  error "Section count mismatch: README.md has $EN_SECTIONS, README_CN.md has $CN_SECTIONS"
fi

# Check phase table row count
EN_PHASES=$(grep -c '| [0-7]\.' "$REPO_ROOT/README.md" 2>/dev/null || echo 0)
CN_PHASES=$(grep -c '| [0-7]\.' "$REPO_ROOT/README_CN.md" 2>/dev/null || echo 0)

if [ "$EN_PHASES" = "$CN_PHASES" ] && [ "$EN_PHASES" -ge 8 ]; then
  pass "Phase table rows match ($EN_PHASES phases in both READMEs)"
else
  error "Phase table mismatch: README.md=$EN_PHASES README_CN.md=$CN_PHASES (expected 8)"
fi
echo ""

# 6. Reference file count
echo "--- Reference file count ---"
REF_COUNT=$(find "$REF_DIR" -name '*.md' -type f 2>/dev/null | wc -l)
INSTALL_CLAIMS=$(grep -oP 'Expected:\s*\K[0-9]+' "$REPO_ROOT/INSTALL.md" 2>/dev/null | head -1 || echo "?")

if [ "$REF_COUNT" -ge 11 ]; then
  pass "$REF_COUNT reference files found"
else
  error "Only $REF_COUNT reference files found (expected >= 11)"
fi

if [ "$INSTALL_CLAIMS" != "?" ] && [ "$REF_COUNT" != "$INSTALL_CLAIMS" ]; then
  error "INSTALL.md claims $INSTALL_CLAIMS reference files but found $REF_COUNT"
fi
echo ""

# Summary
echo "=== Summary ==="
if [ "$ERRORS" -eq 0 ]; then
  echo "All checks passed."
  exit 0
else
  echo "$ERRORS check(s) failed."
  exit 1
fi
