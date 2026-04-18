# Spec: Request Build

## Overview

Constructs a complete, executable HTTP request command from method, URL, headers, body, and auth inputs. All sensitive values are referenced via environment variables — never interpolated as literals — ensuring commands are safe to share or commit.

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| REQ-RQB-001 | MUST construct request commands that include method, URL, headers, and body when provided | MUST |
| REQ-RQB-002 | MUST reference auth values (tokens, API keys, passwords) exclusively via environment variable syntax (e.g., `$TOKEN`, `%TOKEN%`) — MUST NOT embed literal secret values | MUST |
| REQ-RQB-003 | MUST validate that the URL is absolute (starts with `http://` or `https://`) before constructing the command; MUST surface an error if not | MUST |
| REQ-RQB-004 | MUST warn the user when the URL scheme is `http://` and the host is not `localhost` or `127.0.0.1` | MUST |
| REQ-RQB-005 | SHOULD infer the HTTP method from context when not explicitly specified: POST when a body is present, GET otherwise | SHOULD |
| REQ-RQB-006 | MAY suggest adding a correlation ID header (e.g., `X-Request-ID`) to assist with traceability in distributed systems | MAY |
| REQ-RQB-007 | MUST delegate OS and client detection to the `os-detect` capability before emitting any command syntax | MUST |
| REQ-RQB-008 | MUST support all standard HTTP methods: GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS | MUST |
| REQ-RQB-009 | MUST preserve header casing as provided by the caller — MUST NOT normalize to lowercase | MUST |

## Scenarios

### SCN-RQB-001: POST request with JSON body and Bearer auth

**Given**: The caller provides URL `https://api.example.com/users`, no explicit method, a JSON body `{"name":"Alice"}`, and auth token referenced as `$API_TOKEN`
**When**: Request build runs
**Then**: The method is inferred as POST, the command includes `-H "Authorization: Bearer $API_TOKEN"`, `-H "Content-Type: application/json"`, and `-d '{"name":"Alice"}'` — no literal token appears anywhere in the output

### SCN-RQB-002: Relative URL rejected

**Given**: The caller provides URL `api/users` (relative)
**When**: Request build runs
**Then**: The skill emits an error "URL must be absolute (start with http:// or https://)" and halts — no command is generated

### SCN-RQB-003: HTTP non-localhost URL triggers warning

**Given**: The caller provides URL `http://api.example.com/data`
**When**: Request build runs
**Then**: The skill emits a warning "HTTP detected for non-localhost URL — credentials may be transmitted in plaintext" and proceeds to build the command with the warning visible

### SCN-RQB-004: GET request inferred when no body provided

**Given**: The caller provides only a URL and no body
**When**: Request build runs with no explicit method
**Then**: The method is inferred as GET and the generated command omits `-d` / body flags entirely

### SCN-RQB-005: Correlation ID header suggestion

**Given**: The request is targeting a non-localhost API with no `X-Request-ID` or `X-Correlation-ID` header
**When**: Request build runs
**Then**: The skill MAY append a suggestion: "Consider adding `-H 'X-Request-ID: <uuid>'` to trace this request in server logs"
