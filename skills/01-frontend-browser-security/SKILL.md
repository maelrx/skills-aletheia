---
name: 01-frontend-browser-security
description: Use when auditing or hardening browser-side code in React/Next.js/Vite apps. Checks exposed public env vars, source maps, client-side route protection, localStorage/sessionStorage, CORS/CSP, bundle leakage, and frontend failure states.
---


# Frontend Browser Security

## Mission

Protect the only part of the system that runs on someone else's machine: the browser. Anything shipped to the browser is public. The goal is to ensure secrets, privileged data, privileged logic, and authorization decisions are not living in client-side code.

## Use when

- The project uses Next.js, React, Vite, Supabase, Vercel, Lovable, Bolt, v0, or similar AI-generated frontend stacks.
- The user asks about exposed keys, frontend security, protected pages, DevTools leakage, source maps, localStorage, CORS, or CSP.
- Before client delivery of any web app.

## Core mental model

Server-side code can keep secrets. Browser-side code cannot. A secret in a client component, public env variable, source map, localStorage value, or bundle string must be treated as already exposed.

## Workflow

### 1. Identify the browser/server boundary

Inspect framework structure:

```bash
find app pages src components -maxdepth 4 -type f 2>/dev/null | sort | head -250
rg -n '"use client"|use client|middleware|export async function|app/api|pages/api|server action|use server' app pages src 2>/dev/null
```

Mark which routes/components run in the browser and which run on the server.

### 2. Search for exposed secrets and public env misuse

```bash
rg -n --hidden --glob '!node_modules' --glob '!dist' --glob '!build' --glob '!.git' \
  'NEXT_PUBLIC_|VITE_|REACT_APP_|PUBLIC_|SUPABASE_SERVICE_ROLE|OPENAI_API_KEY|ANTHROPIC_API_KEY|STRIPE_SECRET|DATABASE_URL|PRIVATE_KEY|sk-[A-Za-z0-9]' .
```

Flag as P0 if any private credential is in:

- client component,
- public env variable,
- committed `.env`,
- generated bundle,
- public config file,
- source map,
- docs/example that contains a real value.

Allowed public values may include Supabase URL and anon key, analytics public IDs, and publishable payment keys. Private provider keys are never allowed.

### 3. Audit source maps and bundle leakage

Inspect config:

```bash
rg -n 'productionBrowserSourceMaps|sourceMap|sourcemap|devtool|hidden-source-map' next.config.* vite.config.* webpack.config.* package.json 2>/dev/null
```

For production apps, browser source maps must not expose readable original source unless intentionally configured with restricted access.

Search hardcoded sensitive strings:

```bash
rg -n --hidden --glob '!node_modules' --glob '!dist' --glob '!build' 'admin|internal|secret|token|password|private|TODO|FIXME|client_id|client_secret' app pages src public 2>/dev/null
```

### 4. Verify route protection is server-side

Search for client-only redirects:

```bash
rg -n 'useEffect\(|useRouter\(|router\.push|redirect\(|isAdmin|role|session|auth' app pages src 2>/dev/null
```

Red flags:

- admin/dashboard page protected only by `useEffect`, `useRouter`, or client state;
- sensitive HTML/data rendered before redirect;
- no `middleware.ts` or server-side session check for protected routes;
- API routes return data without checking session server-side.

Correct pattern:

- middleware for route access,
- Server Component/session verification before rendering sensitive content,
- API route auth before returning data,
- admin role checked on server, never only in UI.

### 5. Audit browser storage

```bash
rg -n 'localStorage|sessionStorage|document\.cookie|indexedDB|cookies\(|setCookie|getCookie' app pages src 2>/dev/null
```

Never store:

- access tokens or refresh tokens,
- API keys,
- CPF/SSN/passport-like identifiers,
- payment data,
- full user profiles,
- privileged roles/permissions used as authority.

Prefer secure, HttpOnly, SameSite cookies for session tokens.

### 6. Audit CORS and CSP

```bash
rg -n 'Access-Control-Allow-Origin|cors\(|headers\(|Content-Security-Policy|connect-src|script-src|unsafe-inline|unsafe-eval' .
```

Red flags:

- `Access-Control-Allow-Origin: *` on credentialed APIs;
- broad `connect-src *`;
- permanent `unsafe-eval` or unbounded `unsafe-inline`;
- missing CSP for production apps handling personal data.

### 7. Check failure states that leak internals

Search UI error handling:

```bash
rg -n 'error\.message|JSON\.stringify\(error|stack|console\.error|throw new Error|ErrorBoundary|error.tsx' app pages src 2>/dev/null
```

User-facing errors must not expose stack traces, internal table names, raw provider errors, or credentials.

## Common fix patterns

- Move secret-using logic into API routes or Server Actions.
- Replace `NEXT_PUBLIC_*` private keys with server-only env vars.
- Add middleware/server checks before rendering protected pages.
- Replace localStorage tokens with secure cookie/session provider pattern.
- Add restrictive CSP gradually in report-only mode, then enforce.
- Disable production browser source maps unless intentionally secured.

## Output contract

```markdown
# Frontend Browser Security Report

## Executive summary

## Findings
| Severity | Evidence | Risk | Fix | Verification |
|---|---|---|---|---|

## Exposed-secret review

## Route protection review

## Browser storage review

## CORS/CSP review

## Changes made

## Remaining risks
```

## Stop criteria

Stop and report immediately if you find a real production secret in browser-reachable code or Git history. Recommend rotation before continuing.
