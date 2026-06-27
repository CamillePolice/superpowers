# SBD Layer 6 — Frontend Framework Security

> **Core rule:** Frontend framework protections are browser-layer only.
> Server-side validation and output encoding must be **independent** of any frontend protection.
> Angular route guards, React state, Vue computed — none of these are security controls.

---

## Angular

### Template Security
```typescript
// SAFE — Angular auto-escapes interpolation:
<span>{{ userInput }}</span>

// NEVER — bypasses sanitization entirely:
this.trustedHtml = this.sanitizer.bypassSecurityTrustHtml(userInput);
// Any use of bypassSecurityTrust* with user-controlled input = critical finding.

// NEVER — innerHTML with user data:
<div [innerHTML]="userContent"></div>
// Use a sanitizing pipe instead:
<div [innerHTML]="userContent | sanitizeHtml"></div>

// NEVER — dynamic template compilation from user input:
// Compiling user-provided strings as Angular templates = RCE.
```

### HTTP & CSRF
```typescript
// Angular HttpClientModule includes XSRF protection when server sets XSRF-TOKEN cookie.
// Verify in app.config.ts:
provideHttpClient(
  withXsrfConfiguration({
    cookieName: 'XSRF-TOKEN',
    headerName: 'X-XSRF-TOKEN'
  })
)
// Confirm backend validates this header on all state-changing requests.
```

### CSP
```
// Avoid: script-src 'unsafe-inline' 'unsafe-eval' — defeats CSP entirely.
// Prefer hash-based or nonce-based:
// ng build --subresource-integrity generates SRI hashes automatically.
```

### Route Guards — Security Theater
```typescript
// canActivate / canLoad / canMatch = UX only. Bypassable with DevTools.
// NEVER use as sole authorization check.
// Backend must enforce authorization on every request independently.

// This is NOT secure:
canActivate(): boolean { return this.authService.isAdmin(); }
// This IS secure: backend returns 403 for non-admin requests.
```

### Angular Environment Files
```typescript
// NEVER — environment.ts is compiled into the JS bundle, fully readable in browser:
export const environment = {
  apiKey: 'sk-....',
  internalUrl: 'http://10.0.0.5'  // leaks internal topology
};

// CORRECT — only your own backend URL:
export const environment = { apiUrl: 'https://yourapp.com/api' };
```

---

## Nuxt (SSR — project-flow / ClaraCharge)

### Runtime Config
```typescript
// nuxt.config.ts — server-only secrets:
runtimeConfig: {
  dbPassword: '',           // server-only, never exposed
  auth0ClientSecret: '',
  public: {
    apiBase: '/api'         // safe to expose to client
  }
}
// Never put secrets in public.*
```

### SSR State Hydration
```typescript
// DANGEROUS — raw user data in SSR state tag:
<script>window.__STATE__ = ${JSON.stringify(userControlledData)}</script>
// If data contains </script>, parser breaks out → XSS.

// CORRECT:
const safeState = JSON.stringify(sanitized).replace(/<\/script>/gi, '<\\/script>');

// Nuxt useNuxtApp().payload is serialized safely by Nuxt internals — but
// data you manually inject into <script> tags via useHead() must be escaped.
```

### Server Routes (Nitro)
```typescript
// Nitro server routes are a backend surface — apply all backend controls:
// SBD-01 (validate input), SBD-05 (check ownership), SBD-07 (no secrets in code)
export default defineEventHandler(async (event) => {
  const session = await getUserSession(event)
  if (!session?.user) throw createError({ statusCode: 401 })

  const id = getRouterParam(event, 'id')
  // Always verify ownership, never trust client-provided IDs alone
})
```

---

## React

```tsx
// SAFE — React escapes text content and attributes automatically:
<span>{userInput}</span>
<input value={userInput} />

// NEVER:
<div dangerouslySetInnerHTML={{ __html: userContent }} />
// If HTML rendering required, sanitize first:
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userContent) }} />

// NEVER — javascript: URLs:
<a href={userProvidedUrl}>Click</a>
// Validate before rendering:
const isSafeUrl = (url: string) => /^https?:\/\//.test(url) || url.startsWith('/');
```

---

## Vue

```vue
<!-- SAFE — Vue escapes interpolation: -->
<span>{{ userContent }}</span>

<!-- NEVER — v-html with user content: -->
<div v-html="userContent"></div>
<!-- Equivalent to innerHTML. If required, sanitize with DOMPurify first. -->

<!-- NEVER — SSR template injection: -->
<!-- Never compile user-provided strings as Vue templates server-side. -->
```
