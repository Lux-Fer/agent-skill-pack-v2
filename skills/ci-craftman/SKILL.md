---
name: ci-craftman
title: ci-craftman
description: AI agent skill for CI/CD pipeline design, GitHub Actions, Docker builds, deployment strategies, and release engineering
author: agent-skill-pack-v2
version: 1.0.0
tags: [ci-cd, github-actions, docker, deployment, testing, devops]
skill_type: automation
---

# CI Craftman Skill

## Overview

End-to-end CI/CD pipeline design, from commit to production. Covers GitHub Actions, Docker multi-stage builds, test automation, deployment pipelines, environment management, and secrets handling.

## 1. GitHub Actions Workflow Design

### Core Workflow Patterns

```yaml
# .github/workflows/ci.yml — Standard CI workflow
name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  PYTHON_VERSION: '3.12'
  NODE_VERSION: '20'

jobs:
  # ── Quality Gates ──
  lint:
    name: Lint & Format
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
      - run: pip install ruff mypy
      - run: ruff check .
      - run: mypy src/

  test:
    name: Tests
    needs: [lint]
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ['3.11', '3.12']
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_DB: testdb
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
        ports:
          - 5432:5432
      redis:
        image: redis:7-alpine
        ports:
          - 6379:6379

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
          cache: 'pip'
      - run: pip install -r requirements-dev.txt
      - run: pip install -e .
      - run: pytest tests/ --cov=src/ --cov-report=xml --cov-report=term-missing
        env:
          DATABASE_URL: postgresql://test:test@localhost:5432/testdb
          REDIS_URL: redis://localhost:6379/0
      - uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml

  security:
    name: Security Scan
    needs: [lint]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
      - run: pip install bandit safety
      - run: bandit -r src/ -f json -o bandit-report.json || true
      - run: safety check -r requirements.txt --full-report || true
      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: security-reports
          path: bandit-report.json

  # ── Build & Docker ──
  build:
    name: Build & Docker
    needs: [test, security]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    permissions:
      contents: read
      packages: write

    steps:
      - uses: actions/checkout@v4
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ghcr.io/${{ github.repository }}
          tags: |
            type=sha,prefix=
            type=ref,event=branch
            type=semver,pattern={{version}}
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### Workflow Organization Patterns

| Pattern | Structure | Best For |
|---------|-----------|----------|
| **Monorepo single workflow** | One `.yml` per repo | Simple projects, one artifact |
| **Matrix workflows** | Strategy matrix across versions/OS | Multi-version/library compatibility |
| **Reusable workflows** | Call `.github/workflows/` from other workflows | Shared CI patterns across repos |
| **Composite actions** | Custom action steps | Encapsulating complex multi-step logic |
| **Dependent jobs** | `needs:` chain with conditionals | Gate-controlled deployment pipelines |

```yaml
# Reusable workflow example — .github/workflows/deploy.yml (called)
# .github/workflows/deploy-app.yml (caller)
name: Deploy Application

on:
  workflow_dispatch:
    inputs:
      environment:
        type: choice
        description: Target environment
        options: [staging, production]
        required: true
      version:
        description: Docker image tag
        required: true

jobs:
  deploy:
    uses: ./.github/workflows/deploy-template.yml
    with:
      environment: ${{ github.event.inputs.environment }}
      image_tag: ${{ github.event.inputs.version }}
    secrets:
      deploy_key: ${{ secrets.DEPLOY_SSH_KEY }}
```

## 2. Docker Multi-Stage Builds

### Production-Optimized Dockerfile

```dockerfile
# ============================================================
# Stage 1: Dependencies
# ============================================================
FROM python:3.12-slim AS builder

WORKDIR /app
COPY requirements.txt .

# Install build dependencies, then Python packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libpq-dev && \
    pip install --user --no-cache-dir -r requirements.txt && \
    apt-get purge -y gcc && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# ============================================================
# Stage 2: Runtime
# ============================================================
FROM python:3.12-slim AS runtime

WORKDIR /app

# Security: non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy only built wheels from builder stage
COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH

# Copy application code last (maximize layer cache hits)
COPY src/ ./src/
COPY alembic/ ./alembic/
COPY alembic.ini .
COPY pyproject.toml .

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

USER appuser
EXPOSE 8000

ENTRYPOINT ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Node.js Multi-Stage

```dockerfile
# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Stage 2: Production
FROM node:20-alpine AS runtime
WORKDIR /app
RUN addgroup -S appuser && adduser -S appuser -G appuser
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
USER appuser
EXPOSE 3000
CMD ["node", "dist/main.js"]
```

### Docker Build Best Practices

| Practice | Why |
|----------|-----|
| Use `.dockerignore` | Exclude .git, node_modules, __pycache__, .env |
| Pin base image tags | `python:3.12-slim` not `python:latest` |
| Multi-stage builds | Separate build tools from runtime |
| Combine apt-get commands | Fewer layers, smaller images |
| Copy order matters | Maximize layer caching: requirements first, code last |
| Non-root user | Security best practice |
| `--no-cache-dir` / `--no-cache` | Reduce image size |
| HEALTHCHECK | Let orchestrators know container health |
| Specific EXPOSE | Document intent, not security |

## 3. Test Automation Strategies

### Test Pyramid

```
         ╱─────╲
       ╱  E2E   ╲        Few — slow, expensive, covers happy paths
      ╱───────────╲
    ╱  Integration  ╲     Medium — covers API, DB, external service contracts
   ╱─────────────────╲
 ╱     Unit Tests       ╲  Many — fast, isolated, covers logic and edge cases
╱─────────────────────────╲
```

### Parallel Execution

```yaml
# pytest-xdist for parallel test execution
# pip install pytest-xdist
# Command: pytest -n auto tests/
# Splits by CPU count, great for unit tests

# Pytest split by timing (pytest-split)
# First run: pytest --store-durations tests/
# Subsequent: pytest --splits 4 --group 1 tests/

# GitHub Actions: parallel matrix
test:
  strategy:
    matrix:
      shard: [1, 2, 3, 4]
  steps:
    - name: Run tests (shard ${{ matrix.shard }})
      run: pytest --shard-id=${{ matrix.shard }} --num-shards=4 tests/
```

### Test Environment Strategies

```python
# pytest fixtures for integration tests
import pytest
import asyncio
from typing import AsyncGenerator
from httpx import AsyncClient, ASGITransport
from myapp.main import app
from myapp.database import get_db, create_tables, drop_tables

@pytest.fixture(scope="session")
def event_loop():
    """Session-scoped event loop for async fixtures."""
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()

@pytest.fixture(autouse=True)
async def setup_database():
    """Fresh database for each test."""
    await create_tables()
    yield
    await drop_tables()

@pytest.fixture
async def client() -> AsyncGenerator[AsyncClient, None]:
    """Test client with dependency overrides."""
    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test"
    ) as client:
        yield client

@pytest.fixture
def sample_user_data() -> dict:
    """Test data factory."""
    return {"email": "test@example.com", "name": "Test User"}

async def test_create_user(client, sample_user_data):
    response = await client.post("/api/v1/users", json=sample_user_data)
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == sample_user_data["email"]
```

## 4. Deployment Pipelines

### Environment Progression

```
                    ┌──────────┐
                    │  Commit   │
                    └────┬─────┘
                         │
                    ┌────▼─────┐
                    │   CI      │  Lint, test, build, scan
                    └────┬─────┘
                         │
                    ┌────▼──────┐
                    │  Staging   │  Deploy, integration tests, smoke tests
                    └────┬──────┘
                         │
                    ┌────▼────────┐
                    │  Canary 5%  │  Monitor metrics, error rates
                    └────┬────────┘
                         │
                    ┌────▼────────┐
                    │  50% Rollout│  Gradual traffic shift
                    └────┬────────┘
                         │
                    ┌────▼────────┐
                    │  Production  │  Full rollout
                    └─────────────┘
```

### Deployment Workflow

```yaml
# .github/workflows/deploy-prod.yml
name: Production Deployment

on:
  workflow_dispatch:
    inputs:
      confirmed:
        description: 'Type "deploy" to confirm production deployment'
        required: true

jobs:
  deploy-staging:
    name: Deploy to Staging
    environment: staging
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to staging
        run: |
          echo "Deploying to staging..."
          # Deploy logic: kubectl, terraform, rsync, etc.

  integration-tests:
    name: Integration Tests
    needs: [deploy-staging]
    runs-on: ubuntu-latest
    steps:
      - name: Run test suite against staging
        run: |
          echo "Running integration tests against staging..."
          # Run tests that require deployed environment

  deploy-canary:
    name: Canary Deploy (5%)
    needs: [integration-tests]
    environment: production
    runs-on: ubuntu-latest
    steps:
      - name: Deploy canary 5%
        run: |
          echo "Deploying to 5% of production traffic..."
          # Update canary deployment, monitor for 5-10 minutes

  promote-50:
    name: Promote to 50%
    needs: [deploy-canary]
    runs-on: ubuntu-latest
    steps:
      - run: echo "Promoting to 50%..."

  promote-100:
    name: Promote to 100%
    needs: [promote-50]
    runs-on: ubuntu-latest
    steps:
      - run: echo "Promoting to 100%..."

  cleanup:
    name: Cleanup
    needs: [promote-100]
    if: always()
    runs-on: ubuntu-latest
    steps:
      - run: echo "Cleaning up old deployment resources..."
```

## 5. Environment Management

### Environment-Specific Configuration

```yaml
# .github/environments.yml (managed via GitHub Environments)
environments:
  development:
    url: dev-api.example.com
    protection_rules:
      - required_reviewers: []
    variables:
      LOG_LEVEL: DEBUG
      API_URL: https://dev-api.example.com

  staging:
    url: staging-api.example.com
    protection_rules:
      - required_reviewers: [team-leads]
    secrets:
      - DATABASE_URL
      - API_KEY
    variables:
      LOG_LEVEL: INFO
      API_URL: https://staging-api.example.com

  production:
    url: api.example.com
    protection_rules:
      - required_reviewers: [senior-engineers]
      - wait_timer: 5  # minutes
    secrets:
      - DATABASE_URL
      - API_KEY
      - STRIPE_SECRET_KEY
    variables:
      LOG_LEVEL: WARNING
      API_URL: https://api.example.com
```

## 6. Secrets Handling

### Best Practices

| Practice | DO | DON'T |
|----------|----|-------|
| Storage | GitHub Secrets, Vault, AWS Secrets Manager | Committing to repo |
| Rotation | Automate key rotation every 90 days | Hard-coding expiry |
| Access | Least privilege, scoped per environment | Sharing across envs |
| Audit | Enable secret scanning on push | Ignoring secret leak alerts |
| Review | Require approval for prod secrets | Single-person access |
| Transit | Always encrypted (TLS 1.3) | Plaintext in logs/errors |

```yaml
# Using secrets in GitHub Actions
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Mask sensitive values in logs
        run: |
          echo "::add-mask::${{ secrets.DATABASE_URL }}"
          echo "::add-mask::${{ secrets.STRIPE_API_KEY }}"

      - name: Use secrets
        run: |
          docker run -e DATABASE_URL="${{ secrets.DATABASE_URL }}" \
                     -e STRIPE_API_KEY="${{ secrets.STRIPE_API_KEY }}" \
                     myapp:latest

      # Never: job.steps[*].env with secrets
      # Wrong: env:
      #          STRIPE_KEY: ${{ secrets.STRIPE_KEY }}
      # Logs would print the env block in debug mode
```

## 7. CI/CD Best Practices

### Pipeline Design Principles

- **Fail fast**: Run fastest checks first (lint → unit → integration → deploy)
- **Deterministic builds**: Same commit = same artifact (git SHA tags, pinned deps)
- **Immutable artifacts**: Build once, promote through environments (no rebuilds)
- **Idempotent deployments**: Re-running deploy is safe (Kubernetes desired state, Terraform)
- **Gates and approvals**: Manual approval for production, automated gates for staging
- **Observability**: Deploy notifications, metrics dashboards, rollback triggers
- **Rollback strategy**: Canary deployments, traffic splitting, blue/green
- **Pipeline as code**: Store in repo, versioned alongside application code

### Common Anti-Patterns

| Anti-Pattern | Problem | Solution |
|---|---|---|
| Building in deploy step | Different artifact per env | Build once, promote artifact |
| Long-running pipelines (> 30 min) | Slow feedback loop | Parallelize, optimize test speed |
| Skipping lint/security | Tech debt accumulation | Enforce quality gates |
| Manual production deploys | Human error risk | Automate with approval gates |
| No rollback plan | Production incidents become critical | Test rollback procedure |
| Secrets in build logs | Security breach | Mask secrets, audit logs |

## References

- [GitHub Actions documentation](https://docs.github.com/en/actions)
- [Docker best practices](https://docs.docker.com/develop/dev-best-practices/)
- [12 Factor App — Build, release, run](https://12factor.net/build-release-run)
- [Trunk Based Development](https://trunkbaseddevelopment.com/)
