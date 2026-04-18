# Spec: Error Diagnose

## Overview

Maps HTTP error status codes and common network-level errors to specific, actionable fix suggestions by examining both the status code and the response body. Rather than presenting raw error data, this capability translates errors into next steps.

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| REQ-ERD-001 | MUST map status 401 to a suggestion covering: token expired, wrong credentials, or missing Authorization header | MUST |
| REQ-ERD-002 | MUST map status 403 to a suggestion covering: insufficient permissions, wrong OAuth scope, or IP allowlist | MUST |
| REQ-ERD-003 | MUST map status 404 to a suggestion covering: wrong path, missing resource ID, or incorrect API version | MUST |
| REQ-ERD-004 | MUST map status 422 to display the validation error details extracted from the response body (field names and messages when available) | MUST |
| REQ-ERD-005 | MUST map status 429 to read the `Retry-After` header value and surface the exact wait duration or next-retry timestamp | MUST |
| REQ-ERD-006 | MUST map 5xx status codes to a "server-side error" message and suggest retry with exponential backoff | MUST |
| REQ-ERD-007 | MUST map `ECONNREFUSED` (or equivalent connection refused error) to: service may be down, wrong port, or firewall rule | MUST |
| REQ-ERD-008 | SHOULD map SSL/TLS certificate errors to a suggestion to use the insecure flag (`-k` / `--insecure`) for localhost only — MUST NOT suggest `--insecure` for non-localhost targets | SHOULD |
| REQ-ERD-009 | MUST include the raw status code and a one-line summary of the error alongside all suggestions | MUST |
| REQ-ERD-010 | MUST NOT emit `--insecure` suggestions for non-localhost SSL errors — MUST instead advise checking the certificate chain | MUST |

## Scenarios

### SCN-ERD-001: 401 with expired token body hint

**Given**: A response with status 401 and body `{"error":"token_expired","message":"JWT expired at 2025-01-01T00:00:00Z"}`
**When**: Error diagnose runs
**Then**: The skill outputs "401 Unauthorized — token likely expired" and suggests: "(1) refresh your token, (2) verify `$TOKEN` env var is up to date, (3) check token expiry claim"

### SCN-ERD-002: 422 with validation errors in body

**Given**: A response with status 422 and body `{"errors":{"email":["is invalid"],"name":["can't be blank"]}}`
**When**: Error diagnose runs
**Then**: The skill extracts and displays: "422 Unprocessable Entity — validation failed: email: is invalid | name: can't be blank" and suggests fixing the listed fields in the request body

### SCN-ERD-003: 429 with Retry-After header

**Given**: A response with status 429 and header `Retry-After: 30`
**When**: Error diagnose runs
**Then**: The skill outputs "429 Too Many Requests — rate limit hit. Retry-After: 30 seconds. Resume at [current_time + 30s]"

### SCN-ERD-004: ECONNREFUSED error

**Given**: The HTTP client returns a connection refused error (no response received)
**When**: Error diagnose runs
**Then**: The skill outputs "Connection refused — possible causes: (1) service is not running on the target port, (2) wrong port number, (3) firewall is blocking the connection"

### SCN-ERD-005: SSL error on localhost — insecure flag suggested

**Given**: The HTTP client returns an SSL certificate error for target `https://localhost:8443`
**When**: Error diagnose runs
**Then**: The skill suggests adding `-k` / `--insecure` flag with note "only safe for localhost — never use --insecure against production endpoints"

### SCN-ERD-006: SSL error on non-localhost — insecure NOT suggested

**Given**: The HTTP client returns an SSL certificate error for target `https://api.example.com`
**When**: Error diagnose runs
**Then**: The skill outputs a certificate chain diagnosis suggestion and explicitly does NOT suggest `--insecure` — instead advises: "verify CA bundle, check certificate expiry, ensure system trust store is up to date"
