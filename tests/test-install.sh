#!/usr/bin/env bash
# cc-accents installation tests
# Tests: T-INS-01 through T-INS-05

set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0

pass() { echo -e "${GREEN}  ✓ PASS${NC} $1"; PASS=$((PASS + 1)); }
fail() { echo -e "${RED}  ✗ FAIL${NC} $1"; FAIL=$((FAIL + 1)); }

echo -e "${YELLOW}=== cc-accents Installation Tests ===${NC}"
echo ""

# T-INS-01: All required files exist after install
echo "[T-INS-01] All required files created after install"
required_files=(
  "$HOME/.claude/skills/accent/SKILL.md"
  "$HOME/.claude/skills/accent/accents/_registry.md"
  "$HOME/.claude/skills/accent/accents/caveman.md"
  "$HOME/.claude/skills/accent/accents/yoda.md"
  "$HOME/.claude/skills/accent/accents/pirate.md"
  "$HOME/.claude/skills/accent/accents/shakespeare.md"
  "$HOME/.claude/skills/accent/accents/genz.md"
  "$HOME/.claude/skills/accent/accents/leetspeak.md"
  "$HOME/.claude/skills/accent/accents/corporate.md"
  "$HOME/.claude/skills/accent/accents/legalese.md"
  "$HOME/.claude/skills/accent/accents/academic.md"
  "$HOME/.claude/skills/accent/accents/troll.md"
  "$HOME/.claude/skills/accent/accents/doge.md"
  "$HOME/.claude/skills/accent/accents/boomer.md"
  "$HOME/.claude/skills/accent/accents/reddit.md"
  "$HOME/.claude/skills/accent/accents/medieval.md"
  "$HOME/.claude/skills/accent/accents/terminal.md"
  "$HOME/.claude/skills/accent/accents/clickbait.md"
  "$HOME/.claude/skills/accent/accents/hemingway.md"
  "$HOME/.claude/skills/accent/accents/customer-service.md"
  "$HOME/.claude/skills/accent/accents/conspiracy.md"
  "$HOME/.claude/skills/accent/accents/trump.md"
  "$HOME/.claude/skills/accent/accents/british-butler.md"
  "$HOME/.claude/skills/accent/accents/gandalf.md"
  "$HOME/.claude/hooks/accent-inject.sh"
  "$HOME/.claude/.accent-state"
)
all_ok=true
for f in "${required_files[@]}"; do
  if [ ! -f "$f" ]; then
    fail "Missing: $f"
    all_ok=false
  fi
done
$all_ok && pass "All required files present (${#required_files[@]} files)"

# T-INS-02: settings.json contains hook
echo ""
echo "[T-INS-02] Hook present in settings.json"
if grep -q "accent-inject" "$HOME/.claude/settings.json" 2>/dev/null; then
  pass "accent-inject hook found in settings.json"
else
  fail "accent-inject hook NOT found in settings.json"
fi

# T-INS-03: Idempotent — run install again and check no duplicate hooks
echo ""
echo "[T-INS-03] Idempotent install (no duplicate hooks)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bash "$SCRIPT_DIR/install.sh" > /dev/null 2>&1 || true
hook_count=$(grep -c "accent-inject" "$HOME/.claude/settings.json" 2>/dev/null || echo 0)
if [ "$hook_count" -le 1 ]; then
  pass "No duplicate hook entries ($hook_count occurrence(s))"
else
  fail "Duplicate hook entries found ($hook_count occurrences)"
fi

# T-INS-04: Output styles generated
echo ""
echo "[T-INS-04] Output styles generated"
style_count=$(ls "$HOME/.claude/output-styles"/accent-*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$style_count" -ge 22 ]; then
  pass "Output styles generated ($style_count files)"
else
  fail "Expected ≥22 output style files, found $style_count"
fi

# T-INS-05: Hook script is executable
echo ""
echo "[T-INS-05] accent-inject.sh is executable"
if [ -x "$HOME/.claude/hooks/accent-inject.sh" ]; then
  pass "accent-inject.sh has executable permissions"
else
  fail "accent-inject.sh is NOT executable"
fi

# T-INS-06 (bonus): State file initialized to "reset"
echo ""
echo "[T-INS-06] State file initialized to 'reset'"
state=$(cat "$HOME/.claude/.accent-state" 2>/dev/null | tr -d '[:space:]')
if [ "$state" = "reset" ]; then
  pass "State file contains 'reset'"
else
  fail "State file contains '$state' (expected 'reset')"
fi

# Summary
echo ""
echo "═══════════════════════════════════"
echo -e "Results: ${GREEN}$PASS passed${NC}, ${RED}$FAIL failed${NC}"
echo "═══════════════════════════════════"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
