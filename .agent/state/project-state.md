# BIBO Balance — Project State

Status: ARCHITECTURE / SPECIFICATION PHASE

Last updated by agent toolkit bootstrap: 2026-10-01.

## Completed conceptual work

- project identity selected: BIBO Balance;
- simulation-first scope established;
- four independent rod-length actions established;
- arbitrary 3D gravity concept established;
- rolling/contact requirement established;
- fixed friction coefficient proposed for initial deterministic version;
- progressive disturbance curriculum established;
- C/CUDA/Python/TensorFlow stack established;
- local research interface direction established;
- public web interface direction established;
- common state-contract principle established;
- physics-based RL baseline established;
- physics-informed RL identified as a later extension.

## Current implementation status

No implementation state has been independently verified by this toolkit yet.

Treat actual repository code as authoritative over this file.

## Immediate engineering priorities

1. Freeze mechanical constraints.
2. Build/test geometry reference implementation.
3. Build deterministic CPU ball physics.
4. Validate contact and rolling behavior.
5. Add actuator/platform dynamics.
6. Add CUDA batch path.
7. Add RL baseline.
8. Build robustness curriculum.
9. Build local renderer.
10. Build public renderer.
11. Evaluate physics-informed extension experimentally.

## Rule

Update this file whenever a major milestone materially changes the implementation state.
