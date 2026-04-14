# 🎭 cc-accents

> A plug-and-play accent and personality system for Claude Code CLI.
> Pick from 23 comedic speaking styles with a single `/accent` command — while keeping full technical accuracy.

---

## Install

```bash
bash <(curl -sL https://raw.githubusercontent.com/Ciphercrypt/Claude-Accents/main/install.sh)
```

Then **start a new Claude Code session**. That's it.

> **Prerequisites:** [Claude Code CLI](https://claude.ai/code) + one of `python3`, `node`, or `jq`

---

## Usage

```
/accent              # browse the menu
/accent pirate       # activate by name
/accent 3            # activate by number
/accent sha          # partial match → shakespeare
/accent reset        # back to normal
/accent help         # command reference
```

---

## The 23 Accents

| # | Accent | Key | Sounds like |
|---|--------|-----|-------------|
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
| 16 | 📰 Clickbait | `clickbait` | You Won't BELIEVE what was causing this bug 👀 |
| 17 | 📝 Hemingway | `hemingway` | The bug was found. It was a missing semicolon. I fixed it. It was good. |
| 18 | 😊 Customer Service | `customer-service` | Thank you so much for reaching out! I've created ticket #BUG-48291! |
| 19 | 🔺 Conspiracy | `conspiracy` | They don't WANT you to know about this memory leak. Trust no dependency. |
| 20 | 🇺🇸 Trump | `trump` | Nobody fixes bugs better than me. Believe me. Totally fixed. |
| 21 | 🤵 British Butler | `british-butler` | I have taken the liberty of fixing the bug, sir. Most irregular. |
| 22 | 🧙 Gandalf | `gandalf` | YOU SHALL NOT PASS... null to this function. |
| 23 | 🇮🇳 Modi | `modi` | Mitron, ... from last many days this bug is a obstacle in our vikas. Jai Hind! |

---

## How It Works

The accent persists through three layers:

**Layer 1 — `/accent` skill**
Presents the menu, calls `accent-set.sh` to write your selection to `~/.claude/.accent-state`.

**Layer 2 — `UserPromptSubmit` hook**
Fires before every message, reads the state file, injects the accent rules as `additionalContext`. This is why the accent survives `/compact`, `/clear`, and session restarts — the rules are re-injected on every single turn.

**Layer 3 — Output styles**
Each accent also has a file in `~/.claude/output-styles/`. Use `/output-style accent-<name>` to set a permanent cross-session default.

---

## Accent Rules (always enforced)

- Code blocks, file paths, and shell commands are **never** transformed
- Technical accuracy is **never** sacrificed — only the delivery changes
- Safety-critical questions (destructive commands, production ops) **drop the accent** and respond plainly

---

## Uninstall

```bash
bash <(curl -sL https://raw.githubusercontent.com/Ciphercrypt/Claude-Accents/main/uninstall.sh)
```

Removes all installed files and strips the hook from `settings.json`. Start a new session afterwards.

---

## Adding a New Accent

See [docs/ADDING-ACCENTS.md](docs/ADDING-ACCENTS.md) for the full guide.

---

## License

MIT — see [LICENSE](LICENSE).
