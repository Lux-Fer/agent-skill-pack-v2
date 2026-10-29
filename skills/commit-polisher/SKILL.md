---
name: commit-polisher
description: AI agent skill for conventional commits, changelog generation, and git history management
version: 1.0.0
author: Agent Skill Pack
tags: [git, conventional-commits, changelog, versioning]
---

# 💎 Commit Polisher Skill

## Purpose
Craft perfect commits following the Conventional Commits standard, generate professional changelogs, and maintain a clean, navigable git history.

## Activation
When asked to format commits, review commit history, or generate changelogs, follow this skill's conventions.

---

## Conventional Commits Standard

### Format
```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

| Type | Purpose | Version Bump | Example |
|------|---------|-------------|---------|
| `feat` | New feature | MINOR | `feat(auth): add OAuth2 login support` |
| `fix` | Bug fix | PATCH | `fix(parser): handle null values in config` |
| `docs` | Documentation only | — | `docs: add API reference section` |
| `style` | Formatting, linting (no code change) | — | `style: run black on entire codebase` |
| `refactor` | Code change that neither fixes nor adds | — | `refactor: extract payment validation logic` |
| `perf` | Performance improvement | PATCH | `perf(cache): reduce Redis round trips` |
| `test` | Adding/fixing tests | — | `test: add edge cases for user creation` |
| `build` | Build system, dependencies | — | `build(deps): upgrade FastAPI to 0.110.0` |
| `ci` | CI/CD configuration | — | `ci: add nightly test workflow` |
| `chore` | Maintenance, tooling | — | `chore: update pre-commit hooks` |
| `revert` | Revert a previous commit | — | `revert: feat(auth): add OAuth2 login` |

### Breaking Changes
```
feat(api)!: remove deprecated v1 endpoints

BREAKING CHANGE: The /api/v1/users endpoint has been removed.
Migrate to /api/v2/users with the updated schema.

Migration guide:
- /api/v1/users → /api/v2/users
- Response format changed from snake_case to camelCase
```

### Scope Examples
```
feat(auth)         # Authentication-related
fix(api)           # API endpoint fixes
feat(ui)           # User interface
fix(db)            # Database changes
refactor(core)     # Core business logic
build(deps)        # Dependency updates
docs(readme)       # README changes
```

---

## Commit Message Templates

### Standard Feature
```
feat(scope): brief description in imperative mood

More detailed explanation of what and why.
Include motivation for the change and any trade-offs.

Closes #123
```

### Bug Fix with Explanation
```
fix(scope): what was wrong

Root cause: why the bug happened
Fix: how it was resolved
Testing: how the fix was verified

Fixes #456
Refs #789
```

### Refactoring (No Behavior Change)
```
refactor(scope): what changed

Before: how it worked
After: how it works now
Rationale: why this is better (performance, readability, etc.)
```

### Multiple Related Changes
```
feat(auth): implement OAuth2 provider system

Adds support for multiple OAuth2 providers:
- Google OAuth2 (verified)
- GitHub OAuth2 (verified)
- GitLab OAuth2 (verified)

Each provider implements the abstract Provider interface.
Token refresh happens automatically when expired.

Closes #234, #235, #236
```

### Breaking Change
```
feat(api)!: migrate to v2 API schema

BREAKING CHANGE: All endpoints now use v2 schema.
- Renamed `user_name` → `username`
- Removed `legacy_id` field from responses
- Added pagination metadata to list endpoints

Migration:
```python
# Before
response.user_name

# After
response.username
```
```

---

## Changelog Generation

### Keep a Changelog Format
```markdown
# Changelog

## [1.2.0] - 2026-04-30

### Added
- OAuth2 provider system with Google, GitHub, GitLab
- Pagination metadata for list endpoints
- Rate limiting for public API endpoints

### Changed
- API schema migrated to v2 format
- Database connection pool increased to 20 connections

### Fixed
- Null pointer when user profile has no avatar
- Race condition in concurrent order processing
- Unicode encoding error in file upload endpoint

### Security
- Upgraded cryptography library to 42.0.0
- Added input sanitization for all user-facing forms

### Deprecated
- /api/v1/ endpoints (removal in 2.0.0)
```

### Automatic Generation Script
```python
#!/usr/bin/env python3
"""Generate changelog from conventional commits since last tag."""
import subprocess
import re
from collections import defaultdict
from datetime import datetime

SECTIONS = {
    "feat": ("Added", "🚀"),
    "fix": ("Fixed", "🐛"),
    "perf": ("Performance", "⚡"),
    "refactor": ("Changed", "🔄"),
    "docs": ("Documentation", "📚"),
    "test": ("Testing", "🧪"),
    "build": ("Build", "🏗️"),
    "ci": ("CI/CD", "🤖"),
    "security": ("Security", "🔒"),
    "deprecated": ("Deprecated", "⚠️"),
}

def get_commits_since_last_tag():
    result = subprocess.run(
        ["git", "log", "$(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD)..HEAD", 
         "--pretty=format:%s%n%b---"],
        capture_output=True, text=True
    )
    return result.stdout

def parse_conventional_commit(msg):
    pattern = r'^(\w+)(\([^)]+\))?(!)?:\s(.+)'
    match = re.match(pattern, msg.strip())
    if match:
        return match.group(1), match.group(4)
    return None, None

def generate_changelog():
    raw = get_commits_since_last_tag()
    entries = defaultdict(list)
    
    for commit in raw.split("---\n"):
        lines = commit.strip().split("\n")
        if not lines[0]:
            continue
        commit_type, desc = parse_conventional_commit(lines[0])
        if commit_type and commit_type in SECTIONS:
            entries[commit_type].append(desc or lines[0])
    
    output = f"# Changelog\n\n## [{datetime.now().strftime('%Y-%m-%d')}]\n\n"
    for commit_type, (section, emoji) in SECTIONS.items():
        if commit_type in entries:
            output += f"### {emoji} {section}\n"
            for entry in entries[commit_type]:
                output += f"- {entry}\n"
            output += "\n"
    
    return output

if __name__ == "__main__":
    print(generate_changelog())
```

---

## Git History Cleanup

### Squash Commits
```bash
# Squash last 3 commits into one
git rebase -i HEAD~3
# Change 'pick' to 'squash' (or 's') for all but first
```

### Interactive Rebase Best Practices
```bash
# Rebase onto main
git rebase -i main

# Commands:
# pick  = use commit (preserve or edit)
# reword = change message only
# squash = combine with previous, merge messages
# fixup  = combine with previous, discard message
# drop   = remove commit entirely
```

### When to Rebase vs Merge

| Situation | Strategy | Command |
|-----------|----------|---------|
| WIP commits → clean commits | Squash | `git rebase -i` |
| Feature branch outdated | Rebase on main | `git rebase main` |
| Public branch | Never rebase | Use merge instead |
| PR/Collaboration | Rebase before merge | `git rebase main` then merge |
| Fixing a commit message | Amend | `git commit --amend` |

### Commit Review Checklist
Before merging, verify:
- [ ] Subject line ≤ 72 characters
- [ ] Type matches the change type
- [ ] Scope (when applicable) identifies the module
- [ ] Breaking changes marked with `!` or `BREAKING CHANGE`
- [ ] Body explains WHY (not what — git log shows what)
- [ ] Issues/closes referenced correctly
- [ ] No merge commits in feature branch
- [ ] Changes compile/run independently at each commit
