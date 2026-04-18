# Spec: Chain Request

## Overview

Extracts named fields from a response body and makes them available as variables for use in subsequent requests, enabling multi-step API workflows (e.g., create → fetch → update) without manual copy-paste. All chained values exist in session memory only and are never written to disk.

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| REQ-CHN-001 | MUST extract named fields from a JSON response body using dot-path notation (e.g., `.data.id`, `.user.token`) | MUST |
| REQ-CHN-002 | MUST allow referencing extracted values in subsequent request parameters using `$VAR` syntax | MUST |
| REQ-CHN-003 | MUST assert that an extracted value is non-null and non-empty before making it available for chaining — MUST surface an error and halt the chain if the assertion fails | MUST |
| REQ-CHN-004 | MUST surface all chainable fields detected in the response after every request: fields named `id`, `token`, `href`, `url`, `location`, and the `Location` response header | MUST |
| REQ-CHN-005 | SHOULD support chaining across at least 3 sequential requests within a single session | SHOULD |
| REQ-CHN-006 | SHALL NOT write chained values to disk, log files, or any persistent store — session memory only | SHALL NOT |
| REQ-CHN-007 | MUST display the active chain variables and their (redacted) values before each subsequent request in the chain | MUST |
| REQ-CHN-008 | MUST allow the user to name the extracted variable explicitly (e.g., "capture `.data.id` as `$USER_ID`") | MUST |

## Scenarios

### SCN-CHN-001: Create resource and chain ID to subsequent GET

**Given**: A POST to `/api/users` returns `{"data":{"id":"usr_123","email":"alice@example.com"}}` and the chain is configured to capture `.data.id` as `$USER_ID`
**When**: The chain advances to the next request
**Then**: `$USER_ID` is set to `usr_123`, displayed (potentially redacted) in the chain variable summary, and the next request uses `GET /api/users/$USER_ID` without requiring manual input

### SCN-CHN-002: Extracted field is null — chain halted

**Given**: A POST to `/api/sessions` returns `{"data":{"id":null}}` and the chain is configured to capture `.data.id` as `$SESSION_ID`
**When**: Chain request attempts to extract the value
**Then**: The skill emits "Chain halted — `.data.id` is null. Cannot proceed to next request." and stops the chain without making further calls

### SCN-CHN-003: Three-step chain — create, read, delete

**Given**: Step 1 creates a resource and captures `.id` as `$ITEM_ID`; step 2 GETs `/items/$ITEM_ID` and captures `.status` as `$ITEM_STATUS`; step 3 DELETEs `/items/$ITEM_ID`
**When**: The full chain runs
**Then**: All three requests execute sequentially, each using variables from prior steps, and the chain summary shows step-by-step results

### SCN-CHN-004: Chainable fields surfaced after response

**Given**: A response with body `{"id":"abc","href":"/api/things/abc","token":"xyz"}` is received
**When**: Response interpret and chain-request run together
**Then**: The skill surfaces: "Chainable fields detected: id → `$ID`, href → `$HREF`, token → `$TOKEN` — confirm to capture"

### SCN-CHN-005: Chain variable not written to disk

**Given**: A chain captures `access_token` as `$ACCESS_TOKEN` during a session
**When**: The session ends or chain completes
**Then**: No file, log, or persistent artifact contains the value of `$ACCESS_TOKEN` — it exists only in session memory during the active workflow
