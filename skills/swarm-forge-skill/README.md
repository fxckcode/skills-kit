# swarm-forge-skill

[![Release](https://img.shields.io/github/v/release/fxckcode/swarm-forge-skill?sort=semver)](https://github.com/fxckcode/swarm-forge-skill/releases)
[![License](https://img.shields.io/github/license/fxckcode/swarm-forge-skill)](LICENSE)
[![Last Commit](https://img.shields.io/github/last-commit/fxckcode/swarm-forge-skill)](https://github.com/fxckcode/swarm-forge-skill/commits/master)

Current version: v0.1.6

Guided project context setup for multi-CLI agent workflows. This skill inspects a repo, asks only missing questions, and scaffolds or refines context files for Claude Code, Codex, OpenCode, and Gemini CLI using patterns like SDD, TDD, BDD, and ATDD.

## Purpose

The skill is intended to replace the old CLI-driven setup flow with a guided repository setup workflow that:

- reviews the codebase first
- asks only the missing questions
- creates or updates target-specific entrypoint files such as `CLAUDE.md`, `AGENTS.md`, and `GEMINI.md`
- creates CLI-specific folders and shared workflow directories when needed
- refines project context files safely instead of overwriting them blindly

## Skill Files

- `SKILL.md`
- `references/patterns.md`
- `references/orchestration-patterns.md`
- `references/cli-targets.md`
- `references/pattern-matrix.md`
- `references/pattern-research.md`
- `references/workflow.md`
- `references/testing.md`
- `scripts/create-workflow-folders.sh`
- `scripts/scaffold-base-files.sh`
- `scripts/update-workflow-summary.sh`

## Install

Copy this folder into your skills directory. Example:

```bash
cp -R swarm-forge-skill "$HOME/.agents/skills/swarm-forge-skill"
```

Then reference the skill in your agent tooling according to your CLI setup.

### Install into agent folders

If you want the skill files available from a specific agent workspace (any folder that contains your CLI agent configuration, such as `.claude/`, `.opencode/`, or other agent folders), clone the repo and copy it into that agent directory.

Example (generic path):

```bash
git clone https://github.com/fxckcode/swarm-forge-skill.git
cp -R swarm-forge-skill /path/to/your/workspace/<agent-folder>/skills/swarm-forge-skill
```

Examples (common agent folders):

```bash
cp -R swarm-forge-skill /path/to/your/workspace/.claude/skills/swarm-forge-skill
cp -R swarm-forge-skill /path/to/your/workspace/.opencode/skills/swarm-forge-skill
```

Use the agent folder that matches your CLI. The skill folder name should remain `swarm-forge-skill`.

## Usage

Trigger phrases include:

- "set up this repo for Claude Code"
- "set up this repo for Codex"
- "prepare the agent workflow"
- "add a TDD setup"
- "set up ATDD"
- "set up spec driven development"

## What it produces

Depending on your choices, the skill creates or refines:

- CLI entrypoints (`CLAUDE.md`, `AGENTS.md`, `GEMINI.md`)
- Context folders like `.claude/`, `.codex/`, `.opencode/`, `.gemini/`
- Optional agent folders only when the user agrees to create agents
- Knowledge and workflow artifacts (rules, plans, tasks, specs, scenarios)
- Refreshed workflow summaries so entrypoints describe the folders and agents that actually exist

It prefers safe merges over overwriting existing content.

## Compatibility

- Scripts require `bash` and `mkdir`.
- On Windows, use WSL or a bash-compatible shell.

## Why this is different

- Pattern-driven setup instead of ad-hoc scaffolds
- Multi-CLI aware with thin entrypoints per target
- Agent creation is explicit instead of being implied by the pattern alone
- Entrypoint summaries can be refreshed deterministically after scaffolding
- Minimal questions, maximum reuse of repo facts

## Contributing

See `CONTRIBUTING.md` for guidelines.

## Next Step

Implement additional reusable scripts under `scripts/` to inspect the repo and tailor the scaffold to the detected stack even more precisely.
