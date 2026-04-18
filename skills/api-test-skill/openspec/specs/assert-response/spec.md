# Spec: Assert Response

## Overview

Validates an HTTP response against a set of user-defined expectations — status code, body fields, headers, and response latency — and reports each assertion as PASS or FAIL with the actual value alongside the expected value, enabling lightweight inline API testing without a dedicated test framework.

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| REQ-AST-001 | MUST support status code assertion with exact match (e.g., assert status == 201) | MUST |
| REQ-AST-002 | MUST support body field assertions: exact value match, contains (substring/element), and regex match | MUST |
| REQ-AST-003 | MUST support header assertions: presence check (header exists) and exact value match | MUST |
| REQ-AST-004 | MUST report each assertion result as PASS or FAIL, showing the actual value and the expected value side by side | MUST |
| REQ-AST-005 | SHOULD support response latency threshold assertion (e.g., assert latency < 500ms) | SHOULD |
| REQ-AST-006 | SHOULD support multiple assertions per response evaluated in a single call, with individual results for each | SHOULD |
| REQ-AST-007 | MUST continue evaluating all assertions even when one fails — MUST NOT halt on first failure | MUST |
| REQ-AST-008 | MUST produce a final summary: total assertions, count passed, count failed | MUST |
| REQ-AST-009 | MUST use dot-path notation to address nested body fields (e.g., `.data.user.id`) | MUST |

## Scenarios

### SCN-AST-001: All assertions pass

**Given**: A response with status 201, body `{"data":{"id":"abc"}}`, header `Content-Type: application/json`, and latency 120ms
**When**: Assert response runs with: status == 201, `.data.id` contains "abc", header `Content-Type` == `application/json`, latency < 500ms
**Then**: All 4 assertions report PASS and the summary reads "4/4 passed"

### SCN-AST-002: Status code mismatch — FAIL reported

**Given**: A response with status 400 and body `{"error":"bad request"}`
**When**: Assert response runs with status == 200
**Then**: The assertion reports "FAIL — status: expected 200, actual 400" and the summary reads "0/1 passed"

### SCN-AST-003: Multiple assertions — partial failure, all evaluated

**Given**: A response with status 200, body `{"name":"Bob","age":30}`, and latency 600ms
**When**: Assert response runs with: status == 200, `.name` == "Alice", latency < 500ms
**Then**: Status assertion reports PASS; `.name` assertion reports "FAIL — expected 'Alice', actual 'Bob'"; latency assertion reports "FAIL — expected < 500ms, actual 600ms"; summary reads "1/3 passed" — all three are evaluated regardless of failures

### SCN-AST-004: Header presence assertion

**Given**: A response with headers `X-RateLimit-Remaining: 99` and `Content-Type: application/json`
**When**: Assert response runs with: header `X-RateLimit-Remaining` exists, header `X-Auth-Token` exists
**Then**: First assertion reports PASS; second reports "FAIL — header `X-Auth-Token` not present in response"

### SCN-AST-005: Regex body assertion

**Given**: A response body `{"createdAt":"2025-04-18T10:00:00Z"}`
**When**: Assert response runs with `.createdAt` matches regex `^\d{4}-\d{2}-\d{2}T`
**Then**: The assertion reports PASS — the value matches the ISO 8601 date pattern
