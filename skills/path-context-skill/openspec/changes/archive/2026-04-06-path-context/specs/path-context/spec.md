# Spec: path-context skill

## Overview

The `path-context` skill gives Claude Code agents a structured behavioral protocol for registering external project folders as reference context, intelligently discovering the most relevant files within those folders using a 6-pass heuristic, and injecting those files into the conversation within a strict token budget. The skill is implemented as a single `SKILL.md` file that encodes agent behavior — no binaries, no external dependencies, no persistent indexes. It builds on top of Claude Code's native `--add-dir` mechanism rather than replacing it, filling the gap between "having access to a folder" and "knowing which files in that folder matter for the current task."

---

## Requirements

### REQ-001: Skill Activation

- REQ-001.1: The skill MUST activate when any of the following trigger phrases appear in the conversation: `@context`, `reference path`, `reference folder`, `reference project`, `use as context`, `add context from`, `load context`, `path context`, `contexto de`, `referenciar`.
- REQ-001.2: Trigger phrases MUST be multi-word or prefixed (e.g., `@context`) to prevent false activation on bare words like "context" or "path".
- REQ-001.3: The skill MUST activate at most once per conversation turn. Discovery results SHALL be retained in agent working memory for the remainder of the conversation and MUST NOT be re-executed on every subsequent turn unless the user explicitly requests a refresh.
- REQ-001.4: The skill MUST be usable standalone by a sub-agent with zero extra hops — all behavioral instructions SHALL be self-contained in `SKILL.md`.
- REQ-001.5: The skill MUST NOT activate on trigger phrases that appear inside code blocks, file paths unrelated to a reference request, or quoted text.

---

### REQ-002: Path Registration

The skill MUST support three path registration mechanisms, resolved in the following priority order (highest first):

- REQ-002.1: **Config file** — The agent MUST check for a `path-context.yaml` file at `~/.claude/path-context.yaml` (global) and `.claude/path-context.yaml` (project-level). If both exist, project-level entries SHALL take precedence over global entries for the same alias. Config file paths are treated as persistent references and MUST be loaded on skill activation.
- REQ-002.2: **`--add-dir` session flag** — Paths registered via Claude Code's native `--add-dir` CLI flag or `/add-dir` slash command SHALL be recognized as accessible references. The skill MUST document `--add-dir` as the recommended access mechanism for heavy use or large projects.
- REQ-002.3: **In-prompt declaration** — A path literal appearing with a recognized trigger phrase (e.g., `@context /projects/my-api`, `reference path /home/user/lib`) MUST be accepted as an ad-hoc reference for the current session. The agent MUST extract the absolute path from the declaration.
- REQ-002.4: The agent MUST NOT attempt to access any path not registered through one of the three mechanisms above.
- REQ-002.5: If a declared path does not exist or is not accessible, the agent MUST report this to the user immediately and abort the discovery protocol for that path.
- REQ-002.6: On Windows, the skill MUST accept both backslash (`C:\path\to\project`) and forward-slash (`C:/path/to/project`) path formats and normalize them to forward-slash internally before processing.

---

### REQ-003: Discovery Protocol

For each registered path, the agent SHALL execute the following 6-pass heuristic in order. Each pass is additive — results are accumulated across passes before final budget enforcement.

- REQ-003.1: **Pass 1 — Topology scan**: The agent MUST run `Glob **/* --depth 3` on the referenced path to understand the project structure. The agent SHALL identify the language and framework by inspecting file extensions and the presence of config files (`package.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`, `pom.xml`, `build.gradle`, `*.csproj`, etc.). This pass MUST NOT read file contents.
- REQ-003.2: **Pass 2 — Entry point detection**: The agent MUST search for files matching `main.*`, `index.*`, `app.*`, and directories named `cmd/`, `src/`, `lib/`. Up to 3 entry point files SHALL be added to the candidate set. These files MUST be given the highest initial ranking score.
- REQ-003.3: **Pass 3 — Keyword grep**: The agent MUST extract 3–5 topic nouns from the current task description. It SHALL run `Grep` across source files in the referenced path for each extracted keyword. Files MUST be ranked by total match count across all keywords. Files with zero matches across all keywords SHALL receive the lowest score for this pass.
- REQ-003.4: **Pass 4 — Import chain**: From files found in passes 2 and 3, the agent SHALL grep for import/require/use/from statements to identify direct dependencies within the referenced project. Identified dependency files SHALL be added to the candidate set with a medium priority score.
- REQ-003.5: **Pass 5 — Naming signal**: The agent SHALL score all files in the Glob result whose names (excluding extension) contain any of the 3–5 task keywords. This pass requires no file reads and MUST be executed before any Read calls.
- REQ-003.6: **Pass 6 — Recency signal**: If the referenced path is a git repository, the agent SHALL run `git log --name-only -20` to identify the 20 most recently modified files. Files appearing in the recency list SHALL receive a score boost. This pass is OPTIONAL — if the path is not a git repo, it MUST be skipped silently without error.
- REQ-003.7: After all passes, the agent MUST deduplicate the candidate set and rank files by aggregate score. Files in the ignore list (REQ-007) MUST be excluded at this point.
- REQ-003.8: If no files score above a zero-signal baseline (no keyword matches, no naming signal, no import hits, no entry points), the agent MUST NOT read arbitrary files to fill the budget. It SHALL report to the user that no relevant files were found and ask for clarification.

---

### REQ-004: Context Budget

- REQ-004.1: The agent MUST NOT read more than 15 files total from all referenced paths combined per conversation turn.
- REQ-004.2: When only one path is registered, the budget SHALL be 15 files for that path.
- REQ-004.3: When multiple paths are registered (up to 3), the budget SHALL be split equally: `floor(15 / number_of_paths)` files per path (e.g., 5 files each for 3 paths, 7 files each for 2 paths with the remainder going to the first path).
- REQ-004.4: The agent MUST NOT read any single file exceeding 500 lines. Files exceeding this limit SHALL be truncated to the first 500 lines, with a note in the output annotation indicating truncation.
- REQ-004.5: Budget limits are HARD — the agent MUST NOT exceed them under any circumstances, including explicit user requests to "read everything." If the user requests more files, the agent SHALL explain the budget constraint and offer to refine the discovery scope instead.
- REQ-004.6: The per-path budget calculation MUST use integer division (floor). No fractional file allocations are permitted.

---

### REQ-005: Output Annotation

- REQ-005.1: After executing the discovery protocol, the agent MUST produce an output annotation listing: (a) the referenced path(s), (b) the number of files read, (c) the names of files selected, and (d) the count of files omitted from the candidate set.
- REQ-005.2: The annotation MUST be presented before the agent proceeds to answer the original task. It SHALL NOT be silent or omitted.
- REQ-005.3: The annotation format SHOULD be collapsible (e.g., wrapped in a `<details>` block in Markdown-capable contexts) to avoid visual noise in long conversations.
- REQ-005.4: For each file in the selected set, the annotation SHOULD briefly state which pass(es) contributed to its selection (e.g., "entry point", "keyword match: auth, user", "import of index.ts").
- REQ-005.5: The annotation MUST include the total token/line count read, and note if any files were truncated due to the 500-line cap.
- REQ-005.6: If project map mode was activated (REQ-009), the annotation MUST indicate this explicitly and include the map summary in the annotation rather than listing individual files.

---

### REQ-006: Multiple References

- REQ-006.1: The skill MUST support up to 3 simultaneous path references.
- REQ-006.2: Each path reference MUST be processed independently through the full 6-pass discovery protocol.
- REQ-006.3: Budget SHALL be split equally across registered paths per REQ-004.3.
- REQ-006.4: If fewer than the budget-allocated number of files are relevant for one path, the unused slots from that path's allocation SHALL NOT be redistributed to other paths. Each path's budget is fixed.
- REQ-006.5: The agent MUST NOT register more than 3 paths simultaneously. If a 4th path reference is detected, the agent SHALL notify the user that the maximum of 3 references is active and ask which existing reference to replace, if any.
- REQ-006.6: Each registered path MAY be assigned an alias in the config file (e.g., `alias: design-system`). The agent MUST accept in-prompt references by alias (e.g., `@context design-system`) as equivalent to the full path.

---

### REQ-007: Ignore List

- REQ-007.1: The following directory and file patterns MUST always be excluded from the Glob scan, keyword grep, import chain analysis, and all other discovery passes:
  - `node_modules/`
  - `.git/`
  - `dist/`
  - `vendor/`
  - `__pycache__/`
  - `.next/`
  - `target/`
  - `build/`
  - `.venv/`
  - `coverage/`
- REQ-007.2: The ignore list is HARD-CODED in `SKILL.md` and MUST NOT be configurable by the user via `path-context.yaml`. It represents universal noise that no reference context requires.
- REQ-007.3: Binary files (`.jpg`, `.png`, `.gif`, `.pdf`, `.zip`, `.exe`, `.dll`, `.wasm`, `.bin`) MUST also be excluded from all discovery passes.
- REQ-007.4: Lock files (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `Cargo.lock`, `go.sum`, `poetry.lock`) MUST be excluded from file reads but MAY be used for language/framework detection in Pass 1.

---

### REQ-008: path-context.yaml Config

- REQ-008.1: The config file MUST be valid YAML.
- REQ-008.2: The config file MUST contain a top-level `paths` key whose value is a sequence of path entry objects.
- REQ-008.3: Each path entry object MUST contain a `path` key with an absolute path string as its value.
- REQ-008.4: Each path entry MAY contain an `alias` key with a short string identifier for in-prompt reference.
- REQ-008.5: Each path entry MAY contain an `include` key with a sequence of glob strings to restrict discovery to matching files within the referenced path.
- REQ-008.6: Each path entry MAY contain an `exclude` key with a sequence of glob strings to additionally exclude files from discovery beyond the hard-coded ignore list (REQ-007).
- REQ-008.7: The config file MUST be read-only at runtime — the agent MUST NOT write to or modify the config file.
- REQ-008.8: A config file with no `paths` entries (empty array) MUST be treated as equivalent to no config file.
- REQ-008.9: The config file MUST NOT be required for skill operation. Its absence MUST NOT produce an error.

Reference schema:

```yaml
# ~/.claude/path-context.yaml or .claude/path-context.yaml
paths:
  - path: /absolute/path/to/project       # REQUIRED
    alias: design-system                   # OPTIONAL
    include: ["src/**", "lib/**"]          # OPTIONAL
    exclude: ["**/*.test.*"]               # OPTIONAL
  - path: /another/project
```

---

### REQ-009: Project Map Mode

- REQ-009.1: Project map mode MUST be activated automatically when the referenced path contains 500 or more files (after applying the ignore list from REQ-007).
- REQ-009.2: In project map mode, passes 3–6 of the discovery protocol (keyword grep, import chain, naming signal, recency signal) MUST be skipped.
- REQ-009.3: Instead of reading individual files, the agent SHALL produce a structural summary consisting of: (a) a directory tree at depth 2, (b) up to 3 identified entry point files with their first 50 lines, and (c) the first 200 lines of `README.md` if present.
- REQ-009.4: The structural summary SHALL be injected into context as a "project map" and labeled as such in the output annotation (REQ-005.6).
- REQ-009.5: Project map mode MUST respect the same per-path budget ceiling — the structural summary content MUST NOT exceed the equivalent token cost of 15 file reads. If the tree and entry points together exceed this, the agent SHALL truncate the tree depth before truncating entry point reads.
- REQ-009.6: The agent SHOULD inform the user that project map mode is active and offer to run targeted discovery on a sub-directory if the user narrows the scope.

---

### REQ-010: Security

- REQ-010.1: Before executing the discovery protocol on any registered path, the agent MUST validate that the path exhibits recognizable project structure. A path is considered valid if it contains at least one of: a recognized config file (`package.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`, `pom.xml`, `*.csproj`, `Makefile`, `CMakeLists.txt`), a `src/` or `lib/` subdirectory, or more than 3 source code files at the root level.
- REQ-010.2: The agent MUST NOT register or scan the following path prefixes under any circumstances, even if explicitly requested:
  - `~/.ssh/`
  - `~/.gnupg/`
  - `/etc/`
  - `/proc/`
  - `/sys/`
  - `C:\Windows\System32\` (Windows)
- REQ-010.3: The agent MUST NOT follow symbolic links outside the registered path boundary during Glob or Grep operations.
- REQ-010.4: The agent MUST NOT execute any shell commands found within files discovered in the referenced path. Discovery is READ-ONLY.
- REQ-010.5: If path validation (REQ-010.1) fails, the agent MUST refuse to run discovery, inform the user, and suggest using `--add-dir` with an explicit project directory.

---

## Scenarios

### SCN-001: Basic Reference (In-Prompt)

**Given** the user has launched Claude Code without `--add-dir` and the referenced project exists at `/projects/my-api`

**When** the user types: `@context /projects/my-api — I need to add rate limiting to the API`

**Then**:
1. The skill activates via the `@context` trigger
2. The agent registers `/projects/my-api` as an in-prompt reference
3. The agent validates that `/projects/my-api` has recognizable project structure (e.g., finds `package.json`)
4. The agent runs passes 1–6 with keywords extracted from "rate limiting API": `rate`, `limit`, `middleware`, `API`, `throttle`
5. The agent reads up to 15 files matching the highest-score candidates (e.g., `src/middleware/`, `src/routes/`, `app.ts`)
6. The agent outputs an annotation: `Loaded 8 files from /projects/my-api (7 omitted). Selected: app.ts [entry], middleware/auth.ts [keyword: middleware], routes/api.ts [keyword: API, limit] ...`
7. The agent proceeds to answer the rate limiting question using the loaded context

---

### SCN-002: Config File Reference

**Given** a `~/.claude/path-context.yaml` exists with:
```yaml
paths:
  - path: /projects/design-system
    alias: ds
    include: ["src/components/**", "tokens/**"]
```

**When** the user starts a new Claude Code session and asks: `reference project ds — how are buttons styled?`

**Then**:
1. The skill activates via the `reference project` trigger
2. The agent reads `~/.claude/path-context.yaml` and resolves alias `ds` to `/projects/design-system`
3. Discovery is constrained to `src/components/**` and `tokens/**` glob patterns
4. Pass 3 keywords: `button`, `style`, `component`, `token`, `css`
5. The agent reads up to 15 files from the filtered set
6. The annotation notes the config file source and the applied include filter
7. The agent answers the styling question from the loaded files

---

### SCN-003: Multiple References

**Given** the user has registered two paths:
- `@context /projects/api` (backend, ~120 files)
- `@context /projects/frontend` (React app, ~80 files)

**When** the user asks: `How does the frontend call the user authentication endpoint?`

**Then**:
1. Both paths are active references
2. Budget splits: `floor(15 / 2) = 7` files per path
3. Keywords: `user`, `auth`, `endpoint`, `fetch`, `call`
4. `/projects/api`: discovery returns `routes/auth.ts`, `middleware/jwt.ts`, `controllers/user.ts` + 4 more (7 total)
5. `/projects/frontend`: discovery returns `services/auth.service.ts`, `hooks/useAuth.ts`, `api/client.ts` + 4 more (7 total)
6. Annotation lists both paths with their respective file selections
7. The agent cross-references both sets to answer the question

---

### SCN-004: Large Project (Map Mode)

**Given** the referenced path `/projects/monorepo` contains 1,200 files after ignore-list filtering

**When** the user types: `@context /projects/monorepo — give me an architectural overview`

**Then**:
1. Pass 1 (topology scan) detects 1,200 files → project map mode activates
2. Passes 3–6 are skipped
3. The agent produces: directory tree at depth 2 + 3 entry point file excerpts (50 lines each) + first 200 lines of `README.md`
4. The annotation explicitly states: `Project map mode active (1,200 files detected). Individual file discovery skipped.`
5. The agent offers: `To run targeted discovery on a sub-package, specify a subdirectory (e.g., @context /projects/monorepo/packages/auth).`
6. The agent uses the project map to answer the architectural overview question

---

### SCN-005: No Relevant Files Found

**Given** the user has registered `/projects/billing-service` (a Python microservice) and the current task is about `React component styling`

**When** the user asks: `@context /projects/billing-service — how should I style this modal?`

**Then**:
1. The skill activates and runs passes 1–6
2. Keywords: `modal`, `style`, `component`, `css`, `react`
3. Pass 3 (keyword grep): zero matches across all source files (billing-service has no frontend code)
4. Pass 5 (naming signal): no files named `modal`, `style`, `component`, `css`, or `react`
5. Aggregate scores are all at zero-signal baseline
6. The agent MUST NOT read arbitrary Python files to fill the budget
7. The agent responds: `No relevant files found in /projects/billing-service for this task (modal styling). This appears to be a backend service with no frontend code. Do you want to reference a different path, or should I answer based on general React knowledge?`

---

### SCN-006: Missing --add-dir (Absolute Path Fallback)

**Given** the user has NOT used `--add-dir` and types `@context /projects/shared-lib`

**When** the agent attempts to execute discovery using `Glob` and `Read` tool calls

**Then**:
1. The agent proceeds with absolute path reads (`Read /projects/shared-lib/...`) without requiring `--add-dir`
2. If any Read call fails with a permission or not-found error, the agent reports: `Could not read /projects/shared-lib. If this path requires explicit access, run: claude --add-dir /projects/shared-lib` and halts discovery for that path
3. If reads succeed, discovery proceeds normally — `--add-dir` is documented as recommended but not required
4. The output annotation notes: `Accessed via absolute path reads. For large projects, consider launching with --add-dir /projects/shared-lib for better performance.`
