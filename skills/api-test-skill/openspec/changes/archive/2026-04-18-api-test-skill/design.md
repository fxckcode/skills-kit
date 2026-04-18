# Design: API Test Skill

## 1. SKILL.md Structure

| # | Section | Purpose | Capabilities Covered |
|---|---------|---------|----------------------|
| 1 | YAML Frontmatter | Skill identity, trigger phrases, metadata | All (discovery) |
| 2 | When to Use | Trigger examples in English and Spanish | All |
| 3 | Activation Rules | When to fire, when NOT to fire, re-trigger rules | All |
| 4 | Critical Patterns | Non-negotiable behavioral protocols | All 9 |
| 4.1 | Pattern 1: OS Detection Protocol | Detect OS, shell, HTTP client, flags | os-detect |
| 4.2 | Pattern 2: Request Execution Pipeline | Ordered sequence from detection to assertion | request-build, content-type-infer, auth-infer, secret-redact |
| 4.3 | Pattern 3: Security Protocol | Env var enforcement, redaction, HTTP warnings | secret-redact |
| 4.4 | Pattern 4: Response Interpretation | Status classification, header/body parsing, pagination | response-interpret |
| 4.5 | Pattern 5: Error Diagnosis | Status code + body pattern mapping to fix suggestions | error-diagnose |
| 4.6 | Pattern 6: Auth Inference | URL/header pattern matching, confidence levels | auth-infer |
| 4.7 | Pattern 7: Content-Type Inference | Body shape detection, mismatch warnings | content-type-infer |
| 4.8 | Pattern 8: Request Chaining | Variable capture, null guard, chain display | chain-request |
| 4.9 | Pattern 9: Response Assertions | Status/header/body/latency validation, PASS/FAIL reporting | assert-response |
| 5 | Output Format | Consistent rendering order for all responses | response-interpret, secret-redact |
| 6 | Constraints | Hard limits, never-do rules | All |

---

## 2. File Layout

```
skills/api-test-skill/
├── SKILL.md                              # Core skill protocol (all patterns, rules, pipeline)
├── assets/
│   ├── request-template.md               # Per-client command templates (curl, httpie, IRM)
│   ├── chain-template.md                 # Chain step declaration syntax and examples
│   └── assertion-patterns.md             # Assertion syntax reference with examples
└── references/
    ├── os-detection.md                   # Client/shell detection tables, flag compatibility
    ├── security.md                       # Redaction regexes, env var patterns, field scan list
    ├── auth-patterns.md                  # Provider → auth scheme mapping, confidence rules
    ├── error-catalog.md                  # Status code → diagnosis → fix suggestion table
    └── pagination-patterns.md            # Pagination field/header heuristics
```

**Total files**: 9

---

## 3. Frontmatter Design

```yaml
---
name: api-test
description: >
  Protocol-first, client-agnostic skill for testing REST APIs end-to-end from the terminal.
  Detects OS and HTTP client automatically, constructs requests with env var references for
  secrets, interprets responses, infers auth and Content-Type, diagnoses errors, supports
  request chaining and response assertions. All output is secret-redacted before display.
  Trigger: When user says "test API", "HTTP request", "curl", "REST call", "API E2E",
  "testear API", "llamada HTTP", "probar endpoint", "API test", "call endpoint",
  "send request", "make request", "hit endpoint", "enviar request", "probar API".
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---
```

---

## 4. Capability-to-Pattern Mapping

| Capability | Pattern Name | Section in SKILL.md | References Used |
|------------|-------------|---------------------|-----------------|
| os-detect | Pattern 1: OS Detection Protocol | Critical Patterns > Pattern 1 | references/os-detection.md |
| request-build | Pattern 2: Request Execution Pipeline | Critical Patterns > Pattern 2 | assets/request-template.md |
| response-interpret | Pattern 4: Response Interpretation | Critical Patterns > Pattern 4 | references/pagination-patterns.md |
| auth-infer | Pattern 6: Auth Inference | Critical Patterns > Pattern 6 | references/auth-patterns.md |
| content-type-infer | Pattern 7: Content-Type Inference | Critical Patterns > Pattern 7 | (inline — small ruleset) |
| error-diagnose | Pattern 5: Error Diagnosis | Critical Patterns > Pattern 5 | references/error-catalog.md |
| chain-request | Pattern 8: Request Chaining | Critical Patterns > Pattern 8 | assets/chain-template.md |
| assert-response | Pattern 9: Response Assertions | Critical Patterns > Pattern 9 | assets/assertion-patterns.md |
| secret-redact | Pattern 3: Security Protocol | Critical Patterns > Pattern 3 | references/security.md |

---

## 5. OS Detection Protocol Design

### Algorithm

**Step 1 — OS Detection**

```
1a. Check environment variables:
    - $OS == "Windows_NT"           → Windows
    - $OSTYPE starts with "darwin"  → macOS
    - $OSTYPE starts with "linux"   → Linux
    - uname -s fallback:
        "Darwin"  → macOS
        "Linux"   → Linux
        "MINGW*" / "MSYS*" / "CYGWIN*" → Windows (Git Bash / MSYS2)
1b. Record: os_name, os_family (unix | windows)
```

**Step 2 — Shell Detection**

```
2a. Check shell-specific markers:
    - $PSVersionTable exists        → PowerShell
    - $BASH_VERSION exists          → Bash
    - $ZSH_VERSION exists           → Zsh
    - $SHELL contains "fish"        → Fish
    - %COMSPEC% points to cmd.exe   → cmd.exe
2b. If none detected → shell = "unknown"
2c. Record: shell_name, line_continuation_char
```

**Step 3 — Client Availability Check**

```
3a. Probe in order (first match wins):
    Unix:    which curl   → curl
             which http   → httpie
    Windows: where curl.exe  → curl.exe
             where curl      → curl (WSL/Git Bash)
             where http      → httpie
             PowerShell:     → Invoke-RestMethod (always available in PS)
3b. If no client found → HALT with error + install guidance per OS:
    macOS:   "brew install curl" or "brew install httpie"
    Linux:   "sudo apt install curl" or "sudo apt install httpie"
    Windows: "curl.exe ships with Windows 10+. Open PowerShell to use Invoke-RestMethod."
3c. Record: client_name, client_binary (exact command to invoke)
```

**Step 4 — Flag Template Selection**

```
4a. Select flag set based on client_name:
    curl/curl.exe:
      method:   -X {METHOD}
      header:   -H "{Key}: {Value}"
      body:     -d '{body}'
      auth:     -H "Authorization: {scheme} {$VAR}"
      verbose:  -v
      output:   -w "\n%{http_code}" (for status extraction)
      silent:   -s
    httpie:
      method:   {METHOD}
      header:   {Key}:{Value}
      body:     key=value (form) or key:=value (JSON raw)
      auth:     -A bearer -a {$VAR}  OR  -a {$USER}:{$PASS}
      verbose:  -v
    Invoke-RestMethod:
      method:   -Method {METHOD}
      header:   -Headers @{"Key"="Value"}
      body:     -Body '{body}'
      auth:     -Headers @{"Authorization"="{scheme} $env:VAR"}
      ct:       -ContentType "application/json"
4b. Record: flag_template (lookup table for request-build)
```

### curl.exe vs curl Flag Compatibility

| Feature | curl (Unix) | curl.exe (Windows) | Difference |
|---------|-------------|--------------------|--------------------|
| Binary name | `curl` | `curl.exe` | Must use `.exe` on Windows to avoid PS alias |
| Single quotes in body | `-d '{"key":"val"}'` | `-d "{\"key\":\"val\"}"` | Windows cmd/PS does not support single quotes; use escaped double quotes |
| Env var syntax | `$TOKEN` | `$env:TOKEN` (PS) / `%TOKEN%` (cmd) | Shell-dependent variable expansion |
| Line continuation | `\` | `` ` `` (PS) / `^` (cmd) | Different per shell |
| `-w` format string | `-w "\n%{http_code}"` | `-w "\n%{http_code}"` | Same syntax, works on both |
| `--data-raw` | Supported | Supported (Win10+) | No difference |

### Line Continuation Character Table

| Shell | Char | Example |
|-------|------|---------|
| bash | `\` | `curl -X POST \` |
| zsh | `\` | `curl -X POST \` |
| fish | `\` | `curl -X POST \` |
| PowerShell | `` ` `` | `` curl.exe -X POST ` `` |
| cmd.exe | `^` | `curl.exe -X POST ^` |
| unknown | (none — single line) | `curl -X POST -H "..." -d '...' https://...` |

---

## 6. Security Protocol Design

### Redaction Pipeline Position

```
Request Execution Pipeline:
  1. os-detect
  2. auth-infer
  3. content-type-infer
  4. request-build
  5. *** secret-redact (PRE-OUTPUT) ***  ← redact command before display
  6. display command to user
  7. execute command
  8. *** secret-redact (POST-RESPONSE) *** ← redact response before display
  9. response-interpret (operates on redacted output)
  10. error-diagnose
  11. chain-request (variable summary redacted)
  12. assert-response (assertion values redacted)
```

Secret-redact runs at TWO mandatory points:
- **Pre-output (step 5)**: Before the constructed command is shown to the user
- **Post-response (step 8)**: Before the response body/headers are rendered

### Redaction Regex Patterns

| Pattern Name | Regex | Replacement | Scope |
|-------------|-------|-------------|-------|
| Bearer token | `Bearer\s+[A-Za-z0-9._\-]{10,}` | `Bearer [REDACTED]` | Command display, response body |
| Authorization header value | `Authorization:\s*.+` | `Authorization: [REDACTED]` | Full header value after scheme |
| API key param | `(?i)api[_\-]?key[=:]\s*[^\s&"']+` | `api_key=[REDACTED]` | URL query strings, headers |
| Generic secret param | `(?i)(secret|password|passwd|token)[=:]\s*[^\s&"']+` | `{name}=[REDACTED]` | URL query strings, body fields |
| AWS key | `AKIA[0-9A-Z]{16}` | `[REDACTED-AWS-KEY]` | Any output |
| Private key block | `-----BEGIN\s+(RSA\s+)?PRIVATE KEY-----` | `[REDACTED-PRIVATE-KEY]` | Any output |

### Env Var Reference Enforcement

The agent MUST construct commands using env var references, never literal values:

```
CORRECT:  -H "Authorization: Bearer $API_TOKEN"
WRONG:    -H "Authorization: Bearer eyJhbGciOiJSUzI1NiJ9..."

CORRECT:  curl.exe ... -H "Authorization: Bearer $env:API_TOKEN"
WRONG:    curl.exe ... -H "Authorization: Bearer sk-live-abc123..."
```

Rules:
- The skill instructs the agent to ask the user for the env var NAME, not the value
- If the user provides a literal token, the skill MUST refuse and instruct: "Set this as an environment variable first: `export API_TOKEN=<your-token>`, then I'll reference `$API_TOKEN`"
- Variable syntax adapts to detected shell: `$VAR` (bash/zsh), `$env:VAR` (PowerShell), `%VAR%` (cmd.exe)

### HTTP Warning Trigger

Condition: URL scheme is `http://` AND host is NOT one of:
- `localhost`
- `127.0.0.1`
- `::1`
- `0.0.0.0`

Action: Emit warning before command execution:
```
WARNING: HTTP scheme detected for non-localhost URL — credentials may be
transmitted in plaintext. Use HTTPS unless you are certain this endpoint
does not handle sensitive data.
```

### Response Body Secret Field Scan

After parsing the response body, scan top-level and nested field NAMES for:

| Field Name Pattern | Action |
|-------------------|--------|
| `token`, `access_token`, `id_token`, `refresh_token` | Warn: "Response contains sensitive field: {name} — value not displayed. Use chain-request to capture securely." |
| `secret`, `api_key`, `apiKey`, `password`, `passwd` | Warn: same as above |
| `private_key`, `privateKey` | Warn: same as above |

Values of these fields are NEVER displayed in raw output. They can be captured via chain-request (where the summary also shows `[REDACTED]`).

---

## 7. Request Execution Pipeline

Complete ordered sequence of operations for every API request:

```
 ┌─────────────────────────────────────────┐
 │ 1. OS DETECT                            │
 │    Detect OS → Shell → Client → Flags   │
 │    Cache result for session              │
 └──────────────┬──────────────────────────┘
                │
 ┌──────────────▼──────────────────────────┐
 │ 2. AUTH INFER (conditional)             │
 │    Trigger: No Authorization header set │
 │    Output: Suggestion with confidence   │
 │    Requires: User confirmation          │
 └──────────────┬──────────────────────────┘
                │
 ┌──────────────▼──────────────────────────┐
 │ 3. CONTENT-TYPE INFER (conditional)     │
 │    Trigger: Body present, no CT header  │
 │    Output: Inferred Content-Type        │
 │    Mismatch: Warn but don't override    │
 └──────────────┬──────────────────────────┘
                │
 ┌──────────────▼──────────────────────────┐
 │ 4. REQUEST BUILD                        │
 │    Assemble: method + URL + headers +   │
 │    body + flags per client template     │
 │    Validate: absolute URL required      │
 └──────────────┬──────────────────────────┘
                │
 ┌──────────────▼──────────────────────────┐
 │ 5. SECRET REDACT — PRE-OUTPUT           │
 │    Apply all regex patterns to command   │
 │    MUST complete before step 6          │
 └──────────────┬──────────────────────────┘
                │
 ┌──────────────▼──────────────────────────┐
 │ 6. DISPLAY COMMAND                      │
 │    Show redacted command to user        │
 │    HTTP warning if applicable           │
 └──────────────┬──────────────────────────┘
                │
 ┌──────────────▼──────────────────────────┐
 │ 7. EXECUTE COMMAND                      │
 │    Run via Bash tool                    │
 │    Capture: stdout, stderr, exit code   │
 │    Measure: wall-clock latency          │
 └──────────────┬──────────────────────────┘
                │
 ┌──────────────▼──────────────────────────┐
 │ 8. SECRET REDACT — POST-RESPONSE        │
 │    Apply all regex patterns to response │
 │    Scan body fields for secret names    │
 │    MUST complete before step 9          │
 └──────────────┬──────────────────────────┘
                │
 ┌──────────────▼──────────────────────────┐
 │ 9. RESPONSE INTERPRET                   │
 │    Classify status, parse headers/body  │
 │    Detect pagination signals            │
 │    Surface chainable fields             │
 │    Output order: status → headers → body│
 └──────────────┬──────────────────────────┘
                │
        ┌───────┴───────┐
        │ Status 4xx/5xx│
        │ or conn error?│
        └───┬───────┬───┘
          YES       NO
            │       │
 ┌──────────▼───┐   │
 │ 10. ERROR    │   │
 │ DIAGNOSE     │   │
 │ Map to fix   │   │
 │ suggestions  │   │
 └──────────┬───┘   │
            │       │
        ┌───▼───────▼───────────────────────┐
        │ 11. CHAIN REQUEST (conditional)   │
        │     Trigger: chain active          │
        │     Extract fields, set variables  │
        │     Null guard → halt if missing   │
        │     Display summary (redacted)     │
        └───────────────┬───────────────────┘
                        │
        ┌───────────────▼───────────────────┐
        │ 12. ASSERT RESPONSE (conditional) │
        │     Trigger: assertions defined    │
        │     Evaluate all, never short-     │
        │     circuit on failure             │
        │     Report PASS/FAIL per assertion │
        │     Summary: N/M passed            │
        └───────────────────────────────────┘
```

### Caching Rules
- OS detection result (step 1) is cached for the entire conversation session. Re-detection only on explicit user request ("re-detect", "cambiar cliente").
- Auth inference (step 2) runs once per unique hostname. If the user confirms or rejects an inference, the decision is cached for that hostname for the session.

---

## 8. Chaining State Model

### Variable Naming Convention

Chain variables follow the pattern `$CHAIN_{FIELD}` by default, or a user-specified name:

```
Auto-naming:   .data.id       → $CHAIN_ID
               .access_token  → $CHAIN_ACCESS_TOKEN
               Location header→ $CHAIN_LOCATION

User-named:    "capture .data.id as $USER_ID"  → $USER_ID
```

Rules:
- Variable names are UPPER_SNAKE_CASE
- Auto-names are prefixed with `CHAIN_` to avoid collisions
- User-named variables have no prefix requirement
- Names must match `[A-Z][A-Z0-9_]{0,49}` (max 50 chars)

### Storage Scope

- Chain variables exist in **conversation working memory only**
- They are represented as a key-value map maintained by the agent across turns
- NEVER written to disk, log files, engram, or any persistent store
- Cleared when the conversation ends or user explicitly says "clear chain" / "reset chain"

### State Display

Before each chained request, the agent displays:

```
Chain Variables (step N):
  $USER_ID:       usr_123
  $ACCESS_TOKEN:  [REDACTED]
  $ITEM_STATUS:   active
```

Secret-pattern variables are always shown as `[REDACTED]`.

### Null Guard

When an extracted field resolves to `null`, `undefined`, empty string, or the field path does not exist:

```
Chain HALTED at step N.
Field `.data.token` resolved to null.
Cannot proceed — the next request depends on this value.

Suggested actions:
  1. Check the previous response body for the correct field path
  2. Verify the API returned the expected data
  3. Retry the previous request
```

The chain does NOT silently continue with a null value.

### Max Chain Depth

- Hard limit: **10 sequential requests** per chain
- At depth 10, the skill warns: "Chain depth limit reached (10 requests). Start a new chain for additional calls."
- Rationale: prevents runaway chains, keeps working memory bounded, forces the user to think in manageable segments

### Chain Declaration Syntax

Declared in the user's prompt or via the chain template:

```
Chain: create-and-verify
  Step 1: POST /api/users  body={"name":"Alice"}
          capture .data.id as $USER_ID
  Step 2: GET /api/users/$USER_ID
          assert status == 200
          assert .data.name == "Alice"
```

The agent parses this declaratively and executes steps sequentially.

---

## 9. Architecture Decisions

| # | Decision | Rationale | Alternative Considered |
|---|----------|-----------|----------------------|
| 1 | **curl-first in detection chain** | curl is pre-installed on macOS, most Linux distros, and Windows 10+ (as curl.exe). Highest availability across all three OS families. | httpie-first: better UX and JSON-native output, but requires manual install on most systems. Would fail on fresh environments. |
| 2 | **Env var references only, never literal tokens** | Shell history, screen sharing, and log files are all attack surfaces. Env vars keep secrets out of command text entirely. The agent asks for the var NAME, not the value. | Allow inline tokens with a "--unsafe" flag: would cover quick-test scenarios but normalizes bad security habits. One accidental commit of a literal token can compromise an account. |
| 3 | **Auth inference is suggestion-only, never auto-applied** | False positive auth headers can cause confusing 401/403 errors or send credentials to the wrong scheme. Confirmation prevents silent misauth. | Auto-apply with high-confidence matches: faster for known providers but dangerous if URL patterns overlap (e.g., corporate proxies mimicking github.com hostnames). |
| 4 | **Secret-redact runs at two pipeline points (pre-output + post-response)** | Pre-output catches secrets in the constructed command. Post-response catches secrets returned by the API. Both must be redacted before the user sees ANY output. A single point would miss one surface. | Single post-response redaction: simpler but would display literal env var references (which contain the var name, not the value — acceptable) AND miss cases where request-build accidentally interpolates a value. Two points is defense-in-depth. |
| 5 | **OS detection cached per session, not per request** | OS, shell, and available client do not change within a conversation. Re-detecting on every request wastes a Bash tool call and adds latency for zero benefit. | Per-request detection: guarantees correctness if the user switches shells mid-session. Extremely unlikely in practice and the user can force re-detection explicitly. |
| 6 | **Chain variables in working memory only, never persisted** | Chain variables often contain auth tokens, session IDs, or PII. Writing them to disk (even temporarily) creates a secret leakage vector. Working memory is cleared when the conversation ends. | Persist to a temp file for cross-session chains: enables resuming multi-step workflows but creates files containing secrets. Violates REQ-SEC-006 and REQ-CHN-006. |
| 7 | **Content-Type inference never overrides explicit headers** | The user (or upstream tooling) may have a valid reason for a specific Content-Type. Overriding silently breaks those cases. Warning on mismatch preserves user intent while surfacing likely mistakes. | Auto-correct obvious mismatches: would prevent 415 errors but violates the principle that the user's explicit input takes precedence. A warning achieves the same goal without overriding. |
| 8 | **Assertions evaluate ALL rules, never short-circuit** | Partial results hide secondary failures. If status fails but a body field also has the wrong value, the user needs to know BOTH to fix the issue in one pass. | Fail-fast (halt on first failure): faster feedback for simple cases, but forces multiple test cycles to find all issues. Batch reporting is standard in test frameworks for good reason. |
| 9 | **Single SKILL.md with references/ for lookup tables** | SKILL.md contains the critical-path protocol the agent MUST follow. References contain extended data (error catalogs, provider lists) that the agent looks up on demand. This keeps the core file scannable while supporting deep reference data. | Everything in SKILL.md: simpler loading but the file would exceed 1000 lines, making it hard to maintain and slow to parse. Multiple SKILL files: breaks the single-entry-point convention established by path-context-skill and git-setup-skill. |

---

## 10. What Goes in references/ vs SKILL.md

### Decision Rule

| Goes in SKILL.md | Goes in references/ | Goes in assets/ |
|-------------------|---------------------|-----------------|
| Behavioral protocol the agent MUST follow on every invocation | Lookup tables the agent consults conditionally | Templates the agent copies/adapts for output |
| Activation rules and constraints | Extended catalogs (100+ entries) | Syntax examples for user-facing formats |
| Pipeline sequence and ordering | Provider-specific data (auth patterns per API) | Reusable command skeletons |
| Security rules (non-negotiable) | OS/shell/client flag compatibility tables | Chain declaration format |
| Output format specification | Edge case handling and rare scenarios | Assertion syntax reference |
| Chain state model and null guard rules | Historical error code mappings | |

### Concrete File Assignments

**SKILL.md** (always loaded, always followed):
- Frontmatter and trigger phrases
- When to Use / Activation Rules
- All 9 Critical Patterns (protocol steps, decision logic, ordering)
- Security Protocol (redaction pipeline position, env var enforcement, HTTP warning)
- Output Format (rendering order: status → headers → body)
- Constraints (max chain depth, hard limits, never-do rules)

**references/os-detection.md** (loaded by Pattern 1 when constructing commands):
- Full flag compatibility table per client (curl, curl.exe, httpie, IRM)
- Shell-specific quoting rules (single vs double vs escaped)
- Line continuation character table
- Install guidance per OS
- curl.exe vs curl difference matrix

**references/security.md** (loaded by Pattern 3 on every request):
- Complete redaction regex table with examples
- Response body field name scan list
- Env var syntax per shell table

**references/auth-patterns.md** (loaded by Pattern 6 when auth-infer triggers):
- Provider → auth scheme mapping (hostname patterns)
- Confidence scoring rules
- Env var naming suggestions per provider (e.g., `$GITHUB_TOKEN`, `$STRIPE_API_KEY`)

**references/error-catalog.md** (loaded by Pattern 5 on 4xx/5xx/connection error):
- Complete status code → diagnosis → fix suggestion table
- Network error mapping (ECONNREFUSED, ETIMEDOUT, DNS failures)
- SSL/TLS error handling rules (localhost vs non-localhost)

**references/pagination-patterns.md** (loaded by Pattern 4 when parsing responses):
- Field name heuristics for cursor/offset/page pagination
- Link header parsing rules (RFC 8288)
- Provider-specific pagination conventions

**assets/request-template.md** (loaded by Pattern 2 during request-build):
- curl command skeleton with placeholders
- httpie command skeleton with placeholders
- Invoke-RestMethod command skeleton with placeholders
- Per-shell quoting examples

**assets/chain-template.md** (loaded by Pattern 8 when chaining):
- Chain declaration syntax with examples
- Variable capture syntax
- Multi-step chain example (3-step CRUD)

**assets/assertion-patterns.md** (loaded by Pattern 9 when assertions are defined):
- Assertion syntax reference (status, header, body, latency)
- Dot-path notation examples
- Regex assertion examples
- PASS/FAIL output format template
