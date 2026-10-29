---
name: doc-generator
title: Doc Generator
version: 1.0.0
description: AI agent skill for documentation generation — code extraction, READMEs, API docs, architectural docs, changelogs, docstrings, and diagrams.
author: Agent Skill Pack v2
tags: [documentation, readme, openapi, sphinx, mermaid, changelog]
os: [linux, macos, windows]
tools: [python, sphinx, pydoc, typedoc, mermaid-cli, pandoc]
---

# Doc Generator Skill

## Overview

This skill provides agents with structured methodologies for generating comprehensive documentation from code, specifications, and architectural analysis. It covers README generation, API documentation, architectural documentation, changelog generation, docstring standards, and diagram generation.

---

## 1. Code Documentation Extraction

### 1.1 Automated Extraction Tools
| Language | Tool | Command |
|---|---|---|
| Python | pydoc | `python -m pydoc -p 8080` |
| Python | Sphinx autodoc | `sphinx-apidoc -o docs/source src/` |
| JavaScript/TS | TypeDoc | `typedoc --out docs src/` |
| Java | Javadoc | `javadoc -d docs src/**/*.java` |
| Go | godoc | `godoc -http=:8080` |
| Rust | rustdoc | `cargo doc --no-deps` |
| Ruby | YARD | `yard doc --output-dir docs` |

### 1.2 Sphinx autodoc Example
```python
# conf.py
extensions = [
    "sphinx.ext.autodoc",
    "sphinx.ext.napoleon",  # Google/NumPy style support
    "sphinx.ext.viewcode",
    "sphinx.ext.autosummary",
    "sphinx_autodoc_typehints",
]

# Generate API docs
# sphinx-apidoc -o docs/source src/my_package -f -e
# sphinx-build -b html docs/source docs/build
```

### 1.3 Docstring Extraction Pattern
```python
"""
Extract docstrings from Python source files for documentation generation.
"""
import ast
import os
from dataclasses import dataclass

@dataclass
class DocumentationNode:
    name: str
    type: str  # module, class, function, method
    docstring: str
    signature: str
    children: list
    source_file: str
    lineno: int

def extract_docstrings(filepath):
    """Parse a Python file and extract structured documentation."""
    with open(filepath) as f:
        tree = ast.parse(f.read())

    nodes = []
    for node in ast.walk(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            nodes.append(DocumentationNode(
                name=node.name,
                type="async_function" if isinstance(node, ast.AsyncFunctionDef) else "function",
                docstring=ast.get_docstring(node) or "",
                signature=_get_signature(node),
                children=[],
                source_file=filepath,
                lineno=node.lineno,
            ))
        elif isinstance(node, ast.ClassDef):
            members = []
            for item in node.body:
                if isinstance(item, (ast.FunctionDef, ast.AsyncFunctionDef)):
                    members.append(DocumentationNode(
                        name=item.name,
                        type="method",
                        docstring=ast.get_docstring(item) or "",
                        signature=_get_signature(item),
                        children=[],
                        source_file=filepath,
                        lineno=item.lineno,
                    ))
            nodes.append(DocumentationNode(
                name=node.name,
                type="class",
                docstring=ast.get_docstring(node) or "",
                signature="",
                children=members,
                source_file=filepath,
                lineno=node.lineno,
            ))
    return nodes
```

---

## 2. README Generation

### 2.1 README Template
```markdown
# {project_name}

## Overview
{one_paragraph_description_of_what_the_project_does_and_why_it_exists}

## Features
- {feature_1}
- {feature_2}
- {feature_3}

## Quick Start

### Prerequisites
- {requirement_1} (version {min_version})
- {requirement_2}

### Installation
```bash
# Clone the repository
git clone https://github.com/{org}/{repo}.git
cd {repo}

# Set up environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Install the package in development mode
pip install -e .
```

### Configuration
Create a `.env` file in the project root:
```env
DATABASE_URL=postgresql://user:pass@localhost:5432/dbname
API_KEY=your_api_key_here
LOG_LEVEL=info
```

### Running
```bash
# Start the application
python src/main.py

# Run with specific config
python src/main.py --config prod.yaml
```

## Usage

### Basic Example
```python
from my_package import Client

client = Client(api_key="your_key")
result = client.process(data={"key": "value"})
print(result)
```

### CLI Usage
```bash
# Full help
my-tool --help

# Process a file
my-tool process input.csv --output results.json

# Batch mode
my-tool batch --input-dir ./data/ --recursive
```

## API Reference
{link_to_api_documentation_or_generated_docs}

## Architecture
{link_to_architecture_documentation}

## Testing
```bash
# Run unit tests
pytest tests/unit/

# Run integration tests
pytest tests/integration/

# Run with coverage
pytest --cov=src tests/ --cov-report=html
```

## Contributing
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit changes: `git commit -am 'Add my feature'`
4. Push: `git push origin feature/my-feature`
5. Open a Pull Request

### Development Setup
```bash
# Install dev dependencies
pip install -r requirements-dev.txt

# Install pre-commit hooks
pre-commit install

# Run linter
ruff check src/ tests/

# Run formatter
ruff format src/ tests/
```

## License
{license_name}. See [LICENSE](LICENSE) for details.

## Support
- 📖 [Documentation]({docs_url})
- 🐛 [Issue Tracker]({issues_url})
- 💬 [Discussions]({discussions_url})
```

---

## 3. API Documentation (OpenAPI/Sphinx)

### 3.1 OpenAPI 3.0 Doc Template
```yaml
openapi: "3.0.3"
info:
  title: "{api_name}"
  description: |
    {api_description}

    ## Authentication
    {auth_description}

    ## Rate Limiting
    {rate_limit_description}

    ## Pagination
    {pagination_description}
  version: "{api_version}"
  contact:
    name: "{team_name}"
    email: "{team_email}"
  license:
    name: "{license_name}"
    url: "{license_url}"

servers:
  - url: "https://{production_url}/{base_path}"
    description: "Production"
  - url: "https://{staging_url}/{base_path}"
    description: "Staging"

tags:
  - name: "{resource_name}"
    description: "Endpoints for managing {resource_name}"
  - name: "Health"
    description: "Health check and monitoring endpoints"

paths:
  # (see api-designer.skill.md for full endpoint templates)

components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: "Obtain token from POST /auth/login"

  schemas:
    # (define your data models here)

  responses:
    NotFound:
      description: "Resource not found"
      content:
        application/json:
          schema:
            type: object
            properties:
              error:
                type: object
                properties:
                  code:
                    type: string
                    example: "NOT_FOUND"
                  message:
                    type: string
                    example: "The requested resource was not found"
                  request_id:
                    type: string

    ValidationError:
      description: "Validation error"
      content:
        application/json:
          schema:
            type: object
            properties:
              error:
                type: object
                properties:
                  code:
                    type: string
                    example: "VALIDATION_ERROR"
                  message:
                    type: string
                  details:
                    type: object
                    properties:
                      fields:
                        type: array
                        items:
                          type: object
                          properties:
                            field:
                              type: string
                            reason:
                              type: string
```

### 3.2 OpenAPI Generation Script
```python
"""
Generate OpenAPI spec from Python type annotations using Pydantic + FastAPI introspection,
or from a declarative schema definition.
"""
from typing import Optional, List
from pydantic import BaseModel, Field
import json

class OpenAPIGenerator:
    def __init__(self, title="API", version="1.0.0", description=""):
        self.spec = {
            "openapi": "3.0.3",
            "info": {
                "title": title,
                "version": version,
                "description": description,
            },
            "paths": {},
            "components": {
                "schemas": {},
                "responses": {},
            },
        }

    def add_model(self, name: str, model: BaseModel):
        """Add a Pydantic model as an OpenAPI schema."""
        schema = model.model_json_schema()
        self.spec["components"]["schemas"][name] = schema

    def add_endpoint(self, path: str, method: str, summary: str,
                     request_model: Optional[BaseModel] = None,
                     response_model: Optional[BaseModel] = None,
                     tags: Optional[List[str]] = None):
        """Add an endpoint to the spec."""
        endpoint = {
            "summary": summary,
            "responses": {
                "200": {
                    "description": "Success",
                    "content": {}
                }
            }
        }
        if tags:
            endpoint["tags"] = tags

        if request_model:
            schema_name = request_model.__name__
            self.add_model(schema_name, request_model)
            endpoint["requestBody"] = {
                "required": True,
                "content": {
                    "application/json": {
                        "schema": {"$ref": f"#/components/schemas/{schema_name}"}
                    }
                }
            }

        if response_model:
            schema_name = response_model.__name__
            self.add_model(schema_name, response_model)
            endpoint["responses"]["200"]["content"] = {
                "application/json": {
                    "schema": {"$ref": f"#/components/schemas/{schema_name}"}
                }
            }

        if path not in self.spec["paths"]:
            self.spec["paths"][path] = {}
        self.spec["paths"][path][method.lower()] = endpoint

    def generate(self, output_path: str = "openapi.json"):
        """Write the spec to a file."""
        with open(output_path, "w") as f:
            json.dump(self.spec, f, indent=2)
        return output_path
```

---

## 4. Architectural Documentation

### 4.1 Architecture Decision Record (ADR) Template
```markdown
# ADR-{number}: {title}

## Status
[Proposed | Accepted | Deprecated | Superseded]

## Context
{Describe the problem, constraints, and forces at play.}

## Decision
{Describe the decision made and the reasoning behind it.}

## Consequences
### Positive
- {benefit_1}
- {benefit_2}

### Negative
- {tradeoff_1}
- {tradeoff_2}

## Alternatives Considered
1. **Alternative A**: {description} — Rejected because {reason}
2. **Alternative B**: {description} — Rejected because {reason}

## Related Decisions
- ADR-{n}: {related_decision_title}
```

### 4.2 System Architecture Document Template
```markdown
# {System Name} — Architecture Document

## 1. Overview
{High-level description of the system, its purpose, and scope.}

## 2. Architecture Principles
- {principle_1}
- {principle_2}
- {principle_3}

## 3. System Context Diagram
```mermaid
graph TB
    User((User))
    System[{System Name}]
    ExternalAPI[(External API)]
    Database[(Database)]

    User -->|HTTP| System
    System -->|REST| ExternalAPI
    System -->|SQL| Database
```

## 4. Component Architecture
```mermaid
graph TD
    subgraph "API Layer"
        Gateway[API Gateway]
        Auth[Auth Service]
    end
    subgraph "Application Layer"
        Service1[Service 1]
        Service2[Service 2]
    end
    subgraph "Data Layer"
        DB1[(Primary DB)]
        DB2[(Cache)]
    end

    Gateway --> Auth
    Gateway --> Service1
    Gateway --> Service2
    Service1 --> DB1
    Service1 --> DB2
    Service2 --> DB1
```

## 5. Data Flow
{Description of major data flows through the system.}

### Flow 1: User Authentication
```mermaid
sequenceDiagram
    participant U as User
    participant G as Gateway
    participant A as Auth Service
    participant D as Database

    U->>G: POST /auth/login
    G->>A: Validate credentials
    A->>D: Query user
    D-->>A: User record
    A->>A: Generate JWT
    A-->>G: Token response
    G-->>U: 200 OK + JWT
```

## 6. Deployment Architecture
```mermaid
graph LR
    subgraph "Production"
        LB[Load Balancer]
        App1[App Instance 1]
        App2[App Instance 2]
        DB_Primary[(Primary DB)]
        DB_Replica[(Read Replica)]
    end

    LB --> App1
    LB --> App2
    App1 --> DB_Primary
    App2 --> DB_Primary
    App1 --> DB_Replica
    App2 --> DB_Replica
```

## 7. Security Architecture
- Authentication: {method}
- Authorization: {method}
- Data encryption: {details}
- Network security: {details}

## 8. Monitoring & Observability
- Logging: {tool}
- Metrics: {tool}
- Tracing: {tool}
- Alerting: {tool}

## 9. Performance Characteristics
- Expected throughput: {rps}
- Latency targets: {ms}
- Scaling strategy: {horizontal/vertical/auto}
```

---

## 5. Changelog Generation

### 5.1 Keep a Changelog Format
```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- {new_feature_1}
- {new_feature_2}

### Changed
- {change_1}

### Deprecated
- {old_feature} — will be removed in v{next_version}

### Removed
- {removed_feature}

### Fixed
- {bug_fix_1}
- {bug_fix_2}

### Security
- {security_fix_1}

## [1.2.0] — 2026-04-15

### Added
- New pagination support for list endpoints
- Rate limit headers in API responses

### Changed
- Upgraded dependency from {old_version} to {new_version}

### Fixed
- Fixed race condition in order processing (#123)

## [1.1.0] — 2026-03-01

### Added
- User authentication with JWT
- Email notification system

### Changed
- Database schema: added `email_verified` column

## [1.0.0] — 2026-01-15

### Added
- Initial release
- Core CRUD API
- Basic authentication
- PostgreSQL persistence
```

### 5.2 Auto-Generate Changelog from Git
```bash
# Conventional commits format
git log --pretty=format:"* %s (%h)" --since="2026-03-01" --no-merges

# Group by type
echo "## Added"; git log --grep="^feat" --pretty=format:"* %s" --since="2026-03-01"
echo "## Fixed"; git log --grep="^fix" --pretty=format:"* %s" --since="2026-03-01"

# Using git-cliff (structured changelog)
git-cliff --output CHANGELOG.md
# config at cliff.toml
```

### 5.3 git-cliff Configuration
```toml
# cliff.toml
[changelog]
header = "# Changelog\n\n"
template = """
{% for group, commits in commits | group_by(attribute="group") %}
### {{ group | upper_first }}
{% for commit in commits %}
- {{ commit.message | upper_first }}\
  {% if commit.breaking %} (breaking){% endif %}\
  {% if commit.scope %} ({{ commit.scope }}){% endif %}
{% endfor %}
{% endfor %}
"""
[git]
conventional_commits = true
filter_unconventional = true
```

---

## 6. Docstring Standards

### 6.1 Google Style
```python
def calculate_metrics(data: pd.DataFrame, confidence: float = 0.95) -> Dict[str, float]:
    """Calculate statistical metrics from input data.

    Computes mean, median, standard deviation, and confidence intervals
    for each numeric column in the provided DataFrame.

    Args:
        data: Input DataFrame containing numeric columns to analyze.
            Must not be empty and must contain at least one numeric column.
        confidence: Confidence level for interval calculation.
            Must be between 0.0 and 1.0. Defaults to 0.95.

    Returns:
        Dictionary mapping metric names to their computed values.
        Keys include 'mean', 'median', 'std', 'ci_lower', 'ci_upper'.

    Raises:
        ValueError: If data is empty or contains no numeric columns.
        TypeError: If confidence is not a float between 0 and 1.

    Example:
        >>> df = pd.DataFrame({'x': [1, 2, 3, 4, 5]})
        >>> calculate_metrics(df, confidence=0.99)
        {'mean': 3.0, 'median': 3.0, 'std': 1.58, 'ci_lower': 0.94, 'ci_upper': 5.06}
    """
    if not isinstance(confidence, float) or not 0 <= confidence <= 1:
        raise TypeError("confidence must be a float between 0 and 1")
    # ... implementation
```

### 6.2 NumPy Style
```python
def calculate_metrics(data, confidence=0.95):
    """Calculate statistical metrics from input data.

    Computes mean, median, standard deviation, and confidence intervals
    for each numeric column in the provided DataFrame.

    Parameters
    ----------
    data : pd.DataFrame
        Input DataFrame containing numeric columns to analyze.
        Must not be empty and must contain at least one numeric column.
    confidence : float, optional
        Confidence level for interval calculation. Must be between 0.0 and 1.0.
        Default is 0.95.

    Returns
    -------
    dict
        Dictionary mapping metric names to their computed values.
        Keys include 'mean', 'median', 'std', 'ci_lower', 'ci_upper'.

    Raises
    ------
    ValueError
        If data is empty or contains no numeric columns.
    TypeError
        If confidence is not a float between 0 and 1.

    Examples
    --------
    >>> df = pd.DataFrame({'x': [1, 2, 3, 4, 5]})
    >>> calculate_metrics(df, confidence=0.99)
    {'mean': 3.0, 'median': 3.0, 'std': 1.58, 'ci_lower': 0.94, 'ci_upper': 5.06}
    """
    pass
```

### 6.3 Sphinx Style
```python
def calculate_metrics(data, confidence=0.95):
    """Calculate statistical metrics from input data.

    Computes mean, median, standard deviation, and confidence intervals
    for each numeric column in the provided DataFrame.

    :param data: Input DataFrame containing numeric columns to analyze.
    :type data: pd.DataFrame
    :param confidence: Confidence level for interval calculation.
        Must be between 0.0 and 1.0.
    :type confidence: float, optional
    :returns: Dictionary mapping metric names to their computed values.
    :rtype: dict
    :raises ValueError: If data is empty or contains no numeric columns.
    :raises TypeError: If confidence is not a float between 0 and 1.

    :example:
    >>> df = pd.DataFrame({'x': [1, 2, 3, 4, 5]})
    >>> calculate_metrics(df, confidence=0.99)
    {'mean': 3.0, 'median': 3.0, 'std': 1.58, 'ci_lower': 0.94, 'ci_upper': 5.06}
    """
    pass
```

---

## 7. Diagram Generation (Mermaid)

### 7.1 Common Diagram Types
```mermaid
graph TD
    A[Start] --> B{Decision}
    B -->|Yes| C[Process]
    B -->|No| D[End]
```

### 7.2 Sequence Diagram
```mermaid
sequenceDiagram
    participant Client
    participant API
    participant DB
    participant Queue

    Client->>API: POST /orders
    API->>DB: Insert order (status=pending)
    DB-->>API: order_id
    API->>Queue: Publish order.created
    API-->>Client: 201 Created
    Queue-->>API: Acknowledge
```

### 7.3 Class Diagram
```mermaid
classDiagram
    class User {
        +int id
        +string email
        +string name
        +get_orders() List[Order]
        +update_profile(data)
    }
    class Order {
        +int id
        +int user_id
        +float total
        +string status
        +calculate_tax() float
    }
    class Product {
        +int id
        +string name
        +float price
        +int stock
    }
    User "1" --> "*" Order
    Order "*" --> "*" Product
```

### 7.4 Entity Relationship Diagram
```mermaid
erDiagram
    User {
        int id PK
        string email UK
        string name
        datetime created_at
    }
    Order {
        int id PK
        int user_id FK
        float total
        string status
        datetime created_at
    }
    OrderItem {
        int id PK
        int order_id FK
        int product_id FK
        int quantity
        float price
    }
    User ||--o{ Order : has
    Order ||--|{ OrderItem : contains
```

### 7.5 State Diagram
```mermaid
stateDiagram-v2
    [*] --> Pending
    Pending --> Processing: Payment received
    Processing --> Shipped: Fulfilled
    Shipped --> Delivered: Confirmed
    Shipped --> Returned: Customer return
    Delivered --> [*]
    Returned --> [*]
    Pending --> Cancelled: Timeout/cancel
    Processing --> Cancelled: Cancel request
```

### 7.6 Flowchart
```mermaid
flowchart LR
    A[Start] --> B[Check input]
    B --> C{Valid?}
    C -->|Yes| D[Process]
    C -->|No| E[Return error]
    D --> F{Retry?}
    F -->|Yes| B
    F -->|No| G[Complete]
    E --> G
```

### 7.7 C4 Model Diagrams
```mermaid
C4Context
    title System Context diagram for Internet Banking System
    Person(customer, "Customer", "A customer of the bank")
    System(banking, "Internet Banking System", "Allows customers to manage their accounts")
    System_Ext(mail, "Email System", "Sends email notifications")
    System_Ext(batch, "Batch Processing", "Processes scheduled transactions")
    Rel(customer, banking, "Uses")
    Rel(banking, mail, "Sends emails")
    Rel(banking, batch, "Triggers batch jobs")
```

### 7.8 Auto-Generation Script
```python
"""
Generate Mermaid diagrams programmatically from data structures.
"""
from typing import List, Dict

class MermaidGenerator:
    def __init__(self):
        self.lines = []

    def graph(self, direction="TD"):
        self.lines.append(f"graph {direction}")
        return self

    def node(self, node_id, label, shape="box"):
        shape_map = {
            "box": f"{node_id}[{label}]",
            "round": f"{node_id}({label})",
            "diamond": f"{node_id}{{{label}}}",
            "stadium": f"{node_id}([{label}])",
            "circle": f"{node_id}(({label}))",
        }
        self.lines.append(f"    {shape_map.get(shape, shape_map['box'])}")
        return self

    def edge(self, from_id, to_id, label=""):
        if label:
            self.lines.append(f"    {from_id} -->|{label}| {to_id}")
        else:
            self.lines.append(f"    {from_id} --> {to_id}")
        return self

    def class_diagram(self, classes: List[Dict]):
        """Generate a class diagram from data structures."""
        self.lines.append("classDiagram")
        for cls in classes:
            self.lines.append(f"    class {cls['name']}{{")
            for attr in cls.get("attributes", []):
                self.lines.append(f"        {'+'+attr['type'] if attr.get('public') else '-'}{attr['name']}")
            for method in cls.get("methods", []):
                params = ", ".join(method.get("params", []))
                self.lines.append(f"        {'+'+method['return_type'] if method.get('public') else '-'}{method['name']}({params})")
            self.lines.append("    }")
        return self

    def render(self):
        return "\n".join(self.lines)

# Example usage
mg = MermaidGenerator()
mg.graph("LR")
mg.node("A", "Start", "stadium")
mg.node("B", "Valid?", "diamond")
mg.node("C", "Process", "round")
mg.node("D", "Error", "round")
mg.node("E", "End", "stadium")
mg.edge("A", "B")
mg.edge("B", "C", "Yes")
mg.edge("B", "D", "No")
mg.edge("C", "E")
mg.edge("D", "E")
print(mg.render())
```

---

## 8. Documentation Workflow

```
1. DISCOVERY
   - Scan codebase for modules, classes, functions
   - Extract existing docstrings
   - Identify undocumented areas
   - Map dependencies and data flows

2. STRUCTURE
   - Create documentation directory structure:
     docs/
     ├── index.md
     ├── getting-started.md
     ├── api/
     │   ├── overview.md
     │   └── endpoints/
     ├── architecture/
     │   ├── overview.md
     │   ├── decisions/ (ADRs)
     │   └── diagrams/
     ├── guides/
     └── changelog.md

3. GENERATE
   - Run doc extraction tools (sphinx-apidoc, typedoc, etc.)
   - Generate README from template
   - Generate OpenAPI spec
   - Generate architecture diagrams (Mermaid)
   - Generate changelog from git history

4. REVIEW
   - Check for completeness (are all public APIs documented?)
   - Check for accuracy (does doc match implementation?)
   - Check for discoverability (is it easy to find?)
   - Check for freshness (are examples up to date?)

5. INTEGRATE
   - Add to CI/CD pipeline (auto-generate on merge)
   - Deploy to documentation hosting (ReadTheDocs, GitHub Pages)
   - Add search functionality
   - Set up automated freshness checks

6. MAINTAIN
   - Update docs alongside code changes (include in PR checklist)
   - Archive outdated documentation
   - Track documentation coverage metrics
   - Solicit feedback from users
```

---

## 9. Documentation Coverage Checklist

- [ ] README.md exists with install, usage, and quick start
- [ ] All public functions have docstrings (Google/NumPy/Sphinx style)
- [ ] All public classes have docstrings with Attributes section
- [ ] All modules have module-level docstrings
- [ ] OpenAPI spec generated and published
- [ ] Architecture document with C4 diagrams
- [ ] ADRs stored in docs/architecture/decisions/
- [ ] CHANGELOG.md follows keepachangelog format
- [ ] CONTRIBUTING.md with development setup
- [ ] LICENSE file present
- [ ] CODE_OF_CONDUCT.md present
- [ ] SECURITY.md with reporting instructions
- [ ] API documentation versioned alongside releases
- [ ] Examples directory with runnable code samples
- [ ] Diagrams auto-generated in CI
- [ ] Documentation build passes without warnings
- [ ] Broken link checker passes
- [ ] Spell-check run on all documentation files
