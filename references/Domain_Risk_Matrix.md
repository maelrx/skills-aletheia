# Domain Risk Matrix

Use this matrix to classify findings consistently across all skills.

## Severity definitions

| Severity | Meaning | Examples | Default action |
|---|---|---|---|
| P0 / Critical | Immediate or likely catastrophic impact to secrets, data, money, or uptime. | Private API key in frontend; Supabase service role exposed; RLS disabled on customer tables; admin auth bypass; destructive migration without backup; live outage. | Stop, report, rotate/backup/contain before normal work. |
| P1 / High | Serious risk that can become catastrophic under normal usage or common attack paths. | Missing ownership checks; weak tenant filters; no rate limit on paid API; webhook without signature; no production backup; preview deploy uses prod secrets. | Fix before handoff or production traffic. |
| P2 / Medium | Material weakness that degrades security, reliability, compliance, or performance but is not immediately catastrophic. | Missing CSP; slow unindexed query; incomplete consent records; weak logging; untested restore; no E2E smoke test. | Schedule fix in current stabilization cycle. |
| P3 / Low | Hygiene, documentation, polish, or non-blocking improvement. | Missing runbook detail; minor bundle optimization; naming inconsistency; README gap. | Backlog or fix opportunistically. |

## Domain priorities

1. Secrets and credentials.
2. Authentication and authorization.
3. Database access/RLS/tenant isolation.
4. Data-loss prevention/backups/migrations.
5. Billing/cost abuse/rate limits.
6. Production visibility/alerting.
7. Performance and scalability.
8. Compliance evidence and governance.
9. Documentation and handoff polish.

## Evidence quality scale

- **Strong**: exact file/line, SQL result, command output, dashboard setting, or reproduced behavior.
- **Medium**: code pattern strongly suggests issue but runtime verification unavailable.
- **Weak**: suspicion based on absence or convention. Mark as needs verification.

Do not present weak evidence as fact.
