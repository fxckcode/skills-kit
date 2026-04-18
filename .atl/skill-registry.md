# Skill Registry

**Delegator use only.** Any agent that launches sub-agents reads this registry to resolve compact rules, then injects them directly into sub-agent prompts. Sub-agents do NOT read this registry or individual SKILL.md files.

See `_shared/skill-resolver.md` for the full resolution protocol.

**Generated**: 2026-04-18
**Project**: skills-kit

## User Skills

| Trigger | Skill | Path |
|---------|-------|------|
| When creating a pull request, opening a PR, or preparing changes for review | branch-pr | `~/.claude/skills/branch-pr/SKILL.md` |
| When writing Go tests, using teatest, or adding test coverage | go-testing | `~/.claude/skills/go-testing/SKILL.md` |
| When creating a GitHub issue, reporting a bug, or requesting a feature | issue-creation | `~/.claude/skills/issue-creation/SKILL.md` |
| When user says "judgment day", "judgment-day", "review adversarial", "dual review", "doble review", "juzgar", "que lo juzguen" | judgment-day | `~/.claude/skills/judgment-day/SKILL.md` |
| When writing, reviewing, or refactoring NestJS code | nestjs-best-practices | `~/.claude/skills/nestjs-best-practices/SKILL.md` |
| When working with Next.js App Router, Server Components, data fetching, routing patterns | nextjs-best-practices | `~/.claude/skills/nextjs-best-practices/SKILL.md` |
| When user explicitly says "Nothing style", "Nothing design", "/nothing-design", or directly asks to use/apply the Nothing design system | nothing-design | `~/.claude/skills/nothing-design/SKILL.md` |
| When user says "@context", "reference path", "reference folder", "reference project", "use as context", "add context from", "load context", "path context", "contexto de", "referenciar", "cargar contexto" | path-context | `~/.claude/skills/path-context/SKILL.md` |
| When user asks to create a new skill, add agent instructions, or document patterns for AI | skill-creator | `~/.claude/skills/skill-creator/SKILL.md` |

## Project Skills

| Trigger | Skill | Path |
|---------|-------|------|
| When user wants to set up/professionalize a repo, add docs/licensing, configure CI, prepare releases | git-setup-skill | `skills/git-setup-skill/SKILL.md` |
| When user wants to set up repo for Claude Code/Codex/Gemini CLI, prepare agent workflow, add TDD/BDD/ATDD/SDD setup | swarm-forge-skill | `skills/swarm-forge-skill/SKILL.md` |
| When user says "test API", "HTTP request", "curl", "REST call", "API E2E", "testear API", "llamada HTTP", "probar endpoint", "API test", "call endpoint", "send request", "make request", "hit endpoint", "enviar request", "probar API", "test this endpoint", "call this endpoint", "hit this URL" | api-test-skill | `skills/api-test-skill/SKILL.md` |

## Compact Rules

Pre-digested rules per skill. Delegators copy matching blocks into sub-agent prompts as `## Project Standards (auto-resolved)`.

### branch-pr
- Every PR MUST link an approved issue — no exceptions
- Every PR MUST have exactly one `type:*` label
- Automated checks must pass before merge is possible
- Branch naming MUST match: `^(feat|fix|chore|docs|style|refactor|perf|test|build|ci|revert)\/[a-z0-9._-]+$`
- Verify issue has `status:approved` label before creating a branch
- Run shellcheck on any modified scripts
- Use conventional commits throughout

### git-setup-skill
- Never overwrite user files without reviewing their contents first
- Prefer section merges for README and existing docs
- If the stack is unclear, ask for confirmation — do not assume
- Avoid placeholders when the repo already provides real facts; label assumptions explicitly
- Do not invent `lint`, `test`, or `build` commands that don't exist
- Classify project type before proposing changes (library, app, CLI, template, internal, demo)

### go-testing
- Use table-driven tests for multiple test cases: `tests := []struct{ name, input, expected string; wantErr bool }{ ... }`
- Test Bubbletea model state transitions directly via `m.Update(msg)` — no rendering needed
- Use `teatest.NewTestModel(t, model)` for full program-lifecycle tests
- Assert on model fields, not rendered output, whenever possible
- Use `t.Run(tc.name, ...)` for subtests within table-driven tests

### issue-creation
- MUST use a template (bug report or feature request) — blank issues are disabled
- Every issue gets `status:needs-review` automatically on creation
- A maintainer MUST add `status:approved` before any PR can be opened
- Search for duplicates before creating a new issue
- Questions → Discussions, not issues

### judgment-day
- Launch TWO sub-agents in parallel (async) — never sequential
- Each judge receives the same target but works independently — no cross-contamination
- Orchestrator (not a sub-agent) synthesizes verdicts after both return
- Inject skill compact rules into BOTH judge prompts AND the fix agent prompt
- If no registry exists, warn user and proceed with generic review only
- Iterate max 2 times before escalating to user

### nestjs-best-practices
- Organize by feature modules, not technical layers (controllers/, services/)
- Avoid circular module dependencies — use forwardRef() only as last resort
- Use constructor injection over property injection
- Use injection tokens for interfaces (not class references)
- Centralize exception handling via exception filters — throw NestJS HTTP exceptions
- Handle all async errors properly; never swallow unhandled promise rejections
- Abstract database logic behind repository pattern for testability
- Understand singleton/request/transient scopes to avoid scope mismatch bugs

### nextjs-best-practices
- Default to Server Components — only use `'use client'` when state, effects, or event handlers are needed
- Fetch data inside Server Components at the page level; pass results down as props
- Keep Client Components as leaves in the tree — push interactivity to the edges
- Use `loading.tsx` and `error.tsx` for streaming and error boundaries per route segment
- Prefer parallel data fetching with `Promise.all` over sequential awaits

### nothing-design
- Trigger ONLY on explicit user request — never auto-apply to generic UI tasks
- Subtract, don't add: every element must earn its pixel; default to removal
- Monochrome canvas: color is an event, not a default — except for status encoding
- Type does the heavy lifting: scale, weight, and spacing create hierarchy, not color or icons
- Declare required Google Fonts before starting any design work — never assume availability
- Both modes (dark OLED black / light warm off-white) are first-class — ask which to start with

### path-context
- Activate on trigger phrases only; never re-run discovery on every turn — results persist in working memory
- Path registration order: config file (project > global) → in-prompt literal; validate existence and security before any reads
- Forbidden paths (hard reject): `~/.ssh`, `~/.gnupg`, `~/.aws`, `/etc/`, `/proc/`, `/sys/`, `C:\Windows\System32\`, filesystem roots
- Budget: MAX_FILES=15 total, split as floor(15/num_paths) per path; MAX_LINES=500 per file (read first 200 if exceeded); MAX_REFS=3
- 6-pass discovery: topology scan → entry points (read) → keyword grep → import chain → naming signal → recency signal
- Pass 1 short-circuit: if >500 files detected → Project Map Mode (dir tree + entry point + README; skip passes 2–6)
- Zero-signal guard: if no files score above baseline → ask user instead of reading arbitrary files
- Ignore list is hard-coded and non-configurable: node_modules, .git, dist, vendor, __pycache__, .next, target, build, .venv, coverage
- Always output a collapsible annotation (`<details>`) BEFORE responding to the user's task
- Budget is HARD: never exceed under any circumstances; unused budget from one path is NOT redistributed

### skill-creator
- Use frontmatter: `name`, `description` (with Trigger line), `license`, `metadata.author`, `metadata.version`
- Structure: `SKILL.md` (required) + `assets/` (templates/schemas) + `references/` (local doc pointers)
- Naming: `{technology}` | `{project}-{component}` | `{action}-{target}`
- Include "Critical Patterns" section with actionable rules only — no fluff
- NEVER create a skill for trivial/one-off tasks or when docs already cover it
- The skill MUST be usable standalone by a sub-agent with zero extra hops

### api-test-skill
- NEVER inline credentials, tokens, or secrets in any generated command — always use env var references
- Detect OS and HTTP client ONCE per session; cache result; do NOT re-detect unless user says "re-detect OS"
- Emit HTTP warning BEFORE command display if URL is `http://` and host is not localhost/127.0.0.1/::1
- Auth inference is suggestion-only — NEVER add auth headers without explicit user confirmation
- NEVER override user's explicit Content-Type header; warn if inferred type differs but respect user's choice
- Evaluate ALL assertions before reporting results — never short-circuit on first failure
- Chain max depth: warn at step 8, hard stop at 10; any var with TOKEN/KEY/SECRET/PASSWORD → show as [REDACTED]
- NEVER execute a request without displaying the full command to the user first

### swarm-forge-skill
- Inspect the repo BEFORE writing anything — never scaffold blind
- Ask only the missing setup questions; infer what you can from the existing files
- Support multiple CLI targets when user wants reusability (Claude Code, Codex, OpenCode, Gemini CLI)
- Pattern selection: explicit user request wins → match nearest existing pattern → lean for minimal → full by default
- Never overwrite existing context files — merge or extend instead
- Encode the correct dev pattern in context files (TDD, BDD, ATDD, or SDD) based on user intent

## Project Conventions

| File | Path | Notes |
|------|------|-------|
| CLAUDE.md | `CLAUDE.md` | Project instructions for Claude Code — lists available skills and how to load them |
| AGENTS.md | `AGENTS.md` | Same content as CLAUDE.md for Codex/other agents |
