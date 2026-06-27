# SBD Layer 4 — Resilience & Monitoring

## SBD-10 · Security Logging
**Standards:** OWASP A09 · NIST DE.AE-2 · CIS Control 8

Log WHAT happened. Never log the content of sensitive data. Pseudonymize user IDs after 30 days.

```json
{
  "timestamp": "ISO8601",
  "event_type": "auth.login_failed",
  "user_id": "uuid",
  "ip_address": "x.x.x.x",
  "resource": "/api/login",
  "outcome": "failure",
  "reason": "invalid_password"
}
```

For LLM apps: log all prompt inputs and outputs that trigger downstream actions.
**Conflict with SBD-09:** See SKILL.md STEP 4.

---

## SBD-11 · Rate Limiting & Abuse Prevention
**Standards:** OWASP A07 · OWASP LLM10 · NIST PR.DS-6

```python
# LLM — always set hard caps:
response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1000,  # never omit
    timeout=30
)
```

Auth endpoints: max 5/min per IP + per account.

```typescript
// Nuxt server route with rate limiting:
// Use nuxt-rate-limit or implement in middleware:
export default defineEventHandler(async (event) => {
  const ip = getRequestIP(event)
  // check rate limit before processing
})
```

---

## SBD-12 · SSRF Prevention
**Standards:** OWASP A10 · NIST PR.DS-1

```python
import ipaddress

BLOCKED_RANGES = [
    ipaddress.ip_network("10.0.0.0/8"),
    ipaddress.ip_network("172.16.0.0/12"),
    ipaddress.ip_network("192.168.0.0/16"),
    ipaddress.ip_network("127.0.0.0/8"),
    ipaddress.ip_network("169.254.0.0/16"),  # cloud metadata endpoint
]

def is_safe_url(url: str) -> bool:
    host = urllib.parse.urlparse(url).hostname
    addr = ipaddress.ip_address(socket.gethostbyname(host))
    return not any(addr in r for r in BLOCKED_RANGES)
```

**⚠ Homelab / self-hosted note:** If your app fetches URLs from user input (webhooks, imports, previews), SSRF can expose internal services sharing the same private network: NAS admin panel, Portainer, WireGuard endpoints, Jellyfin, Immich. Validate and blocklist before any outbound fetch.

---

## SBD-13 · Error Handling
**Standards:** OWASP A05 · NIST PR.DS-2

```python
try:
    process_request(data)
except Exception as e:
    logger.error(e, exc_info=True)           # detailed → server log
    return {"error": "Something went wrong"} # generic → user
```

Never expose: stack traces · SQL queries · file paths · server versions · internal IPs

```yaml
# Symfony — confirm APP_ENV=prod in production:
# .env.local (never committed):
APP_ENV=prod
APP_DEBUG=false  # DEBUG=true in prod is a critical finding
```
