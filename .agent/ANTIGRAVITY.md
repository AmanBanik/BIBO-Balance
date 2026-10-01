# Antigravity CLI Integration Notes

This toolkit intentionally avoids assuming a vendor-specific configuration syntax.

Use `.agent/AGENT.md` as the canonical instruction file.

Recommended agent startup sequence:

```text
1. load .agent/AGENT.md
2. load .agent/context/project-context.md
3. load .agent/state/project-state.md
4. load .agent/state/open-decisions.md
5. load the role/subagent relevant to the task
6. select a workflow
```

Recommended context persistence:

```text
AGENT.md
→ context
→ state
→ workflow
→ specialist output
→ code
→ tests
→ handoff
```

If the CLI supports project-level agent instructions, point them to `AGENT.md`.

If it supports subagents/agents as named roles, map them to `.agent/subagents/*.md`.

If it supports executable tools, expose `.agent/tools/` and `.agent/scripts/`.

No vendor-specific secret, token, or runner configuration belongs in this directory.
