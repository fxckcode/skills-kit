# Spec: OS Detect

## Overview

Detects the operating system and available HTTP client before constructing any request command, then resolves the correct flag syntax and line-continuation character for the active shell. This ensures generated commands are executable without modification on the user's actual environment.

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| REQ-OSD-001 | MUST detect the operating system (Windows, macOS, or Linux) before generating any request command | MUST |
| REQ-OSD-002 | MUST check for HTTP client availability in this order: curl (or curl.exe on Windows), httpie (http), Invoke-RestMethod (PowerShell) | MUST |
| REQ-OSD-003 | MUST distinguish `curl.exe` (Windows native) from `curl` (Unix/macOS/WSL) and emit the correct binary name in generated commands | MUST |
| REQ-OSD-004 | MUST apply correct flag syntax per client: curl uses `-H`, `-d`, `-X`; httpie uses `key:value` style; Invoke-RestMethod uses `-Headers`, `-Body`, `-Method` | MUST |
| REQ-OSD-005 | MUST output the correct line-continuation character: `\` for bash/zsh, `` ` `` for PowerShell, `^` for cmd.exe, single-line if shell is unknown | MUST |
| REQ-OSD-006 | MUST report which HTTP client was selected and the reason (e.g., "curl.exe found on PATH — Windows detected") | MUST |
| REQ-OSD-007 | SHOULD fall back to emitting a single-line command when the active shell cannot be determined | SHOULD |
| REQ-OSD-008 | MUST NOT proceed to request construction if no supported HTTP client is found — MUST surface a clear error with install guidance | MUST |

## Scenarios

### SCN-OSD-001: Curl detected on Linux with bash shell

**Given**: The environment is Linux, `curl` is available on PATH, and the active shell is bash
**When**: OS detection runs before a request is built
**Then**: The skill selects `curl`, uses `\` as the line-continuation character, emits Unix-style flags (`-H`, `-d`, `-X`), and reports "curl selected — Linux/bash detected"

### SCN-OSD-002: Windows with curl.exe and PowerShell

**Given**: The environment is Windows, `curl.exe` is available on PATH, and the active shell is PowerShell
**Then**: The skill selects `curl.exe`, uses `` ` `` as the line-continuation character, emits Windows curl flags, and reports "curl.exe selected — Windows/PowerShell detected"

### SCN-OSD-003: No curl available — falls back to httpie

**Given**: The environment is macOS, `curl` is NOT on PATH, but `http` (httpie) is available
**When**: OS detection runs
**Then**: The skill selects httpie, applies httpie key-value header syntax, uses `\` as continuation, and reports "httpie selected — curl not found"

### SCN-OSD-004: No supported HTTP client found

**Given**: The environment has no `curl`, `curl.exe`, `http`, or `Invoke-RestMethod` available
**When**: OS detection runs
**Then**: The skill halts, reports an error listing missing clients, and provides install instructions for the detected OS — no request command is generated

### SCN-OSD-005: Shell cannot be determined

**Given**: The environment has `curl` available but the active shell cannot be identified
**When**: OS detection runs
**Then**: The skill selects `curl`, emits the full request as a single-line command (no line-continuation), and notes "shell unknown — single-line format used"
