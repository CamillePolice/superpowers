---
name: source-driven-development
description: Grounds every framework decision in official documentation. Use when building reusable patterns, implementing framework-specific features, or when the user requests verified current best practices.
---

# Source-Driven Development

## Overview

Ground every framework-specific implementation decision in official documentation. Rather than relying on memory or training data, verify patterns against authoritative sources and cite them so users can verify decisions independently.

## Core Process

1. **DETECT** — Identify the exact framework versions from dependency files
2. **FETCH** — Retrieve official documentation for the specific feature
3. **IMPLEMENT** — Write code matching documented patterns
4. **CITE** — Provide full source URLs and relevant quotes

## When to Use

- Building boilerplate or patterns that will be reused
- Implementing framework-specific features (forms, routing, state management)
- The user requests verified, current best practices
- Code correctness depends on a specific framework version

Skip for pure logic, variable renaming, or when the user explicitly prioritizes speed over verification.

## Authority Hierarchy

1. Official documentation
2. Official blogs/changelogs
3. Web standards (MDN)
4. Browser compatibility data

Not authoritative: Stack Overflow, tutorials, training data.

## Key Principles

- Always fetch relevant docs before writing framework code
- Surface conflicts between documentation versions and existing code
- Flag anything unverifiable as explicitly unverified
- Include full URLs in citations with deep links where possible
- Quote relevant passages supporting non-obvious decisions
