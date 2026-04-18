#!/usr/bin/env bash

set -euo pipefail

TARGET_DIR="${1:-.}"
CLI_TARGET="${2:-claude}"
CONTEXT_DIR="${3:-}"

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
    *)
      printf 'Unsupported CLI target: %s\n' "$CLI_TARGET" >&2
      printf 'Supported targets: claude, codex, opencode, gemini\n' >&2
      exit 1
      ;;
  esac
}

entrypoint_path() {
  case "$CLI_TARGET" in
    claude) printf '%s/CLAUDE.md' "$TARGET_DIR" ;;
    codex|opencode) printf '%s/AGENTS.md' "$TARGET_DIR" ;;
    gemini) printf '%s/GEMINI.md' "$TARGET_DIR" ;;
  esac
}

folder_description() {
  case "$1" in
    knowledge) printf 'durable project context and reference docs' ;;
    rules) printf 'non-negotiable coding and workflow rules' ;;
    agents) printf 'project agents for this repository when enabled' ;;
    commands) printf 'tool-specific command helpers' ;;
    skills) printf 'tool-specific reusable skills' ;;
    plans) printf 'implementation plans for multi-step work' ;;
    tasks) printf 'task state and handoff notes' ;;
    specs) printf 'structured specs and feature definitions' ;;
    scenarios) printf 'scenario artifacts for behavior-focused workflows' ;;
    acceptance) printf 'acceptance criteria and acceptance-test artifacts' ;;
    *) printf 'project workflow assets' ;;
  esac
}

supports_folder() {
  local folder="$1"

  case "$CLI_TARGET:$folder" in
    claude:skills|codex:agents|codex:commands|codex:skills|gemini:agents|gemini:commands|gemini:skills)
      return 1
      ;;
    opencode:commands)
      return 1
      ;;
    *)
      return 0
      ;;
  esac
}

collect_agents() {
  local agents_dir="$TARGET_DIR/$BASE_DIR/agents"

  if [ ! -d "$agents_dir" ]; then
    printf '%s\n' "- Agent scaffolding is currently skipped for this target."
    return
  fi

  mapfile -t agent_files < <(find "$agents_dir" -maxdepth 1 -type f ! -name 'README.md' -printf '%f\n' | sort)

  if [ "${#agent_files[@]}" -eq 0 ]; then
    printf '%s\n' "- \`$BASE_DIR/agents/\` exists, but no project agents have been added yet."
    return
  fi

  printf '%s\n' "- Project agents currently present:"
  local agent_file
  for agent_file in "${agent_files[@]}"; do
    printf '%s\n' "- \`$agent_file\`"
  done
}

collect_folders() {
  local folder
  for folder in knowledge rules agents commands skills plans tasks specs scenarios acceptance; do
    if ! supports_folder "$folder"; then
      continue
    fi

    if [ -d "$TARGET_DIR/$BASE_DIR/$folder" ]; then
      printf '%s\n' "- \`$BASE_DIR/$folder/\`: $(folder_description "$folder")"
    fi
  done
}

render_summary_block() {
  cat <<EOF
## Current Workspace State

- Context directory: \`$BASE_DIR/\`
$(collect_agents)

## Active Folder Map

$(collect_folders)
EOF
}

replace_summary_block() {
  local target_file="$1"

  if [ ! -f "$target_file" ]; then
    return
  fi

  local tmp_file
  tmp_file="$(mktemp)"

  awk -v block="$(render_summary_block)" '
    /<!-- swarm-forge:workflow-summary:start -->/ {
      print
      print block
      in_block=1
      next
    }
    /<!-- swarm-forge:workflow-summary:end -->/ {
      in_block=0
      print
      next
    }
    !in_block { print }
  ' "$target_file" > "$tmp_file"

  mv "$tmp_file" "$target_file"
}

BASE_DIR="$(resolve_context_dir)"
ENTRYPOINT_FILE="$(entrypoint_path)"

replace_summary_block "$ENTRYPOINT_FILE"
replace_summary_block "$TARGET_DIR/$BASE_DIR/knowledge/folder-structure.md"

printf 'Updated workflow summary for target %s in %s\n' "$CLI_TARGET" "$TARGET_DIR"
