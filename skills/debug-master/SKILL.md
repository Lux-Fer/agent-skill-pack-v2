---
name: debug-master
description: AI agent skill for systematic 5-step debugging methodology
version: 1.0.0
author: Agent Skill Pack
tags: [debugging, troubleshooting, methodology]
---

# 🐛 Debug Master Skill

## Purpose
Systematically diagnose and fix bugs using a proven 5-step methodology. Eliminate guesswork, reduce time-to-fix by 50%, and prevent recurring bugs.

## Activation
When asked to debug an issue, follow the 5-step methodology below.

---

## The 5-Step Debugging Methodology

### Step 1: Reproduce 🎯
**Goal**: Get a reliable, minimal reproduction of the bug.

- [ ] Can I reproduce it every time? (deterministic)
- [ ] What exact inputs/actions trigger it?
- [ ] What's the exact error message? (copy literally)
- [ ] Does it happen in different environments? (local/staging/prod)
- [ ] Does it happen with different data?
- [ ] What changed recently? (git log, deploy history)

**Output**: A clear, minimal reproduction script or steps.

```
Reproduction: When user uploads a file >5MB with Unicode filename,
  the upload endpoint returns 500 instead of 413.
Steps:
  1. POST /api/upload with multipart form, file="照片-测试-🚀.pdf", size=6MB
  2. Server crashes with: UnicodeEncodeError in save_upload()
```

### Step 2: Isolate 🔍
**Goal**: Find the exact code path and input state causing the failure.

Techniques (pick the fastest applicable):

**Binary Search on History**
```bash
git bisect start
git bisect bad HEAD
git bisect good <last-known-working-commit>
# Git will checkout commits; test each one
```

**Binary Search on Code Path**
Add logging/breakpoints at decision points. If the bug is in a pipeline of 8 steps, check step 4 first — is data correct there? If yes, the bug is in steps 5-8. If no, steps 1-4.

**Reduce Input**
Minimize the failing input until you have the smallest possible reproduction:
- Remove half the data → still fails? Remove another half.
- Strip the file to minimal content → still fails?
- Simplify the user input → still fails?

**Log Analysis**
```python
# Add targeted logging at suspect points
logger.debug(f"Step 3: input={input}, state={state}")

# Or use trace module
python -m trace --trace my_script.py 2>&1 | grep "suspect_module"
```

### Step 3: Identify 🔬
**Goal**: Understand the root cause — not just the symptom.

**Root Cause Categories**:

| Category | Examples | Investigation |
|----------|----------|---------------|
| Logic error | Wrong condition, off-by-one | Code review the failing path |
| Data issue | Null value, encoding, type mismatch | Check actual data at failure point |
| Race condition | Shared state, async timing | Add locks, check order of operations |
| Configuration | Wrong env var, feature flag | Diff configs between working/failing |
| Dependency | Version mismatch, breaking change | Check requirements, update logs |
| Resource exhaustion | Memory, disk, connections | Monitor resource usage during reproduction |
| External service | API change, timeout, rate limit | Check external service status |

**Analysis templates**:

*State diff analysis*:
```
Expected state at line 42:
  user.email = "test@example.com"
  user.status = "active"

Actual state at line 42:
  user.email = None          ← ROOT CAUSE: email not populated
  user.status = "active"
```

*Data flow analysis*:
```
Input → transform_A → transform_B → output
        ✓              ✗              ?
        
Root cause located at transform_B: assumes list is non-empty
```

### Step 4: Fix 🛠️
**Goal**: Apply the minimal change that fixes the root cause.

**Fix Principles**:
1. Fix the root cause, not the symptom
2. One fix per bug (don't add unrelated changes)
3. Add a test that catches this bug (prevent regression)
4. Consider: is this a class of bugs? (fix the pattern, not the instance)

**Fix Template**:
```python
# BEFORE (buggy)
def save_upload(filename: str, content: bytes):
    path = f"/uploads/{filename}"  # BUG: no sanitization
    with open(path, "wb") as f:
        f.write(content)

# AFTER (fixed)
def save_upload(filename: str, content: bytes):
    safe_name = secure_filename(filename)  # Sanitize filename
    path = f"/uploads/{safe_name}"
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "wb") as f:
        f.write(content)

# TEST (prevents regression)
def test_unicode_filename_sanitized():
    result = save_upload("照片-🚀.pdf", b"content")
    assert "../" not in result
    assert result == "/uploads/照片.pdf"
```

### Step 5: Verify ✅
**Goal**: Confirm the fix works and nothing else broke.

- [ ] Original reproduction case now passes
- [ ] All existing tests pass (`pytest` or equivalent)
- [ ] Similar edge cases also work
- [ ] Related features still work (smoke test)
- [ ] Deploy to staging and verify
- [ ] Monitor logs/production after deploy

---

## Common Bug Patterns Cheat Sheet

### Python
| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| `AttributeError: 'NoneType' object has no attribute 'x'` | Function returned None unexpectedly | Check all code paths return a value |
| `KeyError: 'key'` | Dict access without default | Use `.get(key, default)` |
| `ValueError: I/O operation on closed file` | Context manager exited early | Check indentation of `with` block |
| `ImportError: circular import` | Two modules import each other | Move shared types to a third module |
| Mutable default argument | `def f(x=[])` | Use `def f(x=None): x = x or []` |
| Variable captured in lambda | Late binding closure | Use `lambda x=x: x` |

### JavaScript/TypeScript
| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| `undefined is not a function` | Optional chaining needed | Use `obj?.method?.()` |
| `Cannot read property 'x' of undefined` | Object not yet loaded | Check async timing, add null check |
| `NaN` in calculation | String concatenation vs addition | `Number(value)` or `parseInt(value, 10)` |
| Object reference mutation | Spread operator not used | Use `{...original}` for copy |
| Stale closure in useEffect | Missing dependency in array | Add all used variables to deps array |

---

## Debugging Quick Commands

```bash
# Python: trace execution
python -m trace -t script.py | grep suspect_file

# Python: profiler
python -m cProfile -o profile.out script.py
python -m pstats profile.out

# Git: find when bug was introduced
git bisect start
git bisect bad
git bisect good <known-good>

# Network: capture API traffic
curl -v https://api.example.com/endpoint

# Python: debugger
python -m pdb script.py

# Process monitoring
strace -p <PID>  # System calls
lsof -p <PID>    # Open files
```

---

## Debugging Mindset

1. **Assume nothing** — Verify every assumption with evidence
2. **One change at a time** — Change one thing, test, repeat
3. **Write down what you know** — Document findings as you go
4. **Take breaks** — Fresh eyes see what tired eyes miss
5. **Explain to a rubber duck** — Verbalizing often reveals the answer
6. **Check the simple things first** — Typos, wrong config, stale cache
7. **The bug is always in your code** — Until proven otherwise
