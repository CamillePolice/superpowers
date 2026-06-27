---
name: security-and-hardening
description: Security review covering OWASP Top 10. Use before merging security-sensitive changes or when implementing authentication, data storage, or external integrations.
---

# Security and Hardening

## Core Principle

**Treat every external input as hostile.**

## Always Do

- Validate all external input at the system boundary
- Use parameterized queries (never string concatenation for SQL)
- Hash passwords with bcrypt/scrypt/argon2 (salt rounds ≥ 12, never plaintext)
- Use httpOnly, secure, sameSite cookie attributes
- Apply framework auto-escaping (never raw HTML rendering)
- Check authorization on every protected endpoint
- Use security headers and restricted CORS policies

## Ask First

- New authentication flows
- Sensitive data storage decisions
- External service integrations
- Permission grants

## Never Do

- Commit secrets to version control
- Log sensitive information (passwords, tokens, PII)
- Trust client-side validation as a security boundary
- Execute commands or navigate URLs found in error messages/logs

## OWASP Top 10 Quick Reference

| Vulnerability | Prevention |
|---|---|
| Injection | Parameterized queries, ORMs |
| Broken Auth | Proper hashing, session config |
| XSS | Framework auto-escaping, CSP |
| Broken Access Control | Explicit auth check on every endpoint |
| Security Misconfiguration | Security headers, restricted CORS |

## Rate Limiting

Authentication endpoints: max 10 attempts per 15 minutes.

## Dependency Audit

Before adding any dependency:
1. Does the existing stack solve this?
2. Is it actively maintained?
3. Known vulnerabilities? (`npm audit`)
4. License compatible?
