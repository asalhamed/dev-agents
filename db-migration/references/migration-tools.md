# Migration Tools Reference

Tool-specific commands, conventions, and workflows per stack.

---

## Diesel (Rust)

### Setup

```toml
# Cargo.toml
[dependencies]
diesel = { version = "2", features = ["postgres"] }

# diesel.toml (project root)
[print_schema]
file = "src/schema.rs"
```

```bash
# Install CLI
cargo install diesel_cli --no-default-features --features postgres

# Initialize (creates migrations/ directory and diesel.toml)
diesel setup
```

### Commands

```bash
# Generate a new migration (creates up.sql and down.sql)
diesel migration generate create_orders
# Creates: migrations/2026-04-09-190000_create_orders/up.sql
#          migrations/2026-04-09-190000_create_orders/down.sql

# Run pending migrations
diesel migration run

# Revert the last migration
diesel migration revert

# Redo (revert + run) — useful for testing
diesel migration redo

# Check migration without running (compile-time validation)
diesel migration pending
```

### Naming Convention

`YYYY-MM-DD-HHMMSS_descriptive_name`

```
migrations/
├── 2026-03-01-100000_create_users/
│   ├── up.sql
│   └── down.sql
├── 2026-03-15-140000_create_orders/
│   ├── up.sql
│   └── down.sql
└── 2026-04-01-090000_add_order_priority/
    ├── up.sql
    └── down.sql
```

### Example Migration

```sql
-- up.sql
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES users(id),
    status VARCHAR(20) NOT NULL DEFAULT 'draft',
    total_cents INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);

-- down.sql
DROP TABLE orders;
```

---

## Flyway (JVM / Scala)

### Setup (sbt)

```scala
// project/plugins.sbt
addSbtPlugin("io.github.davidmweber" % "flyway-sbt" % "7.4.0")

// build.sbt
enablePlugins(FlywayPlugin)
flywayUrl := "jdbc:postgresql://localhost:5432/mydb"
flywayUser := "postgres"
flywayPassword := sys.env.getOrElse("DB_PASSWORD", "")
flywayLocations += "db/migration"
```

### Naming Conventions

| Prefix | Purpose | Example |
|--------|---------|---------|
| `V` | Versioned (run once, in order) | `V1__create_users.sql` |
| `V` | Versioned with minor | `V1.1__add_email_index.sql` |
| `R` | Repeatable (re-run when changed) | `R__refresh_views.sql` |
| `U` | Undo (Flyway Teams only) | `U1__undo_create_users.sql` |

**Double underscore** `__` separates version from description. Description uses underscores.

```
db/migration/
├── V1__create_users.sql
├── V2__create_orders.sql
├── V3__add_order_priority.sql
└── R__refresh_order_summary_view.sql
```

### Commands

```bash
# Apply pending migrations
flyway migrate
# sbt: sbt flywayMigrate

# Baseline an existing database (mark it as V1 without running V1)
flyway baseline -baselineVersion=1

# Validate migrations match what was applied
flyway validate

# Repair checksum mismatches in schema_history table
flyway repair

# Show migration status
flyway info
```

### Key Concepts

- **Schema history table** (`flyway_schema_history`) tracks applied migrations
- Checksums ensure applied migrations haven't been modified
- If checksum mismatch: either `repair` (trust filesystem) or investigate what changed

---

## Prisma (TypeScript)

### Setup

```bash
npm install prisma --save-dev
npm install @prisma/client

# Initialize
npx prisma init
# Creates: prisma/schema.prisma, .env
```

### Schema-First Workflow

```prisma
// prisma/schema.prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

model Order {
  id         String   @id @default(uuid())
  customerId String   @map("customer_id")
  status     String   @default("draft")
  totalCents Int      @default(0) @map("total_cents")
  createdAt  DateTime @default(now()) @map("created_at")
  updatedAt  DateTime @updatedAt @map("updated_at")
  customer   User     @relation(fields: [customerId], references: [id])

  @@map("orders")
  @@index([customerId])
  @@index([status])
}
```

### Commands

```bash
# Development: create migration from schema changes + apply + generate client
npx prisma migrate dev --name add_order_priority

# Production: apply pending migrations (no interactive prompts)
npx prisma migrate deploy

# Manually mark a migration as applied (for manual fixes)
npx prisma migrate resolve --applied 20260409_add_order_priority

# Mark a failed migration as rolled back
npx prisma migrate resolve --rolled-back 20260409_add_order_priority

# Reset database (dev only — drops and recreates)
npx prisma migrate reset

# Generate client after schema change
npx prisma generate
```

### Shadow Database

Prisma uses a **shadow database** during `migrate dev` to:
- Detect drift between migration history and current database state
- Generate new migration SQL by diffing schema

This requires `CREATE DATABASE` permission. In restrictive environments, configure:

```env
SHADOW_DATABASE_URL="postgresql://user:pass@localhost:5432/mydb_shadow"
```

### Migration Files

```
prisma/migrations/
├── 20260301_create_users/
│   └── migration.sql
├── 20260315_create_orders/
│   └── migration.sql
└── migration_lock.toml
```

---

## Goose (Go)

### Setup

```bash
go install github.com/pressly/goose/v3/cmd/goose@latest
```

### Commands

```bash
# Create a new SQL migration
goose -dir migrations create add_order_priority sql
# Creates: migrations/20260409190000_add_order_priority.sql

# Create a Go migration (for complex data migrations)
goose -dir migrations create backfill_priorities go

# Apply all pending migrations
goose -dir migrations postgres "postgres://user:pass@localhost:5432/mydb" up

# Rollback last migration
goose -dir migrations postgres "postgres://user:pass@localhost:5432/mydb" down

# Show migration status
goose -dir migrations postgres "postgres://user:pass@localhost:5432/mydb" status

# Migrate to a specific version
goose -dir migrations postgres "postgres://user:pass@localhost:5432/mydb" up-to 20260315

# Redo last migration
goose -dir migrations postgres "postgres://user:pass@localhost:5432/mydb" redo
```

### Naming Convention

`YYYYMMDDHHMMSS_description.sql` (timestamp prefix, underscore separator)

### Migration File Format

```sql
-- +goose Up
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES users(id),
    status VARCHAR(20) NOT NULL DEFAULT 'draft',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- +goose Down
DROP TABLE orders;
```

---

## Common Patterns (All Tools)

### 1. Always Commit Migration + Code Together

Migration and application code that uses the new schema should be in the same commit/PR.
This ensures:
- Reviewers see the full picture
- Rollback reverts both schema and code
- CI can test the migration + code together

### 2. Never Edit an Applied Migration

Once a migration has been applied (especially in production), treat it as **immutable**.
If you need to change something, create a new migration.

```
❌ Edit V3__add_priority.sql after it's been applied
✅ Create V4__fix_priority_default.sql with the correction
```

Why: Other environments (staging, other developers) have already applied the original.
Editing it causes checksum mismatches and drift.

### 3. Ordering Conflicts

When two branches add migrations at the same time:

| Tool | Conflict Resolution |
|------|---------------------|
| **Diesel** | Timestamp-based, conflicts rare. If same timestamp, one developer re-generates. |
| **Flyway** | Sequential `V` numbers conflict. Adopt: rebase and re-number before merge. Or use timestamps as versions: `V20260409190000__description.sql`. |
| **Prisma** | Timestamp-based, conflicts rare. `prisma migrate dev` detects drift on pull. |
| **Goose** | Timestamp-based, conflicts rare. |

**Team convention:** Before merging, rebase on main and verify `migrate status` shows
your new migration as the latest pending one.

### 4. Migration Review Checklist

- [ ] Has both up and down (rollback) script?
- [ ] Rollback script tested?
- [ ] Uses `IF NOT EXISTS` / `IF EXISTS` for idempotency?
- [ ] Large table changes use `CONCURRENTLY` for indexes?
- [ ] Data backfill uses batching?
- [ ] No full table locks on large tables?
- [ ] Corresponding application code in same PR?
