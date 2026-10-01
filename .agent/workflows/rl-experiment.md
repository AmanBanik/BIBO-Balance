# Workflow: RL Experiment

1. Freeze simulator version.
2. Define config and seed set.
3. Define observation contract.
4. Define action normalization.
5. Define reward components separately.
6. Define training distribution.
7. Define held-out evaluation distribution.
8. Run baseline.
9. Run candidate.
10. Compare.
11. Record failures.
12. Update experiment registry.

Never change physics and policy architecture in the same experiment unless the interaction itself is the research question.
