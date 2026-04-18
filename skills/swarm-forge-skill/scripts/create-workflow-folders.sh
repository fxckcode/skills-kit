#!/usr/bin/env bash

set -euo pipefail

TARGET_DIR="${1:-.}"
CLI_TARGET="${2:-claude}"
PATTERN="${3:-full}"
CONTEXT_DIR="${4:-}"
CREATE_AGENTS="${5:-no}"

declare -a DIRS=()

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

append_pattern_dirs() {
  local base_dir="$1"

  case "$PATTERN" in
    full|collaborative)
      DIRS+=(
        "$TARGET_DIR/$base_dir/knowledge"
        "$TARGET_DIR/$base_dir/rules"
        "$TARGET_DIR/$base_dir/plans"
        "$TARGET_DIR/$base_dir/tasks"
      )
      if should_create_agents "$CLI_TARGET"; then
        DIRS+=("$TARGET_DIR/$base_dir/agents")
      fi
      ;;
    lean)
      DIRS+=(
        "$TARGET_DIR/$base_dir/knowledge"
        "$TARGET_DIR/$base_dir/rules"
      )
      ;;
    knowledge-first)
      DIRS+=(
        "$TARGET_DIR/$base_dir/knowledge"
      )
      ;;
    *)
      printf 'Unsupported pattern: %s\n' "$PATTERN" >&2
      printf 'Supported patterns: full, collaborative, lean, knowledge-first\n' >&2
      exit 1
      ;;
  esac
}

append_pattern_artifact_dirs() {
  local base_dir="$1"

  case "$PATTERN" in
    full|collaborative)
      DIRS+=(
        "$TARGET_DIR/$base_dir/specs"
        "$TARGET_DIR/$base_dir/scenarios"
        "$TARGET_DIR/$base_dir/acceptance"
      )
      ;;
    lean|knowledge-first)
      ;;
  esac
}

should_create_agents() {
  local cli_target="$1"

  case "$cli_target" in
    claude|opencode|multi)
      [ "$CREATE_AGENTS" = "yes" ]
      ;;
    *)
      return 1
      ;;
  esac
}

BASE_DIR="$(resolve_context_dir)"

case "$CLI_TARGET" in
  claude)
    append_pattern_dirs "$BASE_DIR"
    append_pattern_artifact_dirs "$BASE_DIR"
    ;;
  codex)
    append_pattern_dirs "$BASE_DIR"
    append_pattern_artifact_dirs "$BASE_DIR"
    ;;
  opencode)
    DIRS+=("$TARGET_DIR/.opencode/skills")
    if should_create_agents "$CLI_TARGET"; then
      DIRS+=("$TARGET_DIR/.opencode/agents")
    fi
    append_pattern_dirs "$BASE_DIR"
    append_pattern_artifact_dirs "$BASE_DIR"
    ;;
  gemini)
    DIRS+=(
      "$TARGET_DIR/.gemini"
    )
    append_pattern_dirs "$BASE_DIR"
    append_pattern_artifact_dirs "$BASE_DIR"
    ;;
  multi)
    DIRS+=(
      "$TARGET_DIR/.claude/commands"
      "$TARGET_DIR/.claude/knowledge"
      "$TARGET_DIR/.claude/rules"
      "$TARGET_DIR/.claude/plans"
      "$TARGET_DIR/.claude/tasks"
      "$TARGET_DIR/.claude/specs"
      "$TARGET_DIR/.claude/scenarios"
      "$TARGET_DIR/.claude/acceptance"
      "$TARGET_DIR/.codex/knowledge"
      "$TARGET_DIR/.codex/rules"
      "$TARGET_DIR/.codex/plans"
      "$TARGET_DIR/.codex/tasks"
      "$TARGET_DIR/.codex/specs"
      "$TARGET_DIR/.codex/scenarios"
      "$TARGET_DIR/.codex/acceptance"
      "$TARGET_DIR/.opencode/skills"
      "$TARGET_DIR/.opencode/knowledge"
      "$TARGET_DIR/.opencode/rules"
      "$TARGET_DIR/.opencode/plans"
      "$TARGET_DIR/.opencode/tasks"
      "$TARGET_DIR/.opencode/specs"
      "$TARGET_DIR/.opencode/scenarios"
      "$TARGET_DIR/.opencode/acceptance"
      "$TARGET_DIR/.gemini/knowledge"
      "$TARGET_DIR/.gemini/rules"
      "$TARGET_DIR/.gemini/plans"
      "$TARGET_DIR/.gemini/tasks"
      "$TARGET_DIR/.gemini/specs"
      "$TARGET_DIR/.gemini/scenarios"
      "$TARGET_DIR/.gemini/acceptance"
    )
    if should_create_agents "$CLI_TARGET"; then
      DIRS+=(
        "$TARGET_DIR/.claude/agents"
        "$TARGET_DIR/.opencode/agents"
      )
    fi
    ;;
  *)
    printf 'Unsupported CLI target: %s\n' "$CLI_TARGET" >&2
    printf 'Supported targets: claude, codex, opencode, gemini, multi\n' >&2
    exit 1
    ;;
esac

mkdir -p "${DIRS[@]}"

printf 'Created workflow directories for target %s with pattern %s in %s (agents=%s)\n' \
  "$CLI_TARGET" "$PATTERN" "$TARGET_DIR" "$CREATE_AGENTS"
