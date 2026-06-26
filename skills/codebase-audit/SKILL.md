---
name: codebase-audit
description: >
  Systematic codebase audit — gap analysis against specs (PRD/SDD), architecture review, code quality assessment, and migration readiness checks. Use when the user asks to review a codebase, compare it to a spec, or assess a project.
license: Apache-2.0
metadata:
  author: fxckcode
  version: "1.0"
---

# Codebase Audit

## What This Skill Owns

- Comparing a codebase against a spec (PRD, SDD, architecture doc)
- Identifying gaps with specific evidence (file paths, line numbers)
- Running the 7-phase verification loop as part of the audit
- Functional smoke testing every endpoint systematically
- Delivering actionable verdicts with prioritized recommendations

## When to Use

- User says "review this codebase", "audit this project", "how does this compare to X"
- User drops a PRD/SDD and asks to evaluate implementation status
- Before starting work on an inherited or unfamiliar codebase
- As part of migration readiness assessment

## Audit Workflow

### Phase 0: Clone + Setup
1. Clone the repo
2. Find project docs (README, PRD, ARCHITECTURE, SITEMAP, TASKS)
3. Install dependencies
4. Start the project and verify it responds
5. Run the test suite

### Phase 1: Understand the Spec
Extract every explicit requirement from the spec. Build a mental checklist of what the spec demands.

### Phase 2: Survey the Codebase
1. Read the schema (this is the single most important artifact)
2. Read package.json / go.mod for dependencies and scripts
3. Scan module/service/controller structure
4. Read key service files (auth, core domain, integrations)
5. Check for Docker/devops setup

### Phase 3: Gap Analysis
Compare each spec requirement against the code:

| Spec Item | Status | Evidence |
|---|---|---|
| ChannelIdentity model | MISSING | User still has whatsappNumber @unique |
| INVESTMENT enum | MISSING | Enum only has INCOME \| EXPENSE |

### Phase 4: Verdict
1. TL;DR at the top — percentage complete, one-line assessment
2. What's good — things done right, especially tests
3. What's missing — gap table with evidence
4. What's broken — bugs, broken configs, architectural violations
5. Verdict — actionable recommendation

## Polishing Variant

When user says "pulir funcionalidades con base este PRD":
1. Categorize each PRD requirement as ✅ working / ⚠️ partial / ○ missing
2. Focus on ⚠️ — existing but rough (inverted logic, unclear errors, untested paths)
3. Explicitly defer ○ — missing features are NOT polish
4. Recommend top 2-3 polish items with concrete evidence

## Critical Rules

- **Local code over external references** — when user points to a local dir, that's the truth
- **Don't trust the README** — the code is the truth
- **Don't assume tests pass** — run them
- **Don't conflate "missing" with "needs building"** — may want polish, not new features
- **Check the schema first** — single most information-dense artifact
- **Don't report on what you haven't verified** — either cite the file or say you haven't checked

## Pitfalls

- Skipping the schema — this is where requirements live or die
- Not running the tests — passing tests are a strong signal
- Not checking the run cycle — a project that looks complete may silently block on execution
- Trusting external docs over local code
