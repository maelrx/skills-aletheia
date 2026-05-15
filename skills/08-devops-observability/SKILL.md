---
name: 08-devops-observability
description: Use when establishing or auditing engineering operations: Git workflow, branch strategy, code review, lint/type/test gates, deployment strategy, environment management, logs/metrics/traces, scripts, and operational documentation.
---


# DevOps and Observability

## Mission

Prevent the normal failures of AI-assisted development: losing work, breaking production, not knowing what changed, lacking tests, mixing environments, and debugging blind. DevOps here means the minimum professional operating system for shipping safely.

## Use when

- The user asks for DevOps, repo organization, tests, Git workflow, CI/CD, observability, scripts, runbooks, or professionalization of a vibe-coded project.

## Workflow

### 1. Git and versioning audit

```bash
git status --short
git branch --show-current
git log --oneline -10
rg -n '^\.env|node_modules|dist|build|coverage|\.next|\.DS_Store' .gitignore 2>/dev/null
```

Required:

- Git initialized and clean enough to work safely.
- Meaningful commits.
- `.env`, build artifacts, and dependencies ignored.
- Main branch treated as production or stable.
- Work done on feature branch unless user explicitly says otherwise.

### 2. Code quality gates

Inspect scripts:

```bash
cat package.json 2>/dev/null | sed -n '1,220p'
rg -n 'lint|format|type-check|tsc|eslint|prettier|biome|test|vitest|jest|playwright|cypress' package.json .github . 2>/dev/null
```

Expected scripts:

```json
{
  "lint": "...",
  "type-check": "tsc --noEmit",
  "test": "...",
  "build": "...",
  "pre-deploy": "npm run lint && npm run type-check && npm run test && npm run build"
}
```

### 3. Test coverage audit

```bash
find . -type f \( -name '*.test.*' -o -name '*.spec.*' -o -path '*e2e*' \) | sort | head -200
rg -n 'describe\(|it\(|test\(|expect\(|playwright|cypress|vitest|jest' . 2>/dev/null
```

Minimum for client work:

- unit tests for critical pure logic;
- integration tests for API/auth/business rules;
- E2E smoke tests for login and core flow;
- regression tests for every security fix.

### 4. Deployment strategy audit

```bash
find . -maxdepth 4 -type f \( -path './.github/workflows/*' -o -name 'vercel.json' -o -name 'netlify.toml' -o -name 'render.yaml' -o -name 'railway.toml' \) -print
```

Required:

- staging/preview separate from production;
- automated checks before deploy;
- rollback documented;
- production deploy gated by branch/review.

### 5. Environment management audit

```bash
find . -maxdepth 3 -name '.env*' -print
rg -n 'DATABASE_URL|NEXT_PUBLIC_|SUPABASE|OPENAI|STRIPE|ENV|NODE_ENV' .env* .env.example README* docs package.json 2>/dev/null
```

Required:

- `.env.example` with placeholders only;
- env var inventory documented;
- dev/staging/prod values separated;
- no production DB used for tests.

### 6. Observability audit

```bash
rg -n 'logger|pino|winston|Sentry|captureException|trace|span|metrics|analytics|health|requestId|correlationId|console\.error' app pages src server 2>/dev/null
```

Required:

- structured logs for server errors and critical events;
- request ID/correlation where practical;
- error tracking;
- metrics for both technical and business outcomes;
- health check endpoint.

### 7. Scripts and operational docs

Search:

```bash
find . -maxdepth 3 -type f \( -iname 'README*' -o -iname '*RUNBOOK*' -o -iname '*ADR*' -o -iname '*OPERATIONS*' -o -iname '*DEPLOY*' \) -print
```

Required docs:

- setup instructions;
- local development;
- test/build/deploy;
- environment variables;
- rollback;
- incident response;
- architecture notes/ADRs.

## Output contract

```markdown
# DevOps and Observability Report

## Current operating model

## Findings
| Severity | Area | Evidence | Risk | Fix | Verification |
|---|---|---|---|---|---|

## Recommended scripts

## Recommended CI gate

## Missing runbooks/docs

## Changes made

## Remaining risks
```

## Stop criteria

Stop before force-pushing, rewriting history, deleting branches, changing production CI/CD, or running migrations as part of DevOps cleanup without explicit approval.
