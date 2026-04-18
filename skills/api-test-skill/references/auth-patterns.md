# Auth Patterns Reference

## Provider → Auth Scheme Table

| Provider | Hostname Pattern | Auth Scheme | Header | Suggested Env Var |
|---|---|---|---|---|
| GitHub | `api.github.com` | Bearer (PAT/OAuth) | `Authorization: Bearer $GITHUB_TOKEN` | `GITHUB_TOKEN` |
| Stripe | `api.stripe.com` | Bearer (secret key) | `Authorization: Bearer $STRIPE_SECRET_KEY` | `STRIPE_SECRET_KEY` |
| Google APIs | `*.googleapis.com` | Bearer (OAuth2) | `Authorization: Bearer $GOOGLE_ACCESS_TOKEN` | `GOOGLE_ACCESS_TOKEN` |
| Slack | `slack.com/api/*` | Bearer (Bot token) | `Authorization: Bearer $SLACK_BOT_TOKEN` | `SLACK_BOT_TOKEN` |
| Twilio | `api.twilio.com` | Basic (Account SID + Auth Token) | `Authorization: Basic $TWILIO_CREDENTIALS` | `TWILIO_CREDENTIALS` (base64 of `SID:TOKEN`) |
| SendGrid | `api.sendgrid.com` | Bearer | `Authorization: Bearer $SENDGRID_API_KEY` | `SENDGRID_API_KEY` |
| AWS (API Gateway) | `*.execute-api.*.amazonaws.com` | AWS Signature v4 (complex) | `x-api-key: $AWS_API_KEY` or SigV4 | `AWS_API_KEY` |
| Firebase | `firestore.googleapis.com` / `*.firebaseio.com` | Bearer (ID token) | `Authorization: Bearer $FIREBASE_TOKEN` | `FIREBASE_TOKEN` |
| OpenAI | `api.openai.com` | Bearer | `Authorization: Bearer $OPENAI_API_KEY` | `OPENAI_API_KEY` |
| Anthropic | `api.anthropic.com` | API Key header | `x-api-key: $ANTHROPIC_API_KEY` | `ANTHROPIC_API_KEY` |

---

## Confidence Scoring Rules

### HIGH Confidence
Conditions (any one sufficient):
- URL hostname exactly matches or ends with a known provider hostname pattern in the table above
- URL hostname contains a well-known provider subdomain (e.g., `myapp.auth0.com`, `myproject.supabase.co`)

Action: Surface suggestion with confidence label `(confidence: HIGH)`.

### MEDIUM Confidence
Conditions (any one sufficient):
- URL path contains `/oauth/`, `/auth/`, `/token/`, `/authorize/`
- URL path contains `/api/v*/` with no hostname match
- Response includes `WWW-Authenticate` header (inferred from prior call)

Action: Surface suggestion with confidence label `(confidence: MEDIUM)`.

### LOW Confidence
Conditions:
- No hostname match
- No path signal
- No response header hint

Action: Do NOT surface an unsolicited suggestion. Only suggest if user explicitly asks about auth.

---

## Confirmation Requirement

**MANDATORY**: Auth inference is NEVER applied automatically, regardless of confidence level.

Always present as a suggestion and wait for explicit confirmation before adding the auth header:

```
I detected this endpoint may use Bearer auth (confidence: HIGH — hostname matches api.openai.com).

Add `Authorization: Bearer $OPENAI_API_KEY` to the request headers?
If yes, what env var holds the token? (default: $OPENAI_API_KEY)
```

If user confirms → add header using the specified env var.
If user rejects → cache the rejection for this hostname; stop suggesting for the session.
