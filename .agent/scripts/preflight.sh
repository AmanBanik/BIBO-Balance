#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

echo "== BIBO Agent Preflight =="
python .agent/scripts/agent_check.py
python .agent/scripts/physics/physics_sanity.py
python .agent/scripts/rl/rl_sanity.py

if [[ -f MASTER.md ]]; then
  python .agent/scripts/docs/validate_markdown.py MASTER.md || true
fi

echo "Preflight completed."
