# CLI Targets

Use this reference when the user wants the setup to support one or more coding CLIs instead of assuming Claude Code only.

The skill should treat CLI support as a first-class choice. Ask which CLI or combination of CLIs the user wants unless the repository already makes the answer obvious.

## Supported Targets

### Claude Code

Primary project files and folders:

- `CLAUDE.md`
- `.claude/agents/`
- `.claude/commands/`
- `.claude/settings.json`

Important behavior:

- Claude Code reads project memory from `./CLAUDE.md`
- it also supports user memory at `~/.claude/CLAUDE.md`
- it discovers nested `CLAUDE.md` files under the current subtree as needed
- project subagents live in `.claude/agents/`
- project slash commands live in `.claude/commands/`
- `CLAUDE.md` should mention the current `.claude/` layout and name the project agents that actually exist

Sources:

- [Manage Claude's memory](https://docs.anthropic.com/en/docs/claude-code/memory)
- [Claude Code settings](https://docs.anthropic.com/en/docs/claude-code/settings)
- [Subagents](https://docs.anthropic.com/en/docs/claude-code/sub-agents)
- [Slash commands](https://docs.anthropic.com/en/docs/claude-code/slash-commands)

### Codex

Primary project files and folders:

- `AGENTS.md`
- optional `AGENTS.override.md`
- recommended local namespace such as `.codex/`

Important behavior:

- Codex can be guided by `AGENTS.md`
- Codex can also load `AGENTS.override.md`
- Codex walks from the git or project root toward the current working directory and can merge instructions from those files
- keep `AGENTS.md` short and point it at a project-local context namespace such as `.codex/`
- `AGENTS.md` should summarize the current `.codex/` workspace map and any project-defined agent roles the repo expects humans or tools to use

Recommended repo shape:

```text
AGENTS.md
.codex/
├── knowledge/
├── rules/
├── plans/
├── tasks/
├── specs/
├── scenarios/
└── acceptance/
```

Sources:

- [Introducing Codex](https://openai.com/index/introducing-codex/)
- [Harness engineering: leveraging Codex in an agent-first world](https://openai.com/index/harness-engineering/)
- [Unrolling the Codex agent loop](https://openai.com/index/unrolling-the-codex-agent-loop/)

### OpenCode

Primary project files and folders:

- `AGENTS.md`
- `.opencode/agents/`
- `.opencode/skills/`
- `opencode.json`

Important behavior:

- `/init` creates an `AGENTS.md` file in the project root
- project-specific agents live in `.opencode/agents/`
- skills can live in `.opencode/skills/`
- OpenCode also supports compatible skill discovery from `.claude/skills/` and `.agents/skills/`
- `AGENTS.md` should call out both `.opencode/agents/` and `.opencode/skills/` and briefly explain the purpose of each populated folder under `.opencode/`

Sources:

- [OpenCode intro](https://opencode.ai/docs/)
- [OpenCode agents](https://opencode.ai/docs/agents/)
- [OpenCode skills](https://opencode.ai/docs/skills)

### Gemini CLI

Primary project files and folders:

- `GEMINI.md`
- `.geminiignore`
- optional `.gemini/` local configuration

Important behavior:

- Gemini CLI supports custom context files through `GEMINI.md`
- Gemini CLI supports excluding files via `.geminiignore`
- Gemini Code Assist and Gemini CLI are related but not identical products; for CLI-oriented project instructions, prefer `GEMINI.md`
- `GEMINI.md` should describe the current `.gemini/` context layout after the scaffold completes

Sources:

- [Gemini CLI repository](https://github.com/google-gemini/gemini-cli)
- [Exclude files from Gemini Code Assist use](https://developers.google.com/gemini-code-assist/docs/create-aiexclude-file)
- [Gemini Code Assist agent mode](https://developers.google.com/gemini-code-assist/docs/agent-mode)

## Multi CLI Strategy

When the user wants more than one CLI supported, prefer this model:

1. Give each CLI its own visible namespace for project context.
2. Create one entrypoint file per target CLI.
3. Keep target-specific instructions short and map-like.
4. Mirror the same conceptual content across targets instead of forcing a neutral shared directory as the primary structure.

Recommended multi-CLI structure:

```text
CLAUDE.md
AGENTS.md
GEMINI.md
.claude/
├── knowledge/
├── rules/
├── plans/
├── tasks/
├── specs/
├── scenarios/
└── acceptance/
.codex/
├── knowledge/
├── rules/
├── plans/
├── tasks/
├── specs/
├── scenarios/
└── acceptance/
.opencode/
├── agents/
├── skills/
├── knowledge/
├── rules/
├── plans/
├── tasks/
├── specs/
├── scenarios/
└── acceptance/
.gemini/
├── knowledge/
├── rules/
├── plans/
├── tasks/
├── specs/
├── scenarios/
└── acceptance/
```

Interpretation:

- `CLAUDE.md`, `AGENTS.md`, and `GEMINI.md` are thin entrypoints
- each CLI gets its own visible context tree
- `.claude/` and `.opencode/` also hold tool-specific extensions such as subagents, commands, or skills

## First Question Rule

At the start of a setup flow, ask:

- Which CLI or CLIs should this repository support?

Suggested options:

- Claude Code only
- Codex only
- OpenCode only
- Gemini CLI only
- Claude Code + Codex
- Claude Code + OpenCode
- Claude Code + Gemini CLI
- Codex + OpenCode
- All supported CLIs

If the repo already contains `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.claude/`, or `.opencode/`, use that as a strong signal but still confirm before reshaping the system.
