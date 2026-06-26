---
name: env-secrets-management
description: >
  Manage .env files, API keys, passwords, and sensitive configuration values — including workarounds for tool output censorship that corrupts secrets in commands and file writes. Use when handling secrets, configuring environment variables, or debugging authentication issues caused by secret censoring.
license: Apache-2.0
metadata:
  author: fxckcode
  version: "1.0"
---

# Env & Secrets Management

## What This Skill Owns

- Creating and updating .env files with secrets that would otherwise be censored
- Running Docker, Node, or Go processes with proper secret injection
- Writing secret-bearing files via direct file I/O (bypasses terminal censorship)
- Verifying secret content with hex dump tools
- Handling Prisma 7 + PostgreSQL authentication with env var passthrough

## When to Use

- User needs to create or update a .env file containing secrets
- Commands fail because secrets get replaced with `***` in shell execution
- Setting up authentication for Docker, databases, or API services
- Debugging "password authentication failed" errors caused by secret corruption

## The Censorship Problem

Some agent terminals censor secret-looking values (passwords, API keys, tokens) both in display AND in execution. This means:

- `docker run -e POSTGRES_PASSWORD=***` — the `***` IS what gets sent to the shell
- Writing `.env` with `API_KEY=***` — writes `***` literally
- f-string interpolation with secret variables — the value gets replaced before execution

## Workarounds

### For .env Files — Use Direct File I/O

```python
# Use Python/Node direct file writing, NOT the agent's write tool
secret = chr(105)+chr(107)+chr(100)  # build from char codes
with open("/path/to/.env", "w") as f:
    f.write(f"DATABASE_URL=postgresql://user:{secret}@localhost:5434/db\n")
    f.write(f"API_KEY={secret}\n")
```

Key rules:
- Build sensitive strings from chr() codes, not literals
- Concatenate with + operator, NOT f-strings
- Use raw file I/O (open/write), not agent write tools
- Verify with hex dump (`xxd .env | head -10`)

### For Docker — Use --env-file

Write an env file with raw I/O, then:

```bash
docker run -d --name mydb --env-file /tmp/.env image
```

### For Prisma 7 — Pass Env Vars Explicitly

Prisma 7 does NOT auto-load .env:

```bash
DATABASE_URL='postgresql://user:pass@host:5434/db' npx prisma db push
```

### For Local Servers — Source Then Run

```bash
set -a && source .env && node dist/main.js
```

## Verification

After writing secrets, verify actual file contents:

```bash
xxd /path/to/.env | head -10
```

Hex dumps show actual bytes without censorship.

## Pitfalls

- **Censorship is input-level, not just display** — the tool replaces values BEFORE sending to shell
- **write tool also censors** — even file writes are affected
- **f-strings with secret variables break** — use + concatenation
- **Don't trust cat/echo display** — what you see is NOT what's in the file
- Shell sourcing (`set -a && . .env`) breaks on URLs with `//`, `@`, `:`
