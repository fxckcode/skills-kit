---
name: path-context
description: >
  Behavioral protocol for intelligently loading external project folders as reference context.
  Registers paths via config file, --add-dir, or in-prompt declaration, then runs a 6-pass
  heuristic discovery to select the most relevant files within a strict budget (15 files max).
  Trigger: When user says "@context", "reference path", "reference folder", "reference project",
  "use as context", "add context from", "load context", "path context", "contexto de",
  "referenciar", "cargar contexto".
license: Apache-2.0
metadata:
  author: fxckcode
  version: "1.0"
---

## When to Use

- User provides a path with a trigger phrase: `@context /projects/my-api`
- User references a config alias: `@context design-system — how are buttons styled?`
- User asks about patterns from another project: `reference project /projects/core-api`
- User wants a structural overview of a large codebase: `@context /projects/monorepo`
- User explicitly requests a context refresh: `refresh context` or `re-scan`
- Multi-path cross-reference: `@context /projects/api @context /projects/frontend`

## Activation Rules

- Activate **once per conversation turn** — discovery runs on trigger and results persist in working memory for the rest of the session
- Re-trigger only when: user provides a new path, user starts a clearly different task referencing the same path, or user says "refresh context" / "re-scan"
- Do NOT activate when trigger phrases appear inside code blocks, quoted text, or file paths unrelated to a reference request
- Do NOT re-run discovery on every subsequent turn — use cached context

---

## Critical Patterns

### Pattern 1: Path Registration Protocol

When the skill activates, follow this exact sequence:

**Step 1 — Read config files**

```
1a. Read ~/.claude/path-context.yaml    (global config — lower priority)
1b. Read .claude/path-context.yaml     (project config — higher priority)
1c. Merge: project config takes precedence for same aliases
1d. Collect all `paths` entries from merged config
    - Empty `paths` array = no config (treat as absent)
    - Missing file = fine, proceed without it
```

**Step 2 — Parse in-prompt path literals**

```
2a. Extract absolute path literals from the triggering message:
    - Starts with /         → Unix absolute path
    - Starts with ~/        → Home-relative path
    - Starts with C:\ or C:/ (or any drive letter) → Windows absolute path
2b. Normalize: resolve ~/ to $HOME; convert backslash to forward-slash on Windows
2c. Check alias lookup: if the reference matches a config `alias`, resolve to its `path`
2d. Add parsed paths to the collection
```

**Step 3a — Existence and project structure check**

```
For each collected path:
  - Verify existence: Bash "test -d {path} && echo EXISTS || echo MISSING"
  - If MISSING → report to user and skip this path entirely
  - If EXISTS → run Glob {path}/* depth 1 and look for project indicators:
      package.json, go.mod, Cargo.toml, pyproject.toml, pom.xml, build.gradle,
      *.csproj, .git, src/, lib/, cmd/, README.md, Makefile, CMakeLists.txt
  - If NO indicators found → warn user: "Path {path} doesn't look like a project
    folder. Proceeding anyway, but results may be noisy."
  - If validation fails and user insists → suggest: "Use --add-dir with an explicit
    project directory for better results."
```

**Step 3b — Security validation (MANDATORY — reject before any reads)**

```
Resolve path to absolute. REJECT immediately if it matches any of:
  - ~/.ssh  or  any path containing ".ssh"
  - ~/.gnupg  or  any path containing ".gnupg"
  - ~/.aws  or  any path containing "credentials" or "secrets"
  - ~/.config/gcloud
  - /etc/  /etc/shadow  /etc/passwd  /etc/sudoers
  - /proc/  /sys/
  - C:\Windows\System32\ (Windows)
  - Filesystem roots: /  C:\  D:\  (and other bare drive letters)

On rejection output:
  "Security: path {path} is restricted. The path-context skill only loads project folders."
Do NOT proceed with that path under any circumstances.
```

**Step 4 — Apply limits and calculate budget**

```
4a. Max 3 simultaneous path references
4b. If more than 3 detected → use only the first 3, warn user about the rest
4c. Per-path budget: floor(15 / number_of_paths)
      1 path  → 15 files
      2 paths →  7 files each  (14 total)
      3 paths →  5 files each  (15 total)
4d. If a 4th path is requested while 3 are active → notify user: "Maximum of 3
    references active. Which existing reference should I replace?"
4e. Budget is HARD — never exceed under any circumstances, including user requests
    to "read everything". Explain the constraint and offer to refine scope instead.
```

---

### Pattern 2: 6-Pass Discovery Protocol

Execute all 6 passes **for each registered path**. Passes 1–2 read files; passes 3–6 produce candidates and signals only (no reads until final selection).

**Pass 1 — Topology Scan** (MUST NOT read file contents)

```
Tool call:
  Glob pattern="**/*" path={registered_path}

Extract:
  - Primary language by most common source extension (.ts/.js/.go/.py/.rs/.java/.cs)
  - Framework by config file presence:
      package.json       → Node.js
      go.mod             → Go
      Cargo.toml         → Rust
      pyproject.toml / setup.py → Python
      pom.xml / build.gradle    → Java/Kotlin
      angular.json       → Angular
      next.config.*      → Next.js
      nuxt.config.*      → Nuxt
      vite.config.*      → Vite
  - Total file count after ignore-list filtering
  - Directory structure pattern (flat / src-based / cmd-based / monorepo)

SHORT-CIRCUIT: If file count > 500 → activate Project Map Mode (Pattern 4).
               Skip passes 3–6 entirely. Pass 2 (entry point detection) still runs.
```

**Pass 2 — Entry Point Detection** (consumes budget: up to 3 files READ)

```
Tool calls:
  Glob: {path}/**/main.*
  Glob: {path}/**/index.*        (source extensions only — not .json, .yaml, .lock)
  Glob: {path}/**/app.*
  Glob: {path}/cmd/**/*.*
  Glob: {path}/src/main.*
  Glob: {path}/src/index.*
  Glob: {path}/src/app.*
  Glob: {path}/lib/index.*

Framework-specific extras (based on Pass 1):
  Next.js → {path}/app/layout.*  {path}/src/app/layout.*  {path}/pages/_app.*
  Angular → {path}/src/app/app.module.*  {path}/src/app/app.component.*
  Go      → {path}/cmd/*/main.go  {path}/main.go
  Rust    → {path}/src/main.rs  {path}/src/lib.rs
  Python  → {path}/**/__main__.py

Select up to 3 entry points, prioritized: main > app > index
READ these files immediately (count toward per-path budget).
Assign: highest initial ranking score.
```

**Pass 3 — Keyword Grep** (candidates only — NO reads)

```
Extract 3–5 domain nouns from the user's current task message.
  Exclude: stop words, generic programming terms (function, class, variable, etc.)
  Example: "implement auth middleware using the API project's patterns"
           → keywords: auth, middleware, pattern

For each keyword:
  Grep: pattern={keyword} path={registered_path} type={primary_lang}
        output_mode=files_with_matches head_limit=10

Rank: count keyword matches per file across all greps.
  Files matching 2+ keywords → high priority
  Files matching 1 keyword   → medium priority
  Files matching 0 keywords  → lowest priority for this pass

Do NOT read files in this pass — collect paths only.
```

**Pass 4 — Import Chain** (candidates only — NO reads)

```
For each entry point file READ in Pass 2:
  Grep: pattern="(import|require|from|use)\s" path={entry_file}
        output_mode=content

Parse import paths. Resolve relative imports to absolute within the registered path.
Add resolved dependency files to candidate set: medium priority.
Do NOT read these files yet.
```

**Pass 5 — Naming Signal** (candidates only — NO reads, MUST run before additional Reads)

```
For each keyword from Pass 3:
  Glob: {path}/**/*{keyword}*.*

Filter out:
  - Test files: *.test.*  *.spec.*  *_test.*
  - Files in ignored directories (see Ignore List section)

Add matched files to candidate set: medium priority.
```

**Pass 6 — Recency Signal** (signal only — NO reads)

```
Tool call:
  Bash: cd {path} && git log --name-only --pretty=format: -20 2>/dev/null \
        | sort | uniq -c | sort -rn | head -20

If command fails or returns empty → skip this pass silently (not a git repo).
Apply score BOOST to files appearing in recency output.
Boost is a TIEBREAKER only — not a standalone signal.
```

**Deduplication and Final Ranking**

```
1. Merge candidate lists from passes 3–6; remove duplicates
2. Apply scoring (mental model — no literal computation):

   Signal                               | Weight
   ─────────────────────────────────────|──────────────────────────────────
   Entry point (Pass 2, already read)   | Highest
   2+ keyword matches (Pass 3)          | High
   1 keyword match (Pass 3)             | Medium
   Import dependency of entry point     | Medium
   Name contains task noun (Pass 5)     | Medium
   Recently modified top 5 (Pass 6)     | Boost / tiebreaker only

3. Prefer diversity: don't select 5 files from the same directory if candidates
   span multiple directories.
4. Apply ignore-list exclusion at this point.
5. READ top N candidates (N = remaining_budget after entry points consumed).
   If a file exceeds 500 lines → read first 200 lines only; note "(truncated — {total} lines)".

ZERO-SIGNAL GUARD: If ALL candidates score at zero-signal baseline (no keyword
matches, no naming signal, no import hits, no entry points found):
  → Do NOT read arbitrary files to fill the budget.
  → Output: "No relevant files found in {path} for this task. Do you want to
    reference a different path, or should I answer based on general knowledge?"
```

---

### Pattern 3: Budget Enforcement Algorithm

```
CONSTANTS:
  TOTAL_BUDGET    = 15    # max files across ALL paths combined
  MAX_PATHS       = 3     # max simultaneous path references
  MAX_LINES       = 500   # per-file line cap (read first 200 if exceeded)
  ENTRY_POINT_CAP = 3     # max entry points per path (Pass 2)

ALGORITHM (per path):
  1. per_path_budget = floor(TOTAL_BUDGET / number_of_paths)
  2. entry_points_read = min(entry_points_found, ENTRY_POINT_CAP)
  3. remaining_budget  = per_path_budget - entry_points_read
  4. Select top {remaining_budget} from ranked candidates (passes 3–6)
  5. Read selected files with truncation at MAX_LINES

TOTAL across all paths MUST NOT exceed TOTAL_BUDGET = 15.
Unused budget from one path MUST NOT be redistributed to other paths.

EDGE CASES:
  - Fewer files than budget → read all source files; budget unused is fine
  - No keyword matches     → rely on entry points + import chain only
  - No entry points found  → promote keyword/naming candidates to fill budget
  - All candidates are test files → skip tests; report "no production code found
    matching task"
  - User requests "read everything" → explain budget constraint; offer to refine
    discovery scope (e.g., target a subdirectory)
```

---

### Pattern 4: Project Map Mode

**Trigger**: Pass 1 detects > 500 files after ignore-list filtering.

**Behavior**: Skip passes 3–6 entirely. Pass 2 (entry point detection) still runs. Produce a structural summary instead.

**Tool calls**:

```
Step 1 — Directory tree (depth 2):
  Bash: cd {path} && find . -maxdepth 2 -type d \
    ! -path '*/node_modules/*' ! -path '*/.git/*' ! -path '*/dist/*' \
    ! -path '*/vendor/*' ! -path '*/__pycache__/*' ! -path '*/.next/*' \
    ! -path '*/target/*' ! -path '*/build/*' ! -path '*/.venv/*' \
    ! -path '*/coverage/*' | sort

Step 2 — Entry point detection (up to 3 files, first 50 lines each):
  Glob for main/index/app (same globs as normal Pass 2, framework-specific extras included)
  Read up to 3 entry points, prioritized: main > app > index

Step 3 — README excerpt:
  Read: {path}/README.md (first 200 lines)
  If no README → skip silently
```

**Output format**:

```markdown
## Project Map: {alias or path basename}

**Type**: {language} / {framework}
**Structure**: {flat | src-based | monorepo | cmd-based}
**Size**: ~{count} files

### Directory Structure
{depth-2 tree output}

### Entry Point
{file path} — {first 20 lines or summary}

### README Excerpt
{first 200 lines}

---
*This is a project map (500+ files). For targeted file access, ask about specific files or areas.*
```

**Budget**: Map mode consumes max 4 files (up to 3 entry points + README) from the per-path budget.

**After output**: Offer the user: `"To run targeted discovery on a sub-directory, specify a subdirectory (e.g., @context {path}/packages/auth)."`

---

### Pattern 5: Output Annotation

**Format** (wrap in `<details>` for collapsibility):

```markdown
<details>
<summary>Context loaded from {alias} ({path}) — {N} files</summary>

- `{file1}` — entry point
- `{file2}` — keyword match: auth, middleware
- `{file3}` — imported by main.ts
- `{file4}` — name contains "auth" (Pass 5)
- ({M} candidates omitted)

Total: {N} files read, ~{lines} lines. {If truncated: "Note: {K} files truncated at 200 lines."}

</details>
```

**Placement**: BEFORE the agent's response to the user's actual task.

**Repeat rules**:
- On subsequent turns referencing already-loaded context → do NOT re-output the annotation. Context is in working memory.
- Re-annotate only if re-discovery was triggered (new path or explicit refresh).

**Project Map annotation variant**:

```markdown
<details>
<summary>Context loaded from {alias} — Project map mode ({N} files detected)</summary>

Project map mode active ({N} files detected). Individual file discovery skipped.
{Include the project map summary here}

</details>
```

---

### Pattern 6: Multi-Reference Protocol

- Process each path **independently** through the full 6-pass discovery protocol
- Budget split: `floor(15 / num_paths)` — integer division only, no fractional allocations
- Unused budget from one path is NEVER redistributed to others
- Annotation lists each path separately with its own file selection

**Alias resolution**:
- Config entries MAY include an `alias` key
- Agent MUST accept in-prompt references by alias (`@context design-system`) as equivalent to the full path
- If no alias defined → `basename(path)` is the implicit default alias

**4th-path rejection**:
- If a 4th path reference is detected while 3 are active → notify user:
  `"Maximum of 3 references active. Which existing reference should I replace? Active: {alias1}, {alias2}, {alias3}."`

---

### Pattern 7: Security Boundaries

**Forbidden path prefixes (HARD REJECT — no exceptions)**:

```
~/.ssh         (and any path containing ".ssh")
~/.gnupg       (and any path containing ".gnupg")
~/.aws         (and any path containing "credentials" or "secrets")
~/.config/gcloud
/etc/          (includes /etc/shadow, /etc/passwd, /etc/sudoers)
/proc/
/sys/
C:\Windows\System32\
Filesystem roots: /  C:\  D:\  (bare drive roots)
```

**Validation logic** (applied in Registration Step 3b):

```
1. Resolve path to absolute (expand ~, resolve ..)
2. Check against forbidden list: substring match for keywords, exact match for roots
3. If forbidden → reject immediately with:
   "Security: path {path} is restricted. The path-context skill only loads project folders."
4. If allowed → proceed with project indicator check
```

**Path traversal defense**:
- If any resolved file path from Glob/Grep results escapes the registered base path (e.g., via symlinks resolving outside the tree) → skip that file and warn the user

**Read-only guarantee**:
- This skill NEVER writes, modifies, or deletes files in the referenced path
- All operations are Read, Glob, Grep, or read-only Bash commands

---

## Ignore List (Hard-Coded — NOT Configurable)

Always exclude from ALL discovery passes (Glob, Grep, and Bash commands):

**Directories**:
```
node_modules/   .git/           dist/           vendor/
__pycache__/    .next/          target/         build/
.venv/          coverage/       .turbo/         .cache/
.parcel-cache/  .nuxt/          .output/        .svelte-kit/
```

**Binary file extensions** (excluded from all passes):
```
.jpg  .png  .gif  .pdf  .zip  .exe  .dll  .wasm  .bin
```

**Lock files** (excluded from reads; allowed for language detection in Pass 1 only):
```
package-lock.json  yarn.lock  pnpm-lock.yaml  Cargo.lock  go.sum  poetry.lock
```

Apply by:
- Filtering Glob results that contain these path segments
- Adding `! -path` exclusions in Bash `find` commands
- Skipping Grep matches whose paths contain these segments

---

## Config Schema Reference

**Config file locations** (checked in order, project takes precedence):
```
1. .claude/path-context.yaml       (project-level — highest priority)
2. ~/.claude/path-context.yaml     (global — fallback)
```

**Full schema**:
```yaml
paths:
  - path: /absolute/path/to/project     # REQUIRED — absolute path string
    alias: design-system                 # OPTIONAL — short name for in-prompt ref
    include:                             # OPTIONAL — restrict discovery to these globs
      - "src/**"
      - "lib/**"
      - "packages/core/**"
    exclude:                             # OPTIONAL — remove from candidates
      - "**/*.test.*"
      - "**/*.spec.*"
      - "**/*.stories.*"
      - "**/fixtures/**"

  - path: /another/project              # Minimal entry (alias defaults to basename)
```

**Parsing rules**:
- `path` is REQUIRED. If missing → skip entry and warn user.
- `alias` defaults to `basename(path)` (e.g., `/projects/design-system` → `design-system`).
- `include`: if specified, ONLY files matching at least one include pattern are considered (additive filter).
- `exclude`: removes files from candidates even if they match `include`.
- Both `include` and `exclude` are applied AFTER the hard-coded ignore list.
- Empty `paths` array → treated as no config file.
- Config file is READ-ONLY at runtime — never write to it.

---

## Commands

```bash
# Copy the config template to your preferred location:
cp ~/.claude/skills/path-context/assets/path-context.yaml ~/.claude/path-context.yaml
# or for project-level config:
cp ~/.claude/skills/path-context/assets/path-context.yaml .claude/path-context.yaml

# For large projects or repeated use, launch Claude Code with --add-dir:
claude --add-dir /projects/my-api
claude --add-dir /projects/design-system --add-dir /projects/api

# Or add the directory during a session (if supported):
/add-dir /projects/my-api
```

**Note on `--add-dir`**: The skill works without it (using absolute-path Read calls), but `--add-dir` enables Glob and Grep within the directory natively. For large projects or frequent cross-references, `--add-dir` is strongly recommended.

---

## Resources

- **Config template**: Copy `assets/path-context.yaml` to `~/.claude/path-context.yaml` (global) or `.claude/path-context.yaml` (project-level). The template is fully commented with all optional fields.
- **Quick setup**: Run `claude --add-dir /your/project` to register a path at launch, then use `@context /your/project` to trigger the skill.
