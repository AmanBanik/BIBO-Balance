#!/usr/bin/env python3
"""Generate a session handoff skeleton from the current BIBO state files."""

from __future__ import annotations

from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
AGENT = ROOT / ".agent"
STATE = AGENT / "state"

project_state = (STATE / "project-state.md").read_text(encoding="utf-8")
open_decisions = (STATE / "open-decisions.md").read_text(encoding="utf-8")

now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")

handoff = f"""# BIBO Balance Handoff

Generated: {now}

## Project state snapshot

{project_state}

## Open decisions snapshot

{open_decisions}

## Files changed this session

_Fill this section manually or by the agent._

## Tests run

_Fill this section manually._

## Failures / warnings

_Fill this section manually._

## Exact next action

_Fill this section manually. Be concrete._
"""

target = STATE / "handoff-latest.md"
target.write_text(handoff, encoding="utf-8")
print(target)
