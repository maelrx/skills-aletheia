#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
missing=0

for skill in "$ROOT"/skills/*; do
  if [[ ! -f "$skill/SKILL.md" ]]; then
    echo "Missing SKILL.md in $skill"
    missing=1
    continue
  fi
  if ! head -1 "$skill/SKILL.md" | grep -q '^---$'; then
    echo "Missing YAML frontmatter marker in $skill/SKILL.md"
    missing=1
  fi
  if ! grep -q '^description:' "$skill/SKILL.md"; then
    echo "Missing description in $skill/SKILL.md"
    missing=1
  fi
  if ! grep -q '^## Output contract' "$skill/SKILL.md"; then
    echo "Missing output contract in $skill/SKILL.md"
    missing=1
  fi
  if ! grep -q '^## Stop criteria' "$skill/SKILL.md"; then
    echo "Missing stop criteria in $skill/SKILL.md"
    missing=1
  fi
done

if [[ "$missing" -eq 0 ]]; then
  echo "Skill pack smoke test passed."
else
  echo "Skill pack smoke test failed."
  exit 1
fi
