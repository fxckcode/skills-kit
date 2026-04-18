# Proposal: path-context

## Intent

AI agents using Claude Code lack a protocol for intelligently consuming external project folders as reference context. While `--add-dir` grants file access, it provides no guidance on WHAT to read. This skill gives agents a behavioral protocol to register external paths, discover the most relevant files via heuristics, and inject them into context within a strict budget — enabling cross-project work without context window pollution.

## Scope

### In Scope
- Single `SKILL.md` with behavioral protocol for path registration + intelligent discovery
- Optional `path-context.yaml` config file schema for persistent references
- 6-pass heuristic discovery protocol (topology → entry points → keyword grep → import chain → naming → recency)
- Hard budget enforcement (10-15 files max, split across references)
- Auto-trigger via SKILL.md frontmatter triggers
- Support for up to 3 simultaneous path references
- Project map mode for large projects (500+ files)
- Hard-coded ignore list for common noise directories

### Out of Scope
- Vector/embedding-based semantic search
- Persistent indexing or caching between sessions
- Binary tooling, external dependencies, or runtime code
- Replacing or wrapping `--add-dir` functionality
- Write operations to referenced projects
- File watching or change detection

## Approach

### Architecture

Single `SKILL.md` file containing three behavioral sections:

1. **Activation** — trigger phrases in frontmatter fire the skill
2. **Path Registration** — protocol to resolve paths from config, `--add-dir`, or in-prompt declaration
3. **Discovery Protocol** — 6-pass heuristic to select files within budget

Optional `assets/path-context.yaml.example` as a config template.

### Key Decisions

| # | Question | Decision | Rationale |
|---|----------|----------|-----------|
| 1 | YAML config schema | Flat array of paths with optional `include`/`exclude` globs | Simple to write, covers 95% of cases; no over-abstraction |
| 2 | Activation granularity | Once per conversation; discovery results persist in agent memory | Re-running 6-pass every turn wastes tokens; refresh only on explicit request or new task |
| 3 | Summarization mode | Yes — "project map" mode for 500+ file projects | Produces a structural summary (tree + key files) instead of reading individual files |
| 4 | Output format | Collapsible inline annotation listing loaded files + omitted count | User sees what was loaded without noise; collapsible keeps conversation clean |
| 5 | Multiple references | Up to 3 paths; budget splits equally (e.g., 5 files each for 3 paths) | Prevents any single reference from starving others; 3 is practical ceiling |
| 6 | `--add-dir` interaction | Skill reads files by absolute path directly; documents `--add-dir` as recommended for heavy use | Absolute-path Read works without `--add-dir`; recommending it for large projects avoids permission issues |
| 7 | Ignore list | Hard-coded: `node_modules`, `.git`, `dist`, `vendor`, `__pycache__`, `.next`, `target`, `build`, `.venv`, `coverage` | These are universal noise; no project needs them as reference context |

### path-context.yaml Schema

```yaml
# ~/.claude/path-context.yaml (global) or .claude/path-context.yaml (project)
paths:
  - path: /absolute/path/to/project
    alias: design-system          # optional, for in-prompt reference
    include: ["src/**", "lib/**"] # optional glob filters
    exclude: ["**/*.test.*"]      # optional exclusions
  - path: /another/project
```

### Discovery Protocol (6-pass heuristic)

For each registered path, the agent executes:

1. **Topology scan** — `Glob **/* --depth 3` to understand project structure; identify language/framework from file extensions and config files (`package.json`, `go.mod`, `Cargo.toml`, etc.)
2. **Entry point detection** — find `main.*`, `index.*`, `app.*`, `cmd/`, `src/main`, `lib/` — read these first (max 3)
3. **Keyword grep** — extract 3-5 nouns from the current task, `Grep` across source files; rank by match count
4. **Import chain** — from files found in passes 2-3, grep for `import`/`require`/`use`/`from` to find direct dependencies
5. **Naming signal** — files whose names contain task-relevant nouns (e.g., task mentions "auth" → `auth.service.ts` scores high)
6. **Recency signal** — `git log --name-only -20` (if git repo) to boost recently active files

**Budget enforcement**: after all passes, deduplicate and rank. Select top N files (budget = 15 / number_of_paths). State what was selected, what was omitted, and why.

**Project map mode** (500+ files): skip passes 3-6. Instead, produce a structural summary: directory tree (depth 2) + entry points + `README.md` excerpt. Inject as a "project map" rather than individual files.

### Trigger Design

Frontmatter trigger phrases:
```
@context, reference path, reference folder, reference project, use as context,
add context from, load context, path context, contexto de, referenciar
```

These are specific enough to avoid false activation (no bare "context" trigger) while covering natural phrasing in English and Spanish.

## Rollback Plan

Delete `SKILL.md` and optionally `path-context.yaml`. No other files are affected. No hooks, no config mutations, no side effects.

## Affected Files

| File | Action |
|------|--------|
| `SKILL.md` | Create — main skill definition |
| `assets/path-context.yaml.example` | Create — config template |

## Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| Context pollution from reading too many/large files | HIGH | Hard budget (15 files max), file size cap (500 lines per file), project map mode for large projects |
| Trigger fires too eagerly on common words | MEDIUM | Multi-word trigger phrases only; no bare "context" or "path" |
| Discovery heuristic misses relevant files | MEDIUM | 6-pass approach covers multiple signals; user can explicitly name files to include via `include` globs in config |
