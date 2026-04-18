# Spec: Secret Redact

## Overview

Detects and redacts known secret patterns from all output before display, and warns when insecure conditions (HTTP non-localhost, token-like fields in response bodies) are detected. Secrets are never stored to disk, logs, or any persistent artifact.

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| REQ-SEC-001 | MUST redact Bearer token values matching the pattern `Bearer [A-Za-z0-9._\-]{10,}` in any displayed output — replace with `Bearer [REDACTED]` | MUST |
| REQ-SEC-002 | MUST redact values matching the pattern `api[_\-]?key[=:]\s*[^\s&"]+` (case-insensitive) — replace value portion with `[REDACTED]` | MUST |
| REQ-SEC-003 | MUST redact the full value of any `Authorization` header before display, preserving only the scheme prefix (e.g., `Authorization: Bearer [REDACTED]`) | MUST |
| REQ-SEC-004 | MUST warn the user when the request URL uses the `http://` scheme and the host is not `localhost` or `127.0.0.1` | MUST |
| REQ-SEC-005 | SHOULD warn when a response body contains fields named `token`, `access_token`, `api_key`, or `secret` — surface field names without displaying values | SHOULD |
| REQ-SEC-006 | SHALL NOT store any redacted or unredacted secret value to disk, log files, or any persistent store | SHALL NOT |
| REQ-SEC-007 | MUST apply redaction to all output paths: request command display, response display, chain variable summaries, and assertion reports | MUST |
| REQ-SEC-008 | MUST redact before any output is rendered — MUST NOT display unredacted values even temporarily | MUST |

## Scenarios

### SCN-SEC-001: Bearer token redacted in request command display

**Given**: A request command includes `-H "Authorization: Bearer eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJ1c2VyMSJ9.abc123"`
**When**: Secret redact runs before command display
**Then**: The displayed command shows `-H "Authorization: Bearer [REDACTED]"` — the raw token value never appears in output

### SCN-SEC-002: API key in query string redacted

**Given**: A request URL is `https://api.example.com/data?api_key=sk-live-abcdef1234567890`
**When**: Secret redact runs
**Then**: The displayed URL shows `https://api.example.com/data?api_key=[REDACTED]` — the key value is replaced before display

### SCN-SEC-003: HTTP non-localhost URL triggers security warning

**Given**: A request targets `http://api.example.com/users`
**When**: Secret redact evaluates the request
**Then**: A warning is emitted: "WARNING: HTTP scheme detected for non-localhost URL — credentials may be transmitted in plaintext. Use HTTPS."

### SCN-SEC-004: Response body contains token-like fields — warning without value display

**Given**: A response body contains `{"access_token":"eyJ...","user_id":"123"}`
**When**: Secret redact evaluates the response
**Then**: The skill warns: "Response contains sensitive fields: access_token — values not displayed. Use chain-request to capture securely." The field value is never shown in plain text.

### SCN-SEC-005: Redaction applies to chain variable summary

**Given**: A chain has captured `$ACCESS_TOKEN` with value `eyJhbGciOiJSUzI1NiJ9.abc`
**When**: The chain variable summary is displayed before the next request
**Then**: The summary shows `$ACCESS_TOKEN: [REDACTED]` — the actual token value is not printed

### SCN-SEC-006: Secret never written to disk across any operation

**Given**: A full request-build → send → response-interpret → chain-request workflow runs with Bearer auth
**When**: The entire workflow completes
**Then**: No file, log entry, or openspec artifact contains any unredacted token, API key, or Authorization header value
