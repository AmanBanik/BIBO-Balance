# Render State Contract

The authoritative simulation publishes renderable state snapshots.

Required conceptual fields:

- time;
- ball pose/velocity;
- platform pose;
- platform normal;
- actuator lengths;
- gravity;
- vectors;
- trajectory;
- energy;
- stability;
- controller action;
- reward/telemetry as applicable.

## Local

C++/OpenGL/ImGui consumes the snapshot.

## Web

TypeScript/Three.js consumes the snapshot or replay.

## Rule

The renderer may derive:

- arrow endpoints;
- display-space scaling;
- camera-relative transforms;
- mesh orientation;

but it must not become the authoritative physics source.
