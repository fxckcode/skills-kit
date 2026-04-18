# Proposal: API Test Skill

## Intent
Enable agents to execute, interpret, and diagnose REST API calls from the terminal across Windows, macOS, and Linux — without leaking secrets, without manual flag-switching per OS, and without knowing the correct HTTP client upfront.

## Scope

### In Scope
- Cross-OS HTTP client detection and dispatch (`curl` / `httpie` / `Invoke-RestMethod`)
- Safe request construction with env var references (never literal tokens)
- Response interpretation: status codes, headers, body shape
- Error diagnosis with fix suggestions from status code + body signals
- Auth scheme inference from URL patterns and headers
- Content-Type inference from body shape
- Pagination detection from response fields
- Request chaining (output of one → input of next)
- Assertion layer (validate response fields, status, latency)
- Shell line-continuation awareness (`\`, `` ` ``, `^`)

### Out of Scope
- GraphQL / gRPC / WebSocket protocols
- GUI or browser-based testing
- Persistent test suite storage (out of skill scope — delegate to project tooling)
- OAuth flow automation (token must already be in env)

## Capabilities

### New Capabilities
- `os-detect`: Detect OS and available HTTP client; generate correct flags and line-continuation char per shell
- `request-build`: Construct type-safe HTTP requests with method, headers, body, and auth — all via env var references
- `response-interpret`: Parse status code, headers, and body; surface pagination signals and schema hints
- `auth-infer`: Infer auth scheme (Bearer, Basic, API key header/query) from URL patterns and existing headers
- `content-type-infer`: Detect correct `Content-Type` from body shape (JSON object, form, multipart, raw)
- `error-diagnose`: Map status code + body patterns to actionable fix suggestions
- `chain-request`: Feed response fields from one call into the next request as variables
- `assert-response`: Validate status, headers, body fields, and response latency against expected values
- `secret-redact`: Detect and redact known secret patterns before displaying output; warn on HTTP for non-localhost

### Modified Capabilities
None

## Approach
The skill is protocol-first and client-agnostic: it runs an OS detection chain, selects the available HTTP client, then generates the correct command. Security is enforced at every layer — env var references are mandatory, output is redacted before display, and HTTP (non-localhost) triggers a warning. Intelligence layers (auth inference, content-type detection, error diagnosis) run after response receipt. Chaining and assertions are layered on top of the core request-response cycle.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `skills/api-test-skill/SKILL.md` | New | Core skill protocol and instructions |
| `skills/api-test-skill/assets/` | New | Request, chain, and assertion templates |
| `skills/api-test-skill/references/os-detection.md` | New | Client detection logic per OS/shell |
| `skills/api-test-skill/references/security.md` | New | Secret handling, redaction rules, HTTP warnings |
| `skills/api-test-skill/references/auth-patterns.md` | New | Auth scheme inference rules |
| `skills/api-test-skill/references/error-catalog.md` | New | Status code → diagnosis → fix mapping |
| `skills/api-test-skill/references/pagination-patterns.md` | New | Pagination field detection heuristics |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Secret leakage via shell history | High | Enforce env var references; never generate literal tokens in commands |
| Wrong client flags on Windows (`curl.exe` vs Unix `curl`) | High | Explicit `curl.exe` detection; separate flag templates per client |
| Auth inference false positives | Med | Inference is a suggestion — agent always confirms before sending |
| Chained request failures silently ignored | Med | Assert non-null on each chained variable before next request |
| Line-continuation char mismatch breaks multi-line commands | Low | Detect shell at runtime; default to single-line if shell unknown |

## Rollback Plan
Delete `skills/api-test-skill/` directory entirely. No other skill or project file is modified. Change is fully isolated.

## Dependencies
- None (skill is self-contained; HTTP clients are detected at runtime, not installed by the skill)

## Success Criteria
- [ ] OS detection correctly identifies client on Windows (`curl.exe`), macOS (`curl`), and Linux (`httpie` or `curl`)
- [ ] Generated commands never contain literal token values — only env var references
- [ ] Secret patterns are redacted from response output before display
- [ ] Auth scheme is inferred correctly for Bearer, Basic, and API-key-header patterns
- [ ] Error diagnosis returns at least one actionable suggestion for 4xx and 5xx responses
- [ ] A chained request (A → B using A's response field) executes without manual variable substitution
- [ ] All assertion types (status, header, body field, latency) pass and fail with clear messages
