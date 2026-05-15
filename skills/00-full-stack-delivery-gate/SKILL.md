---
name: 00-full-stack-delivery-gate
description: Use before client handoff or production release. Orchestrates frontend security, backend/API security, database security, infrastructure, production operations, compliance, performance, and DevOps into a single go/no-go delivery gate.
---


# Full-Stack Delivery Gate

## Mission

Decide whether a web application is safe, stable, performant, compliant enough, and operationally ready to deliver to a paying client. This is the final gate, not a casual review.

## Use when

- The user says: "ready to deliver", "production-ready", "handoff", "client delivery", "audit everything", "before deploy", "go/no-go".
- The project was generated or heavily modified by AI and needs professional hardening.
- A client is about to receive access, traffic, paid users, or real customer data.

## Inputs to request only if unavailable

- Repository path and target stack.
- Production URL, staging URL, and deployment platform.
- Database provider and whether production data exists.
- Whether the audit is read-only or allowed to patch code.

If the user already gave enough context, do not ask; proceed with best effort.

## Non-negotiable checks

A delivery cannot be considered ready if any of these are unresolved:

- Real secret exposed in frontend code, Git history, logs, or public config.
- API route or Server Action processes sensitive operations without server-side authentication and authorization.
- Cross-user or cross-tenant access is possible through IDOR or missing tenant filters.
- Supabase tables with user/customer data do not have RLS and correct policies.
- `service_role_key` is used in the browser or exposed as a public environment variable.
- No rollback path for production deploys.
- No backup strategy before destructive migrations.
- No health check or uptime/error monitoring for production systems.
- Paid API endpoints have no rate limiting.
- Personal data is collected without a visible privacy/compliance posture.

## Workflow

### 1. Snapshot the project

Run safe discovery:

```bash
git status --short
find . -maxdepth 3 -type f | sed 's#^./##' | sort | head -250
rg -n --hidden --glob '!node_modules' --glob '!dist' --glob '!build' --glob '!.git' 'NEXT_PUBLIC_|VITE_|REACT_APP_|SUPABASE_SERVICE_ROLE|OPENAI_API_KEY|ANTHROPIC_API_KEY|STRIPE_SECRET|DATABASE_URL|BEGIN PRIVATE KEY|sk-[A-Za-z0-9]' .
```

Record stack, frameworks, deploy config, database client, auth provider, and package manager.

### 2. Run domain gates in this order

1. Frontend/browser security.
2. Backend/API security.
3. Supabase/Postgres database security.
4. Infrastructure/deployment security.
5. Performance/scalability.
6. Production operations.
7. DevOps/observability.
8. Compliance/governance.

Why this order: exposed secrets and auth/data access failures can be catastrophic immediately; operational and compliance gaps matter next for client handoff.

### 3. Classify findings

Use this severity scale:

- **P0 / Critical**: active compromise path, public data access, secret leak, production outage, destructive migration risk, no backup before data-risk operation.
- **P1 / High**: likely unauthorized access, missing paid-endpoint rate limit, weak RLS policy, no rollback, no monitoring for live system.
- **P2 / Medium**: incomplete hardening, missing indexes, weak CSP, incomplete audit logs, untested backup, partial compliance evidence.
- **P3 / Low**: documentation, polish, minor optimization.

### 4. Produce go/no-go decision

Use exactly one of:

- **GO**: no P0/P1 findings remain; P2/P3 risks documented and accepted.
- **GO WITH FIXES**: no P0; P1 findings have clear same-day remediation and can be verified before handoff.
- **NO-GO**: any P0 exists, or multiple P1 risks affect data, auth, billing, or uptime.

## Evidence requirements

Every finding must include at least one of:

- file path + line number,
- command output summary,
- dashboard/config location,
- exact URL/route tested,
- SQL query result,
- missing artifact explicitly searched for.

Do not invent evidence. If inaccessible, say so.

## Output contract

```markdown
# Delivery Gate Report

Decision: GO | GO WITH FIXES | NO-GO

## Executive summary

## P0/P1 blockers
| Severity | Domain | Evidence | Business risk | Required fix | Verification |
|---|---|---|---|---|---|

## P2/P3 improvements
| Severity | Domain | Evidence | Recommendation |
|---|---|---|---|

## Domain scorecard
| Domain | Status | Notes |
|---|---|---|

## Commands run

## Changes made

## Remaining risks / assumptions

## Client-safe handoff notes
```

## Stop criteria

Stop and escalate before changing anything if you find:

- exposed production secrets,
- suspected public access to production customer data,
- destructive migration pending against production,
- auth bypass in admin or billing flows,
- irreversible action required to fix the issue.
