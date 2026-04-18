# Design: path-context skill

## Architecture Overview

The skill is a pure behavioral protocol encoded in a single `SKILL.md` file. No binaries, no runtime code, no external dependencies. The agent executes the protocol using only its built-in tools (`Glob`, `Grep`, `Read`, `Bash`).

```
                         SKILL.md Protocol
                    ┌─────────────────────────┐
                    │                         │
   User prompt ─────►  1. ACTIVATION          │
   (trigger match)  │     ↓                   │
                    │  2. PATH REGISTRATION   │
                    │     ↓                   │
                    │  3. DISCOVERY PROTOCOL  │
                    │     ↓                   │
                    │  4. CONTEXT INJECTION   │
                    │     ↓                   │
                    │  5. TASK EXECUTION      │
                    └─────────────────────────┘

Three logical components:
  A) Activation  — trigger phrases fire the skill
  B) Registration — resolve paths from config / --add-dir / in-prompt
  C) Discovery   — 6-pass heuristic selects files within budget
```

---

## Component Design

### 1. SKILL.md Structure

The SKILL.md will have these exact sections in order:

| Section | Purpose |
|---------|---------|
| **Frontmatter** | Name, description with triggers, license, metadata |
| **When to Use** | Bullet list of activation scenarios |
| **Critical Patterns** | The core behavioral protocol (registration + discovery + budget) |
| **Pattern 1: Path Registration** | Step-by-step for resolving referenced paths |
| **Pattern 2: Discovery Protocol** | The 6-pass heuristic with exact tool calls |
| **Pattern 3: Budget Enforcement** | Algorithm for selecting top-N files |
| **Pattern 4: Project Map Mode** | Large-project fallback (500+ files) |
| **Pattern 5: Output Annotation** | How to report what was loaded |
| **Security Boundaries** | Validated path checks, forbidden paths |
| **Ignore List** | Hard-coded directories to always skip |
| **Config Schema** | path-context.yaml format reference |
| **Resources** | Pointer to `assets/path-context.yaml` template |

### 2. Frontmatter Design

```yaml
---
name: path-context
description: >
  Behavioral protocol for intelligently loading external project folders as reference context.
  Registers paths via config file, --add-dir, or in-prompt declaration, then runs a 6-pass
  heuristic discovery to select the most relevant files within a strict budget.
  Trigger: When user says "@context", "reference path", "reference folder", "reference project",
  "use as context", "add context from", "load context", "path context", "contexto de",
  "referenciar", "cargar contexto".
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---
```

### 3. Activation Protocol

**Trigger phrases** (in frontmatter `description`):

| Phrase | Language | Example usage |
|--------|----------|---------------|
| `@context` | EN | `@context /projects/design-system` |
| `reference path` | EN | `reference path /projects/api for auth patterns` |
| `reference folder` | EN | `reference folder ~/work/shared-lib` |
| `reference project` | EN | `reference project /projects/core-api` |
| `use as context` | EN | `use /projects/api as context` |
| `add context from` | EN | `add context from /projects/shared` |
| `load context` | EN | `load context from ~/work/api` |
| `path context` | EN | `configure path context for this session` |
| `contexto de` | ES | `usar como contexto de /projects/api` |
| `referenciar` | ES | `referenciar /projects/design-system` |
| `cargar contexto` | ES | `cargar contexto de /projects/api` |

**Decision**: multi-word phrases only. Bare "context" or "path" will NOT trigger activation because they are too common. The phrase `@context` is the canonical short form.

**Activation is once per conversation**. After the skill fires and discovery runs, results persist in the agent's working memory. The agent does NOT re-run discovery on every turn. Re-discovery happens only when:
- User explicitly says `@context` again with a new path
- User starts a clearly different task and references the same path
- User says "refresh context" or "re-scan"

### 4. Path Registration Protocol

When the skill activates, the agent follows this exact sequence:

```
Step 1: Check config files (highest priority)
  1a. Read ~/.claude/path-context.yaml (global config)
  1b. Read .claude/path-context.yaml (project config)
  1c. Merge: project config overrides global for same aliases
  1d. If config exists → collect all paths from it

Step 2: Check in-prompt declaration
  2a. Parse the triggering message for path literals
  2b. Path literal = absolute path starting with / or ~/ or drive letter (C:\)
  2c. Normalize: resolve ~/ to $HOME, convert \ to / on Windows
  2d. Add parsed paths to the collection

Step 3: Validate each collected path
  3a. For each path:
      - Verify it exists: Bash "test -d {path} && echo EXISTS || echo MISSING"
      - If MISSING → report to user, skip this path
      - If EXISTS → check for project indicators:
        Glob {path}/* depth 1 — look for: package.json, go.mod, Cargo.toml,
        pyproject.toml, pom.xml, build.gradle, .git, src/, lib/, cmd/,
        README.md, Makefile, CMakeLists.txt
      - If NO project indicators found → warn user:
        "Path {path} doesn't look like a project folder. Proceeding anyway,
        but results may be noisy."
  3b. Security check:
      - REJECT paths that resolve to: ~/.ssh, ~/.gnupg, ~/.aws/credentials,
        /etc/shadow, /etc/passwd, any path containing ".ssh" or "credentials"
      - REJECT paths that are filesystem roots: /, C:\, D:\
      - If rejected → tell user WHY and do NOT proceed with that path

Step 4: Apply limits
  4a. Max 3 simultaneous path references
  4b. If more than 3 → use only the first 3, warn user
  4c. Calculate per-path budget: floor(15 / number_of_paths)
      - 1 path  → 15 files
      - 2 paths → 7 files each (14 total)
      - 3 paths → 5 files each (15 total)
```

**Config lookup specifics**:
- The agent uses `Read` on the YAML files (absolute paths)
- If neither config file exists, that's fine — proceed with in-prompt paths only
- `--add-dir` paths are NOT explicitly detected by the skill. The skill instructs the user: "For best results, also run `--add-dir /your/path` or `/add-dir /your/path` so the agent has native access to the directory. The skill works with absolute-path Read calls regardless, but --add-dir enables Glob and Grep within the directory."

### 5. Discovery Protocol — Detailed Design

For EACH registered path, execute passes 1-6. All tool calls use the registered path as the base directory.

#### Pass 1: Topology Scan

**Purpose**: Understand project structure, identify language/framework.

**Tool calls**:
```
Glob: {path}/**/*  (with path parameter set to {path})
  - Use depth 3 implicitly by globbing {path}/***, {path}/**/*
  - Actually: Glob pattern "**/*" with path={path}
  - This returns file listing; agent mentally groups by extension
```

**Extract**:
- Primary language (most common source extension: .ts/.js/.go/.py/.rs/.java)
- Framework indicators:
  | File | Framework |
  |------|-----------|
  | `package.json` | Node.js ecosystem |
  | `go.mod` | Go |
  | `Cargo.toml` | Rust |
  | `pyproject.toml` / `setup.py` | Python |
  | `pom.xml` / `build.gradle` | Java/Kotlin |
  | `angular.json` | Angular |
  | `next.config.*` | Next.js |
  | `nuxt.config.*` | Nuxt |
  | `vite.config.*` | Vite |
- Directory structure pattern (flat, src-based, cmd-based, monorepo)
- Total file count (for project map mode decision)

**Short-circuit**: If total file count > 500, switch to **Project Map Mode** (see section 7). Skip passes 2-6.

**Output**: mental model of project type + language + structure. No files read yet.

#### Pass 2: Entry Point Detection

**Purpose**: Find the most important files — the ones you'd read first as a human.

**Tool calls**:
```
Glob: {path}/**/main.* with path={path}
Glob: {path}/**/index.* with path={path}  (filter to source extensions only)
Glob: {path}/**/app.* with path={path}
Glob: {path}/cmd/**/*.* with path={path}
Glob: {path}/src/main.* with path={path}
Glob: {path}/src/index.* with path={path}
Glob: {path}/src/app.* with path={path}
Glob: {path}/lib/index.* with path={path}
```

Also check for framework-specific entry points based on Pass 1:
- Next.js: `{path}/src/app/layout.*`, `{path}/app/layout.*`, `{path}/pages/_app.*`
- Angular: `{path}/src/app/app.module.*`, `{path}/src/app/app.component.*`
- Go: `{path}/cmd/*/main.go`, `{path}/main.go`
- Rust: `{path}/src/main.rs`, `{path}/src/lib.rs`
- Python: `{path}/src/*/__main__.py`, `{path}/**/__main__.py`

**Extract**: List of entry point files. Read up to 3 (prioritize `main` > `app` > `index`).

**Budget consumed**: up to 3 files.

#### Pass 3: Keyword Grep

**Purpose**: Find files that mention concepts relevant to the current task.

**Keyword extraction**:
1. From the user's current message, extract 3-5 domain nouns (not stop words, not programming keywords)
2. Examples: if task is "implement auth middleware using the API project's patterns" → keywords: `auth`, `middleware`, `pattern`
3. If task is "style the dashboard like the design system" → keywords: `dashboard`, `style`, `theme`, `component`

**Tool calls** (for each keyword):
```
Grep: pattern={keyword} path={path} type={primary_language_type}
  output_mode=files_with_matches
  head_limit=10
```

**Ranking**: Count how many keywords each file matches. Files matching 2+ keywords rank highest.

**Extract**: Ranked list of files by keyword match count. Do NOT read yet — just collect paths.

**Budget**: This pass produces candidates, not reads.

#### Pass 4: Import Chain

**Purpose**: From files found in passes 2-3, discover what they depend on.

**Tool calls**:
For each file read in Pass 2 (entry points), grep for import patterns:
```
Grep: pattern="(import|require|from|use)\s" path={file} output_mode=content
```

Parse import paths. Resolve relative imports to absolute paths within the referenced project.

**Extract**: List of direct dependencies of entry points. These are "second ring" files — important because the entry points need them.

**Budget**: This pass produces candidates, not reads.

#### Pass 5: Naming Signal

**Purpose**: Zero-read signal — files whose names contain task-relevant nouns.

**Tool calls**:
```
For each keyword from Pass 3:
  Glob: {path}/**/*{keyword}*.* with path={path}
```

Filter out test files (`*.test.*`, `*.spec.*`, `*_test.*`) and files in ignored directories.

**Extract**: Additional candidate files ranked by name relevance.

**Budget**: This pass produces candidates, not reads.

#### Pass 6: Recency Signal

**Purpose**: Recently modified files are more likely to be relevant (active development).

**Tool calls**:
```
Bash: cd {path} && git log --name-only --pretty=format: -20 2>/dev/null | sort | uniq -c | sort -rn | head -20
```

If not a git repo, skip this pass entirely.

**Extract**: List of recently active files with change frequency. Use as a tiebreaker in ranking.

**Budget**: This pass produces a boost signal, not reads.

---

#### Final Ranking & Selection

After all 6 passes, the agent has:
- Entry point files (Pass 2): already read, high priority
- Keyword-matched files (Pass 3): ranked by match count
- Import dependencies (Pass 4): from entry points
- Name-matched files (Pass 5): by keyword overlap
- Recency-boosted files (Pass 6): tiebreaker

**Deduplication**: Merge all candidate lists, remove duplicates.

**Scoring** (agent applies mentally, no literal score computation):

| Signal | Weight | Description |
|--------|--------|-------------|
| Entry point | Highest | Already read in Pass 2 |
| Keyword match (2+ keywords) | High | Multiple keyword hits = strong relevance |
| Keyword match (1 keyword) | Medium | Single keyword = possible relevance |
| Import dependency of entry point | Medium | Structurally important |
| Name contains task noun | Medium | Naming signal |
| Recently modified (top 5) | Boost | Tiebreaker, not standalone signal |

**Selection**: Pick top N files (N = per-path budget from section 4). Prefer diversity — don't select 5 files from the same directory if candidates span multiple directories.

**Read**: Use `Read` tool on each selected file. If a file exceeds 500 lines, read only the first 200 lines and note "(truncated — file has {total} lines)".

### 6. Budget Enforcement Algorithm

```
CONSTANTS:
  TOTAL_BUDGET     = 15        # max files across all paths
  MAX_PATHS        = 3         # max simultaneous references
  MAX_LINES        = 500       # per-file line cap (read first 200 if exceeded)
  ENTRY_POINT_CAP  = 3         # max entry points per path (Pass 2)

ALGORITHM:
  1. per_path_budget = floor(TOTAL_BUDGET / number_of_paths)
  2. For each path:
     a. entry_points_read = min(entry_points_found, ENTRY_POINT_CAP)
     b. remaining_budget  = per_path_budget - entry_points_read
     c. Select top {remaining_budget} from ranked candidates (passes 3-6)
     d. Read selected files (truncate at MAX_LINES)
  3. Total files read across all paths MUST NOT exceed TOTAL_BUDGET
  4. If any path exhausts its budget, do NOT steal from other paths

EDGE CASES:
  - Path has fewer files than budget → read all source files, budget unused
  - No keyword matches at all → rely on entry points + imports only
  - No entry points found → bump keyword/naming passes to fill budget
  - All candidates are test files → skip tests, report "no production code found matching task"
```

### 7. Project Map Mode

**Trigger**: Pass 1 topology scan finds > 500 files in the referenced path.

**Behavior**: Skip passes 2-6 entirely. Instead, produce a structural summary.

**Tool calls**:
```
Step 1: Directory tree (depth 2)
  Bash: cd {path} && find . -maxdepth 2 -type d \
    ! -path '*/node_modules/*' ! -path '*/.git/*' ! -path '*/dist/*' \
    ! -path '*/vendor/*' ! -path '*/__pycache__/*' ! -path '*/.next/*' \
    ! -path '*/target/*' ! -path '*/build/*' ! -path '*/.venv/*' \
    ! -path '*/coverage/*' | sort

Step 2: Entry points (same as Pass 2, but read only 1)
  Glob for main/index/app — read the single most likely entry point

Step 3: README excerpt
  Read: {path}/README.md (first 100 lines only)
  If no README → skip
```

**Output format**:
```markdown
## Project Map: {alias or path basename}

**Type**: {language} / {framework}
**Structure**: {flat | src-based | monorepo | cmd-based}
**Size**: ~{count} files

### Directory Structure
```
{depth-2 tree output}
```

### Entry Point
{file path} — {first 20 lines or summary}

### README Excerpt
{first 100 lines}

---
*This is a project map (500+ files). For targeted file access, ask about specific files or areas.*
```

**Budget**: Project map mode consumes 2 files max (entry point + README) from the budget. The directory tree is metadata, not file reads.

### 8. path-context.yaml Config Schema

```yaml
# Config location (checked in order):
#   1. .claude/path-context.yaml        (project-level, highest priority)
#   2. ~/.claude/path-context.yaml       (global, fallback)
#
# Project-level config overrides global for paths with the same alias.

# Required: at least one entry in paths
paths:
    # Required: absolute path to the referenced project
  - path: /absolute/path/to/project

    # Optional: short name for in-prompt reference
    # Usage: "@context design-system" instead of full path
    # Default: basename of path
    alias: design-system

    # Optional: glob patterns to restrict discovery scope
    # Default: all source files (filtered by ignore list)
    include:
      - "src/**"
      - "lib/**"
      - "packages/core/**"

    # Optional: glob patterns to exclude from discovery
    # Default: none (ignore list already handles common noise)
    exclude:
      - "**/*.test.*"
      - "**/*.spec.*"
      - "**/*.stories.*"
      - "**/fixtures/**"
      - "**/mocks/**"

  - path: /another/project
    alias: api
    include:
      - "src/**"
```

**Parsing rules**:
- `path` is required. If missing, skip entry and warn.
- `alias` defaults to `basename(path)` (e.g., `/projects/design-system` → `design-system`).
- `include` and `exclude` are applied AFTER the ignore list. They restrict which files the discovery protocol considers.
- `include` is additive: if specified, ONLY files matching at least one include pattern are considered.
- `exclude` removes files from candidates even if they match include.

### 9. Output Annotation Format

After discovery completes and files are read, the agent outputs a context annotation BEFORE proceeding with the user's task:

```markdown
---
**Context loaded from {alias}** ({path})
- {file1.ts} — {one-line description: e.g., "main entry point"}
- {file2.ts} — {one-line description: e.g., "auth middleware, matched keyword 'auth'"}
- {file3.ts} — {one-line description: e.g., "imported by entry point"}
- ... ({N} files loaded, {M} candidates omitted)

{If project map mode}: "Project map loaded (500+ files — structural overview only)"
---
```

**Placement**: Immediately after discovery, before the agent's response to the user's actual task.

**When user references a previously-loaded context in a later turn**: Do NOT re-output the annotation. The context is already in working memory. Only re-annotate if re-discovery was triggered.

### 10. Security Boundaries

**Forbidden paths** (REJECT immediately, do NOT read any files):
```
~/.ssh
~/.gnupg
~/.aws
~/.config/gcloud
/etc/shadow
/etc/passwd
/etc/sudoers
Any path containing: .ssh, credentials, secrets, .gnupg
Filesystem roots: /, C:\, D:\, etc.
```

**Validation logic** (applied in Registration step 3b):
```
1. Resolve path to absolute (expand ~, resolve ..)
2. Check against forbidden list (substring match for keywords, exact match for roots)
3. If forbidden → reject with message: "Security: path {path} is restricted.
   The path-context skill only loads project folders."
4. If allowed → proceed with project indicator check
```

**Read-only**: The skill NEVER instructs the agent to write, modify, or delete files in the referenced path. All operations are Read, Glob, Grep, or read-only Bash commands.

**Path traversal defense**: If any resolved file path (from Glob/Grep results) escapes the registered base path (e.g., via symlinks), skip that file and warn.

---

## Ignore List

Hard-coded directories to ALWAYS skip during discovery (all passes):

```
node_modules/
.git/
dist/
vendor/
__pycache__/
.next/
target/
build/
.venv/
coverage/
.turbo/
.cache/
.parcel-cache/
.nuxt/
.output/
.svelte-kit/
```

These are filtered by:
- Excluding from Glob results (pattern filtering)
- Adding `! -path` exclusions in Bash commands
- Skipping matches from Grep results that contain these path segments

---

## File Layout

```
~/.claude/skills/path-context/
├── SKILL.md                          # Main skill file (behavioral protocol)
└── assets/
    └── path-context.yaml             # Config template with comments
```

Two files total. No references/ directory needed (no external docs to point to).

---

## Sequence Diagram

```
User                    Agent                   Skill Protocol              External Path
 │                        │                          │                          │
 │ "@context /projects/api│for auth patterns"        │                          │
 │───────────────────────►│                          │                          │
 │                        │  Trigger match           │                          │
 │                        │─────────────────────────►│                          │
 │                        │                          │                          │
 │                        │  1. REGISTRATION         │                          │
 │                        │  Read config files       │                          │
 │                        │  Parse in-prompt path    │                          │
 │                        │  Validate: exists?       │─── Bash: test -d ───────►│
 │                        │  Security check          │◄── EXISTS ──────────────│
 │                        │  Budget: 15/1 = 15       │                          │
 │                        │                          │                          │
 │                        │  2. PASS 1: Topology     │                          │
 │                        │                          │─── Glob **/* ───────────►│
 │                        │                          │◄── file list (< 500) ───│
 │                        │  Language: TypeScript     │                          │
 │                        │  Framework: NestJS        │                          │
 │                        │                          │                          │
 │                        │  3. PASS 2: Entry points │                          │
 │                        │                          │─── Glob **/main.* ──────►│
 │                        │                          │─── Glob **/index.* ─────►│
 │                        │                          │◄── src/main.ts ─────────│
 │                        │                          │─── Read src/main.ts ────►│
 │                        │                          │◄── content ─────────────│
 │                        │  [budget: 14 remaining]  │                          │
 │                        │                          │                          │
 │                        │  4. PASS 3: Keywords     │                          │
 │                        │  (extracted: auth,        │                          │
 │                        │   middleware, pattern)    │                          │
 │                        │                          │─── Grep "auth" ─────────►│
 │                        │                          │◄── 4 files match ────────│
 │                        │                          │─── Grep "middleware" ────►│
 │                        │                          │◄── 2 files match ────────│
 │                        │  Ranked: auth.guard.ts (2)│                          │
 │                        │          auth.module.ts(2)│                          │
 │                        │                          │                          │
 │                        │  5. PASS 4: Imports      │                          │
 │                        │                          │─── Grep imports in ──────►│
 │                        │                          │    src/main.ts            │
 │                        │                          │◄── app.module.ts ────────│
 │                        │                          │                          │
 │                        │  6. PASS 5: Naming       │                          │
 │                        │                          │─── Glob **/*auth*.* ────►│
 │                        │                          │◄── 3 matches ───────────│
 │                        │                          │                          │
 │                        │  7. PASS 6: Recency      │                          │
 │                        │                          │─── Bash: git log ────────►│
 │                        │                          │◄── recent files ─────────│
 │                        │                          │                          │
 │                        │  8. RANK & SELECT        │                          │
 │                        │  Top 15 files deduped    │                          │
 │                        │                          │─── Read file 2..N ───────►│
 │                        │                          │◄── contents ─────────────│
 │                        │                          │                          │
 │                        │  9. OUTPUT ANNOTATION    │                          │
 │  "Context loaded from  │◄─────────────────────────│                          │
 │   api (7 files, 12     │                          │                          │
 │   candidates omitted)" │                          │                          │
 │                        │                          │                          │
 │  "Now answering your   │                          │                          │
 │   question about auth  │                          │                          │
 │   patterns..."         │                          │                          │
 │◄───────────────────────│                          │                          │
```

---

## Architecture Decisions

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Skill format | Single SKILL.md + 1 asset file | Follows skill-creator conventions; skill must be standalone with zero extra hops |
| 2 | No sub-agent delegation | Agent executes protocol itself | This is a behavioral skill, not an orchestration skill; sub-agents would add latency and token cost for no benefit |
| 3 | Hard-coded ignore list | Yes, in SKILL.md body | Universal noise dirs (node_modules, .git, etc.) never contain useful reference context; configurable excludes cover the rest |
| 4 | 6-pass sequential discovery | Sequential passes, not parallel | Each pass informs the next (topology → entry points → keywords → imports); parallelizing would lose this signal chain |
| 5 | Budget is files, not tokens | 15 files max, 500 lines per file | Files are the natural unit for project navigation; token counting is impractical for a behavioral protocol |
| 6 | Project map mode at 500+ files | Structural summary instead of file reads | Reading individual files from a massive project wastes budget; a structural map gives the agent enough context to ask targeted follow-up questions |
| 7 | Config file is optional | Skill works with in-prompt paths alone | Lowers adoption friction; config adds persistence for repeated use |
| 8 | --add-dir is recommended, not required | Document it, don't enforce it | Absolute-path Read works without --add-dir; but Glob/Grep within the dir work better with it |
| 9 | Activation once per conversation | Discovery persists in agent memory | Re-running 6 passes every turn wastes tokens; explicit re-trigger available |
| 10 | Security: forbidden path list | Hard-coded blocklist + project indicator check | Simple, predictable, no false negatives for obvious sensitive paths |
| 11 | Trigger phrases are multi-word | No bare "context" or "path" | Prevents false activation on extremely common words |
| 12 | Per-file line cap of 500 (read 200) | Truncate with note | Large files (e.g., generated code, lock files) would blow the context budget; 200 lines captures the API surface |
| 13 | Max 3 paths | Hard limit, not configurable | Practical ceiling; 3 paths x 5 files = 15 files already at max budget |
| 14 | Windows path normalization | Normalize \ to /, expand drive letters | Skill must work on Windows (user's primary OS); all internal path handling uses forward slashes |
| 15 | YAML config over JSON | YAML for config file | More readable for humans, supports comments, consistent with Claude Code ecosystem (.claude/ conventions) |
