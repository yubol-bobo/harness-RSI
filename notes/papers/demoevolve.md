# DemoEvolve — Overcoming Sparse Feedback in Agentic Harness Evolution with Demonstrations

- **Authors:** Che et al. **[full list: see paper]**
- **Year / Venue:** 2026 (arXiv May 2026) / preprint
- **Link:** https://arxiv.org/abs/2605.24539
- **Ladder level:** 4 (harness evolution for frozen-model agents)

## TL;DR
In long-horizon stochastic tasks, self-rollout harness evolution suffers from noisy selection: sparse, high-variance scores can select inactive or non-causal edits. Feeding the coding proposer competent human demonstrations as reference experience makes harness evolution more sample-efficient, diagnosable, and stable.

## Problem
Harness evolution works when failures are short-horizon and attributable. In games like Balatro, rewards are sparse, same-seed rollouts vary, and trajectories drift — failures are hard to attribute to harness mechanisms.

## Method
1. Standard harness evolution loop with a coding proposer over a frozen-model agent's harness.
2. Augment the self-rollout archive with **human expert demonstrations** (positive state–action evidence).
3. Proposer compares agent behavior to demos to diagnose and edit model-facing harness mechanisms, narrowing the search space.

## Key results
- Identifies the **noisy-selection failure mode** of self-rollout evolution (abstract).
- Demonstrations improve sample efficiency, diagnosability, stability; self-rollout alone suffices for short-horizon, attributable settings (abstract). Numbers **[not reproduced]**.

## Why it matters for RSI
A concrete limit of pure self-improvement: when the evaluator is sparse/noisy, external positive evidence (humans) is valuable — consistent with Weng's "humans move up the stack" and "weak evaluators" challenges.

## Limitations
- Requires demonstrations (cost, availability); risk of imitating human style rather than optimal play.

## Connections
Self-Harness, AHE (observability), Continual Harness (long-horizon games), Voyager, imitation learning/DAgger.

## Questions to think about
1. How would you statistically detect a "non-causal" accepted edit? (ablation re-runs, paired seeds)
2. Can model-generated demos from a stronger model replace human demos?
