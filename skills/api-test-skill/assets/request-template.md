# Request Templates

Placeholder vars: `{{URL}}`, `{{METHOD}}`, `{{HEADER_NAME}}`, `{{HEADER_VALUE}}`, `{{BODY}}`, `{{TOKEN_VAR}}`

---

## 1. curl (Unix / macOS)

**Use when**: running on Linux or macOS with curl installed (detected via `which curl`)

### GET

```bash
curl -X GET "{{URL}}" \
  -H "Authorization: Bearer ${{TOKEN_VAR}}" \
  -H "{{HEADER_NAME}}: {{HEADER_VALUE}}"
```

### POST (JSON body)

```bash
curl -X POST "{{URL}}" \
  -H "Authorization: Bearer ${{TOKEN_VAR}}" \
  -H "Content-Type: application/json" \
  -H "{{HEADER_NAME}}: {{HEADER_VALUE}}" \
  -d '{{BODY}}'
```

---

## 2. curl.exe (Windows CMD)

**Use when**: running in cmd.exe on Windows (detected via `where curl.exe` and `%COMSPEC%`)

### GET

```cmd
curl.exe -X GET "{{URL}}" ^
  -H "Authorization: Bearer %{{TOKEN_VAR}}%" ^
  -H "{{HEADER_NAME}}: {{HEADER_VALUE}}"
```

### POST (JSON body)

```cmd
curl.exe -X POST "{{URL}}" ^
  -H "Authorization: Bearer %{{TOKEN_VAR}}%" ^
  -H "Content-Type: application/json" ^
  -H "{{HEADER_NAME}}: {{HEADER_VALUE}}" ^
  -d "{\"key\":\"value\"}"
```

> Note: cmd.exe requires double quotes and inner quotes must be escaped with `\"`.

---

## 3. curl.exe (PowerShell)

**Use when**: running in PowerShell on Windows — use `.exe` explicitly to avoid the `Invoke-WebRequest` alias

### GET

```powershell
curl.exe -X GET "{{URL}}" `
  -H "Authorization: Bearer $env:{{TOKEN_VAR}}" `
  -H "{{HEADER_NAME}}: {{HEADER_VALUE}}"
```

### POST (JSON body)

```powershell
curl.exe -X POST "{{URL}}" `
  -H "Authorization: Bearer $env:{{TOKEN_VAR}}" `
  -H "Content-Type: application/json" `
  -H "{{HEADER_NAME}}: {{HEADER_VALUE}}" `
  -d '{{BODY}}'
```

> Note: PowerShell supports single quotes for the body (no escaping needed).

---

## 4. httpie

**Use when**: httpie is installed (detected via `which http`)

### GET

```bash
http GET "{{URL}}" \
  "Authorization:Bearer ${{TOKEN_VAR}}" \
  "{{HEADER_NAME}}:{{HEADER_VALUE}}"
```

### POST (JSON body)

```bash
http POST "{{URL}}" \
  "Authorization:Bearer ${{TOKEN_VAR}}" \
  "{{HEADER_NAME}}:{{HEADER_VALUE}}" \
  Content-Type:application/json \
  <<< '{{BODY}}'
```

> Note: httpie uses `key:=value` for JSON fields inline, or `<<<` heredoc / `--raw` for raw body strings.

---

## 5. Invoke-RestMethod (PowerShell)

**Use when**: running on Windows without curl.exe available — Invoke-RestMethod is always present in PowerShell 3.0+

### GET

```powershell
$params = @{
    Method  = "GET"
    Uri     = "{{URL}}"
    Headers = @{
        "Authorization" = "Bearer $env:{{TOKEN_VAR}}"
        "{{HEADER_NAME}}" = "{{HEADER_VALUE}}"
    }
}
Invoke-RestMethod @params
```

### POST (JSON body)

```powershell
$params = @{
    Method      = "POST"
    Uri         = "{{URL}}"
    Headers     = @{
        "Authorization" = "Bearer $env:{{TOKEN_VAR}}"
        "{{HEADER_NAME}}" = "{{HEADER_VALUE}}"
    }
    ContentType = "application/json"
    Body        = '{{BODY}}'
}
Invoke-RestMethod @params
```

> Note: Splatting (`@params`) keeps PowerShell commands readable. `-ContentType` sets the `Content-Type` header automatically.
