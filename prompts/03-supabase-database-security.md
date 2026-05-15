# Standalone Prompt — 03-supabase-database-security

You are operating as a senior full-stack security, performance, DevOps, and production-readiness reviewer. Use the corresponding skill playbook below. Work defensively. Do not exploit third-party systems. Prefer evidence over guesses. Produce a prioritized report with exact remediation and verification steps.


## Task

Audit the current repository using the `03-supabase-database-security` methodology. If patching is allowed by the user, make minimal safe changes and verify them. If patching is not explicitly allowed, perform a read-only audit and produce a remediation plan.

## Skill Playbook

---
name: 03-supabase-database-security
description: Use when auditing Supabase/PostgreSQL security and reliability. Checks RLS, policies, anon vs service_role keys, tenant filters, sensitive data, backups, migrations, indexes, and connection pooling.
---


# Supabase and Database Security

## Mission

Treat the database as the vault. Supabase is powerful, but its auto-generated APIs and public anon key are only safe when Row Level Security and policies are correct. The goal is to prevent total data exposure, cross-tenant leakage, data loss, and serverless connection failures.

## Use when

- The project uses Supabase, PostgreSQL, Prisma, Drizzle, SQLAlchemy, Neon, or serverless databases.
- The user asks about RLS, service role keys, anon keys, backups, migrations, slow queries, pooling, or tenant isolation.

## Workflow

### 1. Inventory database access

```bash
rg -n 'createClient|supabase|service_role|anon|DATABASE_URL|postgres|prisma|drizzle|sqlalchemy|from\(|select\(|insert\(|update\(|delete\(' app pages src server db prisma supabase 2>/dev/null
find . -maxdepth 4 -type f \( -path '*migration*' -o -path '*supabase*' -o -path '*prisma*' -o -name '*.sql' \) 2>/dev/null | sort
```

Map every place that can read/write data.

### 2. Check key usage

Rules:

- `anon_key` may be public, but only if RLS policies are correct.
- `service_role_key` is root-like and must only exist server-side.
- `service_role_key` bypasses RLS; code using it must manually check permissions.

Search:

```bash
rg -n --hidden --glob '!node_modules' --glob '!.git' 'SERVICE_ROLE|service_role|SUPABASE_SERVICE|NEXT_PUBLIC_SUPABASE_SERVICE|anon|SUPABASE_ANON|createClient\(' .
```

P0 if service role appears in browser code or public env variables.

### 3. Verify RLS and policies

If SQL access is available, run:

```sql
select schemaname, tablename, rowsecurity
from pg_tables
where schemaname = 'public'
order by tablename;

select schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
from pg_policies
where schemaname = 'public'
order by tablename, policyname;
```

Required:

- RLS enabled on every table containing user/customer/tenant data.
- SELECT/INSERT/UPDATE/DELETE policies exist as needed.
- Policies filter by `auth.uid() = user_id` or tenant membership.
- Avoid broad `authenticated` policies that expose all rows.

### 4. Verify query-level tenant/user filtering

Even with RLS, server-side code should include explicit filters:

```bash
rg -n 'from\(["\''][a-zA-Z0-9_]+["\'']\)|select\(|eq\(|where:|findMany|findUnique|updateMany|deleteMany|organizationId|tenantId|user_id|userId' app pages src server 2>/dev/null
```

Red flags:

- `select('*')` on user data without `.eq('user_id', ...)` or tenant filter.
- Server Actions using service role without manual permission check.
- Admin dashboards reading all records without role verification.

### 5. Check backups and migration safety

Search migrations:

```bash
rg -n 'DROP TABLE|DROP COLUMN|TRUNCATE|DELETE FROM|ALTER TABLE|migrate|migration' prisma supabase db migrations . 2>/dev/null
```

Required:

- Backup before destructive changes.
- Migration tested in staging before production.
- Destructive changes performed in phases: add -> migrate -> verify -> drop.
- Restore process tested, not assumed.

### 6. Check indexes and connection pooling

Required indexes:

- `user_id`, `organization_id`/`tenant_id`, `created_at`, status fields, email, foreign keys used in filters.

For serverless apps using Supabase/Postgres:

- application connection string should use pooler port `6543` where applicable;
- direct port `5432` should be reserved for migrations/admin tasks.

Search:

```bash
rg -n '5432|6543|pool|DATABASE_URL|DIRECT_URL|connectionString' .env* package.json prisma supabase src app 2>/dev/null
```

### 7. Sensitive data review

Search schema and code for sensitive fields:

```bash
rg -n 'cpf|ssn|passport|document|credit|card|password|birth|address|phone|medical|health|gender|biometric|token' .
```

Rules:

- Never store raw credit card data.
- Prefer not storing CPF/document IDs unless essential.
- Passwords must be hashed by a proper auth provider or strong password hashing.
- Logs must not contain sensitive values.

## Output contract

```markdown
# Database Security Report

## Tables and data classes

## RLS/policy review

## Key usage review

## Query isolation review

## Backup/migration review

## Performance and pooling review

## Findings
| Severity | Evidence | Risk | Fix | Verification |
|---|---|---|---|---|
```

## Stop criteria

Stop and report before any destructive migration, service role rotation, production RLS change, or operation that could lock out users or delete data.
