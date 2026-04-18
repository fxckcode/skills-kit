# Tasks: api-test-skill

## Phase 1: Infrastructure
- [ ] 1.1 Create `skills/api-test-skill/` root directory
- [ ] 1.2 Create `skills/api-test-skill/assets/` directory
- [ ] 1.3 Create `skills/api-test-skill/references/` directory
- [ ] 1.4 Create `skills/api-test-skill/openspec/` directory tree (already exists — verify `changes/api-test-skill/` subfolder is present)

---

## Phase 2: SKILL.md — Frontmatter & Structure
- [ ] 2.1 Write YAML frontmatter block: `name: api-test`, `version: v1.0`, `license: Apache-2.0`, `author: gentleman-programming`; include `triggers` list with EN phrases ("test this API", "make a request to", "call this endpoint", "send a GET/POST/PUT/PATCH/DELETE to", "curl this URL", "hit this endpoint") and ES equivalents ("probá esta API", "hacé un request a", "llamá a este endpoint", "mandá un GET/POST a", "curl a esta URL") — satisfies REQ-FRONT-001
- [ ] 2.2 Write **Section: When to Use** — bullet list explaining the skill activates when the user wants to test, debug, or call an HTTP API endpoint; include 3 EN + 3 ES trigger phrase examples directly in the list — satisfies REQ-WHEN-001

---

## Phase 3: SKILL.md — Activation Rules
- [ ] 3.1 Write **Section: Activation Rules** — document: (a) fire once per turn regardless of how many endpoints are mentioned; (b) OS detection result is cached for the entire conversation and must not be re-run; (c) re-trigger conditions (new OS signal detected, user switches shell explicitly, chain cleared) — satisfies REQ-ACT-001, REQ-ACT-002, REQ-ACT-003

---

## Phase 4: SKILL.md — Pattern 1 (OS Detection Protocol)
- [ ] 4.1 Write **Pattern 1: OS Detection Protocol** — document the detection sequence: (1) detect OS from context clues or ask, (2) infer shell (bash/zsh → unix; PowerShell → ps; cmd → cmd), (3) select HTTP client (curl on unix/mac, curl.exe on Windows CMD, Invoke-RestMethod on PowerShell, httpie as fallback), (4) apply correct flag set. Include: curl-first preference rule; curl.exe vs curl distinction table (detection trigger, flag differences, quoting differences); flag template table per client × flag type (header, body, method, output, insecure); line-continuation character table (bash: `\`, PowerShell: `` ` ``, cmd: `^`); install guidance per OS (curl, httpie, Invoke-RestMethod availability). Reference `references/os-detection.md` for full lookup tables — satisfies REQ-OSD-001 through REQ-OSD-005

---

## Phase 5: SKILL.md — Pattern 2 (Request Execution Pipeline)
- [ ] 5.1 Write **Pattern 2: Request Execution Pipeline** — document the ordered 12-step pipeline with an ASCII diagram. Steps: (1) Detect OS/shell, (2) Select HTTP client, (3) Infer auth scheme (if URL has auth signals), (4) Infer Content-Type (if body present), (5) Apply security protocol (env vars, redact tokens), (6) Build command scaffold, (7) Insert headers, (8) Insert body or params, (9) Apply chain variable substitutions (if chaining), (10) Execute request, (11) Parse and classify response, (12) Run assertions (if any declared). ASCII diagram must show step numbers and arrows connecting each stage — satisfies REQ-PIPE-001 through REQ-PIPE-012

---

## Phase 6: SKILL.md — Pattern 3 (Security Protocol)
- [ ] 6.1 Write **Pattern 3: Security Protocol** — document: (a) env var enforcement rule — never inline tokens in commands, always use env var syntax; (b) env var syntax per shell: `$VAR` (bash/zsh), `$env:VAR` (PowerShell), `%VAR%` (cmd); (c) literal token refusal instruction — if user pastes a raw token/key in the prompt, refuse to include it inline and ask them to set an env var, then use the var name; (d) HTTP warning trigger — if URL starts with `http://` (not `https://`), emit a visible warning block before the command; (e) response field scan — after receiving a response, scan for fields matching known secret patterns and redact them in output. Reference `references/security.md` for redaction regex patterns — satisfies REQ-SEC-001 through REQ-SEC-005

---

## Phase 7: SKILL.md — Pattern 4 (Response Interpretation)
- [ ] 7.1 Write **Pattern 4: Response Interpretation** — document: (a) status code classification: 1xx=Informational, 2xx=Success, 3xx=Redirect (follow or report), 4xx=Client Error, 5xx=Server Error; (b) body parsing: detect JSON (pretty-print), detect XML (indent), detect plain text (render as-is), detect binary (show hex summary or skip); (c) header parsing: surface Content-Type, X-RateLimit-*, Location, Set-Cookie (redacted), WWW-Authenticate; (d) pagination signals: detect fields `next`, `nextCursor`, `next_cursor`, `next_page`, `after`, `before`, `page`, `total_pages`, `hasMore`, `has_more`, Link header — surface them as chainable references; (e) rendering order: status line → headers → body — satisfies REQ-RESP-001 through REQ-RESP-005

---

## Phase 8: SKILL.md — Pattern 5 (Error Diagnosis)
- [ ] 8.1 Write **Pattern 5: Error Diagnosis** — include inline quick-reference table mapping common status codes to fix suggestions: 401→"Check auth token/env var", 403→"Check permissions/scopes", 404→"Verify URL path and base URL", 422→"Check request body shape and required fields", 429→"Rate limited — add delay or check Retry-After header", 5xx→"Server error — retry or check server logs", ECONNREFUSED→"Server not running or wrong port", SSL error→"Try --insecure flag or check cert". Provide pointer to `references/error-catalog.md` for the complete error table covering all 4xx, 5xx, and network errors — satisfies REQ-ERR-001 through REQ-ERR-003

---

## Phase 9: SKILL.md — Pattern 6 (Auth Inference)
- [ ] 9.1 Write **Pattern 6: Auth Inference** — document: (a) suggestion-only rule — the agent infers auth scheme from URL pattern but NEVER applies it without user confirmation; (b) confirmation message format ("I detected this may use Bearer token auth — want me to add the Authorization header?"); (c) cache inferred scheme per hostname for the conversation duration; (d) confidence levels: HIGH (URL matches known provider in auth-patterns.md), MEDIUM (URL contains `/oauth/`, `/auth/`, `/token/`), LOW (no signals found); (e) URL pattern matching logic (hostname-first, then path segment scan). Reference `references/auth-patterns.md` for the provider → scheme table — satisfies REQ-AUTH-001 through REQ-AUTH-004

---

## Phase 10: SKILL.md — Pattern 7 (Content-Type Inference)
- [ ] 10.1 Write **Pattern 7: Content-Type Inference** — document the 5 body shape rules: (1) `{...}` or `[...]` → `application/json`; (2) `key=value&key2=value2` → `application/x-www-form-urlencoded`; (3) `---boundary` or multipart signals → `multipart/form-data`; (4) XML-like tags → `application/xml`; (5) plain string → `text/plain`. Also document: (a) omit Content-Type header entirely for GET, HEAD, DELETE requests (no body); (b) mismatch warning rule — if user explicitly sets a Content-Type that doesn't match the inferred body shape, emit a warning but NEVER override the user's explicit value — satisfies REQ-CT-001 through REQ-CT-003

---

## Phase 11: SKILL.md — Pattern 8 (Request Chaining)
- [ ] 11.1 Write **Pattern 8: Request Chaining** — document: (a) variable naming convention: `$CHAIN_{FIELD}` (e.g., `$CHAIN_ID`, `$CHAIN_TOKEN`); (b) variable capture syntax — how to declare capture from a response field using dot-path; (c) null guard rule — if a captured variable is null/undefined/missing, halt chain with message: "Chain halted: `$CHAIN_{FIELD}` resolved to null from step N. Fix step N before continuing."; (d) max chain depth: 10 steps — warn at step 8, hard stop at 10; (e) secret variable display — any chain var whose name contains TOKEN, KEY, SECRET, or PASSWORD must be displayed as `[REDACTED]` in output; (f) chain clear instruction — user can say "clear chain" to reset all `$CHAIN_*` variables. Reference `assets/chain-template.md` for usage syntax — satisfies REQ-CHAIN-001 through REQ-CHAIN-006

---

## Phase 12: SKILL.md — Pattern 9 (Response Assertions)
- [ ] 12.1 Write **Pattern 9: Response Assertions** — document: (a) all-assertions-evaluated rule — NEVER short-circuit on first failure; evaluate every declared assertion even if earlier ones fail; (b) PASS/FAIL output per assertion showing actual vs expected values; (c) assertion types: status (exact match), header (exact or regex), body (dot-path value or regex), latency (less-than threshold in ms); (d) dot-path notation for nested JSON fields (e.g., `body.data.id`); (e) regex syntax support (`~=` operator); (f) latency threshold support (`< 500ms`); (g) summary line: "N/M assertions passed" at the end of the assertion block. Reference `assets/assertion-patterns.md` for syntax examples — satisfies REQ-ASSERT-001 through REQ-ASSERT-007

---

## Phase 13: SKILL.md — Output Format & Constraints
- [ ] 13.1 Write **Section: Output Format** — specify rendering order: (1) status line with code + text + latency, (2) selected response headers (Content-Type, X-RateLimit-*, Location, pagination-related), (3) response body (pretty-printed if JSON/XML); specify max body preview length (500 lines — truncate with "... [truncated, N lines omitted]"); specify assertion block placement (after body, before chain variable capture summary) — satisfies REQ-OUT-001 through REQ-OUT-003
- [ ] 13.2 Write **Section: Constraints** — hard limits and never-do rules: never inline credentials in commands; never override user's explicit Content-Type; never execute a request automatically without showing the command first; never chain more than 10 steps; never short-circuit assertions; always warn on HTTP (non-HTTPS) URLs; always cache OS detection per conversation — satisfies REQ-CON-001 through REQ-CON-007

---

## Phase 14: references/os-detection.md
- [ ] 14.1 Write `references/os-detection.md` — include: (a) full flag lookup table with rows = HTTP clients (curl, curl.exe, httpie, Invoke-RestMethod) and columns = flag types (set header, set method, set body, set output format, skip TLS verification, follow redirects, verbose); (b) quoting rules per shell (bash: single or double quotes, PowerShell: single quotes preferred, cmd: double quotes, escape with `\"`); (c) curl.exe vs curl difference matrix (detection trigger, quoting behavior, env var expansion, exit code differences); (d) line-continuation characters (bash `\`, PowerShell `` ` ``, cmd `^`); (e) install commands per OS/package manager (brew, apt, winget, scoop, choco) — satisfies REQ-OSD-005 (lookup table expansion)

---

## Phase 15: references/security.md
- [ ] 15.1 Write `references/security.md` — include: (a) 6 redaction regex patterns with examples for each: Bearer tokens (`Bearer [A-Za-z0-9\-._~+/]+=*`), API keys (`[Aa]pi[_-]?[Kk]ey[\s:=]+\S+`), Basic auth (`Basic [A-Za-z0-9+/=]+`), JWT (`eyJ[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+`), private keys (PEM header `-----BEGIN`), generic secrets (`[Ss]ecret[\s:=]+\S+`); (b) response body field scan list — fields whose values must be redacted in output: `token`, `access_token`, `refresh_token`, `id_token`, `api_key`, `secret`, `password`, `private_key`; (c) env var syntax table per shell with examples (bash/zsh, PowerShell, cmd, fish) — satisfies REQ-SEC-001 through REQ-SEC-005 (full detail)

---

## Phase 16: references/auth-patterns.md
- [ ] 16.1 Write `references/auth-patterns.md` — include: (a) provider → auth scheme table with at least 8 providers: GitHub (Bearer via `Authorization: token` or `Authorization: Bearer`), Stripe (Bearer via `Authorization: Bearer sk_*`), Google APIs (Bearer via OAuth2 access token), Slack (Bearer via `Authorization: Bearer xoxb-*`), Twilio (Basic auth, Account SID + Auth Token), SendGrid (Bearer via `Authorization: Bearer SG.*`), AWS (AWS Signature v4, `Authorization: AWS4-HMAC-SHA256`), Firebase (Bearer via ID token); (b) env var naming convention per provider (e.g., `GITHUB_TOKEN`, `STRIPE_SECRET_KEY`, `GOOGLE_ACCESS_TOKEN`, `SLACK_BOT_TOKEN`, `TWILIO_AUTH_TOKEN`, `SENDGRID_API_KEY`, `AWS_SECRET_ACCESS_KEY`, `FIREBASE_ID_TOKEN`); (c) confidence scoring rules: HIGH if hostname matches known provider domain, MEDIUM if path matches auth keyword, LOW if no match — satisfies REQ-AUTH-001 through REQ-AUTH-004 (lookup detail)

---

## Phase 17: references/error-catalog.md
- [ ] 17.1 Write `references/error-catalog.md` — include complete tables: (a) 4xx errors: 400 Bad Request, 401 Unauthorized, 402 Payment Required, 403 Forbidden, 404 Not Found, 405 Method Not Allowed, 406 Not Acceptable, 408 Request Timeout, 409 Conflict, 410 Gone, 413 Payload Too Large, 415 Unsupported Media Type, 422 Unprocessable Entity, 423 Locked, 429 Too Many Requests, 451 Unavailable For Legal Reasons — each with fix suggestion; (b) 5xx errors: 500 Internal Server Error, 501 Not Implemented, 502 Bad Gateway, 503 Service Unavailable, 504 Gateway Timeout, 507 Insufficient Storage, 511 Network Authentication Required — each with fix suggestion; (c) network errors: ECONNREFUSED, ETIMEDOUT, EHOSTUNREACH, DNS_PROBE_FINISHED_NXDOMAIN — each with diagnosis steps; (d) SSL/TLS errors: certificate expired, self-signed cert, hostname mismatch — with `--insecure` flag warning — satisfies REQ-ERR-003 (full catalog)

---

## Phase 18: references/pagination-patterns.md
- [ ] 18.1 Write `references/pagination-patterns.md` — include: (a) cursor-based pattern — fields: `next_cursor`, `after`, `before`, `cursor`, `endCursor`; capture pattern: `$CHAIN_CURSOR = body.next_cursor`; (b) offset-based pattern — fields: `offset`, `limit`, `total`; (c) page-number pattern — fields: `page`, `per_page`, `total_pages`, `last_page`; (d) Link header pattern — RFC 8288 format (`Link: <url>; rel="next", <url>; rel="last"`), parse rule for `rel="next"` extraction; (e) `hasMore`/`has_more` boolean pattern — halt chain when false; (f) at least 5 provider-specific examples: GitHub (Link header), Stripe (cursor via `has_more` + `starting_after`), Notion (cursor via `has_more` + `next_cursor`), Twitter/X (cursor via `meta.next_token`), Elasticsearch (cursor via `_scroll_id`) — satisfies REQ-RESP-005 (pagination full detail)

---

## Phase 19: assets/request-template.md
- [ ] 19.1 Write `assets/request-template.md` — include command skeletons with placeholder variables for all 5 clients: (a) curl (unix/mac) — GET and POST skeletons with `{{METHOD}}`, `{{URL}}`, `{{HEADER_NAME}}`, `{{HEADER_VALUE}}`, `{{BODY}}`; (b) curl.exe (Windows CMD) — same structure with Windows quoting; (c) curl.exe (PowerShell) — same structure with PowerShell quoting and line-continuation; (d) httpie — `http {{METHOD}} {{URL}} {{HEADER_NAME}}:{{HEADER_VALUE}}` skeleton; (e) Invoke-RestMethod — PowerShell splatting skeleton with `-Uri`, `-Method`, `-Headers`, `-Body` params. Each skeleton must include a comment line explaining when to use it — satisfies REQ-PIPE-006 (client selection reference)

---

## Phase 20: assets/chain-template.md
- [ ] 20.1 Write `assets/chain-template.md` — include: (a) chain declaration format — how to declare a chain step and assign output variables; (b) variable capture syntax — `$CHAIN_{FIELD} = response.body.{dot.path}`; (c) complete 3-step CRUD example: Step 1 POST /users → capture `$CHAIN_ID = body.id`; Step 2 GET /users/$CHAIN_ID → verify created resource; Step 3 DELETE /users/$CHAIN_ID → verify deletion; each step shows the full command with variable substitution applied; (d) null guard example — what the halt message looks like when `$CHAIN_ID` is null; (e) secret variable display example — `$CHAIN_TOKEN` displayed as `[REDACTED]` — satisfies REQ-CHAIN-001, REQ-CHAIN-002, REQ-CHAIN-003

---

## Phase 21: assets/assertion-patterns.md
- [ ] 21.1 Write `assets/assertion-patterns.md` — include: (a) all 4 assertion types with syntax and example: status (`assert status == 201`), header (`assert header Content-Type == "application/json"` or `~= "json"`), body (`assert body.data.id != null`, `assert body.message ~= "created"`), latency (`assert latency < 500ms`); (b) dot-path notation guide — how to navigate nested JSON (arrays: `body.items[0].id`, objects: `body.data.user.email`); (c) regex operator (`~=`) syntax with 2 examples; (d) PASS/FAIL output template: `[PASS] status == 201 (actual: 201)` / `[FAIL] body.data.id != null (actual: null)`; (e) summary line template: `3/4 assertions passed`; (f) all-assertions-evaluated reminder note — satisfies REQ-ASSERT-001 through REQ-ASSERT-007

---

## Phase 22: Skill Registry Update
- [ ] 22.1 Update `CLAUDE.md` in the project root to add `skills/api-test-skill/` to the **Available Skills** table with description: "HTTP API testing — builds curl/httpie/IRM commands, chains requests, evaluates assertions, enforces security best practices"
- [ ] 22.2 Update `.atl/skill-registry.md` (or create if absent) to register `api-test-skill` with its trigger phrases (EN + ES), file path `skills/api-test-skill/SKILL.md`, and compact rules summary for orchestrator injection
