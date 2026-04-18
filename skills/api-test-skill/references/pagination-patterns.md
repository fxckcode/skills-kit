# Pagination Patterns Reference

## 1. Cursor-Based Pagination

**Fields to detect** (check response body for any of these):
- `next_cursor`, `after`, `before`, `cursor`, `endCursor`, `next_page_token`

**Capture pattern**:
```
capture body.next_cursor as $CHAIN_CURSOR
# or: capture body.after as $CHAIN_AFTER
```

**Exit condition**: field is `null`, `""`, or absent → pagination complete, halt chain.

**Next request**: add captured cursor as query param or body field:
```
GET /items?cursor=$CHAIN_CURSOR
GET /items?after=$CHAIN_AFTER
```

---

## 2. Offset-Based Pagination

**Fields to detect** (check response body):
- `offset`, `limit`, `total`, `count`

**Increment formula**:
```
next_offset = current_offset + limit
# e.g.: offset=0&limit=20 → offset=20&limit=20 → offset=40&limit=20
```

**Exit condition**: `next_offset >= total` OR response array length < `limit` → pagination complete.

**Next request**:
```
GET /items?offset=$CHAIN_OFFSET&limit=20
```

---

## 3. Page-Number Pagination

**Fields to detect** (check response body):
- `page`, `per_page`, `total_pages`, `last_page`, `current_page`

**Increment formula**:
```
next_page = current_page + 1
```

**Exit condition**: `next_page > total_pages` OR `next_page > last_page` → pagination complete.

**Next request**:
```
GET /items?page=$CHAIN_PAGE&per_page=25
```

---

## 4. Link Header (RFC 8288)

**Header format**:
```
Link: <https://api.example.com/items?page=3>; rel="next", <https://api.example.com/items?page=1>; rel="prev"
```

**Parse rule**: extract URL where `rel="next"`. If no `rel="next"` present → pagination complete.

**Capture**:
```
capture header.Link[rel=next] as $CHAIN_NEXT_URL
```

**Next request**: use `$CHAIN_NEXT_URL` as the full URL (replace entire URL, not just params).

**Example**:
```bash
curl "$CHAIN_NEXT_URL" \
  -H "Authorization: Bearer $API_TOKEN"
```

---

## 5. hasMore Boolean

**Fields to detect** (check response body):
- `hasMore`, `has_more`

**Behavior**: continue fetching while `hasMore == true` / `has_more == true`.

**Exit condition**: field is `false` → halt chain immediately.

**Typically paired with**: cursor field (`starting_after`, `next_cursor`) for the next page's starting point.

---

## Provider Examples

### GitHub (Link Header)

```
Link: <https://api.github.com/repos/owner/repo/issues?page=2>; rel="next"
```

- Detection: parse `Link` header for `rel="next"`
- Next: use the URL from `rel="next"` verbatim
- Exit: no `rel="next"` in response

```bash
# Page 1
curl "https://api.github.com/repos/owner/repo/issues?per_page=30" \
  -H "Authorization: Bearer $GITHUB_TOKEN"

# Page 2 (captured from Link header)
curl "$CHAIN_NEXT_URL" \
  -H "Authorization: Bearer $GITHUB_TOKEN"
```

---

### Stripe (has_more + starting_after)

```json
{
  "data": [...],
  "has_more": true,
  "url": "/v1/charges"
}
```

- Detection: `has_more == true`
- Cursor: last item's `id` field → pass as `starting_after`
- Exit: `has_more == false`

```bash
# Page 1
curl "https://api.stripe.com/v1/charges?limit=25" \
  -H "Authorization: Bearer $STRIPE_SECRET_KEY"

# Page 2
curl "https://api.stripe.com/v1/charges?limit=25&starting_after=$CHAIN_LAST_ID" \
  -H "Authorization: Bearer $STRIPE_SECRET_KEY"
```

---

### Notion (has_more + next_cursor)

```json
{
  "results": [...],
  "has_more": true,
  "next_cursor": "abc-123-xyz"
}
```

- Detection: `has_more == true`
- Cursor: `body.next_cursor`
- Exit: `has_more == false`

```bash
# Page 2 (POST request — Notion uses body params)
curl -X POST "https://api.notion.com/v1/databases/{id}/query" \
  -H "Authorization: Bearer $NOTION_TOKEN" \
  -H "Notion-Version: 2022-06-28" \
  -d "{\"start_cursor\":\"$CHAIN_CURSOR\"}"
```

---

### Twitter / X (meta.next_token)

```json
{
  "data": [...],
  "meta": {
    "next_token": "abc123",
    "result_count": 10
  }
}
```

- Detection: `body.meta.next_token` is non-null
- Capture: `capture body.meta.next_token as $CHAIN_NEXT_TOKEN`
- Exit: `body.meta.next_token` is absent or null

```bash
curl "https://api.twitter.com/2/tweets/search/recent?query=hello&pagination_token=$CHAIN_NEXT_TOKEN" \
  -H "Authorization: Bearer $TWITTER_BEARER_TOKEN"
```

---

### Elasticsearch (scroll_id)

```json
{
  "_scroll_id": "DXF1ZXJ5QW5kRmV0Y2gBAAAAAAAAEHYWM0FVRU...",
  "hits": { "hits": [...] }
}
```

- Detection: `body._scroll_id` is non-null and `body.hits.hits` is non-empty
- Capture: `capture body._scroll_id as $CHAIN_SCROLL_ID`
- Exit: `body.hits.hits` is empty array

```bash
# Scroll next batch
curl -X POST "https://localhost:9200/_search/scroll" \
  -H "Content-Type: application/json" \
  -d "{\"scroll\":\"1m\",\"scroll_id\":\"$CHAIN_SCROLL_ID\"}"
```
