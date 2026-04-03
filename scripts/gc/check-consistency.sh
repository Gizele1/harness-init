#!/usr/bin/env bash
# Consistency check script for harness-init
# Replaces traditional boundary tests for this documentation-only project.
#
# Checks:
#   1. All `Read references/*.md` paths in SKILL.md resolve to existing files
#   2. plugin.json `skills` path is valid
#   3. README and README_CN have matching phase counts
#   4. No cross-references between reference files
#   5. JSON files are valid
#
# Usage: bash scripts/gc/check-consistency.sh
# Exit code: 0 = all checks pass, 1 = failures found

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILL_FILE="$REPO_ROOT/skills/harness-init/SKILL.md"
REFS_DIR="$REPO_ROOT/skills/harness-init/references"
PLUGIN_JSON="$REPO_ROOT/.claude-plugin/plugin.json"
README="$REPO_ROOT/README.md"
README_CN="$REPO_ROOT/README_CN.md"

errors=0

echo "=== harness-init consistency check ==="
echo ""

# --- Check 1: SKILL.md reference paths ---
echo "Check 1: SKILL.md reference paths"
if [ -f "$SKILL_FILE" ]; then
  # Extract all `Read references/...` or `references/...md` paths from SKILL.md
  refs=$(grep -oP 'references/[a-zA-Z0-9_-]+\.md' "$SKILL_FILE" | sort -u || true)
  check1_errors=0
  if [ -n "$refs" ]; then
    for ref in $refs; do
      full_path="$REPO_ROOT/skills/harness-init/$ref"
      if [ ! -f "$full_path" ]; then
        echo "  FAIL: SKILL.md references '$ref' but file does not exist"
        echo "  FIX:  Create '$full_path' or remove the reference from SKILL.md"
        check1_errors=$((check1_errors + 1))
      fi
    done
    if [ $check1_errors -eq 0 ]; then
      ref_count=$(echo "$refs" | wc -l)
      echo "  OK: All $ref_count referenced files exist"
    fi
  else
    echo "  WARN: No reference paths found in SKILL.md"
  fi
  errors=$((errors + check1_errors))
else
  echo "  FAIL: SKILL.md not found at $SKILL_FILE"
  errors=$((errors + 1))
fi
echo ""

# --- Check 2: plugin.json validity ---
echo "Check 2: plugin.json validity"
if [ -f "$PLUGIN_JSON" ]; then
  # Validate JSON syntax
  if python3 -m json.tool "$PLUGIN_JSON" > /dev/null 2>&1; then
    echo "  OK: plugin.json is valid JSON"
  else
    echo "  FAIL: plugin.json is not valid JSON"
    echo "  FIX:  Fix JSON syntax errors in $PLUGIN_JSON"
    errors=$((errors + 1))
  fi

  # Check skills path
  skills_path=$(python3 -c "import json; print(json.load(open('$PLUGIN_JSON')).get('skills', ''))" 2>/dev/null || echo "")
  if [ -n "$skills_path" ]; then
    resolved="$REPO_ROOT/${skills_path#./}"
    if [ -d "$resolved" ]; then
      echo "  OK: skills path '$skills_path' resolves to valid directory"
    else
      echo "  FAIL: skills path '$skills_path' does not resolve to a directory"
      echo "  FIX:  Update 'skills' field in plugin.json to point to './skills/'"
      errors=$((errors + 1))
    fi
  fi
else
  echo "  FAIL: plugin.json not found at $PLUGIN_JSON"
  errors=$((errors + 1))
fi
echo ""

# --- Check 3: marketplace.json validity ---
echo "Check 3: marketplace.json validity"
MARKETPLACE_JSON="$REPO_ROOT/.claude-plugin/marketplace.json"
if [ -f "$MARKETPLACE_JSON" ]; then
  if python3 -m json.tool "$MARKETPLACE_JSON" > /dev/null 2>&1; then
    echo "  OK: marketplace.json is valid JSON"
  else
    echo "  FAIL: marketplace.json is not valid JSON"
    echo "  FIX:  Fix JSON syntax errors in $MARKETPLACE_JSON"
    errors=$((errors + 1))
  fi
else
  echo "  WARN: marketplace.json not found (optional)"
fi
echo ""

# --- Check 4: README phase count consistency ---
echo "Check 4: README phase count consistency"
if [ -f "$README" ] && [ -f "$README_CN" ]; then
  # Count phase rows in the phase table (lines starting with | N.)
  en_phases=$(grep -cP '^\|\s*\d+\.' "$README" || echo 0)
  cn_phases=$(grep -cP '^\|\s*\d+\.' "$README_CN" || echo 0)
  if [ "$en_phases" -eq "$cn_phases" ] && [ "$en_phases" -gt 0 ]; then
    echo "  OK: Both READMEs have $en_phases phases"
  elif [ "$en_phases" -eq 0 ] && [ "$cn_phases" -eq 0 ]; then
    echo "  WARN: No phase tables detected in either README"
  else
    echo "  FAIL: README.md has $en_phases phases, README_CN.md has $cn_phases phases"
    echo "  FIX:  Sync phase tables between README.md and README_CN.md"
    errors=$((errors + 1))
  fi
else
  echo "  WARN: One or both README files missing, skipping phase comparison"
fi
echo ""

# --- Check 5: No cross-references between reference files ---
# Exception: stack-routing.md is the cross-phase routing table — it may be
# referenced by other files and may reference ci-templates.md for GC workflow.
# See docs/golden-principles/REFERENCES.md "Exceptions" section.
CROSS_REF_EXCEPTIONS="stack-routing.md ci-templates.md"

echo "Check 5: Reference file independence"
if [ -d "$REFS_DIR" ]; then
  cross_refs=0
  for ref_file in "$REFS_DIR"/*.md; do
    basename=$(basename "$ref_file")
    # Check if this file references other files in the same directory
    other_refs=$(grep -oP 'references/[a-zA-Z0-9_-]+\.md' "$ref_file" 2>/dev/null || true)
    if [ -n "$other_refs" ]; then
      for other in $other_refs; do
        other_name=$(basename "$other")
        if [ "$other_name" != "$basename" ]; then
          # Skip known exceptions (cross-phase routing table)
          is_exception=false
          for exc in $CROSS_REF_EXCEPTIONS; do
            if [ "$other_name" = "$exc" ] || [ "$basename" = "stack-routing.md" ]; then
              is_exception=true
              break
            fi
          done
          if [ "$is_exception" = false ]; then
            echo "  FAIL: $basename references $other_name (cross-reference)"
            echo "  FIX:  Inline shared content or extract to a separate reference. See docs/golden-principles/REFERENCES.md"
            cross_refs=$((cross_refs + 1))
          fi
        fi
      done
    fi
  done
  if [ $cross_refs -eq 0 ]; then
    ref_file_count=$(ls -1 "$REFS_DIR"/*.md 2>/dev/null | wc -l)
    exc_count=$(echo $CROSS_REF_EXCEPTIONS | wc -w)
    echo "  OK: All $ref_file_count reference files are independent ($exc_count known exceptions skipped)"
  fi
  errors=$((errors + cross_refs))
else
  echo "  FAIL: References directory not found at $REFS_DIR"
  errors=$((errors + 1))
fi
echo ""

# --- Summary ---
echo "=== Summary ==="
if [ $errors -eq 0 ]; then
  echo "All checks passed."
  exit 0
else
  echo "$errors error(s) found."
  exit 1
fi
