#!/usr/bin/env bash
set -euo pipefail

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_DIR="${1:-$(pwd)}"

mkdir -p "$PROJECT_DIR/.agent-skills"
cp "$PACK_DIR/AGENTS.md" "$PROJECT_DIR/AGENTS.md"
cp -R "$PACK_DIR/skills" "$PROJECT_DIR/.agent-skills/"
cp -R "$PACK_DIR/references" "$PROJECT_DIR/.agent-skills/"

echo "Synced AGENTS.md and .agent-skills into: $PROJECT_DIR"
