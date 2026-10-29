---
name: readme-artist
title: readme-artist
description: AI agent skill for creating compelling READMEs, project documentation, and developer onboarding materials
author: agent-skill-pack-v2
version: 1.0.0
tags: [readme, documentation, project-docs, onboarding, seo, open-source]
skill_type: documentation
---

# README Artist Skill

## Overview

Crafting excellent READMEs and project documentation that drives adoption, contributions, and developer satisfaction. Covers structure, design, SEO, automation, and documentation hierarchy.

## 1. README Structure

### The Anatomy of a Great README

```
┌────────────────────────────────────────────────────────────┐
│   1. Badge Bar         [build] [coverage] [license] [version]│
│   2. Project Title     ──────────────────────────────────── │
│   3. Tagline           A one-line description               │
│   4. Hero Image/Screenshot                                  │
│   5. Description       2-3 paragraphs                       │
│   6. Features          Bullet list of key features          │
│   7. Table of Contents (optional, for long READMEs)         │
│   8. Installation      Step-by-step                        │
│   9. Quick Start       Minimal usage example               │
│  10. API / Usage       Detailed documentation              │
│  11. Examples          Real-world usage examples            │
│  12. Configuration     Environment vars, config files       │
│  13. Contributing      How to contribute                   │
│  14. License           MIT, Apache, GPL, etc.              │
│  15. Acknowledgments   Credits, inspiration                │
└────────────────────────────────────────────────────────────┘
```

### Badge Bar

```markdown
<!-- Badge bar — place at the very top of README -->

<div align="center">

# Project Name

[![CI Status](https://github.com/user/repo/actions/workflows/ci.yml/badge.svg)](https://github.com/user/repo/actions)
[![codecov](https://codecov.io/gh/user/repo/branch/main/graph/badge.svg)](https://codecov.io/gh/user/repo)
[![PyPI version](https://badge.fury.io/py/project-name.svg)](https://badge.fury.io/py/project-name)
[![Python Versions](https://img.shields.io/pypi/pyversions/project-name.svg)](https://pypi.org/project/project-name/)
[![License](https://img.shields.io/github/license/user/repo.svg)](https://github.com/user/repo/blob/main/LICENSE)
[![Downloads](https://pepy.tech/badge/project-name)](https://pepy.tech/project/project-name)
[![Code style: ruff](https://img.shields.io/badge/code%20style-ruff-000000.svg)](https://github.com/astral-sh/ruff)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

</div>
```

### Project Title & Tagline

```markdown
<h1 align="center">🌟 Project Name</h1>
<p align="center">
  <em>A powerful, lightweight tool for doing amazing things with minimum effort.</em>
</p>
```

### Full README Template

```markdown
---
<div align="center">

# Awesome Project

[![CI](https://github.com/user/awesome-project/actions/workflows/ci.yml/badge.svg)](https://github.com/user/awesome-project/actions)
[![Coverage](https://codecov.io/gh/user/awesome-project/branch/main/graph/badge.svg)](https://codecov.io/gh/user/awesome-project)
[![PyPI](https://img.shields.io/pypi/v/awesome-project.svg)](https://pypi.org/project/awesome-project/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Do more with less. Awesome Project handles the complexity so you can focus on shipping.**

</div>

## 📖 Description

Awesome Project is a Python library for [specific problem domain]. It solves [specific pain point]
by providing [key benefit]. Unlike [alternatives], Awesome Project focuses on [differentiator].

**Key design principles:**
- **Simplicity** — Minimal API surface, sensible defaults
- **Performance** — Optimized for throughput and low memory
- **Reliability** — Battle-tested in production at [Company]

## ✨ Features

- 🚀 **Blazing fast** — Up to 10x faster than traditional approaches
- 🔒 **Type-safe** — Full type hints, validated at runtime
- 🔌 **Pluggable** — Extensible via custom backends and middleware
- 📦 **Zero dependencies** — Pure Python, no external packages required
- 🧪 **Tested** — 95%+ test coverage, property-based testing
- 📚 **Well documented** — Full API docs, examples, and tutorials

## 📋 Table of Contents

- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [API Reference](#-api-reference)
- [Examples](#-examples)
- [Configuration](#-configuration)
- [Contributing](#-contributing)
- [License](#-license)

## 🔧 Installation

```bash
# Via pip (recommended)
pip install awesome-project

# Via poetry
poetry add awesome-project

# From source
git clone https://github.com/user/awesome-project.git
cd awesome-project
pip install -e .
```

**Requirements:** Python 3.11+

## 🚀 Quick Start

```python
from awesome_project import Client

# Initialize with default configuration
client = Client()

# Do something amazing
result = client.process(data="hello world")
print(result)
# => {"status": "success", "result": "HELLO WORLD"}
```

## 📚 API Reference

### `Client(**options)`

Create a new client instance.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `timeout` | `int` | `30` | Request timeout in seconds |
| `retries` | `int` | `3` | Number of retries on failure |
| `backend` | `str` | `"default"` | Backend implementation to use |

### `client.process(data: str, **kwargs) -> dict`

Process input data and return results.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `str` | Input data to process |
| `format` | `str` | Output format: `"json"`, `"text"`, or `"raw"` |

**Returns:** A dictionary containing `status` and processed `result`.

### `client.batch(items: list[str]) -> list[dict]`

Process multiple items efficiently.

```python
results = client.batch(["item1", "item2", "item3"])
# => [{"status": "success", "result": "ITEM1"}, ...]
```

## 🎯 Examples

### Web Framework Integration

```python
from fastapi import FastAPI
from awesome_project import Client

app = FastAPI()
client = Client()

@app.post("/process")
async def process_endpoint(data: str):
    result = client.process(data)
    return result
```

### CLI Usage

```bash
# Coming soon: awesome-project-cli
# echo "hello" | awesome-project
```

## ⚙️ Configuration

Environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `AWESOME_PROJECT_TIMEOUT` | `30` | Request timeout |
| `AWESOME_PROJECT_LOG_LEVEL` | `INFO` | Logging level |
| `AWESOME_PROJECT_CACHE_SIZE` | `1000` | Max cache entries |

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md).

### Development Setup

```bash
# Clone and install with dev dependencies
git clone https://github.com/user/awesome-project.git
cd awesome-project
pip install -e ".[dev]"

# Run tests
pytest tests/ -v --cov=src/

# Run linter
ruff check src/ tests/

# Type check
mypy src/
```

### Commit Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` new feature
- `fix:` bug fix
- `docs:` documentation changes
- `test:` adding or updating tests
- `refactor:` code restructuring

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Inspiring Library](https://github.com/example) for the initial idea
- [Framework X](https://framework-x.dev) for the plugin architecture pattern
- All [contributors](https://github.com/user/awesome-project/graphs/contributors) who helped shape this project
```

## 2. Project Documentation Hierarchy

```
project-root/
├── README.md                 # Entry point, quick start, badges
├── CONTRIBUTING.md           # How to contribute, code of conduct
├── CHANGELOG.md              # Release history, semantic versioning
├── CODE_OF_CONDUCT.md        # Behavior expectations
├── SECURITY.md               # Vulnerability reporting process
├── LICENSE                   # License text
├── docs/                     # Detailed documentation
│   ├── index.md              # Documentation home
│   ├── getting-started.md    # Installation and first steps
│   ├── guides/               # How-to guides
│   │   ├── basic-usage.md
│   │   ├── advanced-config.md
│   │   └── deployment.md
│   ├── api/                  # API reference (auto-generated)
│   │   ├── client.md
│   │   └── models.md
│   ├── tutorials/            # Learning-oriented content
│   │   └── beginners-tutorial.md
│   ├── explanation/          # Conceptual explanations
│   │   └── architecture.md
│   └── assets/               # Images, diagrams
│       ├── architecture.png
│       └── demo.gif
├── examples/                 # Runnable example code
│   ├── basic.py
│   └── advanced.py
└── .github/
    └── ISSUE_TEMPLATE/       # Issue and PR templates
        ├── bug_report.md
        ├── feature_request.md
        └── pull_request_template.md
```

### Documentation Types (Diátaxis Framework)

| Type | Audience | Purpose | Example |
|------|----------|---------|---------|
| **Tutorials** | Learners | Guide someone through a step-by-step experience | "Build your first app in 5 minutes" |
| **How-to Guides** | Problem solvers | Show how to accomplish a specific task | "How to configure caching" |
| **Reference** | Users | Technical description of the system | "API reference", "CLI flags" |
| **Explanation** | Understanders | Background and context about the system | "Why we chose event-driven architecture" |

## 3. Screenshot / Demo Integration

### Image Handling

```markdown
<!-- Hero screenshot (centered, with alt text for SEO) -->

<p align="center">
  <img src="docs/assets/screenshot.png"
       alt="Awesome Project dashboard showing real-time analytics with charts and data tables"
       width="80%">
  <br>
  <em>Awesome Project dashboard in action</em>
</p>

<!-- Animated demo (GIF or video) -->

<p align="center">
  <img src="docs/assets/demo.gif"
       alt="Animated demo showing the complete workflow from installation to results"
       width="80%">
</p>

<!-- Comparison screenshot (before/after) -->

| Before | After |
|--------|-------|
| ![Legacy UI](docs/assets/legacy-ui.png) | ![New UI](docs/assets/new-ui.png) |
```

### Video Integration

```markdown
<!-- YouTube embed -->
[![Watch the demo](https://img.youtube.com/vi/VIDEO_ID/maxresdefault.jpg)](https://youtu.be/VIDEO_ID)

<!-- Asciinema terminal recording -->
[![Asciicast](https://asciinema.org/a/CAST_ID.svg)](https://asciinema.org/a/CAST_ID)
```

### Best Practices

| Rule | Why |
|------|-----|
| Keep images under 1MB | READMEs load faster, better mobile experience |
| Use descriptive alt text | SEO for GitHub search, accessibility |
| Optimize with `width=80%` | Responsive on all screen sizes |
| Use relative paths | Works in forks, clones, and GitHub Pages |
| Prefer PNG over JPEG for UI | Better text clarity, smaller for UI shots |
| Add captions/em tags | Context for visual content |

## 4. SEO Optimization for GitHub

### GitHub Search Ranking Factors

| Factor | Impact | How to Optimize |
|--------|--------|----------------|
| **README keywords** | High | Include primary keyword in title, first paragraph, and H2 headers |
| **Repository name** | High | Short, descriptive, keyword-rich |
| **Topics** | Medium | Add 5-10 relevant topics in repo settings |
| **Stars/forks** | Medium | Quality code → organic stars |
| **Description** | High | One-line summary with keywords |
| **README length** | Low-Medium | 500-1500 words of substantive content |
| **Active maintenance** | Medium | Regular commits, issue responses |

### SEO Checklist

```
□ Repository name contains primary keyword
□ Description is 1 sentence with keywords (max 120 chars)
□ 5-10 relevant GitHub topics added
□ README title includes primary keyword
□ First paragraph mentions problem domain and key benefit
□ H2 headers use natural language with keywords
□ Alt text on all images (descriptive, keyword-rich)
□ Links to related projects, documentation, and website
□ Badge bar (build, coverage, version, license) for credibility
□ Active issues/pull requests addressed
```

### Topic Tags (GitHub Topics)

```yaml
# Add in GitHub repo Settings > Topics
# Examples for a Python async web framework:
topics:
  - python
  - async
  - web-framework
  - fastapi-alternative
  - http-server
  - asgi
  - open-source
  - api
  - microservices
  - python-web
  - pydantic
```

## 5. Documentation Automation

### Documentation Generators

| Tool | Language | Output | Best For |
|------|----------|--------|----------|
| **MkDocs** | Python | Static site | Project documentation, guides |
| **Sphinx** | Python | Static site + API docs | Python libraries, large projects |
| **Docusaurus** | JS/TS | Static site (React) | Open source project sites |
| **Storybook** | JS/TS | Component library | UI component libraries |
| **Typedoc** | TypeScript | API reference | TypeScript libraries |
| **pydoc** | Python | API reference | Python inline docstrings |

### MkDocs + Material Configuration

```yaml
# mkdocs.yml
site_name: Awesome Project
site_description: A powerful tool for doing amazing things
site_url: https://user.github.io/awesome-project
repo_url: https://github.com/user/awesome-project
repo_name: user/awesome-project

theme:
  name: material
  palette:
    primary: indigo
    accent: indigo
  features:
    - navigation.tabs
    - navigation.sections
    - toc.integrate
    - content.code.copy

plugins:
  - search
  - mkdocstrings:
      handlers:
        python:
          paths: [src]
          options:
            show_source: true
            show_root_heading: true
            docstring_style: google

markdown_extensions:
  - pymdownx.highlight
  - pymdownx.superfences:
      custom_fences:
        - name: mermaid
          class: mermaid
          format: !!python/name:pymdownx.superfences.fence_code_format
  - pymdownx.tabbed:
      alternate_style: true
  - admonition
  - footnotes

nav:
  - Home: index.md
  - Getting Started: getting-started.md
  - User Guide:
      - Basic Usage: guides/basic-usage.md
      - Configuration: guides/configuration.md
  - API Reference: api/
  - Contributing: contributing.md
```

### Automated Doc Building (CI)

```yaml
# .github/workflows/docs.yml
name: Documentation

on:
  push:
    branches: [main]
    paths:
      - 'docs/**'
      - 'mkdocs.yml'
      - 'src/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - run: pip install mkdocs-material mkdocstrings
      - run: mkdocs build --strict
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./site
```

### README Generation from Code

```python
#!/usr/bin/env python3
"""Automatically update README badges and version references."""

import re
import json
from pathlib import Path
from typing import Optional

def update_readme_version(readme_path: Path, new_version: str) -> None:
    """Update version references in README."""
    content = readme_path.read_text()

    # Update shield.io badge version
    content = re.sub(
        r'badge\.fury\.io/py/[^.]+\.[^.]+',
        f'badge.fury.io/py/project-name-{new_version}',
        content
    )

    # Update code snippet version references
    content = re.sub(
        r'(pip install awesome-project==)[\d.]+',
        f'\\g<1>{new_version}',
        content
    )

    readme_path.write_text(content)
    print(f"✅ Updated README to version {new_version}")

def generate_readme_toc(readme_path: Path) -> Optional[str]:
    """Generate or update table of contents."""
    content = readme_path.read_text()

    headings = re.findall(r'^(#{2,3})\s+(.+)$', content, re.MULTILINE)
    if not headings:
        return None

    toc_lines = ["## 📋 Table of Contents\n"]
    for level, title in headings:
        indent = "  " * (len(level) - 2)
        anchor = title.lower().replace(" ", "-").replace("(", "").replace(")", "")
        anchor = re.sub(r'[^a-z0-9-]', '', anchor)
        toc_lines.append(f"{indent}- [{title}](#{anchor})")

    return "\n".join(toc_lines)

# Usage
# update_readme_version(Path("README.md"), "2.0.0")
```

## References

- [Diátaxis documentation framework](https://diataxis.fr/)
- [MkDocs Material](https://squidfunk.github.io/mkdocs-material/)
- [GitHub README best practices](https://github.com/othneildrew/Best-README-Template)
- [Shields.io badges](https://shields.io/)
- [Conventional Commits](https://www.conventionalcommits.org/)
