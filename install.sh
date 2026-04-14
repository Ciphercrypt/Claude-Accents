#!/usr/bin/env bash
set -euo pipefail

# ╔══════════════════════════════════════════════╗
# ║        cc-accents installer v1.0             ║
# ║   Accent system for Claude Code CLI          ║
# ╚══════════════════════════════════════════════╝

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════╗"
echo "║     🎭  cc-accents installer v1.0  🎭        ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"

# ── Step 1: Prerequisites ──────────────────────
echo -e "${YELLOW}[1/6]${NC} Checking prerequisites..."

if ! command -v claude &> /dev/null; then
  echo -e "${RED}✗ Claude Code CLI not found. Install it first:${NC}"
  echo "  npm install -g @anthropic-ai/claude-code"
  exit 1
fi

if [ ! -d "$HOME/.claude" ]; then
  echo -e "${YELLOW}  Creating ~/.claude directory...${NC}"
  mkdir -p "$HOME/.claude"
fi

# Check for JSON processing capability
JSON_TOOL=""
if command -v jq &> /dev/null; then
  JSON_TOOL="jq"
elif command -v python3 &> /dev/null; then
  JSON_TOOL="python3"
elif command -v node &> /dev/null; then
  JSON_TOOL="node"
else
  echo -e "${RED}✗ Need jq, python3, or node for JSON processing${NC}"
  exit 1
fi
echo -e "${GREEN}  ✓ Prerequisites OK (using $JSON_TOOL for JSON)${NC}"

# ── Step 2: Locate or download source files ────
echo -e "${YELLOW}[2/6]${NC} Locating source files..."

REPO_URL="https://github.com/Ciphercrypt/Claude-Accents/archive/refs/heads/main.tar.gz"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-install.sh}")" 2>/dev/null && pwd)" || SCRIPT_DIR=""
TMP_DIR=""

if [ -f "$SCRIPT_DIR/src/SKILL.md" ]; then
  SRC_DIR="$SCRIPT_DIR/src"
  echo -e "${GREEN}  ✓ Local source files found at $SRC_DIR${NC}"
else
  echo -e "${YELLOW}  Downloading from GitHub...${NC}"
  if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
    echo -e "${RED}✗ Need curl or wget to download files${NC}"
    exit 1
  fi
  TMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TMP_DIR"' EXIT
  if command -v curl &> /dev/null; then
    curl -sL "$REPO_URL" | tar -xz -C "$TMP_DIR" --strip-components=1
  else
    wget -qO- "$REPO_URL" | tar -xz -C "$TMP_DIR" --strip-components=1
  fi
  SRC_DIR="$TMP_DIR/src"
  echo -e "${GREEN}  ✓ Downloaded source files${NC}"
fi

# ── Step 3: Create directory structure ─────────
echo -e "${YELLOW}[3/6]${NC} Creating directory structure..."

mkdir -p "$HOME/.claude/skills/accent/accents"
mkdir -p "$HOME/.claude/output-styles"
mkdir -p "$HOME/.claude/hooks"

echo -e "${GREEN}  ✓ Directories created${NC}"

# ── Step 4: Copy files ─────────────────────────
echo -e "${YELLOW}[4/6]${NC} Installing accent files..."

cp "$SRC_DIR/SKILL.md" "$HOME/.claude/skills/accent/SKILL.md"
cp "$SRC_DIR/accent-set.sh" "$HOME/.claude/skills/accent/accent-set.sh"
chmod +x "$HOME/.claude/skills/accent/accent-set.sh"

ACCENT_COUNT=0
for f in "$SRC_DIR/accents/"*.md; do
  [ -f "$f" ] && cp "$f" "$HOME/.claude/skills/accent/accents/" && ACCENT_COUNT=$((ACCENT_COUNT + 1))
done

# Install hook script
cp "$SRC_DIR/hooks/accent-inject.sh" "$HOME/.claude/hooks/accent-inject.sh"
chmod +x "$HOME/.claude/hooks/accent-inject.sh"

echo -e "${GREEN}  ✓ Installed $ACCENT_COUNT accents + hook script${NC}"

# ── Step 5: Generate output styles ─────────────
echo -e "${YELLOW}[5/6]${NC} Generating output styles..."

STYLE_COUNT=0
for accent_file in "$HOME/.claude/skills/accent/accents/"*.md; do
  key=$(basename "$accent_file" .md)
  [ "$key" = "_registry" ] && continue

  first_line=$(head -1 "$accent_file")
  display_name=$(echo "$first_line" | sed 's/^ACCENT: //')

  cat > "$HOME/.claude/output-styles/accent-${key}.md" << STYLEEOF
---
name: Accent: ${display_name}
description: All Claude Code responses in ${display_name} style
keep-coding-instructions: true
---

$(cat "$accent_file")

REMEMBER: Apply this style to ALL conversational responses. Never apply to code blocks,
file contents, file paths, terminal commands, or error messages.
STYLEEOF
  STYLE_COUNT=$((STYLE_COUNT + 1))
done

echo -e "${GREEN}  ✓ Generated $STYLE_COUNT output styles${NC}"

# ── Step 6: Merge hook into settings.json ──────
echo -e "${YELLOW}[6/6]${NC} Configuring UserPromptSubmit hook..."

SETTINGS="$HOME/.claude/settings.json"

if [ -f "$SETTINGS" ] && grep -q "accent-inject" "$SETTINGS" 2>/dev/null; then
  echo -e "${GREEN}  ✓ Hook already configured — skipping${NC}"
elif [ ! -f "$SETTINGS" ]; then
  cat > "$SETTINGS" << 'HOOKJSON'
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/accent-inject.sh"
          }
        ]
      }
    ]
  }
}
HOOKJSON
  echo -e "${GREEN}  ✓ Created settings.json with hook${NC}"
else
  # Merge into existing settings.json
  if [ "$JSON_TOOL" = "python3" ]; then
    python3 -c "
import json, os
p = os.path.expanduser('~/.claude/settings.json')
with open(p) as f: s = json.load(f)
h = {'hooks': [{'type': 'command', 'command': 'bash ~/.claude/hooks/accent-inject.sh'}]}
s.setdefault('hooks', {}).setdefault('UserPromptSubmit', []).append(h)
with open(p, 'w') as f: json.dump(s, f, indent=2)
print('Hook merged into settings.json successfully.')
"
  elif [ "$JSON_TOOL" = "jq" ]; then
    tmp=$(mktemp)
    jq '.hooks.UserPromptSubmit += [{"hooks":[{"type":"command","command":"bash ~/.claude/hooks/accent-inject.sh"}]}]' \
      "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  elif [ "$JSON_TOOL" = "node" ]; then
    node -e "
const fs=require('fs'); const p=require('os').homedir()+'/.claude/settings.json';
let s=JSON.parse(fs.readFileSync(p,'utf8'));
if(!s.hooks)s.hooks={};if(!s.hooks.UserPromptSubmit)s.hooks.UserPromptSubmit=[];
s.hooks.UserPromptSubmit.push({hooks:[{type:'command',command:'bash ~/.claude/hooks/accent-inject.sh'}]});
fs.writeFileSync(p,JSON.stringify(s,null,2));
console.log('Hook merged into settings.json successfully.');
"
  fi
  echo -e "${GREEN}  ✓ Hook merged into existing settings.json${NC}"
fi

# Initialize state file
echo "reset" > "$HOME/.claude/.accent-state"

# ── Done! ──────────────────────────────────────
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     ✅  cc-accents installed successfully!   ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${CYAN}Usage:${NC}"
echo -e "    ${YELLOW}/accent${NC}           — Pick from the accent menu"
echo -e "    ${YELLOW}/accent pirate${NC}    — Activate directly by name"
echo -e "    ${YELLOW}/accent 11${NC}        — Activate by number (Doge)"
echo -e "    ${YELLOW}/accent reset${NC}     — Return to normal Claude"
echo ""
echo -e "  ${CYAN}Persistent styles (across sessions):${NC}"
echo -e "    ${YELLOW}/output-style${NC}     — Browse all accent output styles"
echo ""
echo -e "  ${CYAN}Start a new Claude Code session to begin! 🎭${NC}"
echo ""
