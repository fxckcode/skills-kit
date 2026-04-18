# Testing The Skill

Use this reference when validating whether the skill is well-triggered and reliable in practice.

## Trigger Checks

Test at least these prompts:

- "Set up this repo for Claude Code"
- "Set up this repo for Codex"
- "Set up this repo for OpenCode"
- "Set up this repo for Gemini CLI"
- "Set up this repo for Claude Code and Codex"
- "Set up TDD for this repository"
- "Make this repo BDD-friendly"
- "Set up ATDD for this product team"
- "Set up SDD with specs, plans, and tasks"
- "Give me a minimal CLAUDE setup for this repo"
- "Set up only the knowledge base structure for this project"

The skill should activate on most of these prompts without the user needing to mention the skill by name.

## Workflow Checks

For each test run, confirm that the skill:

- asks which CLI or CLIs should be supported unless the answer is already explicit
- inspects the repository before writing files
- asks only questions that are not already answerable from the repo
- selects an appropriate integration pattern or asks when unclear
- selects the correct development pattern or asks when unclear
- runs `scripts/create-workflow-folders.sh` with the selected pattern when the base workflow directories are missing
- runs `scripts/scaffold-base-files.sh` with the selected pattern when the base context files are missing
- creates or updates the expected files
- reports assumptions and unresolved placeholders
- encodes the requested pattern correctly instead of falling back to a generic setup
- does not assume `CLAUDE.md` is always the only entrypoint file

## Quality Checks

The result is strong when:

- the user does not need to tell the skill what step comes next
- file structure is consistent across runs
- `CLAUDE.md` reflects the actual repository instead of generic filler
- existing user-authored content is preserved where appropriate

## Failure Signals

Refine the skill if you observe any of these:

- it fails to trigger on obvious setup requests
- it asks for the language or package manager when those facts are already in the repo
- it manually recreates directory creation logic instead of using the bundled script
- it manually recreates base file scaffolding instead of using the bundled script
- it forces the same integration pattern even when the user asked for a lighter or more documentation-focused setup
- it ignores the user's requested development pattern and always scaffolds the same workflow
- it misses unit-test focus for TDD, scenarios for BDD, acceptance artifacts for ATDD, or specs/plans/tasks for SDD
- it assumes Claude-only scaffolding when the user explicitly asked for Codex, OpenCode, Gemini CLI, or a multi-CLI setup
- it overwrites existing context files without clear justification
