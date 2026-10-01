# BIBO Balance Agent Toolkit

A project-specific operating system for coding agents working on **BIBO Balance**.

This `.agent` directory is intentionally independent from any other project's agent tooling. It is designed around BIBO's specific problem:

> a simulation-first 3D mechanical control system in which four independently length-controlled corner actuators change the pose of a rigid planar platform while a rolling ball evolves under gravity, contact, friction, actuator constraints, and a continuously sampled neural controller.

The toolkit is organized around five persistent layers:

1. **Truth** — `context/` and the project master specification.
2. **Rules** — `rules/` and `AGENT.md`.
3. **Specialists** — `subagents/` and `roles/`.
4. **Execution** — `workflows/` and `scripts/`.
5. **Memory** — `state/`, handoffs, decisions, experiment records.

## Entry points

- `AGENT.md` — mandatory operating contract.
- `context/project-context.md` — compact project context.
- `context/contracts/` — interfaces that agents must preserve.
- `state/project-state.md` — current implementation state.
- `state/open-decisions.md` — unresolved design questions.
- `state/decision-log.md` — decisions and supersessions.
- `workflows/` — repeatable task protocols.
- `scripts/` — machine-checkable validation.

## Agent philosophy

The toolkit assumes the project will become large enough that a single context window is not a reliable memory store.

Therefore:

> **Agents must externalize important decisions, assumptions, test results, and unresolved questions into repository files.**

The human developer remains the final authority. A coding agent may infer implementation details inside an already-approved design space, but it must not silently resolve an explicitly open mechanical or scientific decision.

## Quick start

Before making changes:

```bash
cat .agent/AGENT.md
cat .agent/context/project-context.md
cat .agent/state/project-state.md
cat .agent/state/open-decisions.md
```

Then choose the workflow matching the task.

For a generic health check:

```bash
python .agent/scripts/agent_check.py
```

For RL smoke checks:

```bash
python .agent/scripts/rl/rl_sanity.py
```

For physics sanity checks:

```bash
python .agent/scripts/physics/physics_sanity.py
```

For a session handoff:

```bash
python .agent/scripts/make_handoff.py
```

## Important

This toolkit is deliberately **tool-agnostic**. It can be used from Antigravity CLI or another coding-agent environment without assuming a particular vendor-specific prompt format.

