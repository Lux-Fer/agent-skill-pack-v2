---
name: performance-profiler
title: performance-profiler
description: AI agent skill for performance analysis, profiling, bottleneck detection, and optimization
author: agent-skill-pack-v2
version: 1.0.0
tags: [performance, profiling, optimization, debugging, async, memory]
skill_type: analysis
---

# Performance Profiler Skill

## Overview

Systematic approach to performance analysis — from profiling and bottleneck detection to optimization strategies and monitoring. Applies across Python, JavaScript/TypeScript, and general backend systems.

## 1. Profiling Tools

### Python Profiling

| Tool | Use Case | Command |
|------|----------|---------|
| **cProfile** | Built-in deterministic profiling | `python -m cProfile -o output.prof script.py` |
| **py-spy** | Sampling profiler for running processes (no code change) | `py-spy record -o profile.svg --pid 12345` |
| **py-spy top** | Live top-like view | `py-spy top --pid 12345` |
| **memory_profiler** | Line-by-line memory usage | `python -m memory_profiler script.py` |
| **tracemalloc** | Python 3.4+ built-in memory tracing | `tracemalloc.start()` + `snapshot.compare_to()` |
| **scalene** | CPU, GPU, memory profiler | `scalene script.py` |

```python
# cProfile basic usage
import cProfile
import pstats

profiler = cProfile.Profile()
profiler.enable()
# ... code to profile ...
profiler.disable()

stats = pstats.Stats(profiler).sort_stats('cumtime')
stats.print_stats(20)  # top 20 by cumulative time
stats.sort_stats('time').print_stats(20)  # top 20 by internal time
```

```python
# py-spy attach to running process
# sudo py-spy record -o flamegraph.svg --pid $(pgrep -f my_app)
# sudo py-spy top --pid $(pgrep -f my_app)
```

### JavaScript/Node.js Profiling

| Tool | Use Case |
|------|----------|
| **Chrome DevTools** | CPU profile, memory heap snapshots, flame charts |
| **Node --inspect** | `node --inspect --inspect-brk app.js` then open `chrome://inspect` |
| **clinic.js** | Doctor (event loop lag), Bubbleprof (async), Flame (CPU) |
| **0x** | Flame graph generation for Node.js |
| **perf_hooks** | Node.js built-in performance measurement |

```javascript
// Node.js performance hooks
const { performance, PerformanceObserver } = require('perf_hooks');

performance.mark('start-task');
// ... code ...
performance.mark('end-task');
performance.measure('Task Duration', 'start-task', 'end-task');

const obs = new PerformanceObserver((items) => {
  items.getEntries().forEach(entry => {
    console.log(`${entry.name}: ${entry.duration}ms`);
  });
});
obs.observe({ entryTypes: ['measure'] });
```

### Web/Browser Profiling

| Tool | Use Case |
|------|----------|
| **Chrome DevTools Performance** | Full recording: FPS, CPU, network, rendering |
| **Lighthouse** | Automated auditing: performance, accessibility, SEO |
| **Web Vitals** | LCP (Largest Contentful Paint), FID (First Input Delay), CLS (Cumulative Layout Shift) |
| **Bundle Analyzer** | Webpack/Vite bundle size analysis |

## 2. Bottleneck Detection Patterns

### Common Bottlenecks

```
┌─────────────────────────────────────────────────────────┐
│                    Bottleneck Types                      │
├──────────────┬────────────────────┬────────────────────┤
│   CPU-bound  │     I/O-bound      │   Memory-bound     │
├──────────────┼────────────────────┼────────────────────┤
│ Heavy loops  │ Database queries   │ Large allocations  │
│ Computation  │ HTTP requests      │ Object retention   │
│ Serialization│ File operations    │ Cache bloat        │
│ Regex        │ Network latency    │ String concat      │
│ Compression  │ Lock contention    │ DOM nodes (browser)│
└──────────────┴────────────────────┴────────────────────┘
```

### Detection Methodology

1. **Establish baseline** — measure latency, throughput, resource usage
2. **Profile in production-like environment** — dev profiles hide real bottlenecks
3. **Start broad, zoom in** — system-wide → service → function → line
4. **Look for N+1 queries** — one query per loop iteration is a classic red flag
5. **Check p50/p95/p99 latency** — high p99 but low p50 suggests occasional stalls
6. **Watch for lock contention** — threads/async tasks blocking on shared resources

### Warning Signs

- High CPU with low I/O → CPU-bound (compute, serialization, tight loops)
- Low CPU with high latency → I/O-bound (network, disk, database)
- Growing memory over time → memory leak
- Sudden latency spikes → garbage collection, lock contention, or cold starts
- Increasing queue depth → system saturated, needs horizontal scaling

## 3. Optimization Strategies

### Caching

```python
# Multi-level caching strategy
from functools import lru_cache
import aiocache
import redis

# Level 1: In-memory (fastest, smallest)
@lru_cache(maxsize=128)
def compute_expensive(x: int) -> int:
    return x ** x  # Simulated heavy computation

# Level 2: Distributed cache (slower, shared)
cache = redis.Redis(connection_pool=redis.ConnectionPool(max_connections=10))

async def get_user_preferences(user_id: str) -> dict:
    # Check local cache (L1)
    if user_id in local_cache:
        return local_cache[user_id]

    # Check Redis cache (L2)
    cached = await cache.get(f"user:{user_id}")
    if cached:
        local_cache[user_id] = cached
        return cached

    # Fall through to source of truth (L3)
    prefs = await database.fetch_user_preferences(user_id)
    await cache.setex(f"user:{user_id}", 3600, prefs)
    local_cache[user_id] = prefs
    return prefs
```

**Cache invalidation strategies:**
- TTL-based (time-to-live)
- Write-through (update cache on write)
- Write-behind (async cache update)
- Cache-aside (app manages cache lifecycle)
- Event-driven invalidation (pub/sub)

### Lazy Loading

```python
# Python property-based lazy loading
class ExpensiveResource:
    def __init__(self):
        self._data = None

    @property
    def data(self):
        if self._data is None:
            self._data = self._load_data()  # Expensive operation
        return self._data

    def _load_data(self):
        import time
        time.sleep(2)  # Simulate expensive load
        return {"key": "value", "items": list(range(1000))}
```

### Connection Pooling

```python
# Database connection pooling
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool

engine = create_engine(
    "postgresql://user:pass@localhost/db",
    poolclass=QueuePool,
    pool_size=10,           # Max connections in pool
    max_overflow=20,        # Extra connections beyond pool_size
    pool_timeout=30,        # Seconds to wait for a connection
    pool_recycle=1800,      # Recycle connections after 30min
    pool_pre_ping=True      # Test connection before using
)

# HTTP connection pooling
import httpx

client = httpx.AsyncClient(
    limits=httpx.Limits(
        max_connections=100,
        max_keepalive_connections=20,
        keepalive_expiry=30
    ),
    timeout=httpx.Timeout(10.0)
)
```

### Query Optimization

```sql
-- Bad: N+1 queries
-- Application makes 1 query for users, then N queries for each user's orders

-- Good: JOIN to reduce round trips
SELECT u.*, o.*
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
WHERE u.tenant_id = ?;

-- Use EXPLAIN ANALYZE to check query plans
EXPLAIN ANALYZE
SELECT * FROM users WHERE email = 'test@example.com';

-- Add missing indexes
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
CREATE INDEX CONCURRENTLY idx_orders_user_created ON orders(user_id, created_at DESC);

-- Pagination with keyset (cursor) over offset
SELECT * FROM orders
WHERE created_at < %(cursor)s
ORDER BY created_at DESC
LIMIT 50;
```

## 4. Memory Leak Detection

### Python Memory Leaks

```python
# Using tracemalloc
import tracemalloc
import linecache

tracemalloc.start(25)  # Stack trace depth

snapshot1 = tracemalloc.take_snapshot()
# ... run code that may leak ...
snapshot2 = tracemalloc.take_snapshot()

top_stats = snapshot2.compare_to(snapshot1, 'lineno')
for stat in top_stats[:10]:
    print(stat)
    for line in stat.traceback.format():
        print(line)
```

```python
# Using gc module for reference cycles
import gc

gc.collect()  # Force garbage collection
obj_count = len(gc.get_objects())
print(f"Object count: {obj_count}")

# Find objects that shouldn't exist
for obj in gc.get_objects():
    if isinstance(obj, SomeExpectedClass):
        # Check if it should have been freed
        print(f"Leaked: {obj} at {id(obj)}")
```

### JavaScript Memory Leaks

```javascript
// Common leak patterns:
// 1. Global variables
// 2. Forgotten timers/intervals
// 3. Detached DOM nodes (event listeners)
// 4. Closures retaining large objects

// Detection with Chrome DevTools:
// 1. Take heap snapshot
// 2. Perform suspect action
// 3. Take another heap snapshot
// 4. Compare to see retained objects

// Use node --inspect and process.memoryUsage()
const memBefore = process.memoryUsage();
// ... run code ...
const memAfter = process.memoryUsage();
console.log('Heap used:', (memAfter.heapUsed - memBefore.heapUsed) / 1024 / 1024, 'MB');
```

### Common Leak Patterns

| Pattern | Symptom | Fix |
|---------|---------|-----|
| Cached data with no eviction | Memory grows monotonically | Add TTL + max size |
| Event listener accumulation | Memory grows on page interactions | Remove listeners when done |
| Global object references | Objects never GC'd | Use WeakMap/WeakRef |
| Closure capturing large data | Unexpected retention | Nullify references when done |
| Thread pool thread-local data | Worker memory creep | Clear thread-local after request |

## 5. Async / Concurrency Optimization

### Python Async Patterns

```python
import asyncio
import aiohttp

# Bad: sequential awaits
async def fetch_all(urls: list[str]) -> list[dict]:
    results = []
    for url in urls:
        results.append(await fetch(url))  # Sequential!
    return results

# Good: concurrent with asyncio.gather
async def fetch_all_concurrent(urls: list[str]) -> list[dict]:
    async def fetch(session, url):
        async with session.get(url) as resp:
            return await resp.json()

    async with aiohttp.ClientSession() as session:
        tasks = [fetch(session, url) for url in urls]
        return await asyncio.gather(*tasks, return_exceptions=True)

# Throttle concurrent requests
import asyncio
semaphore = asyncio.Semaphore(10)  # Max 10 concurrent

async def throttled_fetch(session, url):
    async with semaphore:
        async with session.get(url) as resp:
            return await resp.json()
```

### Concurrency Models Comparison

| Model | Best For | Pitfalls |
|-------|----------|----------|
| **asyncio** | I/O-bound, many concurrent connections | Not for CPU-bound work |
| **threading** | I/O-bound, blocking library interop | GIL limits CPU parallelism |
| **multiprocessing** | CPU-bound computation | High memory overhead |
| **concurrent.futures** | Mix of I/O and CPU | Thread pool vs process pool choice |

```python
# CPU-bound work with multiprocessing
from concurrent.futures import ProcessPoolExecutor
import math

def compute_chunk(numbers: list[float]) -> list[float]:
    return [math.sqrt(n ** 3 + n ** 2) for n in numbers]

def parallel_compute(all_numbers: list[float], workers: int = 4):
    chunk_size = len(all_numbers) // workers
    chunks = [all_numbers[i:i + chunk_size] for i in range(0, len(all_numbers), chunk_size)]

    with ProcessPoolExecutor(max_workers=workers) as executor:
        results = executor.map(compute_chunk, chunks)

    return [item for chunk in results for item in chunk]
```

### Event Loop Health

```python
# Monitor asyncio event loop lag
import asyncio
import time

async def health_check():
    """Detect event loop blocking."""
    last_check = time.monotonic()
    while True:
        await asyncio.sleep(1)
        now = time.monotonic()
        lag = now - last_check - 1
        if lag > 0.1:  # More than 100ms lag
            print(f"WARNING: Event loop lag: {lag:.2f}s")
        last_check = now

# In Node.js, use process.hrtime() or perf_hooks
# const start = process.hrtime.bigint();
# setTimeout(() => {
#   const delta = Number(process.hrtime.bigint() - start) / 1e6;
#   if (delta > 110) console.warn(`Event loop lag: ${delta}ms`);
# }, 100);
```

## 6. Performance Checklist

### Pre-Optimization

- [ ] Is there a measurable performance problem? (don't optimize prematurely)
- [ ] Have you established a performance baseline?
- [ ] Are you measuring the right metric? (latency, throughput, resource usage)
- [ ] Have you profiled in a production-like environment?
- [ ] Is the bottleneck confirmed by data, not intuition?

### Profiling

- [ ] CPU profile: identify hot functions
- [ ] Memory profile: identify allocations and retention
- [ ] I/O profile: identify blocking calls and latency
- [ ] GC/event loop analysis
- [ ] Database query profiling (EXPLAIN ANALYZE, slow query log)
- [ ] Network profiling (connection setup, TLS, payload size)
- [ ] Frontend: bundle size, render performance, web vitals

### Optimization

- [ ] Add appropriate caching (in-memory, distributed, CDN)
- [ ] Implement connection pooling for databases and HTTP
- [ ] Optimize database queries (indexes, JOINs, pagination)
- [ ] Enable lazy loading for expensive resources
- [ ] Use async/concurrent patterns for I/O-bound work
- [ ] Offload CPU-bound work to worker processes/threads
- [ ] Minimize serialization/deserialization overhead
- [ ] Enable compression (gzip, brotli) for network payloads
- [ ] Batch database operations (bulk inserts, batch queries)
- [ ] Reduce lock contention (fine-grained locks, lock-free data structures)

### Verification

- [ ] Re-run the same benchmarks after optimization
- [ ] Compare before/after metrics
- [ ] Verify correctness (optimization must not change behavior)
- [ ] Check edge cases (high load, concurrent access, error states)
- [ ] Monitor in production for regression

### Monitoring

- [ ] Set up latency alerts (p50, p95, p99)
- [ ] Set up error rate alerts
- [ ] Track resource utilization (CPU, memory, network, disk)
- [ ] Implement distributed tracing for microservices
- [ ] Monitor garbage collection / event loop health
- [ ] Set up synthetic monitoring (periodic health checks)

## References

- [cProfile documentation](https://docs.python.org/3/library/profile.html)
- [py-spy documentation](https://github.com/benfred/py-spy)
- [Chrome DevTools Performance](https://developer.chrome.com/docs/devtools/performance)
- [Node.js diagnostics guide](https://nodejs.org/en/docs/guides/diagnostics)
- [Web Vitals](https://web.dev/vitals/)
