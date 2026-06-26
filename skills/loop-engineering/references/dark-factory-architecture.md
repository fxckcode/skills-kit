# Dark Factory Architecture — 5 Levels

Reference implementation: a CLI tool that turns a PRD into a complete GitHub repo through autonomous agent loops.

```
N0: DECOMPOSE — PRD → UX/FE/BE specs + template injection
N1: BUILD — 3 parallel loops (UX, FE, BE) with internal SDD + maker-checker
     Worktrees isolated per area, parallel execution
N2: INTEGRATE — merge + contract tests (FE ↔ BE API contracts)
N3: QA — extract PRD use cases, verify against integrated product
     Failing areas → re-trigger their loop (up to max retries)
N4: DELIVER — GitHub repo creation + branch push + PR open
```

## Nested SDD

Each internal loop (N1) runs its own SDD cycle:
- **Maker**: propose → spec → design → tasks → apply (persists to external state)
- **Checker**: reads ALL from external state (fresh context), verifies, emits PASS/FAIL
- **Iteration cap**: 3 per area. On cap exceeded → CRITICAL failure.

## Key Innovations

1. **Nested SDD** — each loop has its own propose→spec→design→tasks→apply→verify→archive cycle
2. **External state** — checker reads from persistent store, never from maker's memory
3. **QA loop** — independent agent validates against original PRD, re-triggers failing areas
4. **Template injection** — stack-specific conventions injected as skills before agent runs
