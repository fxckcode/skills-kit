# Guided Setup Workflow

Use this workflow when the user asks to prepare a repository for AI-assisted work without using a separate CLI command.

## 1. Repository Inspection

Before or at the beginning of inspection, confirm which CLI or CLIs the user wants to support.

Read the smallest set of files needed to establish facts:

- `package.json`, lockfiles, `tsconfig.json`, `pyproject.toml`, `go.mod`, etc.
- top-level README and existing docs
- main source entrypoints
- test and lint configuration
- existing `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.claude/`, or `.opencode/` files if present

Extract:

- selected or implied CLI targets
- project type
- language/runtime
- package manager
- commands
- architecture hints
- conventions already present in code

## 2. Gap Detection

Build a short list of unknowns. Ask only questions that materially improve the setup. Avoid asking for information already discoverable in the repo.

Good examples:

- “Which CLI or CLIs do you want this repository to support: Claude Code, Codex, OpenCode, Gemini CLI, or a combination?”
- “What is the primary goal of this project?”
- “Do you want a lightweight setup or a full knowledge base?”
- “Which agents do you want available from day one?”

Bad examples:

- asking for the language when `package.json` and `tsconfig.json` already answer it
- asking for the package manager when lockfiles answer it

Also determine whether the user needs a `full`, `collaborative`, `lean`, or `knowledge-first` pattern. If the intent is still ambiguous after repo inspection, ask.
Also determine whether the user needs `TDD`, `BDD`, `ATDD`, or `SDD`.
Also determine whether the user actually wants agent scaffolding created now. If the answer is not explicit, ask before creating agent definitions or presenting agents as part of the setup.

## 3. Plan The Output

Decide:

- which CLI targets must be supported
- which integration pattern is appropriate
- which development pattern is appropriate
- whether to create a new `CLAUDE.md` or merge into an existing one
- which shared knowledge files are justified
- whether agents should exist yet at all
- which agents should exist if the user opts in
- whether `tasks/` and `plans/` are needed

When the repo already has context files, provide a short pre-edit summary.

## 4. Apply Changes

Preferred behavior:

- create missing directories by running `scripts/create-workflow-folders.sh` with the selected pattern when the base workflow structure is absent
- when agent creation is not explicitly enabled, pass `no` to the folder scaffold so `agents/` is not created implicitly
- create missing base files by running `scripts/scaffold-base-files.sh` with the selected target and pattern when entrypoint files or core workflow files are absent
- create missing files
- merge missing sections into target-specific entrypoint files
- avoid rewriting user content unless clearly requested
- refresh `CLAUDE.md`, `AGENTS.md`, and `GEMINI.md` so they describe the actual agents and folders that now exist

Use concise content grounded in the repo. Replace generic placeholders with detected facts whenever possible.
Prefer a deterministic refresh step such as `scripts/update-workflow-summary.sh` after scaffolding so the documented agent list and folder map reflect the workspace that actually exists.
When possible, encode the selected development pattern into agent definitions, rules, plans, test layout, and task handoff guidance rather than only mentioning it abstractly.
For `SDD`, make sure the generated context includes specs, plans, tasks, and structured document loading.
For `BDD`, make sure scenarios and Given/When/Then style artifacts are visible.
For `ATDD`, make sure acceptance criteria and acceptance-test artifacts are explicit.
For `TDD`, make sure unit-test locations and fast feedback commands are explicit.
For multi-CLI setups, prefer one visible context namespace per CLI and thin target-specific entrypoint files.

## 5. Final Report

Always report:

- created files
- updated files
- skipped files
- whether agent creation was enabled or intentionally skipped
- assumptions
- unresolved items requiring user input

If you leave placeholders, explain why they remain placeholders.
