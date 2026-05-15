# Skills Aletheia

Um pacote portátil de skills para Claude Code, Codex e outros agentes de código. Ele converte os documentos SSOT de segurança e operações fornecidos em skills operacionais reutilizáveis em inglês para auditar, fortalecer e entregar aplicações web construídas com IA.

O pacote é intencionalmente agnóstico em relação a ferramentas:

- **Claude Code** pode consumir cada pasta em `skills/<skill-name>/SKILL.md` como uma skill.
- **Codex** pode consumir `AGENTS.md` como orientação de nível de projeto e pode ser instruído com os arquivos avulsos em `prompts/`.
- **Qualquer agente** pode usar as skills como playbooks procedurais, porque cada skill tem gatilhos, escopo, fluxo de trabalho, comandos, contrato de saída e critérios de parada.

## Conteúdo do Pacote

| Caminho | Finalidade |
|---|---|
| `AGENTS.md` | Instruções operacionais para Codex/projeto e índice de roteamento de skills. |
| `skills/00-full-stack-delivery-gate/SKILL.md` | Gate completo de entrega ao cliente, cobrindo todos os domínios. |
| `skills/01-frontend-browser-security/SKILL.md` | Segurança no navegador: segredos expostos, autenticação no cliente, armazenamento, CSP/CORS, source maps. |
| `skills/02-backend-api-security/SKILL.md` | Segurança de API/backend: auth/authz, validação, IDOR, atribuição em massa, webhooks, limites de taxa. |
| `skills/03-supabase-database-security/SKILL.md` | Segurança de Supabase/Postgres: RLS, políticas, chaves service role, backups, migrações, pooling. |
| `skills/04-infra-deployment-security/SKILL.md` | Segurança de hospedagem/deploy: Vercel, segredos, CI/CD, DNS, SSL/TLS, ambientes, rollback. |
| `skills/05-production-operations/SKILL.md` | Prontidão para produção: logs, uptime, alertas, Sentry, backup, DR, logs de auditoria. |
| `skills/06-compliance-governance-lgpd/SKILL.md` | Governança/compliance: mapeamento de dados orientado à LGPD, consentimento, retenção, DSR, DPAs, evidências de auditoria. |
| `skills/07-performance-scalability/SKILL.md` | Performance e escala: Core Web Vitals, cache, banco de dados, APIs, imagens, bundles, renderização, testes de carga. |
| `skills/08-devops-observability/SKILL.md` | DevOps: fluxo Git, gates de qualidade, testes, ambientes, observabilidade, scripts, documentação. |
| `skills/09-ai-generated-project-triage/SKILL.md` | Triagem inicial para projetos herdados ou feitos por "vibe coding". |
| `prompts/*.md` | Prompts avulsos para ferramentas sem carregadores de skills. |
| `references/*.md` | Templates compartilhados de relatório e matriz de risco. |
| `scripts/install-claude-skills.sh` | Copia as skills para `~/.claude/skills`. |
| `scripts/sync-to-project.sh` | Copia `AGENTS.md` e referências para o repositório atual. |

## Instalação no Claude Code

```bash
cd skills-aletheia
bash scripts/install-claude-skills.sh
```

Isso copia todas as pastas em `skills/` para `~/.claude/skills/`.

## Instalação no Codex

Copie `AGENTS.md` para a raiz do repositório alvo, ou mescle seu conteúdo no `AGENTS.md` existente do repositório.

```bash
cd target-repo
cp /path/to/skills-aletheia/AGENTS.md ./AGENTS.md
mkdir -p .agent-skills
cp -R /path/to/skills-aletheia/skills .agent-skills/
cp -R /path/to/skills-aletheia/references .agent-skills/
```

Depois, peça ao Codex para executar a skill relevante pelo nome, por exemplo:

```text
Use the backend-api-security skill to audit this repository and produce a prioritized remediation plan.
```

## Ordem de auditoria recomendada

1. `09-ai-generated-project-triage`
2. `01-frontend-browser-security`
3. `02-backend-api-security`
4. `03-supabase-database-security`
5. `04-infra-deployment-security`
6. `07-performance-scalability`
7. `05-production-operations`
8. `08-devops-observability`
9. `06-compliance-governance-lgpd`
10. `00-full-stack-delivery-gate`

## Padrão de Severidade

Use a rubrica compartilhada em `references/Domain_Risk_Matrix.md`.

- **P0 / Crítico**: exposição ativa de segredo, acesso público ao banco de dados, bypass de autenticação, indisponibilidade em produção, risco de perda de dados ou risco jurídico/compliance irreversível.
- **P1 / Alto**: acesso não autorizado entre usuários ou tenants, falta de limites de taxa em APIs pagas, ausência de backups, migrações destrutivas, rollback quebrado.
- **P2 / Médio**: índices ausentes, CSP fraco, rastreamento de erros incompleto, separação ruim de ambientes, registros de consentimento incompletos.
- **P3 / Baixo**: lacunas de documentação, melhorias menores de hardening, refinamentos não bloqueantes de UX/performance.

## Contrato de Saída

Toda skill deve terminar com:

1. Resumo executivo.
2. Tabela de evidências.
3. Classificação de riscos.
4. Etapas exatas de remediação.
5. Comandos/testes de verificação.
6. Notas de handoff seguras para o cliente.

## Limite de Segurança

Estas skills são para auditoria defensiva, hardening e entrega profissional. Não as use para explorar sistemas de terceiros, burlar autorização, exfiltrar dados ou executar ações destrutivas. Para operações perigosas, como migrações, rotação de segredos, exclusão de dados ou deploys em produção, crie um backup, documente o caminho de rollback e exija aprovação humana explícita.
