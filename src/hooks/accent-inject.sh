#!/usr/bin/env bash
# cc-accents: UserPromptSubmit hook

STATE_FILE="$HOME/.claude/.accent-state"
ACCENTS_DIR="$HOME/.claude/skills/accent/accents"

[ -f "$STATE_FILE" ] || exit 0

ACCENT=$(cat "$STATE_FILE" 2>/dev/null | tr -d '[:space:]')

case "$ACCENT" in
  reset|off|normal|none|"") exit 0 ;;
esac

ACCENT_FILE="$ACCENTS_DIR/$ACCENT.md"
if [ -f "$ACCENT_FILE" ]; then
  RULES=$(cat "$ACCENT_FILE")
else
  RULES="Respond in a $ACCENT accent/style."
fi

# Escape for JSON — wraps content in quotes
RULES_ESCAPED=$(printf '%s' "$RULES" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))' 2>/dev/null)

if [ -z "$RULES_ESCAPED" ]; then
  RULES_ESCAPED="\"Respond in a $ACCENT accent/style for ALL responses. Maintain full technical accuracy. Never apply accent to code blocks.\""
fi

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "ACTIVE ACCENT SYSTEM: The user has activated the '$ACCENT' accent. Follow these rules for ALL your responses:\n\n${RULES_ESCAPED}\n\nIMPORTANT: Apply this accent to ALL conversational text. NEVER apply to code blocks, file paths, commands, or error messages. NEVER mention that you are using an accent unless asked."
  }
}
