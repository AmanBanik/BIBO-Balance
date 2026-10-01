# Workflow: CUDA

1. Identify CPU reference function.
2. Define independent batch dimension.
3. Choose SoA/AoS deliberately.
4. Define H2D/D2H boundary.
5. Implement kernel.
6. Add runtime error checks.
7. Compare against CPU.
8. Benchmark enough workload to amortize overhead.
9. Record hardware/toolchain.
10. Keep CPU path intact.
