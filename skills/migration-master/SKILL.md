---
name: migration-master
title: Migration Master
version: 1.0.0
description: AI agent skill for database and schema migrations — Alembic patterns, zero-downtime strategies, data backfill, rollback planning, and migration verification.
author: Agent Skill Pack v2
tags: [database, migrations, alembic, schema, sql, devops]
os: [linux, macos, windows]
tools: [python, alembic, psql, mysql, sqlite3, flyway, liquibase]
---

# Migration Master Skill

## Overview

This skill provides agents with structured methodologies for planning, executing, and verifying database schema migrations. It covers Alembic migration patterns, zero-downtime strategies, data backfill scripts, rollback planning, and verification procedures.

---

## 1. Alembic Migration Patterns

### 1.1 Basic Migration Structure
```python
"""add email verification columns

Revision ID: abc123def456
Revises: prev_revision_id
Create Date: 2026-04-30 01:10:00.000000
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "abc123def456"
down_revision = "prev_revision_id"
branch_labels = None
depends_on = None

def upgrade():
    op.add_column("users", sa.Column("email_verified", sa.Boolean(), server_default=sa.text("false"), nullable=False))
    op.add_column("users", sa.Column("email_verified_at", sa.DateTime(), nullable=True))
    op.create_index(op.f("ix_users_email_verified"), "users", ["email_verified"])

def downgrade():
    op.drop_index(op.f("ix_users_email_verified"), table_name="users")
    op.drop_column("users", "email_verified_at")
    op.drop_column("users", "email_verified")
```

### 1.2 Migration Naming Convention
```
YYYY_MM_DD_HHMM_short_description.py

Examples:
2026_04_30_0100_add_email_verification.py
2026_04_30_0115_create_orders_table.py
2026_04_30_0130_add_foreign_key_to_orders.py
2026_04_30_0145_backfill_user_display_names.py
```

### 1.3 Alembic Configuration (env.py)
```python
from alembic import context
from sqlalchemy import engine_from_config, pool
from logging.config import fileConfig

config = context.config

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

def run_migrations_online():
    """Run migrations in 'online' mode with connection sharing."""
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
            compare_type=True,         # Detect type changes
            compare_server_default=True, # Detect default changes
        )
        with context.begin_transaction():
            context.run_migrations()

def run_migrations_offline():
    """Run migrations in 'offline' mode (emit SQL)."""
    context.configure(
        url=config.get_main_option("sqlalchemy.url"),
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )
    with context.begin_transaction():
        context.run_migrations()
```

### 1.4 Commands Reference
```bash
# Create a new migration (autogenerate)
alembic revision --autogenerate -m "add email verification"

# Create a blank migration
alembic revision -m "custom migration"

# Apply migrations
alembic upgrade head

# Rollback one step
alembic downgrade -1

# Rollback to specific revision
alembic downgrade abc123def456

# View history
alembic history

# View current revision
alembic current

# Show pending migrations
alembic check

# Generate SQL without applying
alembic upgrade head --sql

# Apply to a specific database URL
alembic -x db_url=postgresql://... upgrade head
```

---

## 2. Schema Change Types

### 2.1 Add Column
```python
def upgrade():
    # Safe: nullable=True, has default, or column is added in stages
    op.add_column("users", sa.Column("timezone", sa.String(50), nullable=True))

    # For NOT NULL columns on existing tables, add as nullable first,
    # backfill data, then alter to NOT NULL
    op.add_column("users", sa.Column("display_name", sa.String(100), nullable=True))

def upgrade_post_backfill():
    op.alter_column("users", "display_name", nullable=False)
```

### 2.2 Drop Column
```python
def upgrade():
    # WARNING: This is destructive and irreversible!
    # Step 1: Ensure no application code references the column
    # Step 2: Ensure no triggers, views, or SPs reference the column
    op.drop_column("users", "legacy_field")
```

### 2.3 Modify Column Type
```python
def upgrade():
    # PostgreSQL allows direct ALTER
    op.alter_column("users", "age",
                    type_=sa.Integer(),
                    existing_type=sa.String(10),
                    postgresql_using="age::integer")

    # Other DBs: add new column, copy data, drop old column, rename
    op.add_column("users", sa.Column("age_new", sa.Integer(), nullable=True))
    op.execute("UPDATE users SET age_new = age::integer WHERE age ~ '^[0-9]+$'")
    op.drop_column("users", "age")
    op.alter_column("users", "age_new", new_column_name="age")
```

### 2.4 Rename Column
```python
def upgrade():
    # Ensure no application code references the old name
    op.alter_column("users", "full_name", new_column_name="display_name")

def downgrade():
    op.alter_column("users", "display_name", new_column_name="full_name")
```

### 2.5 Add Foreign Key
```python
def upgrade():
    op.create_foreign_key(
        "fk_orders_user_id",
        "orders", "users",
        ["user_id"], ["id"],
        ondelete="CASCADE",
    )
```

### 2.6 Add Index (Concurrently)
```python
from alembic import op
import sqlalchemy as sa

def upgrade():
    # PostgreSQL: CREATE INDEX CONCURRENTLY avoids table lock
    # Must be run outside of transaction
    op.execute(
        "CREATE INDEX CONCURRENTLY ix_orders_user_id ON orders (user_id)"
    )
    op.create_index("ix_orders_created_at", "orders", ["created_at"],
                    postgresql_concurrently=True)
```

### 2.7 Data Transform (Update Existing Rows)
```python
def upgrade():
    # Simple transform in migration
    op.execute("""
        UPDATE users
        SET display_name = COALESCE(NULLIF(TRIM(full_name), ''), email)
        WHERE display_name IS NULL
    """)
```

---

## 3. Zero-Downtime Migration Strategies

### 3.1 Expand-Contract Pattern
```
Phase 1: Expand (backward-compatible)
  - Add new column/table alongside existing
  - Application writes to both old and new
  - Old code still works unchanged

Phase 2: Migrate (dual-write + backfill)
  - Backfill existing data from old to new
  - Switch reads to new structure
  - Both code paths still work

Phase 3: Contract (breaking change)
  - Remove old column/table
  - Deploy code that only uses new structure
  - Drop old structure in migration
```

### 3.2 Column Add (Safe)
```python
# Phase 1 — Add column as nullable
op.add_column("users", sa.Column("email_verified", sa.Boolean(), nullable=True))
# Deploy new code that reads/writes email_verified

# Phase 2 — Backfill existing data (separate script)
# UPDATE users SET email_verified = false WHERE email_verified IS NULL;

# Phase 3 — Make NOT NULL (separate migration)
op.alter_column("users", "email_verified", nullable=False,
                server_default=sa.text("false"))
```

### 3.3 Column Rename (Safe)
```python
# Phase 1 — Add new column, copy data
op.add_column("users", sa.Column("display_name", sa.String(100), nullable=True))
op.execute("UPDATE users SET display_name = full_name")

# Phase 2 — Dual-write: write to both columns
# Deploy code that writes display_name, reads from display_name (preferred)
# or falls back to full_name

# Phase 3 — Drop old column
op.drop_column("users", "full_name")
```

### 3.4 Table Rename (Safe)
```python
# Phase 1 — Create view with old name pointing to new table
# CREATE VIEW legacy_orders AS SELECT * FROM orders_new;
# Deploy code using orders_new; old code uses legacy_orders

# Phase 2 — Drop view and old table
# DROP VIEW legacy_orders;
```

### 3.5 Migration Timing Considerations
| Change Type | Locks Table? | Affects Reads? | Affects Writes? | Downtime Needed? |
|---|---|---|---|---|
| Add column (nullable) | Minimal | No | No | No |
| Add column (NOT NULL, default) | Yes (some DBs) | No | No | No |
| Drop column | Yes | Yes | Yes | Yes |
| Add index (concurrently) | Minimal* | No | Minimal | No |
| Add index (standard) | Yes | No | Yes | Yes |
| Rename column | Yes | Yes | Yes | Yes |
| Change column type | Yes | Yes | Yes | Yes |
| Add foreign key | Yes | No | Yes | Maybe |
| Create table | No | No | No | No |

*PostgreSQL only with CONCURRENTLY option.

---

## 4. Data Backfill Scripts

### 4.1 Batch Backfill (Python)
```python
"""
Batch backfill script for display_name column.
Run AFTER schema migration but BEFORE making column NOT NULL.
"""
import time
from sqlalchemy import create_engine, text

BATCH_SIZE = 1000
engine = create_engine("postgresql://user:pass@localhost/dbname")

def backfill_display_names():
    total = 0
    start_time = time.time()

    with engine.begin() as conn:
        while True:
            result = conn.execute(text("""
                UPDATE users
                SET display_name = COALESCE(NULLIF(TRIM(full_name), ''), email)
                WHERE display_name IS NULL
                AND id IN (
                    SELECT id FROM users
                    WHERE display_name IS NULL
                    LIMIT :batch_size
                    FOR UPDATE SKIP LOCKED
                )
                RETURNING id
            """), {"batch_size": BATCH_SIZE})

            updated = result.rowcount
            total += updated
            print(f"Updated {total} rows so far...")

            if updated == 0:
                break

            time.sleep(0.1)  # Throttle

    elapsed = time.time() - start_time
    print(f"Backfill complete: {total} rows in {elapsed:.2f}s")

if __name__ == "__main__":
    backfill_display_names()
```

### 4.2 SQL-Only Backfill (Throttled)
```sql
-- Throttled backfill with pg_sleep
DO $$
DECLARE
    batch_size INT := 1000;
    updated INT := 0;
BEGIN
    LOOP
        UPDATE users
        SET display_name = COALESCE(NULLIF(TRIM(full_name), ''), email)
        WHERE id IN (
            SELECT id FROM users
            WHERE display_name IS NULL
            LIMIT batch_size
            FOR UPDATE SKIP LOCKED
        );

        updated := updated + batch_size;
        RAISE NOTICE 'Updated % rows', updated;

        EXIT WHEN batch_size = 0;

        PERFORM pg_sleep(0.1);  -- 100ms throttle
    END LOOP;
END $$;
```

### 4.3 Backfill Verification
```sql
-- Check remaining NULLs
SELECT COUNT(*) FROM users WHERE display_name IS NULL;

-- Check for uneven distribution
SELECT
    COUNT(*) FILTER (WHERE display_name = email) AS fell_back_to_email,
    COUNT(*) FILTER (WHERE display_name != email) AS has_full_name,
    COUNT(*) FILTER (WHERE display_name IS NULL) AS still_null
FROM users;
```

---

## 5. Rollback Planning

### 5.1 Rollback Strategy Matrix
| Change Type | Rollback Difficulty | Rollback Method |
|---|---|---|
| Add table | Easy | `DROP TABLE` |
| Add column (nullable) | Easy | `DROP COLUMN` |
| Add column (NOT NULL) | Medium | Drop column, data loss |
| Drop column | Hard | Restore from backup |
| Rename column | Medium | `ALTER TABLE ... RENAME COLUMN` back |
| Change type | Medium | Cast back to original type |
| Data transform | Hard | Restore from backup or inverse transform |
| Add index | Easy | `DROP INDEX` |
| Add foreign key | Easy | `DROP CONSTRAINT` |

### 5.2 Rollback Script Pattern
```python
"""Rollback: revert email verification changes.

Revision ID: def456abc123
Revises: abc123def456
"""
revision = "def456abc123"
down_revision = "abc123def456"

def upgrade():
    """This is the rollback migration — it reverses abc123def456"""
    op.drop_column("users", "email_verified_at")
    op.drop_column("users", "email_verified")

def downgrade():
    """Reverse the rollback — re-apply the original changes"""
    op.add_column("users", sa.Column("email_verified",
                   sa.Boolean(), server_default="false", nullable=False))
    op.add_column("users", sa.Column("email_verified_at", sa.DateTime(), nullable=True))
```

### 5.3 Rollback Decision Flow
```
1. DETECT ISSUE
   - Application errors after migration
   - Performance degradation
   - Data integrity violation
   - Failed verification checks

2. DECIDE
   - Can we fix forward? → Create hotfix migration
   - Must rollback? → Proceed

3. PREPARE
   - Back up database
   - Notify team
   - Prepare rollback migration

4. EXECUTE
   - Rollback schema: alembic downgrade <prev_revision>
   - Rollback data: execute inverse transform script
   - Restore from backup if data changes can't be reversed

5. VERIFY
   - Schema matches expected state
   - Data integrity confirmed
   - Application functions correctly
   - No residual effects

6. DOCUMENT
   - Root cause of rollback
   - Lessons learned
   - Updated migration plan
```

---

## 6. Migration Verification

### 6.1 Pre-Migration Checks
```python
def pre_migration_checks():
    checks = []

    # 1. Check for active connections
    result = db.execute("""
        SELECT count(*) FROM pg_stat_activity
        WHERE state = 'active' AND query NOT LIKE '%pg_stat_activity%'
    """)
    active = result.scalar()
    checks.append(("Active connections", active, active < 10))

    # 2. Check replication lag
    result = db.execute("SELECT GREATEST(0, EXTRACT(EPOCH FROM now() - pg_last_xact_replay_timestamp()))")
    lag = result.scalar() or 0
    checks.append(("Replication lag (s)", lag, lag < 5))

    # 3. Check disk space
    result = db.execute("""
        SELECT pg_database_size(current_database()) / (1024*1024*1024) AS db_size_gb
    """)
    db_size = result.scalar()
    checks.append(("Database size (GB)", db_size, db_size < 100))

    for name, value, ok in checks:
        status = "OK" if ok else "WARN"
        print(f"[{status}] {name}: {value}")
        if not ok:
            print(f"  ⚠ Consider postponing migration")
```

### 6.2 Post-Migration Verification
```sql
-- 1. Schema matches expected
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'users'
ORDER BY ordinal_position;

-- 2. Row counts consistent
SELECT COUNT(*) FROM users;

-- 3. New column populated
SELECT COUNT(*) FROM users WHERE display_name IS NULL;

-- 4. Indexes exist
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'users';

-- 5. Foreign keys intact
SELECT conname, pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conrelid = 'users'::regclass AND contype = 'f';

-- 6. No orphaned records
SELECT u.id FROM users u
LEFT JOIN organizations o ON u.org_id = o.id
WHERE u.org_id IS NOT NULL AND o.id IS NULL;
```

### 6.3 Verification via Alembic
```python
# Run in CI/CD after migration
import subprocess
import sys

def verify_migration():
    """Run verification after alembic upgrade."""
    # Check current revision
    result = subprocess.run(
        ["alembic", "current"],
        capture_output=True, text=True
    )
    print(f"Current revision: {result.stdout.strip()}")

    # Check no pending migrations
    result = subprocess.run(
        ["alembic", "check"],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        print("ERROR: Pending migrations after upgrade!")
        sys.exit(1)

    # Run custom verification queries
    # (see post-migration verification SQL above)

    print("Migration verification passed.")
```

---

## 7. Migration Patterns Reference

### Pattern 1: Add NOT NULL Column Safely
```
1. ALTER TABLE t ADD COLUMN c type NULL
2. Deploy app code that handles NULL
3. Backfill data: UPDATE t SET c = default WHERE c IS NULL
4. ALTER TABLE t ALTER COLUMN c SET NOT NULL
5. Deploy app code expecting NOT NULL
```

### Pattern 2: Split Table (1:1 Relationship)
```
1. Create new table
2. Add foreign key from old to new (nullable)
3. Backfill: INSERT INTO new_table SELECT ... FROM old_table
4. Deploy code reading from both tables
5. Drop old columns or old table
```

### Pattern 3: Merge Tables (1:1 Join)
```
1. Add new columns to target table (nullable)
2. Backfill: UPDATE target SET col = source.col FROM source WHERE ...
3. Add NOT NULL constraints after backfill verified
4. Deploy code using only target table
5. Drop source table
```

### Pattern 4: Enum Type Change
```
1. Create new enum type with updated values
2. ALTER TABLE t ALTER COLUMN c TYPE new_enum USING c::text::new_enum
   (handle values that don't map: UPDATE first)
3. Drop old enum type
```

### Pattern 5: Large Table Indexing
```
PostgreSQL:
  CREATE INDEX CONCURRENTLY ix_name ON table (column);
  DROP INDEX CONCURRENTLY ix_name_old;

MySQL 5.6+ (online DDL):
  ALTER TABLE t ADD INDEX ix_name (column), ALGORITHM=INPLACE, LOCK=NONE;
```

### Pattern 6: Foreign Key Addition (Zero Downtime)
```
1. CREATE INDEX CONCURRENTLY on referencing column (if not indexed)
2. Add foreign key: ALTER TABLE t ADD CONSTRAINT fk_name
   FOREIGN KEY (col) REFERENCES ref_table (id) NOT VALID;
3. Validate: ALTER TABLE t VALIDATE CONSTRAINT fk_name;
   (VALIDATE runs as SHARE UPDATE EXCLUSIVE lock, not blocking writes)
```

---

## 8. Migration Runbook Template

```markdown
## Migration Runbook

**Migration**: {migration_name}
**Revision**: {revision_id}
**Date**: {date}
**Owner**: {owner}
**Approved by**: {approver}

### Pre-Migration
- [ ] Database backup verified
- [ ] Replication lag checked (< 5s)
- [ ] Active connections checked (< threshold)
- [ ] Disk space checked
- [ ] Code compatible with both old and new schema
- [ ] Rollback plan documented

### Migration Steps
1. `alembic upgrade {revision_id}`
2. Run backfill script (if applicable)
3. Verify data integrity (SQL checks)
4. Run application smoke tests

### Rollback Steps
1. `alembic downgrade {down_revision_id}`
2. Restore data from backup (if needed)
3. Verify application health

### Monitoring
- [ ] Error rates
- [ ] Query performance
- [ ] Connection pool usage
- [ ] Replication lag

### Post-Migration
- [ ] All verification checks pass
- [ ] Performance metrics normal
- [ ] No errors in application logs
- [ ] Cleanup old columns/tables scheduled
```
