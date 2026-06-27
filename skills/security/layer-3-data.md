# SBD Layer 3 — Data Protection & Cryptography

## SBD-07 · Secrets Management
**Standards:** OWASP A02 · OWASP LLM02 · NIST PR.DS-1

No credentials in source code, committed files, or client bundles.

```bash
# Pre-commit hook
gitleaks protect --staged --config .gitleaks.toml
```

Key patterns to scan: `sk-[a-zA-Z0-9]{48}` · `AKIA[0-9A-Z]{16}` · `ghp_[a-zA-Z0-9]{36}`

**⚠ Angular / Nuxt warning — environment files are bundled into the client:**
```typescript
// NEVER in Angular environment.ts or Nuxt .env exposed to client:
export const environment = {
  apiKey: 'sk-real-key-here',       // visible in browser bundle
  internalApiUrl: 'http://10.0.0.5' // leaks internal topology
};

// CORRECT — backend proxy pattern:
export const environment = {
  apiUrl: 'https://yourapp.com/api'  // only your own backend
};
```

In Nuxt: use `runtimeConfig` with server-only keys (not prefixed with `public`).
```typescript
// nuxt.config.ts
runtimeConfig: {
  dbPassword: '',        // server-only — never exposed to client
  public: {
    apiBase: '/api'      // safe to expose
  }
}
```

---

## SBD-08 · Cryptographic Standards
**Standards:** OWASP A02 · NIST PR.DS-1

**Approved:** AES-256-GCM · RSA-4096 or ECC P-256 · SHA-256 / SHA-3 · Argon2id · TLS 1.3
**Never generate:** DES · 3DES · RC4 · MD5 · SHA-1 for security · `Math.random()` for tokens

```python
import secrets
token = secrets.token_hex(32)  # cryptographically secure

# HMAC signing (webhook pattern):
import hmac, hashlib
sig = hmac.new(secret.encode(), payload, hashlib.sha256).hexdigest()
```

---

## SBD-09 · Data Minimization
**Standards:** OWASP A02 · NIST PR.DS-5

Collect only what is necessary. Purge what is no longer needed.
**Conflict with SBD-10:** Log the security event metadata. Never log data content. See SKILL.md STEP 4.

---

## SBD-25 · Privacy & GDPR
**Standards:** ISO A.5.34 · GDPR EU 2016/679

**Legal Basis Matrix — document before collecting any personal data:**

| Data | Basis | Notes |
|---|---|---|
| Account credentials | Contract (Art. 6(1)(b)) | Required for service |
| Usage analytics | Legitimate interest (Art. 6(1)(f)) | Requires balancing test |
| Marketing emails | Consent (Art. 6(1)(a)) | Freely given, specific, informed |
| Security logs | Legitimate interest (Art. 6(1)(f)) | Proportionality required |
| Health data | Explicit consent (Art. 9(2)(a)) | Sensitive — stricter rules |

**Data Subject Rights endpoints (required before go-live):**
```
GET  /api/gdpr/export    → all data for user (Art. 15 + Art. 20)
DEL  /api/gdpr/erase     → purge all personal data (Art. 17)
POST /api/gdpr/object    → object to processing (Art. 21)
Response deadline: 30 days. Log all requests.
```

**Breach notification checklist (Art. 33–34):**
```
[ ] Log exact time of detection
[ ] Personal data involved? If no → GDPR notification may not apply
[ ] 72h clock starts at detection
[ ] Notify supervisory DPA within 72h if high risk
[ ] Document: nature, categories/volume, consequences, measures
[ ] Notify affected users if high risk to their rights (Art. 34)
[ ] Record in breach register (Art. 33(5)) — even if no DPA notification
```

⚠ "GDPR compliance" without a documented legal basis per data category is security theater.
