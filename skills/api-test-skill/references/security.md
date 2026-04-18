# Security Reference

## Redaction Regex Patterns

Apply ALL patterns to command string (pre-display) and response body (post-receive). Process in order.

### Pattern 1: Bearer Token

| Field | Value |
|---|---|
| Regex | `Bearer\s+[A-Za-z0-9\-._~+/]+=*` |
| Replacement | `Bearer [REDACTED]` |
| Example input | `Authorization: Bearer eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJ1c2VyIn0.abc123` |
| Example output | `Authorization: Bearer [REDACTED]` |

### Pattern 2: JWT

| Field | Value |
|---|---|
| Regex | `eyJ[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+` |
| Replacement | `[REDACTED-JWT]` |
| Example input | `token: eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0In0.signature` |
| Example output | `token: [REDACTED-JWT]` |

### Pattern 3: API Key Query Param or Header Value

| Field | Value |
|---|---|
| Regex | `(?i)(api[_-]?key\|apikey)[=:]\s*\S+` |
| Replacement | `api_key=[REDACTED]` |
| Example input | `?api_key=sk-abc123def456` |
| Example output | `?api_key=[REDACTED]` |

### Pattern 4: Basic Auth

| Field | Value |
|---|---|
| Regex | `Basic\s+[A-Za-z0-9+/=]+` |
| Replacement | `Basic [REDACTED]` |
| Example input | `Authorization: Basic dXNlcjpwYXNzd29yZA==` |
| Example output | `Authorization: Basic [REDACTED]` |

### Pattern 5: PEM Private Key

| Field | Value |
|---|---|
| Regex | `-----BEGIN\s+(\w+\s+)?PRIVATE KEY-----` |
| Replacement | `[REDACTED-PRIVATE-KEY]` |
| Example input | `-----BEGIN RSA PRIVATE KEY-----` |
| Example output | `[REDACTED-PRIVATE-KEY]` |

### Pattern 6: Generic Secret / Password / Token

| Field | Value |
|---|---|
| Regex | `(?i)(secret\|password\|passwd\|token)[=:]\s*\S+` |
| Replacement | `{matched_name}=[REDACTED]` (preserve the field name) |
| Example input | `password=Sup3rS3cr3t!` |
| Example output | `password=[REDACTED]` |

---

## Response Body Field Scan List

After receiving a response, scan top-level JSON field names. If any field name matches the list below, redact its value before displaying:

```
token
access_token
refresh_token
id_token
api_key
apiKey
secret
password
passwd
private_key
privateKey
client_secret
clientSecret
```

**Display format**: `"access_token": "[REDACTED]"` (preserve field name, redact value only)

**Nested fields**: only scan top-level by default. If a top-level `data` or `auth` object exists, also scan one level deep.

---

## Env Var Syntax Per Shell

| Shell | Syntax | Set Command | Example |
|---|---|---|---|
| bash | `$VAR` | `export VAR=value` | `$API_TOKEN` |
| zsh | `$VAR` | `export VAR=value` | `$API_TOKEN` |
| fish | `$VAR` | `set -x VAR value` | `$API_TOKEN` |
| PowerShell | `$env:VAR` | `$env:VAR = "value"` | `$env:API_TOKEN` |
| cmd.exe | `%VAR%` | `set VAR=value` | `%API_TOKEN%` |

### Refusal script (when user provides raw secret)

When a user pastes a literal token value in the conversation, respond with:

```
Please set this as an env var first:

  export API_TOKEN=<paste_value_here>   # bash/zsh
  $env:API_TOKEN = "<paste_value_here>" # PowerShell
  set API_TOKEN=<paste_value_here>      # cmd.exe

Then I'll reference $API_TOKEN in the command — never the raw value.
```

Do NOT include the token value in any generated command.
