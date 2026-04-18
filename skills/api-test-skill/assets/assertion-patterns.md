# Assertion Patterns Reference

## Assertion Types

### 1. Status Code

Validates the HTTP response status code.

**Syntax**:
```
assert status == {code}
assert status != {code}
assert status >= {code}
```

**Examples**:
```
assert status == 200
assert status == 201
assert status != 404
assert status >= 200
```

---

### 2. Header

Validates a response header value. Supports exact match (`==`) and regex/contains match (`~=`).

**Syntax**:
```
assert header {Header-Name} == "{value}"
assert header {Header-Name} ~= "{pattern}"
```

**Examples**:
```
assert header Content-Type == "application/json"
assert header Content-Type ~= "json"
assert header Location == "https://api.example.com/users/123"
assert header X-RateLimit-Remaining != "0"
```

---

### 3. Body (JSON dot-path)

Validates fields in the JSON response body using dot-path notation.

**Syntax**:
```
assert body.{path} == {value}
assert body.{path} != null
assert body.{path} ~= "{pattern}"
assert body.{path} >= {number}
```

**Examples**:
```
assert body.status == "active"
assert body.data.id != null
assert body.message == "created"
assert body.user.email == "alice@example.com"
assert body.count >= 1
assert body.name ~= "^Alice"
```

---

### 4. Latency

Validates the request round-trip time.

**Syntax**:
```
assert latency < {N}ms
assert latency <= {N}ms
```

**Examples**:
```
assert latency < 500ms
assert latency < 2000ms
assert latency <= 1000ms
```

---

## Dot-Path Notation Guide

### Nested Objects

Access nested fields by chaining keys with `.`:

```
body.data.id              → response.data.id
body.user.profile.email   → response.user.profile.email
body.meta.created_at      → response.meta.created_at
```

### Arrays

Access array elements by index using `[N]`:

```
body.items[0].id          → first item's id
body.results[0].name      → first result's name
body.data[2].status       → third item's status
```

### Mixed

Combine object and array access:

```
body.data.users[0].email
body.results[0].meta.tags[1]
```

---

## Regex Operator (`~=`)

The `~=` operator tests whether the actual value matches the given regex pattern.

**Example 1 — email format**:
```
assert body.email ~= "^[^@]+@[^@]+\.[^@]+$"
```
Output: `[PASS] body.email ~= "^[^@]+@[^@]+\.[^@]+$" (actual: "alice@example.com")`

**Example 2 — string prefix**:
```
assert body.name ~= "^Alice"
```
Output: `[PASS] body.name ~= "^Alice" (actual: "Alice Smith")`

---

## PASS / FAIL Output Templates

### PASS

```
[PASS] status == 201 (actual: 201)
[PASS] header Content-Type ~= "json" (actual: "application/json; charset=utf-8")
[PASS] body.data.id != null (actual: "usr_abc123")
[PASS] latency < 500ms (actual: 142ms)
```

### FAIL

```
[FAIL] status == 201 (actual: 200)
[FAIL] body.data.id != null (actual: null)
[FAIL] body.message == "created" (actual: "updated")
[FAIL] latency < 500ms (actual: 1243ms)
```

---

## Summary Line Template

After all assertions are evaluated, always show a summary:

```
3/4 assertions passed

Failures:
  [FAIL] body.data.id != null (actual: null)
```

Or, when all pass:

```
4/4 assertions passed
```

---

## All-Assertions-Evaluated Rule

**CRITICAL**: All assertions MUST be evaluated before reporting results — even if assertion #1 fails.

- Never short-circuit on first failure
- Collect all failures, then report them together after the summary line
- This ensures the user sees all issues in a single response, not one at a time
