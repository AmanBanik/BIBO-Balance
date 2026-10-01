# Agent Prompt Snippets

Use these as task prefixes when helpful.

## Implement a feature

> Read `.agent/AGENT.md`, the relevant state files, and the relevant subagent contract first. Do not resolve open mechanical decisions silently. State acceptance criteria before editing.

## Review physics

> Act as the BIBO Physics Engineer + Scientific Reviewer. Separate confirmed facts, derived assumptions, and unresolved decisions. Derive the equations before proposing code.

## Optimize CUDA

> Preserve the CPU reference. Propose the batch/data-transfer model, define the parity test, then benchmark before and after.

## Build RL

> Freeze the simulator/config first. Define observation/action/reward contracts, then implement and evaluate with a held-out distribution.

## Build visualization

> Consume the shared render-state contract. Do not move authoritative physics into the renderer.

## End session

> Update project state, decision log if needed, tests/results, and generate a concise handoff for the next agent.
