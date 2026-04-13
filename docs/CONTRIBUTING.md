# Contributing to cc-accents

Thank you for your interest in contributing! This guide covers how to add accents, fix bugs, and improve the system.

## How to Contribute

1. Fork the repository
2. Create a branch: `git checkout -b feature/my-new-accent`
3. Make your changes
4. Test with `./tests/test-install.sh`
5. Submit a pull request

## Adding a New Accent

See [ADDING-ACCENTS.md](ADDING-ACCENTS.md) for the full guide.

Quick checklist:
- [ ] Add `src/accents/<key>.md` with the ACCENT definition
- [ ] Add entry to `src/accents/_registry.md`
- [ ] Add entry to the menu table in `src/SKILL.md`
- [ ] Test locally: install and use `/accent <key>` in Claude Code

## Code of Conduct

- Mock the code, never the person
- Keep accents fun and light-hearted
- No accent should produce actually harmful output
- Comedic impressions of speech patterns only — no targeting individuals
