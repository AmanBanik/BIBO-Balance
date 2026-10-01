# BIBO Balance — Compact Project Context

## Identity

**Name:** BIBO Balance

**Working descriptor:** CUDA-Accelerated, Physics-Based Reinforcement Learning System for 3D Ball Stabilization

**Mode:** Simulation-first.

## Core mechanism

A rigid rectangular platform is supported by four corner-linked actuators/rods.

The controller directly commands:

\[
\Delta L_1,\Delta L_2,\Delta L_3,\Delta L_4
\]

The rod angles are not direct controller actions.

Changing rod lengths changes the rigid platform's pose. The ball rolls over the resulting planar surface.

## Ball/environment

- arbitrary ball release position/time;
- configurable 3D gravity;
- rolling trajectory;
- contact;
- friction;
- energy/stability diagnostics;
- later robustness disturbances.

Initial friction proposal:

\[
\mu=0.9
\]

Robustness extension:

\[
\mu\sim U(\mu_{\min},\mu_{\max})
\]

## Gravity convention

Recommended world frame:

\[
+x=\text{platform length}
\]

\[
+y=\text{platform width}
\]

\[
+z=\text{world up}
\]

Gravity:

\[
\mathbf g =
g
\begin{bmatrix}
\sin\phi\cos\theta\\
\sin\phi\sin\theta\\
\cos\phi
\end{bmatrix}
\]

with:

\[
\theta\in[0,2\pi)
\]

and a configurable inclination range.

## Learning

Baseline:

**physics-based continuous-control RL**

Future extension:

**physics-informed RL**

Candidate algorithms:

- PPO
- SAC
- TD3

Progressive observation strategy:

1. privileged state,
2. phase/state observations,
3. three-view visual observations,
4. robust randomized environment.

## Compute stack

### Numerical reference
C.

### GPU
CUDA.

### Learning/orchestration
Python + TensorFlow.

### Local visualization
C++ + OpenGL + Dear ImGui.

### Public visualization
TypeScript + Three.js + WebGPU/WebGL2 fallback.

## Architecture principle

Physics:

```text
geometry → kinematics → pose → ball dynamics → contact/friction → energy/stability
```

Controller:

```text
observations → neural policy → ΔL1..ΔL4
```

Closed loop:

```text
rod lengths
→ platform pose
→ ball state
→ observations
→ policy
→ rod-length changes
```

## Non-negotiable unresolved item

The exact four-rod mechanical constraint model must be formally frozen before final pose solving is implemented.

Do not invent the mechanism.

## Master specification

The full `MASTER.md` remains the detailed architecture/physics/RL/build reference. This file is the compressed context pack for agents.

