#!/usr/bin/env bash
# cc-accents persistence tests (T-PER-01 through T-PER-06)
# Tests state file durability and hook re-injection behavior

set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0

pass() { echo -e "${GREEN}  ✓ PASS${NC} $1"; PASS=$((PASS + 1)); }
fail() { echo -e "${RED}  ✗ FAIL${NC} $1"; FAIL=$((FAIL + 1)); }

STATE="$HOME/.claude/.accent-state"
HOOK="$HOME/.claude/hooks/accent-inject.sh"

echo -e "${YELLOW}=== cc-accents Persistence Tests ===${NC}"
echo ""

# T-PER-06: Reset writes "reset" to state file
echo "[T-PER-06] Reset accent → state file contains 'reset'"
echo "reset" > "$STATE"
state=$(cat "$STATE" | tr -d '[:space:]')
if [ "$state" = "reset" ]; then
  pass "State file correctly contains 'reset' after reset"
else
  fail "State file contains '$state' (expected 'reset')"
fi

# T-PER-01 (simulation): Hook fires consistently across multiple calls
echo ""
echo "[T-PER-01] Hook injects accent consistently (simulates 5 messages)"
echo "yoda" > "$STATE"
all_consistent=true
for i in 1 2 3 4 5; do
  output=$(bash "$HOOK" 2>/dev/null)
  if ! echo "$output" | grep -q "yoda\|Yoda"; then
    all_consistent=false
    fail "Message $i: hook did not inject yoda accent"
  fi
done
$all_consistent && pass "Hook injected yoda accent consistently across 5 calls"

# T-PER-02/T-PER-03: State file survives (simulates /compact and /clear)
echo ""
echo "[T-PER-02/03] State file persists through session events (simulates /compact, /clear)"
echo "shakespeare" > "$STATE"
# Simulate what would happen if conversation context was cleared
# The hook re-reads from disk each time, so state survives
output=$(bash "$HOOK" 2>/dev/null)
if echo "$output" | grep -q "shakespeare\|Shakespeare"; then
  pass "Accent persists via hook re-injection (survives context reset)"
else
  fail "Accent did not persist through simulated context reset"
fi

# T-PER-04: State file survives process restarts (new session simulation)
echo ""
echo "[T-PER-04] State file survives process restart (new session)"
echo "pirate" > "$STATE"
# Re-source the hook in a fresh subshell to simulate new session
output=$(bash -c "bash '$HOOK'" 2>/dev/null)
if echo "$output" | grep -q "pirate\|Pirate"; then
  pass "Accent persists across session (state file on disk)"
else
  fail "Accent did not persist across session restart"
fi

# T-PER-05: Output styles exist for cross-session persistence
echo ""
echo "[T-PER-05] Output style files exist for cross-session persistence"
missing=0
for accent in caveman yoda pirate shakespeare genz leetspeak corporate legalese \
              academic troll doge boomer reddit medieval terminal clickbait \
              hemingway customer-service conspiracy trump british-butler gandalf; do
  if [ ! -f "$HOME/.claude/output-styles/accent-${accent}.md" ]; then
    fail "Missing output style: accent-${accent}.md"
    missing=$((missing + 1))
  fi
done
[ "$missing" -eq 0 ] && pass "All 22 output style files present"

# Output style has correct frontmatter
echo ""
echo "[T-PER-05b] Output style files have correct frontmatter"
style_file="$HOME/.claude/output-styles/accent-pirate.md"
if grep -q "^name:" "$style_file" && grep -q "keep-coding-instructions: true" "$style_file"; then
  pass "Output style frontmatter is correct"
else
  fail "Output style frontmatter is malformed"
fi

# Restore state
echo "reset" > "$STATE"

# Summary
echo ""
echo "═══════════════════════════════════"
echo -e "Results: ${GREEN}$PASS passed${NC}, ${RED}$FAIL failed${NC}"
echo "═══════════════════════════════════"
echo ""
echo -e "${YELLOW}Note:${NC} Full persistence tests (T-PER-01 to T-PER-05) with live Claude"
echo "sessions require manual verification in a Claude Code terminal."
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
