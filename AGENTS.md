# AGENTS.md — Universal Delivery, Security, Performance, and Operations Guidance

This repository may be operated by Claude Code, Codex, or another coding agent. Follow these instructions before changing code.

## Core operating rules

1. Treat the repository as production-bound unless told otherwise.
2. Never expose secrets in frontend bundles, logs, test output, or generated documentation.
3. Never trust frontend validation. Validate and authorize on the server.
4. Never run destructive database migrations without a backup and explicit approval.
5. Never commit `.env`, real credentials, production dumps, private keys, or customer data.
6. Prefer deterministic checks before LLM judgment: search, inspect, run tests, run build, verify diffs.
7. Produce evidence for every claim: file path, line number, command output, or dashboard/config location.
8. If a finding is uncertain, label it as uncertain and state how to verify it.
9. Keep fixes minimal, reviewable, and reversible.
10. Before final handoff, run the relevant verification commands or state exactly why they could not run.

## Skill routing index

Use the relevant skill playbook from `.agent-skills/skills` or from the installed skill registry.

| User intent / repo condition | Skill |
|---|---|
| Unknown inherited AI-generated project, chaotic codebase, first audit | `09-ai-generated-project-triage` |
| Before delivering to a client | `00-full-stack-delivery-gate` |
| Browser-side security, exposed keys, Next.js client components, DevTools leakage | `01-frontend-browser-security` |
| API routes, Server Actions, auth, IDOR, mass assignment, webhooks, rate limiting | `02-backend-api-security` |
| Supabase/Postgres, RLS, policies, service role keys, migrations, backups | `03-supabase-database-security` |
| Vercel/Railway/Render deploy, DNS, SSL/TLS, env vars, CI/CD, rollback | `04-infra-deployment-security` |
| Production monitoring, uptime, alerting, Sentry, backup, incident response | `05-production-operations` |
| LGPD/privacy/compliance, consent, retention, DSR, subprocessors, audit evidence | `06-compliance-governance-lgpd` |
| Core Web Vitals, caching, image optimization, bundles, DB/API performance, load testing | `07-performance-scalability` |
| Git workflow, tests, code quality, env management, observability, scripts, runbooks | `08-devops-observability` |

## Required workflow for audits

1. Create a working branch, unless the user explicitly asks for read-only analysis.
2. Snapshot the current state:
   - `git status --short`
   - package manager and framework detection
   - main directories and deployment targets
3. Run safe reconnaissance:
   - `rg` for secrets, auth, API routes, DB clients, storage usage, webhooks, migrations
   - inspect config files and environment examples
   - run existing tests/build when practical
4. Classify findings by severity: P0, P1, P2, P3.
5. Fix only what the user asked to fix, unless a P0 is found. For P0, stop and report before making risky changes.
6. After changes, run the smallest verification suite that proves the fix.
7. Produce a final report with evidence and remaining risks.

## Default commands

Use these when applicable. Do not fail the task just because one command is unavailable; record the failure and continue with alternatives.

```bash
git status --short
find . -maxdepth 3 -type f | sed 's#^./##' | sort | head -200
rg -n --hidden --glob '!node_modules' --glob '!dist' --glob '!build' --glob '!.git' \
  'NEXT_PUBLIC_|VITE_|REACT_APP_|SUPABASE_SERVICE_ROLE|OPENAI_API_KEY|ANTHROPIC_API_KEY|STRIPE_SECRET|sk-[A-Za-z0-9]|BEGIN PRIVATE KEY|DATABASE_URL'
rg -n 'export async function|app/api|pages/api|use server|createClient|localStorage|sessionStorage|middleware|rateLimit|Ratelimit|z\.object|safeParse|webhook|signature|audit_log|Sentry|health' .
```

## Final response format

Use this structure unless the user requests another format:

```markdown
# Result

## Executive summary

## Findings
| Severity | Domain | Evidence | Risk | Fix |
|---|---|---|---|---|

## Changes made

## Verification

## Remaining risks

## Next actions
```
