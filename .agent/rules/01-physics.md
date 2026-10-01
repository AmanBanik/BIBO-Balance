# Physics Rules

## Invariants

- Platform is rigid and planar.
- Ball is not teleported.
- Physics uses explicit units.
- Coordinate frames are documented.
- Contact state is explicit.
- Actuator constraints are explicit.
- Renderer cannot mutate physics.

## Numerical safety

Every numerical subsystem should consider:

- NaN,
- Inf,
- zero-length vectors,
- degenerate planes,
- impossible geometry,
- penetration,
- unstable timestep,
- excessive actuator commands.

## Reference implementation

A CPU reference path is required before treating CUDA as authoritative.

## Energy

Energy is a diagnostic and can be part of reward design.

Because actuators actively move the platform, total mechanical energy is not necessarily monotonically decreasing.
