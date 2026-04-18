# Spec: Content-Type Infer

## Overview

Automatically detects the correct `Content-Type` header value from the shape of the request body, and warns when an explicitly set Content-Type conflicts with the actual body format. This prevents silent serialization mismatches that cause 400/415 errors.

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| REQ-CTI-001 | MUST infer `application/json` when the body string starts with `{` or `[` (after trimming leading whitespace) | MUST |
| REQ-CTI-002 | MUST infer `application/x-www-form-urlencoded` when the body matches the pattern `key=value` pairs joined by `&` with no JSON delimiters | MUST |
| REQ-CTI-003 | MUST infer `multipart/form-data` when the body contains form boundary markers (e.g., `--boundary`, `Content-Disposition: form-data`) | MUST |
| REQ-CTI-004 | MUST omit the `Content-Type` header entirely for GET, HEAD, and DELETE requests that carry no body | MUST |
| REQ-CTI-005 | SHOULD emit a warning when the body shape and an explicitly provided `Content-Type` header do not match (e.g., JSON body with `application/x-www-form-urlencoded`) | SHOULD |
| REQ-CTI-006 | MUST NOT override an explicitly provided `Content-Type` header — inference applies only when no Content-Type is present | MUST |
| REQ-CTI-007 | MUST pass the inferred or confirmed Content-Type to the request-build capability as part of the final header set | MUST |
| REQ-CTI-008 | SHOULD surface `text/plain` as a fallback inference when body is non-empty but matches none of the above patterns | SHOULD |

## Scenarios

### SCN-CTI-001: JSON object body — Content-Type inferred

**Given**: The request body is `{"username":"alice","password":"secret"}` and no `Content-Type` header is set
**When**: Content-type infer runs
**Then**: `Content-Type: application/json` is added to the request headers and reported as "inferred from body shape (JSON object detected)"

### SCN-CTI-002: Form-encoded body — Content-Type inferred

**Given**: The request body is `username=alice&password=secret` and no `Content-Type` header is set
**When**: Content-type infer runs
**Then**: `Content-Type: application/x-www-form-urlencoded` is added and reported as "inferred from body shape (form-encoded pairs detected)"

### SCN-CTI-003: Explicit Content-Type mismatch warning

**Given**: The request body is `{"name":"Alice"}` (JSON) and the caller explicitly set `Content-Type: application/x-www-form-urlencoded`
**When**: Content-type infer runs
**Then**: The explicit header is preserved unchanged, but the skill emits a warning: "Body appears to be JSON but Content-Type is application/x-www-form-urlencoded — this may cause a 400 or 415 error"

### SCN-CTI-004: GET request with no body

**Given**: The request method is GET and no body is present
**When**: Content-type infer runs
**Then**: No `Content-Type` header is added and no inference warning is emitted

### SCN-CTI-005: Unrecognized body shape — text/plain fallback

**Given**: The request body is `Hello, API!` (plain text, no JSON or form structure)
**When**: Content-type infer runs
**Then**: `Content-Type: text/plain` is suggested as a fallback inference with note "body shape not recognized as JSON or form-encoded"
