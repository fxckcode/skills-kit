#!/usr/bin/env bash

set -euo pipefail

TARGET_DIR="${1:-.}"
CLI_TARGET="${2:-claude}"
PATTERN="${3:-full}"
CONTEXT_DIR="${4:-}"

write_if_missing() {
  local file_path="$1"
  local content="$2"

  if [ -e "$file_path" ]; then
    printf 'Skipped existing file %s\n' "$file_path"
    return
  fi

  mkdir -p "$(dirname "$file_path")"
  printf '%s' "$content" > "$file_path"
  printf 'Created %s\n' "$file_path"
}

resolve_context_dir() {
  if [ -n "$CONTEXT_DIR" ]; then
    printf '%s' "$CONTEXT_DIR"
    return
  fi

  case "$CLI_TARGET" in
    claude) printf '.claude' ;;
    codex) printf '.codex' ;;
    opencode) printf '.opencode' ;;
    gemini) printf '.gemini' ;;
    multi) printf '' ;;
    *) printf '' ;;
  esac
}

write_claude_entrypoint() {
  local base_dir="$1"
  write_if_missing "$TARGET_DIR/CLAUDE.md" "# Project Context for AI Agents

## Project Overview

[Summarize what this project does and why it exists.]

## Workflow Summary

<!-- swarm-forge:workflow-summary:start -->
Run `scripts/update-workflow-summary.sh "$TARGET_DIR" claude "$base_dir"` after scaffolding or agent changes.
<!-- swarm-forge:workflow-summary:end -->

## Tech Stack

See \`$base_dir/knowledge/tech-stack.md\`.

## Documentation Map

### Always Read First

- \`$base_dir/knowledge/critical-constraints.md\`

### Load As Needed

- \`$base_dir/knowledge/architecture-overview.md\`
- \`$base_dir/knowledge/business-vision.md\`
- \`$base_dir/knowledge/folder-structure.md\`
- \`$base_dir/knowledge/tech-stack.md\`

### Rules

- \`$base_dir/rules/code-style.md\`

## Agent Setup

- Agent scaffolding is optional. Confirm whether project agents should exist before creating or relying on them.
- If agents exist, document them here and keep the list current.
- Claude subagents live in \`$base_dir/agents/\`.

## Workspace Map

- \`$base_dir/knowledge/\`: durable project context and reference docs
- \`$base_dir/rules/\`: non-negotiable coding and workflow rules
- \`$base_dir/agents/\`: Claude subagents for this repository when enabled
- \`$base_dir/commands/\`: Claude slash command helpers when present
- \`$base_dir/plans/\`: implementation plans for multi-step work when enabled
- \`$base_dir/tasks/\`: task state and handoff notes when enabled
- \`$base_dir/specs/\`: structured specs when the workflow uses SDD or similar
- \`$base_dir/scenarios/\`: scenario artifacts for BDD-style work when used
- \`$base_dir/acceptance/\`: acceptance criteria and acceptance-test artifacts when used
"
}

write_codex_entrypoint() {
  local base_dir="$1"
  write_if_missing "$TARGET_DIR/AGENTS.md" "# Project Instructions

## Project Overview

[Summarize what this project does and why it exists.]

## Workflow Summary

<!-- swarm-forge:workflow-summary:start -->
Run `scripts/update-workflow-summary.sh "$TARGET_DIR" codex "$base_dir"` after scaffolding changes.
<!-- swarm-forge:workflow-summary:end -->

## Read First

- \`$base_dir/knowledge/critical-constraints.md\`
- \`$base_dir/rules/code-style.md\`

## Codex Context Directory

- \`$base_dir/\`

Use the files in this directory as the primary source of truth for rules, plans, tasks, specs, scenarios, and acceptance artifacts.

## Agent Setup

- Agent scaffolding is optional. Ask before creating project-specific agents or agent role documents.
- If the repository defines project agents, list them here and keep the inventory current.

## Workspace Map

- \`$base_dir/knowledge/\`: durable project context and reference docs
- \`$base_dir/rules/\`: non-negotiable coding and workflow rules
- \`$base_dir/plans/\`: implementation plans for multi-step work when enabled
- \`$base_dir/tasks/\`: task state and handoff notes when enabled
- \`$base_dir/specs/\`: structured specs when the workflow uses SDD or similar
- \`$base_dir/scenarios/\`: scenario artifacts for BDD-style work when used
- \`$base_dir/acceptance/\`: acceptance criteria and acceptance-test artifacts when used
"
}

write_gemini_entrypoint() {
  local base_dir="$1"
  write_if_missing "$TARGET_DIR/GEMINI.md" "# Project Instructions

## Project Overview

[Summarize what this project does and why it exists.]

## Workflow Summary

<!-- swarm-forge:workflow-summary:start -->
Run `scripts/update-workflow-summary.sh "$TARGET_DIR" gemini "$base_dir"` after scaffolding changes.
<!-- swarm-forge:workflow-summary:end -->

## Read First

- \`$base_dir/knowledge/critical-constraints.md\`
- \`$base_dir/rules/code-style.md\`

## Gemini Context Directory

- \`$base_dir/\`

## Agent Setup

- Agent scaffolding is optional. Record any agreed agent roles here if this repository adopts them.

## Workspace Map

- \`$base_dir/knowledge/\`: durable project context and reference docs
- \`$base_dir/rules/\`: non-negotiable coding and workflow rules
- \`$base_dir/plans/\`: implementation plans for multi-step work when enabled
- \`$base_dir/tasks/\`: task state and handoff notes when enabled
- \`$base_dir/specs/\`: structured specs when the workflow uses SDD or similar
- \`$base_dir/scenarios/\`: scenario artifacts for BDD-style work when used
- \`$base_dir/acceptance/\`: acceptance criteria and acceptance-test artifacts when used
"
}

write_opencode_entrypoint() {
  local base_dir="$1"
  write_if_missing "$TARGET_DIR/AGENTS.md" "# Project Instructions

## Project Overview

[Summarize what this project does and why it exists.]

## Workflow Summary

<!-- swarm-forge:workflow-summary:start -->
Run `scripts/update-workflow-summary.sh "$TARGET_DIR" opencode "$base_dir"` after scaffolding or agent changes.
<!-- swarm-forge:workflow-summary:end -->

## OpenCode Agent Extensions

- \`.opencode/agents/\`
- \`.opencode/skills/\`

## OpenCode Context Directory

- \`$base_dir/\`

## Agent Setup

- Agent scaffolding is optional. Confirm whether to create project agents before adding files under \`.opencode/agents/\`.
- If project agents exist, list them here and keep the inventory current.

## Workspace Map

- \`$base_dir/agents/\`: OpenCode project agents when enabled
- \`$base_dir/skills/\`: OpenCode skills and reusable automations
- \`$base_dir/knowledge/\`: durable project context and reference docs
- \`$base_dir/rules/\`: non-negotiable coding and workflow rules
- \`$base_dir/plans/\`: implementation plans for multi-step work when enabled
- \`$base_dir/tasks/\`: task state and handoff notes when enabled
- \`$base_dir/specs/\`: structured specs when the workflow uses SDD or similar
- \`$base_dir/scenarios/\`: scenario artifacts for BDD-style work when used
- \`$base_dir/acceptance/\`: acceptance criteria and acceptance-test artifacts when used
"

  write_if_missing "$TARGET_DIR/opencode.json" "{
  \"\$schema\": \"https://opencode.ai/config.json\",
  \"theme\": \"system\"
}
"
}

write_context_tree() {
  local base_dir="$1"

  write_if_missing "$TARGET_DIR/$base_dir/knowledge/critical-constraints.md" "# Critical Constraints

## Architecture

- Read and understand existing code before making changes.

## Code Quality

- Use the repository's real lint, format, and test commands.
- Do not commit secrets.

## Agent Workflow

- Keep context files concise and searchable.
- Preserve user-authored content unless the user explicitly asks to replace it.
"

  write_if_missing "$TARGET_DIR/$base_dir/knowledge/architecture-overview.md" "# Architecture Overview

## Application Type

[Describe the type of application.]

## High-Level Structure

[Describe the main modules and boundaries.]
"

  write_if_missing "$TARGET_DIR/$base_dir/knowledge/tech-stack.md" "# Tech Stack

## Core

- Runtime: [Detect from repository]
- Language: [Detect from repository]
- Package manager: [Detect from repository]

## Commands

\`\`\`bash
# Add the repository's real build, test, and lint commands
\`\`\`
"

  write_if_missing "$TARGET_DIR/$base_dir/knowledge/business-vision.md" "# Business Vision

## Purpose

[Describe the problem this project solves.]

## Success Criteria

- [Define how success is measured]
"

  write_if_missing "$TARGET_DIR/$base_dir/knowledge/folder-structure.md" "# Folder Structure

## AI Workflow Layout

[Document the selected folder strategy for this repository.]

## Workflow Summary

<!-- swarm-forge:workflow-summary:start -->
Run `scripts/update-workflow-summary.sh "$TARGET_DIR" $CLI_TARGET "$base_dir"` after workflow changes.
<!-- swarm-forge:workflow-summary:end -->

## Recommended Entries To Keep Updated

- \`$base_dir/knowledge/\`: durable project context and reference docs
- \`$base_dir/rules/\`: non-negotiable coding and workflow rules
- \`$base_dir/agents/\`: project agents when the user enabled agent scaffolding
- \`$base_dir/commands/\`: tool-specific command helpers when supported
- \`$base_dir/skills/\`: tool-specific skills when supported
- \`$base_dir/plans/\`: implementation plans for multi-step work when enabled
- \`$base_dir/tasks/\`: task state and handoff notes when enabled
- \`$base_dir/specs/\`: structured specs when the workflow uses SDD or similar
- \`$base_dir/scenarios/\`: scenario artifacts for BDD-style work when used
- \`$base_dir/acceptance/\`: acceptance criteria and acceptance-test artifacts when used
"

  write_if_missing "$TARGET_DIR/$base_dir/rules/code-style.md" "# Code Style Rules

## General

- Follow existing patterns in the repository.
- Prefer small, focused changes.
- Use the repository's configured formatter and linter.
"

  if [ -d "$TARGET_DIR/$base_dir/agents" ]; then
    write_if_missing "$TARGET_DIR/$base_dir/agents/README.md" "# Agents

Create files in this directory only if the user explicitly wants project agents.
Keep the entrypoint file in sync with any agents added here.
"
  fi

  if [ -d "$TARGET_DIR/$base_dir/commands" ]; then
    write_if_missing "$TARGET_DIR/$base_dir/commands/README.md" "# Commands

Use this directory for tool-specific command helpers when the selected CLI supports them.
"
  fi

  if [ -d "$TARGET_DIR/$base_dir/skills" ]; then
    write_if_missing "$TARGET_DIR/$base_dir/skills/README.md" "# Skills

Use this directory for reusable tool-specific skills when the selected CLI supports them.
"
  fi

  if [ "$PATTERN" = "full" ] || [ "$PATTERN" = "collaborative" ]; then
    write_if_missing "$TARGET_DIR/$base_dir/plans/README.md" "# Plans

Use this directory for implementation plans and execution sequencing.
"
    write_if_missing "$TARGET_DIR/$base_dir/tasks/README.md" "# Tasks

Use this directory for session context, handoffs, and execution tracking.
"
    write_if_missing "$TARGET_DIR/$base_dir/specs/README.md" "# Specs

Use this directory for structured requirements and feature specifications.
"
    write_if_missing "$TARGET_DIR/$base_dir/scenarios/README.md" "# Scenarios

Use this directory for behavior-driven scenarios and examples.
"
    write_if_missing "$TARGET_DIR/$base_dir/acceptance/README.md" "# Acceptance

Use this directory for acceptance criteria and acceptance-test artifacts.
"
  fi
}

write_claude_workflow() {
  local base_dir="$1"
  write_claude_entrypoint "$base_dir"
  write_context_tree "$base_dir"
}

write_codex_workflow() {
  local base_dir="$1"
  write_codex_entrypoint "$base_dir"
  write_context_tree "$base_dir"
}

write_opencode_workflow() {
  local base_dir="$1"
  write_opencode_entrypoint "$base_dir"
  write_context_tree "$base_dir"
}

write_gemini_workflow() {
  local base_dir="$1"
  write_gemini_entrypoint "$base_dir"
  write_context_tree "$base_dir"
}

write_multi_workflow() {
  write_claude_workflow ".claude"
  write_codex_workflow ".codex"
  write_gemini_workflow ".gemini"
  write_opencode_workflow ".opencode"
}

BASE_DIR="$(resolve_context_dir)"

case "$CLI_TARGET" in
  claude)
    write_claude_workflow "$BASE_DIR"
    ;;
  codex)
    write_codex_workflow "$BASE_DIR"
    ;;
  opencode)
    write_opencode_workflow "$BASE_DIR"
    ;;
  gemini)
    write_gemini_workflow "$BASE_DIR"
    ;;
  multi)
    write_multi_workflow
    ;;
  *)
    printf 'Unsupported CLI target: %s\n' "$CLI_TARGET" >&2
    printf 'Supported targets: claude, codex, opencode, gemini, multi\n' >&2
    exit 1
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$CLI_TARGET" in
  claude|codex|opencode|gemini)
    "$SCRIPT_DIR/update-workflow-summary.sh" "$TARGET_DIR" "$CLI_TARGET" "$BASE_DIR"
    ;;
  multi)
    "$SCRIPT_DIR/update-workflow-summary.sh" "$TARGET_DIR" claude ".claude"
    "$SCRIPT_DIR/update-workflow-summary.sh" "$TARGET_DIR" codex ".codex"
    "$SCRIPT_DIR/update-workflow-summary.sh" "$TARGET_DIR" gemini ".gemini"
    "$SCRIPT_DIR/update-workflow-summary.sh" "$TARGET_DIR" opencode ".opencode"
    ;;
esac
