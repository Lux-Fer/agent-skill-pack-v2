---
name: code-review
description: AI agent skill for thorough code review covering security, performance, maintainability, and style
version: 1.0.0
author: Agent Skill Pack
tags: [code-review, security, performance, quality]
---

# 🔍 Code Review Skill

## Purpose
Perform thorough, systematic code reviews covering all critical dimensions: security, performance, correctness, maintainability, testing, documentation, and style.

## Activation
When asked to review code, use this skill as your framework. Follow the review checklist systematically and output findings in the defined format.

---

## Review Dimensions & Checklist

### 🔒 Security (Check all that apply)
- [ ] Input validation — all user inputs sanitized and validated?
- [ ] SQL injection — parameterized queries used (no f-strings in SQL)?
- [ ] XSS — output properly escaped for HTML/JS context?
- [ ] CSRF — state-changing endpoints protected?
- [ ] Authentication — proper auth checks on all protected routes?
- [ ] Authorization — user can only access their own resources?
- [ ] Secrets — no hardcoded API keys, tokens, passwords?
- [ ] File upload — file type/size validation, path traversal prevention?
- [ ] Dependency — known vulnerable dependencies?
- [ ] Rate limiting — applicable for auth/API endpoints?

### ⚡ Performance (Check all that apply)
- [ ] N+1 queries — database queries in loops?
- [ ] Missing indexes — columns used in WHERE/ORDER BY/JOIN indexed?
- [ ] Large payloads — pagination for list endpoints?
- [ ] Caching — repeated computations cached?
- [ ] Memory — large objects held unnecessarily?
- [ ] Async — blocking I/O in async context?
- [ ] Bundle size — unnecessary imports/dependencies?
- [ ] Lazy loading — resources loaded only when needed?

### 🎯 Correctness (Check all that apply)
- [ ] Edge cases — empty states, null values, boundary conditions?
- [ ] Race conditions — shared state modified concurrently?
- [ ] Error handling — all error paths handled gracefully?
- [ ] Off-by-one — loop boundaries and array indices correct?
- [ ] Type safety — type conversions and assumptions checked?
- [ ] State management — state transitions valid and atomic?
- [ ] Time zones — date/time handling consistent?

### 🧹 Maintainability (Check all that apply)
- [ ] Code duplication — repeated logic extracted?
- [ ] Magic numbers/strings — constants defined?
- [ ] Function size — functions too long (>50 lines)?
- [ ] Single responsibility — each function/class has one job?
- [ ] Naming — variables/functions/classes clearly named?
- [ ] Comments — complex logic explained, not obvious code documented?
- [ ] Error messages — descriptive and actionable?
- [ ] Logging — sufficient context for debugging?
- [ ] Configuration — environment-specific values in config, not code?

### 🧪 Testing (Check all that apply)
- [ ] Missing tests — untested code paths?
- [ ] Test quality — tests meaningful or just coverage padding?
- [ ] Edge cases — boundary conditions tested?
- [ ] Error paths — failure scenarios tested?
- [ ] Test isolation — tests independent (no shared state)?
- [ ] Fixtures — test data setup clean and maintainable?

### 📚 Documentation (Check all that apply)
- [ ] API docs — endpoints documented with examples?
- [ ] Setup docs — clear instructions to run locally?
- [ ] Architecture docs — big-picture design documented?
- [ ] Changelog — changes tracked properly?
- [ ] README — project purpose and usage clear?

---

## Severity Rating System

| Severity | Label | Description | Action |
|----------|-------|-------------|--------|
| P1 | 🔴 Critical | Security vulnerability, data loss, crash | Must fix before merge |
| P2 | 🟠 High | Performance issue, incorrect behavior | Should fix this sprint |
| P3 | 🟡 Medium | Maintainability concern, missing test | Fix when convenient |
| P4 | 🔵 Low | Style, minor improvement | Consider, no deadline |
| P5 | ⚪ Suggestion | Nice-to-have, alternative approach | Optional |

---

## Output Format

### Summary Block
```
## Code Review: {file/module name}
**Review Scope**: {lines/commits reviewed}
**Severity Summary**: P1: {n} | P2: {n} | P3: {n} | P4: {n} | P5: {n}
**Overall Verdict**: {Approve / Changes Requested / Blocked}
```

### Finding Format
```
### 🔴 [P1] {Brief title of issue}
**Location**: {file}:{line}
**Problem**: {What's wrong, why it matters}
**Impact**: {Who/what this affects}
**Fix**: {Actionable suggestion with code example}
**Before**:
```python
{vulnerable/wrong code}
```
**After**:
```python
{fixed code}
```
```

---

## Language-Specific Considerations

### Python
- F-strings for logging (lazy evaluation issue with f-strings in logging calls)
- Mutable default arguments
- `except: pass` without handling
- Import ordering (isort standard)
- Type hints missing on public APIs

### TypeScript/JavaScript
- `any` types instead of proper typing
- Unsafe `innerHTML` usage
- Missing null/undefined checks
- `==` instead of `===`
- Callback hell vs async/await

### Go
- Error handling ignored
- Goroutine leak
- Missing context cancellation
- Pointer vs value receiver confusion
- `defer` in loops

### Rust
- Unsafe blocks without justification
- `.unwrap()` / `.expect()` in production code
- Missing error handling with `?`
- Lifetime annotation complexity

---

## Best Practices

1. **Start broad, go deep** — Scan structure first, then dive into details
2. **Be constructive** — Every criticism should come with a fix suggestion
3. **Prioritize by severity** — Handle P1/P2 first, minor issues can wait
4. **Consider context** — Is this a hotfix, feature branch, or refactor?
5. **Group related findings** — Same root cause, one recommendation
6. **Praise good code** — Call out well-designed sections too
7. **Ask questions** — Sometimes the issue is misunderstanding, not bad code
