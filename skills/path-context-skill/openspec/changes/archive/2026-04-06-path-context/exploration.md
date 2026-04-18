# Exploration: path-context

## Summary

We are building a Claude Code skill (`path-context`) — a `SKILL.md` file that instructs AI agents how to (1) register a folder from another project as a reference context, (2) intelligently discover and surface the most relevant files from that folder without blowing the context window, and (3) automatically detect when a path reference appears in conversation and activate the behavior. This is a pure instruction skill — no binaries, no vector databases, no external tooling required.

---

## Key Findings

### 1. Semantic Search Without External Tools

**The core question**: can an AI agent do relevance-ranked file discovery using only `Glob`, `Grep`, `Read`, and `Bash`?

**Answer: Yes — with structured heuristics.** True vector-semantic search (embedding similarity) requires an external tool. But "semantic" in this context really means "relevant-to-the-task", and that can be approximated effectively with a multi-pass strategy:

#### Heuristic Layers (ordered by signal strength)

| Pass | Mechanism | Signal |
|------|-----------|--------|
| 1. Directory topology | `Bash: ls -la` or `Glob: **/*` (depth-limited) | Understand project type, main entry points |
| 2. Entry point detection | Look for `main.*`, `index.*`, `app.*`, `cmd/`, `src/` | Highest-value files first |
| 3. Keyword grep | `Grep: {task_keywords}` across `**/*.{ext}` | Find files that mention concepts in the task |
| 4. Import graph shallow scan | Grep for `import`, `require`, `use`, `from` in found files | Discover what the entry points depend on |
| 5. Naming signal | File names containing task noun (e.g., "auth", "user", "payment") | Zero-read signal |
| 6. Recency signal | `Bash: git log --name-only -20` if git repo | Most recently changed = most active |

**What's achievable**: for a typical project of 50-300 files, this 6-pass approach can identify the 5-15 most relevant files for any given task in under 30 seconds of agent tool calls, and the agent passes those to context — NOT the whole folder.

**Hard limit**: the skill MUST enforce a "context budget" — never read more than N files (suggested: 10-15) from the referenced folder per task. Each Read call costs tokens; the skill should be defensive about this.

**Vectorless RAG as prior art**: The PageIndex paper (VectifyAI, 2024) validates this approach — LLM reasoning over a hierarchical tree index (directory structure = natural tree) can match vector similarity for file retrieval tasks without external infrastructure.

#### What "semantic" means practically for this skill:
- NOT cosine similarity on embeddings
- YES to: given the agent's current task/question, find the files in the referenced folder that are most likely relevant, using naming, keywords, imports, and structure as signals

---

### 2. Folder Reference Mechanism

**How should the user specify the referenced path?**

Three options identified:

#### Option A: Native `--add-dir` flag (Claude Code v1.0.18+)
Claude Code ships `--add-dir /path/to/other-project` as a CLI flag (and `/add-dir` as a slash command mid-session). This makes files in that directory available to the agent's Read/Grep/Glob tools natively.

**Pros**: zero skill complexity, uses built-in tooling, agent can directly Glob/Read those files
**Cons**: requires the user to pass the flag at startup or type `/add-dir` mid-session; the skill can't enforce it; no persistence of "I always reference this path"
**Verdict**: this is the RIGHT foundation. The skill should build on top of `--add-dir`, not replace it.

#### Option B: In-prompt declaration (markdown/natural language)
User types: `@context /projects/my-api` or `reference: /projects/my-api` in their prompt or in `CLAUDE.md`.

**Pros**: works immediately, no CLI changes, user can do it anytime
**Cons**: the skill must parse this from the conversation, fragile, no standard syntax
**Verdict**: useful as the auto-trigger mechanism, BUT the agent still needs the dir added to its access scope (via `--add-dir` or explicit Read calls with absolute paths)

#### Option C: Config file (`.claude/path-context.yaml`)
A file at `~/.claude/path-context.yaml` or project `.claude/path-context.yaml` listing referenced paths.

**Pros**: persistent, discoverable, version-controllable
**Cons**: requires a write step; agent must read config on activation
**Verdict**: valuable for the "always use this reference" use case (e.g., always reference the shared `~/projects/design-system`)

**Recommended design**: support ALL three mechanisms with clear priority:
1. Config file (persistent, highest priority)
2. `--add-dir` (session-level, already built into Claude Code)
3. In-prompt declaration (ad-hoc, triggers the skill to activate for this turn)

---

### 3. Agent Auto-Discovery

**The question**: how does an agent automatically detect a path reference and activate the skill?

#### What Claude Code skills can do for auto-triggering

From research into the Claude Code skill spec:
- Skills are triggered by **Trigger** keywords in the frontmatter `description` field
- The agent loads a skill when it detects matching phrases in the conversation
- There is NO hook/plugin system for arbitrary code execution on pattern match

**Therefore**: the auto-discovery mechanism is the **Trigger field** in the SKILL.md frontmatter. If the trigger includes patterns like:
```
@context, reference path, use as context, reference folder, add context from, contexto de, referenciar proyecto
```
...the agent will load the skill when those phrases appear.

#### Sub-agent component

The "agent that automatically discovers and uses referenced paths" is best implemented as:

1. **Activation**: Trigger in SKILL.md frontmatter fires when path reference appears
2. **Discovery protocol**: The SKILL.md defines a step-by-step protocol the agent follows:
   - Step 1: Detect the referenced path (from config, `--add-dir`, or in-prompt)
   - Step 2: Run the folder topology scan (Bash/Glob, depth-limited)
   - Step 3: Run the relevance heuristics against the current task
   - Step 4: Read the top N files and inject as context
   - Step 5: Proceed with the original task, now informed by the reference context

There is NO separate binary or sub-agent required. The SKILL.md instructions ARE the agent logic.

**Key insight**: this is not a runtime agent — it's a BEHAVIORAL PROTOCOL encoded in markdown that the AI agent executes as its own reasoning process.

---

### 4. Prior Art & Inspiration

#### Claude Code `--add-dir` (native)
Already solved the "access" problem. `--add-dir /path` gives the agent read access to an external directory. What's missing is the PROTOCOL for intelligently using that access without dumping everything into context.

**Gap this skill fills**: `--add-dir` gives access; `path-context` gives intelligence about WHAT to read and HOW to present it.

#### Open feature request: configure `--add-dir` via settings.json
GitHub issue #3146 on `anthropics/claude-code`: users want persistent `--add-dir` configuration in `settings.json` rather than CLI flags. This validates the config-file approach (Option C above) as a real user need.

#### Cursor's codebase indexing
Cursor builds a semantic index of the entire project and all referenced directories. For Claude Code skills (no persistent index), the equivalent is the multi-pass heuristic search described in Finding 1. The key difference: Cursor's index is prebuilt; our approach is on-demand but targeted.

#### GitHub Copilot's RAG retrieval
Copilot uses GitHub code search + RAG against GitHub-hosted repos. For local paths, Copilot relies on the open files in the IDE. Our skill fills a similar gap for CLI-based Claude Code: intelligent, targeted file retrieval from a local path.

#### Aider's explicit file management
Aider requires the user to `/add` files explicitly. Our skill automates this discovery — you specify a folder, the skill figures out which files matter for the current task. This is the core value-add.

#### PageIndex (VectifyAI)
Vectorless reasoning-based RAG using document tree structure. Directly validates the directory-tree-as-index approach in Finding 1.

#### LLM Semantic File System (arXiv:2410.11843)
Proposes using LLMs to navigate file systems via semantic context. Confirms feasibility of our approach.

---

### 5. Constraints & Risks

#### Context Window Pollution (HIGH RISK)
If the skill reads too many files from the referenced folder, it pollutes the agent's context window and crowds out the actual task. **Mitigation**: strict budget (max 10-15 files), explicit summarization step where appropriate, and a "relevance threshold" — if no files score high on heuristics, report that to the user rather than dumping low-relevance files.

#### Path Accessibility on Windows (MEDIUM RISK)
Windows paths (`C:\`, `\\server\share`) differ from Unix paths. The skill must handle both, and `--add-dir` behavior on Windows needs verification. **Mitigation**: document path format requirements; prefer forward-slash normalization.

#### Trigger Collision (LOW-MEDIUM RISK)
If trigger phrases are too broad (e.g., just "context"), the skill activates too eagerly. If too narrow, it never fires. **Mitigation**: use specific multi-word triggers (`@context`, `reference path`, `use as context`).

#### No Persistent State Between Turns (MEDIUM RISK)
Skills don't have memory between conversation turns. If the user says `@context /projects/api` in turn 1, the skill won't remember this in turn 5 unless the agent is explicitly told to maintain it (via CLAUDE.md or the config file). **Mitigation**: config file approach (`path-context.yaml`) persists the reference; CLAUDE.md `@context` declarations persist across turns.

#### Security: Path Traversal (LOW RISK — worth documenting)
An agent following the skill's instructions to read files from an arbitrary path could be directed to read sensitive files (e.g., `~/.ssh`). **Mitigation**: the skill should include an explicit instruction to validate that the referenced path is a project folder (has recognizable project structure) before scanning.

#### Over-Engineering Risk (MEDIUM)
Trying to build "semantic search" as a complex multi-step pipeline when a well-crafted 3-step heuristic (topology + grep + import scan) covers 90% of use cases. **Mitigation**: start with the 3-step version; the skill can evolve.

---

## Recommended Approach

Build a single `SKILL.md` with three logical components encoded as behavioral protocols:

### Component 1: Activation (Trigger)
Multi-phrase trigger that fires when:
- User types `@context <path>` in prompt
- User says "reference [folder/project/path]" or similar
- A path literal appears with "context", "reference", or "use"

### Component 2: Path Registration Protocol
Instructions for the agent to:
1. Check `~/.claude/path-context.yaml` or `.claude/path-context.yaml` for pre-registered paths
2. If `--add-dir` was used, those paths are already accessible
3. Accept in-prompt path declarations
4. NEVER attempt to access paths not registered by the user

### Component 3: Intelligent Discovery Protocol
A clear numbered protocol the agent executes for any referenced path:
1. **Topology scan** — understand the project structure (max depth 3, Glob)
2. **Entry point identification** — find `main`, `index`, `app`, `cmd/`, `src/`
3. **Task-keyed grep** — extract 3-5 keywords from the current task, grep for them
4. **Import chain** — from found files, identify their direct imports
5. **Budget enforcement** — select top 10 files max, state which were selected and why
6. **Inject** — read selected files and proceed with the task

### Key decisions:
- **No external tooling required** — works with Glob + Grep + Read + Bash only
- **Builds on `--add-dir`** — documents it as the recommended access mechanism, doesn't replace it
- **Config file as optional enhancement** — `path-context.yaml` for persistent references
- **Explicit budget** — always state what was selected and what was omitted
- **Single SKILL.md** — no sub-agents, no binary, no runtime code

---

## Open Questions for Design Phase

1. **YAML config schema**: what should `path-context.yaml` look like? Single path? Array? With metadata (description, file patterns to ignore)?

2. **Activation granularity**: should the skill activate once per conversation (setting up a persistent "reference context" mode) or once per turn (re-running discovery each time)?

3. **Summarization mode**: for very large referenced projects (500+ files), should the skill produce a one-shot summary (project map) stored in context, rather than re-running discovery each turn?

4. **Output format**: how does the agent communicate to the user what it loaded from the reference context? Inline annotation? Separate section? Silent?

5. **Multiple references**: can the user reference more than one folder? (e.g., `@context /api` AND `@context /design-system`). How does budget split between them?

6. **Interaction with `--add-dir`**: should the skill explicitly instruct the user to use `--add-dir` before referencing a path, or should it attempt to Read files by absolute path even without it?

7. **Pattern ignore list**: should the skill always skip `node_modules/`, `.git/`, `dist/`, `vendor/` etc.? These are standard noise — probably yes, hard-coded.
