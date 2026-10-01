# Workflow: Bug Fix

1. Reproduce.
2. Identify invariant violated.
3. Find owner module.
4. Add a regression test before/with the fix.
5. Fix root cause.
6. Re-run original reproduction.
7. Run neighboring tests.
8. Record cause and fix if non-obvious.

Do not mask physics bugs in visualization or RL reward logic.
