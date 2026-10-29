---
name: dependency-manager
title: dependency-manager
description: AI agent skill for dependency management, audit, vulnerability scanning, upgrade strategies, and monorepo handling
author: agent-skill-pack-v2
version: 1.0.0
tags: [dependencies, security, audit, vulnerability, monorepo, upgrades]
skill_type: maintenance
---

# Dependency Manager Skill

## Overview

Comprehensive approach to managing project dependencies — auditing for security and licensing issues, planning and executing upgrades, resolving transitive dependency conflicts, and handling monorepo dependency graphs.

## 1. Dependency Audit

### Python Security Auditing

```bash
# ── Safety CLI ──
# Check known vulnerabilities in installed packages
safety check -r requirements.txt --full-report

# JSON output for CI processing
safety check -r requirements.txt --json > safety-report.json

# Ignore specific CVEs (e.g., false positives)
safety check -r requirements.txt --ignore=12345,67890

# ── Bandit (static analysis for security issues) ──
bandit -r src/ -f json -o bandit-report.json

# ── pip-audit ──
pip-audit -r requirements.txt --desc

# ── pip-licenses (license compliance) ──
pip-licenses --format=json --allow-only="MIT;Apache-2.0;BSD-3-Clause"
```

```python
# Programmatic dependency audit
import subprocess
import json
from typing import Optional

def audit_python_deps(requirements_file: str) -> dict:
    """Run safety check and return parsed results."""
    result = subprocess.run(
        ["safety", "check", "-r", requirements_file, "--json"],
        capture_output=True, text=True
    )
    if result.returncode == 0:
        return {"status": "clean", "vulnerabilities": []}

    # Safety returns exit code 1 if vulnerabilities found
    vulns = json.loads(result.stdout)
    return {
        "status": "vulnerable",
        "vulnerabilities": [
            {
                "package": v["package_name"],
                "installed": v["vulnerable_spec"],
                "vulnerability": v["advisory"],
                "cve": v.get("cve"),
                "severity": v.get("severity", "unknown"),
            }
            for v in vulns
        ]
    }
```

### JavaScript/Node.js Auditing

```bash
# ── npm audit ──
npm audit                   # Summary report
npm audit --json            # Machine-readable
npm audit --audit-level=high # Only fail on high/critical

# ── yarn audit ──
yarn audit                 # Vulnerability report
yarn audit --json          # JSON format

# ──── npm outdated (check available upgrades) ────
npm outdated               # List outdated packages
npm outdated --long        # Detailed view

# ── Snyk CLI ──
snyk test                  # Open source vulnerability scanning
snyk monitor               # Continuous monitoring
snyk code test             # SAST (static analysis)
```

```javascript
// Programmatic npm audit (Node.js)
const { execSync } = require('child_process');

function auditDependencies() {
  try {
    const result = execSync('npm audit --json', { encoding: 'utf8' });
    const audit = JSON.parse(result);

    const advisoryCount = Object.keys(audit.advisories || {}).length;
    if (advisoryCount > 0) {
      console.log(`Found ${advisoryCount} vulnerabilities:`);
      for (const [id, advisory] of Object.entries(audit.advisories)) {
        console.log(`  ${advisory.severity.toUpperCase()}: ${advisory.module_name}`);
        console.log(`    ${advisory.title}`);
        console.log(`    Path: ${advisory.findings[0]?.paths?.[0] || 'direct'}`);
      }
    }
    return audit;
  } catch (err) {
    // npm audit exits with non-zero if vulns found
    const audit = JSON.parse(err.stdout);
    return audit;
  }
}
```

### Audit Automation (CI Integration)

```yaml
# GitHub Actions: weekly dependency scan
name: Dependency Audit

on:
  schedule:
    - cron: '0 6 * * 1'  # Every Monday at 6:00 UTC
  workflow_dispatch:       # Manual trigger

jobs:
  audit-python:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - run: pip install safety
      - name: Check dependencies
        run: safety check -r requirements.txt --full-report
        continue-on-error: true

  audit-node:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - name: npm audit
        run: npm audit --audit-level=high
        continue-on-error: true

  notify:
    needs: [audit-python, audit-node]
    if: failure()
    runs-on: ubuntu-latest
    steps:
      - name: Send Slack notification
        uses: slackapi/slack-github-action@v1.24.0
        with:
          payload: |
            {
              "text": "⚠️ Dependency vulnerabilities detected in ${{ github.repository }}"
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

## 2. Upgrade Strategies

### Upgrade Decision Framework

| Factor | Conservative | Balanced | Aggressive |
|--------|-------------|----------|------------|
| **Check frequency** | Monthly | Weekly | Continuous (Dependabot/Renovate) |
| **Patch updates** | Auto-merge | Auto-merge | Auto-merge |
| **Minor updates** | Manual review after 2 weeks | Auto-PR, manual merge | Auto-merge if tests pass |
| **Major updates** | Manual review quarterly | Manual review monthly | Manual review with migration plan |
| **Test coverage needed** | 90%+ | 75%+ | 60%+ with integration tests |

### Python Upgrade Strategy

```python
import subprocess
import re
from packaging.version import Version, InvalidVersion

def analyze_upgrade_impact(
    package_name: str,
    current_version: str,
    target_spec: str = "latest"
) -> dict:
    """Analyze the impact of upgrading a package."""
    # Get available versions
    result = subprocess.run(
        ["pip", "index", "versions", package_name],
        capture_output=True, text=True
    )
    # Parse: "Available versions: 3.0.0, 2.9.2, ..."
    match = re.search(r"Available versions: (.+)", result.stdout)
    if not match:
        return {"error": "Could not find versions"}

    versions = match.group(1).split(", ")
    current = Version(current_version)
    available = [Version(v) for v in versions]

    # Categorize
    patches = [v for v in available if v.micro > current.micro
               and v.major == current.major and v.minor == current.minor]
    minors = [v for v in available if v.minor > current.minor
              and v.major == current.major]
    majors = [v for v in available if v.major > current.major]

    return {
        "package": package_name,
        "current": str(current),
        "latest": str(max(available)) if available else current_version,
        "patch_upgrades": [str(v) for v in patches[-3:]],
        "minor_upgrades": [str(v) for v in minors[-3:]],
        "major_upgrades": [str(v) for v in majors[-3:]],
        "versions_behind": len(available) - available.index(current) - 1,
    }
```

### JavaScript Upgrade Strategy

```bash
# npm-check-updates (interactive)
npx npm-check-updates -i            # Interactive upgrade
npx npm-check-updates -u            # Update package.json
npx npm-check-updates --target minor # Only minor/patch
npx npm-check-updates --doctor      # Test each upgrade

# npm outdated → manual upgrade
npm outdated                          # See what's stale
npm update                            # Safe: respects semver
npm install package@latest            # Force latest

# Dependabot (GitHub native)
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
      time: "09:00"
      timezone: "America/New_York"
    open-pull-requests-limit: 10
    labels: ["dependencies", "python"]
    reviewers: ["team-leads"]
    ignore:
      - dependency-name: "numpy"
        versions: [">=2.0.0"]  # Skip numpy 2.x until migration
```

## 3. Vulnerability Scanning

### Scanning Tools Comparison

| Tool | Ecosystem | Type | Integration |
|------|-----------|------|-------------|
| **Safety** | Python (PyPI) | Known vulns DB | CLI, CI, pre-commit |
| **Bandit** | Python | Static analysis | CLI, CI |
| **pip-audit** | Python | PEP 665, PyPI advisory DB | CLI, CI, pip |
| **npm audit** | Node.js | npm registry advisories | Built-in npm |
| **yarn audit** | Node.js | npm registry advisories | Built-in yarn |
| **Snyk** | Multi-language | SAST + SCA | CLI, CI, GitHub app |
| **Trivy** | Multi-language + containers | Comprehensive | CLI, CI, Kubernetes |
| **Grype** | Multi-language + containers | Fast, Syft integration | CLI, CI |
| **Dependency-Check** | Java/.NET/Python/Ruby | OWASP | CLI, CI, Maven plugin |
| **Renovate** | Multi-language | Dependency updates + vulns | GitHub/GitLab app |

### Vulnerability Response Workflow

```
1. DETECT  ── Scan detects CVE in dependency
      │
2. TRIAGE  ── Severity? Exploitable in our context?
      │
3. DECIDE  ── Update | Patch | Accept | Mitigate
      │
4. ACT     ── Update dependency | Apply workaround | Add to allowlist
      │
5. VERIFY  ── Tests pass | No regression | Scan clean
      │
6. MONITOR ── Track in SBOM | Set alert for fix release
```

```python
# Vulnerability triage helper
from dataclasses import dataclass
from enum import Enum

class Severity(Enum):
    CRITICAL = "critical"
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"

class Remediation(Enum):
    UPDATE = "update"
    PATCH = "patch"
    ACCEPT = "accept_risk"
    MITIGATE = "mitigate_workaround"

@dataclass
class Vulnerability:
    id: str
    package: str
    severity: Severity
    description: str
    fix_version: str | None
    exploitability: str  # "none" | "proof_of_concept" | "active"

    def recommend_action(self, is_direct_dep: bool) -> Remediation:
        """Recommend remediation based on severity and context."""
        if self.severity in (Severity.CRITICAL, Severity.HIGH):
            if self.fix_version and is_direct_dep:
                return Remediation.UPDATE
            elif self.fix_version:
                return Remediation.UPDATE  # Transitive: update direct dep
            else:
                return Remediation.MITIGATE

        if self.severity == Severity.MEDIUM:
            if self.exploitability == "active":
                return Remediation.UPDATE
            return Remediation.ACCEPT if not self.fix_version else Remediation.UPDATE

        return Remediation.ACCEPT
```

## 4. Lock File Management

### Lock File Best Practices

| Ecosystem | Lock File | Strategy |
|-----------|-----------|----------|
| Python | `requirements.txt` + `requirements.lock` | Pin exact versions |
| Python (Pipenv) | `Pipfile.lock` | Hash-verified |
| Python (Poetry) | `poetry.lock` | Deterministic, hash-verified |
| Node.js | `package-lock.json` | Auto-generated, commit |
| Node.js (Yarn) | `yarn.lock` | Auto-generated, commit |
| Go | `go.sum` | Hash-verified |

```yaml
# Lock file management in CI
# Always run with frozen lockfile in CI
steps:
  - name: Install dependencies (frozen)
    run: pip install --no-deps -r requirements.lock

# For npm/yarn
  - name: Install (frozen)
    run: npm ci   # Uses package-lock.json, fails if mismatch
           # OR
    run: yarn install --frozen-lockfile
```

### Lock Diff Review

```bash
# Reviewing a lock file change in PR
git diff main...HEAD -- package-lock.json | head -100

# Detect unexpected transitive dep changes
npm ls --all > before.lock
# ... run npm install ...
npm ls --all > after.lock
diff before.lock after.lock

# Python equivalent
pip freeze > before.txt
# ... update requirements.txt ...
pip install -r requirements.txt
pip freeze > after.txt
diff before.txt after.txt
```

## 5. Transitive Dependency Resolution

### Conflict Resolution

```python
# Python dependency tree inspection
# pipdeptree shows the full dependency tree
# pip install pipdeptree

import subprocess
import re
from collections import defaultdict

def find_dependency_conflicts():
    """Use pipdeptree to find conflicting dependencies."""
    result = subprocess.run(
        ["pipdeptree", "-w"],  # -w warns about conflicts
        capture_output=True, text=True
    )
    conflicts = []
    current_conflict = {}

    for line in result.stdout.split('\n'):
        if 'WARNING:' in line and 'requires' in line:
            # Parse conflict lines
            current_conflict = {'message': line.strip()}
        elif '  ' in line and current_conflict:
            # Continuation lines
            current_conflict['message'] += ' ' + line.strip()
        else:
            if current_conflict:
                conflicts.append(current_conflict)
                current_conflict = {}

    return conflicts

# Preferred resolution order:
# 1. Upgrade direct dependency to version that requires newer transitive
# 2. Pin compatible version in overrides/constraints
# 3. Fork or vendor the conflicting dependency (last resort)
```

```jsonc
// npm overrides (package.json)
// Force a specific version of a transitive dependency
{
  "overrides": {
    "glob": "10.3.10",
    "minimatch": {
      ".": "9.0.3",       // Direct
      "glob": "9.0.3"     // Under glob
    }
  }
}

// Yarn resolutions
{
  "resolutions": {
    "**/minimatch": "9.0.3",
    "glob/**/minimatch": "9.0.3"
  }
}
```

## 6. Monorepo Dependency Management

### Monorepo Strategies

```yaml
# Python: pip-tools with individual requirements per package
# Structure:
# monorepo/
# ├── packages/
# │   ├── core/
# │   │   ├── setup.py
# │   │   └── requirements.in
# │   ├── api/
# │   │   ├── setup.py
# │   │   └── requirements.in
# │   └── worker/
# │       ├── setup.py
# │       └── requirements.in
# └── requirements-dev.txt

# Use pip-compile from pip-tools for each package
# pip-compile packages/core/requirements.in
# pip-compile packages/api/requirements.in
```

```bash
# Node.js: npm/nx workspaces
# package.json at monorepo root
{
  "workspaces": [
    "packages/*"
  ],
  "scripts": {
    "lint": "npm run lint -ws",
    "test": "npm run test -ws --if-present",
    "build": "npm run build -ws --if-present"
  }
}

# Deduplication across workspaces
npx depcheck                   # Find unused dependencies
npx npm dedupe                # Deduplicate transitive deps
npx npm ls --depth=4          # Show dependency tree
```

### Monorepo Dependency Testing

```bash
# Test all packages affected by a dependency change
# Using nx affected
npx nx affected:test --base=main

# Python monorepo: test all consuming packages
# When updating packages/core, also test packages/api and packages/worker
```

## 7. Deprecation Handling

### Deprecation Detection

```python
# Python deprecation warnings
import warnings

# Enable all deprecation warnings
warnings.filterwarnings('once', category=DeprecationWarning)

# Or via CLI
# python -W all::DeprecationWarning app.py

# In tests
@pytest.mark.filterwarnings('error::DeprecationWarning')
def test_no_deprecated_usage():
    """Test fails if any deprecated API is used."""
    ...
```

### Deprecation Response Checklist

- [ ] Read the deprecation notice/changelog
- [ ] Check deprecation timeline (removed in which version?)
- [ ] Find recommended replacement
- [ ] Search code for all usages
- [ ] Schedule migration in sprint
- [ ] Update tests to use new API
- [ ] Remove old code and pin updated dependency
- [ ] Verify no regressions with integration tests

### Library Sunsetting

```python
# When you deprecate an internal library:
import warnings
from typing import Any

def old_api(param: str) -> Any:
    warnings.warn(
        "old_api() is deprecated, use new_api() instead."
        " Will be removed in v3.0.0.",
        DeprecationWarning,
        stacklevel=2
    )
    # ... implementation using old_api ...
    return new_api(param)
```

## References

- [Safety CLI](https://docs.pyup.io/docs/safety)
- [OWASP Dependency-Check](https://owasp.org/www-project-dependency-check/)
- [Dependabot](https://docs.github.com/en/code-security/dependabot)
- [Renovate](https://docs.renovatebot.com/)
- [pip-tools documentation](https://github.com/jazzband/pip-tools)
- [npm workspaces](https://docs.npmjs.com/cli/v7/using-npm/workspaces)
