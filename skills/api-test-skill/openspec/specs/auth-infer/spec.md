# Spec: Auth Infer

## Overview

Infers the most likely authentication scheme from URL patterns, existing headers, and known API provider conventions, then presents the inference as a suggestion for the user or agent to confirm — never applying auth automatically.

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| REQ-AUI-001 | MUST infer Bearer token auth when the URL hostname matches known Bearer-based providers (e.g., `api.github.com`, `api.stripe.com`, `api.openai.com`, `graph.microsoft.com`) | MUST |
| REQ-AUI-002 | MUST infer Basic auth when the URL or accompanying documentation signals username:password credentials (e.g., URL contains `@`, or docs reference "Basic authentication") | MUST |
| REQ-AUI-003 | MUST infer API key header auth when the URL or docs reference patterns such as `x-api-key`, `api-key`, or `apikey` query parameters | MUST |
| REQ-AUI-004 | MUST check for an existing `Authorization` header before running inference — MUST NOT overwrite or suggest replacing an already-present Authorization header | MUST |
| REQ-AUI-005 | MUST present the inferred auth scheme as a suggestion with reasoning, not as an automatic action | MUST |
| REQ-AUI-006 | SHALL NOT apply inferred auth to the request without explicit user or agent confirmation | SHALL NOT |
| REQ-AUI-007 | MUST surface the env var reference template for the inferred scheme (e.g., `Authorization: Bearer $GITHUB_TOKEN`) so the user knows which variable to set | MUST |
| REQ-AUI-008 | SHOULD indicate confidence level (high / medium / low) based on pattern match quality | SHOULD |

## Scenarios

### SCN-AUI-001: GitHub API URL — Bearer inferred at high confidence

**Given**: The target URL is `https://api.github.com/repos/owner/repo/issues` and no `Authorization` header exists
**When**: Auth infer runs
**Then**: The skill suggests "Bearer token auth (high confidence) — GitHub API detected. Add: `-H 'Authorization: Bearer $GITHUB_TOKEN'`" and waits for confirmation before any header is added to the request

### SCN-AUI-002: Existing Authorization header — inference skipped

**Given**: The request already includes `Authorization: Bearer $MY_TOKEN`
**When**: Auth infer runs
**Then**: The skill detects the existing header, skips inference entirely, and outputs "Authorization header already present — no inference needed"

### SCN-AUI-003: URL with x-api-key pattern — API key inferred

**Given**: The target URL is `https://api.someservice.com/v1/data` and the API docs (or existing headers) reference `x-api-key`
**When**: Auth infer runs
**Then**: The skill suggests "API key auth (medium confidence) — x-api-key pattern detected. Add: `-H 'x-api-key: $API_KEY'`" and requires confirmation

### SCN-AUI-004: Unknown URL — no inference, low confidence

**Given**: The target URL is `https://internal.corp.local/api/v2/data` with no known pattern match
**When**: Auth infer runs
**Then**: The skill reports "Auth scheme could not be inferred (low confidence)" and prompts the user to specify the auth type manually — no suggestion is applied

### SCN-AUI-005: Basic auth inferred from URL credentials

**Given**: The target URL is `https://user@api.example.com/data`
**When**: Auth infer runs
**Then**: The skill infers Basic auth, suggests `-u "$API_USER:$API_PASS"` (curl) or equivalent, notes "credentials detected in URL — Basic auth inferred", and requires confirmation before proceeding
