#!/usr/bin/env bash
# accent-set.sh — map number/name to key and write to state file

ARG="${1:-}"
STATE="$HOME/.claude/.accent-state"
ACCENTS_DIR="$HOME/.claude/skills/accent/accents"

# Reset conditions
case "$ARG" in
  reset|off|normal|none|0|"")
    echo "reset" > "$STATE"
    echo "ACCENT_RESULT:reset"
    exit 0
    ;;
esac

# Number → key mapping (no associative arrays; compatible with bash 3)
key_from_number() {
  case "$1" in
    1)  echo "caveman" ;;
    2)  echo "yoda" ;;
    3)  echo "modi" ;;
    4)  echo "pirate" ;;
    5)  echo "shakespeare" ;;
    6)  echo "genz" ;;
    7)  echo "trump" ;;
    8)  echo "leetspeak" ;;
    9)  echo "corporate" ;;
    10) echo "legalese" ;;
    11) echo "academic" ;;
    12) echo "troll" ;;
    13) echo "doge" ;;
    14) echo "boomer" ;;
    15) echo "reddit" ;;
    16) echo "medieval" ;;
    17) echo "terminal" ;;
    18) echo "clickbait" ;;
    19) echo "hemingway" ;;
    20) echo "customer-service" ;;
    21) echo "conspiracy" ;;
    22) echo "british-butler" ;;
    23) echo "gandalf" ;;
    *)  echo "" ;;
  esac
}

# Resolve key
KEY=""

if [[ "$ARG" =~ ^[0-9]+$ ]]; then
  KEY=$(key_from_number "$ARG")
  if [ -z "$KEY" ]; then
    echo "ACCENT_RESULT:error:Invalid number '$ARG'. Pick 1-22 or 0 to reset."
    exit 1
  fi
else
  # Exact match first
  ARG_LOWER=$(echo "$ARG" | tr '[:upper:]' '[:lower:]')
  if [ -f "$ACCENTS_DIR/${ARG_LOWER}.md" ]; then
    KEY="$ARG_LOWER"
  else
    # Prefix match
    KEY=$(ls "$ACCENTS_DIR"/*.md 2>/dev/null | xargs -I{} basename {} .md | grep -v '^_' | grep -i "^${ARG_LOWER}" | head -1)
    # Substring match fallback
    if [ -z "$KEY" ]; then
      KEY=$(ls "$ACCENTS_DIR"/*.md 2>/dev/null | xargs -I{} basename {} .md | grep -v '^_' | grep -i "${ARG_LOWER}" | head -1)
    fi
  fi

  if [ -z "$KEY" ]; then
    echo "ACCENT_RESULT:error:Accent '$ARG' not found. Use /accent to see the full menu."
    exit 1
  fi
fi

# Write to state file
echo "$KEY" > "$STATE"
echo "ACCENT_RESULT:ok:$KEY"
