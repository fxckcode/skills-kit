# Spec: Response Interpret

## Overview

Parses an HTTP response and surfaces actionable information: status class, key headers, body structure, pagination signals, and potential auth tokens for chaining. Output is always presented in a consistent order — status, then headers summary, then body — to train a reliable mental model.

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| REQ-RSP-001 | MUST classify the status code into the correct class: 1xx informational, 2xx success, 3xx redirect, 4xx client error, 5xx server error | MUST |
| REQ-RSP-002 | MUST parse JSON response bodies and surface the names of all top-level fields | MUST |
| REQ-RSP-003 | MUST detect and report pagination signals in both the body and headers: fields named `next`, `nextCursor`, `totalPages`, `page`, `hasMore`, and the `Link` header | MUST |
| REQ-RSP-004 | SHOULD detect fields in the response body that are likely auth tokens (fields named `token`, `access_token`, `id_token`, `refresh_token`) and offer to capture them for chaining | SHOULD |
| REQ-RSP-005 | SHALL display response information in this order: status line → headers summary → body | SHALL |
| REQ-RSP-006 | MUST handle non-JSON bodies gracefully: report content type and raw length without attempting JSON parsing | MUST |
| REQ-RSP-007 | MUST surface the `Location` header value when status is 3xx | MUST |
| REQ-RSP-008 | MUST surface the `Retry-After` header value when status is 429 | MUST |
| REQ-RSP-009 | SHOULD truncate body display at 2000 characters and indicate truncation when body exceeds that limit | SHOULD |

## Scenarios

### SCN-RSP-001: Successful JSON response with pagination

**Given**: A response with status 200, `Content-Type: application/json`, and body `{"items":[...],"next":"/api/items?page=2","totalPages":5}`
**When**: Response interpret runs
**Then**: Status is classified as "2xx success", top-level fields `items`, `next`, `totalPages` are listed, pagination signal `next` and `totalPages` are highlighted, and output order is status → headers → body

### SCN-RSP-002: 401 response with non-JSON body

**Given**: A response with status 401 and `Content-Type: text/plain` and body "Unauthorized"
**When**: Response interpret runs
**Then**: Status is classified as "4xx client error", content type and raw body length are reported, no JSON parsing is attempted, and the status line appears first in output

### SCN-RSP-003: Auth token detected in response body

**Given**: A response with status 200 and body `{"access_token":"eyJ...","expires_in":3600}`
**When**: Response interpret runs
**Then**: The skill surfaces `access_token` as a chainable field and offers: "Capture `access_token` as `$ACCESS_TOKEN` for use in subsequent requests?"

### SCN-RSP-004: 301 redirect response

**Given**: A response with status 301 and `Location: https://api.example.com/v2/users`
**When**: Response interpret runs
**Then**: Status is classified as "3xx redirect" and the `Location` header value is prominently surfaced in the output

### SCN-RSP-005: Large body truncation

**Given**: A response with status 200 and a JSON body exceeding 2000 characters
**When**: Response interpret runs
**Then**: The displayed body is truncated at 2000 characters with a note "[truncated — full body: N bytes]"
