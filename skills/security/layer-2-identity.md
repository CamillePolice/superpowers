# SBD Layer 2 — Identity & Access Control

## SBD-04 · Authentication Integrity
**Standards:** OWASP A07 · NIST PR.AA-1 · CIS Control 5

- Passwords: **Argon2id** (preferred) or bcrypt cost≥12. Never MD5, SHA1, plain SHA256.
- MFA required for all privileged accounts.
- Rate-limit: max 5 attempts/min per IP + per account, exponential backoff.
- Rotate session tokens after login, privilege escalation, password change.
- JWT: always set `exp`, always verify `alg` explicitly — **reject `alg: none`**.

**Instant flags:** `md5(password)` · `sha1(password)` · JWT missing `exp` · no rate limiting on `/login`

```php
# Symfony — use "auto" (picks argon2id or bcrypt based on PHP version):
security:
    password_hashers:
        App\Entity\User:
            algorithm: auto

# Rate limiting with symfony/rate-limiter:
#[RateLimiter(policy: 'login', limit: 5, interval: '1 minute')]
public function login(Request $request): JsonResponse { ... }
```

**Auth0 / Entra (project-flow / ClaraCharge):**
- Always verify `iss`, `aud`, `exp` server-side — never trust client-decoded JWT
- Validate `hd` (hosted domain) claim if restricting to @claranet.fr
- Rotate client secrets on rotation schedule, never hardcode in Nuxt env

---

## SBD-05 · Authorization & Access Control
**Standards:** OWASP A01 · NIST PR.AA-3 · CIS Control 6

Default DENY. Enforce server-side on every request. Never rely on client-side hiding.

```python
# VULNERABLE — no ownership check:
return db.query(Document).filter(Document.id == doc_id).first()

# CORRECT:
doc = db.query(Document).filter(
    Document.id == doc_id,
    Document.owner_id == current_user.id
).first()
if not doc:
    raise HTTPException(status_code=404)  # 404 not 403 — do not leak existence
```

```php
// Symfony Voter — enforce per API call:
protected function voteOnAttribute(string $attribute, mixed $subject, TokenInterface $token): bool {
    $user = $token->getUser();
    return $subject->getOwner() === $user;
}
```

```typescript
// Angular/Nuxt route guards = UX only, never security.
// Guards run in the browser and can be bypassed by calling the API directly.
// ALL authorization logic must live in the backend.
```

---

## SBD-06 · Least Privilege
**Standards:** OWASP A01 · OWASP LLM06 · NIST PR.AA-3

Every service, API key, DB user, LLM agent, and cloud role operates with minimum required permissions.

```json
{ "Action": ["s3:GetObject","s3:PutObject"], "Resource": "arn:aws:s3:::bucket/*" }
// Never: "Action": "*"
```

**Homelab / self-hosted note:** Docker containers should not run as root. DB users should not have DDL grants in production. NAS admin panels must not be reachable from app containers.

Check: Can any single compromised credential cause total system compromise? If yes, re-architect.
For exceptions → see STEP 5 in SKILL.md.
