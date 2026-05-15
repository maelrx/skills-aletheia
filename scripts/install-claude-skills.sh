#!/usr/bin/env bash
set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

mkdir -p "$TARGET_DIR"
cp -R "$PACK_DIR/skills/"* "$TARGET_DIR/"

echo "Installed skills to: $TARGET_DIR"
find "$TARGET_DIR" -maxdepth 2 -name SKILL.md | sort
