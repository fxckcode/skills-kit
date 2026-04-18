# Error Catalog Reference

## 1. Client Errors (4xx)

| Status | Name | Likely Cause | Suggested Fix |
|---|---|---|---|
| 400 | Bad Request | Malformed request body, missing required field, invalid field type | Validate JSON syntax; check API docs for required fields; ensure correct data types |
| 401 | Unauthorized | Missing or expired auth token; wrong credentials | Verify env var is set; check token expiry; re-authenticate if needed |
| 402 | Payment Required | Account billing issue; quota exceeded | Check billing status or subscription plan |
| 403 | Forbidden | Authenticated but lacking permission; wrong OAuth scope; IP not allowlisted | Check user roles/permissions; verify OAuth scopes; check IP allowlist config |
| 404 | Not Found | Wrong URL path, resource deleted, or typo in path param | Double-check URL, path parameters, and base URL; confirm resource exists |
| 405 | Method Not Allowed | Using wrong HTTP method (e.g., GET on POST-only endpoint) | Check API docs for the correct method for this endpoint |
| 406 | Not Acceptable | Client `Accept` header incompatible with server's response types | Set or remove the `Accept` header; try `Accept: application/json` |
| 408 | Request Timeout | Server timed out waiting for the request body | Retry; check network stability; reduce payload size |
| 409 | Conflict | Resource already exists; concurrent modification conflict | Check for duplicate before creating; use PUT/PATCH instead of POST if updating |
| 410 | Gone | Resource permanently deleted | Stop sending requests to this endpoint; update client to remove the call |
| 413 | Payload Too Large | Request body exceeds server size limit | Reduce payload; use multipart for large files; check server limits |
| 415 | Unsupported Media Type | `Content-Type` doesn't match what server accepts | Set correct `Content-Type` (e.g., `application/json`); check API docs |
| 422 | Unprocessable Entity | Request is syntactically valid but semantically incorrect; field validation failed | Parse response body for field-level error details; fix each listed field |
| 423 | Locked | Resource is locked (WebDAV) | Unlock resource or contact owner |
| 429 | Too Many Requests | Rate limit exceeded | Read `Retry-After` header; implement exponential backoff; reduce request frequency |
| 451 | Unavailable For Legal Reasons | Access blocked for legal/compliance reasons | Contact API provider |

---

## 2. Server Errors (5xx)

| Status | Name | Likely Cause | Suggested Fix |
|---|---|---|---|
| 500 | Internal Server Error | Unhandled exception or bug on the server | Retry once; check server logs if accessible; report to API team if persistent |
| 501 | Not Implemented | Server doesn't support the requested method or feature | Use a supported method; check API version compatibility |
| 502 | Bad Gateway | Upstream server returned invalid response; proxy issue | Retry with exponential backoff; may resolve automatically |
| 503 | Service Unavailable | Server temporarily down for maintenance or overloaded | Wait and retry; check API status page |
| 504 | Gateway Timeout | Upstream server didn't respond in time | Retry with longer timeout; check network path |
| 507 | Insufficient Storage | Server storage is full | Contact API team; reduce payload or free up resources |
| 511 | Network Authentication Required | Network-level auth required (captive portal, proxy) | Authenticate with the network; configure proxy settings |

---

## 3. Network Errors

| Error | Diagnosis Steps |
|---|---|
| `ECONNREFUSED` | 1. Verify the service is running: `curl http://localhost:{port}/health` 2. Check the correct port in your config 3. Verify host address (localhost vs 127.0.0.1 vs container name) 4. Check firewall rules |
| `ETIMEDOUT` | 1. Verify network connectivity 2. Ping the host: `ping {hostname}` 3. Increase client timeout with `--max-time 60` 4. Check if host is behind a VPN or firewall 5. Try traceroute |
| `EHOSTUNREACH` | 1. Check routing table 2. Verify host is reachable from this network 3. Check VPN connection 4. Verify correct IP/hostname |
| `ENOTFOUND` / `DNS_PROBE_FINISHED_NXDOMAIN` | 1. Check DNS resolution: `nslookup {hostname}` 2. Verify hostname is correct (no typos) 3. Check `/etc/hosts` for local overrides 4. Flush DNS cache: `sudo dscacheutil -flushcache` (mac) or `ipconfig /flushdns` (win) |

---

## 4. SSL/TLS Errors

### Certificate Expired

**Symptom**: `SSL certificate problem: certificate has expired` or `CERTIFICATE_VERIFY_FAILED`

**Diagnosis**: `curl -v https://api.example.com 2>&1 | grep "expire"`

**Fix**:
- Contact the API provider — their cert needs renewal
- For local dev server: renew via Let's Encrypt or mkcert
- NEVER use `--insecure` for production endpoints

### Self-Signed Certificate

**Symptom**: `SSL certificate problem: self signed certificate`

**Fix (localhost ONLY)**:
- curl: add `--insecure` flag
- httpie: add `--verify=no`
- Invoke-RestMethod: add `-SkipCertificateCheck`

> ⚠️ Using `--insecure` disables certificate validation entirely. ONLY acceptable for local development. NEVER use for any external or production URL.

### Hostname Mismatch

**Symptom**: `SSL: no alternative certificate subject name matches target host name`

**Diagnosis**: The certificate is valid but issued for a different hostname.

**Fix**:
- Verify you're using the correct URL (not an alias or IP address)
- Check if the cert is a wildcard (`*.example.com`) that should cover your subdomain
- Contact API provider if the cert doesn't match their documented hostname
