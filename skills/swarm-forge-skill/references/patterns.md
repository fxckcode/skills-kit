# Supported Integration Patterns

Use this reference when choosing how much workflow structure to introduce into a repository.

## `full`

Use when:

- the user wants a complete Claude Code workflow
- the repository needs full workflow structure and may add specialized agents if the user opts in
- the team wants plans and task context files

Creates:

- `CLAUDE.md`
- `.claude/knowledge/`
- `.claude/rules/`
- `.claude/plans/`
- `.claude/tasks/`

Optional when the user asks for agents:

- `.claude/agents/`

## `collaborative`

Use when:

- the user explicitly wants persistent multi-step collaboration
- plans and task handoffs are central to the workflow

This currently scaffolds the same structure as `full`, but the skill should emphasize `plans/` and `tasks/` when refining the files.
Agent directories remain optional here too and should only be created after explicit user confirmation.

## `lean`

Use when:

- the user wants a lightweight setup
- the repository only needs core context and rules
- the user does not want process-heavy planning files

Creates:

- `CLAUDE.md`
- `.claude/knowledge/`
- `.claude/rules/`

## `knowledge-first`

Use when:

- the user mainly wants institutional memory
- the repository is not ready for a full workflow yet
- documenting constraints and architecture is more important than agent orchestration

Creates:

- `.claude/knowledge/`

## Selection Heuristics

- Prefer the least invasive pattern that still solves the user's goal.
- If the repo already has a partial setup, extend the closest existing pattern.
- If the user asks for "minimal", "simple", or "lightweight", use `lean`.
- If the user asks for "documentation first", "knowledge base", or "institutional memory", use `knowledge-first`.
- If unsure and the user wants full Claude Code support, use `full`.
