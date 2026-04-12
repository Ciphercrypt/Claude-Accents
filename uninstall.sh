#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════╗"
echo "║     🗑️   cc-accents uninstaller v1.0  🗑️     ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"

# ── Remove files ───────────────────────────────
echo -e "${YELLOW}[1/3]${NC} Removing accent files..."

rm -rf "$HOME/.claude/skills/accent"
rm -f "$HOME/.claude/.accent-state"
rm -f "$HOME/.claude/hooks/accent-inject.sh"
rm -f "$HOME/.claude/output-styles"/accent-*.md

echo -e "${GREEN}  ✓ Accent files removed${NC}"

# ── Remove hook from settings.json ─────────────
echo -e "${YELLOW}[2/3]${NC} Removing hook from settings.json..."

SETTINGS="$HOME/.claude/settings.json"

if [ ! -f "$SETTINGS" ]; then
  echo -e "${GREEN}  ✓ No settings.json found — nothing to do${NC}"
elif ! grep -q "accent-inject" "$SETTINGS" 2>/dev/null; then
  echo -e "${GREEN}  ✓ Hook not present in settings.json — nothing to do${NC}"
else
  # Try python3 first, then node
  if command -v python3 &> /dev/null; then
    python3 -c "
import json, os
p = os.path.expanduser('~/.claude/settings.json')
with open(p) as f: s = json.load(f)
if 'hooks' in s and 'UserPromptSubmit' in s['hooks']:
    s['hooks']['UserPromptSubmit'] = [
        h for h in s['hooks']['UserPromptSubmit']
        if not any('accent-inject' in str(hook.get('command', ''))
                   for hook in h.get('hooks', []))
    ]
    if not s['hooks']['UserPromptSubmit']:
        del s['hooks']['UserPromptSubmit']
    if not s['hooks']:
        del s['hooks']
with open(p, 'w') as f: json.dump(s, f, indent=2)
print('Hook removed from settings.json.')
"
  elif command -v node &> /dev/null; then
    node -e "
const fs=require('fs'); const p=require('os').homedir()+'/.claude/settings.json';
let s=JSON.parse(fs.readFileSync(p,'utf8'));
if(s.hooks && s.hooks.UserPromptSubmit){
  s.hooks.UserPromptSubmit=s.hooks.UserPromptSubmit.filter(
    h=>!(h.hooks||[]).some(hh=>(hh.command||'').includes('accent-inject'))
  );
  if(!s.hooks.UserPromptSubmit.length) delete s.hooks.UserPromptSubmit;
  if(!Object.keys(s.hooks).length) delete s.hooks;
}
fs.writeFileSync(p,JSON.stringify(s,null,2));
console.log('Hook removed from settings.json.');
"
  elif command -v jq &> /dev/null; then
    tmp=$(mktemp)
    jq 'del(.hooks.UserPromptSubmit[] | select(.hooks[]?.command | contains("accent-inject")))' \
      "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  else
    echo -e "${RED}  ✗ Could not remove hook — no json tool available. Remove manually from ~/.claude/settings.json${NC}"
  fi
  echo -e "${GREEN}  ✓ Hook removed from settings.json${NC}"
fi

# ── Done ───────────────────────────────────────
echo -e "${YELLOW}[3/3]${NC} Cleanup complete."
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     ✅  cc-accents uninstalled!              ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${CYAN}Start a new Claude Code session for changes to take effect.${NC}"
echo ""
