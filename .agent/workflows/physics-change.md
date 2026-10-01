# Workflow: Physics Change

Required gate sequence:

```text
mechanical assumptions
→ equations
→ reference CPU implementation
→ invariants
→ deterministic scenario
→ numerical validation
→ optional CUDA implementation
→ benchmark
```

If the change alters the mechanical DOF model, resolve the relevant open decision first.

Required artifacts:

- equation note;
- test cases;
- expected behavior;
- failure cases.
