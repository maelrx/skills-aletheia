# Universal Skill Authoring Pattern

Each skill in this pack follows this pattern so it can be adapted to Claude Code, Codex, or another agent.

## 1. Frontmatter

Claude Code skills use YAML frontmatter at the top of `SKILL.md`:

```yaml
---
name: skill-name
description: Use when ...
---
```

The description must be specific enough for automatic triggering.

## 2. Mission

One paragraph describing the invariant the skill protects.

## 3. Use when

Concrete triggers from user language and repository conditions.

## 4. Workflow

A deterministic sequence of checks. Prefer shell searches, tests, config inspection, and code evidence before subjective judgment.

## 5. Commands

Commands must be safe by default. Destructive commands require explicit approval and rollback.

## 6. Output contract

Every skill returns a structured report with evidence, severity, risk, fix, and verification.

## 7. Stop criteria

Clear conditions where the agent must stop and escalate instead of continuing autonomously.
