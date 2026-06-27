---
name: npm-package-vetting
description: |
  Help users safely install npm dependencies by analyzing security vulnerabilities, maintenance status, popularity metrics, license risks, and dependency footprint before installation.

  TRIGGER whenever the user wants to: add/install npm packages, use a new npm dependency, check if an npm package is safe, evaluate a JavaScript/Node.js library, or asks "should I use X package". Also trigger when they mention concerns about npm security, outdated npm packages, or npm package quality.

  The skill performs comprehensive safety checks and suggests safer alternatives when issues are found, while still allowing the user to make the final decision.

  Does NOT trigger for: generic security audits unrelated to npm, Python/Go/Rust/other ecosystem packages, or checking existing package.json without intent to add a new dependency.
allowed-tools:
  - Bash(npm view *)
  - Bash(npm search *)
  - WebFetch(domain:osv.dev)
  - WebFetch(domain:api.npmjs.org)
  - WebFetch(domain:api.github.com)
---

# npm-package-vetting

Analyze npm packages for security, maintenance, license, and dependency risks before installation. Report findings concisely — actionable info only.

## Workflow

### 1. Gather Package Data

**a) Basic Package Information**

```bash
npm view <package-name> --json
```

Extract: latest version, publish date, license, dependencies, repository URL, maintainer count, description.

**b) Security Audit**

Use WebFetch to query OSV.dev (GET only — do NOT attempt POST via Bash curl):

```
WebFetch: https://osv.dev/list?q=<package-name>&ecosystem=npm
```

Extract count and details of HIGH and CRITICAL CVEs only. Also check direct dependencies for CVEs using the same URL pattern.

**c) Popularity & Usage**

Use WebFetch for registry and GitHub APIs:

```
WebFetch: https://api.npmjs.org/downloads/point/last-week/<package-name>
WebFetch: https://api.github.com/repos/<owner>/<repo>   (if repo URL available from npm view)
```

Extract: weekly downloads, GitHub stars, last push date.

**d) Maintenance**

From `npm view` output:

- Last published date
- Version count in past year
- Maintainer count
- Deprecation status

🚨 **Red flags**: >2 years since update, deprecated, single maintainer

**e) License**

✅ **Permissive**: MIT, Apache 2.0, BSD, ISC
⚠️ **Restrictive**: GPL/AGPL (requires source code release), CC BY-NC (non-commercial only), SSPL
🚨 **No license**: Legally risky

Warn clearly if GPL/AGPL or other restrictive licenses.

**f) Dependencies**

```bash
npm view <package-name> dependencies --json
```

Fewer dependencies = smaller attack surface. Note peer dependencies separately.

### 2. Check for Native Alternatives

Check if Node.js/browsers have built-in functionality:

- HTTP clients → `fetch()` (Node 18+)
- UUID → `crypto.randomUUID()` (Node 14.17+)
- File ops (mkdirp/rimraf) → `fs` with `recursive: true`
- Promises (bluebird/q) → Native Promises
- Query strings → `URLSearchParams`
- Deep clone → `structuredClone()` (Node 17+)
- Date formatting → `Intl.DateTimeFormat`

If native exists, recommend it first with version requirements and API differences noted.

### 3. Score the Package

🔒 **Security**: ✅ No CVEs | ⚠️ Low/moderate CVEs | 🚨 High/critical CVEs
🔧 **Maintenance**: ✅ <6mo | ⚠️ 6-24mo | 🚨 >2yr
⭐ **Popularity**: ✅ >100k/wk | ⚠️ 10-100k/wk | 🚨 <10k/wk
📦 **Dependencies**: ✅ 0-5 | ⚠️ 6-15 | 🚨 16+

Context matters: 10M downloads with warnings ≠ 1k downloads with warnings.

### 4. Find Alternatives (if 🚨 red flags)

```bash
npm search <keyword> --json | head -c 5000
```

Quick-check 2-3 top alternatives (>100k downloads). Show side-by-side comparison.

### 5. Present Report

````markdown
## 📦 Package Analysis: <package-name>

### Summary

[One-line assessment: "Safe to use" / "Proceed with caution" / "Consider alternatives"]

### 💡 Native Alternative Available

[If applicable: Show that Node.js or browser has built-in functionality]

- **Native option**: [e.g., "fetch API (Node 18+, all modern browsers)"]
- **Requires**: [Version requirements]
- **Differences**: [Any API differences or limitations]
- **Recommendation**: [Whether to use native or package]

### Security 🔒 [✅/⚠️/🚨]

- **CVEs**: [Count and severity]
- **Last audit**: [Date]
- **Notes**: [Key security findings]

### Maintenance 🔧 [✅/⚠️/🚨]

- **Last published**: [X days/months ago]
- **Update frequency**: [X versions in past year]
- **Maintainers**: [Count]
- **Status**: [Active/Stable/Stale/Deprecated]

### Popularity ⭐ [✅/⚠️/🚨]

- **Weekly downloads**: [Count]
- **GitHub stars**: [Count if available]
- **Dependents**: [Count]

### License 📄 [✅/⚠️/🚨]

- **Type**: [License name]
- **Restriction level**: [Permissive/Restrictive/Unknown]
- **⚠️ Warning**: [If GPL/AGPL/NC/etc., explain the implications]

### Dependencies 📦 [✅/⚠️/🚨]

- **Direct dependencies**: [Count]
- **Peer dependencies**: [List if any]
- **Impact**: [Minimal/Moderate/Heavy]

### ⚠️ Issues Found

[List any concerning findings, if applicable]

### ✨ Recommended Alternatives

[If issues found, show 2-3 better-maintained/more secure alternatives with brief comparison]

### 📝 Recommendation

[Clear guidance: explain what the analysis shows and what the user should consider]

### Installation

[Only if all checks pass with no ⚠️ or 🚨:]

```bash
npm install <package-name>
```
````

[If any ⚠️ or 🚨 exist:]
Do not provide an install command. The user will install manually if they choose to proceed.

## Examples

**Example 1: Safe package with native alternative**

```
User: "I want to install axios for HTTP requests"

Analysis shows:
- 💡 Native fetch API available (Node 18+)
- 🔒 ✅ No vulnerabilities
- 🔧 ✅ Updated recently
- ⭐ ✅ 50M+ weekly downloads
- 📦 ✅ 3 dependencies (minimal)

Result: Recommend native fetch first, note axios as alternative if they need advanced features (interceptors, etc.)
```

**Example 2: Unmaintained package with alternatives**

```
User: "Install request for HTTP calls"

Analysis shows:
- 🔒 ⚠️ Some moderate CVEs
- 🔧 🚨 Deprecated, not updated in 4 years
- ⭐ ✅ Still heavily downloaded (legacy projects)

Result: Show deprecation notice, suggest axios or node-fetch as modern alternatives
```

**Example 3: Popular package with restrictive license**

```
User: "I want to use readline for CLI interactions"

Analysis shows:
- 🔒 ✅ No vulnerabilities
- 🔧 ✅ Well maintained
- ⭐ ✅ Popular
- 📄 🚨 GPL-3.0 license
- 📦 ⚠️ 12 dependencies

Result: Warn about GPL implications, suggest MIT-licensed alternatives like prompts, inquirer, or native readline module
```

**Example 4: Lightweight package with zero dependencies**

```
User: "Install h3-zod for validation"

Analysis shows:
- 🔒 ✅ No vulnerabilities
- 🔧 🚨 Not updated in 2+ years
- ⭐ 🚨 Low downloads (1.5k/week)
- 📦 ✅ 0 dependencies (only peer deps)

Result: Acknowledge excellent dependency footprint but warn about stale maintenance. Suggest manual Zod integration as alternative.
```
