# SBD Layer 1 — Input & Output Integrity

## SBD-01 · Input Validation & Sanitization
**Standards:** OWASP A03 · NIST PR.DS-1 · CIS Control 4

Validate type, format, length, encoding, and range **server-side**. Allowlist, never blocklist.

```python
# NEVER
query = "SELECT * FROM users WHERE id = " + user_id
# CORRECT
cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))

class UserInput(BaseModel):
    name: str = Field(max_length=100, pattern=r'^[a-zA-Z\s]+$')
    age: int = Field(ge=0, le=150)
```

```php
// Symfony — Doctrine query builder:
$em->createQueryBuilder()
   ->select('u')->from(User::class, 'u')
   ->where('u.id = :id')->setParameter('id', $id)
   ->getQuery()->getResult();

// Symfony validator on DTOs:
#[Assert\Length(max: 100)]
#[Assert\Regex(pattern: '/^[a-zA-Z\s]+$/')]
public string $name;
```

**File uploads:** validate MIME server-side, random server-generated filename, store outside web root.

---

## SBD-02 · Prompt Injection Defense
**Standards:** OWASP LLM01 · NIST PR.DS-1

User-controlled content passed to an LLM must be treated as adversarial input.

```python
# DANGEROUS — user content in system prompt:
system_prompt = f"You are an assistant. Context: {user_document}"

# CORRECT — structurally separated:
messages = [
    {"role": "system",  "content": FIXED_SYSTEM_PROMPT},
    {"role": "user",    "content": sanitize_for_llm(user_document)}
]
```

Log all prompt inputs and LLM outputs for auditability.

---

## SBD-03 · Output Encoding & CSP
**Standards:** OWASP A03+A05 · OWASP LLM05 · NIST PR.DS-2

Minimum secure HTTP headers:
```
Content-Security-Policy: default-src 'self'; script-src 'self'; object-src 'none'
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Referrer-Policy: strict-origin-when-cross-origin
Strict-Transport-Security: max-age=31536000; includeSubDomains
Permissions-Policy: camera=(), microphone=(), geolocation=()
```

**⚠ Security theater check:** Headers must be enforced at nginx/CDN level, not app code only.

```nginx
# nginx — use "always" to include on error responses:
add_header Content-Security-Policy "default-src 'self'; script-src 'self'; object-src 'none'" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "DENY" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
```
