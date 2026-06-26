# skills-kit

A collection of agent skills for repository setup, multi-CLI agent workflows, intelligent context loading, API testing, supply chain security, codebase auditing, and autonomous agent orchestration.

## Skills

| Skill | Description |
|-------|-------------|
| [git-setup-skill](skills/git-setup-skill/) | Expert skill for professional Git/GitHub repository setup: `.gitignore`, `.gitattributes`, README files, licensing, metadata, tags, releases, and GitHub Actions. |
| [swarm-forge-skill](skills/swarm-forge-skill/) | Guided project context setup for multi-CLI agent workflows across Claude Code, Codex, OpenCode, and Gemini CLI using patterns like TDD, BDD, ATDD, and SDD. |
| [path-context-skill](skills/path-context-skill/) | Behavioral protocol for registering external project folders as reference context, with a 6-pass discovery heuristic and strict per-turn token budget. |
| [api-test-skill](skills/api-test-skill/) | Protocol-first, client-agnostic skill for testing REST APIs end-to-end from the terminal. Detects OS and HTTP client automatically, constructs requests with env var references for secrets, interprets responses, infers auth and Content-Type, diagnoses errors, supports request chaining and response assertions. |
| [npm-supply-chain-security](skills/npm-supply-chain-security/) | Three-layer npm supply chain security: consumer basics (ignore-scripts, cooldown), PNPM hardening (strictDepBuilds, lockfile-lint), and publisher best practices (OIDC, Provenance, Trusted Publishers, 2FA). |
| [verification-loop](skills/verification-loop/) | Structured 7-phase verification system for code changes: Build → Type → Lint → Test → Spec → Security → Smoke. Also works as an audit tool for existing projects. |
| [go-quality](skills/go-quality/) | Go project quality standards — linting, race detection, CI setup, error wrapping, context propagation, config hygiene, and test isolation. Production-grade Go patterns. |
| [env-secrets-management](skills/env-secrets-management/) | Manage .env files, API keys, and sensitive configuration values — including workarounds for terminal output censorship that corrupts secrets in commands and file writes. |
| [codebase-audit](skills/codebase-audit/) | Systematic codebase audit — PRD/SDD gap analysis, architecture review, code quality assessment, and migration readiness checks. Produces evidence-based gap tables and actionable verdicts. |
| [loop-engineering](skills/loop-engineering/) | Design and implement autonomous agent loops for multi-agent software development. Maker-checker split, nested SDD cycles, worktree isolation, 3-layer verification, and 7-dimension AI code review. |

## Install

### Install the complete skills kit

Install all skills with a single command:

```bash
npx skills add fxckcode/skills-kit
```



### Install individual skills (optional)

If you only need a specific skill, you can install it individually:

```bash
npx skills add fxckcode/skills-kit/skills/git-setup-skill
npx skills add fxckcode/skills-kit/skills/swarm-forge-skill
npx skills add fxckcode/skills-kit/skills/path-context-skill
npx skills add fxckcode/skills-kit/skills/api-test-skill
npx skills add fxckcode/skills-kit/skills/npm-supply-chain-security
npx skills add fxckcode/skills-kit/skills/verification-loop
npx skills add fxckcode/skills-kit/skills/go-quality
npx skills add fxckcode/skills-kit/skills/env-secrets-management
npx skills add fxckcode/skills-kit/skills/codebase-audit
npx skills add fxckcode/skills-kit/skills/loop-engineering
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
    ├── codebase-audit/
    ├── env-secrets-management/
    ├── git-setup-skill/
    ├── go-quality/
    ├── loop-engineering/
    ├── npm-supply-chain-security/
    ├── path-context-skill/
    ├── swarm-forge-skill/
    └── verification-loop/
```

Only the repository root has a `.git/` folder. Individual skills do not carry their own git history inside this repo.

## License

MIT — see [LICENSE](LICENSE).
