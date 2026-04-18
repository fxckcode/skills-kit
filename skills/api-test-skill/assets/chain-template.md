# Request Chain Template

## Chain Declaration Format

A chain is a sequence of requests where each step can reference variables captured from a prior step's response.

```
chain: {chain-name}
step N: {METHOD} {URL}
  [headers]
  [body]
  capture body.{dot-path} as $CHAIN_{FIELD}
  [assert ...]
```

- Chain name is optional but helps readability
- Steps are numbered sequentially (step 1, step 2, ...)
- `capture` extracts a value from the response for use in subsequent steps
- `assert` validates the response before proceeding

---

## Variable Capture Syntax

```
capture body.{dot-path} as $CHAIN_{FIELD}
```

**Examples**:

```
capture body.id as $CHAIN_ID
capture body.data.user.id as $CHAIN_USER_ID
capture body.items[0].token as $CHAIN_TOKEN
capture body.next_cursor as $CHAIN_CURSOR
```

**Dot-path notation**:
- Nested object: `body.data.id`
- Array index: `body.items[0].id`
- Deeply nested: `body.results[0].meta.created_at`

---

## 3-Step CRUD Example

### Step 1: Create User (POST)

```bash
# POST /users — create a new user
curl -X POST "https://api.example.com/users" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Alice","email":"alice@example.com"}'

# capture body.id as $CHAIN_ID
# assert status == 201
```

**Chain state after step 1**: `$CHAIN_ID = "usr_abc123"` (example value)

---

### Step 2: Read User (GET)

```bash
# GET /users/$CHAIN_ID — verify the created resource
curl -X GET "https://api.example.com/users/$CHAIN_ID" \
  -H "Authorization: Bearer $API_TOKEN"

# assert status == 200
# assert body.email == "alice@example.com"
```

**Chain state after step 2**: `$CHAIN_ID` unchanged

---

### Step 3: Delete User (DELETE)

```bash
# DELETE /users/$CHAIN_ID — clean up
curl -X DELETE "https://api.example.com/users/$CHAIN_ID" \
  -H "Authorization: Bearer $API_TOKEN"

# assert status == 204
```

**Chain complete.** All steps passed.

---

## Null Guard Example

If step 1 returns a body where `body.id` is null or missing:

```
Chain halted at step 1: `body.id` resolved to null.
Fix step 1 response before continuing.

Response received:
{
  "error": "validation_failed",
  "message": "email already in use"
}
```

No subsequent steps execute. The chain must be restarted from step 1.

---

## Secret Variable Display Example

If a captured variable name contains `TOKEN`, `KEY`, `SECRET`, or `PASSWORD`, its value is always masked in chain summaries:

```
Chain Summary:
  Step 1 [PASS] POST /auth/login → 200 OK
    captured: $CHAIN_ACCESS_TOKEN = [REDACTED]
  Step 2 [PASS] GET /profile → 200 OK
    captured: $CHAIN_USER_ID = "usr_abc123"
  Step 3 [PASS] PUT /profile → 200 OK
```

The `$CHAIN_ACCESS_TOKEN` value is never shown in output, even in verbose mode.
