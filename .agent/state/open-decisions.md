# BIBO Balance — Open Decisions

These are deliberately unresolved. Agents must not silently choose them.

## OD-001 — Exact four-rod mechanical constraint model

Need to define:

- base anchor coordinates;
- platform corner coordinates;
- whether rods are telescoping rigid links;
- passive joint type;
- allowed platform translation;
- allowed platform yaw;
- allowed platform pitch/roll;
- whether base points are fixed in world space;
- whether rod axes are initially vertical only or constrained to stay vertical;
- how infeasible rod-length commands are handled.

**Priority:** BLOCKING for final pose solver.

## OD-002 — Platform pose parameterization

Candidates:

- rigid pose + quaternion;
- rigid pose + rotation matrix;
- constrained pose with reduced coordinates.

Preferred internal representation is quaternion or rotation matrix, but the final reduced DOF model depends on OD-001.

## OD-003 — Contact solver fidelity

Candidates:

- reduced planar rolling model;
- full rigid sphere-plane contact;
- impulse/contact formulation.

Start simple and validate before increasing complexity.

## OD-004 — Actuator dynamics

Need to choose:

- position-only actuator;
- bounded velocity actuator;
- bounded acceleration actuator;
- explicit actuator lag.

## OD-005 — RL algorithm

Candidate set:

- PPO,
- SAC,
- TD3.

Must be selected experimentally.

## OD-006 — Vision encoder

Need to decide whether the final visual controller uses:

- stacked frames,
- recurrent model,
- temporal convolution,
- transformer-like temporal fusion.

## OD-007 — Public deployment mode

Candidates:

- deterministic replay;
- browser-side simplified physics;
- remote live simulation.

Start with replay.

## OD-008 — Physics-informed learning formulation

Must define exactly which residuals/constraints are included before calling the system physics-informed.
