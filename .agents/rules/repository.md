# Repository conventions

- **README.md is the user guide** (tapping and installing). Update it together with changes that affect users. No other documentation unless explicitly asked.

- General project information, commands and navigation belong in `AGENTS.md`.
  Rules live in `.agents/rules/`; task workflows live in `.agents/skills/`.
- `.claude/rules` and `.claude/skills` are compatibility symlinks.
  Update the canonical targets rather than keeping separate copies.
