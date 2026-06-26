---
name: loop-engineering
description: >
  Design and implement autonomous agent loops for multi-agent software development. Maker-checker split, nested SDD cycles, worktree isolation, verification layers, and iteration budgets. Use when building systems where AI agents collaborate autonomously on software projects.
license: Apache-2.0
metadata:
  author: fxckcode
  version: "1.0"
---

# Loop Engineering — Multi-Agent Orchestration

> "You shouldn't be prompting coding agents anymore. You should be designing loops that prompt your agents." — Peter Steinberger

## What This Skill Owns

- Designing closed-loop autonomous agent pipelines with stopping conditions
- Implementing maker-checker splits (fresh context for verifiers)
- Nested SDD cycles within each agent loop
- Parallel workstream orchestration with worktree isolation
- Three-layer verification: intra-loop, integration, QA
- Iteration caps and token budgets

## Core Primitives

Every production loop needs: Automations (scheduler), Worktrees (isolation), Skills (codified knowledge), Plugins (tool access), Sub-agents (maker-checker split), and State/Memory (external persistence).

## Maker-Checker Split

The single highest-leverage structural decision:

```
MAKER (Agent A)                CHECKER (Agent B)
─────────────────              ──────────────────
Role: create, implement        Role: destroy, verify
Bias: "my code works"          Bias: "nothing works until proven"
Context: inherited              Context: FRESH (reads from state only)
```

**Critical rule**: Checker MUST have fresh context. The agent that wrote the code is too lenient grading its own homework.

## Verification — 3 Layers

1. **Intra-loop** — Maker-checker per area (tests, spec compliance, design)
2. **Integration** — Contract tests between areas (FE ↔ BE)
3. **QA** — Original PRD use cases against integrated product

Verification is the reason you can walk away from a loop. Without it, the loop produces confident garbage.

## Dark Factory Architecture — 5 Levels

```
N0: DECOMPOSE — PRD → UX/FE/BE specs + template injection
N1: BUILD — 3 parallel loops (UX, FE, BE) with maker-checker
     Worktrees isolated per area, Promise.all for parallelism
N2: INTEGRATE — merge + contract tests
N3: QA — PRD use cases against integrated product
N4: DELIVER — GitHub repo + branch + PR
```

## 7-Dimension AI Code Review (Checker's Job)

| # | Dimension | What to Check |
|---|---|---|
| 1 | Correctness | Output matches spec — all edge cases |
| 2 | Hallucination | Every import and type exists in installed packages |
| 3 | Security | Input validated, auth checked, no secrets hardcoded |
| 4 | Architecture Fit | Follows project conventions, not generic AI patterns |
| 5 | Performance | No N+1, no unnecessary nested loops |
| 6 | Error Handling | try/catch, loading/empty/error states in UI |
| 7 | Maintainability | Clear names, small functions, complex logic explained |

## Pitfalls

- **No iteration cap** — always set maxIterations (default: 3)
- **Checker inherits maker context** — defeats the purpose
- **No token budget** — estimate before running: 4 agents × 3 iterations × 200K tokens = 2.4M
- **Weak verification** — "tests pass" is not enough; run the code, check edge cases
- **Comprehension debt** — the faster the loop ships code, the bigger the gap between what exists and what you understand
