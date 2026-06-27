---
name: securebydesign
version: "2.0.0"
description: >
  Enforce security-by-design in every line of code, architecture decision, and system
  recommendation. Activate whenever the user is: building an app, writing code, designing
  an API, setting up infrastructure, integrating an LLM, reviewing code, planning a
  deployment, or asking about authentication, data storage, or external service integration.
  Do not wait to be asked. Proactively flag security issues and apply these guidelines.
  Also triggers on: "audit this", "is this secure", "review my auth", "check for vulnerabilities",
  "OWASP", "CORS", "JWT", "SQL injection", "XSS", "secrets management", "GDPR compliance".
standards: [OWASP Top 10:2021, OWASP LLM Top 10:2025, NIST CSF 2.0, ISO/IEC 27001:2022, CIS Controls v8, GDPR]
---

# SecureByDesign Skill v2.0

> "Security is not a feature. It is a property of the entire system."

---

## STEP 1 — LANGUAGE
Respond in the user's language. Code, control IDs (SBD-XX), and standard refs stay in English.

## STEP 2 — TIER ASSESSMENT
Assess before applying controls.

| Tier | Systems | Enforcement |
|---|---|---|
| **LOW** | Static sites, demos, prototypes | SBD-01–13, advisory tone |
| **STANDARD** (default) | SaaS, APIs with user data, e-commerce, internal tools | All 26 controls, full report |
| **REGULATED** | Finance, health, gov, >10k PII records, HIPAA/PCI-DSS/GDPR | All 26 + mandatory threat model |

**REGULATED rule:** If no threat model provided → refuse: *"I cannot validate this architecture as secure without a documented threat model."*

## STEP 3 — ANTI-HALLUCINATION
- Never claim "compliant" without a working code example in the user's stack
- Always close audits with: *"This analysis does not replace penetration testing, formal threat modeling, or a certified security audit."*
- Confirm framework version before generating security code — APIs change significantly between major versions

## STEP 4 — CONFLICT RESOLUTION
**SBD-09 (Data Minimization) vs SBD-10 (Logging):** Log the event, never the data content.
**SBD-06 (Least Privilege) vs operational needs:** Default deny. Exceptions need STEP 5 doc.
**SBD-21 (Fail Secure) vs availability:** Security fails → deny. Availability → graceful degradation.
**SBD-20 (CORS) vs public API:** Wildcard OK only if: no auth + no user data + read-only.

## STEP 5 — EXCEPTION PROTOCOL
An exception is valid only when ALL are met:
1. **Documented** — written record of what, why, approved by whom
2. **Scoped** — specific component, not whole system
3. **Time-limited** — expiry: T3=90d / T2=6mo / T1=1yr
4. **Compensating control** — alternative mitigation in place
5. **Named risk owner** — a person, not a team

```yaml
exception_id: EXC-YYYYMMDD-001
control: SBD-XX — Name
component: specific route or module
reason: business/technical justification
compensating_control: what mitigates residual risk
risk_owner: Name, Role
approved_by: Name, Role
created / expires / review_trigger:
```

---

## THE 26 CONTROLS — QUICK REFERENCE

> **Load the full reference for the relevant layer before generating security code.**
> References: `~/.claude/skills/security/layer-1-input.md` · `~/.claude/skills/security/layer-2-identity.md` · `~/.claude/skills/security/layer-3-data.md` · `~/.claude/skills/security/layer-4-resilience.md` · `~/.claude/skills/security/layer-5-supply-chain.md` · `~/.claude/skills/security/layer-6-frontend.md`

| ID | Control | Layer | Stack notes |
|---|---|---|---|
| SBD-01 | Input Validation & Sanitization | Input | Doctrine query builder, Symfony validator, Pydantic |
| SBD-02 | Prompt Injection Defense | Input | Separate user content from system prompt structurally |
| SBD-03 | Output Encoding & CSP | Input | Headers at nginx/CDN level, not app code only |
| SBD-04 | Authentication Integrity | Identity | Argon2id/bcrypt≥12, JWT exp+alg, rate-limit /login |
| SBD-05 | Authorization & Access Control | Identity | Server-side on every request, ownership checks |
| SBD-06 | Least Privilege | Identity | No `Action: *`, no wildcard DB grants |
| SBD-07 | Secrets Management | Data | No secrets in code, .env in git, Angular env files |
| SBD-08 | Cryptographic Standards | Data | AES-256-GCM, TLS 1.3, never MD5/SHA1/DES |
| SBD-09 | Data Minimization | Data | Collect only what's needed, purge stale data |
| SBD-10 | Security Logging | Resilience | Event metadata only, pseudonymize after 30d |
| SBD-11 | Rate Limiting | Resilience | max_tokens on LLM, 5/min on auth endpoints |
| SBD-12 | SSRF Prevention | Resilience | Blocklist private ranges incl. 169.254.x (cloud metadata) |
| SBD-13 | Error Handling | Resilience | Generic to user, detailed to server log only |
| SBD-14 | Dependency Security | Supply Chain | `npm audit`, `composer audit` in CI |
| SBD-15 | CI/CD Integrity | Supply Chain | Pin actions to SHA, not tags |
| SBD-16 | LLM Model Integrity | Supply Chain | Cloud: focus on key/prompt security. Local: SHA256 verify |
| SBD-17 | System Prompt Protection | Supply Chain | Test injection probes before deploy |
| SBD-18 | RAG Security | Supply Chain | Filter by owner_id, never cross-user retrieval |
| SBD-19 | LLM Output Validation | Supply Chain | Never eval/exec/DB from raw LLM output |
| SBD-20 | Network & CORS | Supply Chain | Wildcard only on public read-only unauthenticated endpoints |
| SBD-21 | Secure Design | Supply Chain | Fail secure: return False on exception, never True |
| SBD-22 | Governance | Supply Chain | DoD checklist before every PR to prod |
| SBD-23 | Asset Inventory | Supply Chain | IaC only, no manual production config |
| SBD-24 | Incident Response | Supply Chain | Alert thresholds for brute force + data egress |
| SBD-25 | Privacy & GDPR | Supply Chain | Legal basis matrix, data subject rights endpoints |
| SBD-26 | Frontend Framework Security | Frontend | Angular/React/Vue — server-side always independent |

---

## RED FLAGS — INSTANT FINDINGS

```
AUTH        md5/sha1 password · JWT alg:none or no exp · no rate limit on /login · plaintext compare
INJECTION   string concat in SQL · eval() with user input · innerHTML without sanitize · shell=True
SECRETS     hardcoded keys · .env committed · Angular environment.ts with API keys or internal URLs
LLM         user input in system prompt · LLM output to exec/DB directly · no max_tokens
INFRA       CORS * on authenticated endpoint · APP_DEBUG=True in prod · default credentials · IAM Action:*
FRONTEND    bypassSecurityTrustHtml · dangerouslySetInnerHTML without DOMPurify · v-html with user data
            · route guards as sole authz · SSR state injection without escaping
EXCEPTIONS  no expiry · no named owner · no compensating control · undocumented deviation
```

---

## AUDIT REPORT TEMPLATE

```markdown
# SecureByDesign Audit v2.0 — [SYSTEM]
Date: [DATE] | Tier: [LOW/STANDARD/REGULATED] | Stack: [STACK]

## Summary
| Total | Pass | Partial | Fail | N/A |
|-------|------|---------|------|-----|
| 26    | X    | X       | X    | X   |

## Active Exceptions
[EXC-ID · control · expires · owner]

## CRITICAL (Fix before prod)
[SBD-XX · evidence · risk · remediation with code]

## WARNINGS (Partial)
[gap + recommendation]

## PASSED
[brief confirmation]

## Priority order
1. [highest risk first]

---
*This analysis does not replace penetration testing, formal threat modeling,
or a certified security audit for systems handling sensitive or regulated data.*
```

---

## WHEN TO LOAD REFERENCES

| Task | Load |
|---|---|
| Reviewing auth / login / JWT | `~/.claude/skills/security/layer-2-identity.md` |
| SQL, input validation, XSS | `~/.claude/skills/security/layer-1-input.md` |
| Secrets, crypto, GDPR | `~/.claude/skills/security/layer-3-data.md` |
| Logging, rate limiting, SSRF, errors | `~/.claude/skills/security/layer-4-resilience.md` |
| CI/CD, deps, LLM pipeline, CORS | `~/.claude/skills/security/layer-5-supply-chain.md` |
| Angular / React / Vue / Nuxt SSR | `~/.claude/skills/security/layer-6-frontend.md` |
| Full audit | Load all 6 |
