# Tasks: path-context

## Phase 1: Infrastructure
- [x] 1.1 Create `~/.claude/skills/path-context/` directory (supports REQ-001.4: skill usable standalone)
- [x] 1.2 Create `~/.claude/skills/path-context/assets/` directory (design: File Layout section)

---

## Phase 2: SKILL.md — Frontmatter & Structure
- [x] 2.1 Write SKILL.md frontmatter: `name: path-context`, `description` block with all 11 trigger phrases (`@context`, `reference path`, `reference folder`, `reference project`, `use as context`, `add context from`, `load context`, `path context`, `contexto de`, `referenciar`, `cargar contexto`), `license: Apache-2.0`, `metadata.author: gentleman-programming`, `metadata.version: "1.0"` (design: Frontmatter Design; REQ-001.1, REQ-001.2)
- [x] 2.2 Write "When to Use" section: bullet list of activation scenarios including in-prompt path reference, config file alias resolution, multi-path cross-project queries, large project overview, and refresh requests (design: SKILL.md Structure table)
- [x] 2.3 Write "Activation Rules" callout: activate once per conversation turn; results persist in agent working memory for the session; re-trigger only on explicit new path, new task, or `refresh context` / `re-scan` request (REQ-001.3; design: Activation Protocol)

---

## Phase 3: Path Registration Protocol (Pattern 1)
- [x] 3.1 Write Pattern 1 header and step-by-step config file resolution: (a) Read `~/.claude/path-context.yaml` global config using `Read` tool, (b) Read `.claude/path-context.yaml` project config using `Read` tool, (c) merge with project config taking precedence for same aliases, (d) collect all `paths` entries; note that an empty `paths` array equals no config (REQ-002.1, REQ-008.1–REQ-008.9; design: step 1 of registration)
- [x] 3.2 Write in-prompt path parsing rules: extract absolute path literals from the triggering message (starts with `/`, `~/`, or drive letter `C:\` / `C:/`); normalize `~/` to `$HOME` and backslash to forward-slash on Windows; alias lookup from config entries (REQ-002.3, REQ-002.6; design: step 2 of registration)
- [x] 3.3 Write path validation step: use `Bash: test -d {path} && echo EXISTS || echo MISSING`; on MISSING report to user and skip that path; on EXISTS run `Glob {path}/* depth 1` to check for at least one project indicator (`package.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`, `pom.xml`, `build.gradle`, `.git`, `src/`, `lib/`, `cmd/`, `README.md`, `Makefile`, `CMakeLists.txt`); if none found warn user but proceed (REQ-002.5, REQ-010.1, REQ-010.5; design: step 3a)
- [x] 3.4 Write security validation rules: resolve path to absolute; reject paths matching forbidden list (`~/.ssh`, `~/.gnupg`, `~/.aws`, `~/.config/gcloud`, `/etc/shadow`, `/etc/passwd`, `/etc/sudoers`, any path containing `.ssh`, `credentials`, `secrets`, `.gnupg`); reject filesystem roots (`/`, `C:\`, `D:\`, etc.); on rejection output: `"Security: path {path} is restricted. The path-context skill only loads project folders."` (REQ-010.2; design: step 3b, Security Boundaries section)
- [x] 3.5 Write path limit enforcement: max 3 simultaneous references; if more than 3 detected use first 3 and warn user; calculate per-path budget using `floor(15 / number_of_paths)` — 1 path = 15, 2 paths = 7 each, 3 paths = 5 each; note that unused budget from one path MUST NOT be redistributed to others (REQ-004.1–REQ-004.6, REQ-006.1, REQ-006.4–REQ-006.5; design: step 4)

---

## Phase 4: Discovery Protocol — 6 Passes (Pattern 2)
- [x] 4.1 Write Pass 1 — Topology Scan: tool call `Glob "**/*" path={registered_path}`; extract primary language by most common source extension; identify framework from config file presence (`package.json` → Node, `go.mod` → Go, `Cargo.toml` → Rust, `pyproject.toml` / `setup.py` → Python, `pom.xml` / `build.gradle` → Java/Kotlin, `angular.json` → Angular, `next.config.*` → Next.js, `nuxt.config.*` → Nuxt, `vite.config.*` → Vite); count total files after ignore-list filtering; if count > 500 short-circuit to Project Map Mode (Pass 1 is the only pass that executes); this pass MUST NOT read file contents (REQ-003.1, REQ-009.1; design: Pass 1 Topology Scan)
- [x] 4.2 Write Pass 2 — Entry Point Detection: Glob calls for `**/main.*`, `**/index.*` (source extensions only), `**/app.*`, `cmd/**/*.*`, `src/main.*`, `src/index.*`, `src/app.*`, `lib/index.*`; framework-specific extras for Next.js (`app/layout.*`, `pages/_app.*`), Angular (`app.module.*`, `app.component.*`), Go (`cmd/*/main.go`, `main.go`), Rust (`src/main.rs`, `src/lib.rs`), Python (`**/__main__.py`); select up to 3 entry points prioritized as `main` > `app` > `index`; READ these files immediately (consume from per-path budget); initial ranking = highest score (REQ-003.2; design: Pass 2)
- [x] 4.3 Write Pass 3 — Keyword Grep: extract 3–5 domain nouns from the user's current task message (exclude stop words and generic programming terms); for each keyword run `Grep pattern={keyword} path={registered_path} type={primary_lang} output_mode=files_with_matches head_limit=10`; rank candidate files by total keyword match count across all keywords; files matching 2+ keywords rank highest; files with zero matches across ALL keywords receive lowest score (REQ-003.3; design: Pass 3)
- [x] 4.4 Write Pass 4 — Import Chain: for each entry point file read in Pass 2, run `Grep pattern="(import|require|from|use)\\s" path={entry_point_file} output_mode=content`; parse import paths and resolve relative imports to absolute paths within the registered project; add resolved dependency files to candidate set with medium priority score (REQ-003.4; design: Pass 4)
- [x] 4.5 Write Pass 5 — Naming Signal: for each keyword extracted in Pass 3, run `Glob "**/*{keyword}*.*" path={registered_path}`; filter out test files (`*.test.*`, `*.spec.*`, `*_test.*`) and files in ignored directories; add matched files to candidate set with medium priority (REQ-003.5; design: Pass 5)
- [x] 4.6 Write Pass 6 — Recency Signal: run `Bash: cd {path} && git log --name-only --pretty=format: -20 2>/dev/null | sort | uniq -c | sort -rn | head -20`; if command fails or returns empty, skip this pass silently without error (path is not a git repo); files appearing in recency output receive a score boost used as tiebreaker in final ranking (REQ-003.6; design: Pass 6)
- [x] 4.7 Write deduplication and final ranking rules: merge all candidate lists from passes 3–6, remove duplicates; apply scoring weights: Entry point = highest, 2+ keyword matches = high, 1 keyword match = medium, import dependency of entry point = medium, name contains task noun = medium, recently modified top 5 = boost/tiebreaker; enforce diversity — prefer candidates spanning multiple directories over 5 from the same directory; apply ignore list exclusion at this point (REQ-003.7, REQ-007.1–REQ-007.4; design: Final Ranking & Selection)
- [x] 4.8 Write zero-signal guard: if all candidates score at zero-signal baseline (no keyword matches, no naming signal, no import hits, no entry points), the agent MUST NOT read arbitrary files to fill the budget; output to user: `"No relevant files found in {path} for this task. Do you want to reference a different path, or should I answer based on general knowledge?"` (REQ-003.8; spec SCN-005)

---

## Phase 5: Budget Enforcement Algorithm (Pattern 3)
- [x] 5.1 Write budget enforcement algorithm with constants and step-by-step procedure: `TOTAL_BUDGET = 15`, `MAX_PATHS = 3`, `MAX_LINES = 500` (read first 200 if exceeded), `ENTRY_POINT_CAP = 3`; algorithm: (1) `per_path_budget = floor(TOTAL_BUDGET / number_of_paths)`, (2) for each path: `entry_points_read = min(entry_points_found, ENTRY_POINT_CAP)`, `remaining = per_path_budget - entry_points_read`, select top `remaining` from ranked candidates, read with truncation; total across all paths MUST NOT exceed 15 (REQ-004.1–REQ-004.6; design: Budget Enforcement Algorithm)
- [x] 5.2 Write edge case handling rules: fewer files than budget → read all source files, budget unused; no keyword matches → rely on entry points + imports only; no entry points found → promote keyword/naming candidates to fill budget; all candidates are test files → skip, report `"no production code found matching task"`; user requests "read everything" → explain budget constraint and offer to refine discovery scope (REQ-004.5; design: edge cases in budget algorithm)

---

## Phase 6: Project Map Mode (Pattern 4)
- [x] 6.1 Write Project Map Mode trigger and behavior: activates when Pass 1 detects > 500 files after ignore-list filtering; passes 3–6 are SKIPPED entirely (REQ-009.1, REQ-009.2; design: Project Map Mode section)
- [x] 6.2 Write Project Map Mode tool calls: Step 1 — `Bash: cd {path} && find . -maxdepth 2 -type d ! -path '*/node_modules/*' ! -path '*/.git/*' ! -path '*/dist/*' ! -path '*/vendor/*' ! -path '*/__pycache__/*' ! -path '*/.next/*' ! -path '*/target/*' ! -path '*/build/*' ! -path '*/.venv/*' ! -path '*/coverage/*' | sort` for depth-2 directory tree; Step 2 — Glob for entry points and read the single most relevant one (50 lines); Step 3 — `Read {path}/README.md` first 200 lines (skip if not present) (REQ-009.3; design: Project Map Mode tool calls)
- [x] 6.3 Write Project Map Mode output format template: markdown block with `## Project Map: {alias or basename}`, fields for Type, Structure, Size, `### Directory Structure` tree, `### Entry Point` excerpt, `### README Excerpt`, and closing note `"This is a project map (500+ files). For targeted file access, ask about specific files or areas."`; budget: map mode consumes max 2 files (entry point + README) from the per-path budget (REQ-009.3–REQ-009.5; design: output format block)
- [x] 6.4 Write Project Map Mode user offer: after outputting the map, the agent SHOULD offer: `"To run targeted discovery on a sub-directory, specify a subdirectory (e.g., @context {path}/packages/auth)."` (REQ-009.6; spec SCN-004 step 5)

---

## Phase 7: Output Annotation (Pattern 5)
- [x] 7.1 Write output annotation format: wrap in `<details>` block for collapsibility; include: (a) referenced path(s) with alias if applicable, (b) number of files read, (c) names of files selected with one-line description per file noting which pass(es) contributed (e.g., "entry point", "keyword match: auth, user", "imported by main.ts"), (d) count of candidates omitted, (e) total lines read and note if any files were truncated due to 500-line cap (REQ-005.1–REQ-005.5; design: Output Annotation Format)
- [x] 7.2 Write annotation placement and repeat rules: annotation MUST appear before the agent's response to the user's actual task; on subsequent turns referencing already-loaded context, do NOT re-output the annotation (context is in working memory); only re-annotate if re-discovery was triggered by user (REQ-005.2; design: When user references previously-loaded context)
- [x] 7.3 Write Project Map annotation variant: when map mode is active, annotation MUST state `"Project map mode active ({N} files detected). Individual file discovery skipped."` and include the map summary in the annotation instead of listing individual files (REQ-005.6; design: Output Annotation Format)

---

## Phase 8: Multi-Reference Protocol (Pattern 6)
- [x] 8.1 Write multi-reference processing rules: process each path independently through the full 6-pass discovery protocol; budget split is `floor(15 / num_paths)` — integer division only, no fractional allocations; unused budget from one path is NOT redistributed to others; annotation lists each path separately with its own file selection (REQ-006.1–REQ-006.4; spec SCN-003)
- [x] 8.2 Write alias reference resolution: config entries MAY include an `alias` key; the agent MUST accept in-prompt references by alias (`@context design-system`) as equivalent to the full path; if no alias defined in config, `basename(path)` is the implicit default alias (REQ-006.6; design: Config lookup specifics)
- [x] 8.3 Write 4th-path rejection behavior: if a 4th path reference is detected while 3 are already active, the agent SHALL notify the user that the maximum of 3 references is active and ask which existing reference to replace, if any (REQ-006.5)

---

## Phase 9: Security Boundaries (Pattern 7)
- [x] 9.1 Write forbidden path list with exact patterns: `~/.ssh`, `~/.gnupg`, `~/.aws`, `~/.config/gcloud`, `/etc/shadow`, `/etc/passwd`, `/etc/sudoers`, any path containing `.ssh`, `credentials`, `secrets`, `.gnupg`; filesystem roots: `/`, `C:\`, `D:\` (and other drive letters); rejection message template (REQ-010.2; design: Security Boundaries, forbidden paths list)
- [x] 9.2 Write path traversal defense rule: if any resolved file path from Glob/Grep results escapes the registered base path (e.g., via symlinks resolving outside the tree), skip that file and warn the user; the skill NEVER writes, modifies, or deletes files in the referenced path — all operations are Read, Glob, Grep, or read-only Bash (REQ-010.3, REQ-010.4; design: path traversal defense)

---

## Phase 10: Hard-Coded Ignore List
- [x] 10.1 Write the complete ignore list section in SKILL.md with all directories and file type exclusions:
  - Directories: `node_modules/`, `.git/`, `dist/`, `vendor/`, `__pycache__/`, `.next/`, `target/`, `build/`, `.venv/`, `coverage/`, `.turbo/`, `.cache/`, `.parcel-cache/`, `.nuxt/`, `.output/`, `.svelte-kit/`
  - Binary file extensions: `.jpg`, `.png`, `.gif`, `.pdf`, `.zip`, `.exe`, `.dll`, `.wasm`, `.bin`
  - Lock files (excluded from reads, allowed for language detection only): `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `Cargo.lock`, `go.sum`, `poetry.lock`
  - Note that this list is HARD-CODED and NOT configurable via `path-context.yaml` (REQ-007.1–REQ-007.4; design: Ignore List section)

---

## Phase 11: Config Schema Reference
- [x] 11.1 Write `path-context.yaml` config schema reference section in SKILL.md: include config lookup order (project `.claude/` first, then global `~/.claude/`), full YAML example with all optional fields annotated, parsing rules (missing `path` key = skip entry + warn; `alias` defaults to `basename(path)`; `include` is additive filter; `exclude` removes from candidates even if matching `include`; empty `paths` array = equivalent to no config; config file is READ-ONLY at runtime) (REQ-008.1–REQ-008.9; design: Config Schema section)

---

## Phase 12: `assets/path-context.yaml` Config Template
- [x] 12.1 Write `assets/path-context.yaml` with full schema, all optional fields present with commented explanations, two example path entries (one with all optional fields populated, one minimal), config lookup order comment at the top, and a note about which fields are required vs. optional (REQ-008.1–REQ-008.9, REQ-002.1; design: path-context.yaml Config Schema section; spec schema reference block)

---

## Phase 13: Resources Section
- [x] 13.1 Write "Resources" section at the end of SKILL.md pointing to `assets/path-context.yaml` as the config template to copy to `~/.claude/path-context.yaml` or `.claude/path-context.yaml`; include `--add-dir` usage note recommending it for large projects (design: SKILL.md Structure table, Resources row; spec SCN-006)

---

## Phase 14: Skill Registry Update
- [x] 14.1 Check if `.atl/skill-registry.md` exists in the project; if not check `~/.claude/skills/_shared/` or any `.atl/` directory for the registry file (design: File Layout)
- [x] 14.2 Add `path-context` skill entry to the registry with: trigger context (`@context`, `reference path`, `reference folder`, `reference project`, `use as context`, `add context from`, `load context`, `path context`, `contexto de`, `referenciar`), skill path (`~/.claude/skills/path-context/SKILL.md`), and compact rule summary for injection into sub-agent prompts (design: architecture decisions; REQ-001.1)
