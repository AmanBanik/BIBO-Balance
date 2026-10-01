# Visualization Rules

## Local

C++ + OpenGL + Dear ImGui.

Use it for:

- debug vectors,
- energy,
- trajectory,
- camera views,
- actuator data,
- CUDA telemetry,
- RL telemetry,
- interactive parameter editing.

## Web

TypeScript + Three.js + WebGPU/WebGL2 fallback.

Use it for:

- polished 3D scene,
- simple controls,
- replay,
- public explanation,
- performance-safe interaction.

## Shared truth

Renderers consume the common state contract.

Do not duplicate physics equations into front-end code unless they are explicitly a client-side visualization-only approximation.
