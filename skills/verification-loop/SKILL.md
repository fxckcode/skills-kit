---
name: verification-loop
description: >
  Structured 7-phase verification system for code changes: Build → Type → Lint → Test → Spec → Security → Smoke. Use after completing any feature, before PR, or when the agent needs to systematically verify a change.
license: Apache-2.0
metadata:
  author: fxckcode
  version: "1.0"
---

# Verification Loop

## What This Skill Owns

- Running a defined 7-phase verification sequence in order
- Reporting structured results (PASS / FAIL / PASS_WITH_WARNINGS)
- Enforcing the failure protocol (fix and re-run from the failing phase)
- Acting as an audit tool for existing unmodified projects (Phase 0 comprehension)

## When to Use

- After completing a feature or significant change
- Before creating a PR
- User says "verify this", "verifica", "smoke test", "review this"
- After a refactor, or as part of SDD Verify phase
- User drops a project URL and asks for a codebase review

## Phases

### 1. Build
```bash
pnpm build 2>&1 | tail -20
# If fails → STOP, fix before continuing
```

### 2. Type Check
```bash
# TypeScript
npx tsc --noEmit 2>&1 | head -30
# Python
pyright . 2>&1 | head -30
```

### 3. Lint
```bash
# JS/TS: pnpm lint, Python: ruff check ., Rust: cargo clippy
```

### 4. Test
```bash
pnpm test 2>&1 | tail -30
```

### 5. Spec Verification
Read spec.md if it exists. For each REQ-F and REQ-NF: verify it's implemented. Mark as ✅ / ❌ / ⚠️.

### 6. Security Scan
```bash
pnpm audit --prod 2>&1 | tail -10
npm audit --omit=dev 2>&1 | tail -10
```
Manual: no hardcoded secrets, no console.log in prod, input validation at boundaries.

### 7. Smoke Test
Build and start the server, test each endpoint with curl or equivalent client.

## Output

Write a verification report:
- Summary: each phase ✅/❌
- Issues: CRITICAL / WARNING / SUGGESTION
- Verdict: PASS | FAIL | PASS_WITH_WARNINGS

## Failure Protocol

| Phase | On Failure |
|---|---|
| Build | Fix compilation, restart from Phase 1 |
| Type | Fix type errors, restart from Phase 2 |
| Lint | Auto-fix or manual fix |
| Test | Analyze, fix, re-run Phase 4 |
| Spec | Document gap, escalate to user |
| Security | Fix CRITICAL immediately |
| Smoke | Debug and fix, re-run Phase 7 |

## Audit Mode

For existing projects (no change to verify), add a **Phase 0: Architecture Comprehension** before the 7 phases: read the codebase structure, entry points, config, and test suite. Then run all 7 phases and produce a structured audit report.

## Pitfalls

- Skipping phases (especially security) — run all 7 in order
- Ignoring test failures — do NOT skip failed tests
- Verifying without the spec — always read spec.md first if it exists
- Trusting `npm audit` without reviewing critical findings
