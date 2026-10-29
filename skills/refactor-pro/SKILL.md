---
name: refactor-pro
description: AI agent skill for code refactoring with smell detection and proven refactoring patterns
version: 1.0.0
author: Agent Skill Pack
tags: [refactoring, code-quality, patterns]
---

# 🔧 Refactor Pro Skill

## Purpose
Systematically identify code smells and apply proven refactoring patterns to improve code quality, maintainability, and performance without changing behavior.

## Activation
When asked to refactor code, analyze it for smells first, then apply appropriate refactoring patterns.

---

## Code Smell Detection (30+ Smells)

### 🔴 Bloaters (Too Much Code)

| Smell | Symptoms | Refactoring |
|-------|----------|-------------|
| **Long Method** | >50 lines, multiple responsibilities | Extract Method, Decompose Conditional |
| **Large Class** | >300 lines, >10 methods | Extract Class, Extract Subclass |
| **Primitive Obsession** | Using strings/ints instead of objects | Replace Primitive with Object, Introduce Parameter Object |
| **Long Parameter List** | >4 parameters | Introduce Parameter Object, Preserve Whole Object |
| **Data Clumps** | Same 3+ fields appearing together | Extract Class, Introduce Parameter Object |

### 🟠 Object-Orientation Abusers

| Smell | Symptoms | Refactoring |
|-------|----------|-------------|
| **Switch Statements** | Type-based switch/case | Replace Conditional with Polymorphism |
| **Temporary Field** | Field only set in some code paths | Extract Class, Introduce Null Object |
| **Refused Bequest** | Subclass doesn't use inherited methods | Replace Inheritance with Delegation |
| **Alternative Classes** | Different interfaces, same purpose | Unify Interfaces, Extract Superclass |

### 🟡 Change Preventers

| Smell | Symptoms | Refactoring |
|-------|----------|-------------|
| **Divergent Change** | One class changed for multiple reasons | Extract Class |
| **Shotgun Surgery** | One change requires edits everywhere | Move Method, Move Field, Inline Class |
| **Parallel Inheritance** | Adding a subclass means adding more | Move Method, Move Field |
| **Feature Envy** | Method uses another class more than its own | Move Method |

### 🔵 Dispensables (Unnecessary Code)

| Smell | Symptoms | Refactoring |
|-------|----------|-------------|
| **Comments** | Code explained instead of self-documenting | Extract Method, Rename, Decompose Conditional |
| **Duplicate Code** | Same logic in multiple places | Extract Method, Pull Up Method, Form Template Method |
| **Lazy Class** | Class that doesn't do enough | Inline Class, Collapse Hierarchy |
| **Data Class** | Only fields + getters/setters | Move Method, Encapsulate Field |
| **Dead Code** | Never executed | Remove dead code (source control has it) |
| **Speculative Generality** | Hooks for features never built | Remove unused abstractions |

### 🟣 Couplers

| Smell | Symptoms | Refactoring |
|-------|----------|-------------|
| **Inappropriate Intimacy** | Classes too familiar with each other | Move Method, Change Bidirectional to Unidirectional |
| **Message Chains** | `a.getB().getC().getD().do()` | Hide Delegate, Extract Method |
| **Middle Man** | Class just delegates to another | Remove Middle Man, Inline |
| **Indirect Communication** | Classes talk through intermediaries | introduce Direct Communication |

---

## Refactoring Patterns

### Extract Method
```python
# BEFORE
def process_order(order):
    # Validate
    if not order.items:
        raise ValueError("Empty order")
    if order.total <= 0:
        raise ValueError("Invalid total")
    
    # Process payment
    result = payment_processor.charge(order.customer, order.total)
    
    # Send confirmation
    email_service.send(order.customer.email, "Order confirmed", f"Total: ${order.total}")
    
    # Update inventory
    for item in order.items:
        inventory.decrement(item.product_id, item.quantity)
    
    return result

# AFTER
def process_order(order):
    _validate(order)
    payment = _process_payment(order)
    _send_confirmation(order)
    _update_inventory(order)
    return payment

def _validate(order):
    if not order.items:
        raise ValueError("Empty order")
    if order.total <= 0:
        raise ValueError("Invalid total")

def _process_payment(order):
    return payment_processor.charge(order.customer, order.total)

def _send_confirmation(order):
    email_service.send(
        order.customer.email,
        "Order confirmed",
        f"Total: ${order.total}"
    )

def _update_inventory(order):
    for item in order.items:
        inventory.decrement(item.product_id, item.quantity)
```

### Replace Conditional with Polymorphism
```python
# BEFORE
def calculate_shipping(order, method):
    if method == "standard":
        return order.weight * 0.5 + 5
    elif method == "express":
        return order.weight * 1.5 + 10
    elif method == "overnight":
        return order.weight * 3.0 + 20
    elif method == "international":
        return order.weight * 2.0 + 15 + customs_fee(order.value)

# AFTER
from abc import ABC, abstractmethod

class ShippingStrategy(ABC):
    @abstractmethod
    def calculate(self, order) -> float: ...

class StandardShipping(ShippingStrategy):
    def calculate(self, order) -> float:
        return order.weight * 0.5 + 5

class ExpressShipping(ShippingStrategy):
    def calculate(self, order) -> float:
        return order.weight * 1.5 + 10

class OvernightShipping(ShippingStrategy):
    def calculate(self, order) -> float:
        return order.weight * 3.0 + 20

class InternationalShipping(ShippingStrategy):
    def calculate(self, order) -> float:
        return order.weight * 2.0 + 15 + customs_fee(order.value)

# Usage
strategies = {
    "standard": StandardShipping(),
    "express": ExpressShipping(),
    "overnight": OvernightShipping(),
    "international": InternationalShipping(),
}

def calculate_shipping(order, method):
    return strategies[method].calculate(order)
```

### Introduce Parameter Object
```python
# BEFORE
def search_users(name: str, age_min: int, age_max: int, 
                 city: str, country: str, status: str, 
                 sort_by: str, sort_order: str, page: int, limit: int):
    ...

# AFTER
from dataclasses import dataclass
from typing import Optional

@dataclass
class SearchFilters:
    name: Optional[str] = None
    age_min: Optional[int] = None
    age_max: Optional[int] = None
    city: Optional[str] = None
    country: Optional[str] = None
    status: Optional[str] = None

@dataclass
class Pagination:
    page: int = 1
    limit: int = 20
    sort_by: str = "created_at"
    sort_order: str = "desc"

def search_users(filters: SearchFilters, pagination: Pagination):
    ...
```

---

## Incremental Refactoring Workflow

### Before Starting
- [ ] All existing tests pass ✅
- [ ] You understand the current behavior
- [ ] You've identified the specific smells to address

### The Workflow
```
1. Identify smell(s) in the code
2. Choose the smallest refactoring that helps
3. Apply ONE refactoring pattern
4. Run tests → ALL PASS?
   ├── Yes → Commit ("refactor: extract method for validation")
   └── No  → Revert or fix
5. Repeat from step 1 for next smell
6. Done when: code is clearer AND all tests still pass
```

### Output Format
```markdown
## Refactoring Plan

### Target: payment_service.py

| Smell | Location | Refactoring | Difficulty | Risk |
|-------|----------|-------------|------------|------|
| Long Method | `process_payment()` (85 lines) | Extract Method | Easy | Low |
| Duplicate Code | `calculate_fee()` × 3 implementations | Pull Up Method | Easy | Low |
| Primitive Obsession | `status` as string | Introduce Enum | Medium | Medium |
| Large Class | `OrderProcessor` (12 methods) | Extract Class | Medium | Medium |

### Recommended Order
1. Extract Method (first 3 blocks) ✓ 0% risk
2. Pull Up Method ✓ smoke tested
3. Introduce Enum ⚠️ check all status comparisons
4. Extract Class ⚠️ check all OrderProcessor references
```

---

## Refactoring Safety Net

Always ensure these before refactoring:

1. **Good test coverage** — If <60%, add tests first
2. **No partial refactorings** — Each change is complete
3. **Small, frequent commits** — Every 5-10 minutes of work
4. **Feature flags** for high-risk changes
5. **No behavior changes** — Tests must pass identically
