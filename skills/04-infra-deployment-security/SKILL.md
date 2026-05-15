---
name: 04-infra-deployment-security
description: Use when auditing deployment infrastructure for Vercel/Railway/Render/Netlify/GitHub projects. Checks hosting configuration, deploy secrets, preview environments, CI/CD, DNS, SSL/TLS, environment separation, rollback, and build logs.
---


# Infrastructure and Deployment Security

## Mission

Secure the path from code to user: repository, CI/CD, build, deploy platform, environment variables, preview deployments, DNS, SSL/TLS, logs, and rollback. Infrastructure defaults usually optimize convenience, not security.

## Use when

- The app is deployed or about to deploy.
- The project uses Vercel, Netlify, Railway, Render, GitHub Actions, Cloudflare, Supabase, or custom domains.
- The user asks about production setup, secrets, CI/CD, DNS, SSL, preview deploys, or rollback.

## Workflow

### 1. Inventory deployment surface

```bash
find . -maxdepth 3 -type f \( -name 'vercel.json' -o -name 'netlify.toml' -o -name 'render.yaml' -o -name 'railway.toml' -o -name 'Dockerfile' -o -name 'docker-compose.yml' -o -path './.github/workflows/*' \) -print
rg -n 'vercel|netlify|railway|render|docker|github actions|deploy|preview|production|staging' .github package.json README* docs . 2>/dev/null
```

### 2. Check secrets across repo and Git history

```bash
rg -n --hidden --glob '!node_modules' --glob '!dist' --glob '!build' --glob '!.git' \
  'DATABASE_URL|SUPABASE_SERVICE_ROLE|OPENAI_API_KEY|ANTHROPIC_API_KEY|STRIPE_SECRET|RESEND_API_KEY|SENDGRID_API_KEY|PRIVATE_KEY|BEGIN PRIVATE KEY|sk-[A-Za-z0-9]' .
git log --all --name-only --pretty=format: | sort -u | rg '^\.env|env\.local|\.pem|\.key|service-account|credentials' || true
```

If real secrets appear, recommend immediate rotation and history cleanup.

### 3. Verify environment separation

Required separation:

- development secrets for local;
- staging/preview secrets for PR deploys;
- production secrets only for production.

Red flags:

- preview deploys use production database/service role;
- `.env.example` contains real secrets;
- production secrets available to untrusted PRs;
- no documented env var inventory.

### 4. Review CI/CD safety

Inspect workflows:

```bash
find .github/workflows -type f -maxdepth 2 -print -exec sed -n '1,220p' {} \; 2>/dev/null
```

Required:

- protected main branch;
- PR review before production deploy;
- build, lint, type-check, tests before deploy;
- least-privilege tokens;
- no secrets printed in logs;
- deployment jobs restricted to intended branches/environments.

### 5. Review DNS and SSL/TLS

If domain is known:

```bash
curl -I http://example.com
curl -I https://example.com
```

Required:

- HTTP redirects to HTTPS;
- valid certificate;
- no mixed content;
- HSTS considered for stable production domains;
- SPF/DKIM/DMARC configured when sending email from the domain.

### 6. Rollback readiness

Required:

- Known previous deploy rollback method.
- Database rollback/restore plan documented separately from app rollback.
- Release notes/changelog identify what changed.
- No production deploy depends on unreviewed AI-generated diff.

### 7. Build/deploy logs

Inspect build scripts and logs if accessible. Red flags:

- env vars echoed;
- stack traces printing connection strings;
- build output includes public source maps or private endpoints;
- logs accessible to people who do not need secret visibility.

## Output contract

```markdown
# Infrastructure/Deployment Security Report

## Deployment map

## Secrets and environment review

## CI/CD review

## DNS and SSL/TLS review

## Rollback review

## Findings
| Severity | Evidence | Risk | Fix | Verification |
|---|---|---|---|---|
```

## Stop criteria

Stop and report before rotating production secrets, deleting Git history, changing DNS, modifying production CI/CD, or redeploying production without rollback clarity.
