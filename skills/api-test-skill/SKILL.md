---
name: api-test
description: >
  Protocol-first, client-agnostic skill for testing REST APIs end-to-end from the terminal.
  Detects OS and HTTP client automatically, constructs requests with env var references for
  secrets, interprets responses, infers auth and Content-Type, diagnoses errors, supports
  request chaining and response assertions. All output is secret-redacted before display.
  Trigger: When user says "test API", "HTTP request", "curl", "REST call", "API E2E",
  "testear API", "llamada HTTP", "probar endpoint", "API test", "call endpoint",
  "send request", "make request", "hit endpoint", "enviar request", "probar API",
  "test this endpoint", "call this endpoint", "hit this URL".
license: Apache-2.0
metadata:
  author: fxckcode
  version: "1.0"
---

## When to Use

Use this skill when the user wants to test, debug, or call an HTTP REST endpoint from the terminal.

Examples (EN):
- "test this API: POST https://api.example.com/users"
- "curl this endpoint for me: GET /orders/123"
- "send a REST call with Bearer token"
- "make a request to https://api.stripe.com/v1/charges"

Examples (ES):
- "testear API: POST https://api.ejemplo.com/usuarios"
- "probame este endpoint: GET /pedidos/123"
- "enviar request con token Bearer"
- "llamada HTTP a https://api.stripe.com/v1/charges"

## Activation Rules

- Fire once per conversation turn
- OS detection is cached for the entire session — never re-run unless user says "re-detect OS"
- Re-trigger on: new endpoint from user, explicit new chain step, user says "re-detect"
- Do NOT activate on trigger phrases inside code blocks or documentation text

## Critical Patterns

### Pattern 1: OS Detection Protocol

Exact detection sequence:

1. Detect OS: check `$OS`/`$OSTYPE` env vars; fallback to `uname -s`; map to `windows` / `macos` / `linux`
2. Detect shell: `$PSVersionTable` → PowerShell; `$BASH_VERSION` → Bash; `$ZSH_VERSION` → Zsh; `%COMSPEC%` → cmd.exe; unknown → default single-line format
3. Select client (first available):
   - Unix: `which curl` → `which http` (httpie)
   - Windows: `where curl.exe` → `where curl` → PowerShell `Invoke-RestMethod` (always available)
4. Set flag template based on detected client (see table below)
5. Cache result — do not re-detect until user requests "re-detect OS"

Flag template table:

| Client | Method | Header | Body | Auth |
|--------|--------|--------|------|------|
| curl (unix) | `-X {M}` | `-H "{K}: {V}"` | `-d '{body}'` | `-H "Authorization: {scheme} $VAR"` |
| curl.exe (win CMD) | `-X {M}` | `-H "{K}: {V}"` | `-d "{\"key\":\"val\"}"` | `-H "Authorization: {scheme} %VAR%"` |
| curl.exe (win PS) | `-X {M}` | `-H "{K}: {V}"` | `-d '{"key":"val"}'` | `-H "Authorization: {scheme} $env:VAR"` |
| httpie | `{M}` | `{K}:{V}` | `key:=value` | `Authorization:"{scheme} $VAR"` |
| Invoke-RestMethod | `-Method {M}` | `-Headers @{"{K}"="{V}"}` | `-Body '{body}'` | `-Headers @{"Authorization"="{scheme} $env:VAR"}` |

Line-continuation characters:
- bash/zsh: `\`
- PowerShell: `` ` ``
- cmd.exe: `^`
- unknown: single line (no continuation)

**curl.exe differences** (Windows):
- Use double quotes for body (not single quotes)
- Use `$env:VAR` (PowerShell) or `%VAR%` (cmd) — not bare `$VAR`
- Specify explicit `.exe` to avoid conflict with PowerShell `curl` alias

**Install guidance**: macOS `brew install curl` | Linux `apt install curl` / `yum install curl` | Windows: `curl.exe` ships with Windows 10+ | httpie: `pip install httpie`

See `references/os-detection.md` for full flag compatibility tables.

---

### Pattern 2: Request Execution Pipeline

```
[1] OS Detect → [2] Auth Infer? → [3] CT Infer? → [4] Request Build
      ↓                                                      ↓
 (cached)                                          [5] Secret Redact (pre)
                                                           ↓
                                                   [6] Display Command
                                                           ↓
                                                   [7] Execute (Bash)
                                                           ↓
                                                   [8] Secret Redact (post)
                                                           ↓
                                                   [9] Response Interpret
                                                       ↙         ↘
                                               4xx/5xx?         2xx/3xx
                                                  ↓                ↓
                                           [10] Error Diagnose  [continue]
                                                           ↓
                                                   [11] Chain? (optional)
                                                           ↓
                                                   [12] Assert? (optional)
```

- Steps 2, 3, 11, 12 are conditional — only run when applicable
- Step 1 uses cached result after first detection
- Steps 5 and 8 are ALWAYS executed — never skipped

---

### Pattern 3: Security Protocol

1. NEVER inline literal tokens, passwords, or API keys in commands
2. If user provides a raw token value, REFUSE and respond: "Please set this as an env var first: `export API_TOKEN=<value>` — then I'll reference `$API_TOKEN` in the command."
3. Env var syntax per shell:
   - bash/zsh/fish: `$VAR`
   - PowerShell: `$env:VAR`
   - cmd.exe: `%VAR%`
4. HTTP warning: if URL is `http://` and host is NOT `localhost` / `127.0.0.1` / `::1` — emit this block BEFORE displaying the command:
   > ⚠️ HTTP URL detected — credentials may be transmitted in plaintext. Use HTTPS unless this endpoint does not handle sensitive data.
5. Pre-output redaction (step 5): apply all regex patterns from `references/security.md` to command string before display
6. Post-response redaction (step 8): apply regex patterns to response body; scan top-level JSON field names for `token`, `secret`, `key`, `password`, `api_key` — redact their values as `{field}: [REDACTED]`
7. Chain variable display: any var name containing `TOKEN`, `KEY`, `SECRET`, `PASSWORD` → display as `[REDACTED]`

See `references/security.md` for full redaction regex patterns.

---

### Pattern 4: Response Interpretation

1. **Status classification**: 1xx Informational | 2xx Success | 3xx Redirect | 4xx Client Error | 5xx Server Error
2. **Body parsing**: JSON → pretty-print | XML → indent | plain text → as-is | binary → show size only
3. **Header surfacing**: always show `Content-Type`, `X-RateLimit-*`, `Location`, `WWW-Authenticate`; redact `Set-Cookie` values
4. **Pagination detection**: surface any of these fields as chainable:
   - Body fields: `next`, `next_cursor`, `after`, `before`, `cursor`, `next_page`, `page`, `total_pages`, `hasMore`, `has_more`
   - Headers: `Link: <url>; rel="next"` (RFC 8288)
5. **Rendering order**: status line (code + text + latency) → selected headers → body (max 2000 characters; truncate with `... [truncated — full body: N bytes]`)
6. After parsing: list any detected pagination signals and offer to chain the next page

See `references/pagination-patterns.md` for provider-specific patterns.

---

### Pattern 5: Error Diagnosis

| Code/Error | Diagnosis | Suggested Fix |
|------------|-----------|---------------|
| 400 | Bad request syntax | Check body format and required fields |
| 401 | Unauthorized | Check token is set and not expired; verify env var |
| 403 | Forbidden | Check permissions, OAuth scopes, or IP allowlist |
| 404 | Not found | Verify URL path, base URL, and path parameters |
| 405 | Method not allowed | Check correct HTTP method for this endpoint |
| 409 | Conflict | Resource already exists or state conflict |
| 415 | Unsupported media type | Set correct Content-Type header |
| 422 | Validation error | Parse body for field-level errors and fix payload |
| 429 | Rate limited | Read Retry-After header; add delay before retry |
| 5xx | Server error | Retry with backoff; check server logs if accessible |
| ECONNREFUSED | Service not running | Check port, service status, and host address |
| ETIMEDOUT | Network timeout | Check network, increase timeout, verify host |
| SSL error | Certificate issue | Use `--insecure` for localhost only; fix cert for prod |

See `references/error-catalog.md` for the complete 4xx/5xx/network error table.

---

### Pattern 6: Auth Inference

1. **Suggestion-only**: NEVER apply inferred auth automatically — always present as a suggestion and wait for user confirmation
2. **Confidence levels**:
   - HIGH: hostname matches a known provider in `references/auth-patterns.md`
   - MEDIUM: path contains `/oauth/`, `/auth/`, or `/token/`
   - LOW: no detectable signals
3. **Detection order**: check existing `Authorization` header first → if absent, check URL hostname against `references/auth-patterns.md` → surface suggestion
4. **Confirmation message**: "I detected this endpoint may use [scheme] auth (confidence: HIGH). Add `Authorization: [scheme] $VAR` header? If yes, what env var holds the token?"
5. Cache decision per hostname for session duration
6. If user rejects inference → stop suggesting for that hostname

See `references/auth-patterns.md` for provider → scheme mapping table.

---

### Pattern 7: Content-Type Inference

Body shape rules (applied when body is present and no `Content-Type` header is set):

1. Starts with `{` or `[` → `application/json`
2. Matches `key=value&key2=value2` pattern → `application/x-www-form-urlencoded`
3. Contains `--boundary` or `Content-Disposition: form-data` → `multipart/form-data`
4. Starts with `<?xml` or `<root` → `application/xml`
5. Any other string → `text/plain`

Rules:
- Omit `Content-Type` entirely for GET, HEAD, DELETE (no body expected)
- If user explicitly sets a Content-Type that doesn't match the inferred type: warn ("Body looks like JSON but Content-Type is set to text/plain — is this intentional?") but NEVER override the user's explicit value

---

### Pattern 8: Request Chaining

1. **Variable naming**: `$CHAIN_{FIELD}` for auto-named vars (e.g., `$CHAIN_ID`, `$CHAIN_TOKEN`); user can override with explicit name
2. **Capture syntax**: `capture body.data.id as $CHAIN_ID` — use dot-path for nested fields; `body.items[0].id` for arrays
3. **Null guard**: if captured field is null or missing → halt immediately with: "Chain halted at step N: `body.{path}` resolved to null. Fix step N response before continuing."
4. **Secret display**: any var name containing `TOKEN`, `KEY`, `SECRET`, `PASSWORD` → show as `[REDACTED]` in chain summary
5. **Max depth**: warn at step 8 ("Chain depth approaching limit"); hard stop at 10 ("Chain depth limit reached — 10 steps maximum")
6. **Clear**: user says "clear chain" or "reset chain" → wipe all `$CHAIN_*` variables from working memory

See `assets/chain-template.md` for declaration syntax and 3-step CRUD example.

---

### Pattern 9: Response Assertions

1. Evaluate ALL assertions — never short-circuit on first failure
2. **Assertion types**:
   - Status: `assert status == 201`
   - Header: `assert header Content-Type == "application/json"` or `~= "json"` (contains / regex match)
   - Body: `assert body.data.id != null` | `assert body.message == "created"` | `assert body.name ~= "^Alice"`
   - Latency: `assert latency < 500ms`
3. Dot-path for nested JSON: `body.data.user.email`; arrays: `body.items[0].id`
4. Regex operator `~=`: value matches the given regex pattern
5. **Output per assertion**: `[PASS] status == 201 (actual: 201)` or `[FAIL] body.data.id != null (actual: null)`
6. **Summary**: `N/M assertions passed` — shown after all assertions complete
7. On any FAIL: continue evaluating remaining assertions, then report all failures together

See `assets/assertion-patterns.md` for syntax reference and examples.

---

## Output Format

1. **Status line**: `{code} {text} — {latency}ms` (e.g., `200 OK — 142ms`)
2. **Headers**: `Content-Type`, `X-RateLimit-*`, `Location`, `WWW-Authenticate` (others on request)
3. **Body**: pretty-printed JSON/XML; plain text as-is; binary shows size only; max 2000 characters (truncate with `... [truncated — full body: N bytes]`)
4. **Assertion block**: after body (if assertions were declared)
5. **Chain summary**: after assertions (if chaining is active)

## Constraints (Hard Rules)

- NEVER inline credentials in any command
- NEVER override user's explicit Content-Type
- NEVER execute a request without showing the command to the user first
- NEVER chain more than 10 sequential steps
- NEVER short-circuit assertion evaluation
- ALWAYS warn on HTTP (non-HTTPS) for non-localhost URLs
- ALWAYS cache OS detection per conversation session
