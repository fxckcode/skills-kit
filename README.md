# skills-kit

A collection of agent skills for repository setup, multi-CLI agent workflows, and intelligent context loading.

## Skills

| Skill | Description |
|-------|-------------|
| [git-setup-skill](skills/git-setup-skill/) | Expert skill for professional Git/GitHub repository setup: `.gitignore`, `.gitattributes`, README files, licensing, metadata, tags, releases, and GitHub Actions. |
| [swarm-forge-skill](skills/swarm-forge-skill/) | Guided project context setup for multi-CLI agent workflows across Claude Code, Codex, OpenCode, and Gemini CLI using patterns like TDD, BDD, ATDD, and SDD. |
| [path-context-skill](skills/path-context-skill/) | Behavioral protocol for registering external project folders as reference context, with a 6-pass discovery heuristic and strict per-turn token budget. |

## Install

Clone this repo and copy individual skills into your agent skills directory:

```bash
git clone https://github.com/fxckcode/skills-kit.git
```

Then copy the skill you want:

```bash
cp -R skills-kit/skills/git-setup-skill    "$HOME/.agents/skills/git-setup-skill"
cp -R skills-kit/skills/swarm-forge-skill  "$HOME/.agents/skills/swarm-forge-skill"
cp -R skills-kit/skills/path-context-skill "$HOME/.agents/skills/path-context-skill"
```

Or copy into an agent workspace folder:

```bash
cp -R skills-kit/skills/git-setup-skill    /path/to/your/workspace/.claude/skills/git-setup-skill
cp -R skills-kit/skills/swarm-forge-skill  /path/to/your/workspace/.claude/skills/swarm-forge-skill
cp -R skills-kit/skills/path-context-skill /path/to/your/workspace/.claude/skills/path-context-skill
```

## Usage

Skills activate automatically when the agent detects relevant trigger phrases. See each skill's `README.md` or `SKILL.md` for specific triggers and what they produce.

## Repository Layout

```
skills-kit/
├── AGENTS.md
├── CHANGELOG.md
├── CLAUDE.md
├── LICENSE
├── README.md
└── skills/
    ├── git-setup-skill/
    ├── path-context-skill/
    └── swarm-forge-skill/
```

Only the repository root has a `.git/` folder. Individual skills do not carry their own git history inside this repo.

## License

MIT — see [LICENSE](LICENSE).
