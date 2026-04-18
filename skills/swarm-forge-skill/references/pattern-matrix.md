# Pattern Matrix

Use this reference when the user wants the skill to choose or justify a repository setup based on one of the four supported development patterns: `TDD`, `BDD`, `ATDD`, or `SDD`.

The matrix separates three concerns:

- `setup pattern`: how much base scaffolding to create
- `development pattern`: how implementation is driven
- `artifact family`: which extra files or directories govern the workflow

## Recommended Base Layers

### Base scaffold per CLI

```text
.claude/
├── knowledge/
└── rules/
CLAUDE.md
```

Optional when the user asks for agents:

```text
.claude/agents/
```

Equivalent namespaced variants:

```text
.codex/...
.opencode/...
.gemini/...
```

### Extended workflow per CLI

```text
.claude/
├── plans/
├── tasks/
└── context/
```

### Artifact families per CLI

```text
.claude/specs/
.claude/scenarios/
.claude/acceptance/
```

## Matrix

| Pattern | Best fit | Setup pattern | Extra directories | Core files |
|---|---|---|---|---|
| `TDD` | implementation driven by unit tests | `lean` or `full` | `tests/` or co-located test files | `*.test.*`, `*.spec.*`, test config |
| `BDD` | behavior-driven scenarios | `lean` or `full` | `scenarios/features/`, step definitions | `*.feature`, step definition files |
| `ATDD` | acceptance criteria and stakeholder collaboration | `full` | `acceptance/`, `scenarios/`, `plans/` | acceptance test files, criteria docs |
| `SDD` | specs, plans, and structured context drive implementation | `full` or `collaborative` | `specs/`, `plans/`, `tasks/`, optionally `contracts/` | `spec.md`, `plan.md`, `tasks.md`, or structured change folders |

## Selection Guidance

- Prefer the least invasive setup pattern that still supports the requested development pattern.
- Treat agent directories as opt-in workflow extensions, not a mandatory side effect of choosing `full` or `collaborative`.
- Add `plans/` and `tasks/` mainly for `SDD` and heavier `ATDD` flows.
- Add `specs/` for `SDD`, `scenarios/` for `BDD`, and `acceptance/` style artifacts for `ATDD`.
- Keep `TDD` lightweight unless the repository already uses broader workflow artifacts.
- If the repo already has one of these artifact families, extend it instead of creating a parallel structure.
