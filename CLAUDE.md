# skills-kit

This repository contains agent skills. Each skill lives under `skills/` and has its own `SKILL.md` (or equivalent spec) with instructions.

## Available Skills

- `skills/git-setup-skill/` — Git/GitHub repository setup
- `skills/swarm-forge-skill/` — Multi-CLI agent workflow context setup
- `skills/path-context-skill/` — External folder reference context with 6-pass discovery heuristic
- `skills/api-test-skill/` — Protocol-first, client-agnostic REST API testing from the terminal

## How to load a skill

Reference the skill's `SKILL.md` directly from your project's `CLAUDE.md`:

```
@.claude/skills/git-setup-skill/SKILL.md
@.claude/skills/swarm-forge-skill/SKILL.md
@.claude/skills/path-context-skill/SKILL.md
```

Each `SKILL.md` includes the full instructions and links to its supporting `references/` files.
