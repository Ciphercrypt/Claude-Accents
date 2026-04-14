# 🎭 cc-accents

> A plug-and-play accent and personality system for Claude Code CLI.
> Pick from 23 comedic speaking styles with a single `/accent` command — while keeping full technical accuracy.

```
/accent pirate
```
> *Arrr! Set sail we have — the fix be on the open seas now! Yer codebase be shipshape, Cap'n!*

---

## Why

Claude Code is technically precise but tonally monotone. You spend hours in terminal sessions — `cc-accents` makes it a little more fun. One command to switch personalities, zero config, and it never touches your code.

---

## Features

- **23 accents** — Pirate, Yoda, Gen-Z, Corporate, Modi, Gandalf, and 17 more
- **One-command install** — no manual JSON editing
- **Persistent** — survives `/compact`, `/clear`, and session restarts via a `UserPromptSubmit` hook
- **Code stays clean** — accents apply only to conversational text, never to code blocks, file paths, or commands
- **Non-destructive** — merges into your existing `settings.json` without overwriting anything
- **Clean uninstall** — removes every trace with a single command

---

## Installation

### Prerequisites

- [Claude Code CLI](https://claude.ai/code) installed
- `python3`, `node`, or `jq` (for JSON merging — at least one required)

### Install

```bash
git clone https://github.com/Ciphercrypt/Claude-Accents.git
cd Claude-Accents
./install.sh
```

Then **start a new Claude Code session** for the hook to take effect.

### What the installer does

| Step | Action |
|------|--------|
| 1 | Checks prerequisites (Claude CLI, JSON tool) |
| 2 | Creates `~/.claude/skills/accent/` with all accent files |
| 3 | Installs `~/.claude/hooks/accent-inject.sh` |
| 4 | Merges the `UserPromptSubmit` hook into `~/.claude/settings.json` |
| 5 | Generates output style files in `~/.claude/output-styles/` |
| 6 | Initializes `~/.claude/.accent-state` to `reset` |

The installer is **idempotent** — running it twice won't duplicate hooks or overwrite existing settings.

---

## Usage

### Pick from the menu

```
/accent
```

Shows all 23 accents with example sentences. Type a number or name to activate.

### Activate directly

```
/accent pirate          # by name
/accent 3               # by number
/accent sha             # partial match → shakespeare
/accent GENZ            # case-insensitive
```

### Reset to normal

```
/accent reset
/accent off
/accent 0
```

### Help

```
/accent help
```

---

## The 23 Accents

| # | Accent | Key | Flavour |
|---|--------|-----|---------|
| 1 | 🦴 Caveman | `caveman` | Me fix bug. Task done now. You welcome. |
| 2 | 🟢 Yoda | `yoda` | Fixed the bug, I have. Mmm. Strong with the Force, this code is. |
| 3 | 🏴‍☠️ Pirate | `pirate` | Arrr! The barnacle be gone, Cap'n! Shipshape! |
| 4 | 🎭 Shakespeare | `shakespeare` | Hark! The wretched malady hath been vanquished! |
| 5 | 💅 Gen-Z | `genz` | ok so basically the bug was lowkey not it... fixed now bestie no cap |
| 6 | 💻 Leetspeak | `leetspeak` | 1 f1x3d 7h3 bu6. g07 pwn3d!!!!1!1! |
| 7 | 📊 Corporate | `corporate` | I'm pleased to report we've actioned a mission-critical remediation. |
| 8 | ⚖️ Legalese | `legalese` | WHEREAS the aforementioned defect has been remediated in full... |
| 9 | 🎓 Academic | `academic` | Preliminary findings suggest functional correctness (p<0.05, n=1). |
| 10 | 😏 Troll | `troll` | wow. groundbreaking. who could have possibly seen this bug coming. |
| 11 | 🐕 Doge | `doge` | such bug. very fix. much success. wow. |
| 12 | 👴 Boomer | `boomer` | GOOD NEWS !!! The bug.... is FIXED !! LOL — Claude ,, Sent from my Computer |
| 13 | 🧵 Reddit | `reddit` | So, obligatory "this actually happened." TL;DR: bug fixed. EDIT: it works. |
| 14 | ⚔️ Medieval | `medieval` | And lo, the foul beast hath been slain! The Kingdom rejoices! |
| 15 | 🖥️ Terminal | `terminal` | [INFO][PID:1337] PATCH APPLIED — ALL SYSTEMS NOMINAL. STATUS: OPERATIONAL |
| 16 | 📰 Clickbait | `clickbait` | You Won't BELIEVE what was causing this bug 👀 (Number 2 will SHOCK you) |
| 17 | 📝 Hemingway | `hemingway` | The bug was found. It was a missing semicolon. I fixed it. It was good. |
| 18 | 😊 Customer Service | `customer-service` | Thank you so much for reaching out! I've created ticket #BUG-48291 for this! |
| 19 | 🔺 Conspiracy | `conspiracy` | They don't WANT you to know about this memory leak. Trust no dependency. |
| 20 | 🇺🇸 Trump | `trump` | Nobody fixes bugs better than me. Believe me. Totally fixed. Completely fixed. |
| 21 | 🤵 British Butler | `british-butler` | I have taken the liberty of fixing the bug, sir. Most irregular error, that was. |
| 22 | 🧙 Gandalf | `gandalf` | YOU SHALL NOT PASS... null to this function. The road to production is long. |
| 23 | 🇮🇳 Modi | `modi` | Mitron, ... from last many days this bug is a obstacle in our vikas. Jai Hind! |

---

## How It Works

The system has three layers:

```
┌─────────────────────────────────────────────────┐
│  LAYER 1 — /accent skill                        │
│  Presents menu, calls accent-set.sh,            │
│  writes selection to ~/.claude/.accent-state    │
└──────────────────────┬──────────────────────────┘
                       │ writes key
                       ▼
┌─────────────────────────────────────────────────┐
│  STATE FILE — ~/.claude/.accent-state           │
│  Plain text, one line: e.g. "pirate"            │
│  "reset" or empty = no accent active            │
└──────────────────────┬──────────────────────────┘
                       │ read on every message
                       ▼
┌─────────────────────────────────────────────────┐
│  LAYER 2 — UserPromptSubmit hook                │
│  accent-inject.sh fires before every message,  │
│  reads state file, injects accent rules as      │
│  additionalContext — survives /compact, /clear  │
└──────────────────────┬──────────────────────────┘
                       │ optional
                       ▼
┌─────────────────────────────────────────────────┐
│  LAYER 3 — Output Styles (cross-session)        │
│  ~/.claude/output-styles/accent-<name>.md       │
│  Activate with: /output-style accent-pirate     │
│  Persists in settings across sessions           │
└─────────────────────────────────────────────────┘
```

### Layer 1 — The Skill

`/accent` loads `~/.claude/skills/accent/SKILL.md`. When you pick an accent, Claude runs `bash ~/.claude/skills/accent/accent-set.sh <key>`, which maps numbers to keys and writes the result to the state file. The confirmation message is delivered in the chosen accent immediately.

### Layer 2 — The Hook

`~/.claude/hooks/accent-inject.sh` is registered as a `UserPromptSubmit` hook. It fires before Claude sees every message, reads the state file, and returns:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "ACTIVE ACCENT SYSTEM: ..."
  }
}
```

This means the accent persists even after `/compact` or `/clear` — the hook re-injects the rules every single turn.

### Layer 3 — Output Styles

Each accent also has a file in `~/.claude/output-styles/`. Use `/output-style accent-<name>` to set a permanent default that persists across sessions in `settings.local.json`.

---

## Files Installed

```
~/.claude/
├── skills/
│   └── accent/
│       ├── SKILL.md              # /accent command definition
│       ├── accent-set.sh         # maps number/name → key, writes state
│       └── accents/              # 23 accent definition files
│           ├── _registry.md
│           ├── caveman.md
│           └── ... (one per accent)
├── output-styles/
│   └── accent-*.md               # one output style per accent
├── hooks/
│   └── accent-inject.sh          # UserPromptSubmit hook
└── .accent-state                 # current active accent (plain text)
```

---

## Uninstall

```bash
./uninstall.sh
```

Removes all installed files and strips the hook entry from `settings.json`. Start a new Claude Code session afterwards.

---

## Accent Rules (Universal)

All accents follow these non-negotiable rules regardless of style:

- **Code blocks are never transformed** — syntax stays correct
- **File paths and commands are never transformed** — shell commands work
- **Technical accuracy is never sacrificed** — only the delivery changes
- **Intensity is ~70%** — heavy enough to be funny, light enough to read
- **Safety-critical questions drop the accent** — dangerous operations get plain responses

---

## Adding a New Accent

See [docs/ADDING-ACCENTS.md](docs/ADDING-ACCENTS.md) for the full guide.

Quick version:
1. Create `src/accents/<key>.md` following the existing format
2. Add an entry to `src/accents/_registry.md`
3. Add a row to the menu table in `src/SKILL.md`
4. Add a `case` entry in `src/accent-set.sh`
5. Run `./install.sh` to deploy

---

## Contributing

See [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md).

Pull requests for new accents are welcome. Keep them fun, keep them readable, and never break the code integrity rules.

---

## License

MIT — see [LICENSE](LICENSE).
