# OS Detection Reference

## Full Flag Compatibility Table

| Flag Purpose | curl (unix/mac) | curl.exe (CMD) | curl.exe (PS) | httpie | Invoke-RestMethod |
|---|---|---|---|---|---|
| Set method | `-X GET` | `-X GET` | `-X GET` | `GET` | `-Method GET` |
| Add header | `-H "K: V"` | `-H "K: V"` | `-H "K: V"` | `K:V` | `-Headers @{"K"="V"}` |
| Set body (JSON) | `-d '{"k":"v"}'` | `-d "{\"k\":\"v\"}"` | `-d '{"k":"v"}'` | `k:=value` or `--raw '{"k":"v"}'` | `-Body '{"k":"v"}'` |
| Follow redirects | `-L` | `-L` | `-L` | `--follow` | (automatic) |
| Skip TLS verify | `--insecure` | `--insecure` | `--insecure` | `--verify=no` | `-SkipCertificateCheck` |
| Verbose output | `-v` | `-v` | `-v` | `--verbose` | `-Verbose` |
| Write status code | `-w "%{http_code}"` | `-w "%{http_code}"` | `-w "%{http_code}"` | (shown by default) | `.StatusCode` property |
| Silent mode | `-s` | `-s` | `-s` | `--quiet` | n/a |
| Include response headers | `-i` | `-i` | `-i` | (shown by default) | `-ResponseHeadersVariable` |
| Output to file | `-o file.json` | `-o file.json` | `-o file.json` | `> file.json` | `-OutFile file.json` |
| Set timeout | `--max-time 30` | `--max-time 30` | `--max-time 30` | `--timeout=30` | `-TimeoutSec 30` |
| Auth header | `-H "Authorization: Bearer $VAR"` | `-H "Authorization: Bearer %VAR%"` | `-H "Authorization: Bearer $env:VAR"` | `Authorization:"Bearer $VAR"` | `-Headers @{"Authorization"="Bearer $env:VAR"}` |

---

## Quoting Rules Per Shell

### bash / zsh
- Single quotes `'...'`: no variable expansion, no escape processing — use for JSON bodies
- Double quotes `"..."`: variable expansion (`$VAR`), escape with `\`
- Heredoc: `<<<'{"key":"value"}'` for complex JSON
- Escape double quote inside double quotes: `\"`

**Example:**
```bash
curl -X POST https://api.example.com/users \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Alice","email":"alice@example.com"}'
```

### fish
- Single quotes: literal, no expansion
- Double quotes: `$VAR` expands
- No heredoc; use `echo '...' | curl`

**Example:**
```fish
curl -X POST https://api.example.com/users \
  -H "Authorization: Bearer $API_TOKEN" \
  -d '{"name":"Alice"}'
```

### PowerShell
- Single quotes `'...'`: literal, no expansion — use for JSON body
- Double quotes `"..."`: variable expansion (`$env:VAR`), escape with backtick `` ` `` or double `"`
- Escape double quote inside double-quoted string: `` `" `` or `""` (context-dependent)

**Example:**
```powershell
Invoke-RestMethod -Method POST `
  -Uri "https://api.example.com/users" `
  -Headers @{"Authorization" = "Bearer $env:API_TOKEN"; "Content-Type" = "application/json"} `
  -Body '{"name":"Alice","email":"alice@example.com"}'
```

### cmd.exe
- Double quotes only — no single-quote literals
- Escape double quote inside string: `\"`
- Variable expansion: `%VAR%`
- Body with nested quotes must use `\"` for each inner double quote

**Example:**
```cmd
curl -X POST https://api.example.com/users ^
  -H "Authorization: Bearer %API_TOKEN%" ^
  -H "Content-Type: application/json" ^
  -d "{\"name\":\"Alice\",\"email\":\"alice@example.com\"}"
```

---

## curl.exe vs curl Difference Matrix

| Property | curl (unix) | curl.exe (Windows) |
|---|---|---|
| Detection | `which curl` | `where curl.exe` (use `.exe` explicitly in PS to avoid alias) |
| Shell alias conflict | None | PowerShell has `curl` alias for `Invoke-WebRequest` — always use `curl.exe` |
| Body quoting | Single quotes: `-d '{"k":"v"}'` | PS: single quotes OK; CMD: must use `\"` escaping |
| Env var expansion | `$VAR` | PS: `$env:VAR`; CMD: `%VAR%` |
| Exit codes | Standard curl codes | Same codes — but PS may suppress non-zero on HTTP errors |
| Line continuation | `\` | PS: `` ` ``; CMD: `^` |
| Response body | Printed to stdout | Printed to stdout; use `-o` or pipe |

---

## Line-Continuation Characters

| Shell | Character | Notes |
|---|---|---|
| bash | `\` | Must be last char on line, no trailing space |
| zsh | `\` | Same as bash |
| fish | `\` | Same as bash |
| PowerShell | `` ` `` | Backtick — must be last char, no trailing space |
| cmd.exe | `^` | Caret — must be last char |
| unknown / one-liner mode | (none) | Emit entire command on a single line |

---

## Install Commands

### curl

| Platform | Command |
|---|---|
| macOS | `brew install curl` |
| Ubuntu/Debian | `sudo apt install curl` |
| RHEL/CentOS | `sudo yum install curl` |
| Windows (native) | Ships with Windows 10+ at `C:\Windows\System32\curl.exe` |
| Windows (winget) | `winget install cURL.cURL` |
| Windows (scoop) | `scoop install curl` |
| Windows (choco) | `choco install curl` |

### httpie

| Platform | Command |
|---|---|
| Any (pip) | `pip install httpie` |
| macOS | `brew install httpie` |
| Ubuntu/Debian | `sudo apt install httpie` |
| Windows (scoop) | `scoop install httpie` |

### Invoke-RestMethod

Built into PowerShell 3.0+ (Windows 8+). No installation required. Available in PowerShell Core (cross-platform).
