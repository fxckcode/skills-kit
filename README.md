# skills-kit

A collection of agent skills for repository setup, multi-CLI agent workflows, and intelligent context loading.

## Skills

| Skill | Description |
|-------|-------------|
| [git-setup-skill](skills/git-setup-skill/) | Expert skill for professional Git/GitHub repository setup: `.gitignore`, `.gitattributes`, README files, licensing, metadata, tags, releases, and GitHub Actions. |
| [swarm-forge-skill](skills/swarm-forge-skill/) | Guided project context setup for multi-CLI agent workflows across Claude Code, Codex, OpenCode, and Gemini CLI using patterns like TDD, BDD, ATDD, and SDD. |
| [path-context-skill](skills/path-context-skill/) | Behavioral protocol for registering external project folders as reference context, with a 6-pass discovery heuristic and strict per-turn token budget. |
| [api-test-skill](skills/api-test-skill/) | Protocol-first, client-agnostic skill for testing REST APIs end-to-end from the terminal. Detects OS and HTTP client automatically, constructs requests with env var references for secrets, interprets responses, infers auth and Content-Type, diagnoses errors, supports request chaining and response assertions. |

## Install

### Install the complete skills kit

Install all skills with a single command:

```bash
npx skills add fxckcode/skills-kit
```

This will download and install the complete skills kit including:

- **git-setup-skill**: Professional Git/GitHub repository setup: `.gitignore`, `.gitattributes`, README files, licensing, metadata, tags, releases, and GitHub Actions
- **swarm-forge-skill**: Guided project context setup for multi-CLI agent workflows across Claude Code, Codex, OpenCode, and Gemini CLI using patterns like TDD, BDD, ATDD, and SDD
- **path-context-skill**: Behavioral protocol for registering external project folders as reference context, with a 6-pass discovery heuristic and strict per-turn token budget
- **api-test-skill**: Protocol-first, client-agnostic skill for testing REST APIs end-to-end from the terminal

### Install individual skills (optional)

If you only need a specific skill, you can install it individually:

```bash
npx skills add fxckcode/skills-kit/skills/git-setup-skill
npx skills add fxckcode/skills-kit/skills/swarm-forge-skill
npx skills add fxckcode/skills-kit/skills/path-context-skill
npx skills add fxckcode/skills-kit/skills/api-test-skill
```

This will automatically download and install the skill to the appropriate agent skills directory.

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
    ├── api-test-skill/
    ├── git-setup-skill/
    ├── path-context-skill/
    └── swarm-forge-skill/
```

Only the repository root has a `.git/` folder. Individual skills do not carry their own git history inside this repo.

## License

MIT — see [LICENSE](LICENSE).
