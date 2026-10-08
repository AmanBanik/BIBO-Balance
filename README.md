# BIBO Balance: Progress & Phase Tracker

**Brief Intro:**  
BIBO Balance is a simulation-first, physics-based reinforcement learning project. The goal is to use a neural controller to continuously command the lengths of four vertical corner actuators, manipulating a rigid 3:1 platform to stabilize a rolling ball. It features a custom deterministic C/CUDA physics engine and a Python/TensorFlow machine learning layer.

---

## 🟢 Phase 0: Freeze the Mechanical Definition (Completed)
- [x] Define coordinate convention (World Z-up).
- [x] Define actuator joint model (Vertical actuators with spherical joints allowing lateral slip).
- [x] Define base anchor geometry (Identical 3:1 footprint).
- [x] Decide on contact physics fidelity (Full rigid-body sphere with angular inertia and rolling resistance).
- [x] Choose C Toolchain (C11, CMake, GCC/Clang).

## 🟢 Phase 1: Deterministic Geometry Engine (Completed)
- [x] Scaffold core directory structure (`src/`, `include/`, `tests/`, etc.).
- [x] Implement core structs (`Vec3`, `Quat`, `Pose`, `BallState`).
- [x] Implement `Vec3` vector mathematics.
- [x] Implement `Quat` quaternion operations (multiplication, axis-angle, rotations).
- [x] Implement Platform Plane & Normal derivations.
- [x] Implement Rod kinematic distance constraints.
- [x] Configure CMake and pass C-based geometry unit tests.

## 🟢 Phase 2: Ball Physics (Completed)
- [x] Implement configurable 3D gravity decomposition ($g_{normal}$, $g_{parallel}$).
- [x] Implement rigid-body contact detection and resolution.
- [x] Implement rolling mechanics and friction (slip vs. grip thresholds).
- [x] Implement temporal time integration (RK4 or Euler).
- [x] Implement Energy (Kinetic/Potential) calculations.
- [x] Implement stability detection window logic.

## 🟢 Phase 3: Actuator/Platform Dynamics (Completed)
- [x] Implement rod-length rate limiting and constraints.
- [x] Translate $\Delta L$ commands into moving-platform velocity vectors.
- [x] Factor platform movement into contact forces.

## 🟢 Phase 4: CPU Reference Simulator (Completed)
- [x] Finalize deterministic fixed-step C simulator.
- [x] Expose C ABI for external state access.
- [x] Create deterministic replay test suite and benchmark throughput.

## 🟢 Phase 5: CUDA Batch Simulator (Completed)
- [x] Port geometry and physics kernels to CUDA.
- [x] Implement VRAM Allocation for batched state arrays.
- [x] Write global step kernel.
- [x] Expose batched step to Python & Benchmark.

## 🟢 Phase 6: RL V0 (Baseline Controller) (Completed)
- [x] Scaffold Actor-Critic neural networks in TensorFlow.
- [x] Implement PPO rollout buffers and advantage estimation.
- [x] Write the PPO optimization step and training loops.
- [x] Train continuous action agent and save weights.

## 🟡 Phase 7: Robust RL (In Progress)
- [ ] Introduce randomized initial drops.
- [ ] Introduce randomized gravity vectors and friction.
- [ ] Train over disturbance curriculum.

## ⚪ Phase 8: Vision Policy
- [ ] Swap privileged state for multi-camera CNN encodings.
- [ ] Add temporal processing for velocity inference.

## ⚪ Phase 9: Physics-Informed Extension
- [ ] Add explicit physical constraint residuals to the RL loss function.
- [ ] Measure sample efficiency differences vs. baseline.

## ⚪ Phase 10: Local Research Interface
- [ ] Build C++ / OpenGL / Dear ImGui desktop interface.
- [ ] Bind real-time telemetry (energy plots, FPS, actuator effort).

## ⚪ Phase 11: Public Web Demonstrator
- [ ] Build TypeScript / Three.js / WebGPU public client.
- [ ] Set up deterministic replay WebSocket/Server.

## ⚪ Phase 12: Final Verification / Demonstration
- [ ] Generate standard benchmarking reports.
- [ ] Curate and record edge-case demonstration scenarios (A-F).
- [ ] Finalize artifact bundle.
