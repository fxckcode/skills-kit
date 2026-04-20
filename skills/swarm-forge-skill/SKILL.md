---
name: swarm-forge-skill
description: >
  Sets up or refines repository AI workflow context across multiple CLI targets and four development patterns: TDD, BDD, ATDD, and SDD. Use when the user says things like "set up this repo for Claude Code", "set up this repo for Codex", "prepare the agent workflow", "add a TDD setup", "make this BDD-friendly", "set up ATDD", "set up spec driven development", or "review this project and scaffold the context files". It inspects the repo, chooses or confirms suitable CLI targets, setup patterns, and one of the four supported development patterns, asks only missing setup questions, runs bundled scaffold scripts when needed, and safely merges into existing project context files.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# Swarm Forge Skill

Use this skill when the user wants the repository prepared for agent-based work without invoking a CLI command. The skill should inspect the codebase, ask only the missing setup questions, and then create or update the project context files directly.

## What This Skill Owns

- Repository inspection before writing anything
- Guided setup for target-specific entrypoint files such as `CLAUDE.md`, `AGENTS.md`, and `GEMINI.md`
- Safe creation of target-specific workspace files and shared workflow artifacts
- Refinement of existing setup instead of blind overwrite
- Converting vague user intent into a concrete project context scaffold

## Primary Use Cases

- User asks to set up project instruction files or an agent workflow for a repository.
- User wants the setup to support one or more coding CLIs such as Claude Code, Codex, OpenCode, or Gemini CLI.
- User wants the repo reviewed first and then scaffolded based on the real stack.
- User wants a guided setup with a few clarifying questions instead of invoking a CLI command.
- User wants either a full workflow, a lightweight setup, or a knowledge-only starting point.
- User wants one of these development patterns encoded in the repository: `TDD`, `BDD`, `ATDD`, or `SDD`.

## Target Model

Do not assume a single CLI by default when the user is asking for a reusable setup. The skill should support one or more of these targets:

- `Claude Code`
- `Codex`
- `OpenCode`
- `Gemini CLI`

The scripts also accept a `multi` target for multi-CLI folder creation; this is a script convenience, not a CLI itself.

When the user wants more than one target, prefer:

- one visible context namespace per CLI
- one thin entrypoint file per CLI
- tool-specific folders only where the CLI actually supports them

## Supported Patterns

These are setup structure patterns, not development patterns.

- `full`: complete workflow with entrypoint files, knowledge, rules, plans, and tasks, plus optional agents when the user opts in
- `collaborative`: same structure as `full`, preferred when the user explicitly wants plans and persistent task context, with optional agents when the user opts in
- `lean`: lightweight setup with entrypoint files, knowledge, and rules
- `knowledge-first`: repository memory first, focused on `knowledge/` without forcing the full workflow

Pattern selection rules:

- If the user explicitly names a pattern or describes one clearly, use it.
- If the repo already contains partial context files, extend the nearest matching pattern instead of forcing a new one.
- If the user asks for minimal setup, prefer `lean`.
- If the user asks for documentation or institutional memory first, prefer `knowledge-first`.
- Otherwise default to `full`.

## Supported Development Patterns

- `TDD`: test-driven development centered on fast unit-test feedback loops before implementation
- `BDD`: behavior-driven development centered on shared understanding and scenario-based behavior descriptions
- `ATDD`: acceptance-test-driven development centered on acceptance criteria and stakeholder collaboration before implementation
- `SDD`: spec-driven development centered on specs as the source of implementation context, often using structured artifacts such as specs, plans, and tasks

Pattern selection rules:

- If the user names one of these patterns, preserve it.
- If the user wants unit tests to drive implementation, prefer `TDD`.
- If the user wants user behavior and Given/When/Then scenarios, prefer `BDD`.
- If the user wants acceptance criteria written collaboratively before implementation, prefer `ATDD`.
- If the user wants specs, plans, and structured context as the primary source of truth, prefer `SDD`.

## Workflow

For complex setups, copy this checklist into the working notes and mark progress as you go:

- Confirm target CLI or CLIs
- Inspect repository
- Detect stack and existing context files
- Select or confirm integration pattern
- Select or confirm development pattern
- Decide whether agent scaffolding should be created at all
- Ask only missing questions
- Run folder setup script if needed
- Run base file scaffold script if needed
- Create or update context files
- Report created, updated, skipped, and assumptions

1. Ask which CLI or CLIs the repository should support unless the answer is already explicit and unambiguous.
2. Inspect the repository.
3. Identify facts from source files:
   - app type
   - language/runtime
   - package manager
   - test/lint/format commands
   - existing docs and conventions
4. Check which target-specific files already exist, such as `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.claude/`, `.opencode/`, and `.gemini/`.
5. Choose the integration pattern that best fits the repo and the user request.
6. Choose the development pattern that best fits the repo and the user request.
7. Decide whether initial agent scaffolding should be created. If the user did not explicitly ask for agents and the repo does not already contain them, ask whether they want no agents, only the minimum core agents, or a custom initial set. Do not silently create agent files just because a pattern supports them.
8. Ask only the missing high-value questions, including pattern confirmation when uncertain.
9. Summarize the intended setup before major edits when the repo already contains agent context files.
10. If the workflow directories do not exist yet, run `scripts/create-workflow-folders.sh` from the skill directory with the selected CLI target and pattern instead of recreating the directory creation logic manually.
11. If the base context files do not exist yet, run `scripts/scaffold-base-files.sh` from the skill directory with the selected CLI target and pattern to create the initial files that fit that target.
12. Create or update the setup files, including pattern-specific guidance inside the generated context where appropriate.
13. Refresh target-specific entrypoint files after scaffolding so they reflect the actual current state of the workspace. Document:
   - which agents exist now
   - whether agent creation was intentionally skipped
   - which key folders exist in `.claude/`, `.codex/`, `.opencode/`, or `.gemini/`
   - what each documented folder is for
14. For multi-CLI setups, keep one visible context namespace per CLI and create thin target-specific entrypoint files.
15. Report what was created, what was updated, which CLI targets were selected, what setup pattern was chosen, what development pattern was chosen, and what still needs human input.

## Required Questions

Ask these only when they cannot be inferred with confidence:

- What is the project trying to achieve?
- Which CLI or CLIs should this repository support?
- Which integration pattern fits best: full, collaborative, lean, or knowledge-first?
- Which development pattern fits best for this repository and team: TDD, BDD, ATDD, or SDD?
- Do you want this setup to create initial agents now, or leave agent scaffolding out for the moment?
- If agents should be created, which specialized agents should exist initially?
- What rules are non-negotiable for changes in this repo?
- Should session context and implementation plans be part of the workflow?

Optional follow-ups:

- Are there architecture constraints not obvious from the codebase?
- Are there business terms or domain rules that should be captured immediately?
- Should the setup be minimal or comprehensive?

## Writing Rules

- Prefer facts extracted from the repo over placeholders.
- Do not overwrite user-authored sections blindly.
- Merge by sections when updating target-specific entrypoint files.
- Keep knowledge files concise and searchable.
- If a fact is uncertain, label it as an assumption or ask.
- If the repo already contains a better source of truth, reference it instead of duplicating it.

## File Strategy

### Entrypoint Files

Create or update:

- Project overview
- Tech stack reference
- Documentation map
- Rules reference
- Agent list
- Agent creation policy summary
- Workspace folder map
- Key constraints summary
- Command quick reference

Use the appropriate file for each selected CLI:

- `CLAUDE.md` for Claude Code
- `AGENTS.md` for Codex
- `AGENTS.md` plus `.opencode/` extensions for OpenCode
- `GEMINI.md` for Gemini CLI

For multi-CLI setups, keep these files short and point them to shared workflow artifacts.

### Shared Knowledge And Workflow Artifacts

Create only the files that are justified by the repository and user answers. Prefer this initial set:

- `critical-constraints.md`
- `architecture-overview.md`
- `tech-stack.md`
- `business-vision.md`
- `folder-structure.md`

These should live inside the selected CLI namespace, for example:

- `.claude/knowledge/`
- `.codex/knowledge/`
- `.opencode/knowledge/`
- `.gemini/knowledge/`

### Agent Definitions

Create agents only when the user explicitly asks for them or agrees to an initial core set.
If the user prefers not to create agents yet, keep the workflow documentation explicit about that choice and do not create agent definition files just because the directory exists.
Shape the initial agent set according to the selected development pattern.
For `SDD`, prefer a role set that can maintain specs, plans, and shared project knowledge.

Place them according to target:

- `.claude/agents/` for Claude Code
- `.opencode/agents/` for OpenCode
- shared docs plus `AGENTS.md` references for Codex
- shared docs plus `GEMINI.md` references for Gemini CLI

### Rules

Create `code-style.md` when the repo has enough evidence to describe conventions or when the user wants it scaffolded.

### Tasks And Plans

Create the session protocol only if the user wants persistent task context or if the setup is meant for multi-step collaboration.
Create the directory when agent planning is part of the intended workflow.

For multi-CLI setups, prefer per-target locations such as:

- `.claude/plans/`, `.claude/tasks/`, `.claude/specs/`, `.claude/scenarios/`, `.claude/acceptance/`
- `.codex/plans/`, `.codex/tasks/`, `.codex/specs/`, `.codex/scenarios/`, `.codex/acceptance/`
- `.opencode/plans/`, `.opencode/tasks/`, `.opencode/specs/`, `.opencode/scenarios/`, `.opencode/acceptance/`
- `.gemini/plans/`, `.gemini/tasks/`, `.gemini/specs/`, `.gemini/scenarios/`, `.gemini/acceptance/`

Adapt the output to the selected pattern instead of always forcing the full directory set.
Also adapt the output to the selected CLI targets instead of assuming Claude-only scaffolding.
After the directory structure is in place, update the relevant entrypoint files so they describe the real folders that exist and what each one is used for.

Also adapt the file contents to the selected development pattern. For example:

- `TDD`: emphasize unit test locations, red-green-refactor, and framework-specific test commands
- `BDD`: emphasize user behavior, scenarios, Given/When/Then structure, and cross-role collaboration
- `ATDD`: emphasize acceptance criteria, stakeholder collaboration, and acceptance test artifacts
- `SDD`: emphasize specs, plans, tasks, and structured context artifacts as the main execution anchor

## Script Usage

When the repository is missing the base workflow folders, execute this bundled script from the skill directory:

```bash
scripts/create-workflow-folders.sh [target_dir] [cli_target] [pattern] [context_dir] [create_agents]
```

Default behavior:

- `target_dir`: current working directory
- `cli_target`: `claude`
- `pattern`: `full`
- `context_dir`: target default such as `.claude`, `.codex`, `.opencode`, or `.gemini`
- `create_agents`: `yes` or `no`

Use the script instead of reproducing the folder creation step manually. Override `context_dir` when the repository already uses a custom namespace.
When the user has not opted into agents, pass `no` so the folder layout does not imply agents that were never requested.

When the repository is missing the base context files, execute this bundled script from the skill directory:

```bash
scripts/scaffold-base-files.sh [target_dir] [cli_target] [pattern] [context_dir]
```

Default behavior:

- `target_dir`: current working directory
- `cli_target`: `claude`
- `pattern`: `full`
- `context_dir`: target default such as `.claude`, `.codex`, `.opencode`, or `.gemini`

This script only creates missing base files. It does not overwrite existing content. Use it to bootstrap the repository before making targeted edits, and override `context_dir` when the repository already uses a custom namespace.

After scaffolding or after any later agent/folder changes, run:

```bash
scripts/update-workflow-summary.sh [target_dir] [cli_target] [context_dir]
```

Use it to refresh the summary blocks inside `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, and `knowledge/folder-structure.md` so they match the current workspace state.

## When To Read References

- Read `references/cli-targets.md` first when the user wants one or more CLI targets supported.
- Read `references/workflow.md` when running the guided setup flow.
- Read `references/pattern-matrix.md` when mapping a requested pattern to folders, files, and setup scope.
- Read `references/pattern-research.md` when the user wants deeper justification or ecosystem grounding for a pattern choice.
- Read `references/patterns.md` when choosing the setup structure pattern.
- Read `references/orchestration-patterns.md` when choosing between TDD, BDD, ATDD, and SDD.
- Read `references/testing.md` when validating whether the skill triggers and completes the workflow reliably.

## Implementation Guidance

If you need deterministic generation or repeated file updates, prefer reusable scripts over rewriting the same logic inline every time.

## Success Criteria

- The skill activates for common setup requests without needing explicit naming.
- The workflow completes without the user having to specify the next step manually.
- The repository ends with the correct entrypoint files and folder structure for the selected CLI targets.
- Agent creation is treated as an explicit setup choice instead of an automatic side effect.
- Entrypoint files reflect the actual agents and workspace folders that exist after the run.
- The setup matches the requested or inferred development pattern instead of only scaffolding folders.
- Existing context files are extended safely instead of being overwritten carelessly.

## Output Expectations

At the end of the run:

- list created files
- list updated files
- list skipped files
- state selected setup pattern
- state selected development pattern
- call out assumptions
- identify any placeholders the user should complete later
