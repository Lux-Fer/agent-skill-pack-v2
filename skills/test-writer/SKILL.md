---
name: test-writer
description: AI agent skill for generating high-quality tests including unit, integration, and property-based tests
version: 1.0.0
author: Agent Skill Pack
tags: [testing, pytest, tdd, quality]
---

# 🧪 Test Writer Skill

## Purpose
Generate comprehensive, high-quality tests that catch real bugs — not just achieve coverage numbers. Covers unit tests, integration tests, property-based tests, and end-to-end scenarios.

## Activation
When asked to write tests, use this skill's methodology to produce thorough, maintainable test suites.

---

## Test Generation Methodology

### Phase 1: Understand The Code
1. Read the source code you're testing
2. Identify: inputs, outputs, side effects, dependencies
3. Map the state machine (valid states, transitions)
4. List error conditions and edge cases
5. Note external dependencies (DB, API, filesystem)

### Phase 2: Identify Test Targets
For each function/method, identify:
- **Happy path**: Normal inputs produce expected outputs
- **Edge cases**: Empty, null, boundary, maximum values
- **Error paths**: Invalid inputs, network failures, auth failures
- **State transitions**: Object goes from state A to B correctly
- **Invariants**: Properties that must always hold true

### Phase 3: Write Tests

#### Unit Tests (pytest)
```python
import pytest
from datetime import datetime, timezone
from uuid import uuid4

def test_create_user_success():
    """Happy path: user created with valid data"""
    service = UserService()
    user = service.create_user(
        email="test@example.com",
        name="Test User"
    )
    assert user.id is not None
    assert user.email == "test@example.com"
    assert user.created_at is not None

def test_create_user_duplicate_email():
    """Error path: duplicate email raises"""
    service = UserService()
    service.create_user(email="test@example.com", name="User 1")
    with pytest.raises(DuplicateEmailError):
        service.create_user(email="test@example.com", name="User 2")

def test_create_user_invalid_email():
    """Error path: invalid email raises"""
    service = UserService()
    with pytest.raises(ValidationError):
        service.create_user(email="not-an-email", name="Test")

@pytest.mark.parametrize("email,expected", [
    ("user@example.com", True),
    ("user+tag@example.com", True),
    ("", False),
    ("not-email", False),
    ("a@b.c", True),      # Minimum valid
    ("a" * 254 + "@b.c", False),  # Over max length
])
def test_email_validation(email, expected):
    """Edge cases: various email formats"""
    assert UserService.validate_email(email) == expected
```

#### Fixtures and Mocks
```python
@pytest.fixture
def db_session():
    """In-memory SQLite for test isolation"""
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    session = Session(engine)
    yield session
    session.close()

@pytest.fixture
def user_service(db_session):
    """Service with real database"""
    return UserService(db_session)

@pytest.fixture
def mock_email_service(mocker):
    """Mock external email service"""
    return mocker.patch("app.services.email.send_email")

def test_welcome_email_sent(user_service, mock_email_service):
    """Integration: user creation triggers welcome email"""
    user = user_service.create_user(
        email="test@example.com",
        name="Test"
    )
    mock_email_service.assert_called_once_with(
        to="test@example.com",
        template="welcome",
        context={"name": "Test"}
    )
```

#### Property-Based Testing (Hypothesis)
```python
from hypothesis import given, strategies as st
from hypothesis import assume

@given(st.text(min_size=1, max_size=100))
def test_slug_generation_never_empty(name):
    """Property: slug is always non-empty string"""
    slug = UserService.generate_slug(name)
    assert len(slug) > 0
    assert all(c.isalnum() or c == '-' for c in slug)

@given(st.lists(st.integers()))
def test_sort_stable_under_transformation(items):
    """Property: sorting is idempotent"""
    sorted_once = sorted(items)
    sorted_twice = sorted(sorted_once)
    assert sorted_once == sorted_twice
```

---

## Test Structure Patterns

### Arrange-Act-Assert (AAA)
```python
def test_something():
    # Arrange
    service = UserService()
    data = {"email": "test@example.com", "name": "Test"}
    
    # Act
    result = service.create_user(**data)
    
    # Assert
    assert result.email == data["email"]
```

### Given-When-Then (BDD style)
```python
def test_user_can_login():
    # Given: a registered user
    user = create_user(email="test@example.com", password="SecureP@ss1")
    
    # When: they log in with correct credentials
    session = auth_service.login(email="test@example.com", password="SecureP@ss1")
    
    # Then: they get a valid session token
    assert session.token is not None
    assert session.user_id == user.id
    assert session.expires_at > datetime.now(timezone.utc)
```

### Error Case Template
```python
def test_{function}_{error_condition}():
    """Error path: {description}"""
    # Setup the failure condition
    with pytest.raises({ExpectedError}) as exc_info:
        # Call the function that should fail
        result = function_under_test(bad_input)
    
    # Verify error details
    assert str(exc_info.value) == "Expected error message"
```

---

## Coverage Targets

| Test Type | Minimum Coverage | Purpose |
|-----------|-----------------|---------|
| Unit tests (happy path) | 100% of functions | Core functionality works |
| Unit tests (error paths) | 80% of error branches | Failures handled gracefully |
| Edge cases | 90% of boundary conditions | Off-by-one, null, empty |
| Integration tests | All critical flows | Components work together |
| Property-based | Complex data transforms | Invariants hold |

---

## CI Integration
```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: "3.12" }
      - run: pip install -e ".[dev,test]"
      - run: pytest --cov=src --cov-report=term-missing --cov-fail-under=80
      - run: pytest --random-order --strict-markers
```

---

## Anti-Patterns to Avoid

| Anti-Pattern | Why | Better Approach |
|--------------|-----|-----------------|
| Testing implementation details | Tests break on refactoring | Test behavior, not internals |
| Shared mutable fixtures | Tests depend on each other | Fresh fixtures per test |
| Over-mocking | Tests pass but system fails | Integration tests for critical paths |
| Asserting nothing | False sense of security | Explicit assertions for every expectation |
| Hardcoded test data | Brittle when data changes | Factory patterns / builders |
| Testing only the happy path | Real bugs are in edge cases | Systematic edge case enumeration |
