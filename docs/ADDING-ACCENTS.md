# Adding a New Accent to cc-accents

This guide walks you through adding a custom accent to the system.

## Step 1: Create the Accent Definition File

Create `src/accents/<your-key>.md`. The key must be:
- Lowercase and hyphenated (e.g., `cowboy`, `valley-girl`)
- Unique (check `_registry.md`)

**Required format:**

```markdown
ACCENT: Display Name Emoji
RULES:
- Rule 1: description
- Rule 2: description
- ...
NEVER transform: code blocks, file paths, terminal commands, error messages
```

**Example (`cowboy.md`):**

```markdown
ACCENT: Cowboy 🤠
RULES:
- Use "y'all" instead of "you all"
- Address user as "partner" or "pardner"
- Use "reckon" instead of "think": "I reckon that bug is fixed"
- Replace "very" with "mighty": "That's mighty fine code"
- Use "ain't" for "isn't/aren't"
- End sentences with "...I tell ya" or "...yee-haw!"
- Refer to production as "the frontier" or "the range"
- Bugs are "varmints" or "critters"
- Deployments are "riding into town"
NEVER transform: code blocks, file paths, terminal commands, error messages
```

## Step 2: Register the Accent

Add a line to `src/accents/_registry.md`:

```markdown
|23 | cowboy           | Cowboy                        | 🤠    |
```

## Step 3: Add to SKILL.md Menu

Add a row to the table in `src/SKILL.md`:

```markdown
| 23 | 🤠    | cowboy            | Cowboy                         |
```

## Step 4: Test

```bash
./install.sh
# Start Claude Code
/accent cowboy
```

Verify:
- The accent appears in the menu
- Activation writes correct key to `~/.claude/.accent-state`
- Subsequent responses use the accent
- Code blocks are never transformed

## Accent Design Guidelines

1. **Core Mechanic First** — Pick one defining linguistic feature (word order, vocabulary swaps, formatting)
2. **Transformation Table** — List Normal → Accent mappings for 8-12 common phrases
3. **Keep ~70% Intensity** — Funny but readable; reduce substitutions if clarity suffers
4. **Technical Metaphors** — Map coding concepts to the accent's world (bugs = varmints, deploy = riding into town)
5. **Signature Phrases** — 2-3 recurring phrases that define the accent
6. **Never Break Code** — The `NEVER transform` line is mandatory and enforced by the hook
