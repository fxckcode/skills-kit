---
name: go-quality
description: >
  Go project quality standards — linting, race detection, CI setup, error wrapping, context propagation, and test isolation. Use when setting up, reviewing, or fixing Go projects.
license: Apache-2.0
metadata:
  author: fxckcode
  version: "1.0"
---

# Go Quality Standards

## What This Skill Owns

- Verifying Go project layout (cmd/, internal/, single go.mod)
- Enforcing quality gates: build, vet, format, race detector, lint
- Error handling: wrapping with %w, no panic, no naked discards
- Context propagation: every blocking operation accepts ctx
- Config hygiene: YAML + CLI flags + env, sane defaults
- Testing: table-driven, race-safe, no global state mutation
- CI: GitHub Actions with gofmt, vet, test -race

## Quality Gates (MUST DO)

### Build & Format
```bash
go build ./... && go vet ./...
gofmt -s -l .  # must be empty
```

### Race Detector
```bash
go test -race -count=1 ./...
```
MUST pass. Non-negotiable.

### Error Handling
- Wrap errors: `fmt.Errorf("context: %w", err)` — NEVER %s or %v for wrapping
- No panic() for normal flow (log.Fatalf only in main())
- No naked `_ = fn()` discards without justification

### Context Propagation
- Every blocking operation accepts `ctx context.Context` as first param
- Use context.WithTimeout / context.WithCancel — never unbounded goroutines
- Goroutines MUST check ctx.Done()

### Logging
- One log.SetPrefix() in main.go — never duplicate prefixes in format strings
- Use log.Printf, not fmt.Fprintf to stderr

### Config
- YAML for persistence + CLI flags for overrides
- Default config MUST produce a working baseline
- CLI > env > YAML > default priority

### Testing
- Table-driven tests with t.Run subtests
- Use t.TempDir() for filesystem — never override HOME in TestMain
- Mock via interfaces, not global state
- Use t.Helper() in test helpers

## CI Setup
```yaml
jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: "1.26"
          check-latest: true
      - run: test -z "$(gofmt -l -s .)"
      - run: go vet ./...
      - run: go test -race -count=1 ./...
```

## Common Pitfalls

| Pitfall | Symptom | Fix |
|---|---|---|
| Duplicate log prefix | `[app] [app] listen` | Use log.SetPrefix once, omit from format strings |
| Config points to missing backend | YAML references backend that doesn't exist | Keep default config in sync with actual backends |
| TestMain overrides HOME | All tests share contaminated env | Use per-test t.TempDir() instead |
| Streaming delta has empty role | `"role":""` in SSE chunks | Use Delta struct with omitempty |
| Health bypass too broad | `/api/v1/foo/health` skips auth | Compare exact path with ==, not HasSuffix |
