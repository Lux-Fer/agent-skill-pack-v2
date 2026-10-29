---
name: security-auditor
title: Security Auditor
version: 1.0.0
description: AI agent skill for security auditing — OWASP Top 10, dependency scanning, secret detection, input validation, authentication review, authorization checks, and secure coding guidelines.
author: Agent Skill Pack v2
tags: [security, auditing, owasp, vulnerability, authentication, authorization]
os: [linux, macos, windows]
tools: [python, bandit, semgrep, trufflehog, pip-audit, npm-audit, grype, trivy]
---

# Security Auditor Skill

## Overview

This skill provides agents with structured methodologies for performing security audits across application code, dependencies, configurations, and infrastructure. It covers the OWASP Top 10, automated scanning, manual review patterns, and actionable remediation guidance.

---

## 1. OWASP Top 10 (2021) Scanning

### 1.1 A01: Broken Access Control
*Detection patterns:*
- Missing authorization checks in view functions or API handlers
- Direct object references without ownership validation
- Privilege escalation via role/group manipulation
- Insecure CORS configuration allowing arbitrary origins

```python
# VULNERABLE: No ownership check
@app.route("/api/orders/<order_id>")
def get_order(order_id):
    order = db.query(Order).filter(Order.id == order_id).first()
    return jsonify(order.to_dict())

# FIXED: Ownership verification
@app.route("/api/orders/<order_id>")
@require_auth
def get_order(order_id):
    order = db.query(Order).filter(
        Order.id == order_id,
        Order.user_id == current_user.id
    ).first()
    if not order:
        abort(404)
    return jsonify(order.to_dict())
```

### 1.2 A02: Cryptographic Failures
*Detection patterns:*
- HTTPS not enforced (plain HTTP)
- Custom encryption implementations
- Weak algorithms (MD5, SHA1, DES, RC4)
- Hardcoded encryption keys
- Missing TLS certificate validation
- Insecure random number generators (`random` module vs `secrets`)

```python
# VULNERABLE: Weak hash, no salt
password_hash = hashlib.md5(password.encode()).hexdigest()

# FIXED: Strong hash with salt
password_hash = hashlib.scrypt(password.encode(), salt=os.urandom(16), n=16384, r=8, p=1)
```

### 1.3 A03: Injection
*Detection patterns:*
- String concatenation in SQL queries
- Unsafe eval/exec calls
- Unsafe deserialization (pickle, yaml.load, marshal)
- Command injection via os.system/subprocess with shell=True
- Template injection (Jinja2, Handlebars with user input)

```python
# VULNERABLE: SQL injection
query = f"SELECT * FROM users WHERE email = '{email}'"
db.execute(query)

# FIXED: Parameterized query
query = "SELECT * FROM users WHERE email = %s"
db.execute(query, (email,))
```

### 1.4 A04: Insecure Design
*Detection patterns:*
- Missing rate limiting on authentication endpoints
- No account lockout after failed attempts
- Missing input validation at the architectural level
- Trusting client-side validation only
- No security requirements in design documents

### 1.5 A05: Security Misconfiguration
*Detection patterns:*
- Debug mode enabled in production
- Default credentials unchanged
- Directory listing enabled on web server
- Stack traces exposed in error responses
- Permissive CORS (`Access-Control-Allow-Origin: *`)
- Unnecessary open ports

### 1.6 A06: Vulnerable and Outdated Components
*Detection patterns:*
- Dependencies with known CVEs
- Outdated framework versions
- Unmaintained libraries
- Container images with known vulnerabilities

### 1.7 A07: Identification and Authentication Failures
*Detection patterns:*
- Weak password policies
- No MFA for privileged accounts
- Session fixation vulnerabilities
- Insecure session token generation
- Missing session expiration
- Credential stuffing vulnerability (no rate limit)

### 1.8 A08: Software and Data Integrity Failures
*Detection patterns:*
- Unsigned software updates
- Unsigned CI/CD artifacts
- Missing SBOM (Software Bill of Materials)
- Dependency confusion (using public packages with same name as internal)
- Insecure CI/CD pipeline configurations

### 1.9 A09: Security Logging and Monitoring Failures
*Detection patterns:*
- No audit logging for sensitive operations
- Logging sensitive data (passwords, PII, tokens)
- No log monitoring/alerting
- Log injection in log files
- Insufficient retention of security logs

### 1.10 A10: Server-Side Request Forgery (SSRF)
*Detection patterns:*
- User-controlled URLs passed to HTTP libraries
- Missing allowlist of permitted URLs
- Access to internal metadata endpoints (169.254.169.254)
- DNS rebinding vulnerability

```python
# VULNERABLE: User controls URL
response = requests.get(user_input_url)

# FIXED: URL allowlist
ALLOWED_DOMAINS = ["api.trusted-service.com", "cdn.example.com"]
parsed = urlparse(user_input_url)
if parsed.netloc not in ALLOWED_DOMAINS:
    raise ValueError("URL not allowed")
response = requests.get(user_input_url)
```

---

## 2. Dependency Vulnerability Checking

### 2.1 Scanning Commands
```bash
# Python
pip-audit --requirement requirements.txt --format json
pip-audit --requirement requirements.txt --fix   # Auto-fix if available

# Node/JavaScript
npm audit --json
npm audit fix

# Container images
grype myimage:latest --output json
trivy image --severity CRITICAL,HIGH myimage:latest

# Generic SBOM
grype dir:. --output json
syft . -o spdx-json > sbom.json

# Ruby
bundle audit check --update

# Go
govulncheck ./...
```

### 2.2 CVE Severity Classification
| Severity | CVSS Range | Action | SLA |
|---|---|---|---|
| Critical | 9.0-10.0 | Immediate patch | 24 hours |
| High | 7.0-8.9 | Urgent fix | 7 days |
| Medium | 4.0-6.9 | Scheduled fix | 30 days |
| Low | 0.1-3.9 | Monitor | Next release |

### 2.3 Dependency Audit Report Template
```markdown
# Dependency Audit Report
**Date**: {date}
**Project**: {project_name}
**Tool**: {tool_used}

## Summary
- Total dependencies: {total}
- Vulnerable: {vulnerable_count}
- Critical: {critical_count}
- High: {high_count}
- Medium: {medium_count}
- Low: {low_count}

## Critical Findings
| Package | Version | CVE | Severity | Fix Version | Action |
|---|---|---|---|---|---|
| example-lib | 1.2.3 | CVE-2026-1234 | Critical | 1.2.4 | Upgrade now |

## Remediation Steps
1. `pip install example-lib==1.2.4`
2. Run full test suite
3. Deploy to staging
4. Monitor for regressions
```

---

## 3. Secret Detection

### 3.1 Patterns to Detect
```yaml
secrets:
  - name: AWS Access Key
    pattern: "AKIA[0-9A-Z]{16}"
    entropy_min: 25

  - name: GitHub Token
    pattern: "(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{36,}"
    entropy_min: 35

  - name: Generic API Key
    pattern: "(?:api[_-]?key|apikey|secret[_-]?key|secret_key)[\"']?\\s*[:=]\\s*[\"']([A-Za-z0-9+/=_-]{16,})[\"']"
    entropy_min: 30

  - name: Private Key
    pattern: "-----BEGIN (?:RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----"
    entropy_min: 40

  - name: JWT Token
    pattern: "eyJ[A-Za-z0-9_-]{10,}\\.[A-Za-z0-9_-]{10,}\\.[A-Za-z0-9_-]{10,}"

  - name: Password in Code
    pattern: "(password|passwd|pwd)[\"']?\\s*[:=]\\s*[\"']([^\"']{8,})[\"']"
    entropy_min: 25

  - name: Connection String
    pattern: "(mongodb|postgresql|mysql|redis)://[^\\s]+"
```

### 3.2 Scanning Tools
```bash
# TruffleHog — scan git history
trufflehog git https://github.com/org/repo.git --json --only-verified

# Gitleaks — scan repository
gitleaks detect --source . --verbose

# Detect Secrets — YAML-based config
detect-secrets scan --baseline .secrets.baseline

# Git Secrets
git secrets --scan

# Custom regex scanning (ripgrep)
rg -i '(api.?key|secret.?key|password|token)\s*[=:]\s*["'"'"'][^"'"'"']+' --json
```

### 3.3 Secret Remediation
1. **Rotate immediately**: Revoke the exposed secret
2. **Audit usage**: Check logs for unauthorized access
3. **Remove from git**: Use `git-filter-repo` or BFG Repo-Cleaner
4. **Add to `.gitignore`/`.secrets.baseline`**: Prevent re-exposure
5. **Use a secrets manager**: HashiCorp Vault, AWS Secrets Manager, Azure Key Vault

---

## 4. Input Validation Patterns

### 4.1 Validation Categories
| Type | Example | Validation |
|---|---|---|
| Numeric | Age, ID | Type check, range, min/max |
| String | Name, email | Length, charset, regex |
| Boolean | is_active | Type check only |
| Enum | Status | Allowlist of values |
| Date/Time | created_at | Format, range, timezone |
| File | Upload | Size, mime type, content scan |
| URL | avatar_url | Scheme, domain allowlist, format |
| JSON | metadata | Schema validation |

### 4.2 Validation Code Pattern
```python
from pydantic import BaseModel, EmailStr, Field, validator
from typing import Optional

class CreateUserRequest(BaseModel):
    email: EmailStr
    name: str = Field(..., min_length=1, max_length=100, pattern=r"^[a-zA-Z0-9_ ]+$")
    age: int = Field(..., ge=18, le=120)
    role: str = Field(default="user")
    website: Optional[str] = None

    @validator("role")
    def validate_role(cls, v):
        allowed = ["user", "admin", "moderator"]
        if v not in allowed:
            raise ValueError(f"Role must be one of {allowed}")
        return v

    @validator("website")
    def validate_url(cls, v):
        if v and not v.startswith(("https://", "http://")):
            raise ValueError("Website must start with http:// or https://")
        return v
```

### 4.3 Input Validation Checklist
- [ ] All input from untrusted sources validated (query params, body, headers, cookies)
- [ ] Allowlist validation (reject unknown) preferred over denylist
- [ ] Length limits on all string inputs
- [ ] Type checking on numeric inputs
- [ ] Schema validation for JSON/XML inputs
- [ ] File upload: size limit, type validation, content scanning
- [ ] URL validation: scheme, domain, no internal IPs
- [ ] SQL/path injection prevented via parameterization
- [ ] XSS prevented via output encoding
- [ ] Input normalization (Unicode, encoding)

---

## 5. Authentication & Authorization Review

### 5.1 Authentication Audit Checklist
- [ ] Password minimum length (12+ characters)
- [ ] Password complexity requirements
- [ ] Account lockout after 5 failed attempts
- [ ] Rate limiting on login endpoint
- [ ] MFA available and enforced for admin roles
- [ ] Session timeout (idle: 15-30 min, absolute: 24h)
- [ ] Secure session cookie: HttpOnly, Secure, SameSite=Strict
- [ ] JWT: short expiry (15 min), refresh token rotation
- [ ] No sensitive data in session/JWT payload
- [ ] Password reset: secure token, timeout, notification
- [ ] Credential hashing: bcrypt, argon2, scrypt (not MD5/SHA1)
- [ ] Brute force protection on all auth endpoints

### 5.2 Authorization Audit Checklist
- [ ] Principle of least privilege enforced
- [ ] Role-based (RBAC) or attribute-based (ABAC) access control
- [ ] Every endpoint checks authorization, not just authentication
- [ ] No direct object reference (IDOR) vulnerabilities
- [ ] Admin operations require elevated permissions
- [ ] CORS policy restrictive, not wildcard for sensitive endpoints
- [ ] API keys have scoped permissions
- [ ] Rate limiting per user, not per IP
- [ ] Authorization checks on the server side, never trust client

### 5.3 RBAC Implementation Pattern
```python
# decorator-based authorization
from functools import wraps
from flask import abort, g

def require_role(role):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if not hasattr(g, 'current_user'):
                abort(401)
            if role not in g.current_user.roles:
                abort(403)
            return f(*args, **kwargs)
        return decorated_function
    return decorator

# Usage
@app.route("/api/admin/users")
@require_auth
@require_role("admin")
def list_users_admin():
    ...
```

---

## 6. Secure Coding Guidelines

### 6.1 Python
```python
# Secure imports — avoid exec/eval
# VULNERABLE
result = eval(user_input)

# SAFE
import ast
result = ast.literal_eval(safe_input)

# Secure subprocess — no shell=True
# VULNERABLE
subprocess.call(f"ls -la {user_path}", shell=True)

# SAFE
subprocess.call(["ls", "-la", user_path])

# Secure random numbers
# VULNERABLE
import random
token = ''.join(random.choices(string.ascii_letters, k=32))

# SAFE
import secrets
token = secrets.token_hex(32)

# Secure file paths
# VULNERABLE
with open(f"/app/data/{user_filename}") as f: ...

# SAFE
import os
base = "/app/data"
safe_path = os.path.normpath(os.path.join(base, user_filename))
if not safe_path.startswith(base):
    raise ValueError("Path traversal detected")
```

### 6.2 Web Applications
```python
# CSRF protection
# VULNERABLE
@app.route("/api/transfer", methods=["POST"])
def transfer():
    # No CSRF token check
    ...

# SAFE
@app.route("/api/transfer", methods=["POST"])
@require_csrf_token
def transfer():
    ...

# Clickjacking protection — headers
response.headers["X-Frame-Options"] = "DENY"
response.headers["Content-Security-Policy"] = "frame-ancestors 'none'"

# Content-Type sniffing prevention
response.headers["X-Content-Type-Options"] = "nosniff"

# HSTS
response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
```

### 6.3 Infrastructure
```yaml
# Docker: Don't run as root
USER nobody

# Kubernetes: Security context
securityContext:
  runAsNonRoot: true
  runAsUser: 1001
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop:
      - ALL

# Network policies: default deny
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
```

---

## 7. Security Checklist (Full Audit)

### 7.1 Application Security
- [ ] OWASP Top 10 items reviewed
- [ ] SQL injection: parameterized queries everywhere
- [ ] XSS: output encoding, CSP headers
- [ ] CSRF: tokens on state-changing operations
- [ ] SSRF: URL allowlisting
- [ ] XXE: XML parser configured to disable external entities
- [ ] Insecure deserialization: avoid pickle, use safe formats
- [ ] File upload: validation, scanning, storage outside web root
- [ ] IDOR: ownership checks on all resources
- [ ] Auth: rate limiting, lockout, MFA
- [ ] Session: HttpOnly, Secure, SameSite cookies, short expiry

### 7.2 Code Security
- [ ] No secrets in code (API keys, passwords, tokens)
- [ ] No debug mode in production
- [ ] No stack traces exposed to clients
- [ ] Proper error handling (don't leak info)
- [ ] Input validation on all entry points
- [ ] Output encoding for all user-generated content
- [ ] Safe file operations (path traversal prevention)

### 7.3 Dependency Security
- [ ] Pip/NPM audit run and clean
- [ ] Container image scanned (grype/trivy)
- [ ] Known CVEs patched or mitigated
- [ ] SBOM generated and stored
- [ ] Unused dependencies removed

### 7.4 Infrastructure Security
- [ ] TLS/HTTPS enforced
- [ ] CORS configured restrictively
- [ ] Security headers present (HSTS, CSP, XFO, etc.)
- [ ] Rate limiting configured
- [ ] API gateway/WAF in place
- [ ] Audit logging enabled
- [ ] Secrets manager used (no env file secrets)
- [ ] Principle of least privilege for service accounts
- [ ] Read-only filesystem for containers where possible

### 7.5 Incident Response
- [ ] Logging of security events
- [ ] Alerting on suspicious activity
- [ ] Incident response plan documented
- [ ] Secrets rotation process defined
- [ ] Backup and restore procedures tested
