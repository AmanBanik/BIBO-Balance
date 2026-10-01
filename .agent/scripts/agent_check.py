#!/usr/bin/env python3
"""Project-independent structural health check for the BIBO agent toolkit."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
AGENT = ROOT / ".agent"

REQUIRED = [
    "AGENT.md",
    "README.md",
    "context/project-context.md",
    "state/project-state.md",
    "state/open-decisions.md",
    "state/decision-log.md",
    "state/handoff-latest.md",
    "roles/agent-lead.md",
    "subagents/geometry.md",
    "subagents/physics.md",
    "subagents/cuda.md",
    "subagents/rl.md",
    "subagents/qa.md",
    "workflows/feature.md",
    "workflows/physics-change.md",
    "workflows/rl-experiment.md",
    "schemas/state.v1.json",
]

failures = []
for rel in REQUIRED:
    if not (AGENT / rel).exists():
        failures.append(f"MISSING: {rel}")

# Check the state file contains the critical unresolved geometry gate.
open_decisions = (AGENT / "state/open-decisions.md").read_text(encoding="utf-8")
if "OD-001" not in open_decisions:
    failures.append("OPEN DECISION OD-001 missing")

# Check agent rules mention explicit user override.
guide = (AGENT / "AGENT.md").read_text(encoding="utf-8")
if "Explicit user instruction in the current task" not in guide:
    failures.append("Authority hierarchy is incomplete")

print(f"BIBO agent toolkit root: {AGENT}")
print(f"Required files checked: {len(REQUIRED)}")

if failures:
    print("FAIL")
    for item in failures:
        print(f" - {item}")
    raise SystemExit(1)

print("PASS")
